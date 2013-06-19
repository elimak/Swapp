package fr.swapp.input.dispatcher
{
	/**
	 * All available options for matrix transformations.
	 * These options are uint and can be added with the | operator.
	 * @author ZoulouX
	 */
	public class InputMatrixOptions
	{
		/**
		 * Scale option
		 */
		public static const SCALE_OPTION				:uint 						= 1;
		
		/**
		 * Rotation option
		 */
		public static const ROTATION_OPTION				:uint 						= 2;
		
		/**
		 * Drag option
		 */
		public static const DRAG_OPTION					:uint 						= 4;
	}
}