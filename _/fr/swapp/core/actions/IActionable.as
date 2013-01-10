package fr.swapp.core.actions 
{
	/**
	 * L'interface pour les éléments qui pourront interprêter des actions.
	 * @author ZoulouX
	 */
	public interface IActionable 
	{
		/**
		 * Interprêter une action.
		 * @param	pAction
		 */
		function doAction (pAction:IAction):void
	}
}