package fr.swapp.core.mvc.concrete 
{
	import fr.swapp.core.actions.IAction;
	import fr.swapp.core.mvc.abstract.IController;
	
	/**
	 * La classe pour les controlleurs de base.
	 * Ces controlleurs peuvent être démarrés, arrêtés et peuvent prendre du temps à démarrer/s'arrêter.
	 * Les controlleurs possèdent des actions.
	 * @author ZoulouX
	 */
	public class Controller extends Engine implements IController
	{
		/**
		 * La dernière action
		 */
		protected var _lastAction					:IAction;
		
		
		/**
		 * Le constructeur
		 */
		public function Controller ()
		{
			
		}
		
		
		/**
		 * Initialisation du controlleur
		 */
		public function init ():void
		{
			
		}
		
		/**
		 * Doit exécuter une action
		 * @param	pAction : L'action reçu selon laquelle on va agir
		 */
		public function doAction (pAction:IAction):void
		{
			// Enregistrer l'action
			_lastAction = pAction;
		}
		
		/**
		 * Récéption d'une action
		 * @param	pAction : L'action reçu selon laquelle on va agir
		 */
		public function catchAction (pAction:IAction):void
		{
			
		}
	}
}