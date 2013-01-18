package fr.swapp.utils
{
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.CapsStyle;
import flash.display.JointStyle;
import flash.display.LineScaleMode;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.system.System;
import flash.text.StyleSheet;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.utils.getTimer;

/**
 * Improved Stats
 * https://github.com/MindScriptAct/Hi-ReS-Stats(fork of https://github.com/mrdoob/Hi-ReS-Stats)
 * Merged with : https://github.com/rafaelrinaldi/Hi-ReS-Stats AND https://github.com/shamruk/Hi-ReS-Stats
 *
 * Released under MIT license:
 * http://www.opensource.org/licenses/mit-license.php
 *
 * How to use:
 * 
 * Simplest:
 * this.addChild(new Stats());
 *
 * Make it bigger, smallest possible value is 70.(width):
 * addChild(new Stats(150));
 * 
 * Change initial position (x, y): 
 * addChild(new Stats(150, 10, 20));
 *
 * Make it minimized(isMinimized):
 * addChild(new Stats(150, 10, 20, true));
 * 
 * Make it not draggable(isDraggable):
 * addChild(new Stats(150, 10, 20, false, false));
 * 
 * Enable monitoring feature(isMonitoring):
 * addChild(new Stats(150, 10, 20, false, true, true));
 * 
 * Scale it easealy(scale):
 * addChild(new Stats(150, 10, 20, false, true, true, 2)); 
 * 
 * OR :
 * 
 * var stats:Stats = new Stats();
 * this.addChild(stats);
 * stats.width = 150;
 * stats.x = 10;
 * stats.y = 200;
 * //stats.isMinimized = true;
 * //stats.isDraggable = false;
 * stats.isMonitoring = true;
 * //stats.scale = 2;
 * 
 **/

public class Stats extends Sprite
{
	// stats default size.
	private const DEFAULT_WIDTH:int = 100;
	private const DEFAULT_HEIGHT:int = 100;
	private const MINIMIZED_WIDTH:int = 62;
	private const MINIMIZED_HEIGHT:int = 13;
	private const MONITOR_WIDTH:int = 100;
	

	// bonus width addet to default WIDTH.
	private var _bonusWidth:int = 0;

	// stats data in XML format.
	private var statData:XML;
	private var statDataMinimized:XML;

	// textField for stats information
	private var statsText:TextField;
	private var style:StyleSheet;

	// reacent getTimer value.
	private var timer:uint = 0;

	// current stat data
	private var fps:int = 0;
	private var lastTimer:int = 0;
	private var tickTimer:int = 0;
	private var mem:Number = 0;
	private var memMax:Number = 0;

	// data for monitoring
	private var frameRateTime:int;
	private var codeTime:uint;
	private var frameTime:uint;

	//  graph draw object
	private var graph_BD:BitmapData;
	private var clearRect:Rectangle;

	// monitoring draw object
	private var monitorView_BD:BitmapData;
	private var monitorView:Bitmap;
	private var codeRect:Rectangle;
	private var renderRect:Rectangle;
	private var clearMonitorRect:Rectangle;
	private var frameRateRect:Rectangle;
	private var monitoringHistoryRect:Rectangle;
	private var monitoringHistoryNewPoint:Point;
	private var monitorSeparatorRect:Rectangle;


	// current graph draw value.
	private var fpsGraph:int = 0;
	private var memGraph:int = 0;
	private var memMaxGraph:int = 0;

	// object for collor values. (it performs tini bit faster then constants.)
	private var colors:StatColors = new StatColors();

	// flag for counter to be in minimized state. (stats are still tracked, but not shown.)
	private var _isMinimized:Boolean;

	// flag for stats beeing dragable or not.
	private var _isDraggable:Boolean = false;

	// flag to show application execution and render monitoring.
	private var _isMonitoring:Boolean = false;
	private var _xOffset:Number;
	private var _yOffset:Number;
	private var _moved:int = -1;

	/**
	 * Stats - FPS, MS and MEM, all in one.
	 * @param	width			Starting width of Stats object. If it is less then 70 - it will be set to default(70).
	 * @param	x				initial x position
	 * @param	y				initial y position
	 * @param	isMinimized		initial minimize status. (not minimized by default)
	 * @param	isDraggable		makes stats dragable or not. (dragable by default)
	 * @param	isMonitoring	flag to start monitoring frame execution time. (will not monitor by default.)
	 * @param	scale			simplified scaling of stat object.
	 */
	public function Stats(width:int = 70, x:int = 0, y:int = 0, isMinimized:Boolean = false, isDraggable:Boolean = true, isMonitoring:Boolean = false):void {
		//
		this._isDraggable = isDraggable;
		this._isMonitoring = isMonitoring;
		this._isMinimized = isMinimized;

		// calculate increased width.
		bonusWidth = width - DEFAULT_WIDTH;

		// initial positioning
		this.x = x;
		this.y = y;

		// stat data stored in XML formated text.
		statData = <xmlData>
				<fps>FPS:</fps>
				<ms>MS:</ms>
				<mem>MEM:</mem>
				<memMax>MAX:</memMax>
			</xmlData>;

		statDataMinimized = <xmlData>
				<fps>FPS:</fps>
			</xmlData>;			

		// text fild to show all stats.
		statsText = new TextField();
		statsText.autoSize = TextFieldAutoSize.LEFT;
		statsText.styleSheet = style;
		statsText.condenseWhite = true;
		statsText.selectable = false;
		statsText.mouseEnabled = false;

		// style for stats.
		style = new StyleSheet();
		style.setStyle('xmlData', {fontSize: '9px', fontFamily: '_sans', leading: '-2px'});
		style.setStyle('fps', {color: "#" + (colors.fps).toString(16)});
		style.setStyle('ms', {color: "#" + (colors.ms).toString(16)});
		style.setStyle('mem', {color: "#" + (colors.mem).toString(16)});
		style.setStyle('memMax', {color: "#" + (colors.memMax).toString(16)});
		statsText.styleSheet = style;

		//
		graph_BD = new BitmapData(DEFAULT_WIDTH + _bonusWidth, DEFAULT_HEIGHT - 50, false, colors.bg);

		//
		addEventListener(Event.ADDED_TO_STAGE, init, false, 0, true);
		addEventListener(Event.REMOVED_FROM_STAGE, destroy, false, 0, true);
		//
		this.mouseChildren = false;
	}

	//----------------------------------
	//     init
	//----------------------------------

	// stats are initialized then put tu stage.
	private function init(event:Event):void {
		// add text
		addChild(statsText);
		// set initial time in ms for 1 frame.
		frameRateTime = Math.round(1000 / this.stage.frameRate);

		// init objects for later reuse.
		codeRect = new Rectangle(0, 0, -1, 10);
		renderRect = new Rectangle(-1, 0, -1, 10);
		clearMonitorRect = new Rectangle(-1, 0, MONITOR_WIDTH, 10);
		frameRateRect = new Rectangle(frameRateTime, 0, 1, 10);
		monitoringHistoryRect = new Rectangle(0, 9, MONITOR_WIDTH, DEFAULT_HEIGHT);
		monitoringHistoryNewPoint = new Point(0, 10);
		monitorSeparatorRect = new Rectangle(0, 8, MONITOR_WIDTH, 1)

		// add events.
		addEventListener(Event.ENTER_FRAME, handleFrameTick);

		// init draging feature by using setter. 
		isDraggable = _isDraggable;

		// draw bg and graph
		initDrawArea();

	}

	// funciton to init or reInit all visuol object.
	private function initDrawArea():void {
		initBackground();
		initGraph();
		initMonitoring();
	}

	// draw bg with buttons
	private function initBackground():void {
		graphics.clear();
		graphics.beginFill(colors.bg);
		if (_isMinimized) {
			graphics.drawRect(0, 0, MINIMIZED_WIDTH, MINIMIZED_HEIGHT);
		} else {
			graphics.drawRect(0, 0, DEFAULT_WIDTH + _bonusWidth, DEFAULT_HEIGHT);
		}
		graphics.endFill();

		//
		graphics.lineStyle();
	}

	// draw graph
	private function initGraph():void {
		if (!_isMinimized) {
			if (graph_BD) {
				var oldGraph_BD:BitmapData = graph_BD;
			}
			graph_BD = new BitmapData(DEFAULT_WIDTH + _bonusWidth, DEFAULT_HEIGHT - 50, false, colors.bg);

			graphics.beginBitmapFill(graph_BD, new Matrix(1, 0, 0, 1, 0, 50));
			graphics.drawRect(0, 50, DEFAULT_WIDTH + _bonusWidth, DEFAULT_HEIGHT - 50);
			// if oldGraph is set - drow its content into new graph.
			if (oldGraph_BD) {
				graph_BD.copyPixels(oldGraph_BD, oldGraph_BD.rect, new Point(graph_BD.width - oldGraph_BD.width, 0));
				oldGraph_BD.dispose();
			}
		}
	}

	// init monitoring feature
	private function initMonitoring():void {
		// draw button outline.
		graphics.lineStyle();

		// handle  monitorView
		if (_isMonitoring) {
			if (!monitorView) {
				monitorView_BD = new BitmapData(MONITOR_WIDTH, DEFAULT_HEIGHT, false, colors.bg);
				monitorView = new Bitmap(monitorView_BD);
			}
			if (!this.contains(monitorView)) {
				this.addChild(monitorView);
			}
			monitorView.x = DEFAULT_WIDTH + _bonusWidth + 1;
		} else {
			if (monitorView_BD) {
				monitorView_BD.fillRect(monitorView_BD.rect, colors.bg);
			}
			if (monitorView) {
				if (this.contains(monitorView)) {
					this.removeChild(monitorView);
				}
			}
		}

		// hide monitoring if minimized.
		if (_isMinimized) {
			if (monitorView) {
				if (this.contains(monitorView)) {
					this.removeChild(monitorView);
				}
			}
		}

		// handle events
		if (_isMonitoring) {
			if (!this.stage.hasEventListener(Event.RENDER)) {
				this.stage.addEventListener(Event.RENDER, handleFrameRender);
			}
		} else {
			if (this.stage.hasEventListener(Event.RENDER)) {
				this.stage.removeEventListener(Event.RENDER, handleFrameRender);
			}
		}
	}

	//----------------------------------
	//      
	//----------------------------------

	private function destroy(event:Event):void {
		// clear bg
		graphics.clear();

		// remove all childs.
		while (numChildren > 0) {
			removeChildAt(0);
		}

		// dispose graph bitmap.
		graph_BD.dispose();

		// remove listeners.
		removeEventListener(Event.ENTER_FRAME, handleFrameTick);

		if (_isDraggable) {
			stage.removeEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
			stage.removeEventListener(Event.MOUSE_LEAVE, mouseLeaveHandler);
			removeEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
		}
	}

	// every frame calculate frame stats.
	private function handleFrameTick(event:Event):void {

		frameTime = getTimer() - timer;
		timer = getTimer();

		// calculate time change from last tick in ms.
		var tickTime:uint = timer - tickTimer;

		// check if more then 1 second passed.
		if (tickTime >= 1000) {
			//
			tickTimer = timer;

			// calculate ammount of missed seconds. (this can happen then player hangs more then 2 seccond on a job.)
			var missedTicks:uint = (tickTime - 1000) / 1000;

			// get current memory.
			mem = Number((System.totalMemory * 0.000000954).toFixed(3));

			// update max memory.
			if (memMax < mem) {
				memMax = mem;
			}

			// calculate graph point positios.
			fpsGraph = Math.min(graph_BD.height, (fps / stage.frameRate) * graph_BD.height);
			memGraph = Math.min(graph_BD.height, Math.sqrt(Math.sqrt(mem * 5000))) - 2;
			memMaxGraph = Math.min(graph_BD.height, Math.sqrt(Math.sqrt(memMax * 5000))) - 2;

			// move graph by 1 pixels for every second passed.
			graph_BD.scroll(-1 - missedTicks, 0);

			// clear rectangle area for new graph data.
			if (missedTicks) {
				graph_BD.fillRect(new Rectangle(graph_BD.width - 1 - missedTicks, 0, 1 + missedTicks, DEFAULT_HEIGHT - 50), colors.bg);
			} else {
				graph_BD.fillRect(clearRect, colors.bg);
			}

			// draw missed seconds. (if player failed to respond for more then 1 second that means it was hanging, and FPS was < 1 for that time.)
			while (missedTicks) {
				graph_BD.setPixel(graph_BD.width - 1 - missedTicks, graph_BD.height - 1, colors.fps);
				missedTicks--;
			}

			// draw current graph data. 
			graph_BD.setPixel(graph_BD.width - 1, graph_BD.height - ((timer - lastTimer) >> 1), colors.ms);
			graph_BD.setPixel(graph_BD.width - 1, graph_BD.height - memGraph, colors.mem);
			graph_BD.setPixel(graph_BD.width - 1, graph_BD.height - memMaxGraph, colors.memMax);
			graph_BD.setPixel(graph_BD.width - 1, graph_BD.height - fpsGraph, colors.fps);

			// update data for new frame stats.
			if (_isMinimized) {
				statDataMinimized.fps = "FPS: " + fps + " / " + stage.frameRate;
			} else {
				statData.fps = "FPS: " + fps + " / " + stage.frameRate;
				statData.mem = "MEM: " + mem;
				statData.memMax = "MAX: " + memMax;
			}

			// frame count for 1 second handled - reset it.
			fps = 0;
		}

		// handle monitoring
		if (_isMonitoring) {
			this.stage.invalidate();

			// drawCodeTime
			codeRect.width = codeTime;
			monitorView_BD.fillRect(codeRect, colors.executionTime);
			// draw frameTime
			renderRect.x = codeTime;
			renderRect.width = frameTime - codeTime;
			monitorView_BD.fillRect(renderRect, colors.ms);
			// clean rest of the line
			clearMonitorRect.x = frameTime;
			monitorView_BD.fillRect(clearMonitorRect, colors.bg);
			// frame time delimeter
			monitorView_BD.fillRect(frameRateRect, colors.fps);
			//
			// move monitoring history one line down
			monitorView_BD.copyPixels(monitorView_BD, monitoringHistoryRect, monitoringHistoryNewPoint);
			// separator for main graph and log.
			monitorView_BD.fillRect(monitorSeparatorRect, colors.monitorSeparator);
		}

		// time in ms for one frame tick.
		statData.ms = "MS: " + frameTime;

		// update data text.
		if (_isMinimized) {
			statsText.htmlText = statDataMinimized;
		} else {
			statsText.htmlText = statData;
		}
		// increse frame tick count by 1.
		fps++;
		//
		lastTimer = timer;
	}

	// 
	private function handleFrameRender(event:Event):void {
		codeTime = getTimer() - timer;
	}

	//----------------------------------
	//     Dragging functions
	//----------------------------------

	// start dragging
	private function handleMouseDown(event:MouseEvent):void
	{
		_xOffset = mouseX * this.transform.concatenatedMatrix.a;
		_yOffset = mouseY * this.transform.concatenatedMatrix.d;
		_moved = 0;
		this.stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
	}
	
	// stop dragging
	private function handleMouseUp(event:MouseEvent):void {
		this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
		
		if (_moved >= 0 && _moved <= 2)
		{
			if (_isMinimized)
			{
				isMinimized = false;
				isMonitoring = false;
			}
			else if (!_isMonitoring)
			{
				isMonitoring = true;
			}
			else
			{
				isMinimized = true;
			}
			
		}
		
		_moved = -1;
	}

	// handle dragging
	private function mouseMoveHandler(event:MouseEvent):void {
		_moved ++;
		// calculete new possitions.
		if (_isMinimized) {
			this.x = this.stage.mouseX - _xOffset;
			this.y = this.stage.mouseY - _yOffset;
		} else {
			this.x = this.stage.mouseX - _xOffset;
			this.y = this.stage.mouseY - _yOffset;
		}
		fitToStage();
	}

	private function fitToStage():void {
		// handle x bounds
		if (this.x > this.stage.stageWidth - this.width) {
			this.x = this.stage.stageWidth - this.width;
		}
		if (this.x < 0) {
			this.x = 0;
		}
		// handle y bounds.
		if (this.y > this.stage.stageHeight - this.height) {
			this.y = this.stage.stageHeight - this.height;
		}
		if (this.y < 0) {
			this.y = 0;
		}
	}

	// handle mouse leaving the screen.
	private function mouseLeaveHandler(event:Event):void {
		this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
	}

	//----------------------------------
	//     get/set
	//----------------------------------

	/**
	 * flag for stats beeing dragable or not.
	 */
	public function get isDraggable():Boolean {
		return _isDraggable;
	}

	/**
	 * flag for stats beeing dragable or not.
	 */
	public function set isDraggable(value:Boolean):void {
		_isDraggable = value;
		if (_isDraggable) {
			if (stage) {
				if (!stage.hasEventListener(MouseEvent.MOUSE_UP)) {
					stage.addEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
					stage.addEventListener(Event.MOUSE_LEAVE, mouseLeaveHandler);
					addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
				}
			}
		} else {
			if (stage) {
				if (stage.hasEventListener(MouseEvent.MOUSE_UP)) {
					stage.removeEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
					stage.removeEventListener(Event.MOUSE_LEAVE, mouseLeaveHandler);
					removeEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
				}
			}
		}
	}

	/**
	 * flag to show application execution and render monitoring.
	 */
	public function get isMonitoring():Boolean {
		return _isMonitoring;
	}

	/**
	 * flag to show application execution and render monitoring.
	 */
	public function set isMonitoring(value:Boolean):void {
		_isMonitoring = value;
		initMonitoring();
		fitToStage();
	}

	/**
	 * flag for counter to be in minimized state. (stats are still tracked, but not shown.)
	 */
	public function get isMinimized():Boolean {
		return _isMinimized;
	}

	/**
	 * flag for counter to be in minimized state. (stats are still tracked, but not shown.)
	 */
	public function set isMinimized(value:Boolean):void {
		_isMinimized = value;
		initDrawArea();
		fitToStage();
	}

	/**
	 * Change width. If it is less then 70 - it will be set to default value - 70.
	 */
	override public function set width(value:Number):void {
		// calculate increased width.
		bonusWidth = value - DEFAULT_WIDTH;
		initDrawArea();
		fitToStage();
	}

	private function set bonusWidth(value:int):void {
		_bonusWidth = value;
		if (_bonusWidth < 0) {
			_bonusWidth = 0;
		}
		clearRect = new Rectangle(DEFAULT_WIDTH + _bonusWidth - 1, 0, 1, DEFAULT_HEIGHT - 50);
	}

	override public function set height(value:Number):void {
		throw Error("It's not possible to change Stats object height. Sorry.");
	}
}
}

// helper class to store graph colors.
class StatColors {
	public var bg:uint = 0x000033;
	public var fps:uint = 0xFFFF00;
	public var ms:uint = 0x00FF00;
	public var mem:uint = 0x00FFFF;
	public var memMax:uint = 0xFF0070;

	public var executionTime:uint = 0xFF0000;
	public var monitorSeparator:int = 0xD8D8D8;
}