package fr.swapp.graphic.lists 
{
	import com.greensock.easing.Quad;
	import com.greensock.easing.Strong;
	import com.greensock.TweenMax;
	import flash.display.DisplayObject;
	import flash.geom.Point;
	import fr.swapp.graphic.base.SComponent;
	import fr.swapp.touch.emulator.TouchEmulator;
	import org.osflash.signals.Signal;
	
	/**
	 * @author ZoulouX
	 */
	public class SStepList extends SVirtualList
	{
		/**
		 * La tween en cours
		 */
		protected var _currentScrollTween					:TweenMax;
		
		/**
		 * La durée de l'animation
		 */
		protected var _animationDuration					:Number					= .5;
		
		/**
		 * Le easing de l'animation
		 */
		protected var _animationEase						:Function				= Quad.easeOut;
		
		/**
		 * Le taux de modification de durée de l'animation par rapport à la vélocity (0 pour ne pas prendre en compte la vélocité)
		 */
		protected var _velocityAnimationBreak				:Number					= .006;
		
		/**
		 * La vélocité minimum pour changer de cran sans être à la moitié du déplacement
		 */
		protected var _velocityStepLimit					:int					= 2;
		
		/**
		 * L'index affiché
		 */
		protected var _selectedIndex						:int					= 0;
		
		/**
		 * Lorsque l'index change
		 */
		protected var _onIndexChange						:Signal					= new Signal();
		
		
		
		/**
		 * La durée de l'animation
		 */
		public function get animationDuration ():Number { return _animationDuration; }
		public function set animationDuration (value:Number):void
		{
			// Enregistrer
			_animationDuration = value;
		}
		
		/**
		 * Le easing de l'animation
		 */
		public function get animationEase ():Function { return _animationEase; }
		public function set animationEase (value:Function):void
		{
			// Enregistrer
			_animationEase = value;
		}
		
		/**
		 * Le taux de modification de durée de l'animation par rapport à la vélocity (0 pour ne pas prendre en compte la vélocité)
		 */
		public function get velocityAnimationBreak ():Number { return _velocityAnimationBreak; }
		public function set velocityAnimationBreak (value:Number):void
		{
			// Enregistrer
			_velocityAnimationBreak = value;
		}
		
		/**
		 * La vélocité minimum pour changer de cran sans être à la moitié du déplacement
		 */
		public function get velocityStepLimit ():int { return _velocityStepLimit; }
		public function set velocityStepLimit (value:int):void
		{
			// Enregistrer
			_velocityStepLimit = value;
		}
		
		/**
		 * L'index affiché
		 */
		public function get selectedIndex ():int { return _selectedIndex; }
		public function set selectedIndex (value:int):void
		{
			// Enregistrer
			_selectedIndex = value;
			
			// Annuler la vélocité
			_velocity = 0;
			
			// Replacer directement la liste
			replaceList(true);
		}
		
		/**
		 * Lorsque l'index change
		 */
		public function get onIndexChange ():Signal { return _onIndexChange; }
		
		
		/**
		 * Le constructeur
		 * @param	pDelegate : Le delegate de cette liste qui va fournir les éléments et les informations sur le nombre d'éléments
		 * @param	pOrientation : L'orientation de la liste (voir statiques)
		 */
		public function SStepList (pDelegate:IVirtualListDelegate, pOrientation:String = "vertical")
		{
			// Relayer la construction
			super(pDelegate, pOrientation);
		}
		
		/**
		 * Le contenu a été redimensionné
		 */
		override protected function containerResized ():void
		{
			// Patcher la largeur auto
			getDelegateValues();
			
			// Appliquer la largeur aux éléments existants
			var i:int = _elements.length;
			var element:SComponent;
			while (-- i >= 0)
			{
				// Cibler l'élément
				element = _elements[i];
				
				// Appliquer la largeur totale
				element[_contentSizeVar] = _typicalElementSize;
				
				// Et replacer
				element[_positionVar] = element.index * _typicalElementSize;
			}
			
			// Relayer
			super.containerResized();
		}
		
		/**
		 * Vérouillage du déplacement
		 */
		override public function touchDragLock (pTarget:DisplayObject):void
		{
			// On stoppe la tween en cours
			if (_currentScrollTween != null)
			{
				_currentScrollTween.kill();
				_currentScrollTween = null;
			}
			
			// Le drag est vérouille
			_dragLocked = true;
			
			// La liste n'a pas bougé
			_moved = false;
		}
		
		/**
		 * Dévérouillage du déplacement
		 */
		override public function touchDragUnlock (pTarget:DisplayObject):void
		{
			// Le drag est dévérouillé
			_dragLocked = false;
			
			// Lui appliquer une limite en cas de dépassement
			replaceList();
			
			// Plus de vélocité
			_velocity = 0;
		}
		
		/**
		 * Déplacement
		 */
		override public function touchDragging (pTarget:DisplayObject, pDirection:String, pXDelta:Number, pYDelta:Number, pPoints:Vector.<Point>):Boolean
		{
			// Vérifier la direction du drag
			if (
					pDirection == _dragDirection
					||
					(pDirection == TouchEmulator.UNKNOW_DIRECTION && _dragAllowUnknownDirection)
					||
					_dragAllowOppositeDirection
				)
			{
				// La liste a bougé
				_moved = true;
				
				// Récupérer la vélocité du point
				if (_deltaTouchVar == "pXDelta")
				{
					_velocity = pXDelta;
				}
				else if (_deltaTouchVar == "pYDelta")
				{
					_velocity = pYDelta;
				}
				
				// Enregistrer la vélocité
				var currentVelocity:Number = _velocity;
				
				// Gestion de la vélocité
				replaceList(false);
				
				// On applique cette vélocité au scroll
				_container[_positionVar] += _velocity;
				
				// Actualiser
				updateList();
				
				// Si la vélocité a changé
				if (currentVelocity != _velocity)
				{
					// On bloque les dispatch parent
					return false;
				}
			}
			
			// Autoriser les dispatch parent
			return true;
		}
		
		/**
		 * Actualiser la liste
		 */
		override protected function updateList ():void
		{
			//trace("UDPATE LIST");
			
			// Construire les nouveaux éléments dont on a besoin pour remplir la liste
			buildElements();
			
			// Signaler qu'on a bougé
			_onListMoved.dispatch();
		}
		
		/**
		 * Récupérer les valeurs du delegate pour le prochain traitement
		 */
		override protected function getDelegateValues ():void 
		{
			// Si on a un delegate
			if (_delegate != null)
			{
				// On récupérer les index et la taille moyenne
				_firstElementIndex 	= _delegate.getVListFirstElementIndex(this);
				_lastElementIndex 	= _delegate.getVListLastElementIndex(this);
				_typicalElementSize = _delegate.getVListTipicalElementSize(this);
				
				// Si la taille typique est de 0, on prend la largeur
				if (_typicalElementSize <= 0)
				{
					_typicalElementSize = Math.max(1, _container[_contentSizeVar]);
				}
			}
			else
			{
				_firstElementIndex 	= 0;
				_lastElementIndex 	= 0;
				_typicalElementSize = 0;
			}
		}
		
		
		/**
		 * La liste dépasse, replacer la liste
		 * @param	pImmediate : Replacement immediat
		 */
		override protected function replaceList (pImmediate:Boolean = false):void
		{
			// Vérifier que notre container ai une largeur
			if (_container[_contentSizeVar] > 0)
			{
				// On stoppe la tween
				if (_currentScrollTween != null)
				{
					_currentScrollTween.kill();
					_currentScrollTween = null;
				}
				
				// Calculer le décallage par rapport à la moitié
				var offset:Number = this[_contentSizeVar] / 2 - _typicalElementSize / 2;
				
				// La destination
				var destination:Number;
				
				// La durée de l'animation
				var duration:Number = pImmediate ? 0 : _animationDuration;
				
				// Si on n'est pas en drag
				if (!_dragLocked)
				{
					// Si on est en immediat
					if (pImmediate)
					{
						// On calle par rapport à l'index
						destination = - _selectedIndex * _typicalElementSize + offset;
					}
					else
					{
						// Le décallage par la vélocité
						var velocityDecay:Number = 0;
						
						// Si on a une vélocité, ajouter ou soustraire un cran
						if (_velocity > _velocityStepLimit)
						{
							velocityDecay = _typicalElementSize / 1.9;
						}
						else if (_velocity < - _velocityStepLimit)
						{
							velocityDecay = - _typicalElementSize / 1.9;
						}
						
						// Calculer la position la plus proche
						destination = Math.round((_container[_positionVar] - offset + (velocityDecay)) / _typicalElementSize) * _typicalElementSize + offset;
					}
					
					// Limiter aux positions min et max
					destination = Math.max(
						- _lastElementIndex * _typicalElementSize + offset,
						Math.min(
							destination,
							- _firstElementIndex * _typicalElementSize + offset
						)
					);
					
					// Récupérer le nouvel index
					var newIndex:int = ( - destination + offset) / _typicalElementSize;
					
					// Si l'index est différent
					if (_selectedIndex != newIndex)
					{
						//trace(newIndex);
						
						// Enregistrer le nouvel index
						_selectedIndex = newIndex;
						
						// Signaler
						_onIndexChange.dispatch();
					}
					
					// Limiter la vitesse selon la vélocité
					if (
							(destination < currentScroll && _velocity < 0)
							||
							(destination > currentScroll && _velocity > 0)
						)
					{
						duration = (duration * (1 - Math.abs(_velocity) * _velocityAnimationBreak))
					}
					
					// Appliquer l'animation
					_currentScrollTween = TweenMax.to(this, duration, {
						ease: _animationEase,
						currentScroll: destination
					});
				}
				
				// Vérifier que ça dépasse
				else if (
							_container[_positionVar] < - _lastElementIndex * _typicalElementSize + offset
							||
							_container[_positionVar] > - _firstElementIndex * _typicalElementSize + offset
						)
				{
					// Limiter la vélocité
					_velocity = _velocity / _velocityOutBreak;
				}
			}
		}
		
		/**
		 * Récupérer des informations sur la position
		 */
		override public function getPositionInformations ():Array
		{
			var positionInformations:Array;
			
			if (_delegate != null)
			{
				positionInformations = [_selectedIndex];
			}
			
			return positionInformations;
		}
		
		/**
		 * Définir la position
		 */
		override public function setPositionInformations (pPositionInformations:Array):void
		{
			if (_delegate != null && pPositionInformations != null && pPositionInformations.length == 1)
			{
				selectedIndex = pPositionInformations[0];
			}
		}
		
		/**
		 * Destruction
		 */
		override public function dispose():void 
		{
			_onIndexChange.removeAll();
			super.dispose();
		}
	}
}