﻿package fr.swapp.core.log 
{
	import flash.utils.Dictionary;
	
	/**
	 * @author ZoulouX
	 */
	public class Log
	{
		/**
		 * Les différentes actions disponibles
		 */
		public static const LOG_ACTION			:String					= "log";
		public static const DEBUG_ACTION		:String					= "debug";
		public static const WARNING_ACTION		:String					= "warning";
		public static const FATAL_ACTION		:String					= "fatal";
		public static const ERROR_ACTION		:String					= "error";
		public static const SUCCESS_ACTION		:String					= "success";
		public static const NOTICE_ACTION		:String					= "notice";
		public static const CORE_ACTION			:String					= "core";
		
		/**
		 * La liste des loggers
		 */
		protected static var __loggers			:Dictionary 			= new Dictionary(false);
		
		/**
		 * Les actions activées
		 */
		protected static var _enabledActions	:Object					= {
			LOG_ACTION		: true,
			DEBUG_ACTION	: true,
			WARNING_ACTION 	: true,
			FATAL_ACTION 	: true,
			ERROR_ACTION 	: true,
			SUCCESS_ACTION 	: true,
			NOTICE_ACTION 	: true,
			CORE_ACTION		: true
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
		 * Action une action
		 * @param	pActionName : Le nom de l'action à désactiver (ex: 'trace', 'core', 'debug'...)
		 */
		public static function enableAction (pActionName:String):void
		{
			_enabledActions[pActionName] = true;
		}
		
		/**
		 * Désactiver une action
		 * @param	pActionName : Le nom de l'action à désactiver (ex: 'trace', 'core', 'debug'...)
		 */
		public static function disableAction (pActionName:String):void
		{
			_enabledActions[pActionName] = false;
		}
		
		/**
		 * Tracer un ou plusieurs éléments
		 * @param	...rest : Tous les paramètres sont acceptés
		 */
		public static function log (...rest):void
		{
			dispatchLoggerAction(LOG_ACTION, rest);
		}
		
		/**
		 * Debugger un objet (afficher son arborescence)
		 * @param	pDebugName : Nom du debug (pour s'y retrouver)
		 * @param	pObject : Objet à débugger. Tous les objets sont accéptés et seront parsés. Attentions à la récursivité!
		 */
		public static function debug (pDebugName:String, pObject:*):void
		{
			dispatchLoggerAction(DEBUG_ACTION, arguments);
		}
		
		/**
		 * Afficher un avertissement
		 * @param	pString : Nom de l'avertissement
		 * @param	pCode : Code de l'avertissements
		 */
		public static function warning (pString:String, pCode:uint = 0):void
		{
			dispatchLoggerAction(WARNING_ACTION, arguments);
		}
		
		/**
		 * Afficher une erreur fatale
		 * @param	pString : Nom de l'erreur fatale
		 * @param	pCode : Code de l'erreur fatale
		 */
		public static function fatal (pString:String, pCode:uint = 0):void
		{
			dispatchLoggerAction(FATAL_ACTION, arguments);
		}
		
		/**
		 * Afficher une erreur
		 * @param	pString : Nom de l'erreur
		 * @param	pCode : Code de l'erreur
		 */
		public static function error (pString:String, pCode:uint = 0):void
		{
			dispatchLoggerAction(ERROR_ACTION, arguments);
		}
		
		/**
		 * Afficher une réussite
		 * @param	pString : Nom de la réussite
		 * @param	pCode : Code de la réussite
		 */
		public static function success (pString:String, pCode:uint = 0):void
		{
			dispatchLoggerAction(SUCCESS_ACTION, arguments);
		}
		
		/**
		 * Afficher un élément à noter (peu important)
		 * @param	...rest : Tous les paramètres sont acceptés
		 */
		public static function notice (...rest):void
		{
			dispatchLoggerAction(NOTICE_ACTION, rest);
		}
		
		/**
		 * Log interne au framework
		 * @param	pCaller : l'objet appelant (la plupart du temps, 'this' suffit)
		 * @param	pMethodName : Le nomde la méthode appelée
		 * @param	pArguments : Les arguments associés (la plupart du temps, 'arguments' suffit)
		 */
		public static function core (pCaller:Object, pMethodName:String = "", pArguments:Array = null):void
		{
			dispatchLoggerAction(CORE_ACTION, arguments);
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
	}
}