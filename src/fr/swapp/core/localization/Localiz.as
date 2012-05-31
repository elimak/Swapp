/*
  Copyright (c) 2009, La Haute Société (http://www.lahautesociete.com).
  All rights reserved.
*/

package fr.swapp.core.localization 
{   
	import flash.utils.Dictionary;
	import fr.swapp.core.data.remote.IRemote;
	import fr.swapp.core.data.remote.RemotingCall;
	import fr.swapp.core.log.Log;
	import org.osflash.signals.Signal;
	
	/**
	 * Permet de gérer le contenu textuel de l'application en fonction des langes.
	 * @author Pascal Achard
	 * @since 24/02/2012 13:31
	 * 
	 * Pour le moment, le chemin (URL) vers le fichier de localisation est en static.
	 * ex : "locale/locale_fr.json"
	 * A terme, il faudrait qu'on puisse le changer à l'execution.
	 */
	
	public class Localiz
	{
		
		// PROPERTIES
		// ----------------------------------------
		
		public static const DEFAULT_LOCALE_PATH:String 	= "locale/";
		public static const DEFAULT_FILE_NAME:String 	= "locale_";
		//public static const DEFAULT_LANG:Lang			= Lang.FR;
		public static const DEFAULT_SUFFIX:String 		= ".json";
		
		
		
		/**
		 * La langue courrante.
		 */
		private var _currentLang:Lang;
		
		/**
		 * La locale courrante.
		 */
		private var _currentLocale:Locale;
		
		/**
		 * Le dico qui contient les données de chaque langues.
		 */
		private var _dict:Dictionary;
		
		/**
		 * La remote.
		 */
		private var _remote:IRemote;
		
		/**
		 * Le chemin.
		 */
		private var _localPath:String;
		
		/**
		 * Le nom de fichier.
		 */
		private var _fileName:String;
		
		/**
		 * Le suffix.
		 */
		private var _suffix:String;
		
		
		/**
		 * Singleton instance
		 */
		private static var _instance:Localiz;
		
		/**
		 * On peut instancier ?
		 */
		static private var _allowInstantiation:Boolean;
		
		// Le signal sur le changement de localisaiton.
		public var onChange:Signal;
		
		
		
		
		
		
		// GETTERS/SETTERS
		// ----------------------------------------
		
		/**
		 * Récupère/Affecte la langue courrante.
		 */
		public function get lang():Lang 
		{
			return _currentLang;
		}		
		public function set lang(value:Lang):void 
		{
			// Si c'est la même langue, on sort.
			if (_currentLang == value) return;
			
			// On stocke la nouvelle langue courrante.
			_currentLang = value;
			
			// On vérifie si on a déjà les données dans le dico.
			if (_dict[_currentLang])
			{
				// Les données sont là.
				// On notifie le changement.
				notifyChange();
				
			} else
			{
				// Les données ne sont pas là, on les charge.
				loadLang(_currentLang);
			}	
		}
		

		/**
		 * Retourne la locale courrante.
		 */
		public function get locale():Locale 
		{
			return getLocaleByLang(_currentLang);
		}
		
		
		
		public function get remote():IRemote 
		{
			return _remote;
		}
		
		public function set remote(value:IRemote):void 
		{
			_remote = value;
		}
		
		public function get localPath():String 
		{
			return _localPath;
		}
		
		public function set localPath(value:String):void 
		{
			_localPath = value;
		}
		
		public function get fileName():String 
		{
			return _fileName;
		}
		
		public function set fileName(value:String):void 
		{
			_fileName = value;
		}
		
		public function get suffix():String 
		{
			return _suffix;
		}
		
		public function set suffix(value:String):void 
		{
			_suffix = value;
		}
		
		
		
		// SINGLETON CONSTRUCTOR
		// ----------------------------------------
		public function Localiz()
		{
			// On créer le dictionnaire qui contient les Lang.
			_dict = new Dictionary();
			
			// Les params par défaut.
			_localPath = DEFAULT_LOCALE_PATH;
			_fileName = DEFAULT_FILE_NAME;
			_suffix = DEFAULT_SUFFIX;
			
			// Les signaux.
			setupSignals();
			
			if (!_allowInstantiation) {
				throw new Error("Error: Instantiation failed: Use Singleton.getInstance() instead of new.");
			}
		}
		
		// SINGLETON CONSTRUCTOR METHOD
		public static function getInstance():Localiz 
		{
			if(Localiz._instance == null) 
			{
				_allowInstantiation = true;
				_instance = new Localiz();
				_allowInstantiation = false;
			}
			return Localiz._instance;
		}
		
		
		public static function get locale():Locale 
		{
			return Localiz._instance.locale;
		}
		
		
		
		// METHODS
		// ----------------------------------------
		
		/**
		 * Retourne l'objet dynamique (Locale) en fonction de la langue passée.
		 */
		public function getLocaleByLang(pLang:Lang):Locale 
		{
			// On retourne la locale.
			return _dict[pLang] || null;
		}
		
		
		/**
		 * Ajout d'une Locale avec sa Lang.
		 * @param	pLang
		 * @param	pData
		 */
		public function add(pLang:Lang, pData:*):void 
		{
			// Si le code ISO de la lang est déjà présent dans le dico, on passe.
			for (var key:Object in _dict) {
				var lang:Lang = key as Lang;
				if (lang.isoCode == pLang.isoCode)
				{
					trace("La langue : " + pLang.isoCode + " est déjà présente");
					return;
				}
			}
			
			// On transforme pData en Locale.
			var locale:Locale = new Locale(pData);
			
			// On stocke dans le dico la locale avec en clé la langue.
			_dict[pLang] = locale;
			
		}
		
		/**
		 * Notifie le changement de langue.
		 */
		public function notifyChange():void 
		{
			// On dispatche le signal.
			onChange.dispatch();
		}
		
		/**
		 * Charge les données.
		 */
		private function loadLang(pLang:Lang):void 
		{
			
			if (!_remote)
			{
				throw new Error("La remote n'est pas définie !");
			}			
			
			var url:String = Localiz.DEFAULT_LOCALE_PATH + Localiz.DEFAULT_FILE_NAME + lang.isoCode + Localiz.DEFAULT_SUFFIX;
			
			_remote.call(url, {
				onSuccess: function (pCall:RemotingCall):void
				{
					Log.notice("Fichier de localisation chargé : " + url);
					add(lang, pCall.data);
					
					// On notifie le changement.
					notifyChange();
				},
				onError:function ():void 
				{
					Log.error("Impossible de charger le fichier : " + url);
				}
			});
		}
		
		/**
		 * Configure les signaux.
		 */
		private function setupSignals ():void 
		{
			onChange = new Signal();
		}
	}
}
