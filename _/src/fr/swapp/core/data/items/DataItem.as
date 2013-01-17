package fr.swapp.core.data.items 
{
	import fr.swapp.core.roles.IEnablable;
	import fr.swapp.core.roles.IIdentifiable;
	import org.osflash.signals.DeluxeSignal;
	
	/**
	 * L'item unitaire de stockage de données par défaut
	 * @author ZoulouX
	 */
	public class DataItem implements IDataItem, IIdentifiable, IEnablable
	{
		/**
		 * L'id de l'item, en entier absolu
		 */
		protected var _id					:uint						= 0;
		
		/**
		 * Si l'item est actif ou non
		 */
		protected var _enabled				:Boolean					= true;
		
		/**
		 * Définir l'id de l'item
		 */
		public function get id ():uint { return _id; }
		public function set id (value:uint):void 
		{
			// L'id à changé
			_id = value;
		}
		
		/**
		 * Définir l'état de l'item
		 */
		public function get enabled ():Boolean { return _enabled; }
		public function set enabled (value:Boolean):void 
		{
			// Vérifier si la valeur a changé
			if (value != _enabled)
			{
				// Enregistrer la valeur
				_enabled = value;
			}
		}
	}
}