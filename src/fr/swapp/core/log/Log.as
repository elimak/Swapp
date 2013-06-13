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
		 * Debugger un objet (afficher son arborescence)
		 * @param	pDebugName : Nom du debug (pour s'y retrouver)
		 * @param	pObject : Objet à débugger. Tous les objets sont accéptés et seront parsés. Attentions à la récursivité!
		 */
		public static function debug (pDebugName:String, pObject:*):void
		{
			dispatchLoggerAction(DEBUG_LEVEL, arguments);
		}
		
		/**
		 * Afficher un avertissement
		 * @param	pString : Nom de l'avertissement
		 * @param	pCode : Code de l'avertissements
		 */
		public static function warning (pString:String, pCode:uint = 0):void
		{
			dispatchLoggerAction(WARNING_LEVEL, arguments);
		}
		
		/**
		 * Afficher une erreur fatale
		 * @param	pString : Nom de l'erreur fatale
		 * @param	pCode : Code de l'erreur fatale
		 */
		public static function fatal (pString:String, pCode:uint = 0):void
		{
			dispatchLoggerAction(FATAL_LEVEL, arguments);
		}
		
		/**
		 * Afficher une erreur
		 * @param	pString : Nom de l'erreur
		 * @param	pCode : Code de l'erreur
		 */
		public static function error (pString:String, pCode:uint = 0):void
		{
			dispatchLoggerAction(ERROR_LEVEL, arguments);
		}
		
		/**
		 * Afficher une réussite
		 * @param	pString : Nom de la réussite
		 * @param	pCode : Code de la réussite
		 */
		public static function success (pString:String, pCode:uint = 0):void
		{
			dispatchLoggerAction(SUCCESS_LEVEL, arguments);
		}
		
		/**
		 * Afficher un élément à noter (peu important)
		 * @param	...rest : Tous les paramètres sont acceptés
		 */
		public static function notice (...rest):void
		{
			dispatchLoggerAction(NOTICE_LEVEL, rest);
		}
		
		/**
		 * Log interne au framework
		 * @param	pCaller : l'objet appelant (la plupart du temps, 'this' suffit)
		 * @param	pMethodName : Le nomde la méthode appelée
		 * @param	pArguments : Les arguments associés (la plupart du temps, 'arguments' suffit)
		 */
		public static function core (pCaller:Object, pMethodName:String = "", pArguments:Array = null):void
		{
			dispatchLoggerAction(CORE_LEVEL, arguments);
		}
		
		/**
		 * Dispatcher une action sur les debuggers
		 * @param	pAction
		 * @param	pParams
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