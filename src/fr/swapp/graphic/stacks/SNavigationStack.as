package fr.swapp.graphic.stacks
{
	import fr.swapp.core.actions.IAction;
	import fr.swapp.core.mvc.IViewController;
	import fr.swapp.core.navigation.Bootstrap;
	import fr.swapp.core.navigation.IBootstrap;
	import fr.swapp.graphic.base.SComponent;
	import fr.swapp.graphic.base.SView;
	
	/**
	 * @author ZoulouX
	 */
	public class SNavigationStack extends SComponent
	{
		protected var _bootstrap				:Bootstrap;
		
		
		public function get bootstrap ():Bootstrap { return _bootstrap; }
		
		
		
		public function SNavigationStack (pBootstrap:Bootstrap = null)
		{
			// Enregistrer le bootstrap ou créer un par défaut
			_bootstrap = (pBootstrap == null ? new Bootstrap() : pBootstrap);
			
			// Ecouter les changements du bootstrap
			_bootstrap.onViewControllerChange.add(bootstrapControllerChangedHandler);
		}
		
		/**
		 * Bootstrap's current controller has changed
		 */
		protected function bootstrapControllerChangedHandler (pAction:IAction, pViewController:IViewController):void
		{
			
		}
		
		
		public function pushView (pView:SView):void
		{
			
		}
		
		public function popView ():void
		{
			
		}
		
		override public function dispose ():void
		{
			// Ne plus écouter le bootstrap
			_bootstrap.onViewControllerChange.remove(bootstrapControllerChangedHandler);
			
			// Supprimer le bootstrap
			_bootstrap.dispose();
			
			// Relayer
			super.dispose();
		}
	}
}