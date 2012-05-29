package fr.swapp.core.display 
{
	import flash.display.DisplayObject;
	
	/**
	 * L'interface générale des DisplayObjects.
	 * Peut aussi permettre à un objet non graphique d'encapsuler un objet graphique et de se comporter comme tel sans avoir à étendre une classe graphique concrête (via le pattern décoration).
	 * @author ZoulouX
	 */
	public interface IDisplayObject
	{
		/**
		 * L'instance de ce clip typée DisplayObject via son interface
		 */
		function get displayObject ():DisplayObject;
	}
}