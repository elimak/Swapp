package fr.swapp.core.roles 
{
	import org.osflash.signals.ISignal;
	
	/**
	 * Les classes implémentant cette interface pourront déclancher des erreur via un signal.
	 * @author ZoulouX
	 */
	public interface IErrorDispatcher
	{
		/**
		 * Signal d'erreur
		 */
		function get onError ():ISignal;
	}
}