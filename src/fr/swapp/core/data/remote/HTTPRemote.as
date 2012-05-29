package fr.swapp.core.data.remote 
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import fr.swapp.core.log.Log;
	import fr.swapp.utils.ObjectUtils;
	
	/**
	 * @author ZoulouX
	 */
	public class HTTPRemote extends ARemote 
	{
		/**
		 * Le constructeur
		 */
		public function HTTPRemote ()
		{
			
		}
		
		/**
		 * Préparer les données avant l'envoie
		 * @param	pData : Les données à préparer
		 * @return : Les données préparées
		 */
		protected function prepareSend (pData:*):*
		{
			return pData;
		}
		
		/**
		 * Appeler un service HTTP.
		 * @param	pCommand : Le nom du fichier HTTP ou l'URI du service HTTP
		 * @param	pOptions : Les options
		 * @param	... rest : Premier argument : Les paramètres à envoyer en GET ou en POST (object)
		 */
		override public function call (pCommand:String, pOptions:Object = null, ... rest):RemotingCall
		{
			// Si on a pas d'options
			if (pOptions == null)
				pOptions = { };
			
			// Le call
			var remotingCall:RemotingCall;
			
			// Créer le loader la requête et les variables
			var loader:URLLoader = new URLLoader();
			var request:URLRequest = new URLRequest(pCommand);
			var variables:URLVariables = new URLVariables();
			
			// Si on a une méthode dans les options
			if ("method" in pOptions)
				request.method = pOptions.method;
			
			// Si on a des paramètres
			if (rest[0] != null && typeof(rest[0]) == "object")
			{
				// Préparer les options
				rest[0] = prepareSend(rest[0]);
				
				// Passer les paramètres
				ObjectUtils.extra(variables, rest[0]);
			}
			
			// Associer les variables à la requête
			request.data = variables;
			
			// L'appel a réussi
			function HTTPCallSuccessHandler (event:Event):void
			{
				// Enregistrer les données
				remotingCall.data = loader.data;
				
				// Signaler la réussite
				callSuccess(remotingCall);
			}
			
			// Erreur lors de l'appel
			function HTTPCallErrorHandler (event:Event):void
			{
				// Enregistrer les données
				remotingCall.data = loader.data;
				
				// Générer l'erreur
				Log.warning("TODO : HTTPRemote.call / HTTPCallErrorHandler");
				remotingCall.error = new Error("HTTP ERROR");
				
				// Signaler l'échec
				callError(remotingCall);
			}
			
			// Ecouter les erreurs et success (référence faible car c'est un delegate)
			loader.addEventListener(Event.COMPLETE, 					HTTPCallSuccessHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, 				HTTPCallErrorHandler);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, 	HTTPCallErrorHandler);
			
			// Créer le call avec la commande, les options, et la routine.
			remotingCall = getRemotingCall(
				pCommand,							// L'url de fichier à charger
				loader.load,						// La routine d'activation du chargement
				[request],							// Le paramètre de la routine
				pOptions == null ? {} : pOptions 	// Les options du call
			);
			
			// Exécuter cet appel si on est pas en mode queue
			// Ou si on est en mode queue et qu'on a rien dans la pile
			if (_queueMode == false || nextCall == remotingCall)
				callNext();
			
			// Retourner ce call
			return remotingCall;
		}
	}
}