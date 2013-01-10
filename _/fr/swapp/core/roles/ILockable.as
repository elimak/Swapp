package fr.swapp.core.roles 
{
	/**
	 * Vérouillable, dévérouillable
	 * @author ZoulouX
	 */
	public interface ILockable 
	{
		/**
		 * Si l'objet est vérouillé
		 */
		function get locked ():Boolean;
		
		/**
		 * Vérouiller cet objet
		 */
		function lock ():void;
		
		/**
		 * Dévérouiller cet objet.
		 * La méthode d'unlock est spécifique à la concrête.
		 * @param	pUnlockSystem : Permet de spécifier un système de débloquage, spécifique à chaque classe implémentant cette interface.
		 */
		function unlock (pUnlockSystem:int = -1):void
	}
}