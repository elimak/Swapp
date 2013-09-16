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
			// TODO : Model de base plus élaboré
			// TODO : Model avec un service associé (pour faire un AModel basé sur cette classe pour chaque projet)
			construct();
		}
		protected function construct ():void
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