package fr.swapp.input.delegate
{
	import flash.display.DisplayObject;
	
	/**
	 * @author ZoulouX
	 */
	public interface IInputDoubleDelegate extends IInputDelegate
	{
		/**
		 * Double interaction.
		 * @param	pInputType : The input type (see InputTypes)
		 * @param	pTarget : The target.
		 * @param	pTimeOffset : Time elapsed between the 2 interactions, in ms.
		 */
		function inputDoubleHandler (pInputType:uint, pTarget:DisplayObject, pTimeOffset:int):void;
	}
}