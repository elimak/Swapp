package fr.swapptesting.mvc.modules.app
{
	import flash.display.Stage;
	import fr.swapp.core.actions.IAction;
	import fr.swapp.core.mvc.AppViewController;
	
	/**
	 * @author ZoulouX
	 */
	public class MVCAppViewController extends AppViewController
	{
		public function MVCAppViewController ()
		{
			setView(MVCAppView);
		}
		
		override public function requestAction(pAction:IAction):void 
		{
			trace("REQUEST ACTION", pAction);
		}
	}
}