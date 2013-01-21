package fr.swapp.core.mvc
{
	import flash.display.DisplayObjectContainer;
	
	/**
	 * @author ZoulouX
	 */
	public interface IViewController extends IController
	{
		/**
		 * Container which will have view
		 */
		function get container ():DisplayObjectContainer
		
		/**
		 * Associated controlled view
		 */
		function get view ():IView;
	}
}