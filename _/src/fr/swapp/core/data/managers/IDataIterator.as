package fr.swapp.core.data.managers 
{
	/**
	 * Les imports
	 */
	import fr.swapp.core.data.collect.IDataCollection;
	import fr.swapp.core.data.items.IDataItem;
	import fr.swapp.core.roles.IChangeable;
	import org.osflash.signals.ISignal;
	
	/**
	 * L'interface IDataIterator, pour généraliser les itérateurs de collection.
	 * @author ZoulouX
	 */
	public interface IDataIterator extends IChangeable
	{
		/**
		 * La collection à itérer
		 */
		function get dataCollection ():IDataCollection;
		function set dataCollection (value:IDataCollection):void;
		
		/**
		 * Définir l'index courrant de l'iterator
		 */
		function get index ():uint;
		function set index (value:uint):void;
		
		/**
		 * Récupérer l'élément courrant
		 */
		function get current ():IDataItem;
		
		/**
		 * Définir si l'iterator doit tourner en boucle sur les méthodes next() et prev()
		 */
		function get loop ():Boolean
		function set loop (value:Boolean):void
		
		/**
		 * Savoir si on à un élément suivant
		 */
		function hasNext ():Boolean
		
		/**
		 * Savoir si on a un élément précédent.
		 */
		function hasPrev ():Boolean
		
		/**
		 * Aller au suivant
		 * En cas de dépassement, l'index ira au premier élément si loop est à true.
		 * @return L'élément suivant
		 */
		function next ():IDataItem
		
		/**
		 * Aller au précédent.
		 * En cas de dépassement, l'index ira au dernier élément si loop est à true.
		 * @return L'élément précédent
		 */
		function prev ():IDataItem
		
		/**
		 * Remettre l'iterateur au début
		 */
		function reset ():void
		
		/**
		 * Aller à la fin
		 */
		function goToEnd ():void
	}	
}