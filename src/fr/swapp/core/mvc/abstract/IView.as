package fr.swapp.core.mvc.abstract 
{
	import fr.swapp.core.bundle.IBundle;
	import fr.swapp.core.display.IMasterDisplayObject;
	import fr.swapp.core.roles.IEngine;
	
	/**
	 * L'interface des vues de base. Elles composent un displayObject et la référence d'un Bundle.
	 * Ces vues peuvent être démarrés, arrêtés et peuvent prendre du temps à démarrer/s'arrêter.
	 * @author ZoulouX
	 */
	public interface IView extends IMasterDisplayObject, IEngine
	{
		/**
		 * Le Bundle auquel appartient cette vue
		 */
		function get bundle ():IBundle;
		function set bundle (value:IBundle):void;
		
		/**
		 * Récupérer l'état
		 */
		function getState ():Object;
		
		/**
		 * Définir l'état
		 */
		function setState (pState:Object):void;
		
		/**
		 * Activation de la vue
		 */
		function activate ():void;
		
		/**
		 * Désactivation de la vue
		 */
		function deactivate ():void;
	}
}