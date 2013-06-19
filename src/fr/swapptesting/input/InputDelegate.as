package fr.swapptesting.input
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import fr.swapp.core.log.Log;
	import fr.swapp.input.delegate.IInputDragDelegate;
	
	/**
	 * @author ZoulouX
	 */
	public class InputDelegate extends Sprite implements IInputDragDelegate
	{
		public function InputDelegate ()
		{
			graphics.beginFill(0xDDDDDD);
			graphics.drawRect(0, 0, 2000, 2000);
			graphics.endFill();
		}
		
		/* INTERFACE fr.swapp.input.delegate.IInputDragDelegate */
		
		public function inputDragLock (pInputType:uint, pTarget:DisplayObject):void
		{
			Log.notice("inputDragLock", pInputType, pTarget);
		}
		
		public function inputDragUnlock (pInputType:uint, pTarget:DisplayObject):void
		{
			Log.notice("inputDragUnlock", pInputType, pTarget);
		}
		
		public function inputDragging (pInputType:uint, pTarget:DisplayObject, pDirection:String, pXDelta:Number, pYDelta:Number):Boolean
		{
			Log.notice("inputDragging", pInputType, pTarget, pDirection, pXDelta, pYDelta);
			
			return true;
		}
	}
}