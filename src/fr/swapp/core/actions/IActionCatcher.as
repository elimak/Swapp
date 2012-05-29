package fr.swapp.core.actions 
{
	/**
	 * Les éléments implémentant cette interface seront en mesure d'intercepter les actions.
	 * Ces éléments pourront alors effectuer des opérations lors de la récéption de certaines actions.
	 * Ils pourront aussi annuler certaines actions.
	 * @author ZoulouX
	 */
	public interface IActionCatcher
	{
		/**
		 * Intercepter une action.
		 * @param	pAction
		 */
		function catchAction (pAction:IAction):void
	}
}