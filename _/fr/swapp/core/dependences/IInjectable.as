package fr.swapp.core.dependences 
{
	/**
	 * Permet d'avoir une API sur les éléments dont des dépendances sont injectées via le manager de dépendance.
	 * @author ZoulouX
	 */
	public interface IInjectable 
	{
		/**
		 * Appelé par le manager de dépendances lorsqu'une valeur est injectée.
		 * @param	pPropertyName : Le nom de la valeur injectée
		 * @param	pInjectedValue : La propriété injectée
		 */
		function valueInjected (pPropertyName:String, pInjectedValue:*):void;
		
		/**
		 * Tout a été injecté.
		 */
		function valuesInjected ():void;
	}
}