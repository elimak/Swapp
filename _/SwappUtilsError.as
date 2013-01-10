package fr.swapp.utils 
{
	/**
	 * Erreur interne aux utilitaires
	 * @author ZoulouX
	 */
	public class SwappUtilsError extends Error 
	{
		/**
		 * Déclancher une erreur interne aux utilitaires du framework Swapp
		 * @param	pMethod : Le nom de la classe et de la méthode sous cette forme : "MyClass.myMethod"
		 * @param	pMessage : Le message associé à l'erreur
		 * @param	pId : L'id du message
		 */
		public function SwappUtilsError (pMethod:String, pMessage:String, pId:uint = 0)
		{
			// Afficher l'erreur
			super("# Utils error in " + pMethod + " : " + pMessage + "\n" + getStackTrace(), pId);
		}
	}
}