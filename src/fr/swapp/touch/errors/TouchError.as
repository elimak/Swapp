package fr.swapp.touch.errors 
{
	/**
	 * Une erreur interne au niveau du framework touch
	 * @author ZoulouX
	 */
	public class TouchError extends Error 
	{
		/**
		 * déclencher une erreur d'exécution du framework graphique
		 * @param	pMethod : Le nom de la classe et de la méthode sous cette forme : "MyClass.myMethod"
		 * @param	pMessage : Le message associé à l'erreur
		 * @param	pId : L'id du message
		 */
		public function TouchError (pMethod:String, pMessage:String, pId:uint = 0)
		{
			// Afficher l'erreur
			super("# Touch error in " + pMethod + " : " + pMessage + "\n" + getStackTrace(), pId);
		}
	}
}