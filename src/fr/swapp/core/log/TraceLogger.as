package fr.swapp.core.log 
{
	/**
	 * @author ZoulouX
	 */
	public class TraceLogger implements ILogger
	{
		/**
		 * Le constructeur
		 */
		public function TraceLogger ()
		{
			
		}
		
		
		/**
		 * Log level logging
		 */
		public function log (...rest):void
		{
			trace.apply(null, rest);
		}
		
		/**
		 * Debug level logging
		 */
		public function debug (...rest):void
		{
			trace.apply(null, rest);
		}
		
		/**
		 * Warning level logging
		 */
		public function warning (...rest):void
		{
			trace.call(null, "2:" + rest.join(", "));
		}
		
		/**
		 * Fatal level logging
		 */
		public function fatal (...rest):void
		{
			trace.call(null, "3:" + rest.join(", "));
		}
		
		/**
		 * Error level logging
		 */
		public function error (...rest):void
		{
			trace.call(null, "3:" + rest.join(", "));
		}
		
		/**
		 * Success level loggings
		 */
		public function success (...rest):void
		{
			trace.call(null, "4:" + rest.join(", "));
		}
		
		/**
		 * Notice level logging
		 */
		public function notice (...rest):void
		{
			trace.call(null, "0:" + rest.join(", "));
		}
		
		/**
		 * Framework internal level logging.
		 * If you don't work on the framework internals, don't use.
		 */
		public function core (pCaller:Object, pMethodName:String = "", pArguments:Array = null):void
		{
			trace.apply(null, arguments);
		}
	}
}