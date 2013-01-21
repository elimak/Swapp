package fr.swapp.graphic.document
{
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.events.InvokeEvent;
	
	/**
	 * @author ZoulouX
	 */
	public class SAirDocument extends SFlashDocument
	{
		/**
		 * Constructor
		 */
		public function SAirDocument ()
		{
			// Ecouter events de l'app
			NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, invokeHandler);
			NativeApplication.nativeApplication.addEventListener(Event.EXITING, exitHandler);
			NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, activateHandler);
			NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, deactivateHandler);
			
			// Relayer
			super();
		}
		
		/**
		 * When application is resumed
		 */
		protected function activateHandler (event:Event):void 
		{
			
		}
		
		/**
		 * When application is minimized
		 */
		protected function deactivateHandler (event:Event):void 
		{
			
		}
		
		/**
		 * When invoke command is fired
		 */
		protected function invokeHandler (event:InvokeEvent):void
		{
			
		}
		
		/**
		 * When application is closed
		 */
		protected function exitHandler (event:Event):void 
		{
			
		}
	}
}