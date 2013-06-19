package fr.swapp.core.log 
{
	import flash.utils.Dictionary;
	
	/**
	 * @author ZoulouX
	 */
	public class Log
	{
		/**
		 * Les différentes niveaux disponibles
		 */
		public static const LOG_LEVEL			:String					= "log";
		public static const DEBUG_LEVEL			:String					= "debug";
		public static const WARNING_LEVEL		:String					= "warning";
		public static const ERROR_LEVEL			:String					= "error";
		public static const FATAL_LEVEL			:String					= "fatal";
		public static const SUCCESS_LEVEL		:String					= "success";
		public static const NOTICE_LEVEL		:String					= "notice";
		public static const CORE_LEVEL			:String					= "core";
		
		/**
		 * La liste des loggers
		 */
		protected static var __loggers			:Dictionary 			= new Dictionary(false);
		
		/**
		 * Les actions activées
		 */
		protected static var _enabledActions	:Object					= {
			LOG_LEVEL		: true,
			DEBUG_LEVEL		: true,
			WARNING_LEVEL 	: true,
			FATAL_LEVEL 	: true,
			ERROR_LEVEL 	: true,
			SUCCESS_LEVEL 	: true,
			NOTICE_LEVEL 	: true,
			CORE_LEVEL		: true
		};
		
		/**
		 * La liste des loggers
		 */
		public static function get loggers ():Dictionary { return __loggers; }
		
		/**
		 * Ajouter un logger
		 */
		public static function addLogger (pLogger:ILogger):void
		{
			// Enregistrer le logger dans le dico
			__loggers[pLogger] = true;
		}
		
		/**
		 * Virer un logger
		 */
		public static function removeLogger (pLogger:ILogger):void
		{
			// Supprimer le dico
			__loggers[pLogger] = null;
			delete __loggers[pLogger];
		}
		
		/**
		 * Enable a log level
		 */
		public static function enableLevel (pActionName:String):void
		{
			_enabledActions[pActionName] = true;
		}
		
		/**
		 * Disable a log level
		 */
		public static function disableLevel (pActionName:String):void
		{
			_enabledActions[pActionName] = false;
		}
		
		/**
		 * Log level logging
		 */
		public static function log (...rest):void
		{
			dispatchLoggerAction(LOG_LEVEL, rest);
		}
		
		/**
		 * Debug level logging
		 */
		public static function debug (...rest):void
		{
			dispatchLoggerAction(DEBUG_LEVEL, rest);
		}
		
		/**
		 * Warning level logging
		 */
		public static function warning (...rest):void
		{
			dispatchLoggerAction(WARNING_LEVEL, rest);
		}
		
		/**
		 * Fatal level logging
		 */
		public static function fatal (...rest):void
		{
			dispatchLoggerAction(FATAL_LEVEL, rest);
		}
		
		/**
		 * Error level logging
		 */
		public static function error (...rest):void
		{
			dispatchLoggerAction(ERROR_LEVEL, rest);
		}
		
		/**
		 * Success level loggings
		 */
		public static function success (...rest):void
		{
			dispatchLoggerAction(SUCCESS_LEVEL, rest);
		}
		
		/**
		 * Notice level logging
		 */
		public static function notice (...rest):void
		{
			dispatchLoggerAction(NOTICE_LEVEL, rest);
		}
		
		/**
		 * Framework internal level logging.
		 * If you don't work on the framework internals, don't use.
		 */
		public static function core (pCaller:Object, pMethodName:String = "", pArguments:Array = null):void
		{
			dispatchLoggerAction(CORE_LEVEL, arguments);
		}
		
		/**
		 * Dispatcher une action sur les debuggers
		 */
		protected static function dispatchLoggerAction (pAction:String, pParams:Array):void
		{
			// Parcourir les loggers
			for (var logger:Object in __loggers)
			{
				// Cibler le logger et appeler l'action
				logger[pAction].apply(null, pParams);
			}
		}
		
		/**
		 * Describe an object structure to string
		 * @param	pObject : The object to parse
		 * @param	pRecursiveLimit : Recursion limit.
		 * @return String representation of the object
		 */
		public function describeObject (pObject:String, pRecursiveLimit:uint = 10):String
		{
			return "";
		}
	}
}