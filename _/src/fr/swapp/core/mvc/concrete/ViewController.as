package fr.swapp.core.mvc.concrete 
{
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import fr.swapp.core.actions.IAction;
	import fr.swapp.core.bundle.IBundle;
	import fr.swapp.core.errors.SwappError;
	import fr.swapp.core.mvc.abstract.IView;
	import fr.swapp.core.mvc.abstract.IViewController;
	import fr.swapp.core.roles.IEngine;
	import fr.swapp.utils.ObjectUtils;
	
	/**
	 * Le controlleur de vue est un type de controlleur qui gère principalement une vue.
	 * @author ZoulouX
	 */
	public class ViewController extends Controller implements IViewController
	{
		/**
		 * La vue associée à ce controlleur
		 */
		protected var _view							:IView;
		
		/**
		 * Le container qui accueille la vue associée
		 */
		protected var _viewContainer				:DisplayObjectContainer;
		
		/**
		 * Le bundle auquel appartient le controlleur
		 */
		protected var _bundle						:IBundle;
		
		
		/**
		 * La vue associée à ce controlleur
		 */
		public function get view ():IView { return _view; }
		public function set view (value:IView):void
		{
			_view = value;
		}
		
		/**
		 * Le container qui accueille la vue associée
		 */
		public function get viewContainer ():DisplayObjectContainer { return _viewContainer; }
		public function set viewContainer (value:DisplayObjectContainer):void
		{
			_viewContainer = value;
		}
		
		/**
		 * Le Bundle auquel appartient ce controlleur
		 */
		public function get bundle ():IBundle { return _bundle; }
		public function set bundle (value:IBundle):void
		{
			_bundle = value;
		}
		
		/**
		 * La dernière action
		 */
		public function get lastAction ():IAction { return _lastAction; }
		
		
		/**
		 * Le constructeur
		 */
		public function ViewController ()
		{
			// TODO: Autodispose lorsque le displayContainer est supprimé du stage. A faire dans le bootstrap pour bien détruire la référence vers le controlleur et le container.
			// TODO: Système automatique de création de la vue en passant une classe depuis le constructeur
			// TODO: Peut être que l'écoute du removeFromStage du viewContainer qui déclanche dispose peut se faire ici?
		}
		
		/**
		 * Créer une vue et l'ajouter au container.
		 * Le Bundle et son dependencesManager doivent être présent.
		 * Le viewContainer doit être présent.
		 * @param	pViewClass : La classe de la vue à attacher, doit être de type IView.
		 * @param	pExtra : Injections de la vue avant l'init et l'activate
		 */
		protected function attachView (pViewClass:Class, pExtra:Object = null):IView
		{
			// Vérifier si on a tout ce qu'il faut pour instancier et ajouter la vue
			if (_bundle == null || _bundle.dependencesManager == null)
			{
				throw new SwappError("ViewController.attachView", "Bundle and Bundle.dependencesManager can't be null");
				return;
			}
			
			// Si on n'a pas de container
			if (_viewContainer == null)
			{
				throw new SwappError("ViewContainer.attachView", "ViewContainer is null");
				return;
			}
			
			// Créer la vue
			_view = _bundle.dependencesManager.instanciate(pViewClass) as IView;
			
			// Si on a des extras on les injecte
			if (pExtra != null)
				ObjectUtils.extra(_view, pExtra);
			
			// Définir l'état de la vue depuis l'action
			if (_lastAction != null)
				_view.setState(_lastAction.stateInfos);
			
			// Ajouter la vue au container
			_viewContainer.addChild(_view.displayObject);
			
			// Ecouter lorsque cette vue est supprimée de son container
			_view.displayObject.addEventListener(Event.REMOVED_FROM_STAGE, viewRemovedFromStageHandler);
			
			// Activer la vue
			_view.activate();
			
			// Retourner la vue
			return _view;
		}
		
		/**
		 * La vue est supprimée
		 */
		protected function viewRemovedFromStageHandler (event:Event):void 
		{
			// Enregistrer l'état de la vue dans l'action
			if (_lastAction != null)
			{
				_lastAction.stateInfos = _view.getState();
			}
			
			// On vire ce controlleur
			_bundle.bootstrap.killCurrentController(_viewContainer);
		}
		
		/**
		 * Détacher une vue
		 */
		public function dettachCurrentView ():Boolean
		{
			// Si on a une vue et un container
			if (_view != null && _viewContainer != null && _view.displayObject != null && _viewContainer.contains(_view.displayObject))
			{
				// Enregistrer l'état de la vue dans l'action
				if (_lastAction != null)
				{
					_lastAction.stateInfos = _view.getState();
				}
				
				// Ne plus écouter (sinon on va déclancher la destruction du controlleur)
				_view.displayObject.removeEventListener(Event.REMOVED_FROM_STAGE, viewRemovedFromStageHandler);
				
				// Désactiver la vue
				_view.deactivate();
				
				// Supprimer la vue
				_viewContainer.removeChild(_view.displayObject);
				
				// Supprimer la référence vers la vue
				_view = null;
				
				return true;
			}
			
			return false;
		}
		
		/**
		 * Démarrer la vue
		 * @param	pContextInfo : Le contexte de démarrage
		 */
		protected function turnOnView (pContextInfo:Object = null):void
		{
			// Ecouter une fois lorsque la vue sera démarrée pour relayer le signal
			_view.onTurningOn.addOnce(function ():void {
				dispatchEngineSignal(_onTurningOn);
			});
			_view.onTurnedOn.addOnce(function ():void {
				dispatchEngineSignal(_onTurnedOn);
			});
			
			// Démarrer la vue
			_view.turnOn(pContextInfo);
		}
		
		/**
		 * Arrêter la vue
		 * @param	pContextInfo : Le contexte de l'arrêt
		 */
		protected function turnOffView (pContextInfo:Object = null):void
		{
			// Ecouter une fois lorsque la vue sera arrêtée pour relayer le signal
			_view.onTurningOff.addOnce(function ():void {
				dispatchEngineSignal(_onTurningOff);
			});
			_view.onTurnedOff.addOnce(function ():void {
				dispatchEngineSignal(_onTurnedOff);
			});
			
			// Arrêter la vue
			_view.turnOff(pContextInfo);
		}
		
		/**
		 * Destruction de ce controlleur
		 */
		override public function dispose ():void
		{
			// Détacher la vue en cours
			dettachCurrentView();
			
			// Relayer
			super.dispose();
			
			// Supprimer la référence au bundle
			_bundle = null;
			
			// Supprimer la dernière action
			_lastAction = null;
			
			// Supprimer la référence à la vue et à son container
			_view = null;
			_viewContainer = null;
		}
	}
}