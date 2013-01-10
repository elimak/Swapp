package fr.swapp.core.data.enums 
{
	/**
	 * Les imports
	 */
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	/**
	 * @author ZoulouX
	 */
	public class ENum implements IENum
	{
		/**
		 * La valeur
		 */
		protected var _value				:*;
		
		/**
		 * Récupérer la valeur
		 */
		public function get value ():*
		{
			return _value;
		}
		
		/**
		 * Le constructeur
		 * @param	pValue : La valeur
		 */
		public function ENum (pValue:*)
		{
			// Enregistrer la valeur
			_value = pValue;
		}
		
		/**
		 * Vérifier la validité de d'un ENum String
		 * Attention, le nom des constantes et leurs valeurs doivent suivre cette nommenclature:
		 * OK:
		 * MOUSE_OUT = "mouse out";
		 * MOUSEOUT = "mouseOut";
		 * MOUSE_OUT = "MOUSE OUT";
		 * 
		 * NON OK:
		 * MOUSE_OUT = "MouseOut";
		 * MOUSE_OUT = "toto"; (on sait jamais)
		 * @return : Validité booléenne
		 */
		public function isValid ():Boolean
		{
			// Cibler le statique
			var _staticThis:Class = ((getDefinitionByName(getQualifiedClassName(this)) as Class);
			
			// Vérifier si c'est bien un string
			if (_value is String)
			{
				// Vérifier et valider
				return _staticThis[_value.toUpperCase().replace(/ /, "_")] != null);
			}
			else
			{
				// Ne pas valider
				return false;
			}
		}
		
		/**
		 * Le convertir en string
		 */
		public function toString ():String
		{
			// Essayer
			try
			{
				// De convertir en string
				return String(_value);
			}
			catch (e:Error)
			{
				return "{Non string ENum}";
			}
		}
	}
}