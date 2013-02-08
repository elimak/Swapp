package fr.swapp.graphic.controls
{
	import com.greensock.easing.Strong;
	import com.greensock.TweenMax;
	import flash.display.DisplayObject;
	import fr.swapp.graphic.base.SComponent;
	import fr.swapp.graphic.base.SGraphic;
	import fr.swapp.touch.delegate.ITouchDragDelegate;
	import fr.swapp.touch.delegate.ITouchTapDelegate;
	import org.osflash.signals.Signal;
	
	/**
	 * @author ZoulouX
	 */
	public class SSlider extends SComponent implements ITouchDragDelegate, ITouchTapDelegate
	{
		/**
		 * Slider's button
		 */
		protected var _button					:SGraphic;
		
		/**
		 * Background track
		 */
		protected var _track					:SGraphic;
		
		/**
		 * Inner track
		 */
		protected var _inner					:SGraphic;
		
		
		protected var _buttonStart				:int;
		
		protected var _buttonEnd				:int;
		
		
		/**
		 * Minimum value
		 */
		protected var _minimum					:Number						= 0;
		
		/**
		 * Maximum value
		 */
		protected var _maximum					:Number						= 1;
		
		/**
		 * Step value (0 to disable step)
		 */
		protected var _step						:Number						= 0.1;
		
		/**
		 * Value
		 */
		protected var _value					:Number						= 0;
		
		
		/**
		 * If rules are invalidates
		 */
		protected var _rulesInvalidated			:Boolean;
		
		/**
		 * If button position is invalidated
		 */
		protected var _buttonInvalidated		:Boolean;
		
		/**
		 * Round value to step when dragging
		 */
		protected var _dragToSteps				:Boolean;
		
		
		protected var _positionTweenDuration	:Number						= .3;
		
		protected var _positionTweenEasing		:Function					= Strong.easeOut;
		
		protected var _virtualButtonPosition	:Number;
		
		protected var _onStartDrag				:Signal						= new Signal(SSlider);
		protected var _onStopDrag				:Signal						= new Signal(SSlider);
		protected var _onChanged				:Signal						= new Signal(SSlider, Boolean);
		
		protected var _onButtonMoved			:Signal						= new Signal(SSlider, Boolean);
		
		
		/**
		 * Slider's button
		 */
		public function get button ():SGraphic { return _button; }
		
		/**
		 * Background track
		 */
		public function get track ():SGraphic { return _track; }
		
		/**
		 * Inner track
		 */
		public function get inner ():SGraphic { return _inner; }
		
		
		/**
		 * Minimum value
		 */
		public function get minimum ():Number { return _minimum; }
		public function set minimum (pValue:Number):void
		{
			// Si c'est différent et réel
			if (_minimum != pValue && (pValue >= 0 || pValue < 0))
			{
				// Enregistrer la nouvelle valeur
				_minimum = pValue;
				
				// Invalider les règles
				invalidateRules();
				
				// Invalider la position du bouton
				invalidateButton();
			}
		}
		
		/**
		 * Maximum value
		 */
		public function get maximum ():Number { return _maximum; }
		public function set maximum (pValue:Number):void
		{
			// Si c'est différent et réel
			if (_maximum != pValue && (pValue >= 0 || pValue < 0))
			{
				// Enregistrer la nouvelle valeur
				_maximum = pValue;
				
				// Invalider les règles
				invalidateRules();
				
				// Invalider la position du bouton
				invalidateButton();
			}
		}
		
		/**
		 * Step value (0 to disable step)
		 */
		public function get step ():Number { return _step; }
		public function set step (pValue:Number):void
		{
			// Si c'est différent et réel
			if (_step != pValue && (pValue >= 0 || pValue < 0))
			{
				// Enregistrer la nouvelle valeur et interdire les valeurs négatives
				_step = Math.max(0, pValue);
				
				// Invalider les règles
				invalidateRules();
				
				// Invalider la position du bouton
				invalidateButton();
			}
		}
		
		/**
		 * Value
		 */
		public function get value ():Number { return _value; }
		public function set value (pValue:Number):void
		{
			// Si c'est différent et réel
			if (_value != pValue && (pValue >= 0 || pValue < 0))
			{
				// Enregistrer la nouvelle valeur en la limitant
				_value = Math.max(_minimum, Math.min(pValue, _maximum));
				
				// Si on a un step
				if (_step > 0)
				{
					// On calle sur le step
					placeValueOnStep();
				}
				
				// Invalider la position du bouton
				invalidateButton();
			}
		}
		
		/**
		 * Round value to step when dragging
		 */
		public function get dragToSteps ():Boolean { return _dragToSteps; }
		public function set dragToSteps (value:Boolean):void
		{
			// Si c'est différent
			if (value != _dragToSteps)
			{
				// Enregistrer la valeur
				_dragToSteps = value;
			}
		}
		
		public function get onChanged ():Signal { return _onChanged; }
		
		public function get onStartDrag ():Signal { return _onStartDrag; }
		
		public function get onStopDrag ():Signal { return _onStopDrag; }
		
		public function get onButtonMoved ():Signal { return _onButtonMoved; }
		
		
		/**
		 * Constructor
		 */
		public function SSlider (pMin:Number = 0, pMax:Number = 1, pStep:Number = 0.1, pValue:Number = 0, pDragToSteps:Boolean = false)
		{
			// Enregistrer les valeurs
			minimum = pMin;
			maximum = pMax;
			step = pStep;
			value = pValue;
			_dragToSteps = pDragToSteps;
			
			// Construire l'interface
			buildInterface();
		}
		
		
		/**
		 * Build interface
		 */
		protected function buildInterface ():void
		{
			// Créer la track
			_track = new SGraphic();
			_track.place(NaN, 0, NaN, 0).into(this);
			
			// Créer l'inner
			_inner = new SGraphic();
			_inner.place(NaN, NaN, NaN, 0).into(this);
			
			// Créer le bouton
			_button = new SGraphic();
			_button.center(NaN, 0).into(this);
		}
		
		/**
		 * Initialisation
		 */
		override public function init ():void
		{
			// Actualiser la position du bouton
			updateButtonPosition();
			
			// Et de l'inner
			updateInnerPosition(false);
			
			// Relayer
			super.init();
		}
		
		/**
		 * Invalidate rules
		 */
		protected function invalidateRules ():void
		{
			// Invalider les règles
			_rulesInvalidated = true;
		}
		
		/**
		 * Invalidate button
		 */
		protected function invalidateButton ():void
		{
			// Invalider le bouton
			_buttonInvalidated = true;
		}
		
		/**
		 * Update rules
		 */
		protected function updateRules ():void
		{
			
		}
		
		/**
		 * Place the value to the nearest step
		 */
		protected function placeValueOnStep ():void
		{
			_value = _minimum + Math.round((_value - _minimum) / _step) * _step;
		}
		
		/**
		 * Update button position
		 */
		protected function updateButtonPosition ():void
		{
			// Récupérer le ratio de la valeur
			var ratio:Number = (_value - _minimum) / (_maximum - _minimum);
			
			// L'appliquer sur la position du bouton
			_button.horizontalOffset = _buttonStart + ratio * (_buttonEnd - _buttonStart);
		}
		
		/**
		 * Updater inner position
		 */
		protected function updateInnerPosition (pFromUser:Boolean = true):void
		{
			// Appliquer l'inner vu que le bouton a bougé
			_inner.right = _track.width - _button.horizontalOffset;
			
			// Le bouton a bougé
			_onButtonMoved.dispatch(this, pFromUser);
		}
		
		/**
		 * Render phase
		 */
		override protected function renderPhase ():void
		{
			// Relayer
			super.renderPhase();
			
			// Si les règles sont invalidées
			if (_rulesInvalidated)
			{
				// Les actualiser
				updateRules();
				
				// Les valider
				_rulesInvalidated = false;
			}
			
			// Si le bouton est invalidé
			if (_buttonInvalidated)
			{
				// Récupérer les limites du bouton
				getButtonLimits();
				
				// Actualiser sa position
				updateButtonPosition();
				
				// Actualiser la position de l'inner
				updateInnerPosition(false);
				
				// Le valider
				_buttonInvalidated = false;
			}
		}
		
		/**
		 * Get button limits
		 */
		protected function getButtonLimits ():void
		{
			// Récupérer les limites
			_buttonStart = (_inner.left - _track.left);
			_buttonEnd = _track.width - _buttonStart;
		}
		
		/**
		 * Drag locked
		 */
		public function touchDragLock (pTarget:DisplayObject):void
		{
			// Si on est sur le bouton
			if (pTarget == _button)
			{
				// Stopper les tweens du bouton
				TweenMax.killTweensOf(_button);
				
				// Récupérer la position virtuelle du bouton
				_virtualButtonPosition = _button.horizontalOffset;
				
				// Récupérer les limites
				getButtonLimits();
				
				// Signaler
				_onStartDrag.dispatch(this);
			}
		}
		
		/**
		 * Dragging
		 */
		public function touchDragging (pTarget:DisplayObject, pDirection:String, pXDelta:Number, pYDelta:Number):Boolean
		{
			// Si on est sur le bouton
			if (pTarget == _button)
			{
				// Récupérer la valeur avant le mouvement
				var oldValue:Number = _value;
				
				// Actualiser la position virtuelle du bouton
				_virtualButtonPosition += pXDelta;
				
				// Déplacer le bouton et le limiter
				_button.horizontalOffset = Math.max(_buttonStart, Math.min(_virtualButtonPosition, _buttonEnd));
				
				// Récupérer le ratio de cette position
				var ratio:Number = (_button.horizontalOffset - _buttonStart) / (_buttonEnd - _buttonStart);
				
				// L'appliquer sur la valeur
				_value = _minimum + ratio * (_maximum - _minimum);
				
				// Si on a un step
				if (_step > 0)
				{
					// Placer la valeur sur un step
					placeValueOnStep();
					
					// Si on doit placer le bouton sur les steps
					if (_dragToSteps)
					{
						// Actualiser la position du bouton
						updateButtonPosition();
					}
				}
				
				// Actualiser la position de l'inner
				updateInnerPosition();
				
				// Si la valeur à changé
				if (oldValue != _value)
				{
					// Dispatcher le changement
					_onChanged.dispatch(this, true);
				}
			}
			
			// Autoriser
			return true;
		}
		
		/**
		 * Drag unlocked
		 */
		public function touchDragUnlock (pTarget:DisplayObject):void
		{
			// Si on ne placer pas sur le step pendant le dragging et qu'on a un step
			if (!_dragToSteps && _step > 0)
			{
				// Récupérer la position actuelle du bouton
				var buttonPosition:Number = _button.horizontalOffset;
				
				// Actualiser la position du bouton
				updateButtonPosition();
				
				// Animer
				TweenMax.from(_button, _positionTweenDuration, {
					horizontalOffset: buttonPosition,
					ease: _positionTweenEasing,
					onUpdate: updateInnerPosition
				});
			}
			
			// Signaler
			_onStopDrag.dispatch(this);
		}
		
		
		public function touchTapHandler (pTarget:DisplayObject, pIsPrimary:Boolean):void
		{
			
		}
		
		public function touchPressHandler (pTarget:DisplayObject):void
		{
			
		}
		
		public function touchReleaseHandler (pTarget:DisplayObject):void
		{
			
		}
	}
}