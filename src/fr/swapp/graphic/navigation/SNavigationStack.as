package fr.swapp.graphic.navigation
{
	import fr.swapp.core.actions.IAction;
	import fr.swapp.core.mvc.IViewController;
	import fr.swapp.core.navigation.Bootstrap;
	import fr.swapp.core.navigation.IBootstrap;
	import fr.swapp.graphic.base.SContainer;
	
	/**
	 * @author ZoulouX
	 */
	public class SNavigationStack extends SContainer
	{
		/**
		 * Associated bootstrap
		 */
		protected var _bootstrap				:IBootstrap;
		
		/**
		 * Associated bootstrap
		 */
		public function get bootstrap ():IBootstrap { return _bootstrap; }
		
		
		/**
		 * Constructor
		 * @param	pBootstrap : Le bootstrap associé
		 */
		public function SNavigationStack (pBootstrap:IBootstrap = null)
		{
			// Enregistrer le bootstrap ou en créer un nouveau
			_bootstrap = (pBootstrap == null ? new Bootstrap() : pBootstrap);
			
			// Définir le container
			_bootstrap.container = container;
			
			// Ecouter lorsque le bootstrap change de viewVontroller
			_bootstrap.onViewControllerChanged.add(bootstrapViewControllerChangedHandler);
		}
		
		/**
		 * When bootstrap's viewController has changed
		 */
		protected function bootstrapViewControllerChangedHandler (pAction:IAction, pOldViewController:IViewController, pNewViewController:IViewController):void
		{
			
		}
		
		/**
		 * Destruction
		 */
		override public function dispose ():void
		{
			// Ne plus écouter le bootstrap
			_bootstrap.onViewControllerChanged.remove(bootstrapViewControllerChangedHandler);
			
			// Disposer le bootstrap
			_bootstrap.dispose();
			_bootstrap = null;
			
			// Relayers
			super.dispose();
		}
	}
}