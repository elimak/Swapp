package fr.swapp.graphic.views
{
	import fr.swapp.core.actions.Action;
	import fr.swapp.core.mvc.IViewController;
	import fr.swapp.graphic.navigation.STitleBar;
	
	/**
	 * @author ZoulouX
	 */
	public class STitledNavigationView extends SNavigationView
	{
		/**
		 * The TitleBar component
		 */
		protected var _titleBar					:STitleBar;
		
		
		/**
		 * The TitleBar component
		 */
		public function get titleBar ():STitleBar { return _titleBar; }
		
		
		/**
		 * Constructor
		 */
		public function STitledNavigationView () { }
		
		
		/**
		 * Before interface construction
		 */
		override protected function beforeBuildInterface ():void
		{
			// Relayer
			super.beforeBuildInterface();
			
			// Créer et ajouter la navigationStack
			_titleBar = new STitleBar();
			_titleBar.into(this);
		}
		
		/**
		 * When view controller is changed
		 */
		override protected function navigationStackViewControllerChangedHandler (pAction:Action, pOldController:IViewController, pNewController:IViewController):void
		{
			
		}
	}
}