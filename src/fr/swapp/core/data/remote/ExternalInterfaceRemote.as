package fr.swapp.core.data.remote 
{
	import flash.external.ExternalInterface;
	import fr.swapp.core.errors.SwappError;
	import fr.swapp.core.log.Log;
	
	/**
	 * Récupérer des données depuis l'External Interface
	 * @author ZoulouX
	 */
	public class ExternalInterfaceRemote extends ARemote
	{
		/**
		 * Constructeur
		 */
		public function ExternalInterfaceRemote ()
		{
			
		}
		
		/**
		 * Appeler une fonction via ExternalInterface.
		 * @param	pCommand : Le nom de la fonction à appeler
		 * @param	pOptions : Les options
		 * @param	... rest : Les paramètres de la fonction
		 */
		override public function call (pCommand:String, pOptions:Object = null, ... rest):RemotingCall
		{
			// Si on a pas d'options
			if (pOptions == null)
				pOptions = { };
			
			// Le call
			var remotingCall:RemotingCall;
			
			// L'appel a réussi
			function ExternalInterfaceCallRoutine (pCommand:String, pParameters:Array):void
			{
				// Vérifier que l'externalInterface soit disponible
				if (ExternalInterface.available)
				{
					// Essayer d'appeler la fonction et récupérer les données
					remotingCall.data = ExternalInterface.call.apply(null, [pCommand].concat(pParameters));
					
					// Signaler la réussite
					callSuccess(remotingCall);
				}
				else
				{
					// Générer l'erreur
					Log.warning("TODO : ExternalInterfaceRemote.call / ExternalInterfaceCallRoutine");
					remotingCall.error = new Error("EXTERNAL INTERFACE ERROR");
					
					// Signaler l'échec
					callError(remotingCall);
				}
			}
			
			// Créer le call avec la commande, les options, et la routine.
			remotingCall = getRemotingCall(
				pCommand,							// L'url de fichier à charger
				ExternalInterfaceCallRoutine,		// La routine d'activation du chargement
				[pCommand].concat(rest),			// Le paramètre de la routine
				pOptions == null ? {} : pOptions 	// Les options du call
			);
			
			// Exécuter cet appel si on est pas en mode queue
			// Ou si on est en mode queue et qu'on a rien dans la pile
			if (_queueMode == false || totalCurrentCalls == 0)
				remotingCall.execute();
			
			// Ajouter ce call à la liste
			_currentCalls.push(remotingCall);
			
			// Retourner ce call
			return remotingCall;
		}
		
		/**
		 * Ajouter un callBack de l'ExternalInterface vers le flash.
		 * @param	pObject : Un objet ou tableau associatif contenant des fonctions. Ces fonctions doivent avoir le même nom que celle appelées depuis l'externalInterface.
		 */
		public function registerCallbackObject (pObject:Object):void
		{
			// Parcourir les fonctions de l'objet
			for (var i:String in pObject)
			{
				/// Si c'est une fonction
				if (pObject[i] is Function)
				{
					// Ajouter cette fonction
					ExternalInterface.addCallback(i, pObject[i]);
				}
				else
				{
					// Déclancher une erreur
					throw new SwappError("ExternalInterfaceRemote.registerCallbackObject", "Callback objet must contain only functions.");
				}
			}
		}
	}
}