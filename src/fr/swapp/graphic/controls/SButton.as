package fr.swapp.graphic.controls
{
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import fr.swapp.graphic.base.SComponent;
	import fr.swapp.input.delegate.IInputSingleDelegate;
	import org.osflash.signals.Signal;
	
	/**
	 * @author ZoulouX
	 */
	public class SButton extends SComponent implements IInputSingleDelegate
	{
		/**
		 * Accepted interaction modes
		 */
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
		protected var _onTap					:Signal					= new Signal(SButton);
		
		/**
		 * Button interaction mode (see statics)
		 */
		protected var _interactionMode			:String;
		
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
		 * Constructor.
		 */
		public function SButton (pTapHandler:Function = null, pInteractionMode:String = "monotouchInteraction")
		{
			// Enregistrer le multitouch
			_interactionMode = pInteractionMode;
			
			// Désactiver l'interaction sur les childs
			mouseChildren = false;
			
			// Utiliser le curseur main
			useHandCursor = true;
			buttonMode = true;
			
			// Initialiser les handlers
			initHandlers();
			
			// Si on a un handler au tap
			if (pTapHandler != null)
			{
				// On ajoute l'écoute
				_onTap.add(pTapHandler);
			}
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
				
				// Virer la classe de l'ancien state
				removeStyleClass(oldState);
				
				// Et ajouter la nouvelle
				addStyleClass(value);
				
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
		 * Before tap is dispatched
		 */
		protected function beforeTap ():void
		{
			
		}
		
		/**
		 * Single tap or clic.
		 * @param	pInputType : The input type (see InputTypes)
		 * @param	pTarget : The target.
		 * @param	pIsPrimaryInput : If this is the only and primary input used.
		 */
		public function inputSingleHandler (pInputType:uint, pTarget:DisplayObject, pIsPrimaryInput:Boolean):void
		{
			if (
				// Si l'interaction est activée
				mouseEnabled
				&&
				(
					// Si on est en monotouch et que c'est le seul point
					(_interactionMode == MONOTOUCH_INTERACTION && pIsPrimaryInput)
					||
					// Ou si on est en multitouch
					_interactionMode == MULTITOUCH_INTERACTION
				)
			)
			{
				// Avant le tap
				beforeTap();
				
				// On dispatch le tap
				_onTap.dispatch(this);
			}
		}
		
		/**
		 * Input added on the target.
		 * @param	pInputType : The input type (see InputTypes)
		 * @param	pTarget : The target.
		 * @param	pIsPrimaryInput : If this is the only and primary input used.
		 */
		public function inputPressHandler (pInputType:uint, pTarget:DisplayObject, pIsPrimaryInput:Boolean):void
		{
			// Enregistrer
			_pressed = true;
			
			// Actualiser
			updateStateFromProperties();
		}
		
		/**
		 * Input removed from the target.
		 * @param	pInputType : The input type (see InputTypes)
		 * @param	pTarget : The target.
		 * @param	pIsPrimaryInput : If this is the only and primary input used.
		 */
		public function inputReleaseHandler (pInputType:uint, pTarget:DisplayObject, pIsPrimaryInput:Boolean):void
		{
			// Enregistrer
			_pressed = false;
			
			// Actualiser
			updateStateFromProperties();
		}
		
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
			// Virer les listeners du onTap
			_onTap.removeAll();
			_onTap = null;
			
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
			
			// ATTENTION BUG
			// Repasser le focus sur le stage à cause du buttonMode = true
			stage.focus = stage;
			
			// Relayer
			super.dispose();
		}
	}
}