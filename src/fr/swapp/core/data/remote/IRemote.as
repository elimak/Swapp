package fr.swapp.core.data.remote 
{
	import fr.swapp.core.data.parse.IDataParser;
	import org.osflash.signals.ISignal;
	
	/**
	 * L'interface pour les remotes
	 * @author ZoulouX
	 */
	public interface IRemote
	{
		/**
		 * Le parseur associé
		 */
		function get parser ():IDataParser;
		function set parser (value:IDataParser):void;
		
		/**
		 * La liste des appels en cours
		 */
		function get currentCalls ():Array;
		
		/**
		 * Le nombre de calls en cours d'exécution
		 */
		function get totalCurrentCalls ():uint;
		
		/**
		 * Le dernier id attribué à un appel
		 */
		function get lastCallId ():uint;
		
		/**
		 * Récupérer le dernier appel
		 */
		function get lastCall ():RemotingCall;
		
		/**
		 * Récupérer le prochain appel à être traité par la pile
		 */
		function get nextCall ():RemotingCall;
		
		/**
		 * Un appel s'est correctement effectué
		 */
		function get onSuccess ():ISignal;
		
		/**
		 * Une erreur s'est produite
		 */
		function get onError ():ISignal;
		
		/**
		 * Activer le mode queue.
		 * Ce mode permet d'éviter qu'il y ai plusieurs appels en cours sur une même remote.
		 * Si un appel B est effectué alors qu'un appel A est en cours, l'appel B sera exécuté qu'une fois l'appel A terminé (success ou error)
		 */
		function get queueMode ():Boolean;
		function set queueMode (value:Boolean):void;
		
		/**
		 * Annuler automatiquement les appels en attente avec la même commande, lors d'un nouvel appel
		 */
		function get autoCancelCommands ():Boolean;
		function set autoCancelCommands (_autoCancelCommands:Boolean):void;
		
		/**
		 * La méthode call, à concrêtiser en overridant.
		 * @param pCommandName : Le nom de la commande à exécuter
		 * @param pOptions : Les options de l'appel
		 * @param ... rest : Les paramètres non nommés optionnels.
		 * @return : L'objet call contenant son id et sa commande.
		 */
		function call (pCommandName:String, pOptions:Object = null, ... rest):RemotingCall;
		
		/**
		 * Arrêter tous les appels
		 */
		function cancelQueue ():void;
		
		/**
		 * Arrêter tous les appels vers une commande
		 * @param	pCommandName : Le nom de la commande a supprimer
		 */
		function cancelQueueForCommand (pCommandName:String):void;
		
		/**
		 * Arrêter tous les appels qui ne correspondent pas a cette commande
		 * @param	pCommandName : Le nom de la commande a garder
		 */
		function cancelQueueWithOtherCommand (pCommandName:String):void;
	}
}