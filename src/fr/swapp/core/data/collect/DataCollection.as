package fr.swapp.core.data.collect 
{
	/**
	 * Les imports
	 */
	import fr.swapp.core.data.items.IDataItem;
	import fr.swapp.core.data.managers.DataIterator;
	import fr.swapp.core.data.managers.IDataIterator;
	import fr.swapp.core.errors.SwappError;
	import fr.swapp.core.roles.IChangeable;
	import fr.swapp.core.roles.ILockable;
	import fr.swapp.utils.ArrayUtils;
	import fr.swapp.utils.ClassUtils;
	import org.osflash.signals.DeluxeSignal;
	import org.osflash.signals.ISignal;
	
	/**
	 * Le collecteur classique, associant un objet IDataItem à un index.
	 * @author ZoulouX
	 */
	public class DataCollection implements IDataCollection
	{
		/**
		 * Les données
		 */
		protected var _data							:Array;
		
		/**
		 * Le type de IDataItem forcé
		 */
		protected var _dataType						:Class;
		
		/**
		 * L'itérateur associé
		 */
		protected var _iterator						:IDataIterator;
		
		/**
		 * Le signal de changement
		 */
		protected var _onChange						:DeluxeSignal;
		
		/**
		 * Si la collection est vérouillée (pas d'envoie d'events)
		 */
		protected var _locked						:Boolean					= false;
		
		/**
		 * Si un changement a été fait pendant un lock
		 */
		protected var _needDispatchUpdate			:Boolean					= false;
		
		
		/**
		 * Récupérer le signal de changement
		 */
		public function get onChange ():ISignal
		{
			return _onChange;
		}
		
		/**
		 * Récupérer le tableau des données.
		 * Attention, aucune copie n'est générée, le tableau modifé à l'extérieur modifira donc le tableau interne
		 * à la collection.
		 */
		public function get data ():Array
		{
			return _data;
		}
		
		/**
		 * Le type de IDataItem forcé.
		 */
		public function get dataType ():Class { return _dataType; }
		public function set dataType (pValue:Class):void
		{
			// Enregistrer le type sans vérifier
			_dataType = pValue;
			
			/*
			if (pValue is IDataItem)
				_dataType = pValue;
			else
				throw new SwappError("DataCollection.dataType", "DataType must implement IDataItem.");
			*/
		}
		
		/**
		 * Récupérer tous les éléments sous forme de tableau indexé.
		 * Ce tableau est une copie du tableau interne à la collection.
		 * Les éléments stockés ne sont pas copié.
		 */
		public function get all ():Array
		{
			// Retourner une copie
			return ArrayUtils.copy(_data);
		}
		
		/**
		 * Récupérer le nombre d'élément
		 */
		public function get length ():uint
		{
			return _data.length;
		}
		
		/**
		 * Récupérer le premier élément
		 */
		public function get first ():IDataItem
		{
			// Vérifier si la collection n'est pas vide
			if (_data.length > 0)
				return _data[0];
			else
				throw new SwappError("DataCollection.first", "Collection is void.");
		}
		
		/**
		 * Récupérer le dernier élément
		 */
		public function get last ():IDataItem
		{
			// Vérifier si la collection n'est pas vide
			if (_data.length > 0)
				return _data[_data.length - 1];
			else
				throw new SwappError("DataCollection.last", "Collection is void.");
		}
		
		/**
		 * Récupérer l'itérator
		 */
		public function get iterator ():IDataIterator
		{
			// Instancier l'iterator au moins une fois
			if (_iterator == null)
				_iterator = new DataIterator(this);
			
			// Retourner l'iterator
			return _iterator;
		}
		
		/**
		 * Définir l'iterator
		 */
		public function set iterator (value:IDataIterator):void
		{
			// Vérifier que l'iterateur ne soit pas null
			if (value != null)
				_iterator = value;
			else
				throw new SwappError("DataCollection.iterator", "Can't associate null iterator.");
		}
		
		/**
		 * Si la DataCollection est vérouillée
		 */
		public function get locked ():Boolean { return _locked; }
		
		
		/**
		 * Le constructeur
		 * @param	pDataType : Type d'IDataItem forcé
		 * @param	pData : Tableau contenant les données
		 */
		public function DataCollection (pDataType:Class = null, pData:Array = null)
		{
			// Créer le tableau stockant les données
			_data = [];
			
			// Enregistrer le type d'IDataItem et bien vérifier que ça implémente IDataItem
			dataType = pDataType;
			
			// Créer le signal de changement
			_onChange = new DeluxeSignal(this);
			
			// Vérifier si on a un tableau en paramètres, si oui on ajoute les éléments de ce tableau
			if (pData != null)
				addAll(pData);
		}
		
		/**
		 * Récupérer un élément à un index donné
		 * @param	pIndex : L'index de l'élément à récupérer
		 * @return : L'élément de type IDataItem
		 */
		public function getItem (pIndex:uint):IDataItem
		{
			// Vérifier qu'on soit bien dans les valeurs acceptées, sinon on déclenche une erreur
			if (pIndex >= _data.length)
				throw new SwappError("DataCollection.getItem", "Index is out of bounds");
			
			// Retourner la valeur
			return _data[pIndex];
		}
		
		/**
		 * Savoir si un élément est contenu dans la collection
		 * @param	pDataItem : L'item en question
		 * @return : true si l'élément à été trouvé
		 */
		public function contains (pDataItem:IDataItem):Boolean
		{
			// Vérifier si l'élément existe au sein du tableau
			return ArrayUtils.contains(_data, pDataItem);
		}
		
		/**
		 * Ajouter un élément dans la collection.
		 * @param	pDataItem : L'item à ajouter
		 */
		public function add (pDataItem:IDataItem):void
		{
			// Forcer le type si besoin
			forceDataItemType(pDataItem);
			
			// Ajouter à la fin
			_data[_data.length] = pDataItem;
			
			// Les données ont été changées
			if (!_locked)
				_onChange.dispatch();
			else
				_needDispatchUpdate = true;
		}
		
		/**
		 * Vérifier et forcer le type d'un IDataItem
		 * @param	pDataItem : L'item à tester
		 */
		protected function forceDataItemType (pDataItem:IDataItem):void
		{
			// Forcer le type si besoin
			if (_dataType != null && !(pDataItem is _dataType))
				throw new SwappError("DataCollection.add", "This DataItem must implement " + ClassUtils.getClassName(_dataType) + " (forced by DataCollection.dataType)");
		}
		
		/**
		 * Ajouter un tableau d'éléments à la collection
		 * @param	pData : Le tableau d'éléments IDataItem
		 */
		public function addAll (pData:Array):void
		{
			// Mesurer le tableau
			var arrayLength:uint = pData.length;
			
			// Parcourir les valeurs indéxées uniquement
			for (var i:int = 0; i < arrayLength; i++) 
			{
				// Si la donnée est de type IDataItem
				if (pData[i] != null && pData[i] is IDataItem)
				{
					// Forcer le type si besoin
					forceDataItemType(pData[i]);
					
					// On peut la stocker
					_data[_data.length] = pData[i];
				}
				else
					throw new SwappError("DataCollection.getItem", "IDataCollector can only manage IDataItem");
			}
			
			// Les données ont été changées
			if (!_locked)
				_onChange.dispatch();
			else
				_needDispatchUpdate = true;
		}
		
		/**
		 * Ajouter un élément à un endroit spécifique de la collection.
		 * @param	pDataItem : L'item à ajouter
		 * @param	pAt : L'index auquel l'item doit être placé
		 */
		public function addAt (pDataItem:IDataItem, pAt:uint = 0):void
		{
			// Forcer le type si besoin
			forceDataItemType(pDataItem);
			
			// Ajouter à l'endroit spécifié
			_data = ArrayUtils.insertAt(_data, pDataItem, pAt);
			
			// Les données ont été changées
			if (!_locked)
				_onChange.dispatch();
			else
				_needDispatchUpdate = true;
		}
		
		/**
		 * Effacer un élément de la collection
		 * @param	pDataItem : L'item qui doit être supprimé
		 */
		public function remove (pDataItem:IDataItem):void
		{
			// Effacer cet élément
			_data = ArrayUtils.deleteElement(_data, pDataItem);
			
			// Les données ont été changées
			if (!_locked)
				_onChange.dispatch();
			else
				_needDispatchUpdate = true;
		}
		
		/**
		 * Effacer un élément par son index
		 * @param	pAt : L'index qui doit être supprimé
		 */
		public function removeAt (pAt:uint):void
		{
			// Effacer cet index
			_data = ArrayUtils.deleteIndex(_data, pAt);
			
			// Les données ont été changées
			if (!_locked)
				_onChange.dispatch();
			else
				_needDispatchUpdate = true;
		}
		
		/**
		 * Vider la collection
		 */
		public function clear ():void
		{
			// Remettre le tableau à 0
			_data = [];
			
			// Les données ont été updatées
			if (!_locked)
				_onChange.dispatch();
			else
				_needDispatchUpdate = true;
		}
		
		/**
		 * Appèle une méthode sur chaque élément de cette collection.
		 * La méthode doit accueillir les paramètres suivants :
		 * 1. Récéption du IDataItem
		 * 2. Récéption de l'index
		 * Les paramètres optionnels seront ajoutés aux paramètres de la méthode.
		 * Par exemple, pour:
		 * myCollection.forEach(myHandler, [myCollection]);
		 * 
		 * Il faut que le handler ai cette signature:
		 * function myHandler (pItem:IDataItem, pIndex:uint, pCollection:DataCollection = null):void
		 * 
		 * Sinon le handler de base doit avoir cette signature
		 * function myHandler (pItem:IDataItem, pIndex:uint):void
		 * 
		 * @param	pHandler : La méthode appelée pour chaque élément.
		 * @param	pParams : Les paramètres en plus des 2 obligatoires.
		 */
		public function forEach (pHandler:Function, pParams:Array = null):void
		{
			// Les paramètres par défaut
			if (pParams == null)
				pParams = [];
			
			// Compter le nombre d'élément maintenant pour éviter de le faire dans la boucle
			var arrayLength:uint = _data.length;
			
			// La boucle
			for (var i:int = 0; i < arrayLength; i++) 
			{
				// Appeler la méthode et lui passer les paramètres
				pHandler.apply(null, [_data[i] as IDataItem, i].concat(pParams));
			}
		}
		
		/**
		 * Trier la collection selon un ou plusieurs champs des items.
		 * @param	pFields : Les champs à trier. Ce tableau doit être composé de string uniquement. ex: ['id', 'name']
		 * @param	pAscending : L'ordre de tri. Par défaut l'ordre est ascendant (le plus bas en premier)
		 * @param	pCaseSensitive : La prise en compte de la casse. Par défaut la casse n'est pas prise en compte.
		 * @param	pNumeric : Valeurs numériques, par défaut le filtre se comporte pour des tri non numériques (10 est trié avant 2)
		 */
		public function sort (pFields:Array, pAscending:Boolean = true, pCaseSensitive:Boolean = false, pNumeric:Boolean = false):void
		{
			// Trier le tableau sans faire de copie
			_data = _data.sortOn(pFields, (pAscending ? 0 : Array.DESCENDING) | (pCaseSensitive ? 0 : Array.CASEINSENSITIVE) | (pNumeric ? Array.NUMERIC : 0));
			
			// Les données ont été updatées
			if (!_locked)
				_onChange.dispatch();
			else
				_needDispatchUpdate = true;
		}
		
		/**
		 * Filtrer la collection grâce à une méthode callback.
		 * @param	pCallback : Le callback permettant de filtrer la collection. Se référer à la documentation de Array.filter.
		 */
		public function filterCollection (pCallback:Function):void
		{
			// On filtre avec l'array
			_data = _data.filter(pCallback);
			
			// Les données ont changées
			if (!_locked)
				_onChange.dispatch();
			else
				_needDispatchUpdate = true;
		}
		
		/**
		 * Vérouiller la collection (les signaux ne seront plus envoyés)
		 */
		public function lock ():void
		{
			_locked = true;
		}
		
		/**
		 * Dévérouiller la collection (elle pourra renvoyer des signaux)
		 * @param	pUnlockSystem : -1 pour dispatch auto, 0 pour interdiction de dispatch, 1 pour dispatch forcé
		 */
		public function unlock ():void//pUnlockSystem:int = -1):void
		{
			var pUnlockSystem:int = -1;
			
			// Ce n'est plus vérouillé
			_locked = false;
			
			// Si des changements on été effectués pendant le lock
			if ((_needDispatchUpdate || pUnlockSystem == 1) && pUnlockSystem != 0)
			{
				// On redispatch
				_onChange.dispatch();
				
				// Plus de changement a signaler
				_needDispatchUpdate = false;
			}
		}
		
		/**
		 * La méthode toString
		 */
		public function toString ():String
		{
			return "DataCollection {length: " + length + "}";
		}
		
		/**
		 * Cloner cette collection.
		 */
		public function clone ():DataCollection
		{
			// Copier
			return new DataCollection(_dataType, all);
		}
	}
}