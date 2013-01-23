package fr.swapptesting.mvc
{
	import fr.swapp.graphic.document.SAirDocument;
	import fr.swapptesting.mvc.modules.app.MVCAppViewController;
	
	/**
	 * @author ZoulouX
	 */
	public class MVCTestDocument extends SAirDocument
	{
		/**
		 * Constructeur
		 */
		public function MVCTestDocument ()
		{
		
		}
		
		/**
		 * Initialisation du document
		 */
		override public function init():void
		{
			// Initialiser les log avec trace
			initTraceLogger();
			
			// Initialiser le SWrapper pour les composants
			initWrapper(true, true);
			
			// Afficher les stats FPS
			showStats();
			
			// Initialiser la gestion des touch avec les paramètres par défaut
			enableTouchDispatcher();
			
			// Initialiser l'emulateur de touch pour desktop avec les paramètres par défaut
			enableTouchEmulator();
			
			// Activer l'AppViewController
			setupAppViewController(MVCAppViewController);
		}
	}
}