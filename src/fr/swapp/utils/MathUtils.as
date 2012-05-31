package fr.swapp.utils 
{
	/**
	 * Classe utilitaire permettant de gérer les nombres
	 * @author ZoulouX
	 */
	public class MathUtils
	{
		/**
		 * Transformer un radian en degrés
		 * @param	pValue : La valeur en radians
		 * @return : La valeur en degrés
		 */
		public static function radToDeg (pValue:Number):Number
		{
			return pValue / Math.PI * 180;
		}
		
		/**
		 * Transformer un degré en radians
		 * @param	pValue : La valeur en degrés
		 * @return : La valeur en radians
		 */
		public static function degToRad (pValue:Number):Number
		{
			return pValue / 180 * Math.PI;
		}
		
		/**
		 * Récupérer un nombre aléatoire entier.
		 * NB: pStart &lt; pEnd n'est pas vérifié lors de l'opération.
		 * @param	pStart : Le minimum du nombre aléatoire
		 * @param	pEnd : Le maximum du nombre aléatoire
		 * @return : Le nombre entier aléatoire entre pStart et pEnd
		 */
		public static function intRandom (pStart:int, pEnd:int):int
		{
			return int(pStart + Math.random() * (pEnd - pStart));
		}
		
		/**
		 * Récupérer un nombre aléatoire flottant
		 * NB: pStart &lt; pEnd n'est pas vérifié lors de l'opération.
		 * @param	pStart : Le minimum du nombre aléatoire
		 * @param	pEnd : Le maximum du nombre aléatoire
		 * @return : Le nombre flottant aléatoire entre pStart et pEnd
		 */
		public static function floatRandom (pStart:Number, pEnd:Number):Number
		{
			return int(pStart + Math.random() * (pEnd - pStart));
		}
		
		public static function fixed (pNumber:Number, pDecimal:int = 2):Number
		{
			const pow:uint = Math.pow(10, pDecimal);
			
			return int(pNumber * pow + .5) / pow;
		}
	}
}