package fr.swapp.core.mvc
{
	import flash.display.Stage;
	import fr.swapp.core.dependences.DependencesManager;
	import fr.swapp.core.dependences.IDependencesManager;
	
	/**
	 * @author ZoulouX
	 */
	public class AppViewController extends ViewController
	{
		/**
		 * Application dependences manager
		 */
		protected var _dependencesManager			:DependencesManager;
		
		
		/**
		 * Application dependences manager
		 */
		public function get dependencesManager ():IDependencesManager { return _dependencesManager; }
		
		
		/**
		 * Constructor
		 */
		public function AppViewController ()
		{
			
		}
		
		
		/**
		 * Initialize default dependences manager
		 */
		protected function initDependencesManager ():void
		{
			// Instancier le manager de dépendances par défaut
			_dependencesManager = new DependencesManager();
		}
		
		/**
		 * Initialize application dependences
		 */
		protected function initDependences ():void
		{
			
		}
		
		/**
		 * Initialize application models
		 */
		protected function initModels ():void
		{
			
		}
	}
}