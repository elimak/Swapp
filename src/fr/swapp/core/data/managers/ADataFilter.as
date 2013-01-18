package fr.swapp.core.data.managers 
{
	/**
	 * Les imports
	 */
	import fr.swapp.core.data.collect.DataCollection;
	import fr.swapp.core.data.items.IDataItem;
	import fr.swapp.core.data.collect.IDataCollection;
	import fr.swapp.core.data.managers.IDataFilter;
	import fr.swapp.core.errors.SwappError;
	
	/**
	 * Permet de créer des filtres de collection. Les DataFilters doivent implémenter IDataFilter et (devraient) étendre ADataFilter.
	 * Ces classes concrêtes devront aussi overrider la méthode abstraite protégée filterElement (pElement:IDataItem, pIndex:uint):Boolean
	 * Cette méthode doit retourner true ou false pour garder ou non l'élément selon les conditions définies définie dans cette méthode.
	 * Le filtre pourra être éxécuté par la méthode filter ():IDataCollection, la collection filtrée pourra en être récupérée.
	 * Cette collection filtrée est aussi disponible par le getter filteredCollection.
	 * La collection à filtrer peut être automatiquement changée/récupérer par la variable collection.
	 * @author ZoulouX
	 */
	public class ADataFilter implements IDataFilter
	{
		/**
		 * La collection à filter
		 */
		protected var _dataCollection					:IDataCollection;
		
		/**
		 * La collection filtrée
		 */
		protected var _filteredCollection				:IDataCollection;
		
		
		/**
		 * La collection à filtrer
		 */
		public function get dataCollection ():IDataCollection { return _dataCollection;  }
		public function set dataCollection (value:IDataCollection):void
		{
			// Enregistrer la collection
			_dataCollection = value;
		}
		
		/**
		 * Récupérer la collection filtrée
		 */
		public function get filteredCollection ():IDataCollection { return _filteredCollection; }
		public function set filteredCollection (value:IDataCollection):void
		{
			// Enregistrer la collection
			_filteredCollection = value;
		}
		
		
		/**
		 * Le constructeur
		 * @param	pCollection : La collection à filtrer (si null, une nouvelle sera créée)
		 * @param	pFilteredCollection : (si null, la collection filtrée sera clonée)
		 */
		public function ADataFilter (pCollection:IDataCollection = null, pFilteredCollection:IDataCollection = null)
		{
			// Enregistrer la collection
			if (pCollection == null)
				_dataCollection = new DataCollection();
			else
				_dataCollection = pCollection;
			
			// Enregistrer la collection filtrée
			if (pFilteredCollection == null)
				_filteredCollection = new DataCollection(_dataCollection.dataType, _dataCollection.data);
			else
				_filteredCollection = pFilteredCollection;
		}
		
		
		/**
		 * Exécuter le filtre de la collection
		 */
		public function filter ():void
		{
			// Utiliser la méthode interne de filtrage en lui passant une référence au handler
			internalFilterCall(filterElement);
		}
		
		/**
		 * La méthode interne de filtrage. A utiliser dans la classe concrête, à ne pas overrider.
		 * @param	pHandler : La méthode interne de filtrage retournant true ou false sur chaque item
		 * @param	pParams : Les paramètres additionnels sous forme de tableau.
		 */
		final protected function internalFilterCall (pHandler:Function, pParams:Array = null):void
		{
			// Les paramètres null
			if (pParams == null)
				pParams = [];
			
			// Vérouiller la collection
			_filteredCollection.lock();
			
			// Vider la collection
			_filteredCollection.clear();
			
			// Compter le nombre d'item dans la collection à filtrer
			var total:uint = _dataCollection.length;
			
			// L'élément
			var element:IDataItem;
			
			// Parcourir tous les éléments de la collection
			for (var i:int = 0; i < total; i++) 
			{
				// Récupérer l'élément
				element = _dataCollection.getItem(i);
				
				// Tester le filtre, ajouter si c'est true
				if (filterElement.apply(null, [element, i].concat(pParams)))
					_filteredCollection.add(element);
			}
			
			// Dévérouiller la collection
			_filteredCollection.unlock();
		}
		
		/**
		 * Methode abstraite, à overrider.
		 * Filtrer un élément de la collection.
		 * Retournez true pour garder l'élément, retournez false pour l'enlever.
		 * @param	pElement : L'a référence au IDataItem
		 * @param	pIndex : Son index dans la collection
		 * @return : true si l'élément est à garder, false si l'élément ne répond pas aux conditions.
		 */
		protected function filterElement (pElement:IDataItem, pIndex:uint):Boolean
		{
			return true;
		}
	}
}