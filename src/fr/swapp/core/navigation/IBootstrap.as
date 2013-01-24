package fr.swapp.core.navigation
{
	import flash.display.DisplayObjectContainer;
	import fr.swapp.core.actions.IAction;
	import fr.swapp.core.actions.IActionable;
	import fr.swapp.core.dependences.IDependencesManager;
	import fr.swapp.core.mvc.IViewController;
	import fr.swapp.core.roles.IDisposable;
	import fr.swapp.core.roles.ILockable;
	import org.osflash.signals.ISignal;
	
	/**
	 * @author ZoulouX
	 */
	public interface IBootstrap extends IActionable, ILockable, IDisposable
	{
		/**
		 * Actions history
		 */
		function get history ():IHistory;
		
		/**
		 * When an action is requested
		 */
		function get onActionRequested ():ISignal;
		
		/**
		 * When current viewController has changed
		 */
		function get onViewControllerChanged ():ISignal
		
		/**
		 * Associated dependences manager
		 */
		function get dependencesManager ():IDependencesManager;
		
		/**
		 * Current view controller (can be null)
		 */
		function get currentViewController ():IViewController;
		
		/**
		 * Container to inject in ViewController
		 */
		function get container ():DisplayObjectContainer;
		function set container (value:DisplayObjectContainer):void;
		
		/**
		 * Waiting action
		 */
		function get waitingAction ():IAction;
	}
}