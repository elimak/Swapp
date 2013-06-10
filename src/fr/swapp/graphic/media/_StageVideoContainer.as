package fr.swapp.graphic.media
{
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import fr.swapp.graphic.base.SComponent;
	/**
	 * Stage Video container. Automatic Video fallback.
	 * @author Pascale Achard / Alexis Bouhet
	 */
	public class StageVideoContainer extends SComponent 
	{
		/**
		 * Les états de lecture
		 */
		public static const IDDLE_STATE					:String		= "IDDLE_STATE";
		public static const PLAYING_STATE				:String 	= "PLAYING_STATE";
        public static const STOPPED_STATE				:String 	= "STOPPED_STATE";
        public static const PAUSED_STATE				:String 	= "PAUSED_STATE";
		
		/**
		 * Les états fullscreen
		 */
		public static const DISPLAY_STATE_FULLSCREEN	:String 	= "DISPLAY_STATE_FULLSCREEN";
		public static const DISPLAY_STATE_NORMAL		:String 	= "DISPLAY_STATE_NORMAL";
		
		
		/**
		 * La NetConnection.
		 */
		protected var _nc								:NetConnection;
		
		/**
		 * Le NetStream.
		 */
		protected var _ns								:NetStream;
		
		/**
		 * Le wrapper/proxy du StageVideo.
		 */
		protected var _simpleStageVideo					:SimpleStageVideo;
		
		/**
		 * L'URL de la vidéo.
		 */
		private var _url:String;
		
		/**
		 * Le fond.
		 */
		private var _background:ResizableComponent;
		
		/**
		 * La durée du flux.
		 */
		private var _duration:Number;
		
		/**
		 * Les métadatas.
		 */
		private var _metadata:Object;
		
		/**
		 * La vidéo est arretée ?
		 */
		private var _videoStoped:Boolean;
		
		/**
		 * L'état du player.
		 */
		private var _state:String;
		
		/**
		 * L'état de l'affichage.
		 */
		private var _displayState:String;
		
		/**
		 * L'image de la preview.
		 */
		private var _preview:AdvancedBitmap;
		
		/**
		 * L'URL de la préview.
		 */
		private var _previewURL:String;
		
		/**
		 * Les controls.
		 */
		private var _controls:VideoControlsComponent;
		
		/**
		 * Les callbacks sur le fullscreen.
		 */
		private var fullscreenOnHandler:Function;
		private var fullscreenOffHandler:Function;
		
		/**
		 * Toggle Auto ?
		 */
		private var _autoToggle:Boolean;
		
		/**
		 * Autoplay
		 */
		private var _autoPlay:Boolean;
		private var _onStateChange:Signal;
		private var _onDisplayStateChange:Signal;
		
		/**
		 * Le timer du téléchargement.
		 */
		private var _dlTimer:Timer;
		
		/**
		 * 
		 */
		private var _seekRequested:Boolean;
		
		/**
		 * Le conteneur du SimpleStageVideo.
		 */
		private var _simpleStageVideoContainer:ResizableComponent;
		
		
 
		public function get state():String 
		{
			return _state;
		}
		
		public function get controls():VideoControlsComponent 
		{
			return _controls;
		}
		
		public function set controls(value:VideoControlsComponent):void 
		{
			//si on a déjà des controls on les vire.
			if (_controls != null)
			{
				if(_controls.parent) _controls.into(null);
				_controls = null;
			}
			
			_controls = value;
			if (_controls == null) return;
			
			_controls.onTapEnd.add(controlsTapEndHandler);
			_controls.onSeeking.add(controlsSeekHandler);
			_controls.onSeekingEnd.add(controlsSeekEndHandler);
			_controls.onFullscreen.add(controlsBtFullscreenClickHandler);
			_controls.onPlayPause.add(controlsPlayPauseClickHandler);
		}
		
		public function get onStateChange():Signal 
		{
			return _onStateChange;
		}
		
		public function get onDisplayStateChange():Signal 
		{
			return _onDisplayStateChange;
		}
		
		public function get duration():Number 
		{
			return _duration;
		}
		
		/**
		 * Construct
		 */
		public function AndroidVideoPlayer (pUrl:String, pPreviewURL:String = "", pFullscreenOnHandler:Function = null, pFullscreenOffHandler:Function = null, pAutoToggle:Boolean = false, pAutoPlay:Boolean = false )
		{
			// On stock l'URL
			_url = pUrl;
			
			// On stock l'URL de la preview.
			_previewURL = pPreviewURL;
			
			// On stock le "autoToggle".
			_autoToggle = pAutoToggle
			
			// Autoplay ?
			_autoPlay = pAutoPlay;
			
			// L'état par défaut.
			_state = STOPPED_STATE;
			
			_displayState = DISPLAY_STATE_NORMAL;
			
			
			// Les function de fullscreen.
			fullscreenOnHandler = pFullscreenOnHandler;
			fullscreenOffHandler = pFullscreenOffHandler;
			
		}
		
		/**
		 * Met en lecture la vidéo courrante.
		 */
		public function play():void 
		{
			doPlay();
		}
		
		/**
		 * Met en pause la vidéo courrante.
		 */
		public function pause():void 
		{
			doPause();
		}
		
		/**
		 * Ajout au stage
		 */
		override public function init():void 
		{
			super.init();
			
			// Les signaux.
			_onStateChange = new Signal();
			_onDisplayStateChange = new Signal();
			
			// On configure la connexion.
			setupConnection();
			
			// On configure l'affichage.
			setupUI();
			
			// On charge le stream.
			_ns.play(_url);
			
			// Le timer du téléchargement.
			_dlTimer = new Timer(500);
			_dlTimer.addEventListener(TimerEvent.TIMER, dlTimerHandler);
			
			// On met de suite en pause.
			if (_autoPlay)
			{
				doPlay();
			}else
			{
				doPause();
			}
		}
		
		
		public function setFullscreenMode(pMode:String):void 
		{
			if (pMode == DISPLAY_STATE_NORMAL)
			{
				_displayState = DISPLAY_STATE_NORMAL;
				layoutNormal();
				_onDisplayStateChange.dispatch(_displayState);
			}else if (pMode == DISPLAY_STATE_FULLSCREEN)
			{
				_displayState = DISPLAY_STATE_FULLSCREEN;
				layoutFullscreen();
				_onDisplayStateChange.dispatch(_displayState);
			}
		}
		
		public function getFullscreenMode():String 
		{
			return _displayState;
		}
		
		public function preDispose():void 
		{
			
			// Le SimpleStageVideo.
			if (_simpleStageVideo)
			{
				_simpleStageVideo.dispose();
				if(_simpleStageVideo.parent)
					_simpleStageVideo.parent.removeChild(_simpleStageVideo);
				_simpleStageVideo = null;
			}
			
			
			// On vire le ns.
			if (_ns)
			{
				_ns.removeEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
				_ns.close();
				_ns.dispose();
			}
			
			// On vire le nc
			if (_nc)
			{
				_nc.close();
				_nc = null;
			}
		}
		
		public function forceResize():void 
		{
			resized();
		}
		
		public function createDefaultControls():void 
		{
			createControls();
		}
		
		private function setupConnection():void 
		{
			// Connection
			if (!_nc)
			{
				_nc = new NetConnection();
				_nc.connect(null);
			}
			
			// Le netstream			
			_ns = new NetStream(_nc);			
			_ns.inBufferSeek = true;
			
			// client pour la fonction onMetaData
			var customClient:Object;
			customClient = new Object;
			customClient.onMetaData = onMetaDataHandler;
			_ns.client = customClient;
			_ns.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
		}
		
		private function setupUI():void 
		{
			// On créer un fond.
			_background = new AdvancedBitmap(null, AdvancedBitmap.INSIDE_SCALE_MODE, 1, 0x000000);
			_background.place(0, 0, 0, 0);
			_background.into(this);
			//_background.alpha = 0.5;	
			
			// On créer la preview.
			_preview = new AdvancedBitmap(null, AdvancedBitmap.INSIDE_SCALE_MODE, 1);
			_preview.place(0, 0, 0, 0);
			_preview.into(this);
			_preview.alpha = 1;
			
			BitmapCache.create(_preview).load(_previewURL, previewLoadedHandler);
			
			// On créer/configure l'objet vidéo.
			_simpleStageVideoContainer = new ResizableComponent().place(0, 0, 0, 0).into(this);
			_simpleStageVideo = createSimpleStageVideo();
			_simpleStageVideo.addEventListener(Event.INIT, videoSimpleStageVideoInitHandler);
			_simpleStageVideo.addEventListener(SimpleStageVideoEvent.STATUS, statusChangeHandler);
			_simpleStageVideo.visible = false;
			_simpleStageVideo.attachNetStream(_ns);	
			_simpleStageVideoContainer.addChild(_simpleStageVideo);
			
			createControls();
			
			_controls.hideControls();
			
			// On masque le loader.
			_controls.showLoader();
			
		}
		
		/**
		 * Joue le média.
		 */
		private function doPlay ():void 
		{
			// On affiche la vidéo.
			_simpleStageVideo.visible = true;
			
			// On cache la preview.
			_preview.visible = false;
			
			_videoStoped = false;		
			
			if (!_ns || _state == PLAYING_STATE)
				return;			
            if (_state == STOPPED_STATE)
            {
                _ns.seek(0);
            }
			
            _ns.resume();
			
			// On met à jour les boutons correspondants.
			_controls.btPlayPause.selected = true;
			
			// On boucle sur la frame pour la progression de lecture.
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			
			// On démarre le timer du téléchargement.
			_dlTimer.start();
			
			//_state = PLAYING_STATE;
			updateState(PLAYING_STATE);
			
			// On autorise pas le device de passer en sleep.
			NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.KEEP_AWAKE;
		}
		
		/**
		 * Met en pause le média.
		 */
		private function doPause ():void 
		{
			if (!_ns)
				return;			
			_ns.pause();
			
			// On met à jour les boutons correspondants.
			_controls.btPlayPause.selected = false;
			
			//_state = PAUSED_STATE;
			updateState(PAUSED_STATE);
			
			// On autorise le device de passer en sleep.
			NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.NORMAL;
			
		}
		
		/**
		 * Change l'état du player
		 * @param	pState
		 */
		private function updateState(pState:String):void 
		{
			_state = pState;
			_onStateChange.dispatch(_state);
		}
		
		/**
		 * L'image de la préview est chargée.
		 */
		private function previewLoadedHandler(pBitmapData:BitmapData, pFromCache:Boolean):void 
		{
			// Si on n'a pas de stage ça ne sert à rien d'aller plus loin
			if (stage == null || ZapiksAnimationEnhancer.checkIfParentHasCAB(parent, previewLoadedHandler, [pBitmapData, pFromCache]))
			{
				return;
			}
			
			_preview.bitmapData = pBitmapData;
		}
		
		
		private function createControls():void 
		{
			controls = new VideoControlsComponent();
			_controls.place(0, 0, 0, 0);
			_controls.into(this);
			
			// Si on est en lecture, je mets à jour les controles.
			_controls.btPlayPause.selected = _state == PLAYING_STATE;
		}
		
		
		private function controlsTapEndHandler(e:MouseEvent):void 
		{			
			// Si les controles sont visibles, on les cache et vis et versa.
			if (_controls.isControlsShowned) _controls.hideControls();
				else _controls.showControls();
		}
		
		private function controlsSeekHandler(pRatio:Number):void 
		{			
			// Si pas de NetStream on vire.
			if (_ns == null) return;
			
			_seekRequested = true;
			
			// Le ratio de temps.
			var time:int = Math.round(_duration * pRatio);
			//trace( "time : " + time );
			
			// On affiche le temps.
			var m:uint = Math.floor(time / 60);
			var s:uint = Math.floor(time % 60);
			
			_controls.setTime(((m < 10 ? "0" : "") + String(m)) + ":" + ((s < 10 ? "0" : "") + String(s)));
			
		}
		
		private function controlsSeekEndHandler(pRatio:Number):void 
		{
			trace("/////////////////////\n",  "pRatio : " + pRatio );
			
			// Si pas de NetStream on vire.
			if (_ns == null) return;
			
			// Le ratio de temps.
			trace( "_duration : " + _duration );
			var time:Number = Math.round(_duration * pRatio);			
			
			trace( "time : " + time , "\n/////////////////////\n");
			
			// On seek var le nouveau temps
			_ns.seek(time);
		}
		
		/**
		 * Ecoute le bouton play/pause.
		 */
		private function controlsPlayPauseClickHandler(e:MouseEvent):void 
		{
			trace( "e : " + e );
			
			if (_state == PLAYING_STATE)
			{
				doPause();							
			}
			else
			{
				doPlay();
			}
		}
		
		/**
		 * Ecoute le clique sur le boutons fullscreen.
		 * @param	e
		 */
		private function controlsBtFullscreenClickHandler(e:MouseEvent):void 
		{
			
			if (_displayState == DISPLAY_STATE_NORMAL)
			{
				_displayState = DISPLAY_STATE_FULLSCREEN;
				layoutFullscreen();
				
				// On passe par le callback pour masquer l'appli est réverler le StageVideo.
				//fullscreenOnHandler.apply(null, [this]);
				_onDisplayStateChange.dispatch(_displayState);
				
			}else if (_displayState == DISPLAY_STATE_FULLSCREEN)
			{
				_displayState = DISPLAY_STATE_NORMAL;
				
				layoutNormal();
				
				// On passe par le callback pour afficher l'application.
				//fullscreenOffHandler.apply(null, [this]);
				_onDisplayStateChange.dispatch(_displayState);				
				
			}
			
		}
		
		
		
		
		/**
		 * Créer un SimpleStageVideo.
		 */
		private function createSimpleStageVideo():SimpleStageVideo
		{
			if (_simpleStageVideo) return null;
			
			return new SimpleStageVideo(this.totalWidth, this.totalHeight, _autoToggle);
		}
		
		private function statusChangeHandler(event:SimpleStageVideoEvent):void 
		{
			// informs you about the decoding, compositing states and if full GPU acceleration is performing
			var hardwareDecoding:Boolean = event.hardwareDecoding;
			var hardwareCompositing:Boolean = event.hardwareCompositing;
			var fullGPU:Boolean = event.fullGPU;
			Log.notice("hardwareDecoding : ", hardwareDecoding);
			Log.notice("hardwareCompositing : ", hardwareCompositing);
			Log.notice("fullGPU : ", fullGPU);
		}
		
		private function videoSimpleStageVideoInitHandler(e:Event):void 
		{
			trace( "e : " + e );
		}
		
 
		private function onMetaDataHandler(info:Object):void
		{
			// Si les metadata ont déjà été stockées on dégage !
			
			if (_metadata) return;
			_metadata = info;			
			
			// Si les metadata contiennent la durée du média, on la stoque.
			if (_metadata.hasOwnProperty("duration"))
			{
				_duration = Number(_metadata.duration);
			}
			
			trace("metadata: duration=" + info.duration + " width=" + info.width + " height=" + info.height + " framerate=" + info.framerate);			
			
			// Si on a des contoles, on affiche la durée du média;
			if (_controls) _controls.setDuration(_duration);
			
			// On masque le loader.
			_controls.hideLoader();
			_controls.showControls();
			
			resized();		
		}
		
		
		private function updateVideoSize(pWidth:int, pHeight:int):void 
		{
			if (!_simpleStageVideo) return;
			_simpleStageVideo.resize(pWidth, pHeight);
		}
		
		private function netStatusHandler(e:NetStatusEvent):void 
		{
			Log.notice(e.info.code);
			Log.notice("NetStream.onStatus called: ("+getTimer()+" ms)");
			for (var prop:* in e.info) {
				Log.notice("\t"+prop+":\t"+e.info[prop]);
			}
			Log.notice(" ");
			switch (e.info.code) {
				
                case "NetConnection.Connect.Success":
					
                    break;
				case "NetConnection.Connect.Failed":
                case "NetConnection.Connect.Success":
					trace(e.info.code);
					break;
                    
                case "NetStream.Play.StreamNotFound":
                    trace("Unable to locate video: " + _ns.info);
                    break;
				case "NetStream.Play.Start":
                    trace("La vidéo commence");	
					_seekRequested = false;
                    break;
					
				case "NetStream.Play.Stop": 
					trace("La vidéo stop");
					_videoStoped = true;					
					doPause();					
					_ns.seek(0);					
					break;
					
				case "NetStream.Buffer.Empty": 
					trace("La vidéo bufferise");
					//setBufferStatus(true);
					break;
					
				case "NetStream.Buffer.Full":
					_seekRequested = false;
					break;
					
				case "NetStream.Buffer.Flush":
                    break;
				
				case "NetStream.Seek.Notify":
					
                    break;
					
				default:
				{
					
				}
			}			
		}
		
		
		
		private function layoutFullscreen():void 
		{
			// On force le StageVideo.
			if (_autoToggle == false) _simpleStageVideo.toggle(true);
			
			// Si le StageVideo n'est pas disponible on fait un fallback.
			if (_simpleStageVideo.available == false)
			{
				_simpleStageVideo.x = 0;
				_simpleStageVideo.y = 0;
				stage.addChildAt(_simpleStageVideo, 0);
			}
			
			// On resize la vidéo à la taille du stage.
			_simpleStageVideo.resize(stage.fullScreenWidth, stage.fullScreenHeight);
		}
		
		private function layoutNormal():void 
		{			
			// On force le mode video en VideoObject.
			if(_autoToggle == false) _simpleStageVideo.toggle(false);
			
			// On réintègre le SimpleStageVideo au player.
			if (!contains(_simpleStageVideo))
			{
				_simpleStageVideo.x = 0;
				_simpleStageVideo.y = 0;
				this.addChild(_simpleStageVideo);
			}
			
			// On resize la vidéo à la taille du player.
			_simpleStageVideo.resize(this.totalWidth, this.totalHeight);
			
			// Si il n'y a pas de controles, on les créer.
			if(_controls == null)
				createControls();
			
			// On désactive le bt fullscreen.
			_controls.btFullscreen.selected = false;
		}
		
		
		/**
		 * Le conposant à été redimensionné.
		 */
		override protected function resized():void 
		{
			//trace( "resized" );
			
			if ( isNaN(this.totalWidth) || isNaN(this.totalHeight)) return;
			
			// On met à jour les dimensions de la vidéo avec un callback si jamais il y a plusieurs resized.
			TweenMax.killDelayedCallsTo(delayedCallback);			
			TweenMax.delayedCall(0.2, delayedCallback);
			//setTimeout(delayedCallback, 200);
		}
		
		/**
		 * Callback du resized().
		 */
		private function delayedCallback():void 
		{
			// On met à jour la taille de la vidéo.
			// Attention, faut tester si on est en fullscreen ou pas sinon on passe pas les bonnes dimensions.
			if (_displayState == AndroidVideoPlayer.DISPLAY_STATE_FULLSCREEN)
			{
				updateVideoSize(stage.fullScreenWidth, stage.fullScreenHeight);
			}else {
				updateVideoSize(this.totalWidth, this.totalHeight);
			}
		}
		
		/**
		 * Ecoute l'enterframe.
		 * @param	e
		 */
		private function enterFrameHandler(e:Event):void 
		{			
			// Si on à pas de metadata, on à pas le temps courrant...
			if (!_duration) return;
			
			// Si pas de NetStream on vire.
			if (_ns == null) return;
						
			if (_controls.isSeeking) return;
			
			if (_seekRequested) return;
			
			// On affiche le temps.			
			_controls.setTimeInSeconds(_ns.time);
			
			// On met à jour la progression.
			_controls.setTimeProgressBar(_ns.time / _duration);
			//trace( "_ns.time : " + _ns.time );
			
			// on affiche la durée du média;
			_controls.setDuration(_duration);
			
		}
		
		/**
		 * Ecoute le timer de téléchargement.
		 * @param	e
		 */
		private function dlTimerHandler(e:TimerEvent):void 
		{
			// Si pas de NetStream on vire.
			if (_ns == null) return;
			
			// On met à jour la progression de téléchargement.			
			var prc:Number = _ns.bytesLoaded / _ns.bytesTotal;			
			_controls.setDownloadProgress(prc);
			
			// Si on a atteint 100% on arrete le timer.
			if (prc >= 100)
			{
				_dlTimer.stop();
			}
		}
		
		/**
		 * Dispose l'objet.
		 */
		override public function dispose():void 
		{
			Log.notice(Object(this).constructor, "DISPOSE");
			
			// On écoute plus le SSV.
			if (_simpleStageVideo)
			{
				_simpleStageVideo.removeEventListener(Event.INIT, videoSimpleStageVideoInitHandler);
				_simpleStageVideo.removeEventListener(SimpleStageVideoEvent.STATUS, statusChangeHandler);
			}
			
			// On vire les callbacks.
			fullscreenOnHandler = null;
			fullscreenOffHandler = null;
			
			// On écoute plus.
			removeEventListener(Event.ENTER_FRAME, enterFrameHandler); 
			
			// On arrete le timer.
			if (_dlTimer)
			{
				_dlTimer.stop();
				_dlTimer.removeEventListener(TimerEvent.TIMER, dlTimerHandler);
				_dlTimer = null;
			}
			
			// On continue sur le predispose.
			preDispose();
			
			// Les signaux.
			_onDisplayStateChange = null;
			_onStateChange = null;
			
			// On autorise pas le device de passer en sleep.
			NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.NORMAL;
			
			super.dispose();		
		}
	}
}