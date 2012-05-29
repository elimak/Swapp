package fr.swapp.core.localization 
{
	/**
	 * Enumération des langues (non exhaustive) réprésentés par leur code ISO 639-1
	 * @author Pascal Achard
	 * @since 24/02/2012 11:42
	 */
	
	//TODO: Stocker les Langs dans un dico. Methodes static d'acces à un pays ( get(pIso:string) );
	//TODO: Possibilité d'ajouter facilement une langue.
	 
	public class Lang 
	{
		/**
		 * Le code iso du pays.
		 */
		private var _isoCode:String;
		
		/**
		 * La label de la langue.
		 */
		private var _label:String;
		
		/**
		 * Retourne le code ISO.
		 */
		public function get isoCode():String 
		{
			return _isoCode;
		}
		
		/**
		 * Retourne le label de la langue.
		 */
		public function get label():String 
		{
			return _label;
		}
		
		/**
		 * Constructeur.
		 * @param	pIsoCode	Le code ISO 639-1 du pays.
		 * @param	pLabel		Le nom de lang.
		 */
		public function Lang(pIsoCode:String, pLabel:String) 
		{
			// On stock les valeurs.
			_isoCode = pIsoCode;
			_label = pLabel;
		}
		
		/**
		 * French
		 */
		public static const FR:Lang = new Lang("fr", "french");
		
		/**
		 * English
		 */
		public static const EN:Lang = new Lang("en", "English");
		
		/**
		 * German
		 */
		public static const DE:Lang = new Lang("de", "German");
		
		
		
		public function toString():String 
		{
			return "ISO: " + _isoCode + " Label: " + _label;
		}
		
		
	}

}