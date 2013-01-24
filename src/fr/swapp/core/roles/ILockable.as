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
		 */
		function unlock ():void
	}
}