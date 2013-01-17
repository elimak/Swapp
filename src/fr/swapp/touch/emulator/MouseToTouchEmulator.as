package fr.swapp.touch.emulator 
{
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.display.Stage;
	import flash.events.EventPhase;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import fr.swapp.core.roles.IDisposable;
	import fr.swapp.touch.errors.TouchError;
	
	/**
	 * @author ZoulouX
	 */
	public class MouseToTouchEmulator implements IDisposable
	{
		/**
		 * Déclancher automatiquement l'émulateur si besoin
		 */
		public static function auto (pStage:Stage):void
		{
			// Si le device supporte le touch
			if (Multitouch.supportsTouchEvents)
			{
				// On passe en mode touch
				Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
			}
			else
			{
				// Sinon on émule les touch
				emulate(pStage, true, true, false);
			}
		}
		
		/**
		 * Convertir automatiquement les MouseEvent en TouchEvent sur le stage spécifé.
		 * @param	pStage : Le stage sur lequel vont commencer la capture des MouseEvent et le dispatch des TouchEvent
		 * @param	pAllowMultiTouch : Si l'émulateur autorise les combos multitouch avec les touches shift et ctrl du clavier
		 * @param	pShowPoints : Si l'émulateur doit afficher des points témoin de l'émulation tactile
		 * @param	pKillMouseEvents : Si l'émulateur doit remplacer les MouseEvent ou s'il doit les laisser se propager avec les TouchEvent.
		 * @return : L'objet MouseToTouchEmulator. A stocker s'il doit être disposé.
		 */
		public static function emulate (pStage:Stage, pAllowMultiTouch:Boolean, pShowPoints:Boolean = true, pKillMouseEvents:Boolean = false):MouseToTouchEmulator
		{
			// Créer l'objet, le retourner
			return new MouseToTouchEmulator(pStage, pAllowMultiTouch, pShowPoints, pKillMouseEvents);
		}
		
		/**
		 * Créer un TouchEvent rapidement. Ne doit être utilisé que pour l'émulation ou les tests.
		 * @param	pType : Le type de TouchEvent (ex: TouchEvent.TOUCH_BEGIN)
		 * @param	pId : L'ID du TouchEvent (l'émulateur peut aller de 0 à 1). Si l'ID est 0, la propriété isPrimaryTouchPoint sera à true.
		 * @param	pTarget : L'objet cible pour le bubbling
		 * @param	pLocalX : La position X du TouchEvent
		 * @param	pLocalY : La position Y du TouchEvent
		 * @return : Le TouchEvent correctement instancié
		 */
		public static function createTouchEvent (pType:String, pId:uint, pTarget:InteractiveObject, pLocalX:Number, pLocalY:Number, pBasedMouseEvent:MouseEvent = null):TouchEvent
		{
			// Convertir les position du stage en position locales
			var localPoint:Point = pTarget.globalToLocal(new Point(pLocalX, pLocalY));
			
			// Créer et retourner l'event
			return new TouchEvent(pType, true, false, pId, pId == 0, localPoint.x, localPoint.y, NaN, NaN, NaN, pTarget);
		}
		
		
		/**
		 * Le stage de la racine
		 */
		protected var _stage					:Stage;
		
		/**
		 * Si l'émulateur doit tuer les MouseEvent lors de la propagation des TouchEvents
		 */
		protected var _killMouseEvents				:Boolean;
		
		/**
		 * Le point de pinch posé grâce au clavier
		 */
		protected var _pinchPoint					:Point;
		
		/**
		 * Le point de double swipe posé grâce au clavier
		 */
		protected var _doubleSwipePoint				:Point;
		
		/**
		 * Le décallage pour le point de double swipe
		 */
		protected var _doubleSwipeStartPoint		:Point;
		
		/**
		 * Si le clic est enfoncé
		 */
		protected var _mousePressed					:Boolean;
		
		/**
		 * Le TouchEvent principal simulé
		 */
		protected var _primarySimulatedTouchEvent	:TouchEvent;
		
		/**
		 * Le TouchEvent secondaire simulé
		 */
		protected var _secondarySimulatedTouchEvent	:TouchEvent;
		
		/**
		 * Le constructeur de l'émulateur.
		 * Convertir automatiquement les MouseEvent en TouchEvent sur le stage spécifé.
		 * @param	pStage : Le stage sur lequel vont commencer la capture des MouseEvent et le dispatch des TouchEvent
		 * @param	pAllowMultiTouch : Si l'émulateur autorise les combos multitouch avec les touches shift et ctrl du clavier
		 * @param	pShowPoints : Si l'émulateur doit afficher des points témoin de l'émulation tactile
		 * @param	pKillMouseEvents : Si l'émulateur doit remplacer les MouseEvent ou s'il doit les laisser se propager avec les TouchEvent.
		 * @return : L'objet MouseToTouchEmulator. A stocker s'il doit être disposé.
		 */
		public function MouseToTouchEmulator (pStage:Stage, pAllowMultiTouch:Boolean, pShowPoints:Boolean = true, pKillMouseEvents:Boolean = true)
		{
			// Vérifier si on a un stage racine
			if (pStage == null)
			{
				throw new TouchError("MouseToTouchEmulator.construct", "pStage can't be null in MouseToTouchEmulator instanciation.");
				return;
			}
			
			// Enregistrer son stage
			_stage = pStage;
			
			// Si les MouseEvent doivent vivre
			_killMouseEvents = pKillMouseEvents;
			
			// Si on doit afficher les points
			if (pShowPoints)
				TouchIndicator.enableOn(_stage);
			
			// Ecouter les MouseEvents sur le stage
			_stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, true);
			_stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, true);
			_stage.addEventListener(MouseEvent.CLICK, mouseClickHandler, true);
			
			// Ecouter le clavier pour les combos multitouch (si autorisé)
			if (pAllowMultiTouch)
			{
				_stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
				_stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
			}
		}
		
		/**
		 * Dispatcher un TouchEvent pour le point principal
		 * @param	pType : Le type de TouchEvent dispatché
		 * @param	pTarget : La cible du dispatch
		 */
		protected function dispatchPrimaryPoint (pType:String, pTarget:InteractiveObject):void
		{
			// Créer le TouchEvent émulé
			_primarySimulatedTouchEvent = createTouchEvent(
				pType,
				0,
				pTarget,
				_stage.mouseX,
				_stage.mouseY
			);
			
			// Le dispatcher depuis la racine
			pTarget.dispatchEvent(_primarySimulatedTouchEvent);
		}
		
		/**
		 * Dispatcher un TouchEvent pour le point secondaire
		 * @param	pType : Le type de TouchEvent dispatché
		 * @param	pTarget : La cible du dispatch
		 */
		protected function dispatchSecondaryPoint (pType:String, pTarget:InteractiveObject):void
		{
			// Si on a un point de pinch
			if (_pinchPoint != null)
			{
				// On dispatche le second en calculant la position selon le point de pinch
				_secondarySimulatedTouchEvent = createTouchEvent(
					pType,
					1,
					pTarget,
					_pinchPoint.x + (_pinchPoint.x - _stage.mouseX),
					_pinchPoint.y + (_pinchPoint.y - _stage.mouseY)
				);
				pTarget.dispatchEvent(_secondarySimulatedTouchEvent);
			}
			
			// Sinon si on a un point de double swipe
			else if (_doubleSwipePoint != null)
			{
				// Si on commence le déplacement du second point
				if (pType == TouchEvent.TOUCH_BEGIN)
				{
					// On calcule et mémorise le décallage
					_doubleSwipeStartPoint = new Point(
						(_doubleSwipePoint.x - _stage.mouseX) * 2,
						(_doubleSwipePoint.y - _stage.mouseY) * 2
					);
				}
				
				// On dispatche le second en calculant la position selon le point de double swipe
				_secondarySimulatedTouchEvent = createTouchEvent(
					pType,
					1,
					pTarget,
					_stage.mouseX + _doubleSwipeStartPoint.x,
					_stage.mouseY + _doubleSwipeStartPoint.y
				);
				pTarget.dispatchEvent(_secondarySimulatedTouchEvent);
				
				// On supprime le décallage
				if (pType == TouchEvent.TOUCH_END)
					_doubleSwipeStartPoint = null;
			}
		}
		
		/**
		 * Click
		 * @param	event
		 */
		protected function mouseClickHandler (event:MouseEvent):void
		{
			// Dispatcher un TouchTap
			dispatchPrimaryPoint(TouchEvent.TOUCH_TAP, event.target as InteractiveObject);
		}
		
		/**
		 * MouseDown
		 * @param	event
		 */
		protected function mouseDownHandler (event:MouseEvent):void 
		{
			// Si on est en phase de capture
			if (event.eventPhase == EventPhase.CAPTURING_PHASE)
			{
				// Le clic est enfoncé
				_mousePressed = true;
				
				// Tuer les MouseEvent si besoin
				if (_killMouseEvents)
					event.stopImmediatePropagation();
				
				// Masquer le curseur si on a un visuel
				if (TouchIndicator.isEnabledOn(_stage))
					Mouse.hide();
				
				// Dispatcher le TOUCH_BEGIN du point principal
				dispatchPrimaryPoint(TouchEvent.TOUCH_BEGIN, event.target as InteractiveObject);
				
				// Dispatcher si on a un point de pinch ou un point de double swipe
				dispatchSecondaryPoint(TouchEvent.TOUCH_BEGIN, event.target as InteractiveObject);
				
				// Ecouter les mouvements
				_stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler, true);
			}
		}
		
		/**
		 * MouseMove
		 * @param	event
		 */
		protected function mouseMoveHandler (event:MouseEvent):void 
		{
			// Si on est en phase de capture
			if (event.eventPhase == EventPhase.CAPTURING_PHASE)
			{
				// Tuer les MouseEvent si besoin
				if (_killMouseEvents)
					event.stopImmediatePropagation();
				
				// Dispatcher le TOUCH_MOVE du point principal
				dispatchPrimaryPoint(TouchEvent.TOUCH_MOVE, event.target as InteractiveObject);
				
				// Dispatcher si on a un point de pinch ou un point de double swipe
				dispatchSecondaryPoint(TouchEvent.TOUCH_MOVE, event.target as InteractiveObject);
			}
		}
		
		/**
		 * MouseUp
		 * @param	event
		 */
		protected function mouseUpHandler (event:MouseEvent):void 
		{
			// Si on est en phase de capture
			if (event.eventPhase == EventPhase.CAPTURING_PHASE)
			{
				// Le clic est relâché
				_mousePressed = false;
				
				// Ne plus écouter les mouvements
				_stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler, true);
				
				// Tuer les MouseEvent si besoin
				if (_killMouseEvents)
					event.stopImmediatePropagation();
				
				// Afficher le curseur si on a un visuel
				if (TouchIndicator.isEnabledOn(_stage))
					Mouse.show();
				
				// Dispatcher le TOUCH_END du point principal
				dispatchPrimaryPoint(TouchEvent.TOUCH_END, event.target as InteractiveObject);
				
				// Dispatcher si on a un point de pinch ou un point de double swipe
				dispatchSecondaryPoint(TouchEvent.TOUCH_END, event.target as InteractiveObject);
			}
		}
		
		/**
		 * Début d'un combo clavier
		 * @param	event
		 */
		protected function keyDownHandler (event:KeyboardEvent):void 
		{
			// Si on est sur la touche contrôle et si on a pas déjà un point de pinch
			if (event.keyCode == Keyboard.CONTROL && _pinchPoint == null)
			{
				// On pose le point de pinch
				_pinchPoint = new Point(_stage.mouseX, _stage.mouseY);
				
				// Si le clic est déjà enfoncé on dispatche le begin du point secondaire
				if (_mousePressed)
					dispatchSecondaryPoint(TouchEvent.TOUCH_BEGIN, _primarySimulatedTouchEvent.target as InteractiveObject);
				
				// Afficher la croix
				if (TouchIndicator.isEnabledOn(_stage))
					TouchIndicator.showCross(_stage, _pinchPoint.x, _pinchPoint.y);
			}
			
			// Si on est sur la touche shift et qu'on a pas déjà un point de pinch ou de double swipe
			if (event.keyCode == Keyboard.SHIFT && _doubleSwipePoint == null)
			{
				// On pose le point de double swipe
				_doubleSwipePoint = new Point(_stage.mouseX, _stage.mouseY);
				
				// Si le clic est déjà enfoncé on dispatche le begin du point secondaire
				if (_mousePressed)
					dispatchSecondaryPoint(TouchEvent.TOUCH_BEGIN, _primarySimulatedTouchEvent.target as InteractiveObject);
				
				// Afficher la croix
				if (TouchIndicator.isEnabledOn(_stage))
					TouchIndicator.showCross(_stage, _doubleSwipePoint.x, _doubleSwipePoint.y);
			}
		}
		
		/**
		 * Fin d'un combo clavier
		 * @param	event
		 */
		protected function keyUpHandler (event:KeyboardEvent):void 
		{
			// Si on relâche la touche contrôle et qu'on était en pinch
			if (event.keyCode == Keyboard.CONTROL && _pinchPoint != null)
			{
				// Si le clic est encore enfoncé, on dispatche la fin du point secondaire
				if (_mousePressed)
					dispatchSecondaryPoint(TouchEvent.TOUCH_END, _secondarySimulatedTouchEvent.target as InteractiveObject);
				
				// Supprimer le point de pinch
				_pinchPoint = null;
				
				// Masquer la croix
				if (TouchIndicator.isEnabledOn(_stage))
					TouchIndicator.hideCross(_stage);
			}
			
			// Si on relâche la touche shift et qu'on était en double swipe
			if (event.keyCode == Keyboard.SHIFT && _doubleSwipePoint != null)
			{
				// Si le clic est encore enfoncé, on dispatche la fin du point secondaire
				if (_mousePressed)
					dispatchSecondaryPoint(TouchEvent.TOUCH_END, _secondarySimulatedTouchEvent.target as InteractiveObject);
				
				// Supprimer le point de double swipe
				_doubleSwipePoint = null;
				
				// Masquer la croix
				if (TouchIndicator.isEnabledOn(_stage))
					TouchIndicator.hideCross(_stage);
			}
		}
		
		/**
		 * Détruire l'objet
		 */
		public function dispose ():void
		{
			// On n'écoute plus la souris
			_stage.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, true);
			_stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler, true);
			_stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, true);
			_stage.removeEventListener(MouseEvent.CLICK, mouseClickHandler, true);
			
			// On écoute plus le clavier
			_stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			_stage.removeEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
			
			// On masque les indications de touch
			TouchIndicator.disableOn(_stage);
			
			// On vire les références au stage
			_stage == null;
			
			// On vire les events (qui peuvent avoir des références au targets)
			_primarySimulatedTouchEvent = null;
			_secondarySimulatedTouchEvent = null;
		}
	}
}