package fr.swapp.graphic.document
{
	import flash.display.Sprite;
	import flash.events.Event;
	import fr.swapp.core.log.Log;
	import fr.swapp.core.log.TraceLogger;
	import fr.swapp.core.mvc.AppController;
	import fr.swapp.core.roles.IDisposable;
	import fr.swapp.core.roles.IInitializable;
	import fr.swapp.graphic.base.SWrapper;
	import fr.swapp.touch.dispatcher.TouchDispatcher;
	import fr.swapp.touch.emulator.MouseToTouchEmulator;
	import fr.swapp.utils.EnvUtils;
	import fr.swapp.utils.Stats;
	
	/**
	 * @author ZoulouX
	 */
	public class SFlashDocument extends Sprite implements IInitializable
	{
		/**
		 * Components wrapper
		 */
		protected var _wrapper				:SWrapper;
		
		/**
		 * Stats graph
		 */
		protected var _stats				:Stats;
		
		/**
		 * Touch dispatcher
		 */
		protected var _touchDispatcher		:TouchDispatcher;
		
		/**
		 * AppController
		 */
		protected var _appController		:AppController;
		
		
		/**
		 * Components wrapper
		 */
		public function get wrapper ():SWrapper { return _wrapper; }
		
		/**
		 * Stats graph
		 */
		public function get stats ():Stats { return _stats; }
		
		/**
		 * Touch dispatcher
		 */
		public function get touchDispatcher ():TouchDispatcher { return _touchDispatcher; }
		
		/**
		 * AppController
		 */
		public function get appController ():AppController { return _appController; }
		
		
		/**
		 * Constructeur
		 */
		public function SFlashDocument ()
		{
			// TODO : Gérer les SDocumentMode
			// TODO : Faire un helper pour les paramètres (flashVars) et les InvokeEvent. Cette classe doit faire passerelle vers l'extérieur.
			
			// Ecouter les ajouts au stage
			if (stage != null)
			{
				addedHandler();
			}
			else
			{
				addEventListener(Event.ADDED_TO_STAGE, addedHandler);
			}
		}
		
		
		/**
		 * When stage is available
		 * @param	event
		 */
		protected function addedHandler (event:Event = null):void
		{
			// Ne plus écouter
			removeEventListener(Event.ADDED_TO_STAGE, addedHandler);
			
			// Lancer l'initialisation
			init();
		}
		
		/**
		 * Initialize
		 */
		public function init ():void
		{
			
		}
		
		/**
		 * Init SWrapper
		 * @param	pAutoDPI : Enable auto DPI
		 */
		protected function initWrapper (pAutoDPI:Boolean = true):void
		{
			// Créer le wrapper
			_wrapper = SWrapper.getInstance(stage, pAutoDPI);
		}
		
		/**
		 * Initialize touch dispatcher if needed.
		 * @param	pEnableMouse : Enable mouse managment
		 * @param	pAndroidTapThreshold : Android tap threshold (in pixels)
		 * @param	pDefaultTapThreshold : Default tap threshold (in pixels)
		 */
		public function enableTouchDispatcher (pEnableMouse:Boolean = true, pAndroidTapThreshold:int = 10, pDefaultTapThreshold:int = 2):void
		{
			// Créer le touchDispatcher de ce stage
			// Patcher les touch foireux d'Android
			_touchDispatcher = TouchDispatcher.getInstance(stage, pEnableMouse, EnvUtils.getInstance().isPlatformType(EnvUtils.ANDROID_PLATFORM) ? pAndroidTapThreshold : pDefaultTapThreshold);
		}
		
		/**
		 * Enable touch emulator for desktop testing
		 */
		public function enableTouchEmulator ():void
		{
			MouseToTouchEmulator.auto(stage);
		}
		
		/**
		 * Activate trace logger
		 */
		protected function initTraceLogger ():void
		{
			Log.addLogger(new TraceLogger());
		}
		
		/**
		 * Setup AppController and start AppController.
		 * SWrapper will be used if initialised. Else, stage will be provided.
		 */
		protected function setupAppController (pAppControllerClass:Class):void
		{
			// Créer l'AppController
			_appController = new pAppControllerClass();
			
			// Démarrer le controlleur avec un container par défaut
			_appController.turnOn({
				container: _wrapper != null ? _wrapper : stage
			});
			
			// Appeller l'action par défaut sur le controlleur
			//_appController.action();
		}
		
		/**
		 * Show stats
		 */
		public function showStats ():void
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
		 * Hide stats
		 */
		public function hideStats ():void
		{
			// Si on a des stats
			if (_stats != null)
			{
				// On les vires
				stage.removeChild(_stats);
				_stats = null;
			}
		}
	}
}