package fr.swapp.core.navigation
{
	import fr.swapp.core.actions.IAction;
	import fr.swapp.core.dependences.DependencesManager;
	import fr.swapp.core.dependences.IDependencesManager;
	import fr.swapp.core.mvc.IController;
	import fr.swapp.core.mvc.IViewController;
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	
	/**
	 * @author ZoulouX
	 */
	public class Bootstrap implements IBootstrap
	{
		/**
		 * Actions to ViewControllers mapping
		 */
		protected static var __actionsMap		:Array				= [];
		
		
		/**
		 * Actions to ViewControllers mapping (keys : action name, value : ViewController class)
		 */
		public static function get actionsMap ():Array { return __actionsMap; }
		public static function set actionsMap (value:Array):void
		{
			__actionsMap = value;
		}
		
		
		/**
		 * Add mapping between action and view controller
		 * @param	pActionName : The action name 
		 * @param	pViewControllerClass : The ViewController class
		 */
		public static function mapAction (pActionName:String, pViewControllerClass:Class):void
		{
			// Enregistrer le nom de l'action et la classe du ViewController
			__actionsMap[pActionName] = pViewControllerClass;
		}
		
		/**
		 * When bootstrap is disposed
		 */
		protected var _onDisposed					:Signal				= new Signal();
		
		/**
		 * Actions history
		 */
		protected var _history						:History;
		
		/**
		 * When action is requested
		 */
		protected var _onActionRequested			:Signal 			= new Signal(IAction);
		
		/**
		 * When current view controller has changed
		 */
		protected var _onViewControllerChange		:Signal 			= new Signal(IAction, IViewController);
		
		protected var _dependencesManagerName		:String;
		
		protected var _dependencesManager			:IDependencesManager;
		
		protected var _currentViewController		:IViewController;
		
		
		public function get history ():IHistory { return _history; }
		
		public function get onActionRequested ():Signal { return _onActionRequested; }
		
		public function get onViewControllerChange ():Signal { return _onViewControllerChange; }
		
		public function get dependencesManagerName ():String { return _dependencesManagerName; }
		
		public function get dependencesManager ():IDependencesManager { return _dependencesManager; }
		public function set dependencesManager (value:IDependencesManager):void
		{
			_dependencesManager = value;
		}
		
		public function get currentViewController ():IViewController { return _currentViewController; }
		
		public function get onDisposed ():ISignal { return _onDisposed; }
		
		
		/**
		 * Bootstrap constructor
		 * @param	pDependencesManagerName : Name to get the dependences manager (via getInstance static). Default value is "default". Enter void string or null if don't want auto isntanciated dependences manager.
		 */
		public function Bootstrap (pDependencesManagerName:String = "default")
		{
			// Enregistrer le nom du manager de dépendances
			_dependencesManagerName = pDependencesManagerName;
			
			// Si on a un manager de dépendences
			if (_dependencesManagerName != "")
			{
				// On l'initialise
				initDependencesManager();
			}
		}
		
		/**
		 * Init dependences manager
		 */
		protected function initDependencesManager ():void
		{
			// Récupérer l'instance du manager
			_dependencesManager = DependencesManager.getInstance(_dependencesManagerName);
		}
		
		/**
		 * Request an action
		 */
		public function requestAction (pAction:IAction):void
		{
			
		}
		
		/**
		 * Get last action in history
		 */
		public function back ():void
		{
			
		}
		
		/**
		 * Dispose
		 */
		public function dispose ():void
		{
			// Supprimer les signaux
			_onActionRequested.removeAll();
			_onViewControllerChange.removeAll();
			_onActionRequested = null;
			_onViewControllerChange = null;
			
			// Signaler et supprimer
			_onDisposed.dispatch();
			_onDisposed.removeAll();
			_onDisposed = null;
		}
	}
}