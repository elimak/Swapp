package fr.swapptesting.touch
{
	import flash.display.StageQuality;
	import fr.swapp.graphic.document.SAirDocument;
	
	/**
	 * @author ZoulouX
	 */
	public class TouchTest extends SAirDocument
	{
		protected var _container:TransformContainer;
		
		public function TouchTest ()
		{
			
		}
		
		override public function init ():void
		{
			// Initialiser les log avec trace
			initTraceLogger();
			
			// Initialiser le SWrapper pour les composants
			initWrapper(true, true, 1024, 720);
			
			stage.quality = StageQuality.BEST;
			
			// Initialiser la gestion des touch avec les paramètres par défaut
			enableTouchDispatcher();
			
			// Initialiser l'emulateur de touch pour desktop avec les paramètres par défaut
			enableTouchEmulator();
			
			initContainer();
			
			super.init();
		}
		
		protected function initContainer ():void
		{
			_container = new TransformContainer();
			_container.into(_wrapper.root);
			//_container.scaleX = .5;
			//_container.scaleY = .5;
		}
	}
}