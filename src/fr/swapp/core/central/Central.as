package fr.swapp.core.central
{
	import fr.swapp.core.errors.SwappError;
	
	/**
	 * @author ZoulouX
	 */
	public class Central
	{
		/**
		 * Central instance
		 */
		protected static var __instance			:Central;
		
		/**
		 * Get central instance. Will create instance if not initialised.
		 * Don't use constructor.
		 */
		public static function getInstance ():Central
		{
			// Si l'instance n'existe pas
			if (__instance == null)
			{
				// Créer l'instance avec la clé pour autoriser l'instanciation
				__instance = new Central(new SingletonKey());
			}
			
			// Retourner l'instance
			return __instance;
		}
		
		/**
		 * All listeners
		 */
		protected var _listeners				:Array				= [];
		
		/**
		 * Current event id
		 */
		protected var _currentEventId			:int				= 0;
		
		
		/**
		 * Current event id
		 */
		public function get currentEventId ():int { return _currentEventId; }
		
		
		/**
		 * Private constructor. Please use Central.getInstance to create a new instance of Central.
		 */
		public function Central (pInstanciationKey:SingletonKey)
		{
			if (pInstanciationKey == null)
			{
				throw new SwappError("Central.constructor", "Direct instancations are not allowed, please use Central.getInstance instead.");
			}
		}
		
		
		/**
		 * Listen for a message
		 * @param	pMessage : Message name, usually like "theme:messagename"
		 * @param	pHandler : Handler to respond to the message.
		 * @return : Listening ID for removeing listening.
		 */
		public function listen (pMessage:String, pHandler:Function):uint
		{
			return register(pMessage, pHandler, false);
		}
		
		/**
		 * Listen for a message, one time.
		 * @param	pMessage : Message name, usually like "theme:messagename"
		 * @param	pHandler : Handler to respond to the message.
		 * @return : Listening ID for removeing listening.
		 */
		public function listenOnce (pMessage:String, pHandler:Function):uint
		{
			return register(pMessage, pHandler, true);
		}
		
		/**
		 * Dispatch a message to all listening parts.
		 * @param	pMessage : Message to dispatch
		 * @param	pArguments : Arguments added to the handler after the message.
		 * @return : Total of handler responding.
		 */
		public function dispatch (pMessage:String, ... args):uint
		{
			// Vérifier si on a des handlers sur ce message
			if (pMessage in _listeners)
			{
				// Cibler les handlers
				var handlers:Array = _listeners[pMessage];
				var handler:Array;
				
				// Les parcourir
				for (var i:* in handlers)
				{
					// Cibler ce handler
					handler = handlers[i];
					
					// Le dispatcher
					(handler[0] as Function).apply(null, [pMessage].concat(args));
					
					// Si on doit le supprimer juste après le dispatch
					if (handler[1])
					{
						// Le supprimer
						remove(pMessage, handler[0]);
					}
				}
				
				return handlers.length;
			}
			
			return 0;
		}
		
		/**
		 * Remove a listening for an handler
		 * @param	pMessage : Message to remove
		 * @param	pHandler : Handler
		 * @return : If listening handler was found and removed.
		 */
		public function remove (pMessage:String, pHandler:Function):Boolean
		{
			// Vérifier la validité des paramètres
			if (pMessage == null || pHandler == null)
			{
				throw new SwappError("Central.remove", "Message and handler can't be null.");
				return false;
			}
			
			// Sinon on essaye de supprimer directement
			return removeByEntity(pMessage, pHandler, 0);
		}
		
		/**
		 * Remove listener by listening id.
		 * @param	pId : Listener id to remove
		 * @param	pMessage : Will be faster if provided
		 * @return : If listener id was found.
		 */
		public function removeById (pId:uint, pMessage:String = null):Boolean
		{
			// Si le message n'a pas été donné
			if (pMessage == null)
			{
				// On recherche dans les messages
				for (var i:* in _listeners)
				{
					// Essayer de supprimer ce message
					if (removeByEntity(i, pId, 2))
					{
						return true;
					}
				}
				
				// Rien trouvé
				return false;
			}
			else
			{
				// Sinon on essaye de supprimer directement
				return removeByEntity(pMessage, pId, 2);
			}
		}
		
		/**
		 * Remove all listeners for a message.
		 * @param	pMessage : Message to delete all listeners from.
		 * @return : Total listener removed
		 */
		public function removeAll (pMessage:String):Boolean
		{
			// Vérifier la validité des paramètres
			if (pMessage == null || pMessage == "")
			{
				throw new SwappError("Central.removeAll", "Invalid message to remove.");
				return false;
			}
			
			// Vérifier si on a des handlers sur ce message
			if (pMessage in _listeners)
			{
				delete _listeners[pMessage];
				return true;
			}
			
			return false;
		}
		
		/**
		 * Remove an event
		 * @param	pMessage : Message to delete some listeners from
		 * @param	pEntity : Entity to delete
		 * @param	pEntityIndex : Index where to search entity
		 * @return : If a message was found and deleted
		 */
		protected function removeByEntity (pMessage:String, pEntity:*, pEntityIndex:uint):Boolean
		{
			// Vérifier si on a des handlers sur ce message
			if (pMessage in _listeners)
			{
				// Cibler les handlers
				var handlers:Array = _listeners[pMessage];
				
				// Le nouveau tableau des handlers de ce message
				var newHandlers:Array = [];
				
				// Si on a supprimé quelque chose
				var deleted:Boolean = false;
				
				// Les parcourir
				for (var i:* in handlers)
				{
					// Si on est sur l'entité a supprimer
					if (handlers[i][pEntityIndex] == pEntity)
					{
						// On supprime
						deleted = true;
					}
					else
					{
						// Sinon on ajoute
						newHandlers.push(handlers[i]);
					}
				}
				
				// Si on en a supprimé
				if (deleted)
				{
					// Si on a toujours dans handlers dans notre nouveau tableau
					if (newHandlers.length > 0)
					{
						// Replacer le nouveau tableau
						_listeners[pMessage] = newHandlers;
					}
					else
					{
						// Supprimer l'entrée du message
						delete this._listeners[pMessage];
					}
					
					// On a supprimé
					return true;
				}
			}
			
			// Rien supprimé
			return false;
		}
		
		/**
		 * Internal register message to handler
		 * @param	pMessage : Message name
		 * @param	pHandler : 
		 * @param	pOnce : 
		 * @return
		 */
		protected function register (pMessage:String, pHandler:Function, pOnce:Boolean):uint
		{
			// Vérifier qu'on ai un bon handler
			if (pHandler == null)
			{
				throw new SwappError("Central.register", "Invalid handler");
				return 0;
			}
			else
			{
				// Passer à l'id suivant
				_currentEventId ++;
				
				// Créer le tableau contenant les listeners s'il n'existe pas déjà
				if (!(pMessage in _listeners))
				{
					_listeners[pMessage] = [];
				}
				
				// Ajouter le handler et son scope
				_listeners[pMessage].push([pHandler, pOnce, _currentEventId]);
				
				// Retourner l'ID
				return _currentEventId;
			}
		}
	}
}

/**
 * Private key to secure singleton providing.
 */
internal class SingletonKey {}