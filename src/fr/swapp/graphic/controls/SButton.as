package fr.swapp.graphic.controls
{
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import fr.swapp.graphic.base.SComponent;
	import fr.swapp.touch.delegate.ITouchTapDelegate;
	import org.osflash.signals.Signal;
	
	/**
	 * @author ZoulouX
	 */
	public class SButton extends SComponent implements ITouchTapDelegate
	{
		public static const MOUSE_INTERACTION				:String 	= "mouseInteraction";
		public static const MULTITOUCH_INTERACTION			:String 	= "multitouchInteraction";
		public static const MONOTOUCH_INTERACTION			:String 	= "monotouchInteraction";
		
		/**
		 * Current button state (see SButtonStates)
		 */
		protected var _state					:String					= SButtonStates.NORMAL;
		
		/**
		 * When state changed
		 */
		protected var _onStateChanged			:Signal 				= new Signal(SButton, String);
		
		/**
		 * When user tap the button
		 */
		protected var _onTap				:Signal					= new Signal(SButton);
		
		/**
		 * Button interaction mode (see statics)
		 */
		protected var _interactionMode			:String;
		
		/**
		 * Styles associated to states
		 */
		protected var _stateStyles				:Object;
		
		/**
		 * Current rollOver state
		 */
		protected var _rollOver					:Boolean;
		
		/**
		 * Current pressed state
		 */
		protected var _pressed					:Boolean;
		
		
		
		/**
		 * Current button state (see SButtonStates)
		 */
		public function get state ():String { return _state; }
		
		/**
		 * When state changed
		 */
		public function get onStateChanged ():Signal { return _onStateChanged; }
		
		/**
		 * When user tap the button
		 */
		public function get onTap ():Signal { return _onTap; }
		
		/**
		 * Button interaction mode (see statics)
		 */
		public function get interactionMode ():String { return _interactionMode; }
		
		/**
		 * Styles associated to states
		 */
		public function get stateStyles ():Object { return _stateStyles; }
		public function set stateStyles (value:Object):void
		{
			_stateStyles = value;
		}
		
		
		/**
		 * Constructor.
		 */
		public function SButton (pInteractionMode:String = "monotouchInteraction")
		{
			// Enregistrer le multitouch
			_interactionMode = pInteractionMode;
			
			// Désactiver l'interaction sur les childs
			mouseChildren = false;
			
			// Initialiser les handlers
			initHandlers();
		}
		
		/**
		 * Initialise touch handlers
		 */
		protected function initHandlers ():void
		{
			// Si on est en interaction mouse
			if (_interactionMode == MOUSE_INTERACTION)
			{
				// On gère avec les events mouse
				addEventListener(MouseEvent.ROLL_OVER, mouseHandlers);
				addEventListener(MouseEvent.ROLL_OUT, mouseHandlers);
				addEventListener(MouseEvent.MOUSE_DOWN, mouseHandlers);
				addEventListener(MouseEvent.CLICK, mouseHandlers);
			}
		}
		
		/**
		 * Internal setter for state changing. Non exposed method.
		 */
		protected function internalSetState (value:String):void
		{
			// Si la valeur est différente
			if (value != _state)			
			{
				// Enregistrer l'état actuel
				var oldState:String = _state;
				
				// Enregistrer la valeur
				_state = value;
				
				// Signaler le changement en interne
				stateChangedHandler(oldState, value);
				
				// Dispatcher le changement
				onStateChanged.dispatch(this, _state);
			}
		}
		
		/**
		 * All mouse handlers
		 */
		protected function mouseHandlers (event:MouseEvent):void 
		{
			// Au rollOver
			if (event.type == MouseEvent.ROLL_OVER)
			{
				_rollOver = true;
			}
			
			// Au rollOut
			else if (event.type == MouseEvent.ROLL_OUT)
			{
				_rollOver = false;
			}
			
			// Au mouseDown
			else if (event.type == MouseEvent.MOUSE_DOWN)
			{
				_pressed = true;
				
				// Ecouter les mouseUps
				stage.addEventListener(MouseEvent.MOUSE_UP, mouseHandlers);
			}
			
			// Au mouseUp
			else if (event.type == MouseEvent.MOUSE_UP)
			{
				_pressed = false;
				
				// Ne plus écouter les mouseUps
				stage.removeEventListener(MouseEvent.MOUSE_UP, mouseHandlers);
			}
			
			// Au clic
			else if (event.type == MouseEvent.CLICK)
			{
				_onTap.dispatch(this);
			}
			
			// Actualiser l'état selon les properties
			updateStateFromProperties();
		}
		
		/**
		 * Component tapped
		 */
		public function touchTapHandler (pTarget:DisplayObject, pIsPrimary:Boolean):void
		{
			if (
				// Si l'interaction est activée
				mouseEnabled
				&&
				(
					// Si on est en monotouch et que c'est le seul point
					(_interactionMode == MONOTOUCH_INTERACTION && pIsPrimary)
					||
					// Ou si on est en multitouch
					_interactionMode == MULTITOUCH_INTERACTION
				)
			)
			{
				// On dispatch le tap
				_onTap.dispatch(this);
			}
		}
		
		/**
		 * Component is touch pressed
		 */
		public function touchPressHandler (pTarget:DisplayObject):void
		{
			// Enregistrer
			_pressed = true;
			
			// Actualiser
			updateStateFromProperties();
		}
		
		/**
		 * Component is touch released
		 */
		public function touchReleaseHandler (pTarget:DisplayObject):void
		{
			// Enregistrer
			_pressed = false;
			
			// Actualiser
			updateStateFromProperties();
		}
		
		/**
		 * Component double tapped
		 */
		public function touchDoubleTapHandler (pTarget:DisplayObject, pTimeOffset:int):void {}
		
		/**
		 * Component single tapped
		 */
		public function touchSingleTapHandler (pTarget:DisplayObject):void { }
		
		/**
		 * Update the current state following interaction properties
		 */
		protected function updateStateFromProperties ():void
		{
			// Si l'interactivité est désactivée
			if (!mouseEnabled && !mouseChildren)
			{
				internalSetState(SButtonStates.DISABLED);
			}
			
			// Si on est sur l'état pressé
			else if (_pressed)
			{
				internalSetState(SButtonStates.PRESSED);
			}
			
			// Si on est sur l'état rollOver
			else if (_rollOver)
			{
				internalSetState(SButtonStates.HOVER);
			}
			
			// Sinon on est en état normal
			else
			{
				internalSetState(SButtonStates.NORMAL);
			}
		}
		
		/**
		 * Set styles for each Button state
		 */
		/*
		public function statesStyles (pNormalStyle:Object, pHoverStyle:Object, pPressedStyle:Object, pDisabledStyle:Object):void
		{
			// TODO : State styles. Possibilité de surchargé du style au changement de stage
			// TODO : Transition entre les changements de style (propriété / delay / duration / easing ?)
		}
		*/
		
		/**
		 * State has changed
		 * @param	pOldState : Old state before change
		 * @param	pNewState : New state
		 */
		protected function stateChangedHandler (pOldState:String, pNewState:String):void
		{
			
		}
		
		
		/**
		 * Specify if the component is interactive.
		 * Will change button state to DISABLE or NORMAL.
		 * @return this
		 */
		override public function interactive (pValue:Boolean):SComponent
		{
			// Activer / désactiver les mouseEvents
			mouseEnabled = pValue;
			
			// Actualiser l'état selon les properties
			updateStateFromProperties();
			
			// Relayer
			return this;
		}
		
		/**
		 * Destruction
		 */
		override public function dispose ():void
		{
			// Si on était en interaction mouse
			if (!_interactionMode == MOUSE_INTERACTION)
			{
				// Supprimer les handlers
				stage.removeEventListener(MouseEvent.MOUSE_UP, mouseHandlers);
				removeEventListener(MouseEvent.ROLL_OVER, mouseHandlers);
				removeEventListener(MouseEvent.ROLL_OUT, mouseHandlers);
				removeEventListener(MouseEvent.MOUSE_DOWN, mouseHandlers);
				removeEventListener(MouseEvent.CLICK, mouseHandlers);
			}
			
			// Relayer
			super.dispose();
		}
	}
}