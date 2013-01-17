package fr.swapp.graphic.components.navigation 
{
	import flash.events.MouseEvent;
	import fr.swapp.graphic.base.BaseContainer;
	import fr.swapp.graphic.base.ResizableComponent;
	import fr.swapp.graphic.components.controls.Button;
	import fr.swapp.graphic.components.navigation.items.NavigationStackItem;
	import org.osflash.signals.Signal;
	
	/**
	 * ...
	 * @author ZoulouX
	 */
	public class MenuBar extends BaseContainer 
	{
		/**
		 * Les alignements
		 */
		public static const ALIGN_LEFT			:int					= 0;
		public static const ALIGN_CENTER		:int					= 1;
		public static const ALIGN_RIGHT			:int					= 2;
		
		
		/**
		 * La classe graphique des boutons
		 */
		protected var _itemRenderer				:Class 					= Button;
		
		/**
		 * La largeur des boutons
		 */
		protected var _buttonWidth				:int					= 50;
		
		/**
		 * La marge entre chaque bouton
		 */
		protected var _buttonsMargin			:int					= 2;
		
		/**
		 * Alignement des boutons
		 */
		protected var _align					:int					= ALIGN_CENTER;
		
		/**
		 * Les items que cette barre de menu doit afficher
		 */
		protected var _items					:Vector.<NavigationStackItem>;
		
		/**
		 * L'item séléctionné (-1 pour ne pas séléctionner)
		 */
		protected var _selectedIndex			:int					= -1;
		
		/**
		 * Lorsque l'index séléctionné change (paramètre 1 : l'index)
		 */
		protected var _onChange					:Signal					= new Signal(int);
		
		/**
		 * Les largeur totale des boutons
		 */
		protected var _totalWidth				:int;
		
		
		/**
		 * La largeur des boutons
		 */
		public function get buttonWidth ():int { return _buttonWidth; }
		public function set buttonWidth (value:int):void 
		{
			_buttonWidth = value;
			
			// Actualiser
			resized();
		}
		
		/**
		 * La marge entre chaque bouton
		 */
		public function get buttonsMargin ():int { return _buttonsMargin; }
		public function set buttonsMargin (value:int):void 
		{
			_buttonsMargin = value;
			
			// Actualiser
			resized();
		}
		
		/**
		 * Alignement des boutons
		 */
		public function get align ():int { return _align; }
		public function set align (value:int):void 
		{
			_align = value;
			
			// Actualiser
			resized();
		}
		
		/**
		 * Les items que cette barre de menu doit afficher
		 */
		public function get items ():Vector.<NavigationStackItem> { return _items; }
		
		/**
		 * L'item séléctionné (-1 pour ne pas séléctionner)
		 */
		public function get selectedIndex ():int { return _selectedIndex; }
		public function set selectedIndex (value:int):void 
		{
			// Enregistrer
			_selectedIndex = value;
			
			// On actualise visuellement
			updateSelectedIndex();
		}
		
		/**
		 * Lorsque l'index séléctionné change (paramètre 1 : l'index)
		 */
		public function get onChange ():Signal { return _onChange; }
		public function set onChange (value:Signal):void 
		{
			_onChange = value;
		}
		
		
		/**
		 * Le constructeur
		 * @param	pItems : Les items à afficher dans le menu
		 * @param	pItemRenderer : La classe de rendu d'un bouton (pItems doit être défini pour être pris en compte)
		 */
		public function MenuBar (pItems:Array = null, pItemRenderer:Class = null)
		{
			// Activer les styles
			_styleEnabled = true;
			
			// Ecouter les clics
			addEventListener(MouseEvent.CLICK, clickHandler);
			
			// Si on a des paramètres
			if (pItems != null && pItemRenderer != null)
			{
				// On applique les items et l'itemRenderer
				setItems(pItems, pItemRenderer);
			}
		}
		
		/**
		 * Définir les items que cette barre de menu doit afficher
		 * @param	pItems : La liste des items, de type IMenuBarItem ou objets dynamiques qui seront convertis.
		 * @param	pItemRenderer : 
		 */
		public function setItems (pItems:Array, pItemRenderer:Class = null):void
		{
			// Remettre le tableau à 0
			_items = new <NavigationStackItem>[];
			
			// L'item renderer
			_itemRenderer = pItemRenderer == null ? Button : pItemRenderer;
			
			// Parcourir les items
			for each (var item:Object in pItems)
			{
				// Créer l'objet et l'ajouter aux couches
				_items.push(item is NavigationStackItem ? item : new NavigationStackItem(item));
			}
			
			// Construire les boutons
			buildButtons();
		}
		
		/**
		 * Construire les boutons
		 */
		protected function buildButtons ():void
		{
			// Supprimer tous les éléments
			for each (var element:ResizableComponent in _elements)
			{
				removeElement(element);
			}
			
			// Chaque bouton qui va être créé
			var button:Button;
			
			// Parcourir 
			var buttonIndex:uint;
			for each (var item:NavigationStackItem in _items)
			{
				// Créer le bouton
				button = new _itemRenderer();
				
				// Lui passer l'item
				button.styleName = item.styleName;
				
				// Lui passer le titre
				
				
				// Lui passer son index
				button.index = buttonIndex ++;
				
				// Définir la taille du bouton si disponible
				if (_buttonWidth > 0)
					button.size(_buttonWidth, NaN)
				
				// Placer le bouton
				button.place(0, NaN, 0, NaN);
				
				// L'ajouter
				addElement(button);
			}
			
			// Replacer les éléments
			resized();
		}
		
		/**
		 * Définir le layout des boutons
		 * @param	pWidth : Largeur de chaque bouton (-1 pour auto)
		 * @param	pMargin : La marge entre chaque bouton
		 * @param	pAlign : Alignement (voir static)
		 * @param	pPaddingTop : Padding du haut sur les boutons (déplacement simplement le container)
		 * @param	pPaddingBottom : Padding du bas sur les boutons (déplacement simplement le container)
		 */
		public function buttonsLayout (pWidth:int, pMargin:int, pAlign:int = 1, pPaddingTop:Number = 0, pPaddingBottom:Number = 0):MenuBar
		{
			// Largeur marge et aligenement des boutons
			_buttonWidth = pWidth;
			_buttonsMargin = pMargin;
			_align = pAlign;
			
			// Le padding grâce au container
			_container.top = pPaddingTop;
			_container.bottom = pPaddingBottom;
			
			// Actualiser
			replaceButtons();
			
			// Méthode chaînable
			return this;
		}
		
		/**
		 * Click sur le menu
		 */
		protected function clickHandler (event:MouseEvent):void 
		{
			// Si l'élément cliqué est un bouton de menu
			if (event.target is Button)
			{
				// On récupère son index
				_selectedIndex = (event.target as Button).index;
				
				// On actualise visuellement
				updateSelectedIndex();
				
				// On dispatche
				_onChange.dispatch(_selectedIndex);
			}
		}
		
		/**
		 * Actualiser visuellement l'élément séléctionné
		 */
		protected function updateSelectedIndex ():void
		{
			// Parcourir tous les boutons
			const total:uint = _elements.length;
			for (var i:int = 0; i < total; i ++)
			{
				// Et séléctionner le bon
				(_elements[i] as Button).selected = (_selectedIndex == i);
			}
		}
		
		/**
		 * Replacer les boutons
		 */
		protected function replaceButtons ():void
		{
			// Parcourir les éléments pour les placer
			var index:int;
			var previousElement:ResizableComponent;
			for each (var element:ResizableComponent in _elements)
			{
				// Placer l'élément
				element.x = (previousElement != null ? previousElement.x + previousElement.totalWidth + _buttonsMargin : 0);
				
				// La largeur du bouton
				if (_buttonWidth != -1)
					element.width = _buttonWidth;
				
				// Compter la largeur totale
				if (index == _elements.length - 1)
					_totalWidth = element.x + element.totalWidth;
				
				// Passer au suivant
				previousElement = element;
				index ++;
			}
			
			// Actualiser
			resized();
		}
		
		/**
		 * Le composant est redimensionné
		 */
		override protected function resized ():void
		{
			if (_align == ALIGN_LEFT)
			{
				_container.horizontalOffset = 0;
			}
			else if (_align == ALIGN_CENTER)
			{
				_container.horizontalOffset = (_container.totalWidth - _totalWidth) / 2;
			}
			else if (_align == ALIGN_RIGHT)
			{
				_container.horizontalOffset = _container.totalWidth - _totalWidth;
			}
		}
		
		/**
		 * Replacer les éléments lorsqu'un élément à changé de taille
		 */
		override protected function elementResized ():void
		{
			// Si on est en mode auto
			if (_buttonWidth == -1)
			{
				replaceButtons();
			}
		}
		
		/**
		 * Destruction du composant
		 */
		override public function dispose ():void
		{
			_onChange.removeAll();
			_onChange = null;
			
			// Ne plus écouter les clics
			removeEventListener(MouseEvent.CLICK, clickHandler);
			
			// Relayer
			super.dispose();
		}
	}
}