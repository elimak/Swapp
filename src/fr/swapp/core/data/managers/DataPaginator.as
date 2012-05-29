package fr.swapp.core.data.managers 
{
	/**
	 * Les imports
	 */
	import fr.swapp.core.data.collect.IDataCollection;
	
	/**
	 * Permet de paginer un collector
	 * @author ZoulouX
	 */
	public class DataPaginator implements IDataIterator
	{
		/**
		 * Le collecteur à paginer
		 */
		protected var _collector				:IDataCollection
		
		/**
		 * La page courrante
		 */
		protected var _currentPage				:uint;
		
		/**
		 * Le nombre d'items dans une page
		 */
		protected var _itemsByPage				:uint;
		
		/**
		 * L'index
		 */
		protected var _index					:uint;
		
		/**
		 * Le collecteur à paginer
		 */
		public function get collector ():IDataCollection { return _collector; }
		public function set collector (value:IDataCollection):void 
		{
			_collector = value;
		}
		
		/**
		 * Le nombre d'éléments dans une page
		 */
		public function get itemsByPage ():uint { return _itemsByPage; }
		public function set itemsByPage (value:uint):void 
		{
			_itemsByPage = value;
		}
		
		/**
		 * L'index du paginator
		 */
		public function get index ():uint { return _index; }
		public function set index (value:uint):void 
		{
			_index = value;
		}
		
		/**
		 * Le nombre de pages
		 */
		public function get length ():uint { return 0; }
		
		/**
		 * Récupérer la page courrante
		 */
		public function get current ():IDataCollection { return null; }
		
		/**
		 * Le constructeur
		 * @param	pCollection	: Le collector à paginer
		 * @param	pItemsByPage : Le nombre d'items dans une page
		 */
		public function DataPaginator (pCollection:IDataCollection, pItemsByPage:uint = 10)
		{
			
		}
		
		/**
		 * Aller au suivant
		 */
		public function next ():void
		{
			
		}
		
		/**
		 * Aller au précédent
		 */
		public function prev ():void
		{
			
		}
		
		/**
		 * Savoir s'il y a un suivant
		 */
		public function hasNext ():Boolean
		{
			return false;
		}
		
		/**
		 * Savoir s'il y a un précédent
		 */
		public function hasPrev ():Boolean
		{
			return false;
		}
		
		/**
		 * Remettre à 0
		 */
		public function reset ():void
		{
			
		}
	}
}