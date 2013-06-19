package fr.swapp.core.data.config
{
	import fr.swapp.core.errors.SwappError;
	import fr.swapp.utils.ObjectUtils;
	
	/**
	 * @author ZoulouX
	 */
	public class Config
	{
		/**
		 * Available environments
		 */
		public static const TEST_ENVIRONMENT			:String				= "test";
		public static const DEBUG_ENVIRONMENT			:String				= "debug";
		public static const PRODUCTION_ENVIRONMENT		:String				= "production";
		
		/**
		 * Config instance
		 */
		protected static var __instance					:Config;
		
		/**
		 * Get a Config instance.
		 * @return : Config instance
		 */
		public static function getInstance ():Config
		{
			// Si l'instance avec ce nom n'existe pas
			if (__instance == null)
			{
				// Créer l'instance
				new Config(new SingletonKey());
			}
			
			// Retourner l'instance
			return __instance;
		}
		
		
		/**
		 * Current environment
		 */
		protected var _currentEnvironment				:String;
		
		/**
		 * Global environment variables
		 */
		protected var _global							:Object				= { };
		
		/**
		 * Test environment variables
		 */
		protected var _test								:Object				= { };
		
		/**
		 * Debug environment variables
		 */
		protected var _debug							:Object				= { };
		
		/**
		 * Production environment variables
		 */
		protected var _production						:Object				= { };
		
		/**
		 * Computed vars with selected environment
		 */
		protected var _vars								:Object;
		
		
		/**
		 * Current environment
		 */
		public function get currentEnvironment ():String { return _currentEnvironment; }
		public function set currentEnvironment (pValue:String):void
		{
			// Si c'est la première fois qu'on le défini
			if (_currentEnvironment == null)
			{
				// Enregistrer l'environnement
				_currentEnvironment = pValue;
				
				// Calculer les variables d'environnement
				computeEnvironmentVars();
			}
			else
			{
				// Déclancher une erreur
				throw new SwappError("Config.currentEnvironment", "Current environment can't be changed in application lifetime.");
			}
		}
		
		
		/**
		 * Global environment variables
		 */
		public function get global ():Object { return _global; }
		
		/**
		 * Test environment variables
		 */
		public function get test ():Object { return _test; }
		
		/**
		 * Debug environment variables
		 */
		public function get debug ():Object { return _debug; }
		
		/**
		 * Production environment variables
		 */
		public function get production ():Object { return _production; }
		
		/**
		 * Computed vars with selected environment
		 */
		public function get vars ():Object { return _vars; }
		
		
		/**
		 * Constructor
		 */
		public function Config (pSingletonKey:SingletonKey)
		{
			// Vérifier la création du singleton
			if (pSingletonKey == null)
			{
				throw new SwappError("Config.constructor", "Direct instancations are not allowed, please use Config.getInstance instead.");
			}
			else
			{
				// Enregistrer la référence
				__instance = this;
			}
		}
		
		
		/**
		 * Compte environment vars when environment is selected.
		 * Environment vars will herit from global and the selected environment will override properties.
		 */
		protected function computeEnvironmentVars ():void
		{
			// Copier l'objet global
			var globalClone:Object = ObjectUtils.extra({}, _global);
			
			// Si on est en environnement de test
			if (_currentEnvironment == TEST_ENVIRONMENT)
			{
				// Enregistrer les valeurs de global et test
				_vars = ObjectUtils.extra(globalClone, _test);
			}
			
			// Si on est en environnement de debug
			else if (_currentEnvironment == DEBUG_ENVIRONMENT)
			{
				// Enregistrer les valeurs de global et debug
				_vars = ObjectUtils.extra(globalClone, _debug);
			}
			
			// Si on est en environnement de production
			else if (_currentEnvironment == PRODUCTION_ENVIRONMENT)
			{
				// Enregistrer les valeurs de global et production
				_vars = ObjectUtils.extra(globalClone, _production);
			}
			
			// Cet environnement n'existe pas
			else
			{
				// Signaler l'erreur
				throw new SwappError("Config.computeEnvironmentVars", "Incorrect environment setted. See statics for accepted values.");
			}
		}
	}
}

/**
 * Private key to secure singleton providing.
 */
internal class SingletonKey {}