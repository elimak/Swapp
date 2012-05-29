package fr.swapp.core.roles 
{
	/**
	 * Le rôle d'un élément indexable
	 * @author ZoulouX
	 */
	public interface IIndexable 
	{
		/**
		 * L'index de cet élément
		 */
		function get index ():int;
		function set index (value:int):void
	}
}