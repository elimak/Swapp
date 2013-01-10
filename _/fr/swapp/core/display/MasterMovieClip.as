package fr.swapp.core.display 
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	
	/**
	 * La classe principale pour les MovieClips.
	 * @author ZoulouX
	 */
	public class MasterMovieClip extends MovieClip implements IMasterDisplayObject
	{
		/**
		 * Si on doit l'initialiser automatiquement à l'ajout sur la scène
		 */
		protected var _autoInit						:Boolean;
		
		/**
		 * Si on doit disposer automatiquement à la suppression du clip
		 */
		protected var _autoDispose					:Boolean;
		
		
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
		 * L'instance de ce clip typée DisplayObject via son interface
		 */
		public function get displayObject ():DisplayObject
		{
			return this as DisplayObject;
		}
		
		
		/**
		 * Le constructeur
		 */
		public function MasterMovieClip (pAutoInit:Boolean = true, pAutoDispose:Boolean = true)
		{
			// Relayer la construction
			super();
			
			// AutoInit et autoDispose
			_autoInit = pAutoInit;
			_autoDispose = pAutoDispose;
			
			// Ecouter les ajouts au stage
			if (stage != null)
				addedHandler();
			else
				addEventListener(Event.ADDED_TO_STAGE, addedHandler);
			
			// Ecouter la suppression
			addEventListener(Event.REMOVED_FROM_STAGE, removedHandler);
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
				removeEventListener(Event.ADDED_TO_STAGE, addedHandler);
				
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
				removeEventListener(Event.REMOVED_FROM_STAGE, removedHandler);
				
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
		 * Méthode abstraite de destruction. A overrider.
		 */
		public function dispose ():void
		{
			
		}
	}
}