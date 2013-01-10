package fr.swapp.graphic.base
{
	import flash.display.Stage;
	import flash.display.Stage3D;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import fr.swapp.graphic.errors.GraphicalError;
	import fr.swapp.graphic.styles.StyleCentral;
	import org.osflash.signals.Signal;
	import starling.core.Starling;
	import starling.display.Sprite;
	
	/**
	 * @author ZoulouX
	 */
	public class SWrapper
	{
		/**
		 * SWrapper instance
		 */
		protected static var __instance				:SWrapper;
		
		/**
		 * Get the instance of SWrapper.
		 * SWrapper have to be initialised before getting instance by this method.
		 * @return : SWrapper instance
		 */
		public static function getInstance ():SWrapper
		{
			// Si on n'a pas d'instance
			if (__instance == null)
			{
				// On déclanche une erreur
				throw new GraphicalError("SWrapper.getInstance", "SWrapper isn't initialised yet, please do with new SWrapper before getting instance via this method.");
				return null;
			}
			else
			{
				// Retourner l'instance
				return __instance;
			}
		}
		
		/**
		 * The starling engine
		 */
		protected var _starling							:Starling;
		
		/**
		 * Le centre de gestion des styles
		 */
		protected var _styleCentral						:StyleCentral;
		
		/**
		 * When starling / wrapper / root are ready
		 */
		protected var _onReady							:Signal					= new Signal();
		protected var _ready							:Boolean				= false;
		
		
		/**
		 * The starling engine
		 */
		public function get starling ():Starling
		{
			return _starling;
		}
		
		/**
		 * The root component
		 */
		public function get root ():SComponent
		{
			return _starling.root as SComponent;
		}
		
		/**
		 * Le centre de gestion des styles
		 */
		public function get styleCentral ():StyleCentral
		{
			return _styleCentral;
		}
		
		/**
		 * When starling / wrapper / root are ready
		 */
		public function get onReady ():Signal { return _onReady; }
		
		
		/**
		 * Create the SWrapper.
		 * Will create a starling instance.
		 * SWrapper is singleton and can't be instanciated several times.
		 * @param	pStage : The native stage instance from the document class
		 * @param	pViewPort : The viewport showing the starling content, automatic if not provided
		 * @param	pStage3D : The stage3D instance, automatic if not provided
		 * @param	pRenderMode : Type "software" to force software render (default is "auto")
		 * @param	pProfile : Context3DProfile to be used (default is "baselineConstrained")
		 */
		public function SWrapper (pStage:Stage, pViewPort:Rectangle = null, pStage3D:Stage3D = null, pRenderMode:String = "auto", pProfile:String = "baselineConstrained")
		{
			// Si on n'a pas d'instance
			if (__instance == null)
			{
				// Vérifier la validité du stage
				if (pStage != null)
				{
					// Enregistrer l'instance
					__instance = this;
					
					// Ne jamais redimensionner l'UI
					pStage.scaleMode = StageScaleMode.NO_SCALE;
					pStage.align = StageAlign.TOP_LEFT;
					
					// Passer en basse qualité
					pStage.quality = StageQuality.LOW;
					
					// Ecouter les redimentionnements
					pStage.addEventListener(Event.RESIZE, stageResizedHandler);
					
					// Activer le multiTouch
					Starling.multitouchEnabled = true;
					
					// Activer la récupération automatique du contexte
					Starling.handleLostContext = true;
					
					// Créer le starling avec un sprite par défaut et les paramètres reçus
					_starling = new Starling(SComponent, pStage, pViewPort, pStage3D, pRenderMode, pProfile);
					
					_starling.enableErrorChecking = false;
					_starling.antiAliasing = 1;
					_starling.showStats = true;
					
					// Ecouter lorsque le root est prêt
					_starling.addEventListener("rootCreated", rootCreatedHandler);
					
					// Démarrer starling
					_starling.start();
				}
				else
				{
					// Déclancher l'erreur singleton
					throw new GraphicalError("SWrapper.construct", "Stage is null.");
				}
			}
			else
			{
				// Déclancher l'erreur singleton
				throw new GraphicalError("SWrapper.construct", "SWrapper is singleton.");
			}
		}
		
		/**
		 * Root is ready
		 */
		protected function rootCreatedHandler (event:Object):void 
		{
			// Le nom du root
			root.name = "root";
			
			// On est prêt
			_ready = true;
			
			// Appliquer une première fois la taille du viewPort
			stageResizedHandler();
			
			// Signaler que c'est prêt
			_onReady.dispatch();
		}
		
		/**
		 * Native stage is resized
		 */
		protected function stageResizedHandler (event:Event = null):void 
		{
			// Actualiser le viewport de starling
			_starling.viewPort = new Rectangle(0, 0, _starling.nativeStage.stageWidth, _starling.nativeStage.stageHeight);
			
			// Si le root est prêt et si les dimensions sont bien différentes
			if (_ready && (root.width != _starling.nativeStage.stageWidth || root.height != _starling.nativeStage.stageHeight))
			{
				// Appliquer les dimensions sur le stage de starling
				_starling.stage.stageWidth = _starling.nativeStage.stageWidth;
				_starling.stage.stageHeight = _starling.nativeStage.stageHeight;
				
				// Définir la taille du root
				root.size(_starling.nativeStage.stageWidth, _starling.nativeStage.stageHeight);
			}
		}
		
		/**
		 * Initialiser le manager de styles
		 */
		protected function initStyleCentral():void 
		{
			// Créer le centre de gestion des styles
			_styleCentral = new StyleCentral();
			
			// Ecouter lorsque le style change
			_styleCentral.onStyleChanged.add(root.invalidateStyle);
			
			// Activer les styles sur ce container
			root.styleEnabled = true;
		}
	}
}