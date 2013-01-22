package fr.swapp.core.data.remote 
{
	import fr.swapp.core.errors.SwappError;
	import fr.swapp.core.log.Log;
	import fr.swapp.core.roles.IDisposable;
	import fr.swapp.core.roles.IExecutable;
	import fr.swapp.core.roles.IIdentifiable;
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	
	/**
	 * Cette classe permet de généraliser et de stocker chaque appel remoting de manière abstraite.
	 * Les appels peuvent être asynchrones, synchrones, de type XML / AMF ou autre.
	 * @author ZoulouX
	 */
	public class RemotingCall implements IIdentifiable, IExecutable, IDisposable
	{
		/**
		 * L'id de l'appel
		 */
		protected var _id						:uint;
		
		/**
		 * Le nom de la commande exécutée
		 */
		protected var _command					:String;
		
		/**
		 * La routine interne à exécuter
		 */
		protected var _routine					:Function;
		
		/**
		 * Les arguments de la routine
		 */
		protected var _routineArguments			:Array;
		
		/**
		 * Les données reçues
		 */
		protected var _data						:*;
		
		/**
		 * Les options de l'appel
		 */
		protected var _options					:Object;
		
		/**
		 * Si l'appel est en cours
		 */
		protected var _pending					:Boolean;
		
		/**
		 * S'il cet appel à été répondu (par une réussite ou une erreur)
		 */
		protected var _complete					:Boolean;
		
		/**
		 * Erreur associée à cet appel (si on a eu une erreur)
		 */
		protected var _error					:Error;
		
		/**
		 * If call is disposed
		 */
		protected var _disposed					:Boolean;
		
		/**
		 * When disposed
		 */
		protected var _onDisposed				:Signal					= new Signal();
		
		
		
		/**
		 * When disposed
		 */
		public function get onDisposed ():ISignal { return _onDisposed; }
		
		/**
		 * L'id de l'appel
		 */
		public function get id ():uint { return _id; }
		public function set id (value:uint):void 
		{
			throw new SwappError("RemotingCall.id", "RemotingCall's id is permanent. Define it once via the constructor.");
		}
		
		/**
		 * Le nom de la commande
		 */
		public function get command ():String { return _command; }
		
		/**
		 * Les données reçues.
		 * Persistera même après disposition de l'objet.
		 */
		public function get data ():* { return _data; }
		public function set data (value:*):void 
		{
			_data = value;
		}
		
		/**
		 * La routine du call.
		 */
		public function get routine ():Function { return _routine; }
		public function set routine (value:Function):void 
		{
			_routine = value;
		}
		
		/**
		 * Les arguments associés à la routine.
		 * Sera null une fois l'appel terminé.
		 */
		public function get routineArguments ():Array { return _routineArguments; }
		public function set routineArguments (value:Array):void 
		{
			_routineArguments = value;
		}
		
		/**
		 * Les options de l'appel.
		 * Sera null une fois l'appel terminé.
		 */
		public function get options ():Object { return _options; }
		public function set options (value:Object):void 
		{
			_options = value;
		}
		
		/**
		 * S'il cet appel à été répondu (par une réussite ou une erreur)
		 */
		public function get complete ():Boolean { return _complete; }
		public function set complete (value:Boolean):void 
		{
			_complete = value;
			
			if (value)
				_pending = false;
		}
		
		/**
		 * Si l'appel est en cours
		 */
		public function get pending ():Boolean { return _pending; }
		public function set pending (value:Boolean):void
		{
			_pending = value;
		}
		
		/**
		 * Erreur associée à cet appel (si on a eu une erreur)
		 */
		public function get error ():Error { return _error; }
		public function set error (value:Error):void 
		{
			_error = value;
		}
		
		/**
		 * If call is disposed
		 */
		public function get disposed ():Boolean { return _disposed; }
		
		
		/**
		 * Le constructeur de l'appel.
		 * @param	pId : L'identifiant de l'appel
		 * @param	pCommand : Le nom de la commande exécutée
		 * @param	pRoutine : La routine interne à exécuter
		 * @param	pRoutineArguments : La arguments envoyés à la routine
		 * @param	pOptions : Les options de l'appel
		 */
		public function RemotingCall (pId:uint, pCommand:String, pRoutine:Function, pRoutineArguments:Array, pOptions:Object)
		{
			// Enregistrer les paramètres
			_id = pId;
			_command = pCommand;
			_routine = pRoutine;
			_routineArguments = pRoutineArguments;
			_options = pOptions;
		}
		
		/**
		 * Exécuter cet appel
		 */
		public function execute ():void
		{
			// Si on a une routine
			if (_routine != null)
			{
				Log.notice("RemotingCall.execute", _command, _id);
				
				// L'appel est en cours
				_pending = true;
				
				// Appeler la routine en lui passant les paramètres
				_routine.apply(null, _routineArguments == null ? [] : _routineArguments);
			}
			else
			{
				Log.warning("RemotingCall.execute WITHOUT ROUTINE!");
			}
		}
		
		/**
		 * Disposer
		 */
		public function dispose ():void
		{
			Log.notice("RemotingCall.dispose", _command, _id, _routine);
			
			// Effacer la routine
			_routine = null;
			
			// Ses arguments
			_routineArguments = null;
			
			// Et les options
			_options = null;
			
			// Disposed
			_disposed = true;
			
			// Signaler et supprimer
			_onDisposed.dispatch();
			_onDisposed.removeAll();
			_onDisposed = null;
		}
	}
}