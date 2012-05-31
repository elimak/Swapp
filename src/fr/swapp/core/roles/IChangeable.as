package fr.swapp.core.roles 
{
	import org.osflash.signals.ISignal;
	
	/**
	 * Les données de cet élément peuvent être changées.
	 * @author ZoulouX
	 */
	public interface IChangeable
	{
		/**
		 * Le signal de changement
		 */
		function get onChange ():ISignal;
	}
}