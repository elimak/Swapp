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
		
		
		/**
		 * Log level logging
		 */
		public function log (...rest):void
		{
			if (_enabled)
				ExternalInterface.call.apply(null, [_functionName, Log.LOG_LEVEL].concat(rest));
		}
		
		/**
		 * Debug level logging
		 */
		public function debug (...rest):void
		{
			if (_enabled)
				ExternalInterface.call.apply(null, [_functionName, Log.DEBUG_LEVEL].concat(rest));
		}
		
		/**
		 * Warning level logging
		 */
		public function warning (...rest):void
		{
			if (_enabled)
				ExternalInterface.call.apply(null, [_functionName, Log.WARNING_LEVEL].concat(rest));
		}
		
		/**
		 * Fatal level logging
		 */
		public function fatal (...rest):void
		{
			if (_enabled)
				ExternalInterface.call.apply(null, [_functionName, Log.FATAL_LEVEL].concat(rest));
		}
		
		/**
		 * Error level logging
		 */
		public function error (...rest):void
		{
			if (_enabled)
				ExternalInterface.call.apply(null, [_functionName, Log.ERROR_LEVEL].concat(rest));
		}
		
		/**
		 * Success level loggings
		 */
		public function success (...rest):void
		{
			if (_enabled)
				ExternalInterface.call.apply(null, [_functionName, Log.SUCCESS_LEVEL].concat(rest));
		}
		
		/**
		 * Notice level logging
		 */
		public function notice (...rest):void
		{
			if (_enabled)
				ExternalInterface.call.apply(null, [_functionName, Log.NOTICE_LEVEL].concat(rest));
		}
		
		/**
		 * Framework internal level logging.
		 * If you don't work on the framework internals, don't use.
		 */
		public function core (pCaller:Object, pMethodName:String = "", pArguments:Array = null):void
		{
			if (_enabled)
				ExternalInterface.call.apply(null, [_functionName, Log.CORE_LEVEL].concat(arguments));
		}
	}
}