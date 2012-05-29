package fr.swapp.core.pool
{
	import flash.utils.getQualifiedClassName;
	import fr.swapp.core.log.Log;
	import fr.swapp.core.roles.IDisposable;
	
	/**
	 * @author ZoulouX
	 */
	public class ObjectPool implements IDisposable
	{
		/**
		 * La classe qui va être générée
		 */
		protected var _class				:Class;
		
		/**
		 * Les éléments disponibles
		 */
		protected var _elements				:Vector.<Object>		= new Vector.<Object>;
		
		/**
		 * La classe qui va être générée
		 */
		public function get objectClass ():Class { return _class; }
		
		/**
		 * Les éléments disponibles
		 */
		public function get elements ():Vector.<Object> { return _elements; }
		
		/**
		 * Le nombre d'éléments disponibles
		 */
		public function get length ():int { return _elements.length; }
		
		
		/**
		 * Créer une pool d'objet.
		 * @param	pClass : La classe des objets qui seront créés
		 * @param	pNeedMinimumInstances : Le nombre d'instances à créer
		 */
		public function ObjectPool (pClass:Class, pNeedMinimumInstances:uint = 0)
		{
			// Enregistrer la classe
			_class = pClass;
			
			// Créer un nombre minimum
			for (var i:int = 0; i < pNeedMinimumInstances; i++) 
			{
				_elements.push(new _class);
			}
		}
		
		/**
		 * Marquer un objet comme disponible.
		 * L'objet ne doit pas être null et doit être de la classe de la pool.
		 */
		public function flag (pObject:Object):Boolean
		{
			// Si l'objet n'est pas null et est de la bonne classe
			if (pObject != null && pObject is _class)
			{
				// On ajoute par le début
				_elements.unshift(pObject);
				
				// Signaler
				return true;
			}
			else
			{
				return false;
			}
		}
		
		/**
		 * Besoin d'un objet, récupère une instance d'un objet de la classe de la pool.
		 * Si un objet est disponible (flag), alors il sera retourné. Sinon une nouvelle instance sera créée.
		 */
		public function need ():Object
		{
			// Si on est des éléments flag
			if (_elements.length > 0)
			{
				// On retourne le premier
				return _elements.shift();
			}
			else
			{
				Log.notice("ObjectPool created 1 " + _class + " to "+ _elements.length);
				
				// Sinon on en créé un
				return new _class;
			}
		}
		
		/**
		 * Vider la pool de tous les objets flag.
		 */
		public function clear ():void
		{
			_elements = new Vector.<Object>;
		}
		
		/**
		 * toString
		 */
		public function toString ():String
		{
			var out:String = "ObjectPool " + _class + " [" + _elements.length +"]";
			
			const total:int = _elements.length;
			for (var i:int = 0; i < total; i++) 
			{
				out += "-- " + i + " : " + _elements[i] + "\n";
			}
			
			return out;
		}
		
		/**
		 * Détruire tous les éléments dans la pool
		 */
		public function dispose ():void
		{
			// Supprimer tous les éléments et tout disposer
			for each (var element:Object in _elements)
			{
				if (element is IDisposable)
				{
					(element as IDisposable).dispose();
				}
			}
			
			// Disposer cette pool
			_elements = null;
		}
	}
}