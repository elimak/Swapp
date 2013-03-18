package fr.swapp.utils 
{
	/**
	 * Classe utilitaire de gestion des dates et de leurs affichages.
	 * @author ZoulouX
	 */
	public class DateUtils
	{
		/**
		 * Available languages
		 */
		public static const FR					:String				= "FR";
		public static const EN					:String				= "EN";
		
		/**
		 * Days names, starting with "Sunday" (can be overrided without using setLangCode)
		 */
		public static var DAYS_NAMES			:Vector.<String>;
		
		/**
		 * Months names (can be overrided without using setLangCode)
		 */
		public static var MONTHS_NAMES			:Vector.<String>;
		
		/**
		 * Current used language (can be overrided without using setLangCode)
		 */
		public static var currentLang			:String;
		
		
		/**
		 * Set the lang code to use.
		 */
		public static function setLangCode (pLangCode:String):void
		{
			// Si c'est différent
			if (currentLang != pLangCode)
			{
				if (pLangCode == FR)
				{
					DAYS_NAMES = Vector.<String>([
						"Dimanche",
						"Lundi",
						"Mardi",
						"Mercredi",
						"Jeudi",
						"Vendredi",
						"Samedi"
					]);
					MONTHS_NAMES = Vector.<String>([
						"Janvier",
						"Février",
						"Mars",
						"Avril",
						"Mai",
						"Juin",
						"Juiller",
						"Août",
						"Septembre",
						"Octobre",
						"Novembre",
						"Décembre"
					]);
				}
				else if (pLangCode == EN)
				{
					DAYS_NAMES = Vector.<String>([
						"Sunday",
						"Monday",
						"Tuesday",
						"Wednesday",
						"Thursday",
						"Friday",
						"Saturday"
					]);
					MONTHS_NAMES = Vector.<String>([
						"Janary",
						"February",
						"March",
						"April",
						"May",
						"June",
						"July",
						"August",
						"September",
						"October",
						"November",
						"December"
					]);
				}
				else
				{
					throw new SwappUtilsError("DateUtils.setLangCode", "Unable to find language code " + pLangCode);
					return;
				}
				
				// Enregistrer
				currentLang = pLangCode;
			}
		}
		
		/**
		 * Compter le temps entre 2 dates.
		 * Opération effectuée : dateA - dateB
		 * @param	pDateA : La première date de la soustraction
		 * @param	pDateB : La seconde date de la soustraction
		 * @return : la différence entre dateA et dateB
		 */
		public static function difDate (pDateA:Date, pDateB:Date):Date
		{
			// TODO : difDate
			return null;
		}
		
		/**
		 * Transformer un objet date en date lisible, en suivant un template.
		 * Le template est un string, pouvant contenir les instructions suivantes:
		 * [FULL_YEAR] : L'année complète (ex: 1988)
		 * [YEAR] : La décénie (ex: 88)
		 * [MONTH] : Le nom du mois (ex: Octobre)
		 * [MONTH_NUMBER] : Le numéro du mois, en commençant par 1 (ex: 10)
		 * [DAY] : Le nom du jour (ex: Dimanche)
		 * [DATE] : Le numéro du jour (ex: 31)
		 * [AFTER_DATE] : Après le numéro du jour, (ex: "ème" pour le jour n°3 -> 3ème)
		 * [HOUR] : L'heure au format 24h (ex: "01" pour 1h du matin, "13" pour 1h de l'après midi)
		 * [HOUR_12] : L'heure au format 12h (ex: "01" pour 1h du matin, "01" pour 1h de l'après midi)
		 * [AM_PM] : Afficher AM ou PM
		 * [MINUTE] : Afficher les minutes (ex: 05)
		 * [SECOND] : Afficher les secondes (ex: 06)
		 * [CENT] : Afficher les centièmes de secondes (ex: 04)
		 * [MS] : Afficher les millisecondes (ex: 043)
		 * @param	pDate : La date à afficher
		 * @param	pTemplate : Le template à suivre, (ex: "Nous sommes le [DATE] [MONTH] [FULL_YEAR]")
		 * @return : Le template transformé avec la date
		 */
		public static function dateToString (pDate:Date, pTemplate:String):String
		{
			// TODO : Afficher une date complète en string
			// TODO : Rendre compatible avec le moteur de traduction
			return "";
		}
		
		/**
		 * Afficher un temps relatif en date lisible.
		 * Ex: "il y a 5 minutes"
		 * @param	pDate : La date à afficher
		 * @return : Le date relative lisible
		 */
		public static function datDifToString (pDate:Date):String
		{
			// TODO : Méthode helper pour afficher des messages du genre "Il y a 10 minutes" ou "Il y a une semaine"
			return "";
		}
	}
}