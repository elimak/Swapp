package fr.swapp.utils 
{
	import flash.display.Stage;
	import flash.system.Capabilities;
	
	/**
	 * Classe utilitaire permettant de récupérer des informations sur l'environnement d'exécution.
	 * @author ZoulouX, Pascal
	 */
	public class EnvUtils
	{
		/**
		 * Inches size to determinate if phone or tablet (only for android).
		 * This parameter can be changed.
		 */
		public static var TABLET_SIZE_DELIMITATION		:Number				= 6.5;
		
		/**
		 * Unknow platform / device
		 */
		public static const UNKNOW						:String				= "unknow";
		
		/**
		 * All possibles platforms
		 */
		public static const WIN_PLATFORM				:String				= "winPlatform";
		public static const MAC_PLATFORM				:String				= "macPlatform";
		public static const LINUX_PLATFORM				:String				= "linuxPlatform";
		public static const IOS_PLATFORM				:String				= "iosPlatform";
		public static const ANDROID_PLATFORM			:String				= "androidPlatform";
		
		/**
		 * All possibles devices
		 */
		public static const PHONE						:String				= "phoneDevice";
		public static const TABLET						:String				= "tabletDevice";
		public static const DESKTOP						:String				= "desktopDevice";
		
		/**
		 * Bases DPIs (only for desktop and iOS).
		 * iPad mini is excluded from DPI resizing (it will use iPad 1,2 definition)
		 */
		public static const DESKTOP_DPI					:uint				= 72;
		public static const IPAD_CLASSIC_DPI			:uint				= 132;
		public static const IPAD_RETINA_DPI				:uint				= 264;
		public static const IPHONE_CLASSIC_DPI			:uint				= 163;
		public static const IPHONE_RETINA_DPI			:uint				= 326;
		
		/**
		 * iPhone IDs (for detection)
		 */
		public static const IPHONE_1_DEVICE				:String				= "iPhone1,1";
		public static const IPHONE_3G_DEVICE			:String				= "iPhone1,2";
		public static const IPHONE_3GS_DEVICE			:String				= "iPhone2,1";
		public static const IPHONE_4_DEVICE				:String				= "iPhone3,";
		public static const IPHONE_4S_DEVICE			:String				= "iPhone4,1";
		public static const IPHONE_5_DEVICE				:String				= "iPhone5,";
		
		/**
		 * iPod IDs (for detection)
		 */
		public static const IPOD_TOUCH_1_DEVICE			:String				= "iPod1,";
		public static const IPOD_TOUCH_2_DEVICE			:String				= "iPod2,";
		public static const IPOD_TOUCH_3_DEVICE			:String				= "iPod3,";
		public static const IPOD_TOUCH_4_DEVICE			:String				= "iPod4,";
		public static const IPOD_TOUCH_5_DEVICE			:String				= "iPod5,";
		
		/**
		 * iPad IDs (for detection)
		 * iPad mini is excluded from DPI resizing (it will use iPad definition)
		 */
		public static const IPAD_1_DEVICE				:String				= "iPad1,1";
		public static const IPAD_2_DEVICE				:String				= "iPad2,";
		public static const IPAD_3_DEVICE				:String				= "iPad3,1|iPad3,2|iPad3,3";
		public static const IPAD_4_DEVICE				:String				= "iPad3,4|iPad3,5|iPad3,6";
		
		/**
		 * Player runtime type
		 */
		public static const FLASH_RUNTIME				:String				= "flashPlayer";
		public static const AIR_RUNTIME					:String				= "airRuntime";
		
		
		/**
		 * Platform name from Capabilities.version
		 */
		protected static var _platform					:String;
		
		/**
		 * Non computed version (full string)
		 */
		protected static var _version					:String;
		
		/**
		 * Version computed parts from _version
		 */
		protected static var _majorVersion				:uint;
		protected static var _minorVersion				:uint;
		protected static var _buildNumber				:uint;
		protected static var _internalBuildNumber		:uint;
		
		
		/**
		 * Pre-compute all informations about environment to ease access.
		 */
		protected static function precomputeInformations ():void
		{
			// Si la plateforme n'a pas déjà été définie
			if (__platform == null)
			{
				// Récupérer les informations de la version
				var result:Object = /^(\w*) (\d*),(\d*),(\d*),(\d*)$/.exec(Capabilities.version);
				
				// Si on a des résultats
				if (result != null)
				{
					// On enregistre les valeurs
					__version 				= result.input;
					__platform 				= result[1];
					__majorVersion 			= result[2];
					__minorVersion 			= result[3];
					__buildNumber 			= result[4];
					__internalBuildNumber 	= result[5];
				}
			}
		}
		
		/**
		 * Get text format based informations from Capabilities API
		 */
		public static function getTextInformations ():String
		{
			return <text>
				Capabilities.version : {Capabilities.version}
				Capabilities.screenDPI : {Capabilities.screenDPI}
				Capabilities.isDebugger : {Capabilities.isDebugger}
				Capabilities.manufacturer : {Capabilities.manufacturer}
				Capabilities.os : {Capabilities.os}
				Capabilities.pixelAspectRatio : {Capabilities.pixelAspectRatio}
				Capabilities.playerType : {Capabilities.playerType}
				Capabilities.screenResolutionX : {Capabilities.screenResolutionX}
				Capabilities.screenResolutionY : {Capabilities.screenResolutionY}
				Capabilities.touchscreenType : {Capabilities.touchscreenType}
			</text>.toString().replace(/(\t|\r)/g, "");
		}
		
		
		
		/**
		 * ----------------------------------------------
		 * 					DEVICE TYPE
		 * ----------------------------------------------
		 */
		
		/**
		 * If a platform is as a desktop platform
		 */
		protected static function isDesktop (pPlatform:String):Boolean
		{
			return (pPlatform == MAC_PLATFORM || pPlatform == WIN_PLATFORM || pPlatform == LINUX_PLATFORM) && Capabilities.screenDPI <= 72;
		}
		
		/**
		 * Get the device type (see statics)
		 */
		public static function getDeviceType (pAllowDesktop:Boolean = true):String
		{
			// On est sur un device ?
			var platform:String = getPlatformType();
			
			// Si on autorise à retourner un type desktop
			if (pAllowDesktop)
			{
				// On est sur un ordi si on est sur Mac / Pc / Linux et si on a un DPI de 72
				if (isDesktop(platform))
				{
					return DESKTOP;
				}
			}
			
			// Si on est sur iOS
			if (platform == IOS_PLATFORM)
			{
				// Si on est sur le DPI d'un téléphone
				if (Capabilities.screenDPI == IPHONE_RETINA_DPI || Capabilities.screenDPI == IPHONE_CLASSIC_DPI)
				{
					return PHONE;
				}
				
				// Ou sur le DPI d'une tablette
				else if (Capabilities.screenDPI == IPAD_RETINA_DPI || Capabilities.screenDPI == IPAD_CLASSIC_DPI)
				{
					return TABLET
				}
			}
			
			// Si on est sur Android
			else if (platform == ANDROID_PLATFORM)
			{
				// On regarde la taille supposée de l'écran
				return (getScreenSize() >= TABLET_SIZE_DELIMITATION ? TABLET : PHONE);
			}
			
			// Si on n'autorise pas les return computer
			else if (!pAllowDesktop)
			{
				// 
				if (getScreenSize() >= TABLET_SIZE_DELIMITATION)
				{
					return TABLET;
				}
				else
				{
					return PHONE;
				}
				
			}
			
			// Si on est arrivé jusque ici c'est qu'on ne sait pas
			return UNKNOW;
		}
		
		/**
		 * Check a device type (see statics)
		 */
		public static function isDeviceType (pDeviceType:String, pAllowDesktop:Boolean = true):Boolean
		{
			return getDeviceType(pAllowDesktop) == pDeviceType;
		}
		
		
		
		/**
		 * ----------------------------------------------
		 * 				   PLATFORM TYPE
		 * ----------------------------------------------
		 */
		
		/**
		 * Get the platform type (see statics)
		 */
		public static function getPlatformType ():String
		{
			// Passer le nom de la plateforme en minuscules
			var lowPlatform:String = _platform.toLowerCase();
			
			// Le tableau des correspondances des plateformes
			var correspondingPlatforms:Object = {
				"win": WIN_PLATFORM,
				"mac": MAC_PLATFORM,
				"lnx": LINUX_PLATFORM,
				"and": ANDROID_PLATFORM,
				"ios": IOS_PLATFORM
			};
			
			// Retourner si trouvé
			return (lowPlatform in correspondingPlatforms ? correspondingPlatforms[lowPlatform] : UNKNOW);
		}
		
		/**
		 * Check a platform type (see statics)
		 */
		public static function isPlatformType (pPlatformType:String):Boolean
		{
			return getPlatformType() == pPlatformType;
		}
		
		
		
		/**
		 * ----------------------------------------------
		 * 				   RUNTIME TYPE
		 * ----------------------------------------------
		 */
		
		/**
		 * Get the player type (see statics)
		 */
		public static function getRuntime ():String
		{
			return Capabilities.playerType == "Desktop" ? AIR_RUNTIME : FLASH_RUNTIME;
		}
		
		/**
		 * Check a player type (see statics)
		 */
		public static function isRuntime (pPlayerType:String):Boolean
		{
			return getRuntime() == pPlayerType;
		}
		
		
		
		/**
		 * ----------------------------------------------
		 * 				RUNTIME INFORMATION
		 * ----------------------------------------------
		 */
		
		/**
		 * If the runtime is in debug mode
		 */
		public static function isDebug ():Boolean
		{
			return Capabilities.isDebugger;
		}
		
		/**
		 * Get the player version
		 */
		public static function getPlayerVersion ():Vector.<uint>
		{
			// Récupérer les infos si ce n'est pas déjà fait
			precomputeInformations();
			
			// Retourner les numéros de version dans l'ordre
			return new <uint>[__majorVersion, __minorVersion, __buildNumber, __internalBuildNumber];
		}
		
		/**
		 * If the applicatoin runs inside the Standalone Flash Player
		 */
		public static function isStandalone ():Boolean
		{
			return (Capabilities.playerType == "StandAlone");
		}
		
		/**
		 * If the applicatoin runs inside the IDE Flash Player
		 */
		public static function isInIDE ():Boolean
		{
			return Capabilities.playerType == "External";
		}
		
		/**
		 * If the application runs into the browser
		 */
		public static function isInBrowser ():Boolean
		{
			return Capabilities.playerType == "PlugIn" || Capabilities.playerType == "ActiveX";
		}
		
		/**
		 * If the application runs inside Air Runtime
		 */
		public static function isAIRApplication ():Boolean
		{
			return Capabilities.playerType == "Desktop";
		}
		
		/**
		 * Récupérer la version de la plateforme
		 */
		public static function getOSVersion ():String
		{
			return Capabilities.os;
		}
		
		
		
		/**
		 * ----------------------------------------------
		 * 				      DEVICE TYPE
		 * ----------------------------------------------
		 */
		
		/**
		 * Récupérer le nom du device iOS
		 */
		protected static function getIOSDeviceVersion ():String
		{
			return Capabilities.os.substr(Capabilities.os.lastIndexOf(" ") + 1, Capabilities.os.length - 1);
		}
		
		/**
		 * Get the specific iOS device model
		 */
		public static function getiOSDevice ():String
		{
			throw new SwappUtilsError("EnvUtils.getiOSDevice", "Not implemented yet");
			return "";
		}
		
		/**
		 * Si c'est un device spécifique
		 */
		public static function isIOSDevice (pDevice:String):Boolean
		{
			throw new SwappUtilsError("EnvUtils.isIOSDevice", "Not implemented yet");
			return getiOSDevice().indexOf(pDevice) != -1;
		}
		
		/**
		 * Récupérer la version du device
		 */
		public static function getIOSDeviceVersion ():String
		{
			return Capabilities.os.substr(Capabilities.os.lastIndexOf(" ") + 1, Capabilities.os.length - 1);
		}
		
		
		
		/**
		 * ----------------------------------------------
		 * 				 SCREEN INFORMATIONS
		 * ----------------------------------------------
		 */
		
		/**
		 * Get approx screen size (inches)
		 */
		public static function getScreenSize (pAllowDesktopScreenSize:Boolean = false, pStage:Stage = null):Number
		{
			// Si on est sur PC
			var checkDesktop:Boolean = (!pAllowDesktopScreenSize && isDesktop(getPlatformType()) && pStage != null)
			
			const screenWidth	:Number = (checkDesktop ? pStage.stageWidth / 100 : Capabilities.screenResolutionX / Capabilities.screenDPI);
			const screenHeight	:Number = (checkDesktop ? pStage.stageHeight / 100 : Capabilities.screenResolutionY / Capabilities.screenDPI);
			
			return Math.sqrt(screenWidth * screenWidth + screenHeight * screenHeight);
		}
		
		/**
		 * Get ratio for stage
		 */
		public static function getRatioForStage ():Number
		{
			// Récupérer le type de device
			var deviceType:String = getDeviceType(true);
			
			// Si on est sur PC / MAC
			if (deviceType == DESKTOP)
			{
				return Capabilities.screenDPI / DESKTOP_DPI;
			}
			
			// Si on est sur téléphone
			else if (deviceType == PHONE)
			{
				return Capabilities.screenDPI / IPHONE_CLASSIC_DPI;
			}
			
			// Si on est sur tablette
			else if (deviceType == TABLET)
			{
				return Capabilities.screenDPI / IPAD_CLASSIC_DPI;
			}
			
			// Sinon
			else
			{
				return 1;
			}
		}
	}
}