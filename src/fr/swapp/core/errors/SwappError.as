package fr.swapp.core.errors 
{
	/**
	 * Une erreur interne au core du framework Swapp
	 * @author ZoulouX
	 */
	public class SwappError extends Error 
	{
		/**
		 * Déclancher une erreur d'exécution du framework Swapp
		 * @param	pMethod : Le nom de la classe et de la méthode sous cette forme : "MyClass.myMethod"
		 * @param	pMessage : Le message associé à l'erreur
		 * @param	pId : L'id du message
		 */
		public function SwappError (pMethod:String, pMessage:String, pId:uint = 0)
		{
			// Récupérer la stack d'erreur
			var stack:String = getStackTrace();
			
			// Afficher l'erreur
			super("# Internal error in " + pMethod + " : " + pMessage, pId);
		}
	}
}