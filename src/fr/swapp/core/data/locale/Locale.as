package fr.swapp.core.data.locale
{
	import flash.system.Capabilities;
	import fr.swapp.core.errors.SwappError;
	import fr.swapp.core.log.Log;
	import fr.swapp.utils.ArrayUtils;
	import fr.swapp.utils.EmbedUtils;
	import fr.swapp.utils.ObjectUtils;
	import fr.swapp.utils.StringUtils;
	/**
	 * @author ZoulouX
	 */
	public class Locale
	{
		/**
		 * Config instance
		 */
		protected static var __instance					:Locale;
		
		/**
		 * Get a Config instance.
		 * @return : Config instance
		 */
		public static function getInstance ():Locale
		{
			// Si l'instance avec ce nom n'existe pas
			if (__instance == null)
			{
				// Créer l'instance
				new Locale(new SingletonKey());
			}
			
			// Retourner l'instance
			return __instance;
		}
		
		/**
		 * Get a text from current locale
		 * @param	pKey : The key to get the text. Can be dot syntaxed to get recursive content, like "Home.greetings".
		 * @param	pMustacheValues : Dynamic object containing data to map in the translated sentence (will use mustache like syntax).
		 * @return the translate text, if not found will return the key.
		 */
		public static function getText  (pKey:String, pMustacheValues:Object = null):String
		{
			return getInstance().getText(pKey, pMustacheValues);
		}
		
		/**
		 * All locale data with langCode in key and data in value
		 */
		protected var _data								:Object					= {};
		
		/**
		 * The current locale selected. If not found, it will use the default locale langCode
		 */
		protected var _currentLocale					:String;
		
		/**
		 * Default locale langCode if wanted locale is not found.
		 * Default is "EN"
		 */
		protected var _defaultLocaleLangCode			:String					= "EN";
		
		/**
		 * When strict mode is enabled, bad locale path will throw errors. Else it will show warning in console.
		 * Default is false.
		 */
		protected var _strict							:Boolean;
		
		
		/**
		 * The current locale selected. If not found, it will use the default locale langCode
		 */
		public function get currentLocale ():String { return _currentLocale; }
		public function set currentLocale (value:String):void
		{
			// Si la valeur est différente
			if (value != _currentLocale)
			{
				// Si la locale existe
				if (value in _data)
				{
					// On applique la nouvelle locale
					_currentLocale = value;
				}
				else if (_defaultLocaleLangCode in _data)
				{
					// On applique la locale par défaut
					_currentLocale = _defaultLocaleLangCode;
					
					// Afficher un warning
					Log.warning(value + " locale not found, using default locale " + _defaultLocaleLangCode);
				}
				else
				{
					// Afficher l'erreur
					var error:SwappError = new SwappError("Locale.currentLocale", "Invalid langCode or locale not loaded yet " + value);
					if (_strict) throw error else error.log();
				}
			}
		}
		
		/**
		 * When strict mode is enabled, bad locale path will throw errors. Else it will show warning in console.
		 * Default is false.
		 */
		public function get strict ():Boolean { return _strict; }
		public function set strict (value:Boolean):void
		{
			_strict = value;
		}
		
		/**
		 * Default locale langCode if wanted locale is not found.
		 * Default is "EN"
		 */
		public function get defaultLocaleLangCode ():String { return _defaultLocaleLangCode; }
		public function set defaultLocaleLangCode (value:String):void
		{
			_defaultLocaleLangCode = value;
		}
		
		
		/**
		 * Constructor
		 */
		public function Locale (pSingletonKey:SingletonKey)
		{
			// Vérifier la création du singleton
			if (pSingletonKey == null)
			{
				throw new SwappError("Locale.constructor", "Direct instancations are not allowed, please use Locale.getInstance instead.");
			}
			else
			{
				// Enregistrer la référence
				__instance = this;
			}
		}
		
		
		/**
		 * Add locale
		 * @param	pLangCode : The langcode of the added locale
		 * @param	pXMLClass : The data of the added locale (in embedded XML class format)
		 */
		public function addLocaleData (pLangCode:String, pXMLClass:Class):void
		{
			// Convertir la classe en XML et l'ajouter au data
			_data[pLangCode] = EmbedUtils.getXML(pXMLClass);
		}
		
		/**
		 * Set all locale data in one call.
		 * @param	pData : Locale data to store. Use langCode in key, and XML class in value.
		 */
		public function setLocaleData (pData:Object):void
		{
			// Parcourir les données
			for (var langCode:String in pData)
			{
				// Si la valeur n'est pas une classe
				if (!(pData[langCode] is Class))
				{
					// On déclanche une erreur
					throw new SwappError("Locale.setLocaleData", "pData values have to be XML classes. (Use embed metakeyword to embed your XML locale data)");
					break;
				}
				else
				{
					// Ajouter cette locale
					addLocaleData(langCode, pData[langCode] as Class);
				}
			}
		}
		
		/**
		 * Get available locale langCodes.
		 * @return All available langCodes in array.
		 */
		public function getAvailableLocales ():Array
		{
			return ArrayUtils.getKeys(_data);
		}
		
		/**
		 * Check if a key exist in the current locale
		 * @param	pKey : The key to check. Can be dot syntaxed to get recursive content, like "Home.greetings".
		 * @return if the key was found
		 */
		public function checkKey (pKey:String):Boolean
		{
			// Si la locale est introuvable
			if (!(_currentLocale in _data))
			{
				return false;
			}
			else
			{
				return (ObjectUtils.getPath(_data[_currentLocale], pKey, _strict) != null);
			}
		}
		
		/**
		 * Get a text from current locale
		 * @param	pKey : The key to get the text. Can be dot syntaxed to get recursive content, like "Home.greetings".
		 * @param	pMustacheValues : Dynamic object containing data to map in the translated sentence (will use mustache like syntax).
		 * @return the translate text, if not found will return the key.
		 */
		public function getText (pKey:String, pMustacheValues:Object = null):String
		{
			// Récupérer la valeur de ce texte
			var value:Object = ObjectUtils.getPath(_data[_currentLocale], pKey, _strict);
			
			// Si c'est null
			if (value == null)
			{
				// On retourne le nom de la clé
				return pKey;
			}
			
			// Si c'est un nombre
			else if (value is Number)
			{
				// On le passe en string
				return (value as Number).toString(10);
			}
			
			// Sinon on tente une conversion
			else
			{
				// Si on a des données
				if (pMustacheValues != null)
				{
					// On converti le mustache
					return StringUtils.quickMustache(String(value), pMustacheValues);
				}
				else
				{
					return String(value);
				}
			}
		}
	}
}

/**
 * Private key to secure singleton providing.
 */
internal class SingletonKey {}