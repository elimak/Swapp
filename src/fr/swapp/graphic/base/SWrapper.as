package fr.swapp.graphic.base
{
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.utils.Dictionary;
	import fr.swapp.core.roles.IDisposable;
	import fr.swapp.core.roles.IReadyable;
	import fr.swapp.graphic.errors.GraphicalError;
	import fr.swapp.graphic.styles.StyleCentral;
	import fr.swapp.touch.dispatcher.TouchDispatcher;
	import fr.swapp.touch.emulator.MouseToTouchEmulator;
	import fr.swapp.utils.EnvUtils;
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	
	/**
	 * @author ZoulouX
	 */
	public class SWrapper implements IDisposable, IReadyable
	{
		/**
		 * Ratio rounded slices
		 */
		public static var ratioRoundSlices				:Number 				= 6;
		
		
		/**
		 * SWrapper instances
		 */
		protected static var __instances				:Dictionary				= new Dictionary(false);
		
		
		/**
		 * Get an instance of SWrapper. Instances are associated to stages.
		 * @param	pStage : The native associated stage instance from the document class
		 * @param	pAutoRatio : Use auto ratio scaling (only if this is the first getInstance for this stage)
		 * @param	pMinWidth : Minimum stage width. Ratio will be changed if the screen is too small. NaN to ignore.
		 * @param	pMinHeight : Minimum stage height. Ratio will be changed if the screen is too small. NaN to ignore.
		 * @return : SWrapper instance
		 */
		public static function getInstance (pStage:Stage, pAutoRatio:Boolean = true, pMinWidth:Number = NaN, pMinHeight:Number = NaN, pDontCheckResize:Boolean = false):SWrapper
		{
			// Vérifier la validité du stage
			if (pStage == null)
			{
				// déclencher l'erreur singleton
				throw new GraphicalError("SWrapper.getInstance", "Stage can't be null.");
				return null;
			}
			
			// Si on n'a pas d'instance
			if (!(pStage in __instances))
			{
				// TODO : ATTENTION BUG
				// Ici l'association __instances / stage n'est toujours pas faite alors que SComponent retape dans SWrapper.getInstance !
				
				// On créé l'instance avec la clé et on stoque dans le dico
				new SWrapper(new MultitonKey(), pStage, pAutoRatio, pMinWidth, pMinHeight, pDontCheckResize);
			}
			
			// Retourner l'instance
			return __instances[pStage];
		}
		
		
		/**
		 * Associated stage
		 */
		protected var _stage							:Stage;
		
		/**
		 * Component Root
		 */
		protected var _root								:SComponent;
		
		/**
		 * Style manager
		 */
		protected var _styleCentral						:StyleCentral;
		
		/**
		 * Touch dispatcher
		 */
		protected var _touchDispatcher					:TouchDispatcher;
		
		/**
		 * If auto ratio is enabled
		 */
		protected var _autoRatio						:Boolean;
		
		/**
		 * Current stage ratio (if autoRatio is true, default is 1)
		 */
		protected var _ratio							:Number						= 1;
		
		/**
		 * Minimum stage width
		 */
		protected var _minWidth							:Number;
		
		/**
		 * Minimum stage height
		 */
		protected var _minHeight						:Number;
		
		/**
		 * When disposed
		 */
		protected var _onDisposed						:Signal;
		
		/**
		 * Total resize event fired to get the real size
		 */
		protected var _resizeFired						:uint						= 0;
		
		/**
		 * If the wrapper is ready
		 */
		protected var _ready							:Boolean					= false;
		
		/**
		 * When the wrapper is ready
		 */
		protected var _onReady							:Signal						= new Signal();
		
		
		/**
		 * Associated stage
		 */
		public function get stage ():Stage { return _stage; }
		
		/**
		 * The root component
		 */
		public function get root ():SComponent { return _root; }
		
		/**
		 * Style manager
		 */
		public function get styleCentral ():StyleCentral { return _styleCentral; }
		
		/**
		 * Touch dispatcher
		 */
		public function get touchDispatcher ():TouchDispatcher { return _touchDispatcher; }
		
		/**
		 * If auto ratio is enabled
		 */
		public function get autoRatio ():Boolean { return _autoRatio; }
		
		/**
		 * Current stage ratio (if autoRatio is true, default is 1)
		 */
		public function get ratio ():Number { return _ratio; }
		
		/**
		 * Minimum stage width
		 */
		public function get minWidth ():Number { return _minWidth; }
		public function set minWidth (value:Number):void
		{
			// Si la valeur est différente
			if (_minWidth != value)
			{
				// Enregistrer la valeur
				_minWidth = value;
				
				// Prendre en compte le changement
				stageResizedHandler();
			}
		}
		
		/**
		 * Minimum stage height
		 */
		public function get minHeight ():Number { return _minHeight; }
		public function set minHeight (value:Number):void
		{
			// Si la valeur est différente
			if (_minHeight != value)
			{
				// Enregistrer la valeur
				_minHeight = value;
				
				// Prendre en compte le changement
				stageResizedHandler();
			}
		}
		
		/**
		 * When disposed
		 */
		public function get onDisposed ():ISignal { return _onDisposed; }
		
		/**
		 * If the wrapper is ready
		 */
		public function get ready ():Boolean { return _ready; }
		
		/**
		 * When the wrapper is ready
		 */
		public function get onReady ():ISignal { return _onReady; }
		
		
		/**
		 * Private constructor. Please use SWrapper.getInstance to create a new instance of SWrapper.
		 * SWrapper is singleton and can't be instanciated several times.
		 * @param	pMultitonKey : Private key to secure instanciation
		 * @param	pStage : The native associated stage instance from the document class
		 * @param	pAutoRatio : Use auto ratio scaling (only if this is the first getInstance for this stage)
		 * @param	pMinWidth : Minimum stage width. Ratio will be changed if the screen is too small. NaN to ignore.
		 * @param	pMinHeight : Minimum stage height. Ratio will be changed if the screen is too small. NaN to ignore.
		 */
		public function SWrapper (pMultitonKey:MultitonKey, pStage:Stage, pAutoRatio:Boolean = true, pMinWidth:Number = NaN, pMinHeight:Number = NaN, pDontCheckResize:Boolean = false)
		{
			// Vérifier la clé pour la création multiton
			if (pMultitonKey == null)
			{
				// déclencher l'erreur singleton
				throw new GraphicalError("SWrapper.construct", "Direct instancation not allowed, please use SWrapper.getInstance instead.");
			}
			else
			{
				// TODO : Vérifier cette merde
				// Enregistrer l'instance
				__instances[pStage] = this;
				
				// Enregistrer le stage
				_stage = pStage;
				
				// Enregistrer les tailles min et max
				_minWidth = pMinWidth;
				_minHeight = pMinHeight;
				
				// Si on est en ratio auto
				_autoRatio = pAutoRatio;
				
				// Créer la racine
				_root = new SComponent();
				
				// Le nom de la racine
				_root.name = "root";
				
				// Ne jamais redimensionner l'UI
				_stage.scaleMode = StageScaleMode.NO_SCALE;
				_stage.align = StageAlign.TOP_LEFT;
				
				// Qualité au minimum
				_stage.quality = StageQuality.LOW;
				
				// Initialiser le wrapper de DPI automatique
				initDPIWrapper();
				
				// Ecouter les redimentionnements
				_stage.addEventListener(Event.RESIZE, stageResizedHandler);
				
				// Si on est sur flash ou android
				//if (EnvUtils.getInstance().isPlayerType(EnvUtils.FLASH) || EnvUtils.getInstance().isPlatformType(EnvUtils.ANDROID_PLATFORM))
				//if (!EnvUtils.getInstance().isPlatformType(EnvUtils.WIN_PLATFORM))
				if (
					EnvUtils.getInstance().isPlatformType(EnvUtils.ANDROID_PLATFORM)
					||
					EnvUtils.getInstance().isPlayerType(EnvUtils.FLASH)
					||
					pDontCheckResize
					)
				{
					// On met directement le resize
					_resizeFired = 1;
					
					// Appeler une première fois le resize
					stageResizedHandler();
				}
			}
		}
		
		
		/**
		 * Initialize style manager
		 */
		public function enableStyleCentral ():void
		{
			// Créer le centre de gestion des styles
			_styleCentral = new StyleCentral();
			
			// Ecouter lorsque le style change
			_styleCentral.onStyleChanged.add(_root.invalidateStyle);
			
			// Activer les styles sur ce container
			_root.styleEnabled = true;
		}
		
		/**
		 * Native stage is resized
		 */
		protected function stageResizedHandler (event:Event = null):void
		{
			trace(" >>>>>>>>> stageResizedHandler", _stage.stageWidth, _stage.stageHeight, _resizeFired, _autoRatio, _ready);
			
			// Comptabiliser le resize
			_resizeFired ++;
			
			// Si c'est notre premier resize
			if (_resizeFired == 1)
			{
				// On ne va pas plus loin, il est daubé
				return;
			}
			
			// Si on a un ratio automatique
			if (_autoRatio && _ready)
			{
				// Définir la taille du root
				updateRootSizeWidthRatio();
				
				// Si on a une largeur minimum
				if (_minWidth >= 0)
				{
					// Si on est en dessous la largeur minimum
					if (_root.width < _minWidth)
					{
						// On modifie le ratio
						_ratio = _stage.stageWidth / _minWidth;
						
						// Redéfinir la taille du root
						updateRootSizeWidthRatio(false);
					}
				}
				
				// Si on a une hauteur minimum
				if (_minHeight >= 0)
				{
					// Si on est en dessous de la hauteur minimum
					if (_root.height < _minHeight)
					{
						// On modifie le ratio
						_ratio = _stage.stageHeight / _minHeight;
						
						// Redéfinir la taille du root
						updateRootSizeWidthRatio(false);
					}
				}
			}
			else
			{
				// Définir la taille du root
				_root.size(_stage.stageWidth, _stage.stageHeight);
			}
			
			// Si on en est à notre second resize
			if (_resizeFired == 2)
			{
				// On est prêt
				_ready = true;
				
				// Actualiser le ratio et la taille du stage
				updateRootSizeWidthRatio();
				
				// Refaire une passe sur la taille
				stageResizedHandler();
				
				// Ajouter la racine
				_stage.addChild(_root);
				
				// Signaler qu'on est prêt
				_onReady.dispatch();
			}
		}
		
		/**
		 * Update root size
		 */
		protected function updateRootSizeWidthRatio (pRound:Boolean = true):void
		{
			// Arrondir le ratio
			if (pRound)
			{
				_ratio = Math.round(_ratio * ratioRoundSlices) / ratioRoundSlices;
			}
			
			// Appliquer le ratio
			_root.scaleX = _root.scaleY = _ratio;
			
			// Définir la taille par rapport au ratio
			_root.size(_stage.stageWidth / _ratio, _stage.stageHeight / _ratio);
		}
		
		/**
		 * Initialize DPI wrapper (only if autoSize is true at construction)
		 * And set quality from devices type.
		 */
		protected function initDPIWrapper ():void
		{
			// Si on doit adapter
			if (_autoRatio)
			{
				// Récupérer le ratio et l'enregistrer
				_ratio = EnvUtils.getInstance().getRatioForStage();
			}
		}
		
		/**
		 * Set the minimum size
		 */
		public function setMinSize (pMinWidth:Number, pMinHeight:Number):void
		{
			// Enregistrer les valeurs
			_minWidth = pMinWidth;
			_minHeight = pMinHeight;
			
			// Prendre en compte le changement
			stageResizedHandler();
		}
		
		/**
		 * Dispose this instance of SWrapper
		 */
		public function dispose ():void
		{
			// Virer la racine
			_stage.removeChild(_root);
			
			// Disposer la racine
			_root.dispose();
			
			// Ne plus écouter les resizes
			_stage.removeEventListener(Event.RESIZE, stageResizedHandler);
			
			// Disposer le styleCentral
			if (_styleCentral != null)
			{
				_styleCentral.dispose();
			}
			
			// Virer l'instance du dico
			delete __instances[_stage];
			__instances[_stage] = null;
			
			// Tout passer à null
			_stage = null;
			_root = null;
			_styleCentral = null;
			
			// Signaler et supprimer
			_onDisposed.dispatch();
			_onDisposed.removeAll();
			_onDisposed = null;
		}
	}
}

/**
 * Private key to secure multiton providing.
 */
internal class MultitonKey {}