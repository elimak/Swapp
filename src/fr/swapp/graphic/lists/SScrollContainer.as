package fr.swapp.graphic.lists
{
	import com.greensock.easing.Strong;
	import com.greensock.TweenMax;
	import flash.display.DisplayObject;
	import fr.swapp.graphic.base.SComponent;
	import fr.swapp.graphic.base.SContainer;
	import fr.swapp.touch.delegate.ITouchDragDelegate;
	import fr.swapp.touch.dispatcher.TouchDirections;
	
	/**
	 * @author ZoulouX
	 */
	public class SScrollContainer extends SContainer implements ITouchDragDelegate
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
				// Calculer et ajouter la propriété top
				tweenProps.left = Math.max(_localWidth - _container.width, Math.min(_container.left + _lastXDelta * _scrollInertia, 0));
			}
			
			// Si on se déplace à la verticale
			if (_direction == VERTICAL_DIRECTION || _direction == BOTH_DIRECTIONS)
			{
				// Calculer et ajouter la propriété left
				tweenProps.top = Math.max(_localHeight - _container.height, Math.min(_container.top + _lastYDelta * _scrollInertia, 0));
			}
			
			// Animer selon l'objet des tweens
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
			// Remettre le dernier delta à 0
			_lastYDelta = 0;
			
			// Stopper la tween sur le container
			TweenMax.killTweensOf(_container);
		}
		
		/**
		 * Drag is unlocked
		 */
		public function touchDragUnlock (pTarget:DisplayObject):void
		{
			// Actualiser le scroll
			udpateScroll();
		}
		
		/**
		 * While dragging
		 */
		public function touchDragging (pTarget:DisplayObject, pDirection:String, pXDelta:Number, pYDelta:Number):Boolean
		{
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
				if (_container.left > 0 || _container.left < _localWidth - _container.width)
				{
					// Si notre multiplicateur est positif
					if (_scrollOutMultiplier > 0)
					{
						// Limiter le delta
						pXDelta *= _scrollOutMultiplier;
						
						// Actualiser la position
						_container.left += pXDelta;
					}
					else
					{
						// Limiter la position
						_container.left = Math.max(_localWidth - _container.width, Math.min(_container.left, 0));
					}
				}
				else
				{
					// Actualiser la position
					_container.left += pXDelta;
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
				if (_container.top > 0 || _container.top < _localHeight - _container.height)
				{
					// Si notre multiplicateur est positif
					if (_scrollOutMultiplier > 0)
					{
						// Limiter le delta
						pYDelta *= _scrollOutMultiplier;
						
						// Actualiser la position
						_container.top += pYDelta;
					}
					else
					{
						// Limiter la position
						_container.top = Math.max(_localHeight - _container.height, Math.min(_container.top, 0));
					}
				}
				else
				{
					// Actualiser la position
					_container.top += pYDelta;
				}
				
				// Enregistrer les derniers deltas
				_lastYDelta = pYDelta;
				
				// Ne pas autoriser
				allowDragForChildren = false;
			}
			
			// Si on doit autoriser le drag vers les enfants
			return allowDragForChildren;
		}
	}
}