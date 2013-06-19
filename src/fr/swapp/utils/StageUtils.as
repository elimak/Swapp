package fr.swapp.utils
{
	import flash.display.Stage;
	
	/**
	 * @author ZoulouX
	 */
	public class StageUtils
	{
		/**
		 * Access to the main stage.
		 * Used by EnvUtils, have to be setted on app creation.
		 */
		public static var mainStage			:Stage;
		
		
		/**
		 * Throw error if main stage is not defined
		 * @param	pFromMethodSignature : Method name who needs the MAIN_STAGE reference
		 * @return : Will return true if the main stage is valid
		 */
		public static function throwErrorIfMainStageNotDefined (pFromMethodSignature:String):Boolean
		{
			if (mainStage == null)
			{
				throw new SwappUtilsError(pFromMethodSignature, "StageUtils.MAIN_STAGE is not defined.");
				return false;
			}
			else
			{
				return true;
			}
		}
	}
}