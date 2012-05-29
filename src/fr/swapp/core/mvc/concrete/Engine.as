package fr.swapp.core.mvc.concrete
{
	import fr.swapp.core.roles.IDisposable;
	import fr.swapp.core.roles.IEngine;
	import fr.swapp.core.roles.IReadyable;
	import fr.swapp.core.roles.IStartStoppable;
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	
	/**
	 * @author ZoulouX
	 */
	public class Engine implements IEngine, IStartStoppable, IDisposable
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
		 * Le constructeur
		 */
		public function Engine ()
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
		public function turnOn (pContextInfo:Object = null):void
		{
			// Par défaut, dispatcher les 2 signaux directement
			dispatchEngineSignal(_onTurningOn);
			dispatchEngineSignal(_onTurnedOn);
		}
		
		/**
		 * Arrêter le controlleur
		 */
		public function turnOff (pContextInfo:Object = null):void 
		{
			// Par défaut, dispatcher les 2 signaux directement
			dispatchEngineSignal(_onTurningOff);
			dispatchEngineSignal(_onTurnedOff);
		}
		
		/**
		 * Attendre un IReadyable pour construire.
		 * Pas de construction pendant les transitions si pWaitForMe est à true (défaut).
		 */
		public function waitReadyable (pReadyable:IReadyable, pHandler:Function, pWaitForMe:Boolean = true):Boolean
		{
			// Si le readyable est prêt
			if (pReadyable.ready)
			{
				// On appel directement le handler
				pHandler.apply();
				
				// Appelé directement
				return true;
			}
			else
			{
				// Si la vue est affichée
				if (_started || !pWaitForMe)
				{
					// On attend le signal
					pReadyable.onReady.addOnce(pHandler);
				}
				else
				{
					// On attend que cet élément soit prêt
					_onTurnedOn.addOnce(function ():void {
						waitReadyable(pReadyable, pHandler);
					});
				}
				
				// Décallé
				return false;
			}
		}
		
		/**
		 * Ne plus attendre le IReadyable
		 */
		public function noMoreWaitReadyable (pReadyable:IReadyable, pHandler:Function):void
		{
			pReadyable.onReady.remove(pHandler);
		}
		
		/**
		 * Méthode abstraite de destruction. A overrider.
		 */
		public function dispose ():void
		{
			// Supprimer toutes les écoutes des signaux engine
			_onTurningOn.removeAll();
			_onTurnedOn.removeAll();
			_onTurningOff.removeAll();
			_onTurnedOff.removeAll();
		}
	}
}