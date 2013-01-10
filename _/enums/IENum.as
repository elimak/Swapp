package fr.swapp.core.data.enums 
{
	/**
	 * @author ZoulouX
	 */
	public interface IENum 
	{
		/**
		 * Récupérer la valeur
		 */
		function get value ():*;
		
		/**
		 * Vérifier la validité d'un ENum String
		 */
		function isValid ():Boolean;
		
		/**
		 * Retourner sous forme de string
		 */
		function toString ():String;
	}
}