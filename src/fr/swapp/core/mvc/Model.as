package fr.swapp.core.mvc
{
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	/**
	 * @author ZoulouX
	 */
	public class Model implements IModel
	{
		protected var _onDisposed			:Signal;
		
		
		public function get onDisposed ():ISignal { return _onDisposed; }
		
		
		public function Model ()
		{
			
		}
		
		public function dispose ():void
		{
			_onDisposed.dispatch();
			_onDisposed.removeAll();
			_onDisposed = null;
		}
	}
}