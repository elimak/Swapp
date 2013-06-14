package fr.swapptesting.env
{
	import flash.display.Sprite;
	import fr.swapp.utils.EnvUtils;
	
	/**
	 * @author ZoulouX
	 */
	public class EnvUtilsTest extends Sprite
	{
		public function EnvUtilsTest ()
		{
			construct();
		}
		
		protected function construct ():void
		{
			// 
			trace(EnvUtils.isDeviceType(EnvUtils.PHONE));
			trace(EnvUtils.isDeviceType(EnvUtils.TABLET));
			trace(EnvUtils.isDeviceType(EnvUtils.DESKTOP));
		}
	}
}