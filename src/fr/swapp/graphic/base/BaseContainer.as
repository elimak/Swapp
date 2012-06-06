package fr.swapp.graphic.base 
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import fr.swapp.graphic.errors.GraphicalError;
	import fr.swapp.graphic.layouts.ILayout;
	
	/**
	 * La classe des containers de base.
	 * @author ZoulouX
	 */
	public class BaseContainer extends ResizableComponent
	{
		/**
		 * Le layout de positionnement des éléments
		 */
		protected var _layout						:ILayout;
		
		/**
		 * Les éléments ajoutés au container
		 */
		protected var _elements						:Vector.<ResizableComponent>		= new Vector.<ResizableComponent>;
		
		/**
		 * Le container contenant les éléments
		 */
		protected var _container					:ResizableComponent;
		
		/**
		 * Ajouter les éléments par addChild
		 */
		protected var _addChildAsElement			:Boolean							= false;
		
		
		/**
		 * Le layout deplacement des éléments associé a ce container
		 */
		public function get layout ():ILayout { return _layout; }
		public function set layout (value:ILayout):void 
		{
			_layout = value;
		}
		
		/**
		 * Les éléments ajoutés au container
		 */
		public function get elements ():Vector.<ResizableComponent>
		{
			// Copier le tableau et le retourner
			return _elements.concat();
		}
		
		/**
		 * Le container contenant les éléments
		 */
		public function get container ():ResizableComponent
		{
			return _container;
		}
		
		/**
		 * Ajouter les éléments par addChild
		 */
		public function get addChildAsAddElement ():Boolean { return _addChildAsElement; }
		public function set addChildAsAddElement (value:Boolean):void 
		{
			_addChildAsElement = value;
		}
		
		
		/**
		 * Le constructeur
		 */
		public function BaseContainer ()
		{
			// Initialiser le container
			initContainer();
		}
		
		
		/**
		 * Initialiser le container des éléments
		 */
		protected function initContainer ():void
		{
			// Créer le container
			_container = new ResizableComponent();
			
			// Ecouter les redimensionnements
			_container.onResized.add(containerResized);
			
			// Le placer / nommer / ajouter
			_container.place(0, 0, 0, 0).into(this);
		}
		
		/**
		 * Le container est redimensionné
		 */
		protected function containerResized ():void
		{
			
		}
		
		/**
		 * Un des éléments à été redimensionné
		 */
		protected function elementResized ():void
		{
			
		}
		
		/**
		 * Un élément a été ajouté.
		 * Peut être lourd si plusieurs éléments sont ajoutés d'un coup.
		 * Voir la méthode addElements et la méthode overridable elementsAdded dans ce cas.
		 * @param	pElement : L'élément qui a été ajouté
		 */
		protected function elementAdded (pElement:ResizableComponent):void
		{
			
		}
		
		/**
		 * Plusieurs éléments ont été ajoutés d'un coup (via la méthode addElements)
		 */
		protected function elementsAdded ():void
		{
			
		}
		
		/**
		 * Un élément à été supprimé
		 * @param	pElement : L'élément qui a été supprimé
		 */
		protected function elementRemoved (pElement:ResizableComponent):void
		{
			
		}
		
		/**
		 * Ajouter un enfant. Ajoutera un élément si addChildAsElement.
		 * @param	pChild : L'enfant / élément
		 * @return : L'enfant / élément
		 */
		override public function addChild (pChild:DisplayObject):DisplayObject
		{
			// Vérifier si on doit traiter chaque enfant comme un élément
			if (_addChildAsElement)
			{
				// Vérifier si le child que l'ont veut traiter est bien un composant
				if (!(pChild is ResizableComponent))
				{
					throw new GraphicalError("BaseContainer.addChild", "When addChildAsElement is true, pChild must be ResizableComponent.")
				}
				else
				{
					// Ajouter l'élément
					addElement(pChild as ResizableComponent);
				}
				
				// Retourner
				return pChild;
			}
			else
			{
				// Relayer à la super classe
				return super.addChild(pChild);
			}
		}
		
		/**
		 * Supprimer un enfant. Supprimera un élément si addChildAsElement.
		 * @param	pChild : L'enfant / élément
		 * @return : L'enfant / élément
		 */
		override public function removeChild (pChild:DisplayObject):DisplayObject
		{
			// Vérifier si on doit traiter chaque enfant comme un élément
			if (_addChildAsElement)
			{
				// Vérifier si le child que l'ont veut traiter est bien un composant
				if (!(pChild is ResizableComponent))
				{
					throw new GraphicalError("BaseContainer.removeChild", "When addChildAsElement is true, pChild must be ResizableComponent.")
				}
				else
				{
					// Supprimer l'élément
					removeElement(pChild as ResizableComponent);
				}
				
				// Retourner
				return pChild;
			}
			else
			{
				// Relayer à la super classe
				return super.removeChild(pChild);
			}
		}
		
		/**
		 * Ajouter un élément a ce container
		 * @param	pElement : L'élément a ajouter de type ResizableComponent
		 * @param	pAt : L'index de l'ajout -1 pour l'ajouter à la fin
		 */
		public function addElement (pElement:ResizableComponent, pAt:int = -1):ResizableComponent
		{
			// Ajouter l'élément
			internalAddElement(pElement, pAt);
			
			// Signaler en interne
			elementAdded(pElement);
			
			// Retourner l'élément
			return pElement;
		}
		
		/**
		 * Ajouter plusieurs éléments d'un coup.
		 * La méthode overridable elementsAdded sera appelée une seule fois.
		 * @param	pElements : Les éléments à ajouter
		 */
		public function addElements (pElements:Vector.<ResizableComponent>):void
		{
			// Parcourir les éléments à ajotuer
			for each (var element:ResizableComponent in pElements)
			{
				// Ajouter l'élément
				internalAddElement(element);
				
				// Signaler en interne
				elementAdded(element);
			}
			
			// Signaler en interne que les éléments ont été ajoutés
			elementsAdded();
		}
		
		/**
		 * Supprimer un élément de type ResizableComponent
		 * @param	pElement
		 */
		public function removeElement (pElement:ResizableComponent):void
		{
			// Si le container n'a pas cet élément
			if (!_container.contains(pElement))
			{
				throw new GraphicalError("BaseContainer.removeElement", "pElement not found in container.");
				return;
			}
			
			// On supprime en interne
			internalRemoveElement(pElement);
		}
		
		/**
		 * Supprimer tous les ordis
		 */
		public function removeAllElements ():void
		{
			var i:int = _elements.length;
			while (--i >= 0)
			{
				_container.removeChild(_elements[i]);
			}
			
			_elements = new Vector.<ResizableComponent>;
		}
		
		/**
		 * Récupérer un élément par son index dans la pile des éléments
		 * @param	pAt : L'index de l'élément que l'on souhaite récupérer. Laisser -1 pour récupérer le dernier, 0 pour le premier...
		 * @return : Retourne l'élément, peut être null
		 */
		public function getElementAt (pAt:int = -1):ResizableComponent
		{
			// Permettre de compter à l'envers
			const index:int = pAt >= 0 ? pAt : Math.max(0, _elements.length + pAt);
			
			// Retourner si l'élément est trouvé
			if (index in _elements)
				return _elements[index];
			else
				return null;
		}
		
		/**
		 * La méthode interne pour ajouter un élément (pas de déclanchement de méthode overridable)
		 * @param	pElement : L'élément a ajouter de type ResizableComponent
		 * @param	pAt : L'index de l'ajout -1 pour l'ajouter à la fin
		 */
		protected function internalAddElement (pElement:ResizableComponent, pAt:int = -1):void
		{
			var newElements:Vector.<ResizableComponent>;
			
			var haveToListen:Boolean = true;
			
			// Si on contient déjà cet élément
			if (_container.contains(pElement))
			{
				//internalRemoveElement(pElement);
				
				// La nouvelle liste
				newElements = new Vector.<ResizableComponent>;
				
				// Parcourir les éléments
				for each (var element:ResizableComponent in _elements)
				{
					// Si on est pas sur notre élément
					if (element != pElement)
					{
						// Ajouter les autres éléments
						newElements.push(element);
					}
				}
				
				// Appliquer le nouveau tableau
				_elements = newElements;
				
				// On ne doit pas écouter cet élément
				haveToListen = false;
			}
			
			// Si on doit ajouter à la fin
			if (pAt == -1)
			{
				// Ajouter cet élément à la fin
				_elements.push(pElement);
				
				// Ajouter l'élément au container
				_container.addChild(pElement);
			}
			
			// Si on doit ajouter au début
			else if (pAt == 0)
			{
				// Ajouter cet élément au début
				_elements.unshift(pElement);
				
				// Ajouter l'élément au container
				_container.addChildAt(pElement, 0);
			}
			
			// Sinon si on doit ajouter entre le début et la fin
			else if (pAt >= 0 && pAt <= _elements.length)
			{
				// La nouvelle liste
				newElements = new Vector.<ResizableComponent>;
				
				// Compter le nombre d'éléments
				var total:uint = _elements.length;
				
				// Parcourir les éléments
				for (var i:uint = 0; i < total; i++ )
				{
					if (i < pAt)
					{
						// Avant l'index
						newElements[newElements.length] = _elements[i];
					}
					else if (i == pAt)
					{
						// Sur l'index
						newElements[newElements.length] = pElement;
						
						// Ajouter aussi à la displayList
						_container.addChildAt(pElement, pAt);
					}
					else if (i > pAt)
					{
						// Après l'index (décaller de 1)
						newElements[newElements.length] = _elements[i - 1];
					}
				}
			}
			
			// Sinon on est out of range
			else
			{
				// Donc on déclanche un erreur
				throw new GraphicalError("BaseContainer.addElement", "Element index is out of range (" + pAt + " of " + _elements.length + ")");
				
				// Arrêter le script
				return;
			}
			
			// Si on doit écouter cet élément
			if (haveToListen)
			{
				// Ecouter les ajout et suppressions externes de l'éléments
				pElement.addEventListener(Event.ADDED, elementAddedRemovedHandler);
				pElement.addEventListener(Event.REMOVED, elementAddedRemovedHandler);
				
				// Ecouter les redimensionnements de cet élément
				pElement.onResized.add(elementResized);
			}
		}
		
		/**
		 * La méthode interne pour supprimer un élément (pas de déclanchement d'erreur)
		 */
		protected function internalRemoveElement (pElement:ResizableComponent):void
		{
			// La nouvelle liste
			var newElements:Vector.<ResizableComponent> = new Vector.<ResizableComponent>;
			
			// Parcourir les éléments
			for each (var element:ResizableComponent in _elements)
			{
				// Si on est sur notre élément
				if (element == pElement)
				{
					// On supprime l'écoute des
					pElement.removeEventListener(Event.ADDED, elementAddedRemovedHandler);
					pElement.removeEventListener(Event.REMOVED, elementAddedRemovedHandler);
					
					// Supprimer l'élément du container
					if (_container.contains(pElement))
						_container.removeChild(element);
				}
				else
				{
					// Ajouter les autres éléments
					newElements.push(element)
				}
			}
			
			// Enregistrer la nouvelle liste
			_elements = newElements;
			
			// Ne plus écouter les redimensionnements de cet élément
			if (pElement.onResized != null)
				pElement.onResized.remove(elementResized);
			
			// Signaler
			elementRemoved(pElement);
		}
		
		/**
		 * Un élément a été supprimé ou ajouté ailleur depuis l'extérieur
		 * @param	event
		 */
		protected function elementAddedRemovedHandler (event:Event):void 
		{
			// Si on est pas sur le currentTarget, on dégage
			if (event.target != event.currentTarget)
				return;
			
			// Cibler le composant
			var target:ResizableComponent = event.target as ResizableComponent;
			
			// Si le clip a un nouveau parent et/ou un parent différent
			if (target.parent == null || target.parent != _container)
			{
				// On le supprime
				internalRemoveElement(target);
			}
		}
		
		/**
		 * Destruction du container
		 * @param	event
		 */
		override protected function removedHandler (event:Event):void
		{
			// Relayer la destruction
			super.removedHandler(event);
			
			// Si on autorise le dispose auto
			if (_autoDispose)
			{
				// Ne plus écouter les resizes sur le container
				if (_container != null)
				{
					_container.onResized.remove(containerResized);
				}
				
				// Ne plus écouter les redimensionnements sur tous les éléments
				for each (var element:ResizableComponent in _elements)
				{
					element.onResized.remove(elementResized);
				}
			}
		}
	}
}