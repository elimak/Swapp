package fr.swapp.touch.emulator 
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.TouchEvent;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import fr.swapp.core.log.Log;
	import fr.swapp.core.roles.IDisposable;
	import fr.swapp.touch.delegate.ITouchDelegate;
	import fr.swapp.touch.delegate.ITouchDragDelegate;
	import fr.swapp.touch.delegate.ITouchTapDelegate;
	import fr.swapp.touch.errors.TouchError;
	import fr.swapp.utils.ArrayUtils;
	
	/**
	 * @author ZoulouX
	 */
	public class TouchEmulator implements IDisposable
	{
		/**
		 * Les directions
		 */
		public static const HORIZONTAL_DIRECTION			:String						= "horizontal";
		public static const VERTICAL_DIRECTION				:String						= "vertical";
		public static const UNKNOW_DIRECTION				:String						= "unknow";
		
		/**
		 * La sensibilité des dragging sans vitesse.
		 * C'est à dire le nombre de frame sans que le touch bouge qui vont passer avant qu'un touch sans vitesse ne soit dispatché.
		 * 4 par défaut.
		 */
		public static var noVellocityDraggingThreshold		:uint						= 4;
		
		/**
		 * La liste des émulateurs attachés au containers
		 */
		protected static const __emulators					:Dictionary					= new Dictionary(false);
		
		
		/**
		 * La liste des émulateurs attachés au containers
		 */
		static public function get emulators ():Dictionary { return __emulators; }
		
		
		/**
		 * Emuler des GestureTouchEvent sur un container. Si ce container implémente ITouchDelegate, les events seront mappés automatiquement sur gestureTouchHandler.
		 * @param	pTarget : Le container sur lequel on veut émuler les GestureTouchEvent. Peut implémenter ITouchDelegate.
		 * @param	pDelegate : Le delegate de cette emulation (optionnel, si null le target sera utilisé s'il implémente les méthodes de délégation).
		 * @param	pMaxPoints : Le nombre de point maximum a prendre en compte sur le target
		 * @param	pDirectionDetectionMultiplier : Le multiplicateur pour détécter la direction (1 par défaut donc pas de diagonale)
		 * @param	pDoubleTapDelay : Le délais de détéction entre TAP et DOUBLE_TAP, en ms. Par défaut 0 pour ne pas décaller le dispatch des taps.
		 * @return L'émulateur
		 */
		public static function emulate (pTarget:DisplayObject, pDelegate:ITouchDelegate = null, pMaxPoints:int = 2, pDirectionDetectionMultiplier:Number = 1, pDoubleTapDelay:Number = 0):TouchEmulator
		{
			// Créer / retourner
			return new TouchEmulator(pTarget, pDelegate, pMaxPoints, pDirectionDetectionMultiplier, pDoubleTapDelay);
		}
		
		/**
		 * Détacher un émulateur
		 * @param	pTarget : Le container sur lequel on veut arrêter l'émulation
		 */
		public static function demulate (pTarget:DisplayObject):void
		{
			// Si on a un émulateur sur ce container
			if (isEmulated(pTarget))
			{
				// On récupère
				var emulator:IDisposable = (__emulators[pTarget] as IDisposable);
				
				// On le supprime du dico
				__emulators[pTarget] = null;
				delete __emulators[pTarget];
				
				// On le dispose
				emulator.dispose();
			}
		}
		
		/**
		 * Si un container est émulé.
		 * @return True si ce container a un émulateur
		 */
		public static function isEmulated (pTarget:DisplayObject):Boolean
		{
			return __emulators[pTarget] != null;
		}
		
		/**
		 * Les cibles qui ont stoppés un drag
		 */
		protected static var __preventedDragTargets			:Array						= [];
		
		/**
		 * Les cibles qui ont stoppés une transformation
		 */
		protected static var __preventedTransformTargets	:Array						= [];
		
		
		/**
		 * Le container de cet emulateur
		 */
		protected var _rootTarget							:DisplayObject;
		
		/**
		 * Le stage du container
		 */
		protected var _rootStage							:Stage;
		
		/**
		 * Les ids des points
		 */
		protected var _pointsIds							:Array						= [];
		
		/**
		 * Les events
		 */
		protected var _events								:Array						= [];
		
		/**
		 * Les points touch détéctés sur ce container
		 */
		protected var _positions							:Array						= [];
		
		/**
		 * Les directions
		 */
		protected var _directions							:Array						= [];
		
		/**
		 * Les deltas
		 */
		protected var _deltas								:Array						= [];
		
		/**
		 * Le nombre de points
		 */
		protected var _totalPoints							:uint						= 0;
		
		/**
		 * Une instance de point pour faire des calculs
		 */
		protected var _currentPoint							:Point 						= new Point();
		
		/**
		 * Le delegate de cet émulateur
		 */
		protected var _delegate								:ITouchDelegate;
		
		/**
		 * Le multiplicateur pour la détéction de la direction
		 */
		protected var _directionDetectionMultiplier			:Number						= 1;
		
		/**
		 * Le nombre de points maximum (-1 pour ne pas limiter)
		 */
		protected var _maxPoints							:int						= -1;
		
		/**
		 * Le délais de détéction entre TAP et DOUBLE_TAP, en ms. Par défaut 0 pour ne pas décaller le dispatch des taps.
		 */
		protected var _doubleTapDelay						:int						= 0;
		
		/**
		 * Le buffer de dragging sans vitesse
		 */
		protected var _draggingNoMoveBuffer					:int;
		
		
		
		/**
		 * Le delegate de cet émulateur
		 */
		public function get delegate ():ITouchDelegate { return _delegate; }
		public function set delegate (value:ITouchDelegate):void
		{
			// Enregistrer ce delegate
			_delegate = value;
		}
		
		/**
		 * Le multiplicateur pour la détéction de la direction
		 */
		public function get directionDetectionMultiplier ():Number { return _directionDetectionMultiplier; }
		public function set directionDetectionMultiplier (value:Number):void 
		{
			_directionDetectionMultiplier = value;
		}
		
		/**
		 * Le clip cible de l'émulateur
		 */
		public function get target ():DisplayObject { return _rootTarget;}
		
		/**
		 * Le nombre de points détéctés
		 */
		public function get totalPoints ():uint { return _totalPoints; }
		
		/**
		 * Les ID's des points détéctés
		 */
		public function get pointsIds ():Array { return _pointsIds; }
		
		/**
		 * Le nombre de points maximum (-1 pour ne pas limiter)
		 */
		public function get maxPoints ():int { return _maxPoints; }
		
		/**
		 * Le délais de détéction entre TAP et DOUBLE_TAP, en ms. Par défaut 0 pour ne pas décaller le dispatch des taps.
		 */
		public function get doubleTapDelay ():int { return _doubleTapDelay; }
		public function set doubleTapDelay (value:int):void
		{
			_doubleTapDelay = value;
		}
		
		
		/**
		 * Le constructeur
		 * @param	pTarget : Le container sur lequel on veut émuler les GestureTouchEvent. Peut implémenter ITouchDelegate.
		 * @param	pDelegate : Le delegate de cette emulation (optionnel, si null le target sera utilisé s'il implémente les méthodes de délégation).
		 * @param	pMaxPoints : Le nombre de point maximum a prendre en compte sur le target
		 * @param	pDirectionDetectionMultiplier : Le multiplicateur pour détécter la direction (1 par défaut donc pas de diagonale)
		 * @param	pDoubleTapDelay : Le délais de détéction entre TAP et DOUBLE_TAP, en ms. Par défaut 0 pour ne pas décaller le dispatch des taps.
		 */
		public function TouchEmulator (pTarget:DisplayObject, pDelegate:ITouchDelegate = null, pMaxPoints:int = 2, pDirectionDetectionMultiplier:Number = 1, pDoubleTapDelay:Number = 0)
		{
			// TODO: Dispatcher les TAP et les double TAP
			// TODO: Dispatcher les transformations
			// TODO: Dispatcher les transformations matrix
			// TODO: Activer le maxPoints (au touchbegin ne pas aller plus loin si on dépasse la limite)
			
			// Vérifier la validité du container
			if (pTarget == null)
			{
				throw new TouchError("TouchEmulator.construct", "pTarget can't be null in TouchEmulator instanciation.");
				return;
			}
			
			// Désactiver l'ancien émulateur s'il y en avait un
			demulate(pTarget);
			
			// Ajouter ce nouvel émulateur au dico
			__emulators[pTarget] = this;
			
			// Enregistrer le container
			_rootTarget = pTarget;
			
			// Ecouter lorsque le target est supprimé
			_rootTarget.addEventListener(Event.REMOVED_FROM_STAGE, targetRemovedFromStage, false, 0, true);
			
			// Ecouter lorsque le target est ajouté
			if (_rootTarget.stage == null)
				_rootTarget.addEventListener(Event.ADDED_TO_STAGE, targetAddedToStageHandler, false, 0, true);
			else
				targetAddedToStageHandler();
			
			// Ecouter les touch events sur le container et son stage
			_rootTarget.addEventListener(TouchEvent.TOUCH_BEGIN, touchBeginHandler);
			
			// Si on a un delegate
			if (pDelegate != null)
			{
				// On l'enregistre
				delegate = pDelegate;
			}
			
			// Sinon vérifier si le container peut être un delegate
			else if (pTarget is ITouchDelegate)
			{
				// On enregistre le container comme étant le delegate
				delegate = pTarget as ITouchDelegate;
			}
			
			// Enregistrer les paramètres
			_maxPoints = pMaxPoints;
			_directionDetectionMultiplier = pDirectionDetectionMultiplier;
			_doubleTapDelay = pDoubleTapDelay;
		}
		
		/**
		 * Le target est sur le stage
		 */
		protected function targetAddedToStageHandler (event:Event = null):void
		{
			// Enregistrer le stage
			_rootStage = _rootTarget.stage;
		}
		
		/**
		 * Un target a été supprimé
		 */
		protected function targetRemovedFromStage (event:Event):void 
		{
			demulate(event.currentTarget as DisplayObject);
		}
		
		/**
		 * Début d'un touch
		 */
		protected function touchBeginHandler (event:TouchEvent):void 
		{
			// Si on est dans le nombre de points
			if (_totalPoints < _maxPoints)
			{
				// Enregistrer ce point (event / position / delta)
				_events[event.touchPointID]				= event;
				_positions[event.touchPointID] 			= _rootTarget.parent.globalToLocal(new Point(event.stageX, event.stageY));
				_deltas[event.touchPointID] 			= new Point(0, 0);
				
				// Enregistrer l'id de ce point
				_pointsIds[_totalPoints] = event.touchPointID;
				
				// Compter le nombre de points
				// Si c'est le premier point ajouté
				if (++ _totalPoints == 1)
				{
					// Dispatcher le vérouillage du drag
					dispatchDragLock();
					
					// On active l'écoute des moves et des ends
					_rootStage.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
					_rootStage.addEventListener(TouchEvent.TOUCH_MOVE, touchMoveHandler);
					_rootStage.addEventListener(TouchEvent.TOUCH_END, touchEndHandler);
				}
			}
		}
		
		/**
		 * Fin d'un touch
		 */
		protected function touchEndHandler (event:TouchEvent):void 
		{
			// Détécter si l'émulateur n'a pas été disposé
			if (_positions == null)
			{
				Log.warning("TouchEmulator.touchEndHandler problem (disposed).");
				return;
			}
			
			// Détécter si ce point n'est pas dans la liste des points de cet émulateur
			if (!ArrayUtils.contains(_pointsIds, event.touchPointID))
			{
				Log.warning("TouchEmulator.touchEndHandler problem (pointID not found).");
				return;
			}
			
			// Compter le nombre de points
			// Si c'est le dernier point supprimé
			if (-- _totalPoints == 0)
			{
				// On désactive l'écoute des moves et des ends
				_rootStage.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
				_rootStage.removeEventListener(TouchEvent.TOUCH_MOVE, touchMoveHandler);
				_rootStage.removeEventListener(TouchEvent.TOUCH_END, touchEndHandler);
				
				// Purger les deltas si on en a
				if (_deltas[event.touchPointID].x != 0 || _deltas[event.touchPointID].y != 0)
				{
					dispatchDragging();
				}
				
				// Dispatcher le dévérouillage du drag
				dispatchDragUnlock();
				
				// Si ce point n'avait pas bougé
				if (!(event.touchPointID in _directions))
					dispatchTap();
			}
			
			// Supprimer l'id de ce point
			_pointsIds = ArrayUtils.deleteElement(_pointsIds, event.touchPointID);
			
			// Supprimer les events
			delete _events[event.touchPointID];
			
			// Supprimer le point
			delete _positions[event.touchPointID];
			
			// Supprimer le delta du point
			delete _deltas[event.touchPointID];
			
			// Supprimer la direction du point
			delete _directions[event.touchPointID];
		}
		
		/**
		 * Un point touch bouge
		 */
		protected function touchMoveHandler (event:TouchEvent):void 
		{
			// Détécter si l'émulateur n'a pas été disposé
			if (_positions == null)
			{
				Log.warning("TouchEmulator.touchMoveHandler problem (disposed).");
				return;
			}
			
			// Détécter si ce point n'est pas dans la liste des points de cet émulateur
			if (!ArrayUtils.contains(_pointsIds, event.touchPointID))
			{
				Log.warning("TouchEmulator.touchMoveHandler problem (pointID not found).");
				return;
			}
			
			// La position globale du point
			_currentPoint = _rootTarget.parent.globalToLocal(new Point(event.stageX, event.stageY));
			
			// Calculer les deltas
			_deltas[event.touchPointID].x += _currentPoint.x - _positions[event.touchPointID].x;
			_deltas[event.touchPointID].y += _currentPoint.y - _positions[event.touchPointID].y;
			
			// Enregistrer la nouvelle position du point
			_positions[event.touchPointID].x = _currentPoint.x;
			_positions[event.touchPointID].y = _currentPoint.y;
			
			// Si ce point n'a pas de direction
			if (!(event.touchPointID in _directions))
			{
				// Si on déplace significativement plus en X qu'en Y
				if (Math.abs(_deltas[event.touchPointID].x) > Math.abs(_deltas[event.touchPointID].y) * _directionDetectionMultiplier)
				{
					// On est en déplacement horizontal
					_directions[event.touchPointID] = HORIZONTAL_DIRECTION;
				}
				
				// Si on déplace significativement plus en Y qu'en X
				else if (Math.abs(_deltas[event.touchPointID].y) > Math.abs(_deltas[event.touchPointID].x) * _directionDetectionMultiplier)
				{
					// On est en déplacement vertical
					_directions[event.touchPointID] = VERTICAL_DIRECTION;
				}
				
				// Sinon
				else
				{
					// On est en déplacement libre
					_directions[event.touchPointID] = UNKNOW_DIRECTION;
				}
			}
			
			// Enregistrer le nouvel event
			_events[event.touchPointID] = event;
		}
		
		/**
		 * Boucle par frame pour les dispatchs de drag
		 */
		protected function enterFrameHandler (event:Event = null):void
		{
			// On dispatche le dragging
			dispatchDragging();
		}
		
		/**
		 * Dispatcher un TAP sur le delegate
		 */
		protected function dispatchTap ():void
		{
			// Si on a le bon delegate
			if (_delegate != null && _delegate is ITouchTapDelegate)
			{
				// On dispatche
				(_delegate as ITouchTapDelegate).touchTapHandler(_rootTarget);
			}
		}
		
		/**
		 * Dispatcher un DOUBLE_TAP sur le delegate
		 */
		protected function dispatchDoubleTap ():void
		{
			// Si on a le bon delegate
			if (_delegate != null && _delegate is ITouchTapDelegate)
			{
				// On dispatche
				(_delegate as ITouchTapDelegate).touchDoubleTapHandler(_rootTarget, 0);
			}
		}
		
		/**
		 * Dispatcher un DRAG_LOCK sur le delegate
		 */
		protected function dispatchDragLock ():void
		{
			// Si on a le bon delegate
			if (_delegate != null && _delegate is ITouchDragDelegate)
			{
				// Dispatcher
				(_delegate as ITouchDragDelegate).touchDragLock(_rootTarget);
			}
		}
		
		/**
		 * Dispatcher un DRAG_UNLOCK sur le delegate
		 */
		protected function dispatchDragUnlock ():void
		{
			// Si on a le bon delegate
			if (_delegate != null && _delegate is ITouchDragDelegate)
			{
				// Dispatcher
				(_delegate as ITouchDragDelegate).touchDragUnlock(_rootTarget);
				
				// Supprimer l'interception
				if (ArrayUtils.contains(__preventedDragTargets, _rootTarget))
				{
					// Supprimer la cible
					__preventedDragTargets = ArrayUtils.deleteElement(__preventedDragTargets, _rootTarget);
				}
			}
		}
		
		/**
		 * Dispatcher un DRAGGING sur le delegate
		 */
		protected function dispatchDragging ():void
		{
			// Si on a le bon delegate
			// Et une direction
			if (_delegate != null && _delegate is ITouchDragDelegate && _pointsIds[0] in _directions)
			{
				// Si on est dans un container
				if (_rootTarget is DisplayObjectContainer)
				{
					// Si on a un child qui a stoppé la propagation
					for each (var child:DisplayObject in __preventedDragTargets)
					{
						// Si notre target contient un clip qui a stoppé la propagation de drag
						if (child != _rootTarget && (_rootTarget as DisplayObjectContainer).contains(child))
						{
							// On stoppe
							return;
						}
					}
				}
				
				// Les variables de l'appel
				var direction		:String				= _directions[_pointsIds[0]];
				var xDelta			:Number				= 0;
				var yDelta			:Number				= 0;
				var points			:Vector.<Point>		= new Vector.<Point>;
				
				// Parcourir les points qui déplacent
				for each (var pointID:int in _pointsIds)
				{
					// Si ce point a une direction
					if (pointID in _directions)
					{
						// Ajouter la position de ce point à la liste
						points.push(_positions[pointID]);
						
						// Ajouter le delta de ce point au delta total
						xDelta += (_deltas[pointID].x / _pointsIds.length);
						yDelta += (_deltas[pointID].y / _pointsIds.length);
						
						// Remettre ce point à 0
						_deltas[pointID].x = 0;
						_deltas[pointID].y = 0;
					}
				}
				
				// Stopper le dispatch des dragging sans vélocité
				if (
						// Si on n'a pas de vitesse
						// C'est peut être que le touch n'a pas été dispatché
						xDelta == 0
						&&
						yDelta == 0
						
						// Alors on décalle le buffer d'une frame
						// Et si notre buffer ne dépasse pas la limite
						&&
						(_draggingNoMoveBuffer ++ <= noVellocityDraggingThreshold)
					)
				{
					// On ne dispatch pas
					return;
				}
				else
				{
					// Sinon, plus de buffer
					_draggingNoMoveBuffer = 0;
				}
				
				// Dispatcher
				var prevented:Boolean = (_delegate as ITouchDragDelegate).touchDragging(_rootTarget, direction, xDelta, yDelta, points);
				
				// Si le delegate stop la propagation
				if (prevented && !ArrayUtils.contains(__preventedDragTargets, _rootTarget))
				{
					// Ajouter la cible à la liste
					__preventedDragTargets.push(_rootTarget);
				}
				
				// Si le delegate ne stoppe pas la propagation
				else if (!prevented && ArrayUtils.contains(__preventedDragTargets, _rootTarget))
				{
					// Supprimer la cible
					__preventedDragTargets = ArrayUtils.deleteElement(__preventedDragTargets, _rootTarget);
				}
			}
		}
		
		
		/**
		 * Supprimer proprement cet émulateur
		 */
		public function dispose ():void
		{
			// Ne plus écouter les events sur le container et son stage
			_rootTarget.removeEventListener(Event.REMOVED_FROM_STAGE, targetRemovedFromStage);
			_rootTarget.removeEventListener(TouchEvent.TOUCH_BEGIN, touchBeginHandler);
			_rootStage.removeEventListener(TouchEvent.TOUCH_END, touchEndHandler);
			_rootStage.removeEventListener(TouchEvent.TOUCH_MOVE, touchMoveHandler);
			
			// Virer du dico si ce n'est pas déjà fait
			demulate(_rootTarget);
			
			// Supprimer les références
			_delegate = null;
			_rootTarget = null;
			_rootStage = null;
			_positions = null;
		}
	}
}