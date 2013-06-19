package fr.swapptesting.document
{
	import flash.display.Sprite;
	import flash.display.StageAspectRatio;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import fr.swapp.core.data.config.Config;
	import fr.swapp.core.log.Log;
	import fr.swapp.graphic.base.SGraphic;
	import fr.swapp.graphic.document.SAirDocument;
	import fr.swapp.utils.EnvUtils;
	
	/**
	 * @author ZoulouX
	 */
	public class AirDocumentTest extends SAirDocument
	{
		/**
		 * Constructor
		 */
		public function AirDocumentTest () { }
		
		/**
		 * Document initialization
		 */
		override protected function init ():void
		{
			// Enable logger
			enableLogger();
			
			// Enable config
			enableConfig(Config.DEBUG_ENVIRONMENT, {
				// GLOBAL
				
			}, {
				// DEBUG
				
			}, {
				// TEST
				
			}, {
				// PRODUCTION
				
			});
			
			// Enable input dispatcher
			enableInputDispatcher(true, true);
			
			// Enable touch emulator for desktop
			enableTouchEmulator();
			
			// Si on est sur mobile
			if (EnvUtils.like(EnvUtils.PHONE_SIZE))
			{
				// Activer le wrapper en bloquant à la verticale
				//enableWrapper(true, true, 300, 500, StageAspectRatio.PORTRAIT);
				enableWrapper(true, true, NaN, NaN, StageAspectRatio.PORTRAIT);
			}
			else// if (EnvUtils.like(EnvUtils.TABLET_SIZE))
			{
				// Activer le wrapper en bloquant à l'horizontale
				//enableWrapper(true, true, 960, 680, StageAspectRatio.LANDSCAPE);
				enableWrapper(true, true, NaN, NaN, StageAspectRatio.LANDSCAPE);
			}
			
			// Créer les boutons de test
			createButton(10, 10, 100, 50, 0xFF0000, function ():void {
				_wrapper.pushAspectRatio(StageAspectRatio.LANDSCAPE, logStageDimension );
			});
			createButton(10, 70, 100, 50, 0x00FF00, function ():void {
				_wrapper.pushAspectRatio(StageAspectRatio.PORTRAIT, logStageDimension);
			});
			createButton(10, 130, 100, 50, 0x000000, function ():void {
				_wrapper.pushAspectRatio(StageAspectRatio.ANY, logStageDimension);
			});
		}
		
		protected function logStageDimension ():void
		{
			trace("ok", stage.stageWidth, stage.stageHeight, _wrapper.root.width, _wrapper.root.height);
		}
		
		/**
		 * Create test button
		 */
		public function createButton (pX:Number, pY:Number, pWidth:Number, pHeight:Number, pColor:uint, pHandler:Function):Sprite
		{
			var sprite:Sprite = new Sprite();
			
			sprite.graphics.beginFill(pColor);
			sprite.graphics.drawRect(0, 0, pWidth, pHeight);
			sprite.graphics.endFill();
			
			sprite.x = pX;
			sprite.y = pY;
			
			sprite.addEventListener(MouseEvent.CLICK, function (event:Event):void {
				pHandler();
			});
			
			addChild(sprite);
			
			return sprite;
		}
		
		/**
		 * When document is ready
		 */
		override protected function ready ():void
		{
			trace("READY");
			logStageDimension();
			/*
			var component:SGraphic = new SGraphic();
			component.background(0xCCCCCC).place(10, 10, 10, 10);
			component.into(_wrapper.root);
			*/
			
			graphics.beginFill(0xCCCCCC);
			graphics.drawRect(15, 15, stage.stageWidth - 30, stage.stageHeight - 30);
			graphics.endFill();
		}
	}
}