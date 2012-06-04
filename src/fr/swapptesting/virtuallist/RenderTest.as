package fr.swapptesting.virtuallist 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	 * ...
	 * @author ZoulouX
	 */
	public class RenderTest extends Sprite 
	{
		protected var a:Sprite;
		protected var b:Sprite;
		protected var c:Sprite;
		protected var d:Sprite;
		protected var other:Sprite;
		
		public function RenderTest() 
		{
			if (stage != null)
				initHandler(null)
			else
				addEventListener(Event.INIT, initHandler);
		}
		
		protected function initHandler(e:Event):void 
		{
			a = new Sprite();
			b = new Sprite();
			c = new Sprite();
			d = new Sprite();
			other = new Sprite();
			
			a.name = "a";
			b.name = "b";
			c.name = "c";
			d.name = "d";
			other.name = "other";
			
			this.addChild(a);
			this.addChild(other);
			a.addChild(b);
			b.addChild(c);
			c.addChild(d);
			
			a.addEventListener(Event.RENDER, renderHandler);
			b.addEventListener(Event.RENDER, renderHandler);
			c.addEventListener(Event.RENDER, renderHandler);
			d.addEventListener(Event.RENDER, renderHandler);
			other.addEventListener(Event.RENDER, renderHandler);
			
			
			stage.addEventListener(MouseEvent.CLICK, clickHandler);
		}
		
		protected function clickHandler(e:MouseEvent):void 
		{
			trace("click");
			
			
			c.stage.invalidate();
		}
		
		protected function renderHandler (e:Event):void
		{
			trace(e.target.name);
		}
	}
}