package fr.swapp.core.mvc.concrete 
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import fr.swapp.core.bundle.IBundle;
	import fr.swapp.core.errors.SwappError;
	import fr.swapp.core.mvc.abstract.IView;
	
	/**
	 * La classe des vues de base. Elles composent un displayObject et la référence d'un Bundle.
	 * Ces vues peuvent être démarrés, arrêtés et peuvent prendre du temps à démarrer/s'arrêter.
	 * @author ZoulouX
	 */
	public class View extends Engine implements IView
	{
		/**
		 * Si on doit l'initialiser automatiquement à l'ajout sur la scène
		 */
		protected var _autoInit							:Boolean						= true;
		
		/**
		 * Si on doit disposer automatiquement à la suppression du clip
		 */
		protected var _autoDispose						:Boolean						= true;
		
		/**
		 * Le bundle auquel appartient le controlleur
		 */
		protected var _bundle							:IBundle;
		
		/**
		 * Le displayObject associé à cette vue
		 */
		protected var _displayObject					:DisplayObject;
		
		/**
		 * L'état de la vue
		 */
		protected var _state							:Object;
		
		
		/**
		 * Si on doit l'initialiser automatiquement à l'ajout sur la scène
		 */
		public function get autoInit ():Boolean { return _autoInit; }
		public function set autoInit (value:Boolean):void 
		{
			_autoInit = value;
		}
		
		/**
		 * Si on doit disposer automatiquement à la suppression du clip
		 */
		public function get autoDispose ():Boolean { return _autoDispose; }
		public function set autoDispose (value:Boolean):void 
		{
			_autoDispose = value;
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
		 * Le displayObject associé à cette vue
		 */
		public function get displayObject ():DisplayObject { return _displayObject; }
		
		
		/**
		 * Le constructeur.
		 */
		public function View ()
		{
			
		}
		
		
		/**
		 * Créer un displayObject et le définir.
		 * Le Bundle et son dependencesManager doivent être présent.
		 * @param	pDisplayObjectClass : La classe de la vue à attacher, doit être de type IView.
		 */
		protected function createAndAttachDisplayObject (pDisplayObjectClass:Class):void
		{
			// Vérifier si on a tout ce qu'il faut pour instancier et ajouter la vue
			if (_bundle == null || _bundle.dependencesManager == null)
			{
				throw new SwappError("View.attachDisplayObject", "Bundle and Bundle.dependencesManager can't be null");
				return;
			}
			
			// Instancier / attacher
			attachDisplayObject(_bundle.dependencesManager.instanciate(pDisplayObjectClass) as DisplayObject);
		}
		
		/**
		 * Initialiser un displayObject
		 */
		protected function attachDisplayObject (pDisplayObject:DisplayObject):void
		{
			// Définir
			_displayObject = pDisplayObject;
			
			// Ecouter les ajouts au stage
			if (_displayObject.stage != null)
				addedHandler();
			else
				_displayObject.addEventListener(Event.ADDED_TO_STAGE, addedHandler);
			
			// Ecouter la suppression
			_displayObject.addEventListener(Event.REMOVED_FROM_STAGE, removedHandler);
		}
		
		/**
		 * Ajout du clip à la displayList
		 */
		protected function addedHandler (event:Event = null):void
		{
			// Si on doit initialiser automatiquement
			if (_autoInit)
			{
				// Supprimer l'event d'écoute de suppression
				_displayObject.removeEventListener(Event.ADDED_TO_STAGE, addedHandler);
				
				// Appeler la méthode abstraite d'initislisation
				init();
			}
		}
		
		/**
		 * Suppression du clip de la displayList
		 */
		protected function removedHandler (event:Event):void
		{
			// Si on doit disposer automatiquement
			if (_autoDispose)
			{
				// Supprimer l'event d'écoute de suppression
				_displayObject.removeEventListener(Event.REMOVED_FROM_STAGE, removedHandler);
				
				// Appeler la méthode abstraite de vidage mémoire
				dispose();
			}
		}
		
		/**
		 * Méthode abstraite d'initialisation. A overrider.
		 */
		public function init ():void
		{
			
		}
		
		
		/**
		 * Récupérer l'état
		 */
		public function getState ():Object
		{
			return _state;
		}
		
		/**
		 * Définir l'état
		 */
		public function setState (pState:Object):void
		{
			_state = pState;
		}
		
		/**
		 * Activation de la vue
		 */
		public function activate ():void
		{
			
		}
		
		/**
		 * Désactivation de la vue
		 */
		public function deactivate ():void
		{
			
		}
		
		/**
		 * Méthode abstraite de destruction. A overrider.
		 */
		override public function dispose ():void
		{
			// Supprimer la référence au Bundle
			_bundle = null;
			
			// Supprimer la référence au displayObject
			_displayObject = null;
			
			// Relayer
			super.dispose();
		}
	}
}