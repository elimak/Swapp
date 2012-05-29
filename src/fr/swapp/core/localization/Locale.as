package fr.swapp.core.localization 
{
	import fr.swapp.utils.ObjectUtils;
	/**
	 * Objet dynamique contenant les données de localisation.
	 * @author Pascal Achard
	 */
	
	public dynamic class Locale 
	{
		
		/**
		 * Constructeur.
		 */
		public function Locale(pData:* = null) 
		{
			// Si on passe des données, on les stocke.
			if(pData)
			 ObjectUtils.extra(this, pData);
		}
		
	}

}