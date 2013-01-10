package fr.swapp.core.mvc.concrete 
{
	import fr.swapp.core.mvc.abstract.IModel;
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	
	/**
	 * @author ZoulouX
	 */
	public class Model implements IModel
	{
		/**
		 * Lorsque le model est prêt
		 */
		protected var _onReady							:Signal						= new Signal();
		
		/**
		 * Lorsqu'il y a une erreur
		 */
		protected var _onError							:Signal						= new Signal();
		
		/**
		 * Le modèle est pret ?
		 */
		protected var _ready							:Boolean;
		
		
		/**
		 * Lorsque le model est prêt
		 */
		public function get ready ():Boolean { return _ready; }
		public function set ready (value:Boolean):void
		{
			// S'il y a un changement d'état
			if (value != _ready)
			{
				// Enregistrer l'état
				_ready = value;
				
				// Dispatcher si c'est prêt
				if (_ready)
					_onReady.dispatch();
			}
		}
		
		/**
		 * Lorsque le model est prêt
		 */
		public function get onReady ():ISignal { return _onReady; }
		
		/**
		 * Lorsqu'il y a une erreur
		 */
		public function get onError ():ISignal { return _onError; }
		
		
		/**
		 * Constructeur
		 */
		public function Model ()
		{
			
		}
		
		/**
		 * Destruction du model
		 */
		public function dispose ():void
		{
			_onReady.removeAll();
			_onError.removeAll();
		}
	}
}