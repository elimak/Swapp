package fr.swapp.core.roles 
{
	/**
	 * Cet élément peut possèder un identifiant.
	 * @author ZoulouX
	 */
	public interface IIdentifiable 
	{
		/**
		 * L'identifiant de cet élément
		 */
		function get id ():uint;
		function set id (value:uint):void;
	}
}