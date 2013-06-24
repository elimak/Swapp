package fr.swapp.core.data.items 
{
	/**
	 * Cet objet peut contenir un item.
	 * @author ZoulouX
	 */
	public interface IItemContainer
	{
		/**
		 * L'item associé
		 */
		function get item ():IDataItem
		function set item (value:IDataItem):void
	}
}