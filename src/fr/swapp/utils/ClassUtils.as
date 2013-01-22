package fr.swapp.utils 
{
	import flash.utils.getQualifiedClassName;
	/**
	 * Classe utilitaire sur les Classes
	 * @author ZoulouX
	 */
	public class ClassUtils
	{
		/**
		 * Récupérer le nom d'une classe rapidement, sans passer par describeType.
		 * @param	pClass : La classe
		 * @return : Le nom de la classe
		 */
		public static function getClassName (pClass:Class):String
		{
			// On cast la classe en string
			// Puis on y applique une regex pour garder que le nom du type le plus fort
			return /\s(.*)./.exec(String(pClass))[1];
		}
		
		/**
		 * Récupérer le nom d'une classe par une instance, sans passer par describeType.
		 * Si le nom de la classe est introuvable, un string vide sera retourné.
		 * @param	pObject : L'objet en question
		 * @return : Le nom de la classe
		 */
		public static function getClassNameFromInstance (pObject:Object):String
		{
			// Séparer le package du nom de classe
			var parts:Array = getQualifiedClassName(pObject).split("::");
			
			// Retrourné le nom de la classe si trouvé
			return parts.lenght == 0 ? "" : parts[parts.length - 1];
		}
	}
}