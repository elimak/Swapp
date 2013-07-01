package fr.swapptesting.global
{
	import flash.display.StageAspectRatio;
	import fr.swapp.core.data.config.Config;
	import fr.swapp.graphic.document.SAirDocument;
	import fr.swapptesting.global.app.GlobalAppViewController;
	
	/**
	 * @author ZoulouX
	 */
	public class GlobalTestDocument extends SAirDocument
	{
		/**
		 * Constructor
		 */
		public function GlobalTestDocument () { }
		
		/**
		 * Document initialization
		 */
		override protected function init ():void
		{
			// Enable logger
			enableLogger();
			
			// Enable config
			enableConfig(Config.DEBUG_ENVIRONMENT, {
				// GLOBAL
				
			}, {
				// DEBUG
				
			}, {
				// TEST
				
			}, {
				// PRODUCTION
				
			});
			
			// Enable input dispatcher
			enableInputDispatcher(true, true);
			
			// Enable touch emulator for desktop
			enableTouchEmulator();
			
			// Créer le wrapper
			enableWrapper(true, true, NaN, NaN, StageAspectRatio.ANY);
		}
		
		/**
		 * L'app est prête
		 */
		override protected function ready ():void
		{
			// Activer l'appController
			setupAppViewController(GlobalAppViewController);
		}
	}
}