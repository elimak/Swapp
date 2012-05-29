package fr.swapp.utils 
{
	/**
	 * Classe utilitaire dédiée aux Slugs (plus dans String)
	 * @author ZoulouX
	 */
	public class SlugUtils 
	{
		/**
		 * Table de remplacement des caractères pour la conversion en slug.
		 * A gauche le caractère après, a droite le caractère avant remplacement.
		 */
		public static const SLUG_REPLACE_PATTERN:Array = [
			["C", new RegExp("Ç", "g")],
			["c", new RegExp("ç", "g")],
			["u", new RegExp("[üûúù]", "g")],
			["e", new RegExp("[éêëè]", "g")],
			["a", new RegExp("[âäàåá]", "g")],
			["i", new RegExp("[ïîìí]", "g")],
			["A", new RegExp("[ÄÅ]", "g")],
			["E", new RegExp("É", "g")],
			["ae", new RegExp("æ", "g")],
			["Ae", new RegExp("Æ", "g")],
			["o", new RegExp("[ôöòó]", "g")],
			["U", new RegExp("Ü", "g")],
			["y", new RegExp("ÿ", "g")],
			["O", new RegExp("Ö", "g")],
			["n", new RegExp("ñ", "g")],
			["N", new RegExp("Ñ", "g")],
			["-", new RegExp("[^a-zA-Z0-9]", "g")], 	// On converti tout ce qui n'est pas alphanum en tiret
			["-", new RegExp("[-\t\r\n]+", "g")], 		// On supprime les tirets multiples, les espaces et les sauts
			["", new RegExp("^[-]|[-]$", "g")] 			// On enlève les tirets du début et de la fin
		]
		
		
		/**
		 * Transformer une string en slug
		 * @param	pValue : Le strnig à convertir
		 * @return : la version encodée
		 */
		public static function slugify (pValue:String):String
		{
			// Mesurer
			var total:uint = SLUG_REPLACE_PATTERN.length; 
			var i:uint;
			
			// On exécute toute les règles
			for (i = 0; i < total; i++)
			{
				pValue = pValue.replace(SLUG_REPLACE_PATTERN[i][1], SLUG_REPLACE_PATTERN[i][0]);
			}
			
			// Et on retourne en minuscule
			return pValue.toLowerCase();
		}
		
		/**
		 * Nétoyer une regex des métacaractères
		 * @param	pRule : Le string de la regex à nétoyer
		 */
		public static function cleanRule (pRule:String):String
		{
			// Le slash en premier!
			pRule = pRule.replace(/[\\]/g, "\\"+"\\");
			
			// Remplacer les caractères échapables
			pRule = pRule.replace(/[\^]/g, "\\"+"^");
			pRule = pRule.replace(/[\$]/g, "\\"+"$");
			pRule = pRule.replace(/[\.]/g, "\\"+".");
			pRule = pRule.replace(/[\*]/g, "\\"+"*");
			pRule = pRule.replace(/[\+]/g, "\\"+"+");
			pRule = pRule.replace(/[\?]/g, "\\"+"?");
			pRule = pRule.replace(/[\|]/g, "\\"+"|");
			pRule = pRule.replace(/[\<]/g, "\\"+"<");
			pRule = pRule.replace(/[\>]/g, "\\"+">");
			pRule = pRule.replace(/[\(]/g, "\\"+"(");
			pRule = pRule.replace(/[\)]/g, "\\"+")");
			pRule = pRule.replace(/[\[]/g, "\\"+"[");
			pRule = pRule.replace(/[\]]/g, "\\"+"]");
			pRule = pRule.replace(/[\{]/g, "\\"+"{");
			pRule = pRule.replace(/[\}]/g, "\\"+"}");
			
			// On retourne
			return pRule;
		}
	}
}