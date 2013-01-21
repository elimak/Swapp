package fr.swapp.touch.dispatcher
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import fr.swapp.core.roles.IDisposable;
	import fr.swapp.touch.delegate.ITouchDelegate;
	import fr.swapp.touch.delegate.ITouchDragDelegate;
	import fr.swapp.touch.delegate.ITouchTapDelegate;
	import fr.swapp.touch.delegate.ITouchTransformDelegate;
	import fr.swapp.touch.errors.TouchError;
	
	/**
	 * @author ZoulouX
	 */
	public class TouchDispatcher implements IDisposable
	{
		/**
		 * TouchDispatcher instances
		 */
		protected static var __instances				:Dictionary					= new Dictionary(false);
		
		/**
		 * Get a TouchDispatcher instance for a specific stage. Will create an instance for a stage if not created yet.
		 * @param	pStage : Associated stage. Must be non null.
		 * @param	pEnableMouse : Enable mouse managment
		 * @param	pTapThreshold : Threshold value to correcting false tap on bad touchscreens
		 * @return : TouchDispatcher instance
		 */
		public static function getInstance (pStage:Stage, pEnableMouse:Boolean = true, pTapThreshold:int = 0):TouchDispatcher
		{
			// Vérifier que le stage ne soit pas null
			if (pStage == null)
			{
				throw new TouchError("SWrapper.getInstance", "Stage can't be null.");
				return null;
			}
			
			// Si l'instance associée à ce stage n'existe pas
			if (!(pStage in __instances))
			{
				// On l'a créé
				__instances[pStage] = new TouchDispatcher(new MultitonKey(), pStage, pEnableMouse, pTapThreshold);
			}
			
			// Retourner l'instance
			return __instances[pStage];
		}
		
		/**
		 * Associated stage
		 */
		protected var _stage							:Stage;
		
		/**
		 * Direction multiplier. If 1, direction can't be unknown.
		 */
		protected var _directionDetectionMultiplier		:Number			= 1;
		
		/**
		 * Threshold value to correcting false tap on bad touchscreens
		 */
		protected var _tapThreshold						:int;
		
		/**
		 * All touch start events. TouchId in keys.
		 */
		protected var _events							:Array			= [];
		
		/**
		 * All draggables elements. TouchId in keys, array of delegate in values.
		 */
		protected var _draggables						:Array			= [];
		
		/**
		 * All touchables elements. TouchId in keys, array of delegate in values.
		 */
		protected var _touchables						:Array			= [];
		
		/**
		 * All transformables elements. TouchId in keys, array of delegate in values.
		 */
		protected var _transformables					:Array			= [];
		
		/**
		 * All touch positions. TouchId in keys, point in values.
		 */
		protected var _touchPositions					:Array			= [];
		
		/**
		 * All touch deltas. TouchId in keys, point in values.
		 */
		protected var _touchDeltas						:Array			= [];
		
		/**
		 * All touch directions. TouchId in keys, direction in values.
		 */
		protected var _directions						:Array			= [];
		
		/**
		 * Current threshold values by touchIds
		 */
		protected var _touchThresholders				:Array			= [];
		
		/**
		 * Pressed status for tap delegates
		 */
		protected var _pressedDelegates					:Dictionary 	= new Dictionary();
		
		/**
		 * If TouchDispatcher is disposed
		 */
		protected var _disposed							:Boolean;
		
		/**
		 * Direction multiplier. If 1, direction can't be unknown.
		 */
		public function get directionDetectionMultiplier ():Number { return _directionDetectionMultiplier; }
		public function set directionDetectionMultiplier (value:Number):void
		{
			_directionDetectionMultiplier = value;
		}
		
		/**
		 * Threshold value to correcting false tap on bad touchscreens
		 */
		public function get tapThreshold ():int { return _tapThreshold; }
		public function set tapThreshold (value:int):void
		{
			_tapThreshold = value;
		}
		
		/**
		 * If TouchDispatcher is disposed
		 */
		public function get disposed ():Boolean { return _disposed; }
		
		
		/**
		 * Constructor. Please use TouchDispatcher.getInstance(pStage)
		 */
		public function TouchDispatcher (pMultitonKey:MultitonKey, pStage:Stage, pEnableMouse:Boolean, pTapThreshold:int)
		{
			// Enregistrer le stage
			_stage = pStage;
			
			// Enregistrer le threshold du tap
			_tapThreshold = pTapThreshold;
			
			// Ecouter les touch events
			_stage.addEventListener(TouchEvent.TOUCH_BEGIN, touchBeginHandler);
			_stage.addEventListener(TouchEvent.TOUCH_MOVE, touchMoveHandler);
			_stage.addEventListener(TouchEvent.TOUCH_END, touchEndHandler);
			
			// Si on doit aussi gérer les mouse events
			if (pEnableMouse)
			{
				// Ecouter les mouse events
				_stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
				_stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
				_stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			}
		}
		
		/**
		 * Mouse down
		 */
		protected function mouseDownHandler (event:MouseEvent):void 
		{
			
		}
		
		/**
		 * Mouse Move
		 */
		protected function mouseMoveHandler (event:MouseEvent):void 
		{
			
		}
		
		/**
		 * Mouse Up
		 */
		protected function mouseUpHandler (event:MouseEvent):void 
		{
			
		}
		
		/**
		 * Touch begin
		 */
		protected function touchBeginHandler (event:TouchEvent):void
		{
			// Le target concerné par ce touch
			var target:DisplayObjectContainer;
			
			// Cibler l'id du touch
			var touchId:int = event.touchPointID;
			
			// Si on est sur un displayObjectContainer
			if (event.target is DisplayObjectContainer)
			{
				// On le cible
				target = (event.target as DisplayObjectContainer);
			}
			
			// Si on est sur un displayObject
			else if (event.target is DisplayObject)
			{
				// On cible son parent
				target = (event.target as DisplayObject).parent;
			}
			
			// Si on a trouvé un target
			if (target != null)
			{
				// Cibler le topTarget
				var topTarget:DisplayObject = target;
				
				// Enregistrer la position de ce point
				_touchPositions[touchId] 	= new Point(event.stageX, event.stageY);
				_touchDeltas[touchId] 		= new Point(0, 0);
				_events[touchId] 			= event;
				
				// Remonter jusqu'au stage
				while (target != _stage)
				{
					// Si on est sur un delegate
					if (target is ITouchDelegate)
					{
						// Si on a un threshold sur les tap a patcher
						if (_tapThreshold > 0)
						{
							// Enregistrer le threshold de ce point
							_touchThresholders[touchId] = 0;
						}
						
						// Référencer le delegate adéquat
						if (target is ITouchDragDelegate)
						{
							registerDragDelegate(target as ITouchDragDelegate, event, topTarget);
						}
						if (target is ITouchTapDelegate)
						{
							registerTapDelegate(target as ITouchTapDelegate, event, topTarget);
						}
						if (target is ITouchTransformDelegate)
						{
							registerTransformDelegate(target as ITouchTransformDelegate, event, topTarget);
						}
					}
					
					// Continuer vers le parent
					target = target.parent;
				}
			}
		}
		
		/**
		 * Touch move handler
		 */
		protected function touchMoveHandler (event:TouchEvent):void 
		{
			// Cibler l'id du touch
			var touchId:int = event.touchPointID;
			
			// Calculer la nouvelle position et les deltas de ce point
			computeDeltas(event);
			
			// Calculer les directions
			computeDirection(event);
			
			// Si des draggables sont référencés sur ce point
			// Et si la direction a été renseignée
			if (touchId in _draggables && touchId in _directions)
			{
				// Les parcourir
				var target:DisplayObject;
				var allowed:Boolean;
				for each (var delegate:ITouchDragDelegate in _draggables[touchId])
				{
					//trace("DRAG MOVE", delegate);
					target = (delegate as DisplayObject);
					
					// Dispatcher un dragging avec le bon ratio
					allowed = delegate.touchDragging(
						null,
						_directions[touchId],
						_touchDeltas[touchId].x / target.transform.concatenatedMatrix.a,
						_touchDeltas[touchId].y / target.transform.concatenatedMatrix.d
					);
					
					// Si le draggin n'est pas autorisé
					if (!allowed)
					{
						// On ne fait pas les suivants
						break;
					}
				}
			}
		}
		
		/**
		 * Touch end handler
		 */
		protected function touchEndHandler (event:TouchEvent):void 
		{
			// Cibler l'id du touch
			var touchId:int = event.touchPointID;
			
			// Si des draggables sont référencés sur ce point
			if (touchId in _draggables)
			{
				// Les parcourir
				for each (var touchDragDelegate:ITouchDragDelegate in _draggables[touchId])
				{
					// Dispatcher un unlock
					touchDragDelegate.touchDragUnlock(null);
				}
				
				// Supprimer les delegates de ce point qui n'existe plus
				delete _draggables[touchId];
			}
			
			// Si des touchables sont référencés sur ce point
			if (touchId in _touchables)
			{
				// Les parcourir
				for each (var touchTapDelegate:ITouchTapDelegate in _touchables[touchId])
				{
					// Si on a encore des points
					if (_pressedDelegates[touchTapDelegate] > 1)
					{
						// On enlève ce point
						_pressedDelegates[touchTapDelegate] --;
					}
					
					// Si on n'a plus de points
					else if (_pressedDelegates[touchTapDelegate] <= 1)
					{
						// Dispatcher le release
						touchTapDelegate.touchReleaseHandler(null);
						
						// Si on n'a pas de direction
						if (!(touchId in _directions))
						{
							// Dispatcher le tap
							touchTapDelegate.touchTapHandler(null, event.isPrimaryTouchPoint);
						}
						
						// Virer des pressed
						delete _pressedDelegates[touchTapDelegate];
					}
				}
				
				// Supprimer les delegates de ce point qui n'existe plus
				delete _touchables[touchId];
			}
			
			
			// Supprimer l'event et les positions de ce point
			if (touchId in _events)
			{
				delete _touchThresholders[touchId];
				delete _touchPositions[touchId];
				delete _touchDeltas[touchId];
				delete _directions[touchId];
				delete _events[touchId];
			}
		}
		
		/**
		 * Register a delegate for dragging behavior
		 * @param	pDelegate : The drag delegate
		 * @param	pEvent : The touch start event firing
		 * @param	pTarget : The direct top target
		 */
		protected function registerDragDelegate (pDelegate:ITouchDragDelegate, pEvent:TouchEvent, pTarget:DisplayObject):void
		{
			// Cibler l'id du touch
			var touchId:int = pEvent.touchPointID;
			
			// Si ce point n'a pas de draggable référencé
			if (!(touchId in _draggables))
			{
				// On créé un tableau pour pouvoir référencer plusieurs delegate par point
				_draggables[touchId] = [];
			}
			
			// Référencer ce delegate à ce point
			_draggables[touchId].push(pDelegate);
			
			// Dispatcher un lock sur
			pDelegate.touchDragLock(null);
		}
		
		/**
		 * Register a delegate for tapping behavior
		 * @param	pDelegate : The tap delegate
		 * @param	pEvent : The touch start event firing
		 * @param	pTarget : The direct top target
		 */
		protected function registerTapDelegate (pDelegate:ITouchTapDelegate, pEvent:TouchEvent, pTarget:DisplayObject):void
		{
			// Cibler l'id du touch
			var touchId:int = pEvent.touchPointID;
			
			// Si ce point n'a pas de touchable référencé
			if (!(touchId in _touchables))
			{
				// On créé un tableau pour pouvoir référencer plusieurs delegate par point
				_touchables[touchId] = [];
			}
			
			// Référencer ce delegate à ce point
			_touchables[touchId].push(pDelegate);
			
			// Si le status pressed de ce delegate n'est pas encore enregistrée
			if (!(pDelegate in _pressedDelegates))
			{
				// L'enregistrer
				_pressedDelegates[pDelegate] = 0;
				
				// Dispatcher
				pDelegate.touchPressHandler(null);
			}
			else
			{
				// Ajouter ce point
				_pressedDelegates[pDelegate] ++;
			}
		}
		
		/**
		 * Register a delegate for transform behavior
		 * @param	pDelegate : The transform delegate
		 * @param	pEvent : The touch start event firing
		 * @param	pTarget : The direct top target
		 */
		protected function registerTransformDelegate (pDelegate:ITouchTransformDelegate, pEvent:TouchEvent, pTarget:DisplayObject):void
		{
			// TODO : gestion des delegate transform
			// TODO : gestion des double tap
			// TODO : gestion des targets
		}
		
		/**
		 * Compute deltas and position for a specific point
		 */
		protected function computeDeltas (event:TouchEvent):void
		{
			// Cibler l'id du touch
			var touchId:int = event.touchPointID;
			
			// Si ce touch ID à bien un ou plusieur delegate référencés
			if (touchId in _events)
			{
				// Cibler les points
				var position:Point = _touchPositions[touchId];
				var delta:Point = _touchDeltas[touchId];
				
				// Calculer les deltas
				delta.x = event.stageX - position.x;
				delta.y = event.stageY - position.y;
				
				// Enregistrer la nouvelle position
				position.x = event.stageX;
				position.y = event.stageY;
			}
		}
		
		/**
		 * Get the direction from deltas.
		 */
		protected function computeDirection (event:TouchEvent):void
		{
			// Cibler l'id du touch
			var touchId:int = event.touchPointID;
			
			// Si ce point n'a pas de direction
			if (!(touchId in _directions))
			{
				// Si on a un thresholder en attente
				if (touchId in _touchThresholders && _touchThresholders[touchId] < _tapThreshold)
				{
					// On ajoute la distance
					_touchThresholders[touchId] += Math.sqrt(Math.pow(_touchDeltas[touchId].x , 2) + Math.pow(_touchDeltas[touchId].y, 2));
				}
				
				// Si on déplace significativement plus en X qu'en Y
				else if (Math.abs(_touchDeltas[touchId].x) > Math.abs(_touchDeltas[touchId].y) * _directionDetectionMultiplier)
				{
					// On est en déplacement horizontal
					_directions[touchId] = TouchDirections.HORIZONTAL_DIRECTION;
				}
				
				// Si on déplace significativement plus en Y qu'en X
				else if (Math.abs(_touchDeltas[touchId].y) > Math.abs(_touchDeltas[touchId].x) * _directionDetectionMultiplier)
				{
					// On est en déplacement vertical
					_directions[touchId] = TouchDirections.VERTICAL_DIRECTION;
				}
				
				// Sinon
				else
				{
					// On est en déplacement libre
					_directions[touchId] = TouchDirections.UNKNOW_DIRECTION;
				}
			}
		}
		
		/**
		 * Destruction
		 */
		public function dispose ():void
		{
			// TODO : dispose du touch dispatcher
			
			throw new Error("NOT IMPLEMENTED YET -> TouchDispatcher");
			_disposed = true;
		}
	}
}

/**
 * Private key to secure multiton providing.
 */
internal class MultitonKey {}