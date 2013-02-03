package fr.swapp.core.roles 
{
	/**
	 * Permet d'ajouter un comportement à un objet sans l'étendre.
	 * Basé sur le pattern décoration.
	 * @author ZoulouX
	 */
	public interface IBehavior 
	{
		// TODO : Vérifier l'utilité de chaque role et virer ceux qui ne servent plus
		
		function get target ():Object;
		function set target (value:Object):void;
	}
}