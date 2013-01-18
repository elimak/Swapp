package fr.swapp.core.data.remote 
{
	/**
	 * Les imports
	 */
	import fr.swapp.core.data.collect.IDataCollection;
	import fr.swapp.core.data.items.IDataItem;
	import fr.swapp.core.data.parse.DataParser;
	import fr.swapp.core.data.parse.IDataParser;
	import fr.swapp.core.errors.SwappError;
	import fr.swapp.core.roles.IDisposable;
	import fr.swapp.utils.ArrayUtils;
	import org.osflash.signals.DeluxeSignal;
	import org.osflash.signals.ISignal;
	
	/**
	 * La remote abstraite.
	 * Ne pas instancier directement cette classe, seules ses classes concrêtes peuvent être instanciées.
	 * @author ZoulouX
	 */
	public class ARemote implements IRemote, IDisposable
	{
		/**
		 * Fonction appelée lorsque l'appel est réussi
		 */
		public static const ON_SUCCESS					:String 			= "onSuccess";
		
		/**
		 * Fonction appelée lorsque une erreur est interceptée sur le call
		 */
		public static const ON_ERROR					:String 			= "onError";
		
		/**
		 * Parser après un call (true par défaut si un parseur est associé)
		 */
		public static const DO_PARSE					:String 			= "doParse";
		
		/**
		 * Fonction appelée avant le parse des données (les données sont encore brutes)
		 */
		public static const BEFORE_PARSE				:String 			= "beforeParse";
		
		/**
		 * Fonction appelée avant le parse des données (les données sont encore brutes)
		 */
		public static const AFTER_PARSE					:String 			= "afterParse";
		
		/**
		 * La collection à remplir automatiquement avec les IDataItem parsés.
		 * Doit être IDataCollection ou un tableau de IDataCollection.
		 */
		public static const COLLECTION_TO_FEED			:String 			= "collectionToFeed";
		
		/**
		 * Le type pour le remplissage automatique de la collection (IDataItem par défaut)
		 * Sera ignoré s'il y a plusieurs collections dans le collectionToFeed.
		 */
		public static const COLLECTION_FEED_TYPE		:String 			= "collectionFeedType";
		
		/**
		 * Le type pour le remplissage automatique de la collection (IDataItem par défaut)
		 */
		public static const COLLECTION_FEED_RECURSIVITY	:String 			= "collectionFeedRecursivity";
		
		/**
		 * Le type pour le remplissage automatique de la collection (IDataItem par défaut)
		 */
		public static const RESET_COLLECTION_ON_FEED	:String 			= "resetCollectionOnFeed";
		
		
		/**
		 * Le parseur associé
		 */
		protected var _parser					:IDataParser;
		
		/**
		 * La liste des appels en cours
		 */
		protected var _currentCalls				:Array					= [];
		
		/**
		 * L'id de call courrant
		 */
		protected var _lastCallId				:uint					= 0;
		
		/**
		 * Activer le mode queue.
		 * Ce mode permet d'éviter qu'il y ai plusieurs appels en cours sur une même remote.
		 * Si un appel B est effectué alors qu'un appel A est en cours, l'appel B sera exécuté qu'une fois l'appel A terminé (success ou error)
		 */
		protected var _queueMode				:Boolean 				= true;
		
		/**
		 * Annuler automatiquement les appels en attente avec la même commande, lors d'un nouvel appel
		 */
		protected var _autoCancelCommands		:Boolean				= false;
		
		/**
		 * Un appel s'est correctement effectué
		 */
		protected var _onSuccess				:DeluxeSignal			= new DeluxeSignal(this);
		
		/**
		 * Une erreur s'est produite
		 */
		protected var _onError					:DeluxeSignal			= new DeluxeSignal(this);
		
		
		/**
		 * Le parseur associé
		 */
		public function get parser ():IDataParser
		{
			// Créer un parseur à la demande
			if (_parser == null)
				_parser = new DataParser();
			
			return _parser;
		}
		public function set parser (value:IDataParser):void 
		{
			_parser = value;
		}
		
		/**
		 * La liste des appels en cours
		 */
		public function get currentCalls ():Array { return _currentCalls; }
		
		/**
		 * Le nombre de calls en cours d'exécution
		 */
		public function get totalCurrentCalls ():uint { return _currentCalls.length;  }
		
		/**
		 * Le dernier id attribué à un appel
		 */
		public function get lastCallId ():uint { return _lastCallId; }
		
		/**
		 * Récupérer le dernier appel
		 */
		public function get lastCall ():RemotingCall
		{
			return _currentCalls[totalCurrentCalls - 1];
		}
		
		/**
		 * Récupérer le prochain appel à être traité par la pile
		 */
		public function get nextCall ():RemotingCall
		{
			return _currentCalls[0];
		}
		
		/**
		 * Un appel s'est correctement effectué
		 */
		public function get onSuccess ():ISignal { return _onSuccess; }
		
		/**
		 * Une erreur s'est produite
		 */
		public function get onError ():ISignal { return _onError; }
		
		/**
		 * Activer le mode queue.
		 * Ce mode permet d'éviter qu'il y ai plusieurs appels en cours sur une même remote.
		 * Si un appel B est effectué alors qu'un appel A est en cours, l'appel A sera exécuté qu'une fois l'appel B terminé (success ou error)
		 */
		public function get queueMode ():Boolean { return _queueMode; }
		public function set queueMode (value:Boolean):void 
		{
			_queueMode = value;
		}
		
		/**
		 * Annuler automatiquement les appels en attente avec la même commande, lors d'un nouvel appel
		 */
		public function get autoCancelCommands ():Boolean { return _autoCancelCommands }
		public function set autoCancelCommands (value:Boolean):void
		{
			_autoCancelCommands = value;
		}
		
		/**
		 * Le constructeur
		 */
		public function ARemote ()
		{
			
		}
		
		/**
		 * Récupérer un objet RemotingCall
		 */
		protected function getRemotingCall (pCommand:String, pRoutine:Function, pRoutineArguments:Array, pOptions:Object):RemotingCall
		{
			// Vérifier si on doit supprimer tous les calls de la même commande
			if (_autoCancelCommands)
			{
				// Si oui, alors on le fait!
				cancelQueueForCommand(pCommand);
			}
			
			// Créer le call et passer à l'id suivant
			var call:RemotingCall = new RemotingCall(_lastCallId ++, pCommand, pRoutine, pRoutineArguments, pOptions);
			
			// Ajouter le call à la liste
			_currentCalls.push(call);
			
			// Retourner ce call
			return call;
		}
		
		/**
		 * La méthode call, à concrêtiser en overridant.
		 * @param pCommand : Le nom de la commande à exécuter
		 * @param pOptions : Les options de l'appel
		 * @param ... rest : Les paramètres non nommés optionnels.
		 * @return : L'objet call contenant son id et sa commande.
		 */
		public function call (pCommand:String, pOptions:Object = null, ... rest):RemotingCall
		{
			// Par défaut, déclancher une erreur
			throw new SwappError("ADataRemote.call", "This is an abstract method which you must override.");
			return null;
		}
		
		/**
		 * Traiter un appel qui a réussi
		 * @param	pCall : L'appel qui a réussi
		 */
		protected function callSuccess (pCall:RemotingCall):void
		{
			// Si l'appel a une routine (donc s'il n'est pas disposé)
			if (pCall.routine != null)
			{
				// Le call est terminé
				pCall.complete = true;
				pCall.pending = false;
				
				// Préparer les données
				pCall.data = prepareData(pCall.data);
				
				// Appeler le beforeParse sur les options
				if (pCall.options[BEFORE_PARSE] != null && pCall.options[BEFORE_PARSE] is Function)
					pCall.options[BEFORE_PARSE](pCall);
				
				// Si on a un parser et si les options autorisent le parsing
				if (_parser != null && (pCall.options[DO_PARSE] == null || pCall.options[DO_PARSE] == true))
				{
					// Parser les données
					pCall.data = parser.parse(pCall.data);
				}
				
				// Après le parsing
				if (pCall.options[AFTER_PARSE] != null && pCall.options[AFTER_PARSE] is Function)
					pCall.options[AFTER_PARSE](pCall);
				
				// Voir dans les options si on doit remplir une collection automatiquement
				if (pCall.options[COLLECTION_TO_FEED] != null)
				{
					// Le paramètres par défaut pour la récursivité (infinie par défaut)
					if (pCall.options[COLLECTION_FEED_RECURSIVITY] == null || !pCall.options[COLLECTION_FEED_RECURSIVITY] is Number)
						pCall.options[COLLECTION_FEED_RECURSIVITY] = -1;
					
					// Vérifier si on a une ou plusieurs collection
					if (pCall.options[COLLECTION_TO_FEED] is IDataCollection)
					{
						// Le type de IDataItem à intégrer dans la collection
						// Vérifier si c'est correctement spécifié par les options
						if (pCall.options[COLLECTION_FEED_TYPE] == null || !(pCall.options[COLLECTION_FEED_TYPE] is Class))
						{
							// Si on a pas dans les options, on regarde dans la collection
							if ((pCall.options[COLLECTION_TO_FEED] as IDataCollection).dataType != null)
							{
								// On prend le type de la collection
								pCall.options[COLLECTION_FEED_TYPE] = (pCall.options[COLLECTION_TO_FEED] as IDataCollection).dataType;
							}
							else
							{
								// On prend le type par défaut : IDataItem
								pCall.options[COLLECTION_FEED_TYPE] = IDataItem;
							}
						}
						
						// Remplir la collection
						DataParser.feedCollection(
							pCall.options[COLLECTION_TO_FEED],
							pCall.data,
							pCall.options[COLLECTION_FEED_TYPE],
							pCall.options[COLLECTION_FEED_RECURSIVITY],
							pCall.options[RESET_COLLECTION_ON_FEED] == null || pCall.options[RESET_COLLECTION_ON_FEED]
						);
					}
					else if (pCall.options[COLLECTION_TO_FEED] is Array)
					{
						// Remplir les collection
						for each (var collection:IDataCollection in pCall.options[COLLECTION_TO_FEED])
						{
							DataParser.feedCollection(
								collection,
								pCall.data,
								collection.dataType,
								pCall.options[COLLECTION_FEED_RECURSIVITY]
							);
						}
					}
					else
					{
						// Ce ne sont pas des collections, déclancher une erreur
						throw new SwappError("ADataRemote.callSuccess", "Options[COLLECTION_TO_FEED] must be IDataCollection or Array of IDataCollection.");
					}
				}
				
				// Dispatcher
				_onSuccess.dispatch(pCall);
				
				// Appeler le success handler des options
				if (pCall.options[ON_SUCCESS] != null && pCall.options[ON_SUCCESS] is Function)
					pCall.options[ON_SUCCESS](pCall);
				
				// Virer ce call
				cancelCall(pCall);
				
				// Appeler l'appel suivant
				if (_queueMode)
					callNext();
			}
		}
		
		/**
		 * Traiter un appel qui a foiré
		 * @param	pCall : L'appel qui a foiré
		 */
		protected function callError (pCall:RemotingCall):void
		{
			// Si l'appel a une routine (donc s'il n'est pas disposé)
			if (pCall.routine != null)
			{
				// Dispatcher
				_onError.dispatch(pCall);
				
				// Appeler le error handler des options
				if (pCall.options[ON_ERROR] != null && pCall.options[ON_ERROR] is Function)
					pCall.options[ON_ERROR](pCall);
				
				// Virer ce call
				cancelCall(pCall);
				
				// Appeler l'appel suivant
				if (_queueMode)
					callNext();
			}
		}
		
		/**
		 * Appeler la prochaine
		 */
		protected function callNext ():void
		{
			// Si on a un prochain appel
			if (nextCall != null)
			{
				// Vérifier si le prochain appel n'est pas déjà en cours ou même terminé
				if (!nextCall.pending && !nextCall.complete)
				{
					// On peut alors l'exécuter
					nextCall.execute();
				}
			}
		}
		
		/**
		 * Préparer les données avant le parse
		 * @param	pData : Les données brutes
		 * @return : Les données préparées pour le parse (ou usage direct)
		 */
		protected function prepareData (pData:*):*
		{
			return pData;
		}
		
		/**
		 * Arrêter tous les appels
		 */
		public function cancelQueue ():void
		{
			// Parcourir tous les calls
			var total:uint = _currentCalls.length;
			for (var i:int = 0; i < total; i++) 
			{
				// Tuer les références de cet appel (plus de routine, donc plus d'attente de résultat)
				(_currentCalls[i] as IDisposable).dispose();
			}
			
			// Vider le tableau
			_currentCalls = [];
		}
		
		/**
		 * Effacer un appel de la pile.
		 * Pour le moment cette méthode reste privée pour ne pas perturber la pile.
		 * @param	pCall : L'appel à supprimer
		 */
		protected function cancelCall (pCall:RemotingCall):void
		{
			// On annule cet appel
			pCall.dispose();
			
			// On supprime cet appel de la pile
			_currentCalls = ArrayUtils.deleteElement(_currentCalls, pCall);
		}
		
		/**
		 * Arrêter tous les appels vers une commande
		 * @param	pCommandName : Le nom de la commande a supprimer
		 */
		public function cancelQueueForCommand (pCommandName:String):void
		{
			// Le nombre total, l'appel en cours, et les appels à supprimer
			var total				:uint 			= _currentCalls.length;
			var call				:RemotingCall;
			var callsToDelete		:Array			= [];
			
			// Parcourir tous les calls
			for (var i:int = 0; i < total; i++) 
			{
				// Cibler cet appel
				call = (_currentCalls[i] as RemotingCall);
				
				// Vérifier si la commande correspond
				if (call.command == pCommandName)
				{
					// On supprime cet appel
					callsToDelete.push(call);
				}
			}
			
			// Tout supprimer
			for each (call in callsToDelete)
			{
				cancelCall(call);
			}
			
			// Passer au prochain appel
			if (_queueMode)
				callNext();
		}
		
		/**
		 * Arrêter tous les appels qui ne correspondent pas a cette commande
		 * @param	pCommandName : Le nom de la commande a garder
		 */
		public function cancelQueueWithOtherCommand (pCommandName:String):void
		{
			// Le nombre total, l'appel en cours, et les appels à supprimer
			var total				:uint 			= _currentCalls.length;
			var call				:RemotingCall;
			var callsToDelete		:Array			= [];
			
			// Parcourir tous les calls
			for (var i:int = 0; i < total; i++) 
			{
				// Cibler cet appel
				call = (_currentCalls[i] as RemotingCall);
				
				// Vérifier si la commande correspond
				if (call.command != pCommandName)
				{
					// On supprime cet appel
					callsToDelete.push(call);
				}
			}
			
			// Tout supprimer
			for each (call in callsToDelete)
			{
				cancelCall(call);
			}
			
			// Passer au prochain appel
			if (_queueMode)
				callNext();
		}
		
		/**
		 * Effacer cet objet.
		 * Methode à concrêtiser sinon on te pète les doigts.
		 */
		public function dispose ():void
		{
			// Vider la queue
			cancelQueue();
		}
	}
}