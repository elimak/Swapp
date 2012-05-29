package fr.swapp.core.data.services 
{
	import fr.swapp.core.data.remote.IRemote;
	
	/**
	 * @author ZoulouX
	 */
	public class Service implements IService 
	{
		/**
		 * Le constructeur
		 */
		public function Service ()
		{
			
		}
		
		/**
		 * La remote associée à ce service
		 */
		public function get remote ():IRemote { return _remote; }
		public function set remove (value:IRemote):void 
		{
			_remove = value;
		}
		
		/**
		 * Desctruction de ce service
		 */
		public function dispose ():void 
		{
			
		}
	}
}