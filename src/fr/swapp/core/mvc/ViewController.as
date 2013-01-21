package fr.swapp.core.mvc
{
	import flash.display.DisplayObjectContainer;
	/**
	 * @author ZoulouX
	 */
	public class ViewController extends Controller implements IViewController
	{
		protected var _container:DisplayObjectContainer;
		
		protected var _view:IView;
		
		public function get view ():IView
		{
			return _view;
		}
		
		public function get container ():DisplayObjectContainer
		{
			return _container;
		}
		
		public function ViewController ()
		{
			
		}
		
		override public function dispose ():void
		{
			
		}
	}
}