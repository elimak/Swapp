package fr.swapp.core.log 
{
	/**
	 * @author ZoulouX
	 */
	public interface ILogger
	{
		/**
		 * Debugger un objet (afficher son arborescence)
		 * @param	pDebugName : Nom du debug (pour s'y retrouver)
		 * @param	pObject : Objet à débugger. Tous les objets sont accéptés et seront parsés. Attentions à la récursivité!
		 */
		function debug (pDebugName:String, pObject:*):void;
		
		/**
		 * Afficher un avertissement
		 * @param	pString : Nom de l'avertissement
		 * @param	pCode : Code de l'avertissements
		 */
		function warning (pString:String, pCode:uint = 0):void;
		
		/**
		 * Afficher une erreur fatale
		 * @param	pString : Nom de l'erreur fatale
		 * @param	pCode : Code de l'erreur fatale
		 */
		function fatal (pString:String, pCode:uint = 0):void;
		
		/**
		 * Afficher une erreur
		 * @param	pString : Nom de l'erreur
		 * @param	pCode : Code de l'erreur
		 */
		function error (pString:String, pCode:uint = 0):void;
		
		/**
		 * Afficher une réussite
		 * @param	pString : Nom de la réussite
		 * @param	pCode : Code de la réussite
		 */
		function success (pString:String, pCode:uint = 0):void;
		
		/**
		 * Afficher un élément à noter (peu important)
		 * @param	...rest : Tous les paramètres sont acceptés
		 */
		function notice (...rest):void;
		
		/**
		 * Log interne au framework
		 * @param	pCaller : l'objet appelant (la plupart du temps, 'this' suffit)
		 * @param	pMethodName : Le nomde la méthode appelée
		 * @param	pArguments : Les arguments associés (la plupart du temps, 'arguments' suffit)
		 */
		function core (pCaller:Object, pMethodName:String = "", pArguments:Array = null):void;
	}	
}