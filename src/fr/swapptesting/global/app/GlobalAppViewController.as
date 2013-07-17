package fr.swapptesting.global.app
{
	import fr.swapp.core.log.Log;
	import fr.swapp.core.mvc.AppViewController;
	
	/**
	 * @author ZoulouX
	 */
	public class GlobalAppViewController extends AppViewController
	{
		/**
		 * Constructor
		 */
		public function GlobalAppViewController () { }
		
		
		/**
		 * Sub constructor
		 */
		override protected function construct ():void
		{
			// Définir la vue
			setView(GlobalAppView);
		}
		
		
		/**
		 * External command
		 */
		override public function externalCommand (pCommand:String, pParameters:Object):Boolean
		{
			Log.warning("External command from GlobalAppViewController " + pCommand);
			
			return true;
		}
	}
}