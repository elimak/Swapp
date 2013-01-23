package fr.swapp.core.navigation
{
	import fr.swapp.core.actions.IActionable;
	import fr.swapp.core.roles.IDisposable;
	
	/**
	 * @author ZoulouX
	 */
	public interface IBootstrap extends IActionable, IDisposable
	{
		function get history ():IHistory;
	}
}