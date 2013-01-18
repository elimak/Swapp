package fr.swapp.core.log 
{
	import com.demonsters.debugger.MonsterDebugger;
	
	/**
	 * @author ZoulouX
	 */
	public class MonsterLogger implements ILogger
	{
		/**
		 * Les couleurs
		 */
		public static const LOG_COLOR				:uint			 = 0x000000;
		public static const DEBUG_COLOR				:uint			 = 0x000000;
		public static const WARNING_COLOR			:uint			 = 0xe59203;
		public static const ERROR_COLOR				:uint			 = 0xe02727;
		public static const SUCCESS_COLOR			:uint			 = 0x0e9e33;
		public static const NOTICE_COLOR			:uint			 = 0x666666;
		public static const CORE_COLOR				:uint			 = 0x666666;
		
		public var traceDepth:uint			= 10;
		
		/**
		 * Le constructeur
		 */
		public function MonsterLogger (pBase:Object, pAddress:String = "127.0.0.1")
		{
			// Initialiser le debugger
			MonsterDebugger.initialize(pBase, pAddress);
		}
		
		public function log (...rest):void 
		{
			MonsterDebugger.log.apply(null, rest);
		}
		
		public function debug (pDebugName:String, pObject:*):void 
		{
			MonsterDebugger.trace(this, pObject, null, pDebugName, DEBUG_COLOR, traceDepth);
		}
		
		public function warning (pString:String, pCode:uint = 0):void 
		{
			MonsterDebugger.trace(null, pString, null, pCode as String, WARNING_COLOR);
		}
		
		public function fatal (pString:String, pCode:uint = 0):void 
		{
			MonsterDebugger.trace(null, pString, null, pCode as String, ERROR_COLOR);
		}
		
		public function error (pString:String, pCode:uint = 0):void 
		{
			MonsterDebugger.trace(null, pString, null, pCode as String, ERROR_COLOR);
		}
		
		public function success (pString:String, pCode:uint = 0):void 
		{
			MonsterDebugger.trace(null, pString, null, pCode as String, SUCCESS_COLOR);
		}
		
		public function notice (...rest):void 
		{
			MonsterDebugger.trace(null, rest, null, null, NOTICE_COLOR);
		}
		
		public function core (pCaller:Object, pMethodName:String = "", pArguments:Array = null):void 
		{
			MonsterDebugger.trace(pCaller, pArguments, null, pMethodName, CORE_COLOR);
		}
	}
}