<<<<<<< HEAD
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
		protected static var __instance:Central;
		
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
		 * Private constructor. Please use Central.getInstance to create a new instance of Central.
		 */
		public function Central (pInstanciationKey:SingletonKey)
		{
			if (pInstanciationKey == null)
			{
				throw new SwappError("Central.constructor", "Direct instancation not allowed, please use Central.getInstance instead.");
			}
		}
		
		/**
		 * Listen for a message
		 * @param	pMessage : Message name, usually like "theme:messagename"
		 * @param	pHandler : Handler to respond to the message.
		 * @param	pArguments : Arguments added after the message arguments
		 * @return : Listening ID for removeing listening.
		 */
		public function listen (pMessage:String, pHandler:Function, pArguments...):uint
		{
			
		}
		
		/**
		 * Listen for a message, one time.
		 * @param	pMessage : Message name, usually like "theme:messagename"
		 * @param	pHandler : Handler to respond to the message.
		 * @param	pArguments : Arguments added after the message arguments
		 * @return : Listening ID for removeing listening.
		 */
		public function listenOnce (pMessage:String, pHandler:Function, pArguments...):uint
		{
			
		}
		
		/**
		 * Dispatch a message to all listening parts.
		 * @param	pMessage : Message to dispatch
		 * @param	pArguments : Arguments added to the handler after the message.
		 * @return : Total of handler responding.
		 */
		public function dispatch (pMessage:String, pArguments...):uint
		{
			
		}
		
		/**
		 * Remove a listening for an handler
		 * @param	pMessage : Message to remove
		 * @param	pHandler : Handler
		 * @return : If listening handler was found and removed.
		 */
		public function remove (pMessage:String, pHandler:Function):Boolean
		{
			
		}
		
		/**
		 * Remove listener by listening id.
		 * @param	pId : Listener id to remove
		 * @param	pMessage : Will be faster if provided
		 * @return : If listener id was found.
		 */
		public function removeById (pId:uint, pMessage:String):Boolean
		{
			
		}
		
		/**
		 * Remove all listeners for a message.
		 * @param	pMessage : Message to delete all listeners from.
		 * @return : Total listener removed
		 */
		public function removeAll (pMessage:String):uint
		{
			
		}
		
		
		protected function removeByEntity ():void
		{
			
		}
		
		protected function register ():void
		{
			
		}
	}
}

/**
 * Private key to secure singleton providing.
 */
=======
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
		protected static var __instance:Central;
		
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
		 * Private constructor. Please use Central.getInstance to create a new instance of Central.
		 */
		public function Central (pInstanciationKey:SingletonKey)
		{
			if (pInstanciationKey == null)
			{
				throw new SwappError("Central.constructor", "Direct instancation not allowed, please use Central.getInstance instead.");
			}
		}
		
		/**
		 * Listen for a message
		 * @param	pMessage : Message name, usually like "theme:messagename"
		 * @param	pHandler : Handler to respond to the message.
		 * @param	pArguments : Arguments added after the message arguments
		 * @return : Listening ID for removeing listening.
		 */
		public function listen (pMessage:String, pHandler:Function, pArguments...):uint
		{
			
		}
		
		/**
		 * Listen for a message, one time.
		 * @param	pMessage : Message name, usually like "theme:messagename"
		 * @param	pHandler : Handler to respond to the message.
		 * @param	pArguments : Arguments added after the message arguments
		 * @return : Listening ID for removeing listening.
		 */
		public function listenOnce (pMessage:String, pHandler:Function, pArguments...):uint
		{
			
		}
		
		/**
		 * Dispatch a message to all listening parts.
		 * @param	pMessage : Message to dispatch
		 * @param	pArguments : Arguments added to the handler after the message.
		 * @return : Total of handler responding.
		 */
		public function dispatch (pMessage:String, pArguments...):uint
		{
			
		}
		
		/**
		 * Remove a listening for an handler
		 * @param	pMessage : Message to remove
		 * @param	pHandler : Handler
		 * @return : If listening handler was found and removed.
		 */
		public function remove (pMessage:String, pHandler:Function):Boolean
		{
			
		}
		
		/**
		 * Remove listener by listening id.
		 * @param	pId : Listener id to remove
		 * @param	pMessage : Will be faster if provided
		 * @return : If listener id was found.
		 */
		public function removeById (pId:uint, pMessage:String):Boolean
		{
			
		}
		
		/**
		 * Remove all listeners for a message.
		 * @param	pMessage : Message to delete all listeners from.
		 * @return : Total listener removed
		 */
		public function removeAll (pMessage:String):uint
		{
			
		}
		
		
		protected function removeByEntity ():void
		{
			
		}
		
		protected function register ():void
		{
			
		}
	}
}

/**
 * Private key to secure singleton providing.
 */
>>>>>>> Refactoring
internal class SingletonKey {}