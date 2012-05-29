package fr.swapp.core.roles 
{
	/**
	 * Un objet qui peut contenir des données arbitraires
	 * @author ZoulouX
	 */
	public interface IDataContainer 
	{
		/**
		 * Les données arbitraires associées à cet élément
		 */
		function get data ():Object
		function set data (value:Object):void;
	}
}