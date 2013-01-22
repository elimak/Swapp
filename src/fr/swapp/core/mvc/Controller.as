package fr.swapp.core.mvc
{
	import fr.swapp.core.actions.IAction;
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	
	/**
	 * @author ZoulouX
	 */
	public class Controller implements IController
	{
		/**
		 * Les signaux pour le démarrage et l'arrêt
		 */
		protected var _onTurningOn						:Signal 						= new Signal();
		protected var _onTurnedOn						:Signal 						= new Signal();
		protected var _onTurningOff						:Signal 						= new Signal();
		protected var _onTurnedOff						:Signal 						= new Signal();
		
		/**
		 * Si le controlleur est démarré
		 */
		protected var _started							:Boolean						= false;
		
		/**
		 * Si le controlleur démarre
		 */
		protected var _turningOn						:Boolean						= false;
		
		/**
		 * Si le controlleur est en train d'être arrêté
		 */
		protected var _turningOff						:Boolean						= false;
		
		/**
		 * If controller is disposed
		 */
		protected var _disposed							:Boolean;
		
		/**
		 * When controller is disposed
		 */
		protected var _onDisposed						:Signal							= new Signal();
		
		
		/**
		 * Démarrage
		 */
		public function get onTurningOn ():ISignal { return _onTurningOn; }
		
		/**
		 * Démarré
		 */
		public function get onTurnedOn ():ISignal { return _onTurnedOn; }
		
		/**
		 * Arrêt
		 */
		public function get onTurningOff ():ISignal { return _onTurningOff; }
		
		/**
		 * Arrêté
		 */
		public function get onTurnedOff ():ISignal { return _onTurnedOff; }
		
		/**
		 * Si le controlleur est démarré
		 */
		public function get started ():Boolean { return _started; }
		
		/**
		 * Si le controlleur démarre
		 */
		public function get turningOn ():Boolean { return _turningOn; }
		
		/**
		 * Si le controlleur est en train d'être arrêté
		 */
		public function get turningOff ():Boolean { return _turningOff; }
		
		/**
		 * If controller is disposed
		 */
		public function get disposed ():Boolean { return _disposed; }
		
		/**
		 * When controller is disposed
		 */
		public function get onDisposed ():ISignal { return _onDisposed; }
		
		
		/**
		 * Le constructeur
		 */
		public function Controller ()
		{
			
		}
		
		/**
		 * Dispatcher un signal par rapport à l'interface IEngine.
		 * Le propriété started sera gérée automatiquement.
		 */
		protected function dispatchEngineSignal (pSignal:Signal):void
		{
			// Si le signal n'est pas null
			if (pSignal != null)
			{
				// Si on démarre
				if (pSignal == _onTurningOn)
				{
					_turningOn = true;
					_started = false;
					_turningOff = false;
				}
				
				// Si on a démarré
				else if (pSignal == _onTurnedOn)
				{
					_turningOn = false;
					_started = true;
					_turningOff = false;
				}
				
				// Si on arrête
				else if (pSignal == _onTurningOff)
				{
					_turningOn = false;
					_started = true;
					_turningOff = true;
				}
				
				// Si on a arrêté
				else if (pSignal == _onTurnedOff)
				{
					_turningOn = false;
					_started = false;
					_turningOff = false;
				}
				
				// Dispatcher le signal
				pSignal.dispatch();
			}
		}
		
		/**
		 * Démarrer le controlleur
		 */
		public function turnOn ():void
		{
			// Par défaut, dispatcher les 2 signaux directement
			dispatchEngineSignal(_onTurningOn);
			dispatchEngineSignal(_onTurnedOn);
		}
		
		/**
		 * Arrêter le controlleur
		 */
		public function turnOff ():void 
		{
			// Par défaut, dispatcher les 2 signaux directement
			dispatchEngineSignal(_onTurningOff);
			dispatchEngineSignal(_onTurnedOff);
		}
		
		/**
		 * Initialization
		 */
		public function init ():void
		{
			
		}
		
		/**
		 * Request an action
		 */
		public function requestAction (pAction:IAction):void
		{
			
		}
		
		/**
		 * Méthode abstraite de destruction. A overrider et relayer.
		 */
		public function dispose ():void
		{
			// Supprimer toutes les écoutes des signaux engine
			_onTurningOn.removeAll();
			_onTurnedOn.removeAll();
			_onTurningOff.removeAll();
			_onTurnedOff.removeAll();
			
			// Les passer à null
			_onTurningOn = null;
			_onTurnedOn = null;
			_onTurningOff = null;
			_onTurnedOff = null;
			
			// Il est disposé
			_disposed = true;
			
			// Signaler et supprimer
			_onDisposed.dispatch();
			_onDisposed.removeAll();
			_onDisposed = null;
		}
	}
}