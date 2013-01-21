package fr.swapp.core.mvc
{
	import fr.swapp.core.roles.IDisposable;
	import fr.swapp.core.roles.IEngine;
	
	/**
	 * @author ZoulouX
	 */
	public interface IController extends IEngine, IDisposable
	{
		/**
		 * Default action
		 */
		function index (pContext:Object):void;
	}
}