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
		
		public function debug (pDebugName:String, pObject:*):void 
		{
			trace.apply(null, arguments);
		}
		
		public function warning (pString:String, pCode:uint = 0):void 
		{
			trace.call(null, "2:" + pString + "{code " + pCode + "}");
		}
		
		public function fatal (pString:String, pCode:uint = 0):void 
		{
			trace.call(null, "3:" + pString + "{code " + pCode + "}");
		}
		
		public function error (pString:String, pCode:uint = 0):void 
		{
			trace.call(null, "3:" + pString + "{code " + pCode + "}");
		}
		
		public function success (pString:String, pCode:uint = 0):void 
		{
			trace.call(null, "4:" + pString + "{code " + pCode + "}");
		}
		
		public function notice (...rest):void 
		{
			trace.call(null, "0:" + rest.join(", "));
		}
		
		public function core (pCaller:Object, pMethodName:String = "", pArguments:Array = null):void 
		{
			trace.apply(null, arguments);
		}
	}
}