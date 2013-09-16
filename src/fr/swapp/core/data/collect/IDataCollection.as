package fr.swapp.core.data.collect 
{
	import fr.swapp.core.data.items.IDataItem;
	import fr.swapp.core.roles.IChangeable;
	import fr.swapp.core.roles.ILockable;
	import org.osflash.signals.ISignal;
	
	/**
	 * Base data colector interface.
	 * Only to keep IDataItem objects.
	 * More concrete dataType can be setted.
	 * @author ZoulouX
	 */
	public interface IDataCollection extends ICollection, IChangeable, ILockable
	{
		/**
		 * Forced data type for all stored items.
		 * Have to be a class that implements IDataItem.
		 * Default is IDataItem.
		 */
		function get dataType ():Class;
		function set dataType (pValue:Class):void;
		
		/**
		 * All data.
		 * Warning, returned data array is not a copy, any external modification can cause DataCollection malfunction.
		 */
		function get data ():Array;
		
		/**
		 * All data.
		 * This is a safe copy of references from DataCollection.data.
		 */
		function get all ():Array;
		
		/**
		 * Get the first element.
		 * Will return null if there is no element to get.
		 */
		function get first ():IDataItem;
		
		/**
		 * Get the last element.
		 * Will return null if there is no element to get.
		 */
		function get last ():IDataItem;
		
		
		/**
		 * Get item from index
		 * @param	pIndex : Index to get item from
		 * @return : IDataItem typed item.
		 */
		function getItem (pIndex:uint):IDataItem;
		
		/**
		 * Check if an item is stored in this collection.
		 * @param	pDataItem : Searched item
		 * @return : true if the item is in the collection.
		 */
		function contains (pDataItem:IDataItem):Boolean;
		
		/**
		 * Add an item to the collection.
		 * Will check the dataType.
		 * @param	pDataItem : Item to add
		 * @param	pAt : Index where add item at, -1 to add at end.
		 */
		function add (pDataItem:IDataItem, pAt:int = -1):void;
		
		/**
		 * Add all items to the collection.
		 * Same restrictions as DataCollection.add method.
		 * @param	pData : All items to add.
		 */
		function addAll (pData:Array):void;
		
		/**
		 * Delete an item from collection
		 * @param	pDataItem : Item to delete.
		 * @return : If data has changed.
		 */
		function remove (pDataItem:IDataItem):Boolean;
		
		/**
		 * Remove an element by index
		 * @param	pAt : Index where the element to remove is.
		 * @return : If data has changed.
		 */
		function removeAt (pAt:uint):Boolean;
		
		/**
		 * Clear all collection data
		 */
		function clear ():void;
		
		
		/**
		 * Call a function on every stored item in this collection.
		 * The handler have to be like : function (pIndex:uint, pItem:IDataItem):void
		 * Optional parameters will be added from pParams.
		 * @param	pHandler : Function called for every item.
		 * @param	pParams : Additional parameters added to the handler.
		 */
		function forEach (pHandler:Function, pParams:Array = null):void;
		
		/**
		 * Call a function on every stored item in this collection.
		 * If handler return false, the item is removed. If true, the item is kept.
		 * The handler have to be like : function (pIndex:uint, pItem:IDataItem):void
		 * Optional parameters will be added from pParams.
		 * @param	pHandler : Function called for every item.
		 * @param	pParams : Additional parameters added to the handler.
		 */
		function filter (pHandler:Function, pParams:Array = null):void;
		
		/**
		 * Sort collection
		 * @param	pFields : Strings array containing names of properties to sort on. If items have all a property "id", and "name", you can sort on ["id", "name"]
		 * @param	pAscending : Sort order (default is lower in first)
		 * @param	pCaseSensitive : If the sort algorythm is case sensitive.
		 * @param	pNumeric : If the sort algoryth have to sort on numeric values. (default is none, for ex, 10 will be before 2)
		 */
		function sort (pFields:Array, pAscending:Boolean = true, pCaseSensitive:Boolean = false, pNumeric:Boolean = false):void;
		
		
		/**
		 * Convert object to string representation
		 */
		function toString ():String;
		
		/**
		 * Clone this collection (same dataType and data)
		 */
		function clone ():DataCollection;
	}
}