package fr.swapp.audio 
{
	import com.greensock.TweenLite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundLoaderContext;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	import com.greensock.TweenMax;
	import flash.utils.ByteArray;
	
	/**
	 * ...
	 * @author ZoulouX
	 */
	public class SoundLoader extends EventDispatcher
	{
		/**
		 * La librairie des sons
		 */
		public static var soundLib		:Array				= [];
		
		/**
		 * Le son associé
		 */
		protected var _sound			:Sound;
		
		/**
		 * L'url de ce son
		 */
		protected var _url				:String;
		
		/**
		 * Si le son est chargé
		 */
		protected var _loaded			:Boolean			= false;
		
		/**
		 * Si on doit lire ce son directement après le chargement
		 */
		protected var _toPlay			:Boolean			= false;
		
		/**
		 * Le dernier soundChannel joué
		 */
		protected var _channel			:SoundChannel;
		
		/**
		 * Le soundTransform associé
		 */
		protected var _soundTransform	:SoundTransform;
		
		/**
		 * L'ancien volume pour les fades
		 */
		protected var _oldVolume		:Number;
		
		
		/**
		 * Définir le volume
		 */
		public function get volume ():Number { return _soundTransform.volume; }
		public function set volume (value:Number):void
		{
			// Appliquer le volume
			_soundTransform.volume = value;
			
			// Si on a un channel, on lui associe le nouveau soundTransform
			if (_channel != null)
				_channel.soundTransform = _soundTransform;
		}
		
		/**
		 * Définir le panoramique du son
		 */
		public function get pan ():Number { return _soundTransform.pan; }
		public function set pan (value:Number):void
		{
			// Appliquer le panoramique
			_soundTransform.pan = value;
			
			// Si on a un channel, on lui associe le nouveau soundTransform
			if (_channel != null)
				_channel.soundTransform = _soundTransform;
		}
		
		/**
		 * L'url du son
		 */
		public function get url ():String { return _url; }
		
		/**
		 * Le constructeur
		 * @param	url : L'url du son à charger
		 */
		public function SoundLoader(url:String = null, pSoundInstance:Sound = null)
		{
			// Associer l'instance de son
			if (pSoundInstance != null)
				_sound = pSoundInstance;
			else
				_sound = new Sound();
			
			// Vérifier si une URL a été passée
			if (url != null)
				load(url);
			
			// Créer le soundTransform
			_soundTransform = new SoundTransform();
		}
		
		/**
		 * Charger un son
		 */
		public function load (url:String):void
		{
			// Le charger
			_sound.load(new URLRequest(url));
			
			// Ecouter
			initListeners();
		}
		
		/**
		 * Créer les listeners
		 */
		protected function initListeners():void
		{
			// Ecouter ce qu'il se passe
			_sound.addEventListener(Event.COMPLETE, loadHandler);
			_sound.addEventListener(IOErrorEvent.IO_ERROR, loadErrorHandler);
			_sound.addEventListener(SecurityErrorEvent.SECURITY_ERROR, loadErrorHandler);
		}
		
		/**
		 * Le chargement de ce son est ok
		 */
		protected function loadHandler (event:Event):void
		{
			// Le son est chargé
			_loaded = true;
			
			// Lire si on doit le lire
			if (_toPlay)
				play();
			
			// Dispatcher
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		/**
		 * Ce son n'a pas pu être chargé
		 */
		protected function loadErrorHandler (event:Event):void
		{
			// Dispatcher
			dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));
		}
		
		/**
		 * Lire le son
		 * @param	pConfig : La configuration du son. Les propriétés: loop, delay, volume, pan, fade, start
		 * @return : le soundChannel associé
		 */
		public function play (pConfig:Object = null):SoundChannel
		{
			// Si la config n'est pas nulle
			if (pConfig == null)
				pConfig = { };
			
			// Créer un nouveau soundTransform
			var soundTransform:SoundTransform = new SoundTransform(
				_soundTransform.volume,
				_soundTransform.pan
			);
			
			// Si le volume est différent de nul, on le change
			if (pConfig["volume"] != null && pConfig["volume"] is Number)
				soundTransform.volume = pConfig["volume"];
			
			// Le panoramique
			if (pConfig["pan"] != null && pConfig["pan"] is Number)
				soundTransform.pan = pConfig["pan"];
			
			// Le loop
			var loopParam:uint = pConfig["loop"] != null && pConfig["loop"] is Number ? pConfig["loop"] : 0;
			
			// Le start time
			var startTimeParam:Number = pConfig["start"] != null && pConfig["start"] is Number ? pConfig["start"] : 0;
			
			// Le fade
			var fadeParam:Number = pConfig["fade"] != null && pConfig["fade"] is Number ? pConfig["fade"] : 0;
			
			// Vérifier si y'a un delais
			if (pConfig["delay"] != null && pConfig["delay"] is Number && pConfig["delay"] != 0)
			{
				// Ajouter le delais
				TweenLite.delayedCall(pConfig["delay"], function (pConfigDelay:Object):void
				{
					// Virer le delais de la config
					pConfigDelay["delay"] = 0;
					
					// Lire le son
					play(pConfigDelay);
				},
				[pConfig]);
			}
			else
				_channel = _sound.play(startTimeParam, loopParam, soundTransform);
			
			// Si faut fader
			if (fadeParam > 0)
			{
				// Tweener
				TweenLite.from(soundTransform, pConfig["fade"], {
					volume: 0
				});
			}
			
			// Retourner ce channel
			return _channel == null ? null : _channel;
		}
		
		/**
		 * Arrêter le son
		 */
		public function stop ():void
		{
			// Arrêter le son
			if (_channel != null)
				_channel.stop();
		}
		
		/**
		 * Mutter le son
		 * @param	fade : La durée du fade en secondes
		 */
		public function mute (fade:Number = 1):void
		{
			// Enregistrer l'ancien volume
			_oldVolume = volume;
			
			// Tweener
			TweenLite.to(this, fade, {
				volume: 0
			})
		}
		
		/**
		 * Remettre le son
		 * @param	fade : La durée du fade en secondes
		 */
		public function unmute (fade:Number = 1):void
		{
			// Tweener
			TweenLite.to(this, fade, {
				volume: _oldVolume
			});
		}
	}
}