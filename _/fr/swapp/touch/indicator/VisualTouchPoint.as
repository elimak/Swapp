package fr.swapp.touch.indicator 
{
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * @author ZoulouX
	 */
	public class VisualTouchPoint extends Sprite
	{
		protected var _pointId			:uint;
		protected var _text				:TextField 			= new TextField();
		
		override public function set x (pValue:Number):void
		{
			super.x = pValue;
			
			updateText();
		}
		override public function set y (pValue:Number):void
		{
			super.y = pValue;
			
			updateText();
		}
		
		public function VisualTouchPoint (pPointId:uint = 0, pSize:Number = 10, pColor:uint =  0xFFFFFF, pAlpha:Number = .5, pOutlineColor:uint = 0x330000, pOutlineWidth:Number = 1)
		{
			_pointId = pPointId;
			
			if (pOutlineWidth > 0)
				graphics.lineStyle(pOutlineWidth, pOutlineColor);
			
			graphics.beginFill(pColor, pAlpha);
			graphics.drawCircle(0, 0, pSize / 2);
			graphics.endFill();
			
			_text.width = 44;
			_text.height = 44;
			_text.multiline = true;
			
			_text.x = - pSize / 2 - _text.width - 4;
			_text.y = - pSize / 2 - _text.height - 4;
			
			var textFormat:TextFormat = new TextFormat("Arial", 10, 0x333333);
			textFormat.align = TextFormatAlign.RIGHT;
			
			_text.defaultTextFormat = textFormat;
			
			addChild(_text);
			
			hitArea = new Sprite();
			mouseEnabled = false;
			mouseChildren = false;
			
			updateText();
		}
		
		public function updateText ():void
		{
			_text.text = "id: " + _pointId + "\nx: " + int(x) + "\ny: " + int(y);
		}
	}
}