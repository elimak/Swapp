package fr.swapp.core.roles 
{
	import org.osflash.signals.ISignal;
	
	/**
	 * L'interface des éléments qui peuvent être initialisés
	 * @author ZoulouX
	 */
	public interface IInitializable
	{
		/**
		 * When element is initialized
		 */
		function get onInit ():ISignal;
		
		/**
		 * Initialiser cet élément
		 */
		function init ():void;
	}
}