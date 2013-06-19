package fr.swapp.input.delegate 
{
	import flash.display.DisplayObject;
	
	/**
	 * @author ZoulouX
	 */
	public interface IInputSingleDelegate extends IInputDelegate
	{
		/**
		 * Single tap or clic.
		 * @param	pInputType : The input type (see InputTypes)
		 * @param	pTarget : The target.
		 * @param	pIsPrimaryInput : If this is the only and primary input used.
		 */
		function inputSingleHandler (pInputType:uint, pTarget:DisplayObject, pIsPrimaryInput:Boolean):void;
		
		/**
		 * Input added on the target.
		 * @param	pInputType : The input type (see InputTypes)
		 * @param	pTarget : The target.
		 * @param	pIsPrimaryInput : If this is the only and primary input used.
		 */
		function inputPressHandler (pInputType:uint, pTarget:DisplayObject, pIsPrimaryInput:Boolean):void;
		
		/**
		 * Input removed from the target.
		 * @param	pInputType : The input type (see InputTypes)
		 * @param	pTarget : The target.
		 * @param	pIsPrimaryInput : If this is the only and primary input used.
		 */
		function inputReleaseHandler (pInputType:uint, pTarget:DisplayObject, pIsPrimaryInput:Boolean):void;
	}
}