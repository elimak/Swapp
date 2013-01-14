package fr.swapptesting.rebirth
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
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
		protected var _currentFrame:int;
		protected var _graph2:SGraphic;
		
		public function RebirthDocument ()
		{
			super();
		}
		
		override public function init ():void
		{
			trace("SDocument.init", _wrapper);
			
			var texture:BitmapData = (new ImageTest as Bitmap).bitmapData;
			
			_graph1 = new SGraphic(texture, SRenderMode.REPEAT);
			_graph1.border(1, 0, 1);
			_graph1.place(100, 100, 100, 100).into(_wrapper.root);
			
			_graph2 = new SGraphic();
			_graph2.place(50, NaN, 50, 50).size(200, NaN);
			_graph2.background(SBackgroundType.VERTICAL_GRADIENT, 0xFF0000, 1, 0x00FF00, 0.8);
			_graph2.into(_graph1);
			
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		protected function enterFrameHandler (event:Event):void
		{
			_currentFrame ++;
			_graph1.bitmapOffset(_currentFrame, _currentFrame / 2);
		}
	}
}