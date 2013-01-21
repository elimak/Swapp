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
	import flash.utils.ByteArray;
	import fr.swapp.core.central.Central;
	import fr.swapp.core.log.Log;
	import fr.swapp.core.log.TraceLogger;
	import fr.swapp.graphic.atlas.SAtlas;
	import fr.swapp.graphic.atlas.SAtlasItem;
	import fr.swapp.graphic.base.SBackgroundType;
	import fr.swapp.graphic.base.SComponent;
	import fr.swapp.graphic.base.SDocument;
	import fr.swapp.graphic.base.SGraphic;
	import fr.swapp.graphic.base.SRenderMode;
	import fr.swapp.graphic.controls.SButton;
	import fr.swapp.graphic.lists.IVirtualListDelegate;
	import fr.swapp.graphic.lists.SFreeList;
	import fr.swapp.graphic.lists.SVirtualList;
	import fr.swapp.graphic.text.SHTMLText;
	import fr.swapp.graphic.text.SLabel;
	import fr.swapp.touch.emulator.MouseToTouchEmulator;
	
	/**
	 * @author ZoulouX
	 */
	public class RebirthDocument extends SDocument implements IVirtualListDelegate
	{
		[Embed(source="../../../../lib/images/z.jpg")]
		public static const ImageTest:Class
		
		[Embed(source="../../../../lib/images/atlas.png")]
		public static const AtlasImageTest:Class
		
		[Embed(source="../../../../lib/images/atlas.xml", mimeType='application/octet-stream')]
		public static const AtlasXMLTest:Class
		
		protected var _graph1:SGraphic;
		protected var _graph2:SGraphic;
		protected var _graph3:SGraphic;
		protected var _graph4:SGraphic;
		
		protected var _currentFrame:int;
		protected var _list:SFreeList;
		
		public function RebirthDocument ()
		{
			initTraceLogger();
			initAppViewController();
		}
		
		override public function init ():void
		{
			trace("SDocument.init", _wrapper);
			
			_wrapper.enableStyleCentral();
			_wrapper.enableTouchDispatcher();
			_wrapper.enableTouchEmulator();
			_wrapper.showStats();
			
			_wrapper.styleCentral.styleData = {
				".component1" : {
					center: [0, 0],
					size: [200, 200],
					backgroundGraphic: {
						background: [0xFF0000, 1, SBackgroundType.VERTICAL_GRADIENT, 0x000000, 1],
						border: [10, 0xFF0000]
					}
				},
				".component1 .label" : {
					font: "Helvetica",
					fontSize: "18",
					bold: true,
					color: 0xFFFFFF
				}
			};
			
			var c1:SComponent = new SComponent();
			c1.style("component1");
			c1.into(_wrapper.root);
			
			var text:SLabel = new SLabel(true, false, "Salut");
			text.style("label");
			text.center(0, 0).into(c1);
			
			var central:Central = Central.getInstance();
			central.listen("tutu", function (pName:String, pId:int):void {
				trace(arguments);
			});
			
			central.dispatch("tutu", 4);
			central.removeAll("tutu");
			central.dispatch("tutu", 3);
			
			/*
			var html:SHTMLText = new SHTMLText(false, true, true);
			html.style("label");
			html.textStyle();
			html.html('<a href="">TUTU</a><br>TEST<br><u>TEST</u>');
			html.place(0, 0, 0, 0).into(c1);
			*/
			
			//c1.center(0, 0).size(200, 200);
			//c1.backgroundImage.border(1);
			
			/*
			var ba:ByteArray = (new AtlasXMLTest as ByteArray);
			
			var atlas:SAtlas = new SAtlas(
				(new AtlasImageTest as Bitmap).bitmapData,
				new XML(ba.readUTFBytes(ba.length)),
				2
			);
			
			trace(atlas.getNames());
			
			//var atlasItem:SAtlasItem = atlas.getAtlasItem("start-button");
			var atlasItem:SAtlasItem = atlas.getAtlasItem("arrow-left");
			
			_graph1 = new SGraphic();
			_graph1.atlas(atlasItem);
			_graph1.border(1);
			_graph1.center(0, 0).into(_wrapper.root);
			*/
			
			/*
			_list = new SFreeList(this);
			_list.place(100, 100, 100, 100).into(_wrapper.root);
			_list.clipContent = true;
			*/
			
			/*
			
			var button:SButton = new SButton(false);
			button.styleEnabled = true;
			button.backgroundImage.background(SBackgroundType.FLAT, 0x333333);
			button.backgroundImage.allRadius(10);
			button.size(150, 30).center(0, 0).into(_wrapper.root);;
			
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
				ratio : {_wrapper.ratio}
			</text>.toString().replace(/(\t|\r)/g, "");
			addChild(textField);
			*/
			//trace(10000000000000000 === 10000000000000001);
			
		}
		
		/* INTERFACE fr.swapp.graphic.lists.IVirtualListDelegate */
		
		public function getFirstVirtualIndex (pTarget:SVirtualList):int
		{
			return 0;
		}
		
		public function getLastVirtualIndex (pTarget:SVirtualList):int
		{
			return 100;
		}
		
		public function getVirtualElement (pTarget:SVirtualList, pIndex:int):SComponent
		{
			var component:SComponent;
			
			/*
			component = new SComponent();
			component.styleEnabled = true;
			component.backgroundImage.background(SBackgroundType.FLAT, Math.random() * 0xFFFFFF);
			
			var c:SComponent = component;
			var oldC:SComponent;
			for (var i:int = 0; i < 6; i++) 
			{
				oldC = c;
				c = new SComponent();
				c.styleEnabled = true;
				c.backgroundImage.background(SBackgroundType.FLAT, Math.random() * 0xFFFFFF);
				c.place(10, 10, 10, 10).into(oldC);
			}
			*/
			
			if (pTarget == _list)
			{
				component = new SFreeList(this, "horizontal");
			}
			else
			{
				component = new SComponent();
				component.styleEnabled = true;
				component.backgroundGraphic.background(Math.random() * 0xFFFFFF);
				
				var button:SButton = new SButton();
				button.styleEnabled = true;
				button.backgroundGraphic.background(0x333333, 1, SBackgroundType.VERTICAL_GRADIENT, 0x000000, 1);
				button.backgroundGraphic.radius(10);
				button.center(0, 0).size(80, 30).into(component);
			}
			
			return component;
		}
		
		public function getVirtualTipicalElementSize (pTarget:SVirtualList):int
		{
			return 160;
		}
		
		protected function enterFrameHandler (event:Event):void
		{
			_currentFrame ++;
			_graph1.bitmapOffset(_currentFrame, - _currentFrame / 2);
			
			_graph4.size(Math.sin(_currentFrame / 50) * 100 + 200, Math.cos(_currentFrame / 60) * 100 + 200);
		}
	}
}