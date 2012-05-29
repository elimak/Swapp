package fr.swapp.core.bootstrap 
{
	import flash.display.DisplayObjectContainer;
	import fr.swapp.core.actions.IAction;
	
	/**
	 * Interface du delegate du bootstrap pour récupérer le container graphique par défaut
	 * @author ZoulouX
	 */
	public interface IBootstrapDelegate 
	{
		/**
		 * Récupérer le container graphique par défaut
		 * @param	pAction : L'action qui demande un containeur (le container n'a pas été trouvé dans les infos du contexte)
		 * @return : Le container graphique. Ne doit pas être null.
		 */
		function getDefaultDisplayContainer (pAction:IAction):DisplayObjectContainer
	}
}