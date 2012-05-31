package fr.swapp.core.data.services 
{
	import fr.swapp.core.data.remote.IRemote;
	import fr.swapp.core.roles.IDisposable;
	
	/**
	 * L'interface pour les services.
	 * @author ZoulouX
	 */
	public interface IService extends IDisposable
	{
		/**
		 * La remote associée à ce service
		 */
		function get remote ():IRemote;
		function set remote (value:IRemote):void;
	}	
}