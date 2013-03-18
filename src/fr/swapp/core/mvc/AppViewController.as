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
		 * Initialize
		 */
		override public function init ():void
		{
			// Relayer
			super.init();
			
			// Initialiser les models
			initModels();
			
			// Initialiser le manager de dépendances
			initDependencesManager();
			
			// Initialiser les dépendences
			initDependences();
			
			// Initialiser les actions
			initActions();
		}
		
		/**
		 * Initialize application models
		 */
		protected function initModels ():void
		{
			
		}
		
		/**
		 * Initialize default dependences manager
		 */
		protected function initDependencesManager (pDependencesManagerName:String = "default"):void
		{
			// Instancier le manager de dépendances par défaut
			_dependencesManager = DependencesManager.getInstance(pDependencesManagerName);
		}
		
		/**
		 * Initialize application dependences
		 */
		protected function initDependences ():void
		{
			
		}
		
		/**
		 * Initialize actions
		 */
		protected function initActions ():void
		{
			
		}
	}
}