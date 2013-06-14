package fr.swapptesting
{
	import flash.display.Sprite;
	import flash.events.Event;
	import fr.swapptesting.env.EnvUtilsTest;
	
	/**
	 * @author ZoulouX
	 */
	public class Main extends Sprite
	{
		public function Main ()
		{
			if (stage != null)
			{
				construct()
			}
			else
			{
				addEventListener(Event.ADDED_TO_STAGE, construct);
			}
		}
		
		protected function construct (event:Event = null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, construct);
			
			
			addChild(new EnvUtilsTest());
		}
	}
}