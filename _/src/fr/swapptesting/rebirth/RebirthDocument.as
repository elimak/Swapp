package fr.swapptesting.rebirth
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.events.Event;
	import flash.system.Capabilities;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextInteractionMode;
	import fr.swapp.graphic.base.SBackgroundType;
	import fr.swapp.graphic.base.SDocument;
	import fr.swapp.graphic.base.SGraphic;
	import fr.swapp.graphic.base.SRenderMode;
	
	/**
	 * @author ZoulouX
	 */
	public class RebirthDocument extends SDocument
	{
		[Embed(source="../../../../lib/images/z.jpg")]
		public static const ImageTest:Class
		
		protected var _graph1:SGraphic;
		protected var _graph2:SGraphic;
		protected var _graph3:SGraphic;
		protected var _graph4:SGraphic;
		
		protected var _currentFrame:int;
		
		public function RebirthDocument ()
		{
			super();
		}
		
		override public function init ():void
		{
			trace("SDocument.init", _wrapper);
			/*
			_wrapper.showStats();
			
			var texture:BitmapData = (new ImageTest as Bitmap).bitmapData;
			
			_graph1 = new SGraphic(texture, SRenderMode.REPEAT);
			_graph1.border(1, 0, 1);
			_graph1.place(100, 100, 100, 100).into(_wrapper.root);
			
			_graph2 = new SGraphic();
			_graph2.place(50, NaN, 50, 50).size(200, NaN);
			_graph2.background(SBackgroundType.VERTICAL_GRADIENT, 0xFF0000, 1, 0x00FF00, 0.8);
			_graph2.into(_graph1);
			
			_graph3 = new SGraphic();
			_graph3.place(NaN, 0, NaN, 0).center(NaN, 0).size(NaN, 150);
			_graph3.background(SBackgroundType.HORIZONTAL_GRADIENT, 0x0000FF, 0.5, 0xFFFFFF, 1);
			_graph3.into(_graph1);
			
			_graph4 = new SGraphic(texture, SRenderMode.INSIDE);
			_graph4.center(0, 0).size(200, 200);
			_graph4.background(SBackgroundType.FLAT, 0x000000, .5);
			_graph4.into(_graph1);
			//_graph4.blendMode = BlendMode.MULTIPLY;
			// SCREEN
			// INVERT
			// MULTIPLY
			// ADD
			// NORMAL
			
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			*/
			
			
			/*
			var textField:TextField = new TextField();
			textField.width = stage.stageWidth;
			textField.height = stage.stageHeight;
			
			textField.defaultTextFormat = new TextFormat("Arial", 30);
			
			textField.htmlText = <text>
				Capabilities.version : {Capabilities.version}
				Capabilities.screenDPI : {Capabilities.screenDPI}
				Capabilities.isDebugger : {Capabilities.isDebugger}
				Capabilities.manufacturer : {Capabilities.manufacturer}
				Capabilities.os : {Capabilities.os}
				Capabilities.pixelAspectRatio : {Capabilities.pixelAspectRatio}
				Capabilities.playerType : {Capabilities.playerType}
				Capabilities.screenResolutionX : {Capabilities.screenResolutionX}
				Capabilities.screenResolutionY : {Capabilities.screenResolutionY}
				Capabilities.touchscreenType : {Capabilities.touchscreenType}
			</text>.toString().replace(/(\t|\r)/g, "");
			addChild(textField);
			
			//trace(10000000000000000 === 10000000000000001);
			*/
		}
		
		protected function enterFrameHandler (event:Event):void
		{
			_currentFrame ++;
			_graph1.bitmapOffset(_currentFrame, - _currentFrame / 2);
			
			_graph4.size(Math.sin(_currentFrame / 50) * 100 + 200, Math.cos(_currentFrame / 60) * 100 + 200);
		}
	}
}