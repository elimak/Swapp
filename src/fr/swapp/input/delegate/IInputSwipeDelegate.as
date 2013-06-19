package fr.swapp.input.delegate 
{
	import flash.display.DisplayObject;
	//import flash.display.DisplayObject;
	
	/**
	 * @author ZoulouX
	 */
	public interface IInputSwipeDelegate extends IInputDelegate
	{
		/**
		 * Swipe on a target.
		 * @param	pInputType : The input type (see InputTypes)
		 * @param	pTarget : The target.
		 * @param	pDirection : Drag direction, see statics at InputDirections..
		 */
		function inputSwipeDelegate (pInputType:uint, pTarget:DisplayObject, pDirection:String):void
	}
}