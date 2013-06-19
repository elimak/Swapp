package fr.swapptesting.utils
{
	import flash.display.Sprite;
	import flash.events.Event;
	import fr.swapp.core.log.Log;
	import fr.swapp.core.log.TraceLogger;
	import fr.swapp.utils.EnvUtils;
	import fr.swapp.utils.StageUtils;
	
	/**
	 * @author ZoulouX
	 */
	public class EnvUtilsTest extends Sprite
	{
		/**
		 * Constructor
		 */
		public function EnvUtilsTest ()
		{
			// Check and wait for stage availability
			(stage != null ? construct() : addEventListener(Event.ADDED_TO_STAGE, construct));
		}
		
		
		/**
		 * Second constructeur
		 */
		protected function construct (event:Event = null):void
		{
			// Initialiser le logger trace
			Log.addLogger(new TraceLogger);
			
			// Définir le stage
			StageUtils.mainStage = stage;
			
			// Test device Type
			Log.notice("Is EnvUtils.DESKTOP_DEVICE", EnvUtils.like(EnvUtils.DESKTOP_DEVICE));
			Log.notice("Is EnvUtils.MOBILE_DEVICE", EnvUtils.like(EnvUtils.MOBILE_DEVICE));
			Log.notice(" ");
			
			// Test device Size
			Log.notice("Is EnvUtils.PHONE_SIZE", EnvUtils.like(EnvUtils.PHONE_SIZE));
			Log.notice("Is EnvUtils.TABLET_SIZE", EnvUtils.like(EnvUtils.TABLET_SIZE));
			Log.notice("Is EnvUtils.DESKTOP_SIZE", EnvUtils.like(EnvUtils.DESKTOP_SIZE));
			Log.notice(" ");
			
			// Test iOS / Android platform
			Log.notice("Is EnvUtils.IOS_PLATFORM", EnvUtils.like(EnvUtils.IOS_PLATFORM));
			Log.notice("Is EnvUtils.ANDROID_PLATFORM", EnvUtils.like(EnvUtils.ANDROID_PLATFORM));
			Log.notice(" ");
			
			// Test runtime
			Log.notice("Is EnvUtils.AIR_RUNTIME", EnvUtils.like(EnvUtils.AIR_RUNTIME));
			Log.notice("Is EnvUtils.FLASH_RUNTIME", EnvUtils.like(EnvUtils.FLASH_RUNTIME));
			Log.notice(" ");
			
			// Test ratio for stage
			Log.notice("Ratio for stage", EnvUtils.getRatioForMainStage());
			Log.notice(" ");
			
			// Test iPhone device
			Log.notice("Is EnvUtils.IPHONE_1_DEVICE", EnvUtils.like(EnvUtils.IPHONE_1_DEVICE));
			Log.notice("Is EnvUtils.IPHONE_3G_DEVICE", EnvUtils.like(EnvUtils.IPHONE_3G_DEVICE));
			Log.notice("Is EnvUtils.IPHONE_3GS_DEVICE", EnvUtils.like(EnvUtils.IPHONE_3GS_DEVICE));
			Log.notice("Is EnvUtils.IPHONE_4_DEVICE", EnvUtils.like(EnvUtils.IPHONE_4_DEVICE));
			Log.notice("Is EnvUtils.IPHONE_4S_DEVICE", EnvUtils.like(EnvUtils.IPHONE_4S_DEVICE));
			Log.notice("Is EnvUtils.IPHONE_5_DEVICE", EnvUtils.like(EnvUtils.IPHONE_5_DEVICE));
			Log.notice(" ");
			
			// Test iPad device
			Log.notice("Is EnvUtils.IPAD_1_DEVICE", EnvUtils.like(EnvUtils.IPAD_1_DEVICE));
			Log.notice("Is EnvUtils.IPAD_2_DEVICE", EnvUtils.like(EnvUtils.IPAD_2_DEVICE));
			Log.notice("Is EnvUtils.IPAD_3_DEVICE", EnvUtils.like(EnvUtils.IPAD_3_DEVICE));
			Log.notice("Is EnvUtils.IPAD_4_DEVICE", EnvUtils.like(EnvUtils.IPAD_4_DEVICE));
			Log.notice(" ");
			
			// Text informations
			Log.notice(EnvUtils.getTextInformations());
		}
		
		/**
			RESULTS
			
			
			
			Air / PC Windows 7
			------------------------------------------------
			
			Is EnvUtils.DESKTOP_DEVICE, true
			Is EnvUtils.MOBILE_DEVICE, false
			
			Is EnvUtils.PHONE_SIZE, false
			Is EnvUtils.TABLET_SIZE, true
			Is EnvUtils.DESKTOP_SIZE, false
			
			Is EnvUtils.IOS_PLATFORM, false
			Is EnvUtils.ANDROID_PLATFORM, false
			
			Is EnvUtils.AIR_RUNTIME, true
			Is EnvUtils.FLASH_RUNTIME, false
			
			Ratio for stage, 1
			
			Is EnvUtils.IPHONE_1_DEVICE, false
			Is EnvUtils.IPHONE_3G_DEVICE, false
			Is EnvUtils.IPHONE_3GS_DEVICE, false
			Is EnvUtils.IPHONE_4_DEVICE, false
			Is EnvUtils.IPHONE_4S_DEVICE, false
			Is EnvUtils.IPHONE_5_DEVICE, false
			
			Is EnvUtils.IPAD_1_DEVICE, false
			Is EnvUtils.IPAD_2_DEVICE, false
			Is EnvUtils.IPAD_3_DEVICE, false
			Is EnvUtils.IPAD_4_DEVICE, false
			
			Capabilities.version : WIN 11,7,700,202
			Capabilities.screenDPI : 72
			Capabilities.isDebugger : true
			Capabilities.manufacturer : Adobe Windows
			Capabilities.os : Windows 7
			Capabilities.pixelAspectRatio : 1
			Capabilities.playerType : Desktop
			Capabilities.screenResolutionX : 1920
			Capabilities.screenResolutionY : 1080
			Capabilities.touchscreenType : finger
			
			
			Air / iPad 3
			------------------------------------------------
			Is EnvUtils.DESKTOP_DEVICE, false
			Is EnvUtils.MOBILE_DEVICE, true
			
			Is EnvUtils.PHONE_SIZE, false
			Is EnvUtils.TABLET_SIZE, true
			Is EnvUtils.DESKTOP_SIZE, false
			
			Is EnvUtils.IOS_PLATFORM, true
			Is EnvUtils.ANDROID_PLATFORM, false
			
			Is EnvUtils.AIR_RUNTIME, true
			Is EnvUtils.FLASH_RUNTIME, false
			
			Ratio for stage, 2
			
			Is EnvUtils.IPHONE_1_DEVICE, false
			Is EnvUtils.IPHONE_3G_DEVICE, false
			Is EnvUtils.IPHONE_3GS_DEVICE, false
			Is EnvUtils.IPHONE_4_DEVICE, false
			Is EnvUtils.IPHONE_4S_DEVICE, false
			Is EnvUtils.IPHONE_5_DEVICE, false
			
			Is EnvUtils.IPAD_1_DEVICE, false
			Is EnvUtils.IPAD_2_DEVICE, false
			Is EnvUtils.IPAD_3_DEVICE, true
			Is EnvUtils.IPAD_4_DEVICE, false
			
			Capabilities.version : IOS 11,7,700,202
			Capabilities.screenDPI : 264
			Capabilities.isDebugger : true
			Capabilities.manufacturer : Adobe iOS
			Capabilities.os : iPhone OS 6.0.1 iPad3,3
			Capabilities.pixelAspectRatio : 1
			Capabilities.playerType : Desktop
			Capabilities.screenResolutionX : 1536
			Capabilities.screenResolutionY : 2048
			Capabilities.touchscreenType : finger
			
			
			Air / iPhone 4s
			------------------------------------------------
			Is EnvUtils.DESKTOP_DEVICE, false
			Is EnvUtils.MOBILE_DEVICE, true
			
			Is EnvUtils.PHONE_SIZE, true
			Is EnvUtils.TABLET_SIZE, false
			Is EnvUtils.DESKTOP_SIZE, false
			
			Is EnvUtils.IOS_PLATFORM, true
			Is EnvUtils.ANDROID_PLATFORM, false
			
			Is EnvUtils.AIR_RUNTIME, true
			Is EnvUtils.FLASH_RUNTIME, false
			
			Ratio for stage, 2
			
			Is EnvUtils.IPHONE_1_DEVICE, false
			Is EnvUtils.IPHONE_3G_DEVICE, false
			Is EnvUtils.IPHONE_3GS_DEVICE, false
			Is EnvUtils.IPHONE_4_DEVICE, false
			Is EnvUtils.IPHONE_4S_DEVICE, true
			Is EnvUtils.IPHONE_5_DEVICE, false
			
			Is EnvUtils.IPAD_1_DEVICE, false
			Is EnvUtils.IPAD_2_DEVICE, false
			Is EnvUtils.IPAD_3_DEVICE, false
			Is EnvUtils.IPAD_4_DEVICE, false
			
			Capabilities.version : IOS 11,7,700,202
			Capabilities.screenDPI : 326
			Capabilities.isDebugger : true
			Capabilities.manufacturer : Adobe iOS
			Capabilities.os : iPhone OS 6.1.3 iPhone4,1
			Capabilities.pixelAspectRatio : 1
			Capabilities.playerType : Desktop
			Capabilities.screenResolutionX : 640
			Capabilities.screenResolutionY : 960
			Capabilities.touchscreenType : finger
			
			
			Air / Nexus 4
			------------------------------------------------
			Is EnvUtils.DESKTOP_DEVICE, false
			Is EnvUtils.MOBILE_DEVICE, true
			
			Is EnvUtils.PHONE_SIZE, true
			Is EnvUtils.TABLET_SIZE, false
			Is EnvUtils.DESKTOP_SIZE, false
			
			Is EnvUtils.IOS_PLATFORM, false
			Is EnvUtils.ANDROID_PLATFORM, true
			
			Is EnvUtils.AIR_RUNTIME, true
			Is EnvUtils.FLASH_RUNTIME, false
			
			Ratio for stage, 1.9631901840490797
			
			Is EnvUtils.IPHONE_1_DEVICE, false
			Is EnvUtils.IPHONE_3G_DEVICE, false
			Is EnvUtils.IPHONE_3GS_DEVICE, false
			Is EnvUtils.IPHONE_4_DEVICE, false
			Is EnvUtils.IPHONE_4S_DEVICE, false
			Is EnvUtils.IPHONE_5_DEVICE, false
			
			Is EnvUtils.IPAD_1_DEVICE, false
			Is EnvUtils.IPAD_2_DEVICE, false
			Is EnvUtils.IPAD_3_DEVICE, false
			Is EnvUtils.IPAD_4_DEVICE, false
			
			Capabilities.version : AND 11,7,700,202
			Capabilities.screenDPI : 320
			Capabilities.isDebugger : true
			Capabilities.manufacturer : Android Linux
			Capabilities.os : Linux 3.4.0-perf-g7ce11cd
			Capabilities.pixelAspectRatio : 1
			Capabilities.playerType : Desktop
			Capabilities.screenResolutionX : 768
			Capabilities.screenResolutionY : 1184
			Capabilities.touchscreenType : finger
		 */
	}
}