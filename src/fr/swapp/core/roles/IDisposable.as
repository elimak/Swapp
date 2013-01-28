package fr.swapp.core.roles 
{
	import org.osflash.signals.ISignal;
	
	/**
	 * Cet élément peut être effacé de la mémoire.
	 * Pour cela il suffit d'implémenter la méthode dispose, appelable depuis l'exérieur.
	 * La méthode dispose doit alors tuer toutes les références, disposer les éléments disposables, et aussi ne plus écouter les évènements.
	 * @author ZoulouX
	 */
	public interface IDisposable
	{
		/**
		 * When element is disposed
		 */
		function get onDisposed ():ISignal
		
		/**
		 * Effacer cet élément de la mémoire
		 */
		function dispose ():void
	}	
}