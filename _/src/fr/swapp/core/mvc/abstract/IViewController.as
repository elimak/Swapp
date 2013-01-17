package fr.swapp.core.mvc.abstract 
{
	import flash.display.DisplayObjectContainer;
	import fr.swapp.core.bundle.IBundle;
	
	/**
	 * Le controlleur de vue est un type de controlleur qui gère principalement une vue.
	 * @author ZoulouX
	 */
	public interface IViewController extends IController
	{
		/**
		 * La vue associée à ce controlleur de vue
		 */
		function get view ():IView;
		function set view (value:IView):void;
		
		/**
		 * Le container qui accueille la vue associée
		 */
		function get viewContainer ():DisplayObjectContainer;
		function set viewContainer (value:DisplayObjectContainer):void;
		
		/**
		 * Le Bundle auquel appartient ce controlleur
		 */
		function get bundle ():IBundle;
		function set bundle (value:IBundle):void;
	}
}