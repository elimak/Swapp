package fr.swapp.core.data.services 
{
	import fr.swapp.core.data.remote.IRemote;
	
	/**
	 * @author ZoulouX
	 */
	public class Service implements IService 
	{
		/**
		 * La remote associée à ce service
		 */
		protected var _remote					:IRemote;
		
		
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
		public function set remote (value:IRemote):void 
		{
			_remote = value;
		}
		
		/**
		 * Desctruction de ce service
		 */
		public function dispose ():void 
		{
			
		}
	}
}