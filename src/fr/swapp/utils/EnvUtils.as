package fr.swapp.utils 
{
	import flash.display.Stage;
	import flash.system.Capabilities;
	
	/**
	 * Utils class to get platform / device / environment specific informations.
	 * @author ZoulouX, Pascal
	 */
	public class EnvUtils
	{
		/**
		 * Inches size to determinate if the device is phone, tablet or desktop sized.
		 * These parameters can be changed.
		 */
		public static var tabletSizeDelimitation		:Number				= 6.5;
		public static var desktopSizeDelimitation		:Number				= 13;
		
		
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
		 * Unknow platform / device
		 */
		public static const UNKNOW						:String				= "unknow";
		
		/**
		 * All possibles platforms.
		 * Available for "like" API.
		 */
		public static const WIN_PLATFORM				:String				= "winPlatform";
		public static const MAC_PLATFORM				:String				= "macPlatform";
		public static const LINUX_PLATFORM				:String				= "linuxPlatform";
		public static const IOS_PLATFORM				:String				= "iosPlatform";
		public static const ANDROID_PLATFORM			:String				= "androidPlatform";
		
		/**
		 * High level devices.
		 * Available for "like" API.
		 */
		public static const DESKTOP_DEVICE				:String				= "desktopDevice";
		public static const MOBILE_DEVICE				:String				= "mobileDevice";
		
		/**
		 * All possibles device sizes.
		 * Available for "like" API.
		 */
		public static const PHONE_SIZE					:String				= "phoneSize";
		public static const TABLET_SIZE					:String				= "tabletSize";
		public static const DESKTOP_SIZE				:String				= "desktopSize";
		
		/**
		 * iPhone IDs.
		 * Available for "like" API.
		 */
		public static const IPHONE_1_DEVICE				:String				= "iPhone1,1";
		public static const IPHONE_3G_DEVICE			:String				= "iPhone1,2";
		public static const IPHONE_3GS_DEVICE			:String				= "iPhone2,1";
		public static const IPHONE_4_DEVICE				:String				= "iPhone3,";
		public static const IPHONE_4S_DEVICE			:String				= "iPhone4,1";
		public static const IPHONE_5_DEVICE				:String				= "iPhone5,";
		
		/**
		 * iPod IDs.
		 * Available for "like" API.
		 */
		public static const IPOD_TOUCH_1_DEVICE			:String				= "iPod1,";
		public static const IPOD_TOUCH_2_DEVICE			:String				= "iPod2,";
		public static const IPOD_TOUCH_3_DEVICE			:String				= "iPod3,";
		public static const IPOD_TOUCH_4_DEVICE			:String				= "iPod4,";
		public static const IPOD_TOUCH_5_DEVICE			:String				= "iPod5,";
		
		/**
		 * iPad IDs.
		 * iPad mini is excluded from DPI resizing (it will use iPad definition).
		 * Available for "like" API.
		 */
		public static const IPAD_1_DEVICE				:String				= "iPad1,1";
		public static const IPAD_2_DEVICE				:String				= "iPad2,";
		public static const IPAD_3_DEVICE				:String				= "iPad3,1|iPad3,2|iPad3,3";
		public static const IPAD_4_DEVICE				:String				= "iPad3,4|iPad3,5|iPad3,6";
		
		/**
		 * Player runtime type.
		 * Available for "like" API.
		 */
		public static const FLASH_RUNTIME				:String				= "flashRuntime";
		public static const AIR_RUNTIME					:String				= "airRuntime";
		
		
		/**
		 * Platform name from Capabilities.version
		 */
		protected static var __platform					:String;
		
		/**
		 * Non computed version (full string)
		 */
		protected static var __version					:String;
		
		/**
		 * Version computed parts from _version
		 */
		protected static var __majorVersion				:uint;
		protected static var __minorVersion				:uint;
		protected static var __buildNumber				:uint;
		protected static var __internalBuildNumber		:uint;
		
		
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
		 * Check any "is" like method.
		 * Include : isPlatformType / isDeviceType / isDeviceType / isIOSDevice / isRuntime
		 */
		public static function like (pWhat:String):Boolean
		{
			return isPlatformType(pWhat) || isDeviceSize(pWhat) || isDeviceType(pWhat) || isIOSDevice(pWhat) || isRuntime(pWhat);
		}
		
		
		
		/**
		 * ----------------------------------------------
		 * 					DEVICE TYPE
		 * ----------------------------------------------
		 */
		
		/**
		 * If a platform is as a desktop platform.
		 * Let pPlatform to null to check with the current platform.
		 * Will also check if DPI is 72 to get only Desktop type platforms.
		 */
		public static function isDesktop (pPlatform:String = null):Boolean
		{
			// Si on n'a pas de plateforme de passée
			if (pPlatform == null || pPlatform == "")
			{
				// On récupère la plateforme
				pPlatform = getPlatformType();
			}
			
			// Si on est sur PC / MAC / Linux
			return (pPlatform == MAC_PLATFORM || pPlatform == WIN_PLATFORM || pPlatform == LINUX_PLATFORM) && Capabilities.screenDPI <= 72;
		}
		
		/**
		 * Get the high level device type
		 */
		public static function getDeviceType ():String
		{
			// Retourner si on est sur mobile ou tablette
			return isDesktop() ? DESKTOP_DEVICE : MOBILE_DEVICE;
		}
		
		/**
		 * Check the high level device type (see statics)
		 */
		public static function isDeviceType (pDeviceType:String):Boolean
		{
			return getDeviceType() == pDeviceType;
		}
		
		
		/**
		 * Get the specific iOS device model
		 */
		public static function getIOSDevice ():String
		{
			return Capabilities.os.substr(Capabilities.os.lastIndexOf(" ") + 1, Capabilities.os.length - 1);
		}
		
		/**
		 * Si c'est un device spécifique
		 */
		public static function isIOSDevice (pDevice:String):Boolean
		{
			// Récupérer le device iOS
			var currentDeviceID:String = getIOSDevice();
			
			// Voir si on a déguisé un tableau dans le string de cet id
			if (pDevice.indexOf("|"))
			{
				// On le split
				var deviceIDs:Array = pDevice.split("|");
				
				// Parcourir les IDs
				for (var i:int = 0, total:uint = deviceIDs.length; i < total; i++) 
				{
					// Si ce device ID correspond
					if (currentDeviceID.indexOf(deviceIDs[i]) != -1)
					{
						// On l'a trouvé
						return true;
					}
				}
				
				// On n'a pas trouvé ce device
				return false;
			}
			else
			{
				// Retourner directement si ce device ID est dans la signature
				return currentDeviceID.indexOf(pDevice) != -1;
			}
		}
		
		
		
		/**
		 * ----------------------------------------------
		 * 					DEVICE SIZE
		 * ----------------------------------------------
		 */
		
		/**
		 * Get approx screen size (inches)
		 */
		public static function getScreenSize ():Number
		{
			// On déclanche une erreur si on n'a pas notre stage
			StageUtils.throwErrorIfMainStageNotDefined("EnvUtils.getScreenSize");
			
			// Si on est sur un environnement desktop
			var checkDesktop:Boolean = isDesktop();
			
			// Récupérer la largeur et la hauteur réelle (pas en pixels mais bien en pouces)
			const screenWidth	:Number = (checkDesktop ? StageUtils.mainStage.stageWidth / 100 : Capabilities.screenResolutionX / Capabilities.screenDPI);
			const screenHeight	:Number = (checkDesktop ? StageUtils.mainStage.stageHeight / 100 : Capabilities.screenResolutionY / Capabilities.screenDPI);
			
			// Retourner la 
			return Math.sqrt(screenWidth * screenWidth + screenHeight * screenHeight);
		}
		
		/**
		 * Get ratio for main stage
		 */
		public static function getRatioForMainStage ():Number
		{
			// Récupérer le type de device
			var deviceSize:String = getDeviceSize();
			
			// Si on est sur un environnement desktop
			// Ne pas regarder deviceSize == DESKTOP_SIZE car ça peut être android
			if (isDesktop())
			{
				// On calcul par rapport au DPI de base du Desktop
				return Capabilities.screenDPI / DESKTOP_DPI;
			}
			
			// Si on est sur téléphone
			else if (deviceSize == PHONE_SIZE)
			{
				// On calcul par rapport au DPI de base de l'iPhone
				return Capabilities.screenDPI / IPHONE_CLASSIC_DPI;
			}
			
			// Si on est sur tablette
			else if (deviceSize == TABLET_SIZE)
			{
				// On calcul par rapport au DPI de base de l'iPad
				return Capabilities.screenDPI / IPAD_CLASSIC_DPI;
			}
			
			// Sinon on met un ratio de 1
			else
			{
				return 1;
			}
		}
		
		/**
		 * Get the device type (see statics)
		 * Phone, tablet or desktop size
		 */
		public static function getDeviceSize ():String
		{
			// Récupérer la platforme
			var platform:String = getPlatformType();
			
			// Récupérer la taille de l'écran
			var screenSize:Number = getScreenSize();
			
			// Si on est sur iOS
			if (platform == IOS_PLATFORM)
			{
				// Si on est sur le DPI d'un téléphone
				if (Capabilities.screenDPI == IPHONE_RETINA_DPI || Capabilities.screenDPI == IPHONE_CLASSIC_DPI)
				{
					return PHONE_SIZE;
				}
				
				// Ou sur le DPI d'une tablette
				else if (Capabilities.screenDPI == IPAD_RETINA_DPI || Capabilities.screenDPI == IPAD_CLASSIC_DPI)
				{
					return TABLET_SIZE;
				}
			}
			
			// Si on est sur Android
			else if (platform == ANDROID_PLATFORM)
			{
				// Si c'est une taille de desktop
				if (screenSize >= desktopSizeDelimitation)
				{
					return DESKTOP_SIZE;
				}
				
				// Si c'est une taille de tablette
				else if (screenSize >= tabletSizeDelimitation)
				{
					return TABLET_SIZE;
				}
				
				// Si c'est une taille de téléphone
				else
				{
					return PHONE_SIZE;
				}
			}
			
			// Sinon, si on est sur desktop
			else if (isDesktop(platform))
			{
				// Si c'est une taille de desktop
				if (getScreenSize() >= desktopSizeDelimitation)
				{
					return DESKTOP_SIZE;
				}
				
				// Si c'est une taille de tablette
				else if (getScreenSize() >= tabletSizeDelimitation)
				{
					return TABLET_SIZE;
				}
				
				// Si c'est une taille de téléphone
				else
				{
					return PHONE_SIZE;
				}
			}
			
			// Si on est arrivé jusque ici c'est qu'on ne sait pas
			return UNKNOW;
		}
		
		/**
		 * Check a device size (see statics)
		 */
		public static function isDeviceSize (pDeviceSize:String):Boolean
		{
			return getDeviceSize() == pDeviceSize;
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
			// Récupérer les infos si ce n'est pas déjà fait
			precomputeInformations();
			
			// Passer le nom de la plateforme en minuscules
			var lowPlatform:String = __platform.toLowerCase();
			
			// Le tableau des correspondances des plateformes
			var correspondingPlatforms:Object = {
				"win" : WIN_PLATFORM,
				"mac" : MAC_PLATFORM,
				"lnx" : LINUX_PLATFORM,
				"and" : ANDROID_PLATFORM,
				"ios" : IOS_PLATFORM
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
		 * If the app is runing on a specified runtime (see statics).
		 * Just Flash or Air
		 */
		public static function isRuntime (pRuntime:String):Boolean
		{
			return getRuntime() == pRuntime;
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
		public static function isStandaloneRuntime ():Boolean
		{
			return (Capabilities.playerType == "StandAlone");
		}
		
		/**
		 * If the applicatoin runs inside the IDE Flash Player
		 */
		public static function isIDERuntime ():Boolean
		{
			return Capabilities.playerType == "External";
		}
		
		/**
		 * If the application runs into the browser
		 */
		public static function isBrowserRuntime ():Boolean
		{
			return Capabilities.playerType == "PlugIn" || Capabilities.playerType == "ActiveX";
		}
		
		/**
		 * Récupérer la version de la plateforme
		 */
		public static function getOSVersion ():String
		{
			return Capabilities.os;
		}
	}
}