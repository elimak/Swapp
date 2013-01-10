package fr.swapp.core.mvc.abstract 
{
	import fr.swapp.core.actions.IActionable;
	import fr.swapp.core.actions.IActionCatcher;
	import fr.swapp.core.roles.IDisposable;
	import fr.swapp.core.roles.IEngine;
	import fr.swapp.core.roles.IInitializable;
	import fr.swapp.core.roles.IStartStoppable;
	
	/**
	 * L'interface pour les controlleurs de base.
	 * Ces controlleurs peuvent être démarrés, arrêtés et peuvent prendre du temps à démarrer/s'arrêter.
	 * Les controlleurs possèdent des actions.
	 * @author ZoulouX
	 */
	public interface IController extends IEngine, IStartStoppable, IDisposable, IActionCatcher, IActionable, IInitializable
	{
		
	}
}