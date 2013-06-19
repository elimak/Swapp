package fr.swapptesting.input
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import fr.swapp.core.log.Log;
	import fr.swapp.core.log.TraceLogger;
	import fr.swapp.input.delegate.IInputDragDelegate;
	import fr.swapp.input.dispatcher.InputDispatcher;
	import fr.swapp.input.emulator.MouseToTouchEmulator;
	import fr.swapp.utils.StageUtils;
	
	/**
	 * @author ZoulouX
	 */
	public class InputDispatcherTest extends Sprite
	{
		protected var _dispatcher:InputDispatcher;
		/**
		 * Constructor
		 */
		public function InputDispatcherTest ()
		{
			// Check and wait for stage availability
			(stage != null ? construct() : addEventListener(Event.ADDED_TO_STAGE, construct));
		}
		
		
		/**
		 * Second constructeur
		 */
		protected function construct (event:Event = null):void
		{
			// Initialiser le logger trace
			Log.addLogger(new TraceLogger);
			
			// Définir le stage
			StageUtils.mainStage = stage;
			
			// Créer le dispatcher
			_dispatcher = InputDispatcher.getInstance(stage);
			
			// Ajouter l'émulateur
			MouseToTouchEmulator.auto(stage);
			
			addChild(new InputDelegate());
		}
	}
}