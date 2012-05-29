package fr.swapp.core.roles 
{
	import org.osflash.signals.ISignal;
	
	/**
	 * @author ZoulouX
	 */
	public interface IEngine extends IStartStoppable
	{
		/**
		 * Si l'objet est en train de démarrer
		 */
		function get turningOn ():Boolean;
		
		/**
		 * Si l'objet est en train d'être arrêté
		 */
		function get turningOff ():Boolean;
		
		/**
		 * Lorsque l'objet est en train d'être démarré
		 */
		function get onTurningOn ():ISignal;
		
		/**
		 * Lorsque l'objet est démarré
		 */
		function get onTurnedOn ():ISignal;
		
		/**
		 * Lorsque l'objet est en train d'être arrêté
		 */
		function get onTurningOff ():ISignal;
		
		/**
		 * Lorsque l'objet est arrêté
		 */
		function get onTurnedOff ():ISignal;
	}
}