package fr.swapp.core.mvc
{
	import flash.display.DisplayObjectContainer;
	import fr.swapp.core.navigation.IBootstrap;
	import fr.swapp.core.roles.IDisposable;
	import fr.swapp.core.roles.IInitializable;
	
	/**
	 * @author ZoulouX
	 */
	public interface IView extends IDisposable, IInitializable
	{
		/**
		 * Get displayObject instance of this view
		 */
		function get displayObject ():DisplayObjectContainer;
		
		/**
		 * Get the first bootstrap recursively to the stage.
		 */
		function get bootstrap ():IBootstrap
	}
}