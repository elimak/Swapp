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
				// Si on avait un container qui contenant la vue et qu'on n'a plus de container
				if (pValue == null && _container != null && _view != null && _container.contains(_view.displayObject))
				{
					// On vire la vue du container
					// Ce qui peut entraîner un dispose
					_container.removeChild(_view.displayObject);
					
					// Passer la vue à null
					_view = null;
				}
				
				// Si on a un nouveau container et une vue
				if (pValue != null && _container == null && _view != null)
				{
					// Enregistrer le container avant l'ajout pour l'avoir dans l'init
					_container = pValue;
					
					// On ajoute cette vue dans le container
					// Ce qui peut entraîner l'init
					pValue.addChild(_view.displayObject);
				}
				
				// Enregistrer le container
				_container = pValue;
			}
		}
		
		
		/**
		 * Construction
		 */
		public function ViewController () { }
		
		
		/**
		 * Set view class
		 */
		protected function setView (pViewClass:Class):void
		{
			// Instancier la vue
			_view = DependencesManager.getInstance().instanciate(pViewClass) as IView;
			
			// Ecouter l'init de la vue
			_view.onInit.add(viewInitHandler);
			
			// Ecouter quand la vue est disposée
			_view.onDisposed.add(viewDisposedHandler);
		}
		
		/**
		 * View is initialized
		 */
		protected function viewInitHandler ():void
		{
			// On initialise aussi ce controller
			init();
		}
		
		/**
		 * View is disposed
		 */
		protected function viewDisposedHandler ():void
		{
			// On dispose aussi ce controller
			dispose();
		}
		
		/**
		 * Dispose
		 */
		override public function dispose ():void
		{
			// Si on avait une vue
			if (_view != null)
			{
				// Virer la référence vers la vue
				_view = null;
			}
			
			// Relayer
			super.dispose();
		}
	}
}