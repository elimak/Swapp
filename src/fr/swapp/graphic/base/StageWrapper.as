package fr.swapp.graphic.base 
{
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.SoftKeyboardEvent;
	import flash.events.TouchEvent;
	import flash.geom.Point;
	import flash.system.Capabilities;
	import flash.utils.Dictionary;
	import fr.swapp.core.log.Log;
	import fr.swapp.graphic.styles.StyleCentral;
	import fr.swapp.utils.EnvUtils;
	import org.osflash.signals.Signal;
	
	/**
	 * @author ZoulouX
	 */
	public class StageWrapper extends ResizableComponent 
	{
		/**
		 * Si les composants seront redimensionnés automatiquement selon le DPI
		 */
		protected var _autoDPIOnMobileAndTablets				:Boolean;
		
		/**
		 * Le DPI de base pour la conversion sur téléphones
		 */
		protected var _baseDPIForPhones							:uint;
		
		/**
		 * Le DPI de base pour la conversion sur tablettes
		 */
		protected var _baseDPIForTablets						:uint;
		
		/**
		 * Le DPI de base pour la conversion sur PC / MAC
		 */
		protected var _baseDPIForComputers						:uint;
		
		/**
		 * Le ratio appliqué après le DPI auto
		 */
		protected var _ratio									:Number					= 1;
		
		/**
		 * Si on doit réagir au clavier virtuel (ne pas utiliser softKeyboardBehavior PAN si true)
		 */
		protected var _listenSoftKeyboard						:Boolean				= false;
		
		/**
		 * Le point pour le centrage
		 */
		protected var _stageSizeForCenterAlign					:Point;
		
		/**
		 * Le centre de gestion des styles
		 */
		protected var _styleCentral								:StyleCentral;
		
		/**
		 * La phase en cours
		 */
		protected var _phase									:int;
		
		
		/**
		 * Le ratio appliqué après le DPI auto
		 */
		public function get ratio ():Number { return _ratio; }
		
		/**
		 * Si on doit réagir au clavier virtuel (ne pas utiliser softKeyboardBehavior PAN si true)
		 */
		public function get listenSoftKeyboard ():Boolean { return _listenSoftKeyboard; }
		public function set listenSoftKeyboard (value:Boolean):void
		{
			_listenSoftKeyboard = value;
		}
		
		/**
		 * Le centre de gestion des styles
		 */
		public function get styleCentral ():StyleCentral { return _styleCentral; }
		
		/**
		 * Si on est en phase en cours
		 */
		public function get phase ():int { return _phase; }
		
		
		/**
		 * Le constructeur du wrapper de composants.
		 * Les redimensionnements / rotations du stage seront écoutées automatiquement.
		 * @param	pStageSizeForCenterAlign : Si ce point n'est pas null, le stage sera aligné par le centre. Les valeurs x et y du point doivent alors correspondrent à la taille du stage à la compilation (pour l'algo de centrage)
		 */
		public function StageWrapper (pStageSizeForCenterAlign:Point = null)
		{
			// Essayer de définir un nom pour le debug
			try
			{
				name = "StageWrapper";
			}
			catch (e:Error) { }
			
			// Si on a un point pour le centrage
			_stageSizeForCenterAlign = pStageSizeForCenterAlign;
			
			// Initialiser le manager de styles
			initStyleCentral();
			
			// Relayer
			super();
		}
		
		/**
		 * Initialiser le manager de styles
		 */
		protected function initStyleCentral():void 
		{
			
			// Créer le centre de gestion des styles
			_styleCentral = new StyleCentral();
			
			// Ecouter lorsque le style change
			_styleCentral.onStyleChanged.add(invalidateStyle);
			
			// Activer les styles sur ce container
			_styleEnabled = true;
		}
		
		/**
		 * Le composant est ajouté
		 */
		override protected function addedHandler (event:Event = null):void
		{
			// Ne jamais redimensionner l'UI
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			// Si on a pas de stage par défaut dans la classe ResizableComponent
			if (ResizableComponent.wrapper == null)
			{
				// On le défini
				ResizableComponent.wrapper = this;
			}
			
			// Alignement
			if (_stageSizeForCenterAlign == null)
			{
				stage.align = StageAlign.TOP_LEFT;
			}
			
			// Replacer
			stageResizedHandler();
			
			// Ecouter les phases
			stage.addEventListener(Event.ENTER_FRAME, phaseHandler);
			stage.addEventListener(Event.RENDER, phaseHandler);
			
			// Ecouter les redimentionnements
			stage.addEventListener(Event.RESIZE, stageResizedHandler);
			
			// Ecouter les changements de dimensions sur le clavier virtuel
			//_stage.addEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_ACTIVATE, stageResizedHandler);
			//_stage.addEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_ACTIVATING, stageResizedHandler);
			//_stage.addEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_DEACTIVATE, stageResizedHandler);
			
			// Relayer
			super.addedHandler(event);
		}
		
		/**
		 * Phase en cours
		 */
		protected function phaseHandler (event:Event):void
		{
			// On est en phase de rendu
			if (event.type == Event.RENDER)
			{
				_phase = 1;
			}
			
			// On est en phase de pré-rendu
			else if (_phase != 0)
			{
				_phase = 0;
			}
		}
		
		
		/**
		 * Configurer le mode multi DPI automatique
		 * @param	pAutoDPIOnMobileAndTablets : Si on doit convertir les dimensions des composants automatiquement sur les mobiles et les tablettes (pas de changement sur PC et MAC)
		 * @param	pBaseDPIForPhones : Le DPI de base pour la conversion des dimensions sur mobile (163 par défaut, définition d'un iPhone 3GS)
		 * @param	pBaseDPIForTablets : Le DPI de base pour la conversion des dimensions sur tablette (132, la définition d'un iPad 1/2)
		 * @param	pBaseDPIForComputers : Le DPI de base pour la conversion des dimensions sur PC / MAC (72 par défaut)
		 */
		public function setAutoDPI (pAutoDPIOnMobileAndTablets:Boolean = true, pBaseDPIForPhones:uint = EnvUtils.IPHONE_CLASSIC_DPI, pBaseDPIForTablets:uint = EnvUtils.IPAD_CLASSIC_DPI, pBaseDPIForComputers:uint = EnvUtils.COMPUTER_DPI):StageWrapper
		{
			// Enregistrer les réglages du DPI
			_autoDPIOnMobileAndTablets 	= pAutoDPIOnMobileAndTablets;
			_baseDPIForPhones 			= pBaseDPIForPhones;
			_baseDPIForTablets 			= pBaseDPIForTablets;
			_baseDPIForComputers 		= pBaseDPIForComputers;
			
			// Initialiser le wrapper de DPI
			initDPIWrapper();
			
			// Retourner this
			return this;
		}
		
		/**
		 * Initialiser le redimensionnement selon le DPI
		 */
		protected function initDPIWrapper ():void
		{
			// Vérifier si on doit adapter
			if (_autoDPIOnMobileAndTablets)
			{
				// Récuéprer le type de device sur lequel on est
				const deviceType:String = EnvUtils.getDeviceType();
				
				// Si on est sur PC / MAC
				if (deviceType == EnvUtils.COMPUTER)
				{
					scaleX = scaleY = Capabilities.screenDPI / _baseDPIForComputers;
				}
				
				// Si on est sur téléphone
				else if (deviceType == EnvUtils.PHONE)
				{
					scaleX = scaleY = Capabilities.screenDPI / _baseDPIForPhones;
				}
				
				// Si on est sur tablette
				else if (deviceType == EnvUtils.TABLET)
				{
					scaleX = scaleY = Capabilities.screenDPI / _baseDPIForTablets;
				}
			}
			else
			{
				// Le scale à 1
				scaleX = scaleY = 1;
			}
			
			// Enregistrer le ratio pour le récupérer de l'extérieur
			_ratio = scaleX;
		}
		
		/**
		 * Le stage a été redimensionné
		 */
		protected function stageResizedHandler (event:Event = null):void 
		{
			// Le stage a été redimentionné
			if (stage.stageWidth > 0 && stage.stageHeight > 0)
			{
				// Décallage du clavier
				/*
				var keyboardOffset:Number = 0;
				
				// Si on a un softKeyboard
				if (_listenSoftKeyboard && _stage.softKeyboardRect != null && _stage.softKeyboardRect.height > 0)
				{	
					trace("SoftKeyboardRect: " + _stage.softKeyboardRect);
					
					// Enregistrer la hauteur du clavier
					keyboardOffset = _stage.softKeyboardRect.height;
				}
				*/
				/*
				TweenMax.to(this, .5, {
					ease: Quad.easeInOut,
					x: _stageSizeForCenterAlign.x / 2 - stage.stageWidth / 2,
					y: _stageSizeForCenterAlign.y / 2 - stage.stageHeight / 2,
					width: int(_stage.stageWidth / scaleX + .5),
					height: int((_stage.stageHeight - keyboardOffset) / scaleY + .5)
				});
				return;
				*/
				
				// Centrer
				if (_stageSizeForCenterAlign != null)
				{
					x = _stageSizeForCenterAlign.x / 2 - stage.stageWidth / 2;
					y = _stageSizeForCenterAlign.y / 2 - stage.stageHeight / 2;
				}
				
				// Si on doit redimensionner automatiquement selon le DPI
				if (_autoDPIOnMobileAndTablets)
				{
					// On récupère la taille et on applique la modification du scale
					size(
						int(stage.stageWidth / scaleX + .5),
						int(stage.stageHeight / scaleY + .5)
						//int((_stage.stageHeight - keyboardOffset) / scaleY + .5)
					);
				}
				else
				{
					// On applique directement
					size(stage.stageWidth, stage.stageHeight);
					//size(_stage.stageWidth, _stage.stageHeight - keyboardOffset);
				}
			}
		}
		
		/**
		 * La destruction du composant
		 */
		override protected function removedHandler (event:Event):void 
		{
			// Ne plus écouter le redimensionnement du stage
			stage.removeEventListener(Event.RESIZE, stageResizedHandler);
			
			// Ne plus écouter les phases
			stage.removeEventListener(Event.ENTER_FRAME, phaseHandler);
			stage.removeEventListener(Event.RENDER, phaseHandler);
			
			// Ne plus écouter le clavier virtuel
			//_stage.removeEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_ACTIVATE, stageResizedHandler);
			//_stage.removeEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_ACTIVATING, stageResizedHandler);
			//_stage.removeEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_DEACTIVATE, stageResizedHandler);
			
			// Virer le styleCentral
			_styleCentral.dispose();
			_styleCentral.onStyleChanged.remove(invalidateStyle);
			_styleCentral = null;
			
			// Relayer la destruction
			super.removedHandler(event);
		}
	}
}