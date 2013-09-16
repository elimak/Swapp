package fr.swapp.graphic.views
{
	import fr.swapp.core.actions.Action;
	import fr.swapp.core.mvc.IViewController;
	import fr.swapp.graphic.navigation.SNavigationStack;
	
	/**
	 * @author ZoulouX
	 */
	public class SNavigationView extends SView
	{
		/**
		 * Get the first parent SNavigationStack recursively to the stage.
		 */
		protected var _navigationStack					:SNavigationStack;
		
		
		/**
		 * Get the first parent SNavigationStack recursively to the stage.
		 */
		override public function get navigationStack ():SNavigationStack { return this._navigationStack; }
		
		
		/**
		 * Constructor
		 */
		public function SNavigationView () { }
		
		
		/**
		 * Before interface construction
		 */
		override protected function beforeBuildInterface ():void
		{
			// Créer et ajouter la navigationStack
			_navigationStack = new SNavigationStack();
			_navigationStack.into(this);
			
			// Ecouter les changements de page
			_navigationStack.bootstrap.onViewControllerChanged.add(navigationStackViewControllerChangedHandler);
			
			// Relayer
			super.beforeBuildInterface();
		}
		
		/**
		 * When view controller is changed
		 */
		protected function navigationStackViewControllerChangedHandler (pAction:Action, pOldController:IViewController, pNewController:IViewController):void
		{
			
		}
	}
}