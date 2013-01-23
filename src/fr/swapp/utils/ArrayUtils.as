package fr.swapp.utils 
{
	/**
	 * Librairie utilitaire pour faciliter les manipulations sur les tableaux
	 * @author ZoulouX
	 */
	public class ArrayUtils
	{
		/**
		 * Vérifier si un élément est présent dans un tableau
		 * @param	pArray : Le tableau en question
		 * @param	pElement : La valeur recherche
		 * @return : true si l'élément à été trouvé
		 */
		public static function contains (pArray:Array, pElement:*):Boolean
		{
			// Mesurer le tableau
			var total:uint = pArray.length;
			
			// Parcourir le tableau
			for (var i:int = 0; i < total; i++)
			{
				// Si on trouve l'élément on retourne true
				if (pArray[i] == pElement)
					return true;
			}
			
			// On l'a pas trouvé
			return false;
		}
		
		/**
		 * Vérifier si un tableau contient bien un certain index
		 * @param	pArray : Le tableau à traiter
		 * @param	pIndex : L'index à vérifer
		 * @return : true si l'index à été trouvé
		 */
		public static function indexExists (pArray:Array, pIndex:uint):Boolean
		{
			// Simplement retourner si l'élément associé à l'index est nul
			return pArray[pIndex] != null;
		}
		
		/**
		 * Insérer un élément à un index précis
		 * @param	pArray : Le tableau qui va contenir l'élément
		 * @param	pElement : L'élément en question
		 * @param	pIndex : La position de l'élément dans le vecteur
		 * @return : Le tableau avec l'élément inséré
		 */
		public static function insertAt (pArray:Array, pElement:*, pIndex:uint = 0):Array
		{
			// Mesurer le tableau
			var total:uint = pArray.length;
			
			// Créer le nouveau tableau de sortie
			var newTab:Array = [];
			
			// Vérifier que l'index est correct par rapport à la taille
			// Sinon, on déclenche une erreur
			if (pIndex <= total || total)
			{
				// Boucler avec une itération de plus
				for (var i:int = 0; i < total + 1; i++) 
				{
					// Si on est sur l'index, on ajoute l'élément passé en paramètre
					// Sinon ajouter simplement depuis le tableau passé en paramètre
					if (i == pIndex)
						newTab[newTab.length] = pElement;
					else if (i > pIndex)
						newTab[newTab.length] = pArray[i - 1];
					else
						newTab[newTab.length] = pArray[i];
				}
			}
			else
			{
				// déclencher l'erreur
				throw new SwappUtilsError("ArrayUtils.insertAt", "pIndex is out of bounds.");
			}
			
			// Retourner le nouveau tableau
			return newTab;
		}
		
		/**
		 * Effacer un élément dans un tableau
		 * @param	pArray : Le tableau à traiter
		 * @param	pElement : La référence vers l'élément à supprimer
		 * @return : Le tableau avec l'élément en moins si l'élément à été trouvé
		 */
		public static function deleteElement (pArray:Array, pElement:*):Array
		{
			// Créer le nouveau tableau
			var newTab:Array = [];
			
			// Mesurer le tableau
			var total:uint = pArray.length;
			
			// Parcourir le tableau
			for (var i:int = 0; i < total; i++) 
			{
				// Si c'est pas l'élément en question, on ajoute au nouveau tableau
				if (pArray[i] != pElement)
					newTab[newTab.length] = pArray[i];
			}
			
			// Retourner le nouveau tableau sans l'élément
			return newTab;
		}
		
		/**
		 * Effacer un index dans un tableau
		 * @param	pArray : Le tableau à traiter
		 * @param	pIndex : L'index à supprimer du tableau
		 * @return : Le tableau avec l'élément en moins si son index à été trouvé
		 */
		public static function deleteIndex (pArray:Array, pIndex:uint):Array
		{
			// Créer le nouveau tableau
			var newTab:Array = [];
			
			// Mesurer le tableau
			var total:uint = pArray.length;
			
			// Parcourir le tableau
			for (var i:int = 0; i < total; i++) 
			{
				// Ajouter dans le nouveau tableau si l'index n'est pas celui à enlever
				if (i != pIndex)
					newTab[newTab.length] = pArray[i];
			}
			
			// Retourner le nouveau tableau sans l'élément
			return newTab;
		}
		
		/**
		 * Copier un tableau indéxé, en gardant les références des objets qu'il contient.
		 * @param	pArray : Le tableau à copier
		 * @return : Son clone
		 */
		public static function copy (pArray:Array):Array
		{
			// Créer le nouveau tableau
			var newTab:Array = [];
			
			// Mesurer le tableau
			var total:uint = pArray.length;
			
			// Parcourir le tableau passé en paramètres
			for (var i:int = 0; i < total; i++) 
			{
				// Ajouter chaque référence
				newTab[i] = pArray[i];
			}
			
			// Retourner le cloné du tableau
			return newTab;
		}
		
		/**
		 * Récupérer les clés d'un tableau
		 */
		public static function getKeys (pArray:Array):Array
		{
			// Créer le tableau de sortie
			var out:Array = [];
			
			// Parcourir les tableau d'entrée par clé
			for (var i:* in pArray)
			{
				// Ajouter chaque clé au tableau de sortie
				out.push(i);
			}
			
			// Retourner le tableau de sortie
			return out;
		}
	}
}