package fr.swapptesting.virtuallist
{
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.utils.setTimeout;
	import fr.swapp.core.entries.Document;
	import fr.swapp.core.log.Log;
	import fr.swapp.core.log.TraceLogger;
	import fr.swapp.graphic.base.ResizableComponent;
	import fr.swapp.graphic.base.StageWrapper;
	import fr.swapp.graphic.components.lists.AVirtualList;
	import fr.swapp.graphic.components.lists.FreeVirtualList;
	import fr.swapp.graphic.components.lists.IVirtualListDelegate;
	import fr.swapp.graphic.components.misc.BorderComponent;
	import fr.swapp.graphic.components.lists.StepVirtualList;
	import fr.swapp.touch.emulator.MouseToTouchEmulator;
	
	/**
	 * ...
	 * @author ZoulouX
	 */
	public class VirtualListTest extends Document implements IVirtualListDelegate
	{
		protected var _wrapper:StageWrapper;
		protected var _container:ResizableComponent;
		protected var _freeList:FreeVirtualList;
		protected var _stepList:StepVirtualList;
		
		public function VirtualListTest()
		{
			
		}
		
		override public function init():void
		{
			// DEBUG : Passer le listMovedHandler en phase de rendu
			
			setTimeout(start, 1);
		}
		
		public function start ():void
		{
			
			MouseToTouchEmulator.auto(stage);
			
			stage.quality = StageQuality.LOW;
			
			_wrapper = new StageWrapper(stage);
			
			_container = (new ResizableComponent()).place(10, 10, 10, 10).into(_wrapper);
			
			Log.addLogger(new TraceLogger());
			
			//_freeList = new FreeVirtualList(this, AVirtualList.VERTICAL_ORIENTATION);
			//_freeList.clipContent = true;
			//_freeList.dragAllowOppositeDirection = true;
			//_freeList.place(150, 0, 0, 0).into(_container);
			//_freeList.place(0, 0, 0, 0).into(_container);
			
			_stepList = new StepVirtualList(this, AVirtualList.HORIZONTAL_ORIENTATION);
			_stepList.clipContent = true;
			_stepList.place(0, 0, NaN, 0).size(NaN, 150).into(_container);
			_stepList.container.place(0, 10, 0, 10);
			//_stepList.elementsOverLoad = 2;
			
			//(new BorderComponent(0xFF0000, 2)).place(0, 0, 0, 0).into(_wrapper);
			(new BorderComponent(0x000000, 1)).place(0, 0, 0, 0).into(_container);
			//(new BorderComponent(0x00FF00, 1)).place(0, 0, 0, 0).into(_freeList);
			//(new BorderComponent(0x0000FF, 1)).place(0, 0, 0, 0).into(_stepList);
			//(new BorderComponent(0x0000FF, 1)).place(0, 0, 0, 0).into(_stepList.container);
			//(new BorderComponent(0xFF0000, 1)).place(0, 0, 0, 0).into(_freeList.container);
			
			//(new BorderComponent(0x0000FF, 1)).place(0, NaN, 0, NaN).center(0, NaN).size(160, NaN).into(_stepList);
			
			
			//addEventListener(Event.RENDER, firstRender);
			
			//stage.invalidate();
			
			//firstRender();
			
			//stage.addEventListener(MouseEvent.CLICK, firstRender);
		}
		
		protected function firstRender (event:Event = null):void
		{
			stage.removeEventListener(MouseEvent.CLICK, firstRender);
			//removeEventListener(Event.RENDER, firstRender);
			//trace("RENDER");
			//stage.invalidate();
			
			var element:FreeListElement = new FreeListElement(true, 50);
			
			element.place(10, 10, 10, 10).into(_container);
			
			element.addEventListener(MouseEvent.CLICK, function (event:Event):void {
				element.into(null);
				firstRender();
			});
		}
		
		public function getVListFirstElementIndex(pTarget:AVirtualList):int
		{
			return 0;
		}
		
		public function getVListLastElementIndex(pTarget:AVirtualList):int
		{
			if (pTarget == _freeList)
			{
				return 100;
			}
			else
			{
				return 10;
			}
		}
		
		public function getVListElementAt(pTarget:AVirtualList, pIndex:int):ResizableComponent
		{
			if (pTarget == _freeList)
			{
				if (pIndex >= getVListFirstElementIndex(pTarget) && pIndex <= getVListLastElementIndex(pTarget))
				{
					return new FreeListElement(true, pIndex)//.margin(5, 10, 5, 10);
				}
				else
				{
					return new FreeListElement(false);
				}
			}
			else if (pIndex >= getVListFirstElementIndex(pTarget) && pIndex <= getVListLastElementIndex(pTarget))
			{
				return new StepListElement(pIndex);
			}
			
			return null;
		}
		
		public function getVListTipicalElementSize(pTarget:AVirtualList):int
		{
			if (pTarget == _freeList)
			{
				return 80;
			}
			else
			{
				//return 100;
				//return 200;
				return 0;
			}
		}
	}
}