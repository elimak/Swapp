package fr.swapp.core.actions
{
	import flash.display.DisplayObjectContainer;
	
	/**
	 * @author ZoulouX
	 */
	public interface IAction
	{
		/**
		 * Action name
		 */
		function get name ():String;
		
		/**
		 * Action context
		 */
		function get context ():Object;
		
		/**
		 * Action params
		 */
		function get params ():Object;
	}
}