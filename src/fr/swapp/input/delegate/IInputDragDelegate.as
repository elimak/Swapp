package fr.swapp.input.delegate 
{
	import flash.display.DisplayObject;
	
	/**
	 * @author ZoulouX
	 */
	public interface IInputDragDelegate extends IInputDelegate
	{
		/**
		 * Move locked by an input (like startDrag)
		 * @param	pInputType : The input type (see InputTypes)
		 * @param	pTarget : The target.
		 */
		function inputDragLock (pInputType:uint, pTarget:DisplayObject):void;
		
		/**
		 * Move is unlocked and can move (like stopDrag)
		 * @param	pInputType : The input type (see InputTypes)
		 * @param	pTarget : The target.
		 */
		function inputDragUnlock (pInputType:uint, pTarget:DisplayObject):void;
		
		/**
		 * Dragging the target. Values are rounded if multiple input points.
		 * @param	pInputType : The input type (see InputTypes)
		 * @param	pTarget : The target.
		 * @param	pDirection : Drag direction, see statics at InputDirections. (computed at the first move, this value will not change since touchDragUnlock).
		 * @param	pXDelta : Horizontal offset since last dragging call.
		 * @param	pYDelta : Vertical offset since last dragging call.
		 * @return : Return true to allow parents to get touchDraggings.
		 */
		function inputDragging (pInputType:uint, pTarget:DisplayObject, pDirection:String, pXDelta:Number, pYDelta:Number):Boolean;
	}
}