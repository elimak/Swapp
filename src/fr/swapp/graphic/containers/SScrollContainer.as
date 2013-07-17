package fr.swapp.graphic.containers
{
	import com.greensock.easing.Strong;
	import com.greensock.TweenMax;
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.utils.getTimer;
	import fr.swapp.graphic.base.SComponent;
	import fr.swapp.graphic.base.SContainer;
	import fr.swapp.touch.delegate.ITouchDragDelegate;
	import fr.swapp.touch.delegate.ITouchTapDelegate;
	import fr.swapp.touch.delegate.ITouchTransformDelegate;
	import fr.swapp.touch.dispatcher.TouchDirections;
	import fr.swapp.touch.dispatcher.TouchMatrixOptions;
	
	/**
	 * @author ZoulouX
	 */
	public class SScrollContainer extends SContainer implements ITouchDragDelegate, ITouchTransformDelegate, ITouchTapDelegate
	{
		/**
		 * Available directions
		 */
		public static const HORIZONTAL_DIRECTION	:String							= "horizontal";
		public static const VERTICAL_DIRECTION		:String							= "vertical";
		public static const BOTH_DIRECTIONS			:String							= "both";
		
		
		/**
		 * Scroll inertia (delta multiplier)
		 */
		protected var _scrollInertia				:Number							= 12;
		
		/**
		 * Scroll duration (in seconds)
		 */
		protected var _scrollDuration				:Number							= 0.9;
		
		/**
		 * Scroll duration when content is out of bounds (in seconds)
		 */
		protected var _scrollOutDuration			:Number							= 0.5;
		
		/**
		 * Easing effect for scrolling
		 */
		protected var _scrollEase					:Function						= Strong.easeOut;
		
		/**
		 * Delta multiplier when user drag content out of bounds (set to 0 to disable overflow)
		 */
		protected var _scrollOutMultiplier			:Number							= 0.5;
		
		/**
		 * Allowed direction
		 */
		protected var _direction					:String;
		
		/**
		 * Elements boundaries need to be refreshed
		 */
		protected var _elementsBoundsInvalidated	:Boolean;
		
		/**
		 * Last horizontal delta dragging
		 */
		protected var _lastXDelta					:Number							= 0;
		
		/**
		 * Last vertical delta dragging
		 */
		protected var _lastYDelta					:Number							= 0;
		
		/**
		 * If scrolling is enabled
		 */
		protected var _scrollEnabled				:Boolean						= true;
		
		/**
		 * If dragging lock direction
		 */
		protected var _dragLockDirection			:Boolean 						= true;
		
		/**
		 * If drag is allowed by zooming
		 */
		protected var _allowDragging				:Boolean;
		
		/**
		 * If zooming is allowed
		 */
		protected var _allowZooming					:Boolean;
		
		/**
		 * Last time the user tapped the frame
		 */
		protected var _lastTapTime					:Number;
		
		/**
		 * Max zoom scale
		 */
		protected var _maxZoom						:Number							= 2.5;
		
		
		/**
		 * Scroll inertia (delta multiplier)
		 */
		public function get scrollInertia ():Number { return _scrollInertia; }
		public function set scrollInertia (value:Number):void
		{
			_scrollInertia = value;
		}
		
		/**
		 * Scroll duration (in seconds)
		 */
		public function get scrollDuration ():Number { return _scrollDuration; }
		public function set scrollDuration (value:Number):void
		{
			_scrollDuration = value;
		}
		
		/**
		 * Scroll duration when content is out of bounds (in seconds)
		 */
		public function get scrollOutDuration ():Number { return _scrollOutDuration; }
		public function set scrollOutDuration (value:Number):void
		{
			_scrollOutDuration = value;
		}
		
		/**
		 * Delta multiplier when user drag content out of bounds (set to 0 to disable overflow)
		 */
		public function get scrollOutMultiplier ():Number { return _scrollOutMultiplier; }
		public function set scrollOutMultiplier (value:Number):void
		{
			_scrollOutMultiplier = value;
		}
		
		/**
		 * Allowed direction
		 */
		public function get direction ():String { return _direction; }
		public function set direction (value:String):void
		{
			// Si la direction est différente
			if (_direction != value)
			{
				// Enregistrer la nouvelle valeur
				_direction = value;
				
				// A la verticale
				if (_direction == VERTICAL_DIRECTION)
				{
					// Placer en largeur
					_container.bottom = NaN;
					_container.right = 0;
				}
				
				// A l'horizontale
				else if (_direction == HORIZONTAL_DIRECTION)
				{
					// Placer en hauteur
					_container.right = NaN;
					_container.bottom = 0;
				}
			}
		}
		
		/**
		 * If scrolling is enabled
		 */
		public function get scrollEnabled ():Boolean { return _scrollEnabled; }
		public function set scrollEnabled (value:Boolean):void
		{
			_scrollEnabled = value;
		}
		
		/**
		 * If dragging lock direction
		 */
		public function get dragLockDirection ():Boolean { return _dragLockDirection; }
		public function set dragLockDirection (value:Boolean):void
		{
			_dragLockDirection = value;
		}
		
		public function get allowZooming ():Boolean { return _allowZooming; }
		public function set allowZooming (value:Boolean):void
		{
			_allowZooming = value;
		}
		
		/**
		 * Max zoom scale
		 */
		public function get maxZoom ():Number { return _maxZoom; }
		public function set maxZoom (value:Number):void
		{
			_maxZoom = value;
		}
		
		
		
		/**
		 * Constructor
		 */
		public function SScrollContainer (pDirection:String = "vertical")
		{
			// Relayer
			super();
			
			// Enregister la direction
			direction = pDirection;
		}
		
		/**
		 * Initialisation
		 */
		override public function init():void 
		{
			// Relayer
			super.init();
			
			// Ecouter les mouseWheel
			addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler);
		}
		
		/**
		 * MouseWheel event
		 */
		protected function mouseWheelHandler (event:MouseEvent):void 
		{
			// Enregistrer les derniers deltas
			_lastYDelta -= (event.delta > 0 ? -1 : 1) * 14;
			
			// Actualiser le scroll
			udpateScroll(.6, true);
		}
		
		/**
		 * Initialize container
		 */
		override protected function initContainer ():void
		{
			// Créer le container
			_container = new SComponent();
			
			// Ecouter les redimensionnements
			_container.onResized.add(containerResized);
			
			// Le placer / nommer / ajouter
			_container.into(this);
			
			// Placer en haut à droite
			_container.verticalOffset = 0;
			_container.horizontalOffset = 0;
			_container.top = 0;
			_container.left = 0;
		}
		
		/**
		 * Update scroll if content has changed
		 */
		public function udpateScroll (pAnimationDuration:Number = NaN, pForceBoundariesCheck:Boolean = false):void
		{
			// Si on n'a pas de durée d'animation
			if (!(pAnimationDuration >= 0 || pAnimationDuration < 0))
			{
				// On récupère celle de base
				pAnimationDuration = _scrollDuration;
			}
			
			// Si on doit forcer la récupération des limites par les childs
			if (pForceBoundariesCheck)
			{
				getElementsBoundaries();
			}
			
			// L'objet de tweens
			var tweenProps:Object = {
				ease: _scrollEase
			};
			
			// Si on se déplace à l'horizontale
			if (_direction == HORIZONTAL_DIRECTION || _direction == BOTH_DIRECTIONS)
			{
				// Calculer et ajouter la propriété horizontalOffset
				tweenProps.horizontalOffset = Math.max(_localWidth - _container.width * _container.scaleX, Math.min(_container.horizontalOffset + _lastXDelta * _scrollInertia, 0));
				
				// Diviser la vitesse
				_lastXDelta /= 2;
			}
			
			// Si on se déplace à la verticale
			if (_direction == VERTICAL_DIRECTION || _direction == BOTH_DIRECTIONS)
			{
				// Calculer et ajouter la propriété verticalOffset
				tweenProps.verticalOffset = Math.max(_localHeight - _container.height * _container.scaleY, Math.min(_container.verticalOffset + _lastYDelta * _scrollInertia, 0));
				
				// Diviser la vitesse
				_lastYDelta /= 2;
			}
			
			// Animer selon l'objet des tweens
			TweenMax.killTweensOf(_container);
			TweenMax.to(_container, pAnimationDuration, tweenProps);
		}
		
		/**
		 * Invalidate elements boundaries
		 */
		protected function invalidateElementsBoundaries ():void
		{
			// Si ce n'est pas déjà invalidé
			if (!_elementsBoundsInvalidated)
			{
				// Enregistrer l'état
				_elementsBoundsInvalidated = true;
			}
		}
		
		/**
		 * An element was resized
		 */
		override protected function elementResized ():void
		{
			// Invalider l'espace pris par les éléments
			invalidateElementsBoundaries();
		}
		
		/**
		 * Render phase
		 */
		override protected function renderPhase ():void
		{
			// Relayer
			super.renderPhase();
			
			// Si les limite du contenu a été invalidé
			if (_elementsBoundsInvalidated)
			{
				// Enregistrer
				getElementsBoundaries();
			}
		}
		
		/**
		 * Update elements bounds
		 */
		protected function getElementsBoundaries ():void
		{
			// Remettre à 0
			_container.height = _container.width = 0;
			
			// Parcourir les éléments
			for each (var element:SComponent in _elements)
			{
				// La limite horizontale
				if (_direction == HORIZONTAL_DIRECTION || _direction == BOTH_DIRECTIONS)
				{
					// Récupérer la position de l'élément et garder que le plus grand
					_container.width = Math.max(_container.width, element.x + element.width);
				}
				
				// La limite verticale
				if (_direction == VERTICAL_DIRECTION || _direction == BOTH_DIRECTIONS)
				{
					// Récupérer la position de l'élément et garder que le plus grand
					_container.height = Math.max(_container.height, element.y + element.height);
				}
			}
		}
		
		/**
		 * Drag is locked
		 */
		public function touchDragLock (pTarget:DisplayObject):void
		{
			// Remettre les derniers delta à 0
			_lastXDelta = 0;
			_lastYDelta = 0;
			
			// Le drag est autorisé
			_allowDragging = true;
			
			// Stopper la tween sur le container
			TweenMax.killTweensOf(_container);
		}
		
		/**
		 * Drag is unlocked
		 */
		public function touchDragUnlock (pTarget:DisplayObject):void
		{
			// Si les déplacements sont autorisés
			if (_allowDragging)
			{
				// Actualiser le scroll
				udpateScroll();
			}
		}
		
		/**
		 * While dragging
		 */
		public function touchDragging (pTarget:DisplayObject, pDirection:String, pXDelta:Number, pYDelta:Number):Boolean
		{
			// Si le drag est interdit, on coupe
			if (!_allowDragging)
			{
				return true;
			}
			
			// Si on doit autoriser le drag vers les enfants
			var allowDragForChildren:Boolean = true;
			
			// Si on se déplace à l'horizontale
			if (
					// Si ce container est déplaçable sur l'axe horizontal
					(_direction == HORIZONTAL_DIRECTION || _direction == BOTH_DIRECTIONS)
					&&
					// Et si la direction du touch le permet
					(pDirection == TouchDirections.HORIZONTAL_DIRECTION || pDirection == TouchDirections.UNKNOW_DIRECTION || !_dragLockDirection)
				)
			{
				// Si l'utilisateur dépasse
				if (_container.horizontalOffset > 0 || _container.horizontalOffset < _localWidth - _container.width * _container.scaleX)
				{
					// Si notre multiplicateur est positif
					if (_scrollOutMultiplier > 0)
					{
						// Limiter le delta
						pXDelta *= _scrollOutMultiplier;
						
						// Actualiser la position
						_container.horizontalOffset += pXDelta;
					}
					else
					{
						// Limiter la position
						_container.horizontalOffset = Math.max(_localWidth - _container.width * _container.scaleX, Math.min(_container.horizontalOffset, 0));
					}
				}
				else
				{
					// Actualiser la position
					_container.horizontalOffset += pXDelta;
				}
				
				// Enregistrer les derniers deltas
				_lastXDelta = pXDelta;
				
				// Ne pas autoriser
				allowDragForChildren = false;
			}
			
			// Si on se déplace à la verticale
			if (
					// Si ce container est déplaçable sur l'axe horizontal
					(_direction == VERTICAL_DIRECTION || _direction == BOTH_DIRECTIONS)
					&&
					// Et si la direction du touch le permet
					(pDirection == TouchDirections.VERTICAL_DIRECTION || pDirection == TouchDirections.UNKNOW_DIRECTION || !_dragLockDirection)
				)
			{
				// Si l'utilisateur dépasse
				if (_container.verticalOffset > 0 || _container.verticalOffset < _localHeight - _container.height * _container.scaleY)
				{
					// Si notre multiplicateur est positif
					if (_scrollOutMultiplier > 0)
					{
						// Limiter le delta
						pYDelta *= _scrollOutMultiplier;
						
						// Actualiser la position
						_container.verticalOffset += pYDelta;
					}
					else
					{
						// Limiter la position
						_container.verticalOffset = Math.max(_localHeight - _container.height * _container.scaleY, Math.min(_container.verticalOffset, 0));
					}
				}
				else
				{
					// Actualiser la position
					_container.verticalOffset += pYDelta;
				}
				
				// Enregistrer les derniers deltas
				_lastYDelta = pYDelta;
				
				// Ne pas autoriser
				allowDragForChildren = false;
			}
			
			// Si on doit autoriser le drag vers les enfants
			return allowDragForChildren;
		}
		
		/**
		 * Début d'un pinch / zoom
		 */
		public function touchTransformStartHandler (pTarget:DisplayObject):DisplayObject
		{
			// Si le zoom est autorisé
			if (_allowZooming)
			{
				// On arrête le déplacement
				TweenMax.killTweensOf(_container);
				
				// On interdit les drag
				_allowDragging = false;
				
				// On remet les deltas à 0
				_lastXDelta = 0;
				_lastYDelta = 0;
			}
			
			// Toujours cibler le container
			return _container;
		}
		
		/**
		 * Fin d'un pinch / zoom
		 */
		public function touchTransformStopHandler (pTarget:DisplayObject):void
		{
			// Actualiser le scroll
			udpateScroll();
		}
		
		/**
		 * Le type de transformation à accepter sur la matrice
		 */
		public function touchTransformMatrixType (pTarget:DisplayObject):uint
		{
			// Autoriser le scale et le drag
			return TouchMatrixOptions.SCALE_OPTION | TouchMatrixOptions.DRAG_OPTION;
		}
		
		/**
		 * Transformation matricielle sur le container
		 */
		public function touchMatrixTransformHandler (pTarget:DisplayObject, pTransformationMatrix:Matrix, pPoints:uint):Boolean
		{
			// Si on a 2 points et que le zoom est autorisé
			if (pPoints == 2 && _allowZooming)
			{
				// Appliquer le scale
				_container.scaleX = _container.scaleY = pTransformationMatrix.a;
				
				// Si le scale a été limité
				var scaleLimited:Boolean = false;
				
				// Si le scale est trop grand
				if (_container.scaleX > _maxZoom)
				{
					// On limite le scale
					_container.scaleX = _container.scaleY = _maxZoom;
					
					// Le scale a été limité
					scaleLimited = true;
				}
				
				// Si le scale est trop petit
				else if (_container.width * _container.scaleX < _localWidth)
				{
					// On limite le scale
					_container.scaleX = _container.scaleY = (_localWidth / _container.width);
					
					// Le scale a été limité
					scaleLimited = true;
				}
				
				// Si le container dépasse horizontalement
				if (
					_container.horizontalOffset > 0
					||
					_container.horizontalOffset < _localWidth - (_container.width * _container.scaleX)
					)
				{
					// On actualise la position du container
					pTransformationMatrix.tx -= (pTransformationMatrix.tx - _container.horizontalOffset) * _scrollOutMultiplier;
				}
				
				// Si le container dépasse verticalement
				if (
					_container.verticalOffset > 0
					||
					_container.verticalOffset < _localHeight - (_container.height * _container.scaleY)
					)
				{
					// On actualise la position du container
					pTransformationMatrix.ty -= (pTransformationMatrix.ty - _container.verticalOffset) * _scrollOutMultiplier;
				}
				
				if (!scaleLimited)
				{
					// On actualise la position du container
					_container.horizontalOffset = pTransformationMatrix.tx;
					_container.verticalOffset = pTransformationMatrix.ty;
				}
			}
			
			// Autoriser les transformations
			return true;
		}
		
		/**
		 * Transformation (non utilisé)
		 */
		public function touchTransformHandler (pTarget:DisplayObject, pScaleDelta:Number, pRotationDelta:Number, pXDelta:Number, pYDelta:Number, pPoints:uint):Boolean
		{
			// Autoriser les transformations
			return true;
		}
		
		/**
		 * When user tap
		 */
		public function touchTapHandler (pTarget:DisplayObject, pIsPrimary:Boolean):void
		{
			// Si le zoom est autorisé
			if (_allowZooming && pIsPrimary)
			{
				// Récupérer le temps lorsque l'utilisateur a fait un tap
				var currentTime:Number = getTimer();
				
				// Si ce tap est court par rapport au dernier tap, alors c'est un double tap
				if (currentTime - _lastTapTime < 400)
				{
					// Interdire le dragging
					_allowDragging = false;
					
					// Calculer le zoom minimum
					const minZoom:Number = _container.width / _localWidth;
					
					// Le zoom de destination
					var scaleDestination:Number;
					
					// Vérifier si on est plus proche de l'état zoomé ou dézoomé
					//if (Math.abs(_container.scaleX - _maxZoom) > Math.abs(_container.scaleX - minZoom))
					if (_container.scaleX == minZoom)
					{
						// Aller vers le zoom
						scaleDestination = _maxZoom;
					}
					else
					{
						// Aller vers le dezoom
						scaleDestination = minZoom;
					}
					
					// Zoomer
					TweenMax.killTweensOf(_container);
					TweenMax.to(_container, .5, {
						// Appliquer le scale
						scaleX: scaleDestination,
						scaleY: scaleDestination,
						
						// Centrer horizontalement
						horizontalOffset: - (_container.width * scaleDestination - _localWidth) / 2,
						
						// Centrer verticalement
						verticalOffset: (
							scaleDestination == _maxZoom ? (
								// Si on zoom
								_container.verticalOffset / _container.scaleX * scaleDestination - _localHeight * scaleDestination / 2
							) : (
								// Si on dézoom
								_container.verticalOffset / _container.scaleX * scaleDestination + _localHeight * scaleDestination / 2
							)
						),
						
						// Actualiser le scroll une fois terminé
						onComplete: udpateScroll,
						
						ease: Strong.easeInOut
					});
				}
				
				// Enregistrer le temps de ce tap
				_lastTapTime = currentTime;
			}
		}
		
		public function touchPressHandler (pTarget:DisplayObject):void { }
		
		public function touchReleaseHandler (pTarget:DisplayObject):void { }
	}
}