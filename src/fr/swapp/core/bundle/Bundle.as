package fr.swapp.core.bundle
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import fr.swapp.core.actions.IAction;
	import fr.swapp.core.bootstrap.Bootstrap;
	import fr.swapp.core.bootstrap.IBootstrap;
	import fr.swapp.core.dependences.DependencesManager;
	import fr.swapp.core.dependences.IDependencesManager;
	import fr.swapp.core.mvc.abstract.IViewController;
	import fr.swapp.core.mvc.concrete.View;
	import fr.swapp.core.mvc.concrete.ViewController;
	import fr.swapp.graphic.components.containers.popups.PopupProvider;
	
	/**
	 * @author ZoulouX
	 */
	public class Bundle implements IBundle
	{
		/**
		 * Le conteneur graphique de ce bundle
		 */
		protected var _displayContainer					:DisplayObjectContainer;
		
		/**
		 * Le bootstrap
		 */
		protected var _bootstrap						:IBootstrap;
		
		/**
		 * Le manager de dépendances
		 */
		protected var _dependencesManager				:IDependencesManager;
		
		/**
		 * L'action par défaut
		 */
		protected var _defaultAction					:IAction;
		
		/**
		 * Initialisation automatique
		 */
		protected var _autoInit							:Boolean;
		
		/**
		 * Destruction automatique
		 */
		protected var _autoDispose						:Boolean;
		
		/**
		 * Le controlleur principal de l'application
		 */
		protected var _appController					:IViewController;
		
		/**
		 * Le provider de popups
		 */
		protected var _popupProvider					:PopupProvider;
		
		
		/**
		 * Le conteneur graphique de ce bundle
		 */
		public function get displayContainer ():DisplayObjectContainer { return _displayContainer; }
		
		/**
		 * Le bootstrap associé
		 */
		public function get bootstrap ():IBootstrap { return _bootstrap; }
		
		/**
		 * Le manager des dépendances de l'application
		 */
		public function get dependencesManager ():IDependencesManager { return _dependencesManager; }
		
		/**
		 * Le controlleur principal de l'application
		 */
		public function get appController ():IViewController { return _appController; }
		
		/**
		 * Le provider de popups
		 */
		public function get popupProvider ():PopupProvider { return _popupProvider; }
		
		
		/**
		 * Le constructeur
		 * @param	pDisplayContainer : Le container graphique de ce bundle. S'il est null, un sprite sera créé.
		 * @param	pDefaultAction : L'action par défaut à exécuter
		 * @param	pAutoInit : Initialisation automatique du bundle lorsque le container est ajouté à la scène
		 * @param	pAutoDispose : Destruction automatique du bundle lorsque le container est supprimé de la scène
		 */
		public function Bundle (pDisplayContainer:DisplayObjectContainer = null, pDefaultAction:IAction = null, pAutoInit:Boolean = true, pAutoDispose:Boolean = true)
		{
			// Enregistrer l'action par défaut
			_defaultAction = pDefaultAction;
			
			// Les configurations auto
			_autoInit = pAutoInit;
			_autoDispose = pAutoDispose;
			
			// Si le container est null, on créé un sprite
			_displayContainer = (pDisplayContainer == null ? new Sprite() : pDisplayContainer);
			
			// Si ce nouveau container est déjà sur le stage
			if (_displayContainer.stage != null)
			{
				// On signale qu'il est ajouté
				containerAddedHandler();
			}
			else
			{
				// Sinon on attend qu'il soit ajouté
				_displayContainer.addEventListener(Event.ADDED_TO_STAGE, containerAddedHandler);
			}
			
			// Ecouter lorsque ce container est supprimé
			_displayContainer.addEventListener(Event.REMOVED_FROM_STAGE, containerRemovedHandler);
		}
		
		/**
		 * Le displayContainer est ajouté au stage
		 */
		protected function containerAddedHandler (event:Event = null):void
		{
			// Si on doit initialiser automatiquement
			if (_autoInit)
			{
				init();
			}
		}
		
		/**
		 * Le displayContainer est supprimé du stage
		 */
		protected function containerRemovedHandler (event:Event = null):void
		{
			// Si on doit détruire automatiquement
			if (_autoDispose)
			{
				dispose();
			}
		}
		
		/**
		 * Récupérer le container graphique par défaut
		 * @param	pAction : L'action qui demande un containeur (le container n'a pas été trouvé dans les infos du contexte)
		 * @return : Le container graphique. Ne doit pas être null.
		 */
		public function getDefaultDisplayContainer (pAction:IAction):DisplayObjectContainer
		{
			return _displayContainer;
		}
		
		/**
		 * Initialisation du Bundle.
		 * Appelé automatiquement lorsque le displayContainer fait partie de la displayList.
		 * L'ordre des appels doit rester le même, overridez plutôt la méthode protégée prepare.
		 */
		final public function init ():void
		{
			// Initialiser le bootstrap
			initBootstrap();
			
			// Initialiser le manager de dépendances
			initDependencesManager();
			
			// Initialiser les dépendances de base
			initBaseDependences();
			
			// Initialiser le provider de popups
			initPopupsProvider();
			
			// Mapper le delegate le manager de dépendances sur le bootstrap
			mapDelegateAndDependencesManagerToBootstrap();
			
			// Initialiser les models
			initModels();
			
			// Initialiser les dépendances de l'application
			initDependences();
			
			// Initialiser les actions
			initActions();
			
			// Préparer les éléments de l'application
			prepare();
			
			// Une fois que tout est prêt, on peut exécuter l'action par défaut
			executeDefaultAction();
		}
		
		/**
		 * Initialiser le bootstrap.
		 * A overrider pour ne pas avoir un Bootstrap de base par défaut.
		 */
		protected function initBootstrap ():void
		{
			// Instancier le bootstrap de base
			_bootstrap = new Bootstrap();
		}
		
		/**
		 * Initialiser le manager de dépendances.
		 * A overrider pour ne pas avoir un manager de base par défaut
		 */
		protected function initDependencesManager ():void
		{
			// Instancier le manager de dépendances par défaut
			_dependencesManager = new DependencesManager();
		}
		
		/**
		 * Initialiser les dépendances de base
		 */
		protected function initBaseDependences ():void
		{
			// Donner ce Bundle aux vues et controlleurs
			_dependencesManager.addDependences(ViewController, {
				bundle: this
			});
			_dependencesManager.addDependences(View, {
				bundle: this
			});
		}
		
		/**
		 * Initialiser le provider de popups
		 */
		protected function initPopupsProvider ():void
		{
			// Créer le popup provider et lui donner une instance de ce bundle
			_popupProvider = new PopupProvider();
			_popupProvider.bundle = this;
		}
		
		/**
		 * Préparer les éléments principaux de l'application.
		 * A ce niveau de l'initialisation, seul le bootstrap et le manager de dépendances sont prêts.
		 */
		protected function prepare ():void
		{
			
		}
		
		/**
		 * Mapper le delegate et l'injecteur au bootstrap.
		 * Le bootstrap et le manager de dépendances ne doivent pas être null.
		 * Par défaut, ce Bundle sera le delegate du bootstrap.
		 */
		protected function mapDelegateAndDependencesManagerToBootstrap ():void
		{
			// Si on a un bootstrap
			if (_bootstrap != null)
			{
				// Ce Bundle est le delegate
				_bootstrap.delegate = this;
				
				// Définir le manager de dépendances
				_bootstrap.dependencesManager = _dependencesManager;
			}
		}
		
		/**
		 * Construire et gérer l'AppController de l'application via le bootstrap.
		 * Le bootstrap et le displayContainer ne doivent pas être null.
		 * @param	pAppControllerClass : La classe de l'AppController (doit implémenter IViewController). Si null, une erreur sera levée par le bootstrap.
		 */
		protected function buildAppController (pAppControllerClass:Class):void
		{
			// Ajouter ce controlleur au bootstrap
			if (_bootstrap != null && _displayContainer != null)
			{
				// TODO : Mapping de l'appcontroller sur le bootstrap
				_appController = _bootstrap.callControllerForContainer(pAppControllerClass, _displayContainer);
			}
		}
		
		/**
		 * Initialier les models de l'application
		 */
		protected function initModels ():void
		{
			
		}
		
		/**
		 * Initialiser les dépendences
		 */
		protected function initDependences ():void
		{
			
		}
		
		/**
		 * Initialiser les actions de l'application
		 */
		protected function initActions ():void
		{
			
		}
		
		/**
		 * Exécuter l'action par défaut
		 */
		public function executeDefaultAction ():void
		{
			// Si on a un bootstrap et une action par défaut
			if (_bootstrap != null && _defaultAction != null)
			{
				// On exécute l'action par défaut sur le bootstrap
				_bootstrap.doAction(_defaultAction);
			}
		}
		
		/**
		 * Destruction du Bundle
		 */
		public function dispose ():void
		{
			// Ne plus écouter les ajouts / suppressions
			_displayContainer.removeEventListener(Event.ADDED_TO_STAGE, containerAddedHandler);
			_displayContainer.removeEventListener(Event.REMOVED_FROM_STAGE, containerRemovedHandler);
			
			// Ne plus écouter ce container
			_displayContainer = null;
			
			// Disposer les éléments
			if (_bootstrap != null)
				_bootstrap.dispose();
		}
	}
}