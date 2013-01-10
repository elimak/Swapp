package fr.swapptesting.style
{
	import flash.display.StageQuality;
	import fr.swapp.core.bootstrap.Bootstrap;
	import fr.swapp.core.entries.Document;
	import fr.swapp.graphic.base.ResizableComponent;
	import fr.swapp.graphic.base.StageWrapper;
	import fr.swapp.graphic.components.misc.BorderComponent;
	import fr.swapp.graphic.components.navigation.NavigationStack;
	import fr.swapp.touch.emulator.MouseToTouchEmulator;
	/**
	 * @author ZoulouX
	 */
	public class StyleTest extends Document
	{
		protected var _wrapper:StageWrapper;
		protected var _container:ResizableComponent;
		
		public function StyleTest()
		{
		
		}
		
		override public function init ():void
		{
			MouseToTouchEmulator.auto(stage);
			
			stage.quality = StageQuality.LOW;
			
			_wrapper = new StageWrapper(stage);
			
			_wrapper.styleCentral.styleData = {
				"NavigationStack.navigationStyle .borderStyle" : {
					backgroundImage: {
						background: [0x00FF00, 1]
					}
				}
			};
			
			_container = (new ResizableComponent()).place(0, 0, 0, 0).into(_wrapper);
			
			//_container.style("");
			
			var bootstrap:Bootstrap = new Bootstrap();
			
			var navigation:NavigationStack = new NavigationStack(bootstrap, null, -1, true, false);
			
			
			navigation.place(0, 0, 0, 0).into(_container);
			
			var border:BorderComponent = new BorderComponent(0xFF0000, 1);
			
			
			border.place(10, 10, 10, 10).into(navigation.actionStack.currentContainer);
			
			navigation.style("navigationStyle");
			navigation.titleBar.style("titleBarStyle");
			border.style("borderStyle");
			
			//trace(_wrapper.styleCentral.getStyleSignature(border));
			//trace(_wrapper.styleCentral.getStyleSignature(navigation.titleBar));
		}
	}
}