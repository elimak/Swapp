package fr.swapp.graphic.threedee
{
	import away3d.containers.View3D;
	import flash.display.DisplayObject;
	import flash.geom.Matrix;
	import fr.swapp.graphic.base.SComponent;
	import fr.swapp.input.delegate.IInputDelegate;
	import fr.swapp.input.delegate.IInputDragDelegate;
	import fr.swapp.input.delegate.IInputSingleDelegate;
	import fr.swapp.input.delegate.IInputTransformDelegate;
	
	/**
	 * @author ZoulouX
	 */
	public class SAwayView extends SComponent implements IInputSingleDelegate, IInputDragDelegate, IInputTransformDelegate
	{
		/**
		 * La vue away3D
		 */
		protected var _awayView3D							:View3D;
		
		/**
		 * Le delegate pour le proxy input
		 */
		protected var _inputDelegate						:IInputDelegate;
		
		
		/**
		 * La vue away3D
		 */
		public function get awayView3D ():View3D { return _awayView3D; }
		public function set awayView3D (value:View3D):void
		{
			// Si c'est différent
			if (_awayView3D != value)
			{
				// Si on avait déjà une vue
				if (_awayView3D != null)
				{
					// On la vire
					removeChild(_awayView3D);
				}
				
				// Si on a une nouvelle vue
				if (value != null)
				{
					// On l'ajoute
					addChild(value);
				}
				
				// Enregistrer la référence
				_awayView3D = value;
			}
		}
		
		/**
		 * Le delegate pour le proxy input
		 */
		public function get inputDelegate ():IInputDelegate { return _inputDelegate; }
		public function set inputDelegate (value:IInputDelegate):void
		{
			_inputDelegate = value;
		}
		
		
		/**
		 * Le constructeur
		 */
		public function SAwayView (pView3D:View3D, pInputDelegate:IInputDelegate = null)
		{
			// Enregistrer la référence de la vue 3D
			// En passant par le setter
			awayView3D = pView3D;
			
			// Enregistrer le delegate
			_inputDelegate = pInputDelegate;
			
			// Lancer le sous constructeur
			construct();
		}
		
		/**
		 * Le sous constructeur
		 */
		protected function construct ():void
		{
			
		}
		
		
		/**
		 * Lorsque le composant est redimensionné
		 */
		override protected function resized ():void
		{
			// Si on la vue et le wrapper
			if (_awayView3D != null && _wrapper != null)
			{
				// Mettre la vue 3D en plein écran
				_awayView3D.width = _localWidth * _wrapper.ratio;
				_awayView3D.height = _localHeight * _wrapper.ratio;
			}
		}
		
		
		/**
		 * --------------------------------------------
		 * 				PROXY DELEGATION
		 * --------------------------------------------
		 */
		
		/**
		 * INTERFACE fr.swapp.input.delegate.IInputSingleDelegate
		 */
		public function inputSingleHandler (pInputType:uint, pTarget:DisplayObject, pIsPrimaryInput:Boolean):void
		{
			// Si le delegate est présent de du bon type
			if (_inputDelegate != null && _inputDelegate is IInputSingleDelegate)
			{
				(_inputDelegate as IInputSingleDelegate).inputSingleHandler(pInputType, pTarget, pIsPrimaryInput);
			}
		}
		public function inputPressHandler (pInputType:uint, pTarget:DisplayObject, pIsPrimaryInput:Boolean):void
		{
			// Si le delegate est présent de du bon type
			if (_inputDelegate != null && _inputDelegate is IInputSingleDelegate)
			{
				(_inputDelegate as IInputSingleDelegate).inputPressHandler(pInputType, pTarget, pIsPrimaryInput);
			}
		}
		public function inputReleaseHandler (pInputType:uint, pTarget:DisplayObject, pIsPrimaryInput:Boolean):void
		{
			// Si le delegate est présent de du bon type
			if (_inputDelegate != null && _inputDelegate is IInputSingleDelegate)
			{
				(_inputDelegate as IInputSingleDelegate).inputReleaseHandler(pInputType, pTarget, pIsPrimaryInput);
			}
		}
		
		
		/**
		 * INTERFACE fr.swapp.input.delegate.IInputDragDelegate
		 */
		public function inputDragLock (pInputType:uint, pTarget:DisplayObject):void
		{
			// Si le delegate est présent de du bon type
			if (_inputDelegate != null && _inputDelegate is IInputDragDelegate)
			{
				(_inputDelegate as IInputDragDelegate).inputDragLock(pInputType, pTarget);
			}
		}
		public function inputDragUnlock (pInputType:uint, pTarget:DisplayObject):void
		{
			// Si le delegate est présent de du bon type
			if (_inputDelegate != null && _inputDelegate is IInputDragDelegate)
			{
				(_inputDelegate as IInputDragDelegate).inputDragUnlock(pInputType, pTarget);
			}
		}
		public function inputDragging (pInputType:uint, pTarget:DisplayObject, pDirection:String, pXDelta:Number, pYDelta:Number):Boolean
		{
			// Si le delegate est présent de du bon type
			if (_inputDelegate != null && _inputDelegate is IInputDragDelegate)
			{
				return (_inputDelegate as IInputDragDelegate).inputDragging(pInputType, pTarget, pDirection, pXDelta, pYDelta);
			}
			else
			{
				return false;
			}
		}
		
		
		/**
		 * INTERFACE fr.swapp.input.delegate.IInputTransformDelegate
		 */
		public function inputTransformStartHandler (pInputType:uint, pTarget:DisplayObject):DisplayObject
		{
			// Si le delegate est présent de du bon type
			if (_inputDelegate != null && _inputDelegate is IInputTransformDelegate)
			{
				return (_inputDelegate as IInputTransformDelegate).inputTransformStartHandler(pInputType, pTarget);
			}
			else
			{
				return null;
			}
		}
		public function inputTransformStopHandler (pInputType:uint, pTarget:DisplayObject):void
		{
			// Si le delegate est présent de du bon type
			if (_inputDelegate != null && _inputDelegate is IInputTransformDelegate)
			{
				(_inputDelegate as IInputTransformDelegate).inputTransformStopHandler(pInputType, pTarget);
			}
		}
		public function inputTransformMatrixType (pInputType:uint, pTarget:DisplayObject):uint
		{
			// Si le delegate est présent de du bon type
			if (_inputDelegate != null && _inputDelegate is IInputTransformDelegate)
			{
				return (_inputDelegate as IInputTransformDelegate).inputTransformMatrixType(pInputType, pTarget);
			}
			else
			{
				return 0;
			}
		}
		public function inputTransformHandler (pInputType:uint, pTarget:DisplayObject, pScaleDelta:Number, pRotationDelta:Number, pXDelta:Number, pYDelta:Number, pPoints:uint):Boolean
		{
			// Si le delegate est présent de du bon type
			if (_inputDelegate != null && _inputDelegate is IInputTransformDelegate)
			{
				return (_inputDelegate as IInputTransformDelegate).inputTransformHandler(pInputType, pTarget, pScaleDelta, pRotationDelta, pXDelta, pYDelta, pPoints);
			}
			else
			{
				return false;
			}
		}
		public function inputMatrixTransformHandler (pInputType:uint, pTarget:DisplayObject, pOffsetMatrix:Matrix, pPoints:uint):Boolean
		{
			// Si le delegate est présent de du bon type
			if (_inputDelegate != null && _inputDelegate is IInputTransformDelegate)
			{
				return (_inputDelegate as IInputTransformDelegate).inputMatrixTransformHandler(pInputType, pTarget, pOffsetMatrix, pPoints);
			}
			else
			{
				return false;
			}
		}
	}
}