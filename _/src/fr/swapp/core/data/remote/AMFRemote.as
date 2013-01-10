package fr.swapp.core.data.remote 
{
	/**
	 * Les imports
	 */
	import flash.events.AsyncErrorEvent;
	import flash.events.ErrorEvent;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.NetConnection;
	import flash.net.Responder;
	import fr.swapp.core.log.Log;
	import fr.swapp.core.roles.IDisposable;
	
	/**
	 * Récupération de données depuis une passerelle AMF
	 * @author ZoulouX
	 */
	public class AMFRemote extends ARemote implements IRemote, IDisposable
	{
		/**
		 * La NetConnection
		 */
		protected var _netConnection				:NetConnection;
		
		/**
		 * Récupérer la netConnection
		 */
		public function get netConnection ():NetConnection { return _netConnection; }
		
		
		/**
		 * Le constructeur
		 * @param	pGatewayURI : L'URI de la passerelle AMF. Serveur FMS ou passerelle AMF classique.
		 * @param	pNetConnection : Une netConnection spécifique peut être passée en paramètre
		 * @param	pAutoCancelCommands : Annuler automatiquement les doubles appels vers la même commande. Activé par défaut sur la remote AMF.
		 */
		public function AMFRemote (pGatewayURI:String = "", pNetConnection:NetConnection = null, pAutoCancelCommands:Boolean = true)
		{
			// Annuler les appels vers la même commande
			_autoCancelCommands = pAutoCancelCommands;
			
			// Vérifier si on a une netConnection
			if (pNetConnection != null)
				_netConnection = pNetConnection;
			else
				_netConnection = new NetConnection();
			
			// Ecouter les events
			registerEvents();
			
			// Se connecter si on a une URL
			if (pGatewayURI != "")
			{
				_netConnection.connect(pGatewayURI);
				Log.notice("Connecting AMFRemote to "+pGatewayURI);
			}
		}
		
		/**
		 * Ecouter les évènements
		 */
		protected function registerEvents ():void
		{
			_netConnection.addEventListener(NetStatusEvent.NET_STATUS, 				netStatusHandler);
			_netConnection.addEventListener(IOErrorEvent.IO_ERROR, 					asyncErrorHandler);
			_netConnection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, 		asyncErrorHandler);
			_netConnection.addEventListener(AsyncErrorEvent.ASYNC_ERROR, 			asyncErrorHandler);
		}
		
		/**
		 * Ne plus écouter les évènements
		 */
		protected function unregisterEvents ():void
		{
			_netConnection.removeEventListener(NetStatusEvent.NET_STATUS, 			netStatusHandler);
			_netConnection.removeEventListener(IOErrorEvent.IO_ERROR, 				asyncErrorHandler);
			_netConnection.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, 	asyncErrorHandler);
			_netConnection.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, 		asyncErrorHandler);
		}
		
		/**
		 * Appeler un service AMF.
		 * @param	pCommand : Le nom de la commande AMF, par exemple "MainController.mainAction"
		 * @param	pOptions : Les options de cet appel. Cet objet peut contenir une fonction onSuccess, onError, et un flag immediateCall. Si ce dernier est à false, la méthode executée du RemotingCall devra être appelée manuellement.
		 * @param	... rest : Les paramètres à passer à la commande AMF
		 * @return
		 */
		override public function call (pCommand:String, pOptions:Object = null, ... rest):RemotingCall
		{
			// Si on a pas d'options
			if (pOptions == null)
				pOptions = {};
			
			// Le call
			var remotingCall:RemotingCall;
			
			// L'appel a réussi
			function AMFCallSuccessHandler (pResponse:*):void
			{
				Log.notice("AMFRemote / AMFCallSuccessHandler");
				
				// Enregistrer les données
				remotingCall.data = pResponse;
				
				// Signaler la réussite
				callSuccess(remotingCall);
			}
			
			// Erreur lors de l'appel
			function AMFCallErrorHandler (pResponse:*):void
			{
				Log.notice("AMFRemote / AMFCallErrorHandler");
				
				// Enregistrer les données
				remotingCall.data = pResponse;
				
				// Générer l'erreur
				Log.warning("TODO : AMFRemote.call / AMFCallErrorHandler");
				remotingCall.error = new Error("AMF ERROR");
				
				// Signaler l'échec
				callError(remotingCall);
			}
			
			// Créer le responder, avec le délégations locales
			var responder:Responder = new Responder(AMFCallSuccessHandler, AMFCallErrorHandler);
			
			// Créer le call avec la commande, les options, et la routine.
			remotingCall = getRemotingCall(
				pCommand,
				_netConnection.call,
				[pCommand, responder].concat(rest),
				pOptions == null ? {} : pOptions
			);
			
			// Exécuter cet appel si on est pas en mode queue
			// Ou si on est en mode queue et qu'on a rien dans la pile
			if (_queueMode == false || nextCall == remotingCall)
				callNext();
			
			// Retourner ce call
			return remotingCall;
		}
		
		/**
		 * Préparer les données avant le parse
		 * @param	pData
		 * @return
		 */
		override protected function prepareData (pData:*):*
		{
			return pData;
		}
		
		/**
		 * Erreur asynchrone sur la netConnection
		 * @param	event
		 */
		protected function asyncErrorHandler (event:ErrorEvent):void
		{
			Log.warning("TODO : AMFRemote.asyncErrorHandler");
			Log.log(event.type);
			
			/*
			// Vérifier le type d'erreur
			if (event is AsyncErrorEvent)
				// Dispatcher une erreur Async
				dispatchError("", 0);
			else if (event is IOErrorEvent)
				// Dispatcher une erreur IO
				dispatchError("", 0);
			else if (event is SecurityErrorEvent)
				// Dispatcher une erreur Security
				dispatchError("", 0);
			*/
		}
		
		/**
		 * Changement de status de la passerelle
		 * @param	event
		 */
		protected function netStatusHandler (event:NetStatusEvent):void 
		{
			Log.warning("TODO : AMFRemote.netStatusHandler");
			Log.log(event.info.code);
		}
		
		/**
		 * Effacer
		 */
		override public function dispose ():void
		{
			// Relayer
			super.dispose();
			
			// Ne plus écouter les events
			unregisterEvents();
		}
	}
}