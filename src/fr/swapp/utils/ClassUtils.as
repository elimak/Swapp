package fr.swapp.utils 
{
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
	}
}