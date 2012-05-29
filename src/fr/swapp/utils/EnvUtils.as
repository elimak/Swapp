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
		 * Les plateformes
		 */
		public static const WIN_PLATFORM				:String				= "WIN";
		public static const MAC_PLATFORM				:String				= "MAC";
		public static const LINUX_PLATFORM				:String				= "LINUX";
		public static const IOS_PLATFORM				:String				= "IOS";
		public static const ANDROID_PLATFORM			:String				= "ANDROID";
		
		/**
		 * Les types de devices
		 */
		public static const PHONE						:String				= "PHONE";
		public static const TABLET						:String				= "TABLET";
		public static const COMPUTER					:String				= "COMPUTER";
		
		/**
		 * Inconnu (plateforme, device, taille...)
		 */
		public static const UNKNOW						:String				= "UNKNOW";
		
		/**
		 * La délimitation entre téléphone et tablette (en pouces)
		 */
		public static const TABLET_SIZE_DELIMITATION	:Number				= 6.5;
		
		/**
		 * Les DPIs de base
		 */
		public static const COMPUTER_DPI				:uint				= 72;
		public static const IPAD_CLASSIC_DPI			:uint				= 132;
		public static const IPAD_RETINA_DPI				:uint				= 264;
		public static const IPHONE_CLASSIC_DPI			:uint				= 163;
		public static const IPHONE_RETINA_DPI			:uint				= 326;
		
		/**
		 * Les identifiants iPhone (pour la détéction)
		 */
		public static const IPHONE_1_DEVICE				:String				= "iPhone1,1";
		public static const IPHONE_3G_DEVICE			:String				= "iPhone1,2";
		public static const IPHONE_3GS_DEVICE			:String				= "iPhone2,1";
		public static const IPHONE_4_DEVICE				:String				= "iPhone3,";
		public static const IPHONE_4S_DEVICE			:String				= "iPhone4,1";
		
		/**
		 * Les identifiants iPod (pour la détéction)
		 */
		public static const IPOD_TOUCH_1_DEVICE			:String				= "iPod1,";
		public static const IPOD_TOUCH_2_DEVICE			:String				= "iPod2,";
		public static const IPOD_TOUCH_3_DEVICE			:String				= "iPod3,";
		public static const IPOD_TOUCH_4_DEVICE			:String				= "iPod4,";
		
		/**
		 * Les identifiants iPad (pour la détéction)
		 */
		public static const IPAD_1_DEVICE				:String				= "iPad1,1";
		public static const IPAD_2_DEVICE				:String				= "iPad2,";
		
		/**
		 * Récupérer la version du player
		 */
		public static function getPlayerVersion ():Vector.<uint>
		{
			return new <uint>[PlayerInfos.getMajorVersion(), PlayerInfos.getMinorVersion(), PlayerInfos.getBuildNumber(), PlayerInfos.getInternalBuild()];
		}
		
		/**
		 * Récupérer la plateforme sur laquelle est éxécuté le player
		 */
		public static function getPlatform ():String
		{	
			/**
			 * Deux façon de connaitre la platefomre :
			 * 	- par le Capabilities.version
			 *  - par le Capabilities.os, mais là c'est le système d'exploitation. 
			 * Par exemple sur mon SII on a :
			 * Capabilities.os :  Linux 2.6.35.7-I9100XWKK5-CL754841
			 * PlayerInfos.getPlatform() :  AND
			 * 
			 * Il vaut donc mieux passer par le player pour récupérer la plateforme.
			 * 
			 */
			var platform:String = Capabilities.os;
			
			//trace( "Capabilities.os : " , platform );
			//trace( "Capabilities.manufacturer : " , Capabilities.manufacturer );
			//trace( "PlayerInfos.getPlatform() : " , PlayerInfos.getPlatform() );
			
			switch (PlayerInfos.getPlatform().toLowerCase()) 
			{
				case "win":
					return WIN_PLATFORM;
				break;
				case "mac":
					return MAC_PLATFORM;
				break;
				case "lnx":
					return LINUX_PLATFORM;
				break;
				case "and":
					return ANDROID_PLATFORM;
				break;
				case "ios":
					return IOS_PLATFORM;
				break;
				default:
					return UNKNOW;
			}
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
		 * Récupérer le type de device
		 */
		public static function getDeviceType (pAllowComputerReturn:Boolean = true, pScreenWidth:int = -1, pScreenHeight:int = -1):String
		{
			// On est sur un device ?
			var platform:String = EnvUtils.getPlatform();
			
			// Si on autorise à retourner un type computer
			if (pAllowComputerReturn)
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
				switch (Capabilities.screenDPI) 
				{
					// iPhone4
					case IPHONE_RETINA_DPI:
					// iPhone3
					case IPHONE_CLASSIC_DPI:
						return PHONE;
					break;
					// iPad3
					case IPAD_RETINA_DPI:
					// iPad
					case IPAD_CLASSIC_DPI:
						return TABLET;
					break;
					default: "";
				}
			}
			
			// Ou si on est sur Android
			else if (platform == ANDROID_PLATFORM)
			{
				if (getScreenSize() >= TABLET_SIZE_DELIMITATION)
				{
					return TABLET;
				}
				else
				{
					return PHONE;
				}
			}
			
			// Si on n'autorise pas les return computer
			else if (!pAllowComputerReturn)
			{
				if (getScreenSize(pScreenWidth, pScreenHeight) >= TABLET_SIZE_DELIMITATION)
				{
					return TABLET;
				}
				else
				{
					return PHONE;
				}
				
			}
			
			return UNKNOW;
		}
		
		/**
		 * Récupérer la taille de l'écran (la diagonale, en pouces)
		 */
		public static function getScreenSize (pScreenWidth:int = -1, pScreenHeight:int = -1):Number
		{
			const screenWidth	:Number = (pScreenWidth != -1 ? pScreenWidth : Capabilities.screenResolutionX) / Capabilities.screenDPI;
			const screenHeight	:Number = (pScreenHeight != -1 ? pScreenHeight : Capabilities.screenResolutionY) / Capabilities.screenDPI;
			const screenSize	:Number = Math.sqrt(screenWidth * screenWidth + screenHeight * screenHeight);
			
			return screenSize;
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
		
		/**
		 * Un toString de l'environnement.
		 * @return
		 */
		static public function toString():String 
		{
			// La sortie.
			var output:String;
			
			// Le player.
			output = PlayerInfos.toString();
			
			// La plateforme.
			
			output += 	"---------PLATFORM-----------\n" +
						"PLATFORM:\t\t\t" + EnvUtils.getPlatform() + "\n" +
						"PLATFORM_VERSION:\t\t" + EnvUtils.getPlateformVersion() + "\n" +
						"-----------------------------\n";
		
			// Le Device.
			output += 	"---------DEVICE-----------\n" +
						"DEVICE:\t\t\t" + EnvUtils.getDeviceType() + "\n" +
						"-----------------------------\n";
			
			return output;
		}
	}
}

import flash.system.Capabilities;


// Le player
class PlayerInfos
{
	
	// PROPERTIES
	// ----------------------------------------
	
	/**
	 * La plateforme
	 */
	protected static var __platform				:String;
	
	/**
	 * Le numéro de version (complet, ex: 11,3,521,22).
	 */
	protected static var __version				:String;
	
	/**
	 * La version majeur
	 */
	protected static var __majorVersion			:uint;
	
	/**
	 * La version mineur.
	 */
	protected static var __minorVersion			:uint;
	
	/**
	 * Le num de la build
	 */
	protected static var __buildNumber			:uint;
	
	/**
	 * Le num de la build interne.
	 */
	protected static var __internalBuildNumber	:uint;
	
	// METHODS
	// ----------------------------------------		
	
	/**
	 * On récupère la platfomer sur laquel fonctionne le player en cours. (PC, Mac, Lin ?).
	 * @return Retourne la platforme du player.
	 */
	public static function getPlatform():String 
	{
		if (!__platform)
			_getPlayerInfos();
		
		return __platform;
	}
	
	
	/**
	 * On récupère le numéro majeur de version du player.
	 * @return Le numéro majeur du player.
	 */
	public static function getMajorVersion():Number 
	{
		if (!__majorVersion)
			_getPlayerInfos();
		
		return __majorVersion;
	}
	
	
	/**
	 * On récupère le numéro mineur de version du player.
	 * @return Le numéro mineur du player.
	 */
	public static function getMinorVersion():Number 
	{
		if (!__minorVersion)
			_getPlayerInfos();
		
		return __minorVersion;
	}
	
	
	/**
	 * On récupère la build du player.
	 * @return Retourne le numéro de build du player.
	 */
	public static function getBuildNumber():Number 
	{
		if (!__buildNumber)
			_getPlayerInfos();
		
		return __buildNumber;
	}
	
	/**
	 * Récupère la build interne.
	 */
	public static function getInternalBuild():Number 
	{
		if (!__internalBuildNumber)
			_getPlayerInfos();
		
		return __internalBuildNumber;
	}
	
	
	protected static function _getPlayerInfos ():void 
	{
		var versionString:String = Capabilities.version; 
		var pattern:RegExp = /^(\w*) (\d*),(\d*),(\d*),(\d*)$/; 
		var result:Object = pattern.exec(versionString);
		
		if (result != null) 
		{ 
			__version = 			result.input;
			__platform = 			result[1];
			__majorVersion = 		result[2];
			__minorVersion = 		result[3];
			__buildNumber = 		result[4];
			__internalBuildNumber = result[5];
		} 
		else 
		{ 
			trace("Unable to match RegExp."); 
		}
	}	
	
	
	static public function toString ():String
	{
		return  "-------- PLAYER ------------\n" +
				"PLATFORM:\t\t\t" + PlayerInfos.getPlatform() + "\n" +
				"MAJOR_VERSION:\t\t" + PlayerInfos.__majorVersion + "\n" +
				"MINOR_VERSION:\t\t" + PlayerInfos.__minorVersion + "\n" +
				"BUILD_NUMBER:\t\t\t" + PlayerInfos.__buildNumber+ "\n" +
				"INTERNAL_BUILD_NUMBER:\t" + PlayerInfos.__internalBuildNumber + "\n" +
				"-----------------------------\n";
	}
}
	