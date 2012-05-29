package fr.swapp.graphic.components.navigation 
{
	import flash.display.BitmapData;
	import fr.swapp.core.bootstrap.BootstrapAction;
	import fr.swapp.graphic.components.bitmaps.AdvancedBitmap;
	import fr.swapp.graphic.components.containers.stacks.IStackLayerItem;
	import fr.swapp.graphic.components.controls.buttons.skins.IButtonSkinItem;
	import fr.swapp.graphic.components.controls.text.TextSkin;
	import fr.swapp.utils.ObjectUtils;
	
	/**
	 * ...
	 * @author ZoulouX
	 */
	public class NavigationStackItem implements IStackLayerItem, IButtonSkinItem
	{
		/**
		 * L'action déclanchée à la séléction d'un index
		 */
		protected var _action							:BootstrapAction;
		
		/**
		 * Le type de destruction de cette couche
		 */
		protected var _destructionPolicy				:String;
		
		
		/**
		 * L'image de fond normale
		 */
		protected var _normalBackground					:BitmapData;
		
		/**
		 * L'image séléctionnée de fond
		 */
		protected var _selectedBackground				:BitmapData;
		
		/**
		 * La densité du fond
		 */
		protected var _backgroundDensity				:Number					= 1;
		
		
		/**
		 * L'image normale du bouton
		 */
		protected var _normalImage						:BitmapData;
		
		/**
		 * L'image séléctionnée du bouton
		 */
		protected var _selectedImage					:BitmapData;
		
		/**
		 * La densité de l'image
		 */
		protected var _imageDensity						:Number					= 1;
		
		/**
		 * Le mode de rendu de l'image
		 */
		protected var _imageRenderMode					:String					= AdvancedBitmap.INSIDE_SCALE_MODE;
		
		
		
		/**
		 * Le titre
		 */
		protected var _title							:String;
		
		/**
		 * Le skin du titre à l'état normal
		 */
		protected var _normalTitleSkin					:TextSkin;
		
		/**
		 * Le skin du titre à l'état séléctionné
		 */
		protected var _selectedTitleSkin				:TextSkin;
		
		/**
		 * Si l'item est visible (et donc accessible via le menu)
		 */
		protected var _visible							:Boolean;
		
		
		/**
		 * L'action déclanchée à la séléction d'un index
		 */
		public function get action ():BootstrapAction { return _action; }
		public function set action (value:BootstrapAction):void 
		{
			_action = value;
		}
		
		/**
		 * Le type de destruction de cette couche
		 */
		public function get destructionPolicy ():String { return _destructionPolicy; }
		public function set destructionPolicy (value:String):void 
		{
			_destructionPolicy = value;
		}
		
		
		/**
		 * L'image de fond normale
		 */
		public function get normalBackground ():BitmapData { return _normalBackground; }
		public function set normalBackground (value:BitmapData):void
		{
			_normalBackground = value;
		}
		
		/**
		 * L'image séléctionnée de fond
		 */
		public function get selectedBackground ():BitmapData { return _selectedBackground; }
		public function set selectedBackground (value:BitmapData):void
		{
			_selectedBackground = value;
		}
		
		/**
		 * La densité du fond
		 */
		public function get backgroundDensity ():Number { return _backgroundDensity; }
		public function set backgroundDensity (value:Number):void
		{
			_backgroundDensity = value;
		}
		
		
		/**
		 * L'image normale du bouton
		 */
		public function get normalImage ():BitmapData { return _normalImage; }
		public function set normalImage (value:BitmapData):void 
		{
			_normalImage = value;
		}
		
		/**
		 * L'image séléctionnée du bouton
		 */
		public function get selectedImage ():BitmapData { return _selectedImage; }
		public function set selectedImage (value:BitmapData):void 
		{
			_selectedImage = value;
		}
		
		/**
		 * La densité de l'image
		 */
		public function get imageDensity ():Number { return _imageDensity; }
		public function set imageDensity (value:Number):void
		{
			_imageDensity = value;
		}
		
		/**
		 * Le mode de rendu de l'image
		 */
		public function get imageRenderMode ():String { return _imageRenderMode; }
		public function set imageRenderMode (value:String):void
		{
			_imageRenderMode = value;
		}
		
		
		/**
		 * Le titre
		 */
		public function get title ():String { return _title; }
		public function set title (value:String):void 
		{
			_title = value;
		}
		
		/**
		 * Le skin du titre à l'état normal
		 */
		public function get normalTitleSkin ():TextSkin { return _normalTitleSkin };
		public function set normalTitleSkin (value:TextSkin):void 
		{
			_normalTitleSkin = value;
		}
		
		/**
		 * Le skin du titre à l'état séléctionné
		 */
		public function get selectedTitleSkin ():TextSkin { return _selectedTitleSkin };
		public function set selectedTitleSkin (value:TextSkin):void 
		{
			_selectedTitleSkin = value;
		}
		
		/**
		 * Si l'item est visible (et donc accessible via le menu)
		 */
		public function get visible ():Boolean { return _visible };
		public function set visible (value:Boolean):void 
		{
			_visible = value;
		}
		
		
		/**
		 * Le constructeur
		 * @param	pData : Les données de cet objet
		 */
		public function NavigationStackItem (pData:Object = null)
		{
			ObjectUtils.extra(this, pData);
		}
	}
}