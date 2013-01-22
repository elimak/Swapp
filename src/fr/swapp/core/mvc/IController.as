package fr.swapp.core.mvc
{
	import fr.swapp.core.actions.IAction;
	import fr.swapp.core.roles.IDisposable;
	import fr.swapp.core.roles.IEngine;
	import fr.swapp.core.roles.IInitializable;
	
	/**
	 * @author ZoulouX
	 */
	public interface IController extends IEngine, IDisposable, IInitializable
	{
		/**
		 * Request an action
		 */
		function requestAction (pAction:IAction):void;
	}
}