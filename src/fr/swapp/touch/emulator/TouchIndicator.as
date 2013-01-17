package fr.swapp.touch.emulator 
{
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.TouchEvent;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.utils.Dictionary;
	
	/**
	 * @author ZoulouX
	 */
	public class TouchIndicator 
	{
		public static var DEFAULT_POINT_SIZE		:Number				= Multitouch.inputMode == MultitouchInputMode.TOUCH_POINT ? 60 : 30;
		public static var DEFAULT_POINT_COLOR		:uint				= 0xCECECE;
		public static var DEFAULT_POINT_ALPHA		:Number				= 0.5;
		public static var DEFAULT_OUTLINE_COLOR		:uint				= 0x660000;
		public static var DEFAULT_OUTLINE_WIDTH		:Number				= 0.9;
		
		protected static var __points				:Dictionary 		= new Dictionary();
		
		public static function enableOn (pStage:Stage):void
		{
			if (pStage != null)
			{
				pStage.addEventListener(TouchEvent.TOUCH_BEGIN, touchBeginHandler);
				pStage.addEventListener(TouchEvent.TOUCH_MOVE, touchMoveHandler);
				pStage.addEventListener(TouchEvent.TOUCH_END, touchEndHandler);
				
				__points[pStage] = [];
			}
		}
		
		public static function disableOn (pStage:Stage):void
		{
			if (pStage != null)
			{
				pStage.removeEventListener(TouchEvent.TOUCH_BEGIN, touchBeginHandler);
				pStage.removeEventListener(TouchEvent.TOUCH_MOVE, touchMoveHandler);
				pStage.removeEventListener(TouchEvent.TOUCH_END, touchEndHandler);
				
				for each (var element:Sprite in __points[pStage])
				{
					pStage.removeChild(element);
				}
				
				__points[pStage] = null;
			}
		}
		
		public static function isEnabledOn (pStage:Stage):Boolean
		{
			return __points[pStage] != null;
		}
		
		public static function showCross (pStage:Stage, pX:Number, pY:Number):void
		{
			if (pStage != null)
			{
				var cross:Sprite;
				
				if (__points[pStage]["cross"] == null)
				{
					cross = new VisualCross();
					
					__points[pStage]["cross"] = cross;
				}
				else
				{
					cross = __points[pStage]["cross"] as Sprite;
				}
				
				cross.x = pX;
				cross.y = pY;
				
				pStage.addChild(cross);
			}
		}
		
		public static function hideCross (pStage:Stage):void
		{
			if (pStage != null && __points[pStage]["cross"] != null && pStage.contains(__points[pStage]["cross"]))
			{
				pStage.removeChild(__points[pStage]["cross"]);
			}
		}
		
		protected static function touchBeginHandler (event:TouchEvent):void
		{
			__points[event.currentTarget][event.touchPointID] = new VisualTouchPoint(event.touchPointID, DEFAULT_POINT_SIZE, DEFAULT_POINT_COLOR, DEFAULT_POINT_ALPHA);
			
			(event.currentTarget as Stage).addChild(__points[event.currentTarget][event.touchPointID]);
			
			touchMoveHandler(event);
		}
		
		protected static function touchMoveHandler (event:TouchEvent):void
		{
			(__points[event.currentTarget][event.touchPointID] as VisualTouchPoint).x = event.stageX;
			(__points[event.currentTarget][event.touchPointID] as VisualTouchPoint).y = event.stageY;
		}
		
		protected static function touchEndHandler (event:TouchEvent):void
		{
			(event.currentTarget as Stage).removeChild(__points[event.currentTarget][event.touchPointID]);
			__points[event.currentTarget][event.touchPointID] = null;
		}
	}
}