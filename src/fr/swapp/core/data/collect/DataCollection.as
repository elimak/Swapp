package fr.swapp.core.data.collect 
{
	import fr.swapp.core.data.items.IDataItem;
	import fr.swapp.core.errors.SwappError;
	import fr.swapp.utils.ArrayUtils;
	import fr.swapp.utils.ClassUtils;
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	
	/**
	 * Base data colector.
	 * Only to keep IDataItem objects.
	 * More concrete dataType can be setted.
	 * @author ZoulouX
	 */
	public class DataCollection implements IDataCollection
	{
		/**
		 * All data
		 */
		protected var _data							:Array						= [];
		
		/**
		 * Concrete IDataItem type for all data
		 */
		protected var _dataType						:Class						= IDataItem;
		
		/**
		 * When data change
		 */
		protected var _onChange						:Signal						= new Signal(IDataCollection);
		
		/**
		 * If collection is locked. When locked, no onChange will be fired.
		 */
		protected var _locked						:Boolean					= false;
		
		/**
		 * If a change occured when locked.
		 */
		protected var _needDispatchUpdate			:Boolean					= false;
		
		
		/**
		 * When data change
		 */
		public function get onChange ():ISignal { return _onChange;}
		
		/**
		 * Forced data type for all stored items.
		 * Have to be a class that implements IDataItem.
		 * Default is IDataItem.
		 */
		public function get dataType ():Class { return _dataType; }
		public function set dataType (pValue:Class):void
		{
			// Vérifier si c'est différent
			if (pValue != _dataType)
			{
				// Si on n'a pas de données
				if (_data.length == 0)
				{
					// On déclanche une erreur car la collection doit être vide pour changer le type
					throw new SwappError("DataCollection.dataType", "DataCollection have to be empty when changing dataType.");
				}
				else if (!(pValue is IDataItem) && pValue != IDataItem)
				{
					// Le type n'est pas IDataItem
					throw new SwappError("DataCollection.dataType", "DataType have to be a class that implements IDataItem.");
				}
				else
				{
					// Enregistrer le type
					_dataType = pValue;
				}
			}
		}
		
		/**
		 * All data.
		 * Warning, returned data array is not a copy, any external modification can cause DataCollection malfunction.
		 */
		public function get data ():Array { return _data; }
		
		/**
		 * All data.
		 * This is a safe copy of references from DataCollection.data.
		 */
		public function get all ():Array
		{
			// Retourner une copie
			return ArrayUtils.copy(_data);
		}
		
		/**
		 * Total elements in data array.
		 */
		public function get length ():uint { return _data.length; }
		
		/**
		 * Get the first element.
		 * Will return null if there is no element to get.
		 */
		public function get first ():IDataItem
		{
			// Vérifier si la collection n'est pas vide
			return _data.length > 0 ? _data[0] : null;
		}
		
		/**
		 * Get the last element.
		 * Will return null if there is no element to get.
		 */
		public function get last ():IDataItem
		{
			// Vérifier si la collection n'est pas vide
			return _data.length > 0 ? _data[_data.length - 1] : null;
		}
		
		/**
		 * Si la DataCollection est vérouillée
		 */
		public function get locked ():Boolean { return _locked; }
		
		
		/**
		 * Constructor
		 * @param	pDataType : Forced DataType. If null, IDataItem will be used.
		 * @param	pData : Data to insert at construction.
		 */
		public function DataCollection (pDataType:Class = null, pData:Array = null)
		{
			// Enregistrer le type d'IDataItem et bien vérifier que ça implémente IDataItem
			dataType = pDataType;
			
			// Vérifier si on a un tableau en paramètres, si oui on ajoute les éléments de ce tableau
			if (pData != null)
				addAll(pData);
		}
		
		
		/**
		 * ----------------------------------------------------
		 * 					Internal utilities
		 * ----------------------------------------------------
		 */
		
		/**
		 * Check an item type before add.
		 */
		protected function checkDataItem (pDataItem:IDataItem):void
		{
			// Vérifier si l'item est null
			if (_dataType == null)
			{
				// Signaler le problème
				throw new SwappError("DataCollection.forceDataItemType", "DataItem can't be null.");
			}
			
			// Vérifier si l'item à le bon type
			else (!(pDataItem is _dataType))
			{
				// Signaler le pronlème
				throw new SwappError("DataCollection.forceDataItemType", "DataItem must implement " + ClassUtils.getClassName(_dataType) + " (forced by DataCollection.dataType).");
			}
		}
		
		/**
		 * Dispatch change if not locked. Else, will store changed state.
		 */
		protected function dispatchChange ():void
		{
			if (!_locked)
				_onChange.dispatch();
			else
				_needDispatchUpdate = true;
		}
		
		
		/**
		 * ----------------------------------------------------
		 * 					  	  Items
		 * ----------------------------------------------------
		 */
		
		/**
		 * Get item from index
		 * @param	pIndex : Index to get item from
		 * @return : IDataItem typed item.
		 */
		public function getItem (pIndex:uint):IDataItem
		{
			// Vérifier qu'on soit bien dans les valeurs acceptées, sinon on déclenche une erreur
			if (pIndex >= _data.length)
			{
				throw new SwappError("DataCollection.getItem", "Index " + pIndex + " is out of bounds " + length);
				return null;
			}
			else
			{
				// Retourner la valeur
				return _data[pIndex];
			}
		}
		
		/**
		 * Check if an item is stored in this collection.
		 * @param	pDataItem : Searched item
		 * @return : true if the item is in the collection.
		 */
		public function contains (pDataItem:IDataItem):Boolean
		{
			// Vérifier si l'élément existe au sein du tableau
			return ArrayUtils.contains(_data, pDataItem);
		}
		
		/**
		 * Add an item to the collection.
		 * Will check the dataType.
		 * @param	pDataItem : Item to add
		 * @param	pAt : Index where add item at, -1 to add at end.
		 */
		public function add (pDataItem:IDataItem, pAt:int = -1):void
		{
			// Vérifier l'item
			if (checkDataItem(pDataItem))
			{
				// Si on doit le placer à -1 (la fin)
				if (pAt == -1)
				{
					// Ajouter à la fin
					_data[_data.length] = pDataItem;
				}
				else
				{
					// Ajouter au bon endroit
					_data = ArrayUtils.insertAt(_data, pDataItem, pAt);
				}
				
				// Les données ont été changées
				dispatchChange();
			}
		}
		
		/**
		 * Add all items to the collection.
		 * Same restrictions as DataCollection.add method.
		 * @param	pData : All items to add.
		 */
		public function addAll (pData:Array):void
		{
			// Si le tableau des données à ajouter est ok
			if (pData != null && pData.length > 0)
			{
				// Parcourir les valeurs indéxées uniquement
				for (var i:int = 0, total:uint = pData.length; i < total; i++) 
				{
					// Forcer le type si besoin
					if (checkDataItem(pData[i]))
					{
						// On peut la stocker
						_data[_data.length] = pData[i];
					}
				}
				
				// Les données ont été changées
				dispatchChange();
			}
		}
		
		/**
		 * Delete an item from collection
		 * @param	pDataItem : Item to delete.
		 * @return : If data has changed.
		 */
		public function remove (pDataItem:IDataItem):Boolean
		{
			// Mesurer les données
			var oldLength:Boolean = _data.length;
			
			// Effacer cet élément
			_data = ArrayUtils.deleteElement(_data, pDataItem);
			
			// Si la taille des données à changée
			if (_data.length != oldLength)
			{
				// Les données ont été changées
				dispatchChange();
				
				// Les données ont été modifiées
				return true;
			}
			else
			{
				// Les données n'ont pas été modifiées
				return false;
			}
		}
		
		/**
		 * Remove an element by index
		 * @param	pAt : Index where the element to remove is.
		 * @return : If data has changed.
		 */
		public function removeAt (pAt:uint):Boolean
		{
			// Mesurer les données
			var oldLength:Boolean = _data.length;
			
			// Effacer cet index
			_data = ArrayUtils.deleteIndex(_data, pAt);
			
			// Si la taille des données à changée
			if (_data.length != oldLength)
			{
				// Les données ont été changées
				dispatchChange();
				
				// Les données ont été modifiées
				return true;
			}
			else
			{
				// Les données n'ont pas été modifiées
				return false;
			}
		}
		
		/**
		 * Clear all collection data
		 */
		public function clear ():void
		{
			// Remettre le tableau à 0
			_data = [];
			
			// Les données ont été changées
			dispatchChange();
		}
		
		
		/**
		 * ----------------------------------------------------
		 * 					  Transformations
		 * ----------------------------------------------------
		 */
		
		/**
		 * Call a function on every stored item in this collection.
		 * The handler have to be like : function (pIndex:uint, pItem:IDataItem):void
		 * Optional parameters will be added from pParams.
		 * @param	pHandler : Function called for every item.
		 * @param	pParams : Additional parameters added to the handler.
		 */
		public function forEach (pHandler:Function, pParams:Array = null):void
		{
			// Les paramètres par défaut
			if (pParams == null)
				pParams = [];
			
			// La boucle
			for (var i:int = 0, arrayLength:uint = _data.length; i < arrayLength; i++) 
			{
				// Appeler la méthode et lui passer les paramètres
				pHandler.apply(null, [i, _data[i] as IDataItem].concat(pParams));
			}
		}
		
		/**
		 * Call a function on every stored item in this collection.
		 * If handler return false, the item is removed. If true, the item is kept.
		 * The handler have to be like : function (pIndex:uint, pItem:IDataItem):void
		 * Optional parameters will be added from pParams.
		 * @param	pHandler : Function called for every item.
		 * @param	pParams : Additional parameters added to the handler.
		 */
		public function filter (pHandler:Function, pParams:Array = null):void
		{
			// Les paramètres par défaut
			if (pParams == null)
				pParams = [];
			
			// Le nouveau tableau
			var newArray:Array = [];
			
			// La boucle
			for (var i:int = 0, arrayLength:uint = _data.length; i < arrayLength; i++) 
			{
				// Appeler la méthode et lui passer les paramètres
				pHandler.apply(null, [i, _data[i] as IDataItem].concat(pParams));
			}
			
			// Les données ont été changées
			dispatchChange();
		}
		
		/**
		 * Sort collection
		 * @param	pFields : Strings array containing names of properties to sort on. If items have all a property "id", and "name", you can sort on ["id", "name"]
		 * @param	pAscending : Sort order (default is lower in first)
		 * @param	pCaseSensitive : If the sort algorythm is case sensitive.
		 * @param	pNumeric : If the sort algoryth have to sort on numeric values. (default is none, for ex, 10 will be before 2)
		 */
		public function sort (pFields:Array, pAscending:Boolean = true, pCaseSensitive:Boolean = false, pNumeric:Boolean = false):void
		{
			// Trier le tableau sans faire de copie
			_data = _data.sortOn(pFields, (pAscending ? 0 : Array.DESCENDING) | (pCaseSensitive ? 0 : Array.CASEINSENSITIVE) | (pNumeric ? Array.NUMERIC : 0));
			
			// Les données ont été changées
			dispatchChange();
		}
		
		
		/**
		 * ----------------------------------------------------
		 * 						  Lock
		 * ----------------------------------------------------
		 */
		
		/**
		 * Lock the collection (onChange will not fire when locked)
		 */
		public function lock ():void
		{
			_locked = true;
		}
		
		/**
		 * Unlock the collection (onChange will instatly fire if changes occured when locked)
		 */
		public function unlock ():void
		{
			// Ce n'est plus vérouillé
			_locked = false;
			
			// Si des changements on été effectués pendant le lock
			if (_needDispatchUpdate)
			{
				// On redispatch
				_onChange.dispatch();
				
				// Plus de changement a signaler
				_needDispatchUpdate = false;
			}
		}
		
		
		/**
		 * ----------------------------------------------------
		 * 					 Object utilities
		 * ----------------------------------------------------
		 */
		
		/**
		 * Convert object to string representation
		 */
		public function toString ():String
		{
			return "DataCollection {length: " + length + ", dataType: " + ClassUtils.getClassName(_dataType) + "}";
		}
		
		/**
		 * Clone this collection (same dataType and data)
		 */
		public function clone ():DataCollection
		{
			return new DataCollection(_dataType, data);
		}
	}
}