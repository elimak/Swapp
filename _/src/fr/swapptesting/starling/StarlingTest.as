package fr.swapptesting.starling
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import starling.core.Starling;
	
	/**
	 * @author ZoulouX
	 */
	public class StarlingTest extends Sprite
	{
		protected var _starling:Starling;
		
		public function StarlingTest ()
		{
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
			
			_starling = new Starling(StarlingContext, stage, null, null, "auto", "baseline");
			_starling.start();
		}
	}
}