package fr.swapp.graphic.styles 
{
	/**
	 * @author ZoulouX
	 */
	public interface IStylable
	{
		/**
		 * Le nom du style associé
		 */
		function get styleName ():String;
		function set styleName (value:String):void;
		
		/**
		 * Récupérer l'élément stylisable parent
		 */
		function get parentStylable ():IStylable;
	}
}