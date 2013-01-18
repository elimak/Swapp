package fr.swapp.core.bootstrap 
{
	/**
	 * Cette classe permet au bootstrap de stocker et identifier les mappings entre actions et controlleur.
	 * @author ZoulouX
	 */
	public class BootstrapActionMapToController 
	{
		/**
		 * Le nom de l'action qui va déclancher le controlleur
		 */
		protected var _actionName					:String;
		
		/**
		 * La classe du controlleur à instancier
		 */
		protected var _controllerClass				:Class;
		
		/**
		 * Les paramètres par défaut
		 */
		protected var _defaultParams				:Object;
		
		/**
		 * Les informations du contexte par défaut
		 */
		protected var _defaultContextInfos			:Object;
		
		
		/**
		 * Le nom de l'action qui va déclancher le controlleur
		 */
		public function get actionName ():String { return _actionName; }
		
		/**
		 * La classe du controlleur à instancier
		 */
		public function get controllerClass ():Class { return _controllerClass; }
		
		/**
		 * Les paramètres par défaut
		 */
		public function get defaultParams ():Object { return _defaultParams; }
		
		/**
		 * Les informations du contexte par défaut
		 */
		public function get defaultContextInfos ():Object { return _defaultContextInfos; }
		
		
		/**
		 * Le constructeur
		 * @param	pActionName : Le nom de l'action
		 * @param	pControllerClass : La classe du controlleur à instancier
		 * @param	pDefaultParams : Les paramètres par défaut (seront écrasés à l'appel de l'action)
		 * @param	pDefaultContextInfos : Les informations du contexte par défaut (seront écrasés à l'appel de l'action)
		 */
		public function BootstrapActionMapToController (pActionName:String, pControllerClass:Class, pDefaultParams:Object = null, pDefaultContextInfos:Object = null)
		{
			// Tout enregistrer
			_actionName = pActionName;
			_controllerClass = pControllerClass;
			_defaultParams = pDefaultParams;
			_defaultContextInfos = pDefaultContextInfos;
		}
	}
}