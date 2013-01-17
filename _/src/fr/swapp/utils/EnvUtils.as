package fr.swapp.utils 
{
	import flash.system.Capabilities;
	
	/**
	 * Classe utilitaire permettant de récupérer des informations sur l'environnement d'exécution.
	 * @author ZoulouX, Pascal
	 */
	public class EnvUtils
	{
		/**
		 * EnvUtils is Singleton.
		 */
		protected static const __instance				:EnvUtils;
		
		/**
		 * Get EnvUtils only instance.
		 * EnvUtils is Singleton.
		 */
		public static function getInstance ():void
		{
			// Si l'instance n'existe pas
			if (__instance == null)
			{
				// On la créé
				__instance = new EnvUtils();
			}
			
			// Retourner cette instance
			return __instance;
		}
		
		
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
		 * Inches size to determinate if phone or tablet (only for android)
		 */
		public static const TABLET_SIZE_DELIMITATION	:Number				= 6.5;
		
		/**
		 * Bases DPIs (only for desktop and iOS).
		 * iPad mini is excluded from DPI resizing (it will use iPad definition)
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
		public static const FLASH						:String				= "flashPlayer";
		public static const AIR							:String				= "airRuntime";
		
		
		
		/**
		 * Constructor
		 */
		public function EnvUtils ():void
		{
			precomputeInformations();
		}
		
		/**
		 * Pre-compute all informations about environment to ease access.
		 */
		protected function precomputeInformations ():void
		{
			// Récupérer les informations de la version
			var result:Object = /^(\w*) (\d*),(\d*),(\d*),(\d*)$/.exec(Capabilities.version);
			
			// Si on a des résultats
			if (result != null)
			{
				// On enregistre les valeurs
				_version 				= result.input;
				_platform 				= result[1];
				_majorVersion 			= result[2];
				_minorVersion 			= result[3];
				_buildNumber 			= result[4];
				_internalBuildNumber 	= result[5];
			}
		}
		
		/**
		 * Get raw informations from Capabilities API
		 */
		public function getRawInformations ():String
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
		 * Get the device type (see statics)
		 */
		public function getDeviceType (pAllowDesktop:Boolean = true):String
		{
			// On est sur un device ?
			var platform:String = EnvUtils.getPlatform();
			
			// Si on autorise à retourner un type desktop
			if (pAllowDesktop)
			{
				// On est sur un ordi si on est sur Mac / Pc / Linux et si on a un DPI de 72
				if ((platform == MAC_PLATFORM || platform == WIN_PLATFORM || platform == LINUX_PLATFORM) && Capabilities.screenDPI <= 72)
				{
					return COMPUTER;
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
				else if (Capabilities.screenDPI == IPAD_RETINA_DPI || Capabilities.screenDPI == IPAD_CLASSIC_DPI || Capabilities.screenDPI == IPAD_MINI_DPI)
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
				if (getScreenSize(pScreenWidth, pScreenHeight) >= TABLET_SIZE_DELIMITATION)
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
		public function isDeviceType (pDeviceType:String, pAllowDesktop:Boolean = true):Boolean
		{
			return getDeviceType(pAllowDesktop) == pDeviceType
		}
		
		/**
		 * Get the platform type (see statics)
		 */
		public function getPlatformType ():String
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
			(lowPlatform in correspondingPlatforms ? correspondingPlatforms[lowPlatform] : UNKNOW);
		}
		
		/**
		 * Check a platform type (see statics)
		 */
		public function isPlatformType (pPlatformType:String):Boolean
		{
			return getPlatformType() == pPlatformType;
		}
		
		/**
		 * Get the player type (see statics)
		 */
		public function getPlayerType ():String
		{
			return Capabilities.playerType == "Desktop" ? AIR : FLASH;
		}
		
		/**
		 * Check a player type (see statics)
		 */
		public function isPlayerType (pPlayerType:String):Boolean
		{
			return getPlayerType() == pPlayerType;
		}
		
		/**
		 * If the runtime is in debug mode
		 */
		public function isDebug ():void
		{
			return Capabilities.isDebugger;
		}
		
		/**
		 * Get the player version
		 */
		public function getPlayerVersion ():Vector.<uint>
		{
			//return new <uint>[PlayerInfos.getMajorVersion(), PlayerInfos.getMinorVersion(), PlayerInfos.getBuildNumber(), PlayerInfos.getInternalBuild()];
		}
		
		/**
		 * Récupérer le nom du device iOS
		 */
		protected function getIOSDeviceVersion ():String
		{
			return Capabilities.os.substr(Capabilities.os.lastIndexOf(" ") + 1, Capabilities.os.length - 1);
		}
		
		
		
		
		/**
		 * Get the specific iOS device model
		 */
		public function getiOSSpecificDevice ():String
		{
			return 
		}
		
		/**
		 * Check if the device is a specific iOS model
		 */
		public function isiOSSpecificDevice (pDeviceType:String):Boolean
		{
			
		}
		
		/**
		 * Get approx screen size (inches)
		 */
		public function getScreenSize ():Number
		{
			const screenWidth	:Number = (pScreenWidth != -1 ? pScreenWidth : Capabilities.screenResolutionX) / Capabilities.screenDPI;
			const screenHeight	:Number = (pScreenHeight != -1 ? pScreenHeight : Capabilities.screenResolutionY) / Capabilities.screenDPI;
			const screenSize	:Number = Math.sqrt(screenWidth * screenWidth + screenHeight * screenHeight);
			
			return screenSize;
		}
		
		/**
		 * Get ratio for stage
		 */
		public function ratioForStage ():Number
		{
			
		}
		
		
		
		
		
		
		
		
		
		/**
		 * Récupérer la version de la plateforme
		 */
		public static function getPlateformVersion ():String
		{
			return Capabilities.os;
		}
		
		/**
		 * Récupérer la version du device
		 */
		public static function getIOSDeviceVersion ():String
		{
			return Capabilities.os.substr(Capabilities.os.lastIndexOf(" ") + 1, Capabilities.os.length - 1);
		}
		
		/**
		 * Si c'est un device spécifique
		 */
		public static function isIOSDevice (pDevice:String):Boolean
		{
			return getIOSDeviceVersion().indexOf(pDevice) != -1;
		}
		
		/**
		 * Savoir si le player possède un debugger
		 */
		public static function isPlayerDebug ():Boolean
		{
			return Capabilities.isDebugger;
		}
		
		/**
		 * Savoir si le player est en standAlone.
		 */
		public static function isStandalone ():Boolean
		{
			return (Capabilities.playerType == "StandAlone");
		}
		
		/**
		 * On teste si on est dans l'IDE de Flash.
		 * @return True si on est dans L'IDE sinon false.
		 */
		public static function isInIDE ():Boolean
		{
			return Capabilities.playerType == "External";
		}
		
		/**
		 * On test si on est dans un browser ou pas.
		 * @return	True si on est dans un browser, si non, false.
		 */
		public static function isInBrowser ():Boolean
		{
			return Capabilities.playerType == "PlugIn" || Capabilities.playerType == "ActiveX";
		}
		
		/**
		 * On test si on est dans une application AIR
		 * @return
		 */
		public static function isAIRApplication ():Boolean
		{
			return Capabilities.playerType == "Desktop";
		}
		
	}
}