package fr.swapp.graphic.media
{
	import flash.events.NetStatusEvent;
	import flash.events.StageVideoAvailabilityEvent;
	import flash.events.StageVideoEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.StageVideo;
	import flash.media.StageVideoAvailability;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.utils.setTimeout;
	import fr.swapp.core.roles.IReadyable;
	import fr.swapp.graphic.base.SComponent;
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	
	/**
	 * @author ZoulouX
	 */
	public class SVideoContainer extends SComponent implements IReadyable
	{
		/**
		 * Net connection
		 */
		protected var _netConnection			:NetConnection;
		
		/**
		 * Net stream
		 */
		protected var _netStream				:NetStream;
		
		/**
		 * If player is ready
		 */
		protected var _ready					:Boolean;
		
		/**
		 * When player is ready
		 */
		protected var _onReady					:Signal						= new Signal();
		
		/**
		 * If video is enough loaded to play
		 */
		protected var _loaded					:Boolean;
		
		/**
		 * When video is enough loaded to play
		 */
		protected var _onLoaded					:Signal						= new Signal();
		
		/**
		 * If StageVideo is available
		 */
		protected var _stageVideoAvailable		:Boolean;
		
		/**
		 * If StageVideo is allowed
		 */
		protected var _stageVideoAllowed		:Boolean					= true;
		
		/**
		 * The reserved StageVideo component
		 */
		protected var _stageVideoComponent		:StageVideo;
		
		/**
		 * The local Video component
		 */
		protected var _videoComponent			:Video;
		
		/**
		 * Vidéo to load when ready
		 */
		protected var _videoToLoad				:String;
		
		/**
		 * If autoplay is enabled
		 */
		protected var _autoPlay					:Boolean;
		
		/**
		 * Original video width
		 */
		protected var _videoWidth				:uint;
		
		/**
		 * Original video height
		 */
		protected var _videoHeight				:uint;
		
		/**
		 * Video duration in seconds
		 */
		protected var _videoDuration			:Number;
		
		/**
		 * When video is ended
		 */
		protected var _onVideoEnded				:Signal					= new Signal();
		
		
		/**
		 * If player is ready
		 */
		public function get ready ():Boolean { return _ready; }
		
		/**
		 * When player is ready
		 */
		public function get onReady ():ISignal { return _onReady; }
		
		/**
		 * If video is enough loaded to play
		 */
		public function get loaded ():Boolean { return _loaded; }
		
		/**
		 * When video can be played
		 */
		public function get onLoaded ():ISignal { return _onLoaded; }
		
		/**
		 * If StageVideo is available
		 */
		public function get stageVideoAvailable ():Boolean { return _stageVideoAvailable; }
		
		/**
		 * Original video width
		 */
		public function get videoWidth ():uint { return _videoWidth; }
		
		/**
		 * Original video height
		 */
		public function get videoHeight ():uint { return _videoHeight; }
		
		/**
		 * Video duration in seconds
		 */
		public function get videoDuration ():Number { return _videoDuration; }
		
		/**
		 * When video is ended
		 */
		public function get onVideoEnded ():Signal { return _onVideoEnded; }
		
		/**
		 * If StageVideo is allowed
		 */
		public function get stageVideoAllowed ():Boolean { return _stageVideoAllowed; }
		public function set stageVideoAllowed (value:Boolean):void
		{
			_stageVideoAllowed = value;
		}
		
		
		/**
		 * Constructor
		 */
		public function SVideoContainer ()
		{
			
		}
		
		
		/**
		 * Initialisation
		 */
		override public function init ():void
		{
			trace("INIT");
			
			// Ecouter si le stageVideo est disponible
			stage.addEventListener(StageVideoAvailabilityEvent.STAGE_VIDEO_AVAILABILITY, stageVideoAvailableHandler);
			
			// Relayer
			super.init();
		}
		
		
		/**
		 * When we know if StageVideo is available
		 */
		protected function stageVideoAvailableHandler (event:StageVideoAvailabilityEvent):void 
		{
			// Ne plus écouter l'état de disponibilité
			stage.removeEventListener(StageVideoAvailabilityEvent.STAGE_VIDEO_AVAILABILITY, stageVideoAvailableHandler);
			
			// Si le player n'a pas déjà un état ready
			if (!_ready)
			{
				// Enregistrer l'état de disponibilité de StageVideo
				_stageVideoAvailable = event.availability == StageVideoAvailability.AVAILABLE;
				
				// Si le stageVideo est disponible
				if (_stageVideoAvailable && _stageVideoAllowed)
				{
					// On récupère un composant stageVideo
					_stageVideoComponent = stage.stageVideos[stage.stageVideos.length - 1];
					
					// Ecouter lorsque le stageVideo change d'état
					_stageVideoComponent.addEventListener(StageVideoEvent.RENDER_STATE, stageVideoRenderHandler);
				}
				else
				{
					// On créé un container Video de base
					_videoComponent = new Video(0, 0);
					
					// Lisser la vidéo
					_videoComponent.smoothing = true;
					
					// Ajouter la vidéo
					addChild(_videoComponent);
				}
				
				// On est prêt
				_ready = true;
				
				// Signaler qu'on est prêt
				_onReady.dispatch();
				
				trace("AVAILABILITY", _stageVideoAvailable, _stageVideoAllowed, _stageVideoAvailable && _stageVideoAllowed);
				
				// Si on a une vidéo à charger
				if (_videoToLoad != null && _videoToLoad != "")
				{
					load(_videoToLoad, _autoPlay);
				}
			}
		}
		
		/**
		 * Stage video rendered
		 */
		protected function stageVideoRenderHandler (event:StageVideoEvent):void 
		{
			trace("RENDER", event.status);
			
			// Redimensionner
			resized();
		}
		
		/**
		 * Load a video
		 * @param	pURL : The video URL
		 * @param	pAutoPlay : If the video have to play when loaded
		 */
		public function load (pURL:String, pAutoPlay:Boolean = false):void
		{
			trace("LOAD", pURL, pAutoPlay);
			
			// Si le player est prêt
			if (_ready)
			{
				// Si on a déjà un netStream
				if (_netStream != null)
				{
					// Tuer la vidéo en cours
				}
				
				// Plus de vidéo à lire
				_videoToLoad = "";
				
				// Enregistrer l'autoPlay
				_autoPlay = pAutoPlay;
				
				// Créer le netConnection
				_netConnection = new NetConnection();
				_netConnection.connect(null);
				
				// Créer le netStream
				_netStream = new NetStream(_netConnection);
				
				// Appliquer le client
				_netStream.client = {
					onMetaData: metaDataHandler
				};
				
				// Appliquer le netStream à la vidéo
				_stageVideoComponent != null ? _stageVideoComponent.attachNetStream(_netStream) : _videoComponent.attachNetStream(_netStream);
				
				// Ecouter les status
				_netStream.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
				
				// Commencer le chargement de la vidéo
				_netStream.play(pURL);
				
				trace("PLAY", pURL, _stageVideoAvailable, _autoPlay);
				
				/*
				// Si on n'est pas en autoPlay
				if (!_autoPlay)
				{
					// On met en pause
					pause();
				}*/
			}
			else
			{
				// Enregistrer l'URL à lire
				_videoToLoad = pURL;
				_autoPlay = pAutoPlay;
			}
		}
		
		/**
		 * When video receive MetaData
		 */
		protected function metaDataHandler (pMetaData:Object):void
		{
			trace("META DATA HANDLER", pMetaData.width, pMetaData.height, pMetaData.duration);
			
			// Enregistrer les dimensions
			_videoWidth = pMetaData.width;
			_videoHeight = pMetaData.height;
			
			// Enregistrer la durée
			_videoDuration = pMetaData.duration;
			
			// C'est chargé
			_loaded = true;
			
			// Replacer
			resized();
			
			// Signaler que c'est chargé
			_onLoaded.dispatch();
		}
		
		/**
		 * NetStatus on the NetStream
		 */
		protected function netStatusHandler (event:NetStatusEvent):void 
		{
			trace("VideoContainer.netStatusHandler", event.info.code);
			
			// Si la vidéo est finie
			if (event.info.code == "NetStream.Play.Start")
			{
				// Replacer
				resized();
			}
			else if (event.info.code == "NetStream.Play.Stop")
			{
				// Signaler la fin
				_onVideoEnded.dispatch();
			}
		}
		
		/**
		 * Seek into video
		 * @param	pSeekTo : Seek position in seconds
		 */
		public function seek (pSeekTo:Number):void
		{
			
		}
		
		/**
		 * Stop the playing (the video is unloaded)
		 */
		public function stop ():void
		{
			
		}
		
		/**
		 * Pause playing
		 */
		public function pause ():void
		{
			
		}
		
		/**
		 * Resume playing
		 */
		public function resume ():void
		{
			
		}
		
		/**
		 * When player is resized
		 */
		override protected function resized ():void
		{
			// Si c'est prêt
			if (_ready && _loaded)
			{
				// Les positions et dimensions de la vidéo
				var computedVideoWidth		:Number	= _localWidth;
				var computedVideoHeight		:Number	= _localHeight;
				var computedVideoX			:Number	= 0;
				var computedVideoY			:Number	= 0;
				
				// Calculer le ratio
				const videoRatio			:Number = videoWidth / videoHeight;
				
				// Adapter la largeur
				computedVideoHeight = computedVideoWidth / videoRatio;
				
				// Si on dépasse en hauteur
				if (computedVideoHeight > _localHeight)
				{
					// Adapter sur la hauteur
					computedVideoHeight = _localHeight;
					computedVideoWidth = computedVideoHeight * videoRatio;
				}
				
				// Calculer le centre
				computedVideoX = _localWidth / 2 - computedVideoWidth / 2;
				computedVideoY = _localHeight / 2 - computedVideoHeight / 2;
				
				trace("VIDEO SIZE", computedVideoX, computedVideoY, computedVideoWidth, computedVideoHeight);
				
				// Si on a un StageVideo
				if (_stageVideoComponent != null)
				{
					// Le point qui va nous servir à récupérer les coordonnées
					var point:Point = new Point(computedVideoX, computedVideoY);
					
					// Le rectangle de la zone visible de la vidéo
					var viewPort:Rectangle = new Rectangle();
					
					// Récupérer le coin haut gauche
					point = localToGlobal(point);
					
					// Appliquer sur le viewPort
					viewPort.topLeft = point;
					
					// Placer le point en bas à droite
					point.x = computedVideoX + computedVideoWidth;
					point.y = computedVideoY + computedVideoHeight;
					
					// Récupérer le coin bas droite
					point = localToGlobal(point);
					
					// Appliquer sur le viewPort
					viewPort.bottomRight = point;
					
					// On le place
					_stageVideoComponent.viewPort = viewPort;
				}
				
				// Sinon si on est sur un Video
				else if (_videoComponent != null)
				{
					// Placer le composant vidéo
					_videoComponent.x = computedVideoX;
					_videoComponent.y = computedVideoY;
					_videoComponent.width = computedVideoWidth;
					_videoComponent.height = computedVideoHeight;
				}
			}
		}
		
		/**
		 * Destruction
		 */
		override public function dispose ():void
		{
			// Si on a un netStream
			if (_netStream != null)
			{
				// Ne plus écouter les netStatus
				_netStream.removeEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
				
				// Fermer les flux
				_netStream.close();
				_netStream.dispose();
				_netConnection.close();
				_netStream = null;
				_netConnection = null;
			}
			
			// Si on a un composant vidéo
			if (_videoComponent != null)
			{
				// On la vire
				_videoComponent.attachNetStream(null);
				removeChild(_videoComponent);
				_videoComponent = null;
			}
			
			// Si on a un StageVideo
			if (_stageVideoComponent != null)
			{
				// Ecouter lorsque le stageVideo change d'état
				_stageVideoComponent.removeEventListener(StageVideoEvent.RENDER_STATE, stageVideoRenderHandler);
				_stageVideoComponent.attachNetStream(null);
				_stageVideoComponent = null;
			}
			
			// Virer les signaux
			_onLoaded.removeAll();
			_onVideoEnded.removeAll();
			
			_onLoaded = null;
			_onVideoEnded = null;
			
			// Relayer
			super.dispose();
		}
	}
}