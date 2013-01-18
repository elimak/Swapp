package fr.swapptesting.virtuallist 
{
	import com.greensock.TweenMax;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import fr.swapp.graphic.base.ResizableComponent;
	import fr.swapp.graphic.components.misc.BorderComponent;
	import fr.swapp.graphic.components.text.Label;
	
	/**
	 * ...
	 * @author ZoulouX
	 */
	public class FreeListElement extends ResizableComponent 
	{
		protected var _hasContent:Boolean;
		
		public function FreeListElement (pHasContent:Boolean, pIndex:int = 0)
		{
			_styleEnabled = true;
			
			(new BorderComponent(0x666666, 1)).place(0, 0, 0, 0).into(this);
			
			_hasContent = pHasContent;
			
			if (pHasContent)
			{
				(new Label(true)).text(pIndex + " - " + Math.random()).rectPlace(10, 10).into(this);
				
				backgroundImage.background(0xFFFFFF * Math.random(), 1);
			}
			else
			{
				backgroundImage.background(0xFFFFFF, 1);
			}
			
			//flatten();
			
			addEventListener(MouseEvent.CLICK, clickHandler);
		}
		
		/**
		 * Clic
		 */
		protected function clickHandler (event:MouseEvent):void 
		{
			TweenMax.to(this, .4, {
				height: Math.random() * 100 + 50
			});
		}
		/*
		override protected function preparePhase():void 
		{
			trace("PREPARE PHASE FLE");
			
			super.preparePhase();
		}
		
		override protected function renderPhase():void 
		{
			trace("RENDER PHASE FLE");
			
			super.renderPhase();
		}
		
		override protected function replace ():void 
		{
			trace("REPLACE FLE");
			
			super.replace();
		}
		
		
		override protected function removedHandler (event:Event):void
		{
			trace("REMOVED", index, _watchedParent);
			
			super.removedHandler(event);
			
			//trace(_watchedParent);
		}
		*/
	}
}