package fr.swapp.core.navigation
{
	import flash.display.DisplayObjectContainer;
	import fr.swapp.core.actions.IAction;
	import fr.swapp.core.actions.IActionable;
	import fr.swapp.core.dependences.DependencesManager;
	import fr.swapp.core.dependences.IDependencesManager;
	import fr.swapp.core.log.Log;
	import fr.swapp.core.mvc.IController;
	import fr.swapp.core.mvc.IViewController;
	import fr.swapp.core.roles.IDisposable;
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
		 * When an action is requested
		 */
		protected var _onActionRequested			:Signal 			= new Signal(IAction);
		
		/**
		 * When current viewController has changed
		 */
		protected var _onViewControllerChanged		:Signal 			= new Signal(IAction, IViewController, IViewController);
		
		/**
		 * Associated dependences manager
		 */
		protected var _dependencesManager			:IDependencesManager;
		
		/**
		 * Current view controller (can be null)
		 */
		protected var _currentViewController		:IViewController;
		
		/**
		 * If bootstrap is locked
		 */
		protected var _locked						:Boolean;
		
		/**
		 * Container to inject in ViewController
		 */
		protected var _container					:DisplayObjectContainer;
		
		/**
		 * Waiting action
		 */
		protected var _waitingAction				:IAction;
		
		
		/**
		 * Actions history
		 */
		public function get history ():IHistory { return _history; }
		
		/**
		 * When an action is requested
		 */
		public function get onActionRequested ():ISignal { return _onActionRequested; }
		
		/**
		 * When current viewController has changed
		 */
		public function get onViewControllerChanged ():ISignal { return _onViewControllerChanged; }
		
		/**
		 * Associated dependences manager
		 */
		public function get dependencesManager ():IDependencesManager { return _dependencesManager; }
		
		/**
		 * Current view controller (can be null)
		 */
		public function get currentViewController ():IViewController { return _currentViewController; }
		
		/**
		 * When bootstrap is disposed
		 */
		public function get onDisposed ():ISignal { return _onDisposed; }
		
		/**
		 * If bootstrap is locked
		 */
		public function get locked ():Boolean { return _locked; }
		
		/**
		 * Container to inject in ViewController
		 */
		public function get container ():DisplayObjectContainer { return _container; }
		public function set container (value:DisplayObjectContainer):void
		{
			_container = value;
		}
		
		/**
		 * Waiting action
		 */
		public function get waitingAction ():IAction { return _waitingAction; }
		
		
		/**
		 * Bootstrap constructor
		 * @param	pDependencesManagerName : Name to get the dependences manager (via getInstance static).
		 */
		public function Bootstrap (pDependencesManagerName:String = "default")
		{
			// Récupérer l'instance du manager
			_dependencesManager = DependencesManager.getInstance(pDependencesManagerName);
		}
		
		
		/**
		 * Request an action
		 */
		public function requestAction (pAction:IAction):void
		{
			Log.core("Bootstrap.requestAction", [pAction.name]);
			
			// TODO : Trouver un moyen d'appeler plusieurs fois la même webview (même action) mais faire des push view quand même
			// TODO : Par exemple si on a une arborescence de fichiers / dossier à parcourir
			// TODO : Gérer l'historique
			// TODO : Créer un routeur?
			// TODO : Gestion des types de transition (parallèle ou séquenciel ou autre)
			// TODO : Implémenter la gestion des transitions (avec l'inversion du sens pour le back)
			// TODO : Tester de bouriner (vérifier la solidité des lock) avec différents types de transitions
			
			// Si on a une action
			if (pAction != null)
			{
				// Signaler
				_onActionRequested.dispatch(pAction);
				
				// Si cette action est mappée
				if (pAction.name in __actionsMap)
				{
					// Si on est vérouillé
					if (_locked)
					{
						// On enregistre l'action demandée
						_waitingAction = pAction;
					}
					else
					{
						// Si on a déjà un controller
						if (_currentViewController != null)
						{
							// Vérifier si on va instancier le même controller
							if (_currentViewController is __actionsMap[pAction.name])
							{
								// On passe juste l'action
								(_currentViewController as IActionable).requestAction(pAction);
							}
							else
							{
								// Vérouiller
								lock();
								
								// Enregistrer l'action en attente
								_waitingAction = pAction;
								
								// Ecouter lorsque le controller en cours est arrêté
								_currentViewController.onTurnedOff.addOnce(instanciateWaitingViewController);
								
								// On vire le controller en cours
								_currentViewController.turnOff();
							}
						}
						else
						{
							// Vérouiller
							lock();
							
							// Enregistrer l'action en attente
							_waitingAction = pAction;
							
							// Instancier le controller en attente
							instanciateWaitingViewController();
						}
					}
				}
			}
		}
		
		/**
		 * Instanciate waiting viewController from waiting action
		 */
		protected function instanciateWaitingViewController ():void
		{
			// Cibler l'action
			var action:IAction = _waitingAction;
			
			// Cibler l'ancien controller
			var oldController:IViewController = _currentViewController;
			
			// Instancier le nouveau controller et injecter automatiquement ses dépendences
			var newController:IViewController = _dependencesManager.instanciate(__actionsMap[action.name]) as IViewController;
			
			// Si on avait un controller
			if (oldController != null)
			{
				// On le vire du container
				oldController.container = null;
			}
			
			// Si on a un container à injecter
			if (_container != null)
			{
				// On l'injecte
				newController.container = _container;
			}
			
			// Ecouter le dispose
			(newController as IDisposable).onDisposed.add(viewControllerDisposedHandler);
			
			// Attendre que le nouveau soit démarré et 
			newController.onTurnedOn.addOnce(unlock);
			
			// Démarrer le nouveau controller
			newController.turnOn();
			
			// Appeler l'action sur le nouveau controller
			newController.requestAction(action);
			
			// On n'a plus d'action en attente
			_waitingAction = null;
			
			// Placer le nouveau controller en controller courant
			_currentViewController = newController;
			
			// Signaler le changement de controller
			_onViewControllerChanged.dispatch(action, oldController, newController);
		}
		
		/**
		 * Un controller a été disposé
		 */
		protected function viewControllerDisposedHandler ():void
		{
			_currentViewController = null;
		}
		
		/**
		 * Lock the bootstrap
		 */
		public function lock ():void
		{
			_locked = true;
		}
		
		/**
		 * Unlock the bootstrap
		 */
		public function unlock ():void
		{
			_locked = false;
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
			_onActionRequested = null;
			
			_onViewControllerChanged.removeAll();
			_onViewControllerChanged = null;
			
			// Supprimer les références
			_container = null;
			_currentViewController = null;
			_dependencesManager = null;
			
			// Signaler et supprimer
			_onDisposed.dispatch();
			_onDisposed.removeAll();
			_onDisposed = null;
		}
	}
}