package fr.swapp.core.roles 
{
	/**
	 * Les imports
	 */
	import org.osflash.signals.ISignal;
	
	/**
	 * Cet élément peut être activé ou désactivé.
	 * @author ZoulouX
	 */
	public interface IEnablable
	{
		/**
		 * Récupérer l'état d'activation de cet élément
		 */
		function get enabled ():Boolean;
		
		/**
		 * Activer, désactiver cet élément
		 */
		function set enabled (value:Boolean):void;
	}
}