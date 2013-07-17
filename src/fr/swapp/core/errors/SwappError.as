package fr.swapp.core.errors 
{
	import fr.swapp.core.log.Log;
	import fr.swapp.utils.ClassUtils;
	
	/**
	 * Internal swapp core error
	 * @author ZoulouX
	 */
	public class SwappError extends Error 
	{
		/**
		 * Throw runtime error for internal framework
		 * @param	pMethod : Class and method name firing the error like : "MyClass.myMethod"
		 * @param	pMessage : Associated message to the error
		 * @param	pId : Error ID (optionnal)
		 */
		public function SwappError (pMethod:String, pMessage:String, pId:uint = 0)
		{
			// Afficher l'erreur
			super("# " + ClassUtils.getClassNameFromInstance(this) + " in " + pMethod + " : " + pMessage + "\n" + getStackTrace(), pId);
		}
		
		/**
		 * Log error without throwing it
		 */
		public function log (pWarningLevel:Boolean = true):void
		{
			pWarningLevel ? Log.warning(this.message) : Log.error(this.message);
		}
	}
}