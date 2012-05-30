package fr.swapp.graphic.components.lists 
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.geom.Point;
	import fr.swapp.core.pool.ObjectPool;
	import fr.swapp.graphic.base.BaseContainer;
	import fr.swapp.graphic.base.ResizableComponent;
	import fr.swapp.graphic.errors.GraphicalError;
	import fr.swapp.touch.delegate.ITouchDragDelegate;
	import fr.swapp.touch.emulator.TouchEmulator;
	import org.osflash.signals.Signal;
	
	/**
	 * @author ZoulouX
	 */
	public class AVirtualList extends BaseContainer implements ITouchDragDelegate
	{
		/**
		 * L'orientation horizontale
		 */
		public static const HORIZONTAL_ORIENTATION	:String							= "horizontal";
		
		/**
		 * L'orientation verticale
		 */
		public static const VERTICAL_ORIENTATION	:String							= "vertical";
		
		
		/**
		 * Les propriétés de directions
		 */
		protected static const ORIENTATIONS_VAR_NAMES:Object	= {
			horizontal: {
				_positionVar			: "horizontalOffset",
				_contentSizeVar			: "width",
				_contentTotalSizeVar	: "totalWidth",
				_deltaTouchVar			: "pXDelta",
				_scaleVar				: "scaleX",
				_dragDirection			: "horizontal",
				_placementVar1			: "top",
				_placementVar2			: "bottom",
				_containerPlacementVar1	: "left",
				_containerPlacementVar2	: "right"
			},
			vertical: {
				_positionVar			: "verticalOffset",
				_contentSizeVar			: "height",
				_contentTotalSizeVar	: "totalHeight",
				_deltaTouchVar			: "pYDelta",
				_scaleVar				: "scaleY",
				_dragDirection			: "vertical",
				_placementVar1			: "left",
				_placementVar2			: "right",
				_containerPlacementVar1	: "top",
				_containerPlacementVar2	: "bottom"
			}
		}
		
		
		/**
		 * Le delegate de cette liste
		 */
		protected var _delegate						:IVirtualListDelegate;
		
		/**
		 * Lorsque la liste a été déplacée (par l'utilisateur ou le code)
		 */
		protected var _onListMoved					:Signal						= new Signal();
		
		/**
		 * Lorsqu'un élément est ajouté
		 */
		protected var _onElementAdded				:Signal						= new Signal();
		
		/**
		 * Lorsqu'un élément est supprimé
		 */
		protected var _onElementDeleted				:Signal						= new Signal();
		
		/**
		 * La propriété de positionnement pour cette orientation
		 */
		protected var _positionVar					:String						= "";
		
		/**
		 * Le propriété de taille pour cette orientation
		 */
		protected var _contentSizeVar				:String						= "";
		
		/**
		 * Le propriété de taille totale (avec marges) pour cette orientation
		 */
		protected var _contentTotalSizeVar			:String						= "";
		
		/**
		 * La propriété de delta sur les dragEvents pour cette orientation
		 */
		protected var _deltaTouchVar				:String						= "";
		
		/**
		 * La propriété pour le scale
		 */
		protected var _scaleVar						:String						= ""
		
		/**
		 * La direction a vérifier sur les dragEvents
		 */
		protected var _dragDirection				:String 					= "";
		
		/**
		 * Les variables de placement
		 */
		protected var _placementVar1				:String						= "";
		protected var _placementVar2				:String						= "";
		
		/**
		 * Les variables de placement du container
		 */
		protected var _containerPlacementVar1		:String						= "";
		protected var _containerPlacementVar2		:String						= "";
		
		/**
		 * L'orientation de la liste virtuelle
		 */
		protected var _orientation					:String						= "";
		
		/**
		 * Le surchargement des éléments autorisés (peut être le double en mémoire : avant le début et après la fin)
		 */
		protected var _elementsOverLoad				:int						= 0;
		
		/**
		 * Si on autorise le drag sur les dragEvents dont la direction est inconnue
		 */
		protected var _dragAllowUnknownDirection	:Boolean 					= true;
		
		/**
		 * Si on autorise le drag sur les dragEvents dont la direction est inverse à la direction de la liste
		 */
		protected var _dragAllowOppositeDirection	:Boolean 					= false;
		
		/**
		 * Si le drag est vérouille
		 */
		protected var _dragLocked					:Boolean;
		
		/**
		 * Le premier index récupéré depuis le delegate
		 */
		protected var _firstElementIndex			:int;
		
		/**
		 * Le dernier index récupéré depuis le delegate
		 */
		protected var _lastElementIndex				:int;
		
		/**
		 * La taille typique de l'élément
		 */
		protected var _typicalElementSize			:Number						= 0;
		
		/**
		 * Si la liste réagi à la mollette
		 */
		protected var _mouseWheelEnabled			:Boolean;
		
		/**
		 * Si on a besoin de vérifier les dépassements à la prochaine itération
		 */
		protected var _needReplaceCheck				:Boolean;
		
		/**
		 * La vélocité du mouvement de la liste
		 */
		protected var _velocity						:Number						= 0;
		
		/**
		 * Le frein de l'inertie quand la liste dépasse
		 */
		protected var _velocityOutBreak				:Number						= 2;
		
		/**
		 * Ne jamais masquer les éléments
		 */
		protected var _neverHide					:Boolean					= false;
		
		/**
		 * Ne jamais supprimer les éléments
		 */
		protected var _neverRemove					:Boolean					= false;
		
		/**
		 * Pool d'objets
		 */
		protected var _objectPool					:ObjectPool;
		
		/**
		 * Si la liste a été déplacée
		 */
		protected var _moved						:Boolean					= false;
		
		
		/**
		 * Lorsque la liste a été déplacée (par l'utilisateur ou le code)
		 */
		public function get onListMoved ():Signal { return _onListMoved; }
		
		/**
		 * Lorsqu'un élément est ajouté
		 */
		public function get onElementAdded ():Signal { return _onElementAdded; }
		
		/**
		 * Lorsqu'un élément est supprimé
		 */
		public function get onElementDeleted ():Signal {return _onElementDeleted; }
		
		/**
		 * Si on autorise le drag sur les dragEvents dont la direction est inconnue
		 */
		public function get dragAllowUnknownDirection ():Boolean { return _dragAllowUnknownDirection; }
		public function set dragAllowUnknownDirection (value:Boolean):void 
		{
			_dragAllowUnknownDirection = value;
		}
		
		/**
		 * Si on autorise le drag sur les dragEvents dont la direction est inverse à la direction de la liste
		 */
		public function get dragAllowOppositeDirection ():Boolean { return _dragAllowOppositeDirection; }
		public function set dragAllowOppositeDirection (value:Boolean):void 
		{
			_dragAllowOppositeDirection = value;
		}
		
		/**
		 * L'orientation de la liste
		 */
		public function get orientation ():String { return _orientation; }
		public function set orientation (value:String):void 
		{
			// Si on a des infos sur l'orientation
			if (value in ORIENTATIONS_VAR_NAMES)
			{
				// On enregistre l'orientation
				_orientation = value;
				
				// Parcourir les propriétés sur l'orientation et les définir sur cette liste
				for (var i:String in ORIENTATIONS_VAR_NAMES[_orientation])
				{
					this[i] = ORIENTATIONS_VAR_NAMES[_orientation][i];
				}
				
				// Actualiser
				if (stage != null)
					listMovedHandler();
			}
		}
		
		/**
		 * Activer la molette de la souris
		 */
		public function get mouseWheelEnabled ():Boolean { return _mouseWheelEnabled; }
		public function set mouseWheelEnabled (value:Boolean):void 
		{
			_mouseWheelEnabled = value;
		}
		
		/**
		 * Le surchargement des éléments autorisés (peut être le double en mémoire : avant le début et après la fin)
		 */
		public function get elementsOverLoad ():int { return _elementsOverLoad; } 
		public function set elementsOverLoad (value:int):void 
		{
			_elementsOverLoad = value;
		}
		
		/**
		 * Le delegate de cette liste
		 */
		public function get delegate ():IVirtualListDelegate { return _delegate; }
		public function set delegate (value:IVirtualListDelegate):void
		{
			// Enregistrer
			_delegate = value;
			
			// Actualiser
			if (stage != null)
				listMovedHandler();
		}
		
		/**
		 * La position actuelle du scroll
		 */
		public function get currentScroll ():Number { return _container[_positionVar]; }
		public function set currentScroll (value:Number):void 
		{
			// Enregistrer
			_container[_positionVar] = value;
			
			// Actualiser
			if (stage != null)
				listMovedHandler();
		}
		
		/**
		 * Ne jamais masquer les éléments
		 */
		public function get neverHide ():Boolean { return _neverHide; }
		public function set neverHide (value:Boolean):void
		{
			// Enregistrer
			_neverHide = value;
			
			// Actualiser
			if (stage != null)
				listMovedHandler();
		}
		
		/**
		 * Ne jamais supprimer les éléments
		 */
		public function get neverRemove ():Boolean { return _neverRemove; }
		public function set neverRemove (value:Boolean):void
		{
			// Enregistrer
			_neverRemove = value;
			
			// Actualiser
			if (stage != null)
				listMovedHandler();
		}
		
		/**
		 * Pool d'objets
		 */
		public function get objectPool ():ObjectPool { return _objectPool; }
		public function set objectPool (value:ObjectPool):void
		{
			// Enregistrer
			_objectPool = value;
			
			// Actualiser
			if (stage != null)
				listMovedHandler();
		}
		
		
		/**
		 * Le constructeur
		 */
		public function AVirtualList (pDelegate:IVirtualListDelegate, pOrientation:String = "vertical")
		{
			// Relayer
			super();
			
			// Définir une orientation
			orientation = pOrientation;
			
			// Activer le scroll sur les listes verticales
			if (orientation == VERTICAL_ORIENTATION)
				_mouseWheelEnabled = true;
			
			// Enregistrer le delegate
			_delegate = pDelegate;
		}
		
		
		/**
		 * Arrêter la vélocité de la liste
		 */
		public function stopVelocity ():void
		{
			_velocity = 0;
		}
		
		/**
		 * Initialisation du composant
		 */
		override protected function addedHandler (event:Event = null):void
		{
			// Relayer
			super.addedHandler(event);
			
			// Initialiser les intéractions
			initInteractions();
		}
		
		/**
		 * Initialiser les intéractions
		 */
		protected function initInteractions ():void 
		{
			// Ecouter les touch
			TouchEmulator.emulate(this);
			
			// Ecouter la molette
			addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler);
			addEventListener(MouseEvent.CLICK, tapAndClickHandler, true, 1000, false);
			addEventListener(TouchEvent.TOUCH_TAP, tapAndClickHandler, true, 1000, false);
		}
		
		/**
		 * Tap ou click sur la liste
		 */
		protected function tapAndClickHandler (event:Event):void
		{
			// Si la liste a été déplacée
			if (_moved)
			{
				// On désactive le tap et/ou click
				event.stopImmediatePropagation();
				event.stopPropagation();
			}
		}
		
		/**
		 * Déplacement avec la molette
		 */
		protected function mouseWheelHandler (event:MouseEvent):void
		{
			
		}
		
		/**
		 * Vérouillage du déplacement
		 */
		public function touchDragLock (pTarget:DisplayObject):void
		{
			
		}
		
		/**
		 * Dévérouillage du déplacement
		 */
		public function touchDragUnlock (pTarget:DisplayObject):void
		{
			
		}
		
		/**
		 * Déplacement
		 */
		public function touchDragging (pTarget:DisplayObject, pDirection:String, pXDelta:Number, pYDelta:Number, pPoints:Vector.<Point>):Boolean
		{
			return false;
		}
		
		/**
		 * Afficher un index spécifique
		 * @param	pIndex : L'index en question
		 * @param	pAnimationParams : Paramètres de l'animation
		 */
		public function showIndex (pIndex:int = 0, pAnimationParams:Object = null):void
		{
			
		}
		
		/**
		 * Besoin d'un rafraichissement (revérifie les index des éléments)
		 */
		public function update ():void
		{
			// Actualiser
			listMovedHandler();
		}
		
		/**
		 * La liste a bougé
		 */
		protected function listMovedHandler (pNeedReplaceCheck:Boolean = true):void
		{
			// Récupérer les valeurs du delegate
			getDelegateValues();
			
			// Construire les nouveaux éléments dont on a besoin pour remplir la liste
			buildElements();
			
			// Vu qu'on a bougé, vérifier les dépassements à la prochaine itération
			_needReplaceCheck = pNeedReplaceCheck;
			
			// Signaler qu'on a bougé
			_onListMoved.dispatch();
		}
		
		/**
		 * Récupérer les valeurs du delegate pour le prochain traitement
		 */
		protected function getDelegateValues ():void 
		{
			// Si on a un delegate
			if (_delegate != null)
			{
				// On récupérer les index et la taille moyenne
				_firstElementIndex 	= _delegate.getVListFirstElementIndex(this);
				_lastElementIndex 	= _delegate.getVListLastElementIndex(this);
				_typicalElementSize = _delegate.getVListTipicalElementSize(this);
			}
			else
			{
				_firstElementIndex 	= 0;
				_lastElementIndex 	= 0;
				_typicalElementSize = 0;
			}
		}
		
		/**
		 * Un élément a changé de taille, il faut les replacer
		 */
		override protected function elementResized ():void
		{
			//trace("ELEMENT RESIZED");
			return;
			
			// Compter le nombre d'éléments
			const total:int = _elements.length;
			
			// Si on a au moins 2 éléments
			if (total > 0)
			{
				// L'élément précédent
				var lastElement:ResizableComponent;
				
				// Parcourir les éléments
				for (var i:int = 0; i < total; i++)
				{
					// Placer selon la taille estimée
					if (i > 0)
					{
						// Sinon on place par rapport à l'ancien élément
						_elements[i][_positionVar] = lastElement[_positionVar] + lastElement[_contentTotalSizeVar];
					}
					
					// Cibler l'ancien élément
					lastElement = _elements[i];
				}
			}
			
			// Replacer la liste
			replaceList(true);
			
			// La liste a bougé
			listMovedHandler(false);
		}
		
		/**
		 * Besoin d'un élément à un index data vers un index d'élément
		 * @param	pFromIndex : L'index data par rapport aux données
		 * @param	pToIndex : L'index de l'élément dans les éléments (-1 pour ajouter à la fin)
		 */
		protected function needElementAt (pFromIndex:int, pToIndex:int = -1):ResizableComponent
		{
			// Si on a un delegate
			if (_delegate != null && stage != null && _container[_contentSizeVar] > 0)
			{
				// Demander cet élément au delegate
				var element:ResizableComponent = _delegate.getVListElementAt(this, pFromIndex);
				
				// Si on a un élément
				if (element != null)
				{
					// Lui spécifier son index
					element.index = pFromIndex;
					
					// Si le composant n'a pas de taille de base, on pioche l'info dans le delegate
					if (!(element[_contentSizeVar] > 0))
					{
						// Si on a une taille typique donnée par le delegate
						if (_typicalElementSize > 0)
						{
							// Appliquer la taille typique du delegate
							element[_contentSizeVar] = _typicalElementSize;
						}
						else
						{
							// Déclancher une erreur et arrêter
							throw new GraphicalError("AVirtualList.needElementAt", "Element " + pFromIndex + " has no size and delegate can't deliver typical size");
							return null;
						}
					}
					
					// Spécifier les dimensions du container
					element[_placementVar1] = 0;
					element[_placementVar2] = 0;
					
					// Compter le nombre d'éléments
					const total:int = _elements.length;
					
					// Si on a pas d'éléments
					if (total == 0)
					{
						// Placer cet élément a une position estimée
						element[_positionVar] = pToIndex * _typicalElementSize;
					}
					else
					{
						// Parcourir les éléments
						var i:int = total;
						while (--i >= 0)
						{
							// Si c'est l'élément d'avant
							if (_elements[i].index == pToIndex - 1)
							{
								// On place après
								element[_positionVar] = _elements[i][_positionVar] + _elements[i][_contentTotalSizeVar];
								break;
							}
							
							// Si c'est l'élément d'après
							else if (_elements[i].index == pToIndex + 1)
							{
								// On place avant
								element[_positionVar] = _elements[i][_positionVar] - element[_contentTotalSizeVar];
								break;
							}
						}
					}
					
					// On l'ajoute
					addElement(element, pToIndex);
					
					// Signaler
					_onElementAdded.dispatch(element);
				}
				
				// Retourner cet élément
				return element;
			}
			else
			{
				return null;
			}
		}
		
		/**
		 * Le contenu a été redimensionné
		 */
		override protected function containerResized ():void
		{
			// Replacer
			replaceList(true);
			
			// La liste a bougé
			listMovedHandler(false);
		}
		
		/**
		 * Récupérer les limites du contenu
		 */
		protected function getContentLimit ():Number
		{
			// La limite de la liste (NaN si pas de limite dépassée)
			var limit:Number;
			
			// La position du premier élément
			var firstElementPosition:Number;
			
			// La position du dernier élément (sa position + sa taille !)
			var lastElementPosition:Number;
			
			// On vérifie si on dépasse sur une limite (début ou fin, début prioritaire)
			// Parcourir les éléments à l'envers
			var currentElement:ResizableComponent;
			var i:int = _elements.length;
			while (--i >= 0)
			{
				// Cibler l'élément
				currentElement = _elements[i];
				
				// Vérifier si on est sur le premier élément
				if (currentElement.index == _firstElementIndex)
				{
					// Enregistrer la position du premier élément
					firstElementPosition = _container[_positionVar] + currentElement[_positionVar];
					
					// Si le premier élément dépasse du container
					if (firstElementPosition > 0)
					{
						// On a donc une limite
						limit = firstElementPosition;
					}
				}
				
				// Si on est sur le dernier élément
				if (currentElement.index == _lastElementIndex)
				{
					// On récupère sa position (et sa taille !)
					lastElementPosition = _container[_positionVar] + currentElement[_positionVar] + currentElement[_contentTotalSizeVar];
					
					// Si sa position dépasse du container
					if (lastElementPosition < _container[_contentSizeVar])
					{
						// On a une limite
						limit = lastElementPosition - _container[_contentSizeVar] - 1;
					}
				}
			}
			
			// Si le premier et le dernier éléments sont dans la vue en entier
			if (
					(firstElementPosition >= 0 || firstElementPosition < 0)
					&&
					(lastElementPosition >= 0 || lastElementPosition < 0)
					&&
					lastElementPosition - firstElementPosition < _container[_contentSizeVar]
				)
			{
				// La limite est sur le premier élément
				limit = firstElementPosition;
			}
			
			// Retourner cette limite
			return limit;
		}
		
		/**
		 * La liste dépasse, replacer la liste
		 * @param	pImmediate : Replacement immediat
		 */
		protected function replaceList (pImmediate:Boolean = false):void
		{
			
		}
		
		/**
		 * Construire les éléments
		 */
		protected function buildElements ():void
		{
			// Si on a un delegate
			if (_delegate != null && _localHeight > 0 && _localWidth > 0)
			{
				//trace("BUILD ELEMENT");
				
				// Les éléments traités
				var element:ResizableComponent;
				var currentIndex:int;
				
				// Calculer les limites
				const beginLimit		:Number = - _container[_containerPlacementVar1] - _container[_positionVar];
				const endLimit			:Number = _container[_containerPlacementVar1] + _container[_contentSizeVar] + _container[_containerPlacementVar2] - _container[_positionVar];
				
				// Les overloads
				var overloadBeginLimit	:Number = beginLimit - _elementsOverLoad * _typicalElementSize;
				var overloadEndLimit	:Number = endLimit + _elementsOverLoad * _typicalElementSize;
				
				// Parcourir les éléments de la liste
				var i:int = _elements.length;
				while (--i >= 0)
				{
					// Cibler l'élément
					element = _elements[i];
					
					// Vérifier si cet élément dépasse de la liste
					if  (
							// On supprime rien si on est en déplacement
							!_dragLocked
							&&
							// On ne supprime pas si on ne doit jamais supprimer
							!_neverRemove
							&&
							// Ne pas supprimer les overloads
							(
								element[_positionVar] + element[_contentTotalSizeVar] <= overloadBeginLimit
								||
								element[_positionVar] >= overloadEndLimit
							)
							&&
							// Supprimer le premier élément que s'il dépasse du début
							(element.index != _firstElementIndex || element[_positionVar] <= beginLimit)
							&&
							// Supprimer le dernier élément que s'il dépasse de la fin
							(element.index != _lastElementIndex || element[_positionVar] >= endLimit)
						)
					{
						trace("DELETED", element.index);
						
						// Effacer l'élément en faisant attention au pooling
						surelyDeleteElement(element);
						
						// Un élément de moins
						i--;
					}
					
					// Sinon on est dans la liste
					else if (!element.visible)
					{
						// Donc afficher cet élément
						element.visible = true;
					}
				}
				
				// Si on a pas d'élément, on demande le courant
				if (_elements.length == 0)
				{
					// Ajouter le premier à sa position théorique
					needElementAt(int((- currentScroll) / _typicalElementSize + .5), 0);
				}
				
				// Si on a au moins un élément
				if (_elements.length > 0)
				{
					// Forcer le rendu sur l'élément
					//_elements[0].render();
					
					// On ajoute les éléments dont on a besoin au début
					while (_elements[0][_positionVar] > overloadBeginLimit)
					{
						// Ajouter à la suite au début
						element = needElementAt(_elements[0].index - 1, 0);
						
						trace("TOP ADDED", _elements[0].index, element);
						
						// Si ce dernier est disponible
						if (element != null)
						{
							// Placer cet élément sous l'élément de l'index suivant
							element[_positionVar] = _elements[1][_positionVar] - element[_contentTotalSizeVar];
							
							// Forcer le rendu
							//element.render();
						}
						else
						{
							// Arrêter l'ajout
							break;
						}
					}
					
					// On ajoute les éléments dont on a besoin à la fin
					while (getElementAt(-1)[_positionVar] + getElementAt(-1)[_contentTotalSizeVar] < overloadEndLimit)
					{
						// Ajouter à la suite à la fin
						element = needElementAt(getElementAt(-1).index + 1, -1);
						
						trace("BOTTOM ADDED", getElementAt(-1).index, element);
						
						// Si ce dernier est disponible
						if (element != null)
						{
							// Placer cet élément sous l'élément de l'index suivant
							element[_positionVar] = getElementAt(-2)[_positionVar] + getElementAt(-2)[_contentTotalSizeVar];
							
							// Forcer le rendu
							//element.render();
						}
						else
						{
							// Arrêter l'ajout
							break;
						}
					}
				}
				
				/*
				
				// Parcourir les éléments de la liste
				var i:int = _elements.length;
				while (--i >= 0)
				{
					// Cibler l'élément
					element = _elements[i];
					
					// Vérifier si cet élément dépasse de la liste
					if (
							// Si on dépasse avant le début
							element[_positionVar] + element[_contentTotalSizeVar] <= beginLimit
							||
							// Ou si on dépasse après la fin
							element[_positionVar] >= endLimit
						)
					{
						// Si c'est un élément supprimable
						if (
								// On supprime rien si on est en déplacement
								!_dragLocked
								&&
								// On ne supprime pas si on ne doit jamais supprimer
								!_neverRemove
								&&
								// Ne pas supprimer les overloads
								(
									element[_positionVar] + element[_contentTotalSizeVar] <= overloadBeginLimit
									||
									element[_positionVar] >= overloadEndLimit
								)
								&&
								// Supprimer le premier élément que s'il dépasse du début
								(element.index != _firstElementIndex || element[_positionVar] <= beginLimit)
								&&
								// Supprimer le dernier élément que s'il dépasse de la fin
								(element.index != _lastElementIndex || element[_positionVar] >= endLimit)
							)
						{
							
							trace("DELETED", element.index);
							
							// Effacer l'élément en faisant attention au pooling
							surelyDeleteElement(element);
							
							// Un élément de moins
							i--;
						}
						
						// Sinon on masque juste cet élément
						else if (element.visible && !_neverHide)
						{
							element.visible = false;
						}
					}
					
					// Sinon on est dans la liste
					else if (!element.visible)
					{
						// Donc afficher cet élément
						element.visible = true;
					}
				}*/
			}
		}
		
		/**
		 * Effacer l'élément en faisant attention au pooling
		 */
		protected function surelyDeleteElement (pElement:ResizableComponent):void
		{
			// Si on a une pool on essaye de flag l'élément
			if (_objectPool != null && _objectPool.flag(pElement))
			{
				// Supprimer l'élément de la liste sans le supprimer de la scène
				
				// Masquer cet élément
				pElement.visible = false;
				
				// La nouvelle liste
				var newElements:Vector.<ResizableComponent> = new Vector.<ResizableComponent>;
				
				// Parcourir les éléments
				for each (var elementToDelete:ResizableComponent in _elements)
				{
					// Si on est pas sur notre élément
					if (pElement != elementToDelete)
					{
						// Ajouter les autres éléments
						newElements.push(elementToDelete)
					}
				}
				
				// Enregistrer le nouveau tableau
				_elements = newElements;
			}
			else
			{
				// On supprime cet élément
				removeElement(pElement);
			}
		}
		
		/**
		 * Récupérer des informations sur la position.
		 * Le tableau peut être null si la liste n'est pas conforme.
		 */
		public function getPositionInformations ():Array
		{
			// Créer le tableau
			var positionInformations:Array;
			
			// Si on a un delegate
			if (_delegate != null)
			{
				// On replace la liste
				replaceList(true);
				
				// Récupérer les valeurs du delegate
				//getDelegateValues();
				
				// On parcour tous les éléments
				var i:int = 0;
				var total:int = _elements.length;
				var element:ResizableComponent;
				while (i < total)
				{
					// Cibler l'élément
					element = _elements[i];
					
					// Dès qu'on a le premier élément qui est conforme (dans les indexs)
					if (element.index >= _firstElementIndex && element.index <= _lastElementIndex && element.visible)
					{
						// On récupère son index, sa position, et la position de la liste
						positionInformations = [
							element.index,
							element[_positionVar],
							_container[_positionVar]
						];
						
						// On ne cherche pas plus loin
						break;
					}
					
					// Passer au suivant
					i ++;
				}
			}
			
			// Retourner le tableau des informations
			return positionInformations;
		}
		
		/**
		 * Remettre la liste à 0
		 */
		public function reset ():void
		{
			setPositionInformations([0, 0, 0]);
		}
		
		/**
		 * Définir la position
		 * @param	pPositionInformations : [index de l'élément à récupérer, position de l'élément à récupérer, position de la liste]
		 */
		public function setPositionInformations (pPositionInformations:Array):void
		{
			// Si on a un delegate et que les informations sont conformes
			if (_delegate != null && pPositionInformations != null && pPositionInformations.length == 3)
			{
				// Si notre élément et bien dans la plage d'index
				if (pPositionInformations[0] >= _delegate.getVListFirstElementIndex(this) && pPositionInformations[0] <= _delegate.getVListLastElementIndex(this))
				{
					// L'élément qui va être traité
					var element:ResizableComponent;
					
					// Si on a des éléments
					if (_elements.length > 0)
					{
						// On supprime tout les éléments (en faisant attention au pooling)
						for each (element in _elements)
						{
							if (!_neverRemove)
							{
								surelyDeleteElement(element);
							}
							else if (!_neverHide)
							{
								element.visible = false;
							}
						}
					}
					
					// Récupérer l'élément
					element = (getElementAt(pPositionInformations[0]) || needElementAt(pPositionInformations[0]));
					
					// Si on a un élément
					if (element != null)
					{
						// Placer le container
						_container[_positionVar] = pPositionInformations[2];
						
						// Placer l'élément
						element[_positionVar] = pPositionInformations[1];
						
						// L'index de l'élément
						element.index = pPositionInformations[0];
						
						// Ajouter l'élément
						addElement(element);
						
						// Afficher l'élément
						element.visible = true;
						
						// Construire les éléments autour de celui ci
						buildElements();
						
						// Appliquer les dépassements de liste
						replaceList(true);
					}
				}
			}
		}
		
		/**
		 * Déstruction
		 */
		override public function dispose ():void
		{
			// Ne plus émuler cet éléments
			TouchEmulator.demulate(this);
			
			// Désactiver les listeners
			removeEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler);
			removeEventListener(MouseEvent.CLICK, tapAndClickHandler, true);
			removeEventListener(TouchEvent.TOUCH_TAP, tapAndClickHandler, true);
			
			// Vider la pool
			if (_objectPool != null)
				_objectPool.clear();
			
			// Relayer
			super.dispose();
		}
	}
}