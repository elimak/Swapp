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
		 * @param	pContextInfo : Objet personnalisable et optionnel pour avoir plus d'informations sur le démarrage.
		 */
		function turnOn (pContextInfo:Object = null):void;
		 
		/**
		 * Arrêter l'objet
		 * @param	pContextInfo : Objet personnalisable et optionnel pour avoir plus d'informations sur l'arrêt.
		 */
		function turnOff (pContextInfo:Object = null):void;
	}
}