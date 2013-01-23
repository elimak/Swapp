package fr.swapp.core.data.remote 
{
	import fr.swapp.core.errors.SwappError;
	
	/**
	 * Récupération de données depuis un fichier/service JSON via HTTP
	 * @author ZoulouX
	 */
	public class JSONRemote extends HTTPRemote
	{
		/**
		 * La fonction de codage par défaut (null par défaut)
		 */
		public static var DEFAULT_ENCODE_FUNCTION	:Function;
		
		/**
		 * La fonction de décodage par défaut (null par défaut)
		 */
		public static var DEFAULT_DECODE_FUNCTION	:Function;
		
		
		/**
		 * La fonction d'encodage
		 */
		protected var _encodeFunction				:Function;
		
		/**
		 * La fonction de décodage
		 */
		protected var _decodeFunction				:Function;
		
		/**
		 * Encoder les données à l'envoie
		 */
		protected var _encodeOnSend					:Boolean;
		
		
		/**
		 * Le constructeur.
		 * Pour Flash Player 11+ et AIR 3+, utilisez JSON.parse et JSON.stringify.
		 * Pour les versions inférieures, utilisez les méthodes de la CoreLib d'Adobe.
		 * @param	pJSONEncodeFunction : La fonction d'encodage JSON
		 * @param	pJSONDecodeFunction : La fonction de décodage JSON
		 * @param	pEncodeOnSend : Encoder automatiquement les paramètres envoyés
		 */
		public function JSONRemote (pJSONEncodeFunction:Function = null, pJSONDecodeFunction:Function = null, pEncodeOnSend:Boolean = true)
		{
			// Fonction d'encodage
			if (pJSONEncodeFunction != null)
				_encodeFunction = pJSONEncodeFunction;
			else
				_encodeFunction = DEFAULT_ENCODE_FUNCTION;
			
			// Fonction de décodage
			if (pJSONDecodeFunction != null)
				_decodeFunction = pJSONDecodeFunction;
			else
				_decodeFunction = DEFAULT_DECODE_FUNCTION;
			
			// Encoder les paramètres envoyés
			_encodeOnSend = pEncodeOnSend;
		}
		
		/**
		 * Préparation des données avant l'envoie
		 */
		override protected function prepareSend (pData:*):*
		{
			// Si on doit encoder les paramètres envoyés
			// Et si on a une fonction d'encodage
			if (_encodeOnSend && _encodeFunction != null)
			{
				// On fait un nouvel objet
				var pOut:Object = { };
				
				// On parcour les paramètres
				for (var i:String in pData)
				{
					// On converti chaque paramètres
					pOut[i] = _encodeFunction.call(null, pData[i]);
				}
				
				// On retourne les paramètres convertis
				return pOut;
			}
			else
			{
				// Retourner directement les données
				return pData;
			}
		}
		
		/**
		 * Préparer les données pour le parse
		 * @param	pData : Les données brutes
		 * @return : Les données préparées
		 */
		override protected function prepareData (pData:*):*
		{
			// Si on a une fonction de décodage
			if (_decodeFunction != null)
			{
				return _decodeFunction.call(null, pData);
			}
			else
			{
				// déclencher une erreur interne
				throw new SwappError("JSONRemote.prepareData", "JSONRemote must compose a decode function (view constructor signature)");
			}
			return null;
		}
	}
}