package fr.swapptesting.second
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import fr.swapp.graphic.base.SComponent;
	import fr.swapp.graphic.base.SGraphic;
	import fr.swapp.graphic.base.SRenderMode;
	import fr.swapp.graphic.base.SWrapper;
	import starling.display.Image;
	import starling.textures.Texture;
	
	/**
	 * @author ZoulouX
	 */
	public class SecondTest extends Sprite
	{
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
			_component.place(100, 100, 100, 100).into(_wrapper.root, "component");
			
			var texture:Texture = Texture.fromBitmap(new ExBitmap, false);
			
			texture.repeat = false;
			
			_image = new Image(texture);
			_component.addChild(_image);
			
			_image.x = 200;
			_image.y = 200;
			_image.width = 400;
			_image.height = 200;
			
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			/*
			
			_c1 = new SGraphic(texture, SRenderMode.CENTER, 1);
			_c1.border(1);
			//_c1.allRadius(20);
			_c1.place(0, 0, 0, 0).into(_component, "c1");
			*/
			
			
			/*
			for (var i:int = 0; i & lt; 4; i++) 
			{ 
				p = mStarfield1.getTexCoords(i);
				p.x += mMousePos.x * .00002;
				p.y += mMousePos.y * .00002;
				mStarfield1.setTexCoords(i, p);
				p = mStarfield2.getTexCoords(i);
				p.x += mMousePos.x * .00004;
				p.y += mMousePos.y * .00004;
				mStarfield2.setTexCoords(i, p);
			}
			*/
		}
		
		protected function enterFrameHandler(e:Event):void 
		{
			var p:Point;
			for (var i:int = 0; i < 4; i++) 
			{ 
				p = _image.getTexCoords(i);
				p.x += (stage.stageWidth - mouseX / 2) * .00002 * i;
				p.y += (stage.stageHeight - mouseY / 2)* .00002 * i;
				_image.setTexCoords(i, p);
			}
		}
		
	}
}