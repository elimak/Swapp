package fr.swapp.core.roles 
{
	/**
	 * Interface pour des objet démarrable et arrêtables.
	 * @author ZoulouX
	 */
	public interface IStartStoppable 
	{
		/**
		 * Si l'objet est démarré
		 */
		function get started ():Boolean;
		
		/**
		 * Démarrer l'objet
		 */
		function turnOn ():void;
		 
		/**
		 * Arrêter l'objet
		 */
		function turnOff ():void;
	}
}