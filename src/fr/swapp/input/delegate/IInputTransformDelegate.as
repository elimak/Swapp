package fr.swapp.input.delegate 
{
	import flash.display.DisplayObject;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	/**
	 * @author ZoulouX
	 */
	public interface IInputTransformDelegate extends IInputDelegate
	{
		/**
		 * Transformation is starting (at least 2 input points on the target)
		 * @param	pInputType : The input type (see InputTypes)
		 * @param	pTarget : The target.
		 * @return : Target to apply transformations on. (You can choose any target added to the stage, return null to keep current)
		 */
		function inputTransformStartHandler (pInputType:uint, pTarget:DisplayObject):DisplayObject;
		
		/**
		 * Transformation is stopped (less than 2 input points on the target)
		 * @param	pInputType : The input type (see InputTypes)
		 * @param	pTarget : La cible
		 */
		function inputTransformStopHandler (pInputType:uint, pTarget:DisplayObject):void;
		
		/**
		 * Set input matrix types accepted by inputTransformHandler.
		 * @param	pInputType : The input type (see InputTypes)
		 * @param	pTarget : The target.
		 * @return You have to return the allowed InputMatrixOptions, can be added by | operator.
		 */
		function inputTransformMatrixType (pInputType:uint, pTarget:DisplayObject):uint;
		
		/**
		 * Transform occurs (2 input points at least).
		 * Offsets are used to compute your transformation representation.
		 * @param	pInputType : The input type (see InputTypes)
		 * @param	pTarget : The target.
		 * @param	pScaleDelta : Scale offset since last call.
		 * @param	pRotationDelta : Rotation offset since last call.
		 * @param	pXDelta : Horizontal offset since last call.
		 * @param	pYDelta : Vertical offset since last call.
		 * @param	pPoints : Total used points.
		 * @return : Return true to allow parents to get inputTransformHandler.
		 */
		function inputTransformHandler (pInputType:uint, pTarget:DisplayObject, pScaleDelta:Number, pRotationDelta:Number, pXDelta:Number, pYDelta:Number, pPoints:uint):Boolean;
		
		/**
		 * Transform occurs (2 input points at least).
		 * Matrix is used to compute your transformation representation.
		 * @param	pInputType : The input type (see InputTypes)
		 * @param	pTarget : The target.
		 * @param	pOffsetMatrix : Offset transformation matrix since last call.
		 * @param	pPoints : Total used points.
		 * @return : Return true to allow parents to get inputTransformHandler.
		 */
		function inputMatrixTransformHandler (pInputType:uint, pTarget:DisplayObject, pOffsetMatrix:Matrix, pPoints:uint):Boolean
	}
}