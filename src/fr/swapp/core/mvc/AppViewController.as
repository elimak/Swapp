package fr.swapp.core.mvc
{
	import flash.display.Stage;
	import fr.swapp.core.dependences.DependencesManager;
	import fr.swapp.core.dependences.IDependencesManager;
	
	/**
	 * @author ZoulouX
	 */
	public class AppViewController extends ViewController implements IAppViewController
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
		 * Handle external command Document.
		 * @param	pCommand : Command name. On android, "back" and "menu" are sended.
		 * @param	pParameters : Command associated parameters. Can be messy, debug to know the structure.
		 * @return : Return true to cancel default behavior.
		 */
		public function externalCommand (pCommand:String, pParameters:Object):Boolean
		{
			return false;
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