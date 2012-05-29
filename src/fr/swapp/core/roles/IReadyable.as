package fr.swapp.core.roles 
{
	import org.osflash.signals.ISignal;
	
	/**
	 * Un élément qui peut être prêt
	 * @author ZoulouX
	 */
	public interface IReadyable 
	{
		/**
		 * Si cet élément est prêt
		 */
		function get ready ():Boolean
		
		/**
		 * Dispatché lorsque l'élément est prêt
		 */
		function get onReady ():ISignal
	}
}