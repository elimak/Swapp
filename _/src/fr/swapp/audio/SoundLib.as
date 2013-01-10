package fr.swapp.audio 
{
	import flash.media.Sound;
	import flash.media.SoundChannel;
	/**
	 * ...
	 * @author ZoulouX
	 */
	public class SoundLib
	{
		/**
		 * L'instance en singleton
		 */
		protected static var __instance			:SoundLib;
		
		/**
		 * La librairie publique
		 */
		public var lib							:Array = [];
		
		/**
		 * Le constructeur
		 */
		public function SoundLib ()
		{
			__instance = this;
		}
		
		/**
		 * Ajouter un son dans la librairie
		 * @param	pSound : Un objet de type Sound, SoundLoader, ou string pour l'url
		 */
		public function addSound (pName:String, pSound:*):void
		{
			// Le soundLoader
			var soundLoader:SoundLoader;
			
			// Vérifier le type du son
			if (pSound is String)
				soundLoader = new SoundLoader(pSound);
			else if (pSound is Sound)
				soundLoader = new SoundLoader(null, pSound as Sound);
			else if (pSound is SoundLoader)
				soundLoader = pSound as SoundLoader;
			else
				soundLoader = new SoundLoader();
			
			// Ajouter à la librairie
			lib[pName] = soundLoader;
		}
		
		/**
		 * Récupérer un soundLoader par son nom
		 * @param	pName
		 * @return : Le soundLoader
		 */
		public function getSoundByName (pName:String):SoundLoader
		{
			if (lib[pName] != null)
				return lib[pName];
			else
				return null
		}
		
		/**
		 * Lire un son de la livrairie
		 * @param	pName : Le nom du son à jouer
		 */
		public function playSound (pName:String, pConfig:Object = null):SoundChannel
		{
			if (lib[pName] != null)
				return (lib[pName] as SoundLoader).play(pConfig);
			else
				return null;
		}
		
		/**
		 * Initialisation de la lib
		 */
		public function init ():void
		{
			
		}
	}
}