package fr.swapp.graphic.document
{
	import flash.display.Sprite;
	import flash.events.Event;
	import fr.swapp.core.actions.Action;
	import fr.swapp.core.actions.IAction;
	import fr.swapp.core.data.config.Config;
	import fr.swapp.core.errors.SwappError;
	import fr.swapp.core.log.ExternalInterfaceLogger;
	import fr.swapp.core.log.Log;
	import fr.swapp.core.log.TraceLogger;
	import fr.swapp.core.mvc.AppViewController;
	import fr.swapp.graphic.base.SWrapper;
	import fr.swapp.graphic.tools.Stats;
	import fr.swapp.input.dispatcher.InputDispatcher;
	import fr.swapp.input.emulator.MouseToTouchEmulator;
	import fr.swapp.utils.EnvUtils;
	import fr.swapp.utils.ObjectUtils;
	import fr.swapp.utils.StageUtils;
	
	/**
	 * @author ZoulouX
	 */
	public class SFlashDocument extends Sprite
	{
		/**
		 * Components wrapper
		 */
		protected var _wrapper					:SWrapper;
		
		/**
		 * Stats graph
		 */
		protected var _stats					:Stats;
		
		/**
		 * Touch dispatcher
		 */
		protected var _inputDispatcher			:InputDispatcher;
		
		/**
		 * AppViewController
		 */
		protected var _appViewController		:AppViewController;
		
		
		/**
		 * Components wrapper
		 */
		public function get wrapper ():SWrapper { return _wrapper; }
		
		/**
		 * Stats graph
		 */
		public function get stats ():Stats { return _stats; }
		
		/**
		 * Input dispatcher
		 */
		public function get inputDispatcher ():InputDispatcher { return _inputDispatcher; }
		
		/**
		 * AppViewController
		 */
		public function get appViewController ():AppViewController { return _appViewController; }
		
		
		/**
		 * Constructeur
		 */
		public function SFlashDocument ()
		{
			// TODO : Faire un helper pour les paramètres (flashVars) et les InvokeEvent. Cette classe doit faire passerelle vers l'extérieur.
			
			// Appeler le sous-constructeur
			construct();
		}
		
		/**
		 * Sub-constructor.
		 */
		protected function construct ():void
		{
			// Ecouter les ajouts au stage
			(stage != null ? addedHandler() : addEventListener(Event.ADDED_TO_STAGE, addedHandler));
		}
		
		
		/**
		 * When stage is available. Private.
		 */
		protected function addedHandler (event:Event = null):void
		{
			// Ne plus écouter
			removeEventListener(Event.ADDED_TO_STAGE, addedHandler);
			
			// Passer le stage principal au StageUtils
			StageUtils.mainStage = stage;
			
			// On est prêt
			init();
			
			// Si un wrapper a été créé
			if (_wrapper != null && !_wrapper.ready)
			{
				// Ecouter lorsque le wrapper est prêt
				_wrapper.onReady.addOnce(ready);
			}
			else
			{
				// On est prêt
				ready();
			}
		}
		
		/**
		 * Initialize the document.
		 * This is the only place where "init" is protected and have to be overrided.
		 * This is where you call all the "enable" like protected methods.
		 */
		protected function init ():void
		{
			throw new SwappError("SFlashDocument.init", "This method have to be overrided.");
		}
		
		/**
		 * When all is ready.
		 * Setup your app only when it's ready.
		 * Have to be overrided.
		 */
		protected function ready ():void
		{
			throw new SwappError("SFlashDocument.ready", "This method have to be overrided.");
		}
		
		/**
		 * Init SWrapper to enable component flow from main stage
		 * @param	pEnableStyleCentral : Enable style central
		 * @param	pAutoRatio : Use auto ratio scaling (only if this is the first getInstance for this stage)
		 * @param	pMinWidth : Minimum stage width. Ratio will be changed if the screen is too small. NaN to ignore.
		 * @param	pMinHeight : Minimum stage height. Ratio will be changed if the screen is too small. NaN to ignore.
		 * @param	pDefaultAspectRatio : Default aspect ratio. Use StageAspectRatio statics. (Only available on Air runtime)
		 */
		protected function enableWrapper (
												pEnableStyleCentral			:Boolean	= true,
												pAutoRatio					:Boolean 	= true,
												pMinWidth					:Number 	= NaN,
												pMinHeight					:Number 	= NaN,
												pDefaultAspectRatio			:String		= "any"
											):void
		{
			// Créer le wrapper
			_wrapper = SWrapper.getInstance(stage, pAutoRatio, SWrapper.DEFAULT_RATIO_ROUND_SLICES, pMinWidth, pMinHeight, pDefaultAspectRatio);
			
			// Si on doit activer le style central
			if (pEnableStyleCentral)
			{
				_wrapper.enableStyleCentral();
			}
		}
		
		/**
		 * Enable input dispatcher
		 * @param	pEnableMouse : Enable mouse managment
		 * @param	pAndroidTapThreshold : Android tap threshold (in pixels)
		 * @param	pDefaultTapThreshold : Default tap threshold (in pixels)
		 */
		protected function enableInputDispatcher (pEnableTouch:Boolean = true, pEnableMouse:Boolean = true, pAndroidTapThreshold:int = 10, pDefaultTapThreshold:int = 2):void
		{
			// Créer l'inputDispatcher de ce stage
			// Patcher les touch foireux d'Android
			_inputDispatcher = InputDispatcher.getInstance(
				stage,
				pEnableTouch,
				pEnableMouse,
				(
					EnvUtils.isPlatformType(EnvUtils.ANDROID_PLATFORM)
					?
					pAndroidTapThreshold
					:
					pDefaultTapThreshold
				)
			);
		}
		
		/**
		 * Enable touch emulator for desktop testing with faked touch events
		 */
		protected function enableTouchEmulator ():void
		{
			MouseToTouchEmulator.auto(stage);
		}
		
		/**
		 * Auto init logger.
		 * ExternalInterfaceLogger will be added when available.
		 * Else, TraceLogger will be used.
		 */
		protected function enableLogger ():void
		{
			// Voir si on est sur flash, dans un browser
			if (EnvUtils.like(EnvUtils.FLASH_RUNTIME) && EnvUtils.isBrowserRuntime())
			{
				// On active le logger par external interface
				Log.addLogger(new ExternalInterfaceLogger());
			}
			else
			{
				// Sinon on active via trace
				Log.addLogger(new TraceLogger());
			}
		}
		
		/**
		 * Enable config and configure config environments
		 * @param	pConfigEnvironment : Current enabled config environment (See Config statics, can't be changed)
		 * @param	pGlobal : Global vars (will be overrided by the 3 nexts parameters following select config environment)
		 * @param	pDebug : Debug vars, will override global if selected
		 * @param	pTest : Test vars, will override global if selected
		 * @param	pProduction : Production vars, will override global if selected
		 */
		protected function enableConfig (pConfigEnvironment:String, pGlobal:Object, pDebug:Object, pTest:Object, pProduction:Object):void
		{
			// Récupérer la config
			var config:Config = Config.getInstance();
			
			// Définir les objets de config pour chaque environnement
			ObjectUtils.extra(config.global,		pGlobal);
			ObjectUtils.extra(config.debug,			pDebug);
			ObjectUtils.extra(config.test,			pTest);
			ObjectUtils.extra(config.production,	pProduction);
			
			// Activer l'environnement
			config.currentEnvironment = pConfigEnvironment;
		}
		
		/**
		 * Enable stats counter
		 */
		public function enableStats ():void
		{
			// Créer les stats
			_stats = new Stats(100, 0, 0);
			
			// Si on a un wrapper
			if (_wrapper != null)
			{
				// Appliquer le ratio du stage
				_stats.scaleX = _stats.scaleY = _wrapper.ratio;
			}
			
			// Les ajouter
			stage.addChild(_stats);
		}
		
		/**
		 * Hide stats counter
		 */
		public function disableStats ():void
		{
			// Si on a des stats
			if (_stats != null)
			{
				// On les vires
				stage.removeChild(_stats);
				_stats = null;
			}
		}
		
		/**
		 * Setup AppViewController and start AppViewController.
		 * SWrapper will be used if initialised. Else, stage will be provided.
		 * Call this method only in the "ready" method.
		 */
		protected function setupAppViewController (pAppViewControllerClass:Class, pDefaultAction:IAction = null):void
		{
			// Vérifier que la classe soit bien un appViewController
			if (!(pAppViewControllerClass is AppViewController))
			{
				// Déclancher une erreur
				throw new SwappError("SFlashDocument.setupAppViewController", "The pAppViewControllerClass parameter in setupAppViewController have to be an AppViewController based class.");
			}
			else
			{
				// Créer l'AppController
				_appViewController = new pAppViewControllerClass();
				
				// Donner un container au controller (wrapper si disponible sinon stage)
				_appViewController.container = (_wrapper != null ? _wrapper.root : stage);
				
				// Démarrer le controlleur
				_appViewController.turnOn();
				
				// Appeller l'action par défaut sur le controlleur
				_appViewController.requestAction(pDefaultAction == null ? Action.create("default") : pDefaultAction);
			}
		}
	}
}