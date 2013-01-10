package fr.swapp.core.bundle 
{
	import flash.display.DisplayObjectContainer;
	import fr.swapp.core.bootstrap.IBootstrap;
	import fr.swapp.core.bootstrap.IBootstrapDelegate;
	import fr.swapp.core.dependences.IDependencesManager;
	import fr.swapp.core.mvc.abstract.IViewController;
	import fr.swapp.core.roles.IDisposable;
	import fr.swapp.core.roles.IInitializable;
	
	/**
	 * @author ZoulouX & Pascal
	 */
	public interface IBundle extends IInitializable, IDisposable, IBootstrapDelegate
	{
		/**
		 * Le conteneur graphique de ce bundle
		 */
		function get displayContainer ():DisplayObjectContainer;
		
		/**
		 * Le bootstrap associé a ce bundle
		 */
		function get bootstrap ():IBootstrap;
		
		/**
		 * Le manager des dépendances de l'application
		 */
		function get dependencesManager ():IDependencesManager;
		
		/**
		 * Le controlleur principal de l'application
		 */
		function get appController ():IViewController;
		
		/**
		 * Exécuter l'action par défaut
		 */
		function executeDefaultAction ():void;
	}
}