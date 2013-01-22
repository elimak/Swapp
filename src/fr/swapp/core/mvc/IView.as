package fr.swapp.core.mvc
{
	import flash.display.DisplayObject;
	import fr.swapp.core.roles.IDisposable;
	
	/**
	 * @author ZoulouX
	 */
	public interface IView extends IDisposable
	{
		/**
		 * Get displayObject instance of this view
		 */
		function get displayObject ():DisplayObject;
	}
}