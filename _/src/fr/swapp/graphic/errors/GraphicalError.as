package fr.swapp.graphic.errors 
{
	/**
	 * Une erreur interne au niveau du framework graphique
	 * @author ZoulouX
	 */
	public class GraphicalError extends Error 
	{
		/**
		 * Déclancher une erreur d'exécution du framework graphique
		 * @param	pMethod : Le nom de la classe et de la méthode sous cette forme : "MyClass.myMethod"
		 * @param	pMessage : Le message associé à l'erreur
		 * @param	pId : L'id du message
		 */
		public function GraphicalError (pMethod:String, pMessage:String, pId:uint = 0)
		{
			// Afficher l'erreur
			super("# Graphical error in " + pMethod + " : " + pMessage + "\n" + getStackTrace(), pId);
		}
	}
}