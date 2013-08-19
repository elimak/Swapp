package fr.swapp.graphic.threedee
{
	import away3d.cameras.Camera3D;
	import away3d.core.base.Object3D;
	import com.greensock.easing.Strong;
	import com.greensock.TweenMax;
	import flash.display.DisplayObject;
	import flash.geom.Matrix;
	import flash.geom.Vector3D;
	import fr.swapp.input.delegate.IInputDragDelegate;
	import fr.swapp.input.delegate.IInputTransformDelegate;
	
	/**
	 * @author ZoulouX
	 */
	public class AwayCameraController implements IInputDragDelegate, IInputTransformDelegate
	{
		/**
		 * La camera 3D
		 */
		protected var _camera					:Camera3D;
		
		/**
		 * Le target de la camera
		 */
		protected var _cameraTarget				:Vector3D						= new Vector3D();
		
		/**
		 * Le scale de la scène
		 */
		protected var _sceneScale				:Number							= 1;
		
		/**
		 * Si on autorise la camera à être déplacée
		 */
		protected var _cameraFreeMode			:Boolean						= false;
		
		/**
		 * Si le déplacement de la camera est utilisé
		 */
		protected var _cameraMoving				:Boolean;
		
		/**
		 * La distance de la camera en mode déplacement libre
		 */
		protected var _cameraDistance			:Number							= 0;
		
		/**
		 * La distance min et max
		 */
		protected var _cameraDistanceMin		:Number							= 0;
		protected var _cameraDistanceMax		:Number							= Number.POSITIVE_INFINITY;
		
		/**
		 * Le delta de la distance de la camera
		 */
		protected var _cameraDistanceDelta		:Number							= 0;
		
		/**
		 * L'inertie de la camera
		 */
		protected var _cameraInertia			:Number							= 0.8;
		
		/**
		 * La différence de déplacement pour la camera
		 */
		protected var _cameraRevolutionDeltaX	:Number							= 0;
		protected var _cameraRevolutionDeltaY	:Number							= 0;
		
		/**
		 * La révolution de la camera
		 */
		protected var _cameraXRevolution		:Number							= 0;
		protected var _cameraYRevolution		:Number							= 0;
		
		/**
		 * Le centre de rotation de la camera
		 */
		protected var _cameraRevolutionCenter	:Vector3D						= new Vector3D();
		
		/**
		 * Les positions verticales limites de déplacement de la camera
		 */
		protected var _cameraMaxY				:Number							= Number.POSITIVE_INFINITY;
		protected var _cameraMinY				:Number							= Number.NEGATIVE_INFINITY;
		
		/**
		 * Les diviseurs si on dépasse la limite vertical
		 */
		protected var _cameraOverflowRatio		:Number							= 2.5;
		protected var _cameraOverflowSpeed		:Number							= 6;
		
		/**
		 * Les diviseurs de déplacement de la camera
		 */
		protected var _cameraRevolutionXCoef	:Number							= 0.005;
		protected var _cameraRevolutionYCoef	:Number							= 2;
		
		
		/**
		 * Si la camera est en animation
		 */
		public function get cameraAnimating ():Boolean
		{
			return TweenMax.isTweening(_camera) || TweenMax.isTweening(_cameraTarget);
		}
		
		
		/**
		 * Constructeur
		 */
		public function AwayCameraController ()
		{
			construct();
		}
		
		/**
		 * Sous-constructeur
		 */
		protected function construct ():void
		{
			
		}
		
		
		/**
		 * ---------------------------------------------
		 * 			    	ANIMATIONS
		 * ---------------------------------------------
		 */
		
		/**
		 * Animer la camera
		 */
		public function animateCamera (pOptions:Object):void
		{
			// Les variables de l'animation
			var delay		:Number = (("delay" in pOptions && pOptions.delay is Number) ? pOptions.delay as Number : 0);
			var duration	:Number = (("duration" in pOptions && pOptions.duration is Number) ? pOptions.duration as Number : 0);
			var position	:Vector3D = _cameraTarget.clone();
			
			// Si on doit animer le target de la camera
			if ("target" in pOptions)
			{
				// Si on a un objet à cibler
				if ("object" in pOptions.target && pOptions.target.object is Object3D)
				{
					position = (pOptions.target.object as Object3D).position;
				}
				
				// Si on a une position
				else if ("position" in pOptions.target && pOptions.target.position is Vector3D)
				{
					position = (pOptions.target.position as Vector3D);
				}
				
				// Si on a un offset
				if ("offset" in pOptions.target && pOptions.target.offset is Vector3D)
				{
					position = position.add(pOptions.target.offset as Vector3D);
				}
				
				// Si on a une durée
				if ("duration" in pOptions.target && pOptions.target is Number)
				{
					duration = (pOptions.target.duration as Number);
				}
				
				// Si on a un délais
				if ("delay" in pOptions.target && pOptions.target is Number)
				{
					delay = (pOptions.target.delay as Number);
				}
				
				// Scale de la position
				position.scaleBy(_sceneScale);
				
				// Animer le target de la camera
				TweenMax.to(_cameraTarget, duration, {
					x: position.x,
					y: position.y,
					z: position.z,
					
					delay: delay,
					
					ease: ("ease" in pOptions.target ? pOptions.target.ease : Strong.easeInOut),
					
					onComplete: ("complete" in pOptions.target ? pOptions.target.complete : null),
					onCompleteParams: ("completeParams" in pOptions.target ? pOptions.target.completeParams : null)
				});
			}
			
			// Replacer la position par défaut pour la camera
			position = _camera.position.clone();
			
			// Si on doit animer la camera
			if ("body" in pOptions)
			{
				// Si on a un objet à cibler
				if ("object" in pOptions.body && pOptions.body.object is Object3D)
				{
					position = (pOptions.body.object as Object3D).position;
				}
				
				// Si on a une position
				else if ("position" in pOptions.body && pOptions.body.position is Vector3D)
				{
					position = (pOptions.body.position as Vector3D);
				}
				
				// Si on a un offset
				if ("offset" in pOptions.body && pOptions.body.offset is Vector3D)
				{
					position = position.add(pOptions.body.offset as Vector3D);
				}
				
				// Si on a une durée
				if ("duration" in pOptions.body && pOptions.body is Number)
				{
					duration = (pOptions.body.duration as Number);
				}
				
				// Si on a un délais
				if ("delay" in pOptions.body && pOptions.body is Number)
				{
					delay = (pOptions.body.delay as Number);
				}
				
				// Si on a un fov
				if ("fov" in pOptions.body && pOptions.body.fov is Number)
				{
					// Animer le zoom
					TweenMax.to(_camera.lens, duration, {
						fieldOfView: pOptions.body.fov,
						
						delay: delay,
						
						ease: ("ease" in pOptions.body ? pOptions.body.ease : Strong.easeInOut)
					});
				}
				
				// Scale de la position
				position.scaleBy(_sceneScale);
				
				// Animer la camera
				TweenMax.to(_camera, duration, {
					x: position.x,
					y: position.y,
					z: position.z,
					
					delay: delay,
					
					ease: ("ease" in pOptions.body ? pOptions.body.ease : Strong.easeInOut),
					
					onComplete: ("complete" in pOptions.body ? pOptions.body.complete : null),
					onCompleteParams: ("completeParams" in pOptions.body ? pOptions.body.completeParams : null)
				});
			}
		}
		
		/**
		 * Arrêter l'animation de la camera
		 */
		public function stopCameraAnimation ():void
		{
			TweenMax.killTweensOf(_camera);
			TweenMax.killTweensOf(_camera.lens);
			TweenMax.killTweensOf(_cameraTarget);
		}
		
		/**
		 * ---------------------------------------------
		 * 				DEPLACEMENT LIBRE
		 * ---------------------------------------------
		 */
		
		/**
		 * Début du déplacement de la camera
		 */
		public function inputDragLock (pInputType:uint, pTarget:DisplayObject):void
		{
			// Si on est en mode de déplacement libre
			if (_cameraFreeMode)
			{
				// On déplace
				_cameraMoving = true;
			}
		}
		
		/**
		 * Fin du déplacement de la camera
		 */
		public function inputDragUnlock (pInputType:uint, pTarget:DisplayObject):void
		{
			// On ne déplace plus
			_cameraMoving = false;
		}
		
		/**
		 * Déplacement de la camera
		 */
		public function inputDragging (pInputType:uint, pTarget:DisplayObject, pDirection:String, pXDelta:Number, pYDelta:Number):Boolean
		{
			// Si la camera est en déplacement
			if (_cameraFreeMode && _cameraMoving)
			{
				// Enregistrer les deltas
				_cameraRevolutionDeltaX = pXDelta;
				_cameraRevolutionDeltaY = pYDelta;
			}
			
			// Bloquer si la camera est en déplacement
			return _cameraFreeMode;
		}
		
		/**
		 * Actualiser le déplacement libre de la camera
		 */
		protected function updateFreeCameraPosition ():void
		{
			// Si les déplacements libres sont autorisés
			if (_cameraFreeMode)
			{
				// Mémoriser le delta de révolution
				var oldCameraDeltaX:Number = _cameraRevolutionDeltaX;
				var oldCameraDeltaY:Number = _cameraRevolutionDeltaY;
				
				// Si on se déplace
				if (_cameraMoving)
				{
					// Si la camera est trop bas ou trop haute
					if (_cameraYRevolution < _cameraMinY)
					{
						// On réduit le delta vertical
						_cameraRevolutionDeltaY /= 1 + Math.abs(_cameraYRevolution - _cameraMinY) / _cameraOverflowRatio;
					}
					else if (_cameraYRevolution > _cameraMaxY)
					{
						// On réduit le delta vertical
						_cameraRevolutionDeltaY /= 1 + Math.abs(_cameraYRevolution - _cameraMaxY) / _cameraOverflowRatio;
					}
				}
				else
				{
					// Inertie
					_cameraRevolutionDeltaX *= _cameraInertia;
					_cameraRevolutionDeltaY *= _cameraInertia;
					
					// Si la camera est trop bas ou trop haute
					// On la replace
					if (_cameraYRevolution < _cameraMinY)
					{
						_cameraYRevolution -= (_cameraYRevolution - _cameraMinY) / _cameraOverflowSpeed;
					}
					else if (_cameraYRevolution > _cameraMaxY)
					{
						_cameraYRevolution -= (_cameraYRevolution - _cameraMaxY) / _cameraOverflowSpeed;
					}
				}
				
				// Actualiser la révolution de la camera
				_cameraXRevolution += _cameraRevolutionDeltaX * _cameraRevolutionXCoef;
				_cameraYRevolution += _cameraRevolutionDeltaY * _cameraRevolutionYCoef;
				
				// Convertir la révolution en angle
				_camera.x = Math.sin(_cameraXRevolution) * _cameraDistance + 2 * Math.PI - _cameraRevolutionCenter.x;
				_camera.z = Math.cos(_cameraXRevolution) * _cameraDistance + 2 * Math.PI - _cameraRevolutionCenter.z;
				
				// La hauteur de la camera
				_camera.y = _cameraYRevolution;
				
				// Appliquer la distance de la camera
				_cameraDistance += _cameraDistanceDelta;
				
				// Si la distance de la camera dépasse
				if (_cameraDistance < _cameraDistanceMin)
				{
					_cameraDistanceDelta = Math.abs(_cameraDistance - _cameraDistanceMin) / _cameraOverflowSpeed / 2;
				}
				else  if (_cameraDistance > _cameraDistanceMax)
				{
					_cameraDistanceDelta = - Math.abs(_cameraDistance - _cameraDistanceMax) / _cameraOverflowSpeed / 2;
				}
				else
				{
					// Appliquer l'inertie sur le zoom
					_cameraDistanceDelta *= _cameraInertia;
				}
				
				/*
				// Si on se déplace mais qu'il n'y a pas de delta différent
				if (_cameraMoving && oldCameraDeltaX == _cameraRevolutionDeltaX && oldCameraDeltaY == _cameraRevolutionDeltaY)
				{
					// On remet les deltas à 0
					_cameraRevolutionDeltaX = 0;
					_cameraRevolutionDeltaY = 0;
				}
				*/
			}
		}
		
		/**
		 * Activer le dragging de la camera
		 * @param	pCenter : Le centre de révolution de la camera
		 * @param	pDistance : La distance de la camera par rapport au centre de révolution
		 * @param	pMinY : La position vertical min de la camera
		 * @param	pMaxY : La position vertical max de la cameras
		 * @param	pXRevolution : L'angle de révolution X de la camera
		 * @param	pYRevolution : L'angle de révolution Y de la camera
		 * @param	pCameraDistanceMin : La distance min de la camera par rapport à son centre de révolution
		 * @param	pCameraDistanceMin : La distance max de la camera par rapport à son centre de révolution
		 */
		public function enableCameraDragging (pCenter:Vector3D, pDistance:Number = 500, pMinY:Number = Number.NEGATIVE_INFINITY, pMaxY:Number = Number.POSITIVE_INFINITY, pXRevolution:Number = 0, pYRevolution:Number = 0, pCameraDistanceMin:Number = 0, pCameraDistanceMax:Number = Number.POSITIVE_INFINITY):void
		{
			// Enregistrer les paramètres de la révolution
			_cameraRevolutionCenter = pCenter;
			_cameraDistance = pDistance;
			_cameraMinY = pMinY;
			_cameraMaxY = pMaxY;
			_cameraXRevolution = pXRevolution;
			_cameraYRevolution = pYRevolution;
			_cameraDistanceMin = Math.max(0, pCameraDistanceMin);
			_cameraDistanceMax = pCameraDistanceMax;
			
			// Remettre les deltas à 0
			_cameraRevolutionDeltaX = 0;
			_cameraRevolutionDeltaY = 0;
			
			// Activer le mode de déplacement
			_cameraFreeMode = true;
		}
		
		/**
		 * Désactiver le déplacement de la camera
		 */
		public function disableCameraDragging ():void
		{
			// Désactiver le mode de déplacement
			_cameraFreeMode = false;
			_cameraRevolutionDeltaX = 0;
			_cameraRevolutionDeltaY = 0;
		}
		
		/**
		 * Actualiser le target de la camera.
		 * A appeler juste avant le render de la vue
		 */
		public function updateCameraControllerTarget ():void
		{
			_camera.lookAt(_cameraTarget);
		}
		
		
		
		
		
		/* INTERFACE fr.swapp.input.delegate.IInputTransformDelegate */
		public function inputTransformStartHandler (pInputType:uint, pTarget:DisplayObject):DisplayObject
		{
			return null;
		}
		
		public function inputTransformStopHandler (pInputType:uint, pTarget:DisplayObject):void
		{
			
		}
		
		public function inputTransformMatrixType (pInputType:uint, pTarget:DisplayObject):uint
		{
			return 0;
		}
		
		public function inputTransformHandler (pInputType:uint, pTarget:DisplayObject, pScaleDelta:Number, pRotationDelta:Number, pXDelta:Number, pYDelta:Number, pPoints:uint):Boolean
		{
			return false;
		}
		
		public function inputMatrixTransformHandler (pInputType:uint, pTarget:DisplayObject, pOffsetMatrix:Matrix, pPoints:uint):Boolean
		{
			return false;
		}
	}
}