package fr.swapptesting.graphics
{
	import flash.display.StageAspectRatio;
	import flash.events.Event;
	import flash.events.TouchEvent;
	import flash.utils.getTimer;
	import fr.swapp.core.data.config.Config;
	import fr.swapp.graphic.animation.SAtlasAnimation;
	import fr.swapp.graphic.atlas.SAtlas;
	import fr.swapp.graphic.atlas.SAtlasItem;
	import fr.swapp.graphic.base.SBackgroundType;
	import fr.swapp.graphic.base.SGraphic;
	import fr.swapp.graphic.base.SRenderMode;
	import fr.swapp.graphic.document.SAirDocument;
	import fr.swapp.utils.EmbedUtils;
	
	/**
	 * @author ZoulouX
	 */
	public class GraphicsTest extends SAirDocument
	{
		protected var _graphic1:SGraphic;
		protected var _atlasAnimation:SAtlasAnimation;
		[Embed(source="../../../../lib/images/lhs-animation.png")]
		public static const LHSAnimationSprite:Class;
		
		[Embed(source="../../../../lib/images/lhs-animation.xml", mimeType="application/octet-stream")]
		public static const LHSAnimationXML:Class
		
		
		/**
		 * Constructor
		 */
		public function GraphicsTest () { }
		
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
			
			// Activer le wrapper
			enableWrapper(true, true, NaN, NaN, StageAspectRatio.ANY);
			
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		protected function enterFrameHandler (event:Event):void 
		{
			if (_graphic1 != null)
			{
				_graphic1.rotation += 5;
				
				_graphic1.scale((Math.sin(getTimer() / 1000) + 2));
			}
		}
		
		/**
		 * Document is ready
		 */
		override protected function ready ():void
		{
			// Test du pivot
			
			var backround:SGraphic = new SGraphic();
			backround.background(0xFF0000, 0.5).radius(100).size(120, 120).center(0, 0).into(_wrapper.root);
			
			_graphic1 = new SGraphic();
			_graphic1.background(0, 1, SBackgroundType.VERTICAL_GRADIENT, 0xAAAAAA, 1).radius(10);
			_graphic1.center(0, 0).size(100, 50)
			_graphic1.pivot(50, 25).into(_wrapper.root);
			
			// Test de la récupération de la sequence d'atlas
			var atlas:SAtlas = new SAtlas(
				EmbedUtils.getBitmapData(LHSAnimationSprite),
				EmbedUtils.getXML(LHSAnimationXML)
			);
			
			var sequence:Vector.<SAtlasItem> = atlas.getAtlasSequence("lhs");
			
			trace("ATLAS SEQUENCE ---");
			trace(sequence);
			
			// Test de SAtlasAnimation
			var atlasAnimation:SAtlasAnimation;
			
			for (var i:int = 0; i < 4; i++) 
			{
				atlasAnimation = new SAtlasAnimation(sequence, SRenderMode.AUTO_SIZE, 60);
				
				if (i == 0)
				{
					atlasAnimation.place(50, NaN, NaN, 50);
				}
				else if (i == 1)
				{
					atlasAnimation.place(50, 50, NaN, NaN);
				}
				else if (i == 2)
				{
					atlasAnimation.place(NaN, 50, 50, NaN);
				}
				else if (i == 3)
				{
					atlasAnimation.place(NaN, NaN, 50, 50);
				}
				
				atlasAnimation.into(_wrapper.root);
				atlasAnimation.play(1, 45);
				atlasAnimation.addEventListener(TouchEvent.TOUCH_BEGIN, animationTouchHandler);
			}
		}
		
		protected function animationTouchHandler (event:TouchEvent):void
		{
			if (event.currentTarget is SAtlasAnimation)
			{
				var atlasAnimation:SAtlasAnimation = (event.currentTarget as SAtlasAnimation);
				
				atlasAnimation.play(Math.random() > 0.5 ? 1 : -1, atlasAnimation.currentFrame == 0 ? 45 : 0);
			}
		}
	}
}