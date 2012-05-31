package fr.swapp.graphic.components.navigation 
{
	import flash.display.DisplayObject;
	import fr.swapp.graphic.base.BaseContainer;
	import fr.swapp.graphic.base.ResizableComponent;
	
	/**
	 * @author ZoulouX
	 */
	public class ViewStack extends BaseContainer 
	{
		/**
		 * L'index de l'élément séléctionné
		 */
		protected var _selectedIndex						:int;
		
		/**
		 * L'élément séléctionné
		 */
		protected var _selectedElement						:ResizableComponent;
		
		
		/**
		 * L'index de l'élément séléctionné
		 */
		public function get selectedIndex ():int { return _selectedIndex; }
		public function set selectedIndex (value:int):void 
		{
			// Séléctionner
			_selectedIndex = value;
			_selectedElement = _elements[_selectedIndex];
			
			// Actualiser l'état
			updateSelected();
		}
		
		/**
		 * L'élément séléctionné
		 */
		public function get selectedElement ():ResizableComponent {return _selectedElement; }
		public function set selectedElement (value:ResizableComponent):void 
		{
			// Séléctionner
			_selectedElement = value;
			_selectedIndex = -1;
			
			// Si on a un élément de séléctionné
			if (value != null)
			{
				// Parcourir les éléments
				var index:uint;
				for each (var element:ResizableComponent in _elements)
				{
					// Si on tombe sur notre élément
					if (element == value)
					{
						_selectedIndex = index;
						break;
					}
					
					// Passer au suivant
					index ++;
				}
			}
			
			// Actualiser l'état
			updateSelected();
		}
		
		
		/**
		 * Une liste de vues.
		 * Par défaut, les addChild réagisseront comme des addElement.
		 */
		public function ViewStack ()
		{
			// Activer les styles
			_styleEnabled = true;
			
			// Tous les addChilds seront ajoutés comme des éléments
			_addChildAsElement = true;
		}
		
		
		/**
		 * Ajout d'un élément
		 */
		override public function addElement (pElement:ResizableComponent, pAt:int = -1):ResizableComponent
		{
			// Relayer
			super.addElement(pElement, pAt);
			
			// Afficher/masquer l'élément ajouté
			pElement.visible = (_elements[_selectedIndex] == pElement);
			
			// Retourner l'élément
			return pElement;
		}
		
		/**
		 * Actualiser
		 */
		protected function updateSelected ():void
		{
			// Parcourir
			for each (var element:ResizableComponent in _elements)
			{
				// Afficher le bon élément
				element.visible = (element == _selectedElement);
			}
		}
	}
}