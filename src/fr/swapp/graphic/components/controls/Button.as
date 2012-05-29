package fr.swapp.graphic.components.controls
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import fr.swapp.graphic.components.base.ResizableComponent;
	import fr.swapp.graphic.components.bitmaps.AdvancedBitmap;
	import fr.swapp.graphic.components.bitmaps.AutoScaleNineBitmaps;
	import fr.swapp.graphic.components.controls.buttons.skins.IButtonSkinItem;
	import fr.swapp.graphic.components.controls.text.Label;
	import org.osflash.signals.Signal;
	
	/**
	 * @author ZoulouX
	 */
	public class Button extends ResizableComponent
	{
		/**
		 * Lorsqu'on clique sur ce bouton
		 */
		protected var _onClick							:Signal 					= new Signal();
		
		/**
		 * Les backgrounds de cet élément
		 */
		protected var _normalBackground					:AutoScaleNineBitmaps;
		protected var _selectedBackground				:AutoScaleNineBitmaps;
		
		/**
		 * L'image représentant cet élément
		 */
		protected var _image							:AdvancedBitmap;
		
		/**
		 * Le label
		 */
		protected var _label							:Label;
		
		/**
		 * L'item associé
		 */
		protected var _item								:IButtonSkinItem;
		
		/**
		 * Si le bouton est séléctionné (ne déclanchera pas d'action)
		 */
		protected var _selected							:Boolean
		
		/**
		 * Si le bouton est séléctionnable
		 */
		protected var _selectable						:Boolean					= false;
		
		
		/**
		 * L'image représentant cet élément
		 */
		public function get image ():AdvancedBitmap { return _image; }
		
		/**
		 * Le label
		 */
		public function get label ():Label { return _label; }
		
		/**
		 * L'item associé
		 */
		public function get item ():IButtonSkinItem { return _item; }
		public function set item (value:IButtonSkinItem):void 
		{
			// Virer les fonds si présents
			if (_normalBackground != null)
				removeChild(_normalBackground);
			
			if (_selectedBackground != null)
				removeChild(_selectedBackground);
			
			// Enregistrer l'item
			_item = value;
			
			// Appliquer la densité et le mode de rendu sur l'image
			_image.density = _item.imageDensity;
			_image.renderMode = _item.imageRenderMode;
			
			// Spécifier le titre
			if (_item.title != null)
				_label.text(_item.title);
			
			// Créer le fond normal si besoin
			if (_item.normalBackground != null)
			{
				_normalBackground = new AutoScaleNineBitmaps(_item.normalBackground, _item.backgroundDensity);
				_normalBackground.place(0, 0, 0, 0).into(this, "", 0);
			}
			
			// Créer le fond séléctionné si besoin
			if (_item.selectedBackground != null)
			{
				_selectedBackground = new AutoScaleNineBitmaps(_item.selectedBackground, _item.backgroundDensity);
				_selectedBackground.place(0, 0, 0, 0).into(this, "", 0);
			}
			
			// Actualiser l'état
			updateSelectedState();
		}
		
		/**
		 * Si le bouton est séléctionné (ne déclanchera pas d'action)
		 */
		public function get selected ():Boolean { return _selected; }
		public function set selected (value:Boolean):void 
		{
			// Enregistrer l'état
			_selected = value;
			
			// Actualiser
			updateSelectedState();
		}
		
		/**
		 * Lorsqu'on clique sur ce bouton
		 */
		public function get onClick ():Signal { return _onClick; }
		
		/**
		 * Si le bouton est séléctionnable
		 */
		public function get selectable ():Boolean { return _selectable; }
		public function set selectable (value:Boolean):void
		{
			_selectable = value;
		}
		
		
		/**
		 * Constructeur
		 */
		public function Button ()
		{
			// Ne pas gérer l'intéractivité sur le contenu
			mouseChildren = false;
			buttonMode = true;
			
			// Créer la zone d'intéraction
			hitArea = new Sprite();
			hitArea.graphics.beginFill(0xFF0000);
			hitArea.graphics.drawRect(0, 0, 1, 1);
			hitArea.graphics.endFill();
			addChild(hitArea);
			hitArea.visible = false;
			
			// Initialiser les composants
			initComponents();
		}
		
		/**
		 * Redimensionné
		 */
		override protected function resized ():void
		{
			hitArea.width = _localWidth;
			hitArea.height = _localHeight;
		}
		
		/**
		 * Initialisation
		 */
		override public function init ():void 
		{
			// Ecouter les clics
			addEventListener(MouseEvent.MOUSE_DOWN, mouseHandler);
			
			// Actualiser
			updateSelectedState();
		}
		
		/**
		 * Evènement click
		 */
		protected function mouseHandler (event:MouseEvent):void 
		{
			if (_selectable)
			{
				if (event.type == MouseEvent.MOUSE_DOWN)
				{
					stage.addEventListener(MouseEvent.MOUSE_UP, mouseHandler, false, 0, true);
					
					selected = true;
				}
				else if (event.type == MouseEvent.MOUSE_UP)
				{
					stage.removeEventListener(MouseEvent.MOUSE_UP, mouseHandler, false);
					
					selected = false;
					
					if (event.target == this)
						_onClick.dispatch();
				}
			}
		}
		
		/**
		 * Actualiser l'état séléctionné
		 */
		protected function updateSelectedState ():void
		{
			// Si on a un item
			if (_item != null && stage != null)
			{
				// Actualiser l'image
				_image.bitmapData = ((_selected && _item.selectedImage != null) ? _item.selectedImage : _item.normalImage);
				
				// Actualiser le titre
				_label.textSkin((_selected && _item.selectedTitleSkin != null) ? _item.selectedTitleSkin : _item.normalTitleSkin);
				
				// Actualiser le background
				updateBackground();
			}
		}
		
		/**
		 * Actualiser le background
		 */
		protected function updateBackground ():void
		{
			// Afficher/masquer le fond séléctionné
			if (_selectedBackground != null)
				_selectedBackground.visible = _selected;
			
			// Afficher/masquer le fond normal
			if (_normalBackground != null)
				_normalBackground.visible = (_selectedBackground == null ? true : !_selected);
		}
		
		/**
		 * Initialiser les composants
		 */
		protected function initComponents ():void
		{
			// Créer l'image
			_image = new AdvancedBitmap(null);
			_image.place(0, 0, 0, 0).into(this);
			
			// Créer le label
			_label = new Label(false, true);
			_label.into(this);
		}
		
		/**
		 * Destruction
		 */
		override public function dispose():void 
		{
			super.dispose();
			
			removeEventListener(MouseEvent.MOUSE_DOWN, mouseHandler);
			
			_onClick.removeAll();
		}
	}
}