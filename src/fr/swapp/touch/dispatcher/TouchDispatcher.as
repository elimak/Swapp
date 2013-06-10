package fr.swapp.touch.dispatcher
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import fr.swapp.core.roles.IDisposable;
	import fr.swapp.touch.delegate.ITouchDelegate;
	import fr.swapp.touch.delegate.ITouchDragDelegate;
	import fr.swapp.touch.delegate.ITouchTapDelegate;
	import fr.swapp.touch.delegate.ITouchTransformDelegate;
	import fr.swapp.touch.errors.TouchError;
	import fr.swapp.utils.ArrayUtils;
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	
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
		 * Direction detection multiplier.
		 */
		protected var _directionDetectionMultiplier		:Number			= 1.5;
		
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
		 * All top targets by touchIds
		 */
		protected var _targets							:Array			= [];
		
		/**
		 * Pressed status for tap delegates
		 */
		protected var _pressedTouchables				:Dictionary 	= new Dictionary();
		
		/**
		 * Pressed status for transform delegates
		 */
		protected var _pressedTransformables			:Dictionary 	= new Dictionary();
		
		/**
		 * When disposed
		 */
		protected var _onDisposed						:Signal			= new Signal();
		
		/**
		 * Reused temp point 
		 */
		protected var _tempPoint						:Point			= new Point();
		
		/**
		 * Total loops needed (0 to disable enterFrame loop)
		 */
		protected var _currentTransformLoop				:uint;
		
		/**
		 * Current transformation center for TransformDelegates
		 */
		protected var _currentCenter					:Dictionary 	= new Dictionary();
		
		/**
		 * Current scale for TransformDelegates
		 */
		protected var _currentScale						:Dictionary 	= new Dictionary();
		
		/**
		 * Current rotation for TransformDelegates
		 */
		protected var _currentRotation					:Dictionary 	= new Dictionary();
		protected var _currentTransformType				:uint;
		
		
		
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
		 * When disposed
		 */
		public function get onDisposed ():ISignal { return _onDisposed; }
		
		
		/**
		 * Constructor. Please use TouchDispatcher.getInstance(pStage)
		 */
		public function TouchDispatcher (pMultitonKey:MultitonKey, pStage:Stage, pEnableMouse:Boolean, pTapThreshold:int)
		{
			// TODO : gestion des delegate transform
			// TODO : gestion des double tap
			// TODO : gestion des swipes via ITouchSwipeDelegate
			// TODO : Ajouter la source de l'event (mouse ou touch)
			//			-> VirtualList pourra avoir des propriété "touchEnabled" et "mouseEnabled" pour agir en fonction.
			//			-> Plus besoin de MouseToTouchEmulator pour dev en mode release pour PC
			//			-> Rendre compatible avec Flash et Air desktop
			
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
				// Enregistrer la position de ce point
				_touchPositions[touchId] 	= new Point(event.stageX, event.stageY);
				_touchDeltas[touchId] 		= new Point(0, 0);
				_events[touchId] 			= event;
				
				// Enregistrer le target
				_targets[touchId] = target;
				
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
							registerDragDelegate(target as ITouchDragDelegate, event);
						}
						if (target is ITouchTapDelegate)
						{
							registerTapDelegate(target as ITouchTapDelegate, event);
						}
						if (target is ITouchTransformDelegate)
						{
							registerTransformDelegate(target as ITouchTransformDelegate, event);
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
			
			// Actualiser l'event
			_events[touchId] = event;
			
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
				for each (var dragDelegate:ITouchDragDelegate in _draggables[touchId])
				{
					// Cibler le delegate en tant que DisplayObject pour calculer la transformation
					target = (dragDelegate as DisplayObject);
					
					// Dispatcher un dragging avec le bon ratio
					allowed = dragDelegate.touchDragging(
						_targets[touchId],
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
			
			// Si des transformables sont référencés sur ce point
			if (touchId in _transformables)
			{
				// Parcourir les delegates 
				for each (var transformDelegate:ITouchTransformDelegate in _transformables[touchId])
				{
					//transformDelegate.touchMatrixTransformHandler();
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
			
			// Si des touchables sont référencés sur ce point
			if (touchId in _touchables)
			{
				// Les parcourir
				for each (var touchTapDelegate:ITouchTapDelegate in _touchables[touchId])
				{
					// Si on a encore des points
					if (_pressedTouchables[touchTapDelegate] > 1)
					{
						// On enlève ce point
						_pressedTouchables[touchTapDelegate] --;
					}
					
					// Si on n'a plus de points
					else if (_pressedTouchables[touchTapDelegate] <= 1)
					{
						// Dispatcher le release
						touchTapDelegate.touchReleaseHandler(_targets[touchId]);
						
						// La position du point par rapport au stage
						_tempPoint.x = event.stageX;
						_tempPoint.y = event.stageY;
						
						// Vérifier la validité du tap
						if (
								// Vérifier si on est toujours sur le target
								(_targets[touchId] as DisplayObjectContainer).contains(event.target as DisplayObject)
								
								// Si ce point n'est pas aussi sur un draggable ou un transformable qui a bougé
								&&
								!(touchId in _draggables && touchId in _directions)
								&&
								!(touchId in _transformables && touchId in _directions)
							)
						{
							// Dispatcher le tap
							touchTapDelegate.touchTapHandler(_targets[touchId], event.isPrimaryTouchPoint);
						}
						
						// Virer des pressed
						delete _pressedTouchables[touchTapDelegate];
					}
					
					// Supprimer les delegates de ce point qui n'existe plus
					delete _touchables[touchId];
				}
			}
			
			// Si des draggables sont référencés sur ce point
			if (touchId in _draggables)
			{
				// Les parcourir
				for each (var touchDragDelegate:ITouchDragDelegate in _draggables[touchId])
				{
					// Dispatcher un unlock
					touchDragDelegate.touchDragUnlock(_targets[touchId]);
				}
				
				// Supprimer les delegates de ce point qui n'existe plus
				delete _draggables[touchId];
			}
			
			// Si des transformables sont référencés sur ce point
			if (touchId in _transformables)
			{
				// Les parcourir
				for each (var touchTransformDelegate:ITouchTransformDelegate in _transformables[touchId])
				{
					// Rechercher si ce delegate est dans un statut pressed de transformables
					if (touchTransformDelegate in _pressedTransformables)
					{
						// Supprimer cet id
						_pressedTransformables[touchTransformDelegate] = ArrayUtils.deleteElement(_pressedTransformables[touchTransformDelegate], touchId);
						
						// Si on a plus qu'un point
						if (_pressedTransformables[touchTransformDelegate].length == 1)
						{
							// On n'a plus besoin de la boucle
							removeTransformLoop();
							
							// On dispatche un stop en lui passant le target
							touchTransformDelegate.touchTransformStopHandler(_targets[touchId]);
						}
						
						// Si on a plus de point
						else if (_pressedTransformables[touchTransformDelegate].length == 0)
						{
							// On supprime l'entrée
							delete _pressedTransformables[touchTransformDelegate];
							
							// Et on supprime toutes les données de transformation
							delete _currentCenter[touchTransformDelegate];
							delete _currentScale[touchTransformDelegate];
							delete _currentRotation[touchTransformDelegate];
						}
					}
				}
				
				// Supprimer les delegates de ce point qui n'existe plus
				delete _transformables[touchId];
			}
			
			
			// Supprimer l'event et les positions de ce point
			if (touchId in _events)
			{
				delete _touchThresholders[touchId];
				delete _touchPositions[touchId];
				delete _touchDeltas[touchId];
				delete _directions[touchId];
				delete _events[touchId];
				delete _targets[touchId];
			}
		}
		
		/**
		 * Register a delegate for dragging behavior
		 * @param	pDelegate : The drag delegate
		 * @param	pEvent : The touch start event firing
		 */
		protected function registerDragDelegate (pDelegate:ITouchDragDelegate, pEvent:TouchEvent):void
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
			pDelegate.touchDragLock(_targets[touchId]);
		}
		
		/**
		 * Register a delegate for tapping behavior
		 * @param	pDelegate : The tap delegate
		 * @param	pEvent : The touch start event firing
		 */
		protected function registerTapDelegate (pDelegate:ITouchTapDelegate, pEvent:TouchEvent):void
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
			if (!(pDelegate in _pressedTouchables))
			{
				// L'enregistrer
				_pressedTouchables[pDelegate] = 0;
				
				// Dispatcher
				pDelegate.touchPressHandler(_targets[touchId]);
			}
			else
			{
				// Ajouter ce point
				_pressedTouchables[pDelegate] ++;
			}
		}
		
		/**
		 * Register a delegate for transform behavior
		 * @param	pDelegate : The transform delegate
		 * @param	pEvent : The touch start event firing
		 */
		protected function registerTransformDelegate (pDelegate:ITouchTransformDelegate, pEvent:TouchEvent):void
		{
			// Cibler l'id du touch
			var touchId:int = pEvent.touchPointID;
			
			// Si ce point n'a pas de transformable référencé
			if (!(touchId in _transformables))
			{
				// On créé un tableau pour pouvoir référencer plusieurs delegate par point
				_transformables[touchId] = [];
			}
			
			// Référencer ce delegate à ce point
			_transformables[touchId].push(pDelegate);
			
			// Si ce delegate n'est toujours pas enregistré
			if (!(pDelegate in _pressedTransformables))
			{
				// Créer le tableau
				_pressedTransformables[pDelegate] = [];
			}
			
			// Ajouter cet id de touch
			_pressedTransformables[pDelegate].push(touchId);
			
			// Si on en a 2
			if (_pressedTransformables[pDelegate].length == 2)
			{
				// On dispatch un start en passant le target
				// Et on récupère la nouvelle cible
				var newTarget:DisplayObject = pDelegate.touchTransformStartHandler(_targets[touchId]);
				
				// Si on a une nouvelle cible
				if (newTarget != null)
				{
					// On écrase cette cible
					_targets[touchId] = newTarget;
				}
				
				// Ajouter une boucle pour la transformation
				addTransformLoop();
			}
		}
		
		/**
		 * Add a transform loop
		 */
		protected function addTransformLoop ():void
		{
			// Incrémenter le nombre de boucles voulues
			_currentTransformLoop ++;
			
			// Si on a une boucle
			if (_currentTransformLoop == 1)
			{
				// Démarrer la boucle
				_stage.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			}
		}
		
		/**
		 * Remove a transform loop
		 */
		protected function removeTransformLoop ():void
		{
			// Décrémenter le nombre de boucles voulues
			_currentTransformLoop --;
			
			// Si on n'a plus de boucle
			if (_currentTransformLoop == 0)
			{
				// Démarrer la boucle
				_stage.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			}
		}
		
		/**
		 * Every frame loop for transform gestures
		 */
		protected function enterFrameHandler (event:Event):void
		{
			// Le delegate ciblé
			var transformDelegate		:ITouchTransformDelegate;
			
			// Le displayObject cible
			var target					:DisplayObject;
			
			// La matrice de transformation de la cible
			var matrix					:Matrix;
			
			// Les id's de chaque point de ce delegate
			var pointIds				:Array;
			
			// Les 2 points
			var p1						:Point;
			var p2						:Point;
			
			// Le centre de transformation
			var center					:Point;
			
			// Les valeurs des centres de scale et rotation
			var a						:Number;
			var b						:Number;
			
			// La distance et l'angle entre les 2 points de transformation
			var distance				:Number;
			var angle					:Number;
			
			// Le décallage horizontal et vertical par rapport à l'ancienne frame
			var centerHorizontalOffset	:Number;
			var centerVerticalOffset	:Number;
			
			// La différence de distance et d'angle par rapport à l'ancienne frame
			var distanceOffset			:Number;
			var angleOffset				:Number;
			
			// Parcourir les delegates transformables
			for (var i:* in _pressedTransformables)
			{
				// Récupérer le delegate
				transformDelegate = (i as ITouchTransformDelegate);
				
				// Récupérer les points de ce délégate
				pointIds = (_pressedTransformables[i] as Array);
				
				// Cibler le displayObject concerné
				target = (_targets[pointIds[1]] as DisplayObject);
				
				// Cibler les 2 points
				p1 = _touchPositions[pointIds[0]];
				p2 = _touchPositions[pointIds[1]];
				
				// Calculer le centre entre les 2 points
				center = new Point(
					((p1.x + p2.x) / 2) / target.parent.transform.concatenatedMatrix.a,
					((p1.y + p2.y) / 2) / target.parent.transform.concatenatedMatrix.d
				);
				
				// Soustraire les positions des 2 points
				a = (p2.x - p1.x) / target.parent.transform.concatenatedMatrix.a;
				b = (p2.y - p1.y) / target.parent.transform.concatenatedMatrix.d;
				
				// Calculer la distance entre les 2 points pour le scale, grâce aux soustractions précédentes
				distance = Math.sqrt(a * a + b * b);
				
				// Calculer l'angle que forment ces 2 points, grâce aux soustractions précédentes (en degrés)
				angle = Math.atan2(b, a) / Math.PI * 180;
				
				// Si ce delegate n'a pas déjà de valeurs de transformations
				if (!(transformDelegate in _currentCenter))
				{
					// Demander le type de transformation
					_currentTransformType = transformDelegate.touchTransformMatrixType(target);
					
					// Les créer et enregistrer les valeurs
					_currentCenter[transformDelegate] = center.clone();
					_currentScale[transformDelegate] = distance;
					_currentRotation[transformDelegate] = angle;
				}
				else
				{
					// Calculer les mouvements du centre
					centerHorizontalOffset = center.x - _currentCenter[transformDelegate].x;
					centerVerticalOffset = center.y - _currentCenter[transformDelegate].y;
					
					// Calculer les mouvements de distance
					distanceOffset = (distance / _currentScale[transformDelegate]);
					
					// Calculer les mouvements de rotation
					angleOffset = angle - _currentRotation[transformDelegate];
					
					// Actualiser les valeurs
					_currentCenter[transformDelegate] = center.clone();
					_currentScale[transformDelegate] = distance;
					_currentRotation[transformDelegate] = angle;
					
					// Dispatcher la transformation
					transformDelegate.touchTransformHandler(target, distanceOffset, angleOffset, centerHorizontalOffset, centerVerticalOffset, pointIds.length);
					
					// Récupérer la matrice du target
					matrix = target.transform.matrix.clone();
					
					// Décaller au centre de transformation
					matrix.translate(- center.x, - center.y);
					
					// Appliquer le scale
					if (_currentTransformType & TouchMatrixOptions.SCALE_OPTION)
					{
						matrix.scale(distanceOffset, distanceOffset);
					}
					
					// Appliquer la rotation
					if (_currentTransformType & TouchMatrixOptions.ROTATION_OPTION)
					{
						matrix.rotate(angleOffset / 180 * Math.PI);
					}
					
					// Replacer le centre de transformation
					matrix.translate(center.x, center.y);
					
					// Appliquer le décallage
					if (_currentTransformType & TouchMatrixOptions.DRAG_OPTION)
					{
						matrix.translate(centerHorizontalOffset, centerVerticalOffset);
					}
					
					// Dispatcher la transformation
					transformDelegate.touchMatrixTransformHandler(target, matrix, pointIds.length);
				}
			}
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
			
			// Signaler et dispatcher
			_onDisposed.dispatch();
			_onDisposed.removeAll();
			_onDisposed = null;
		}
	}
}

/**
 * Private key to secure multiton providing.
 */
internal class MultitonKey {}