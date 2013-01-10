package fr.swapp.core.data.remote 
{
	/**
	 * Les imports
	 */
	import fr.swapp.core.log.Log;
	
	/**
	 * Récupération de données depuis un fichier/service XML via HTTP
	 * @author ZoulouX
	 */
	public class XMLRemote extends HTTPRemote
	{
		/**
		 * Le constructeur
		 */
		public function XMLRemote ()
		{
			
		}
		
		/**
		 * Préparer les données pour le parse
		 * @param	pData : Les données brutes
		 * @return : Les données préparées
		 */
		override protected function prepareData (pData:*):*
		{
			try
			{
				// Convertir les données
				return new XML(pData);
			}
			catch (e:Error)
			{
				// Déclancher une erreur
				Log.warning("TODO : PREPARE XML ERROR");
				_onError.dispatch();
			}
			
			// Retourner les données
			return pData;
		}
	}
}