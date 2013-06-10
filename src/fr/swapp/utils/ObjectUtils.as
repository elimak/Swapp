package fr.swapp.utils 
{
	import flash.utils.ByteArray;
	
	/**
	 * Classe utilitaire sur la gestion des objets.
	 * @author ZoulouX
	 */
	public class ObjectUtils
	{
		/**
		 * Ajouter toutes les propriétés de extra dans source.
		 * Peut être pratique pour ajouter rapidement des propriété à un objet fraichement instancié.
		 * ex: var monSprite:Sprite = ObjectUtils.extra(new MyDisplayObject(), {x:5, y:8, alpha:0.5}) as Sprite;
		 * NB: Pas de copie de propriété générée.
		 * NB2: Attention à ne pase utiliser une classe non explorable dans pExtra (aucune propriété non explorable ne sera copiée).
		 * @param	pSource : L'objet qui va recevoir les données
		 * @param	pExtra : L'objet qui contient les données
		 * @return : l'objet source agrémenté des propriétés de extra
		 */
		public static function extra (pSource:Object, pExtra:Object, pOverride:Boolean = true, pRecursive:Boolean = false):Object
		{
			// Déclarer la source null
			if (pSource == null)
				pSource = {};
			
			// Déclarer l'extra null
			if (pExtra == null)
				pExtra = {};
			
			// Parcourir extra
			for (var i:* in pExtra)
			{
				// Ajouter la propriété dans source
				if (pOverride || !(i in pSource) || pSource[i] == null || pSource[i] is Number)
				{
					// Si on n'est pas récursif ou pas sur un objet
					if (!pRecursive || typeof(pSource[i]) != "object")
					{
						// On ajoute
						pSource[i] = pExtra[i];
					}
					else
					{
						// Sinon on étend en récursif
						pSource[i] = extra(pSource[i], pExtra[i], pOverride, true);
					}
				}
			}
			
			// Retourner source
			return pSource;
		}
		
		
		/**
		 * Fait une "vrai" copie d'un objet.
		 * @param	pSource
		 * @return	Un objet clonné.
		 */
		public static function cloneObject (pSource:Object):Object
		{
			// Créer le ByteArray de copie
			var cloner:ByteArray = new ByteArray();
			
			// Ecrire l'objet en AMF
			cloner.writeObject(pSource);
			
			// Retourner au début
			cloner.position = 0;
			
			// Retourner l'objet AMF décodé, donc cloné
			return(cloner.readObject());
		}
	}
}