package fr.swapp.core.log 
{
	/**
	 * @author ZoulouX
	 */
	public interface ILogger
	{
		/**
		 * Log level logging
		 */
		function log (...rest):void
		
		/**
		 * Debug level logging
		 */
		function debug (...rest):void
		
		/**
		 * Warning level logging
		 */
		function warning (...rest):void
		
		/**
		 * Fatal level logging
		 */
		function fatal (...rest):void
		
		/**
		 * Error level logging
		 */
		function error (...rest):void
		
		/**
		 * Success level loggings
		 */
		function success (...rest):void
		
		/**
		 * Notice level logging
		 */
		function notice (...rest):void
		
		/**
		 * Framework internal level logging.
		 * If you don't work on the framework internals, don't use.
		 */
		function core (pCaller:Object, pMethodName:String = "", pArguments:Array = null):void
	}	
}