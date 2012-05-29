package fr.swapp.core.mvc.abstract 
{
	import fr.swapp.core.roles.IDisposable;
	import fr.swapp.core.roles.IErrorDispatcher;
	import fr.swapp.core.roles.IReadyable;
	
	/**
	 * @author ZoulouX
	 */
	public interface IModel extends IReadyable, IErrorDispatcher, IDisposable
	{
		
	}
}