package fr.swapp.core.mvc
{
	import flash.display.DisplayObjectContainer;
	import fr.swapp.core.dependences.DependencesManager;
	import fr.swapp.core.errors.SwappError;
	
	/**
	 * @author ZoulouX
	 */
	public class ViewController extends Controller implements IViewController
	{
		/**
		 * Associated view container
		 */
		protected var _container			:DisplayObjectContainer;
		
		/**
		 * Associated view
		 */
		protected var _view					:IView;
		
		/**
		 * Auto dispose controller when view is disposed
		 */
		protected var _autoDispose			:Boolean						= true;
		
		/**
		 * If controller was initialized
		 */
		protected var _initialized			:Boolean;
		
		
		/**
		 * Associated view
		 */
		public function get view ():IView { return _view; }
		
		/**
		 * Associated view container
		 */
		public function get container ():DisplayObjectContainer { return _container; }
		public function set container (pValue:DisplayObjectContainer):void
		{
			// Vérifier que la valeur du container soit différente
			if (pValue != _container)
			{
				// Enregistrer le container
				_container = pValue;
				
				// Vérifier si on doit lancer l'init
				checkForInit();
			}
		}
		
		/**
		 * Check for init. If container and view are set, init is fired.
		 */
		protected function checkForInit ():void
		{
			// Si le controller n'a pas déjà été initialisé
			if (!_initialized && _container != null && _view != null)
			{
				// On ajoute la vue au container
				_container.addChild(_view.displayObject);
				
				// Lancer l'init
				init();
				
				// Il a été initialisé
				_initialized = true;
			}
		}
		
		/**
		 * Auto dispose controller when view is disposed
		 */
		public function get autoDispose ():Boolean { return _autoDispose; }
		
		
		/**
		 * Construction
		 */
		public function ViewController ()
		{
			
		}
		
		
		/**
		 * Set view class
		 */
		protected function setView (pViewClass:Class):void
		{
			// Instancier la vue
			_view = DependencesManager.getInstance().instanciate(pViewClass) as IView;
			
			// Ecouter quand la vue est disposée
			_view.onDisposed.add(viewDisposedHandler);
			
			// Vérifier si on doit lancer l'init
			checkForInit();
		}
		
		/**
		 * Set events via central
		 */
		protected function setEvent ():void
		{
			
		}
		
		/**
		 * View is disposed
		 */
		protected function viewDisposedHandler ():void
		{
			// Si on est en autoDispose
			if (_autoDispose)
			{
				// Virer autoDispose pour éviter la récursivité de suppression de la vue
				_autoDispose = false;
				
				// On dispose aussi ce controller
				dispose();
			}
		}
		
		/**
		 * Turning on the controller
		 */
		override public function turnOn ():void
		{
			// Démarrage
			dispatchEngineSignal(_onTurningOn);
			
			// Initialiser le container
			initContainer();
			
			// Initialiser la vue
			initView();
			
			// Démarré
			dispatchEngineSignal(_onTurnedOn);
		}
		
		/**
		 * Turning off the controller
		 */
		override public function turnOff ():void
		{
			// Démarrage
			dispatchEngineSignal(_onTurningOff);
			
			// Disposer la vue
			disposeView();
			
			// Disposer le container
			disposeContainer();
			
			// Démarré
			dispatchEngineSignal(_onTurnedOff);
		}
		
		/**
		 * Initialize container
		 */
		protected function initContainer ():void
		{
			
		}
		
		/**
		 * Initialize associated view
		 */
		protected function initView ():void
		{
			
		}
		
		/**
		 * Dispose view
		 */
		protected function disposeView ():void
		{
			// Si on a un container et une vue
			if (_container != null && _view != null && _container.contains(_view.displayObject))
			{
				// On vire la vue de son container
				_container.removeChild(_view.displayObject);
			}
			
			// Supprimer la référence
			_view = null;
		}
		
		/**
		 * Dispose container
		 */
		protected function disposeContainer ():void
		{
			// Supprimer la référence
			_container = null;
		}
		
		/**
		 * Destruction
		 */
		override public function dispose ():void
		{
			// Si on est en autoDispose
			if (_autoDispose)
			{
				// Disposer la vue si besoin
				disposeView();
			}
			
			// Dispose le container si besoin
			disposeContainer();
		}
	}
}