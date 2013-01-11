package fr.swapptesting.second
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.utils.getTimer;
	import fr.swapp.graphic.base.SBackgroundType;
	import fr.swapp.graphic.base.SComponent;
	import fr.swapp.graphic.base.SGraphic;
	import fr.swapp.graphic.base.SRenderMode;
	import fr.swapp.graphic.base.SWrapper;
	import starling.display.Image;
	import starling.textures.Texture;
	import starling.textures.TextureSmoothing;
	
	/**
	 * @author ZoulouX
	 */
	public class SecondTest extends Sprite
	{
		private var _frame:int;
		private var _c2:SGraphic;
		[Embed(source="../../../../lib/images/z.jpg")]
		public static const ExBitmap:Class
		
		
		protected var _wrapper		:SWrapper;
		protected var _c1			:SGraphic;
		protected var _component	:SComponent;
		protected var _image:Image;
		
		public function SecondTest ()
		{
			if (stage == null)
				addEventListener(Event.ADDED_TO_STAGE, addedHandler);
			else
				addedHandler();
		}
		
		protected function addedHandler (event:Event = null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, addedHandler);
			
			_wrapper = new SWrapper(stage);
			_wrapper.onReady.addOnce(wrapperReadyHandler);
		}
		
		protected function wrapperReadyHandler ():void
		{
			_component = new SComponent();
			_component.place(200, 200, 200, 200).into(_wrapper.root, "component");
			
			var texture:Texture = Texture.fromBitmap(new ExBitmap, false);
			texture.repeat = true;
			
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			
			_c1 = new SGraphic(texture, SRenderMode.OUTSIDE, 1);
			_c1.allowOverflow = true;
			_c1.alpha = 0.5;
			_c1.place(0, 0, 0, 0).into(_component, "c1");
			
			_c2 = new SGraphic(texture, SRenderMode.OUTSIDE, 1);
			_c2.allowOverflow = false;
			_c2.alpha = 0.5;
			_c2.place(0, 0, 0, 0).into(_component, "c2");
			
			/*
			_c1 = new SGraphic();
			_c1.background(SBackgroundType.VERTICAL_GRADIENT, 0x000000, 1, 0x222222, 1);
			_c1.place(0, 0, 0, 0).into(_component, "c1");
			_c1.image(texture, SRenderMode.INSIDE, 1);
			*/
		}
		
		protected function enterFrameHandler(e:Event):void 
		{
			//_c1.bitmapOffset(_frame ++, _frame / 10);
		}
	}
}