package fr.swapp.core.data.managers 
{
	/**
	 * Les imports
	 */
	import fr.swapp.core.data.collect.IDataCollection;
	import fr.swapp.core.data.items.IDataItem;
	import fr.swapp.core.errors.SwappError;
	import fr.swapp.core.roles.IChangeable;
	import org.osflash.signals.DeluxeSignal;
	import org.osflash.signals.ISignal;
	
	/**
	 * L'iterateur de base des DataCollection.
	 * Ne prend en charge que le IDataCollection.
	 * Permet de boucler (attention à l'utilisation dans une boucle!)
	 * Permet d'itérer à l'endroit comme à l'envers.
	 * @author ZoulouX
	 */
	public class DataIterator implements IDataIterator
	{
		/**
		 * La collection à itérer
		 */
		protected var _dataCollection			:IDataCollection			= null;
		
		/**
		 * L'index courrant
		 */
		protected var _index					:int						= -1;
		
		/**
		 * L'iterator tourne en boucle
		 */
		protected var _loop						:Boolean					= false;
		
		/**
		 * Changement des données
		 */
		protected var _onChange					:DeluxeSignal;
		
		
		/**
		 * Changement des données
		 */
		public function get onChange ():ISignal 
		{
			return _onChange;
		}
		
		/**
		 * Définir la collection à itérer à la volée.
		 * L'index est remis à 0 lors de la définition.
		 */
		public function get dataCollection ():IDataCollection { return _dataCollection; }
		public function set dataCollection (value:IDataCollection):void 
		{
			// Vérifier que la collection à définir n'est pas nulle
			if (value == null)
			{
				// déclencher une error interne
				throw new SwappError("DataIterator.dataCollection", "DataCollection can't be null.");
			}
			else
			{
				// Enregistrer la collection
				_dataCollection = value;
				
				// Remettre l'index à 0
				_index = 0;
				
				// Dispatcher le change
				_onChange.dispatch();
			}
		}
		
		/**
		 * Définir l'index courrant de l'iterator
		 */
		public function get index ():uint { return Math.max(0, Math.min(_index, _dataCollection.length - 1)); }
		public function set index (value:uint):void 
		{
			// Si ça rentre dans les limites, on enregistre
			if (_index < _dataCollection.length)
			{
				// Enregistrer la nouvelle valeur
				_index = value;
				
				// Dispatcher le changement
				//dispatchUpdate();
			}
			else
			{
				// déclencher l'erreur
				throw new SwappError("DataIterator.index", "Index is out of bounds.");
			}
		}
		
		/**
		 * Récupérer l'élément courrant
		 */
		public function get current ():IDataItem
		{
			// Récupérer l'élément courrant dans les limites pour ne pas déclencher de bounds error
			return _dataCollection.getItem(Math.max(0, Math.min(_index, _dataCollection.length - 1)));
		}
		
		/**
		 * Définir si l'iterator doit tourner en boucle sur les méthodes next() et prev()
		 */
		public function get loop ():Boolean { return _loop; }
		public function set loop (value:Boolean):void 
		{
			// Enregistrer la valeur du loop
			_loop = value;
		}
		
		/**
		 * Le constructeur
		 * @param	pCollection : Le dataCollection à itérer
		 */
		public function DataIterator (pCollection:IDataCollection)
		{
			// Enregistrer la collection
			_dataCollection = pCollection;
			
			// Créer le signal
			_onChange = new DeluxeSignal(this);
		}
		
		/**
		 * Savoir si on à un élément suivant
		 */
		public function hasNext ():Boolean
		{
			return (_index < _dataCollection.length - 1);
		}
		
		/**
		 * Savoir si on a un élément précédent.
		 */
		public function hasPrev ():Boolean
		{
			return (_index > 0);
		}
		
		/**
		 * Aller au suivant
		 * En cas de dépassement, l'index ira au premier élément si loop est à true.
		 * @return L'élément suivant
		 */
		public function next ():IDataItem
		{
			// Si on peut aller au suivant
			if (_index < _dataCollection.length)
			{
				// On incrémente
				_index ++;
			}
			
			if (_index == _dataCollection.length && _loop)
			{
				// Sinon on loop
				_index = 0;
			}
			
			// Dispatcher le changement
			_onChange.dispatch();
			
			// On retourne l'item courrant
			return current;
		}
		
		/**
		 * Aller au précédent.
		 * En cas de dépassement, l'index ira au dernier élément si loop est à true.
		 * @return L'élément précédent
		 */
		public function prev ():IDataItem
		{
			// Si on peut aller au précédent
			if (_index > 0)
			{
				// On décrémente
				_index --;
			}
			else if (_loop)
			{
				// Sinon on loop
				_index = _dataCollection.length - 1;
			}
			
			// Dispatcher le changement
			_onChange.dispatch();
			
			// On retourne l'item courrant
			return current;
		}
		
		/**
		 * Remettre l'iterateur au début
		 */
		public function reset ():void
		{
			// On remet juste l'index à 0
			_index = -1;
			
			// Dispatcher le changement
			_onChange.dispatch();
		}
		
		/**
		 * Aller à la fin
		 */
		public function goToEnd ():void
		{
			// On met l'index sur le dernier cran
			_index = _dataCollection.length;
			
			// Dispatcher le changement
			_onChange.dispatch();
		}
	}
}