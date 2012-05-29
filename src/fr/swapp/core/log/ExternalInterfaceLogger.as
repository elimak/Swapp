package fr.swapp.core.log
{
	import flash.external.ExternalInterface;
	
	/**
	 * @author ZoulouX
	 */
	public class ExternalInterfaceLogger implements ILogger
	{
		/**
		 * Si le logger est activé
		 */
		protected var _enabled						:Boolean;
		
		/**
		 * Le nom de la fonction log
		 */
		protected var _functionName					:String;
		
		/**
		 * Le constructeur
		 * @param	pLogFunctionName : Le nom de la fonction log à appeler sur l'ExternalInterface
		 */
		public function ExternalInterfaceLogger (pLogFunctionName:String = "console.log")
		{
			// Vérifier si on doit activer
			_enabled = ExternalInterface.available;
			
			// Enregistrer le nom de la fonction
			_functionName = pLogFunctionName;
		}
		
		public function log (... rest):void
		{
			if (_enabled)
				ExternalInterface.call.apply(null, [_functionName, Log.LOG_ACTION, rest]);
		}
		
		public function debug (pDebugName:String, pObject:*):void
		{
			if (_enabled)
				ExternalInterface.call.apply(null, [_functionName, Log.DEBUG_ACTION, pDebugName, pObject]);
		}
		
		public function warning (pString:String, pCode:uint = 0):void
		{
			if (_enabled)
				ExternalInterface.call.apply(null, [_functionName, Log.WARNING_ACTION, pString, pCode]);
		}
		
		public function fatal (pString:String, pCode:uint = 0):void
		{
			if (_enabled)
				ExternalInterface.call.apply(null, [_functionName, Log.FATAL_ACTION, pString, pCode]);
		}
		
		public function error (pString:String, pCode:uint = 0):void
		{
			if (_enabled)
				ExternalInterface.call.apply(null, [_functionName, Log.ERROR_ACTION, pString, pCode]);
		}
		
		public function success (pString:String, pCode:uint = 0):void
		{
			if (_enabled)
				ExternalInterface.call.apply(null, [_functionName, Log.SUCCESS_ACTION, pString, pCode]);
		}
		
		public function notice (...rest):void
		{
			if (_enabled)
				ExternalInterface.call.apply(null, [_functionName, Log.NOTICE_ACTION, rest]);
		}
		
		public function core (pCaller:Object, pMethodName:String = "", pArguments:Array = null):void
		{
			if (_enabled)
				ExternalInterface.call.apply(null, [_functionName, Log.CORE_ACTION, String(pCaller), pMethodName, pArguments]);
		}
	}
}