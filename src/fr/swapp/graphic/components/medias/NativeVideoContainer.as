package fr.swapp.graphic.components.medias 
{
	import flash.events.Event;
	import fr.swapp.graphic.components.webview.WebViewContainer;
	
	/**
	 * Player video natif via un StageWebView.
	 * @author Pascal Achard / ZoulouX
	 */
	public class NativeVideoContainer extends WebViewContainer 
	{
		public static const MEDIA_EVENT_MESSAGE			:String 			= "mediaEvent";
		public static const MEDIA_LOADED_MESSAGE		:String 			= "mediaLoaded";
		public static const MEDIA_ERROR_MESSAGE			:String 			= "mediaError";
		
		/**
		 * L'URL de la vidéo
		 */
		protected var _videoURL							:String				= "";
		
		/**
		 * Si la vidéo doit se charger dès le début
		 */
		protected var _autoLoad							:Boolean;
		
		/**
		 * L'URL de l'image avant la lecture de la vidéo
		 */
		protected var _posterURL						:String;
		
		
		/**
		 * Constructeur
		 */
		public function NativeVideoContainer ()
		{
			// Styles du player
			_additionalStyle += <![CDATA[
				body {
					background-color: black;
				}
				#media
				{
					width: 100%;
					height: 100%;
				}
			]]>.toString();
			
			// Scripts du player
			_additionalScript += <![CDATA[
				// L'objet vidéo
				var media;
				
				// Si la vidéo est prête à la lecture
				var mediaLoaded = false;
				
				// L'état fullscreen
				var fullScreenState;
				
				// Si la vidéo doit charger automatiquement
				var autoLoad;
				
				// L'URL de la vidéo
				var mediaURL;
				
				// L'URL du poster
				var posterURL;
				
				// L'interval du check de l'état plein écran
				var fullScreenCheckInterval;
				
				
				/**
				 * Charger une vidéo
				 * @param	pVideoURL : L'URL de la vidéo à charger
				 * @param	pAutoLoad : Charger automatiquement la vidéo (déclanchera un message "mediaLoaded")
				 * @param	pPosterURL : L'URL de l'image avant la lecture de la vidéo
				 */
				function loadVid (pURL, pAutoLoad, pPosterURL)
				{
					// Enregistrer les paramètres
					mediaURL = pURL;
					autoLoad = pAutoLoad;
					posterURL = pPosterURL;
					
					// Créer l'objet vidéo
					createVideoElement();
					
					// Activer la pause automatique lorsqu'on quitte le plein écran
					pauseOnFullScreenChange();
				}
				
				// Pause lorsqu'on quitte le plein écran
				function pauseOnFullScreenChange ()
				{
					// Si la boucle n'est pas déjà lancée
					if (fullScreenCheckInterval == undefined)
					{
						// L'état du plein écran
						fullScreenState = media.webkitDisplayingFullscreen;
						
						// Activer une boucle de vérification (les events ne marchent pas)
						fullScreenCheckInterval = window.setInterval(function ()
						{
							// Si on a une vidéo et si l'état de plein écran à changé
							if (fullScreenState != media.webkitDisplayingFullscreen && media != null)
							{
								// On enregistre le nouvel état
								fullScreenState = media.webkitDisplayingFullscreen;
								
								// On envoie le message
								sendMessage("fullscreenStateChange", [fullScreenState]);
								
								// Si on n'est plus en plein écran
								if (!fullScreenState)
								{
									// On met la vidéo en pause
									media.pause();
								}
							}
						}, 300);
					}
				}
				
				/**
				 * Créer l'objet vidéo
				 */
				function createVideoElement ()
				{
					// Si on a déjà un objet video
					if (media != null)
					{
						// On n'écoute plus les events
						media.removeEventListener("abort", 			mediaEvent);
						media.removeEventListener("suspend", 		mediaEvent);
						media.removeEventListener("canplaythrough",	mediaEvent);
						media.removeEventListener("emptied", 		mediaEvent);
						media.removeEventListener("stalled", 		mediaEvent);
						media.removeEventListener("error", 			mediaEvent);
						media.removeEventListener("canplay", 		mediaEvent);
						media.removeEventListener("ended", 			mediaEvent);
						
						// On le vire de la DOM
						body.removeChild(media);
						media = null;
					}
					
					// Si on a un lien pour la vidéo
					if (mediaURL != "")
					{
						// Créer l'objet vidéo
						media = document.createElement("video");
						
						// Ecouter les events media
						media.addEventListener("abort", 			mediaEvent);
						media.addEventListener("suspend", 			mediaEvent);
						media.addEventListener("canplaythrough",	mediaEvent);
						media.addEventListener("emptied", 			mediaEvent);
						media.addEventListener("stalled", 			mediaEvent);
						media.addEventListener("error", 			mediaEvent);
						media.addEventListener("canplay", 			mediaEvent);
						media.addEventListener("ended", 			mediaEvent);
						
						// Définir son ID
						media.setAttribute("id", "media");
						
						// Si on doit charger automatiquement
						if (autoLoad)
							media.setAttribute("preload", "preload");
						
						// Si on doit afficher les contrôles
						media.setAttribute("controls", "controls");
						
						// Appliquer l'URL de la vidéo
						media.setAttribute("src", mediaURL);
						
						// Ajouter à la DOM
						body.appendChild(media);
						
						// Si on doit charger automatiquement
						if (autoLoad && "load" in media)
						{
							media.load();
						}
					}
				}
				
				/**
				 * Event media reçu
				 */
				function mediaEvent (event)
				{
					// Renvoyer le message
					sendMessage("mediaEvent", [event.type]);
					
					// Vérifier quel type d'event on a reçu
					if (event.type == "canplay")
					{
						// Envoyer le message
						sendMessage("mediaLoaded", []);
						
						// Le media est chargé
						mediaLoaded = true;
					}
					else if (event.type == "ended")
					{
						// Envoyer le message
						sendMessage("mediaEnded", [event.type]);
						
						// Quitter le plein écran
						media.webkitExitFullscreen();
					}
				}
				
				/**
				 * Lire la vidéo en cours
				 */
				function playCurrentVideo ()
				{
					// Si on a une vidéo
					if (media != null)
					{
						// On lance la lecture
						media.play();
						
						// Et le plein écran
						media.webkitEnterFullscreen();
					}
				}
			]]>.toString();
		}
		
		/**
		 * Joue une vidéo
		 * @param	pVideoURL : L'URL de la vidéo à charger
		 * @param	pAutoLoad : Charger automatiquement la vidéo (déclanchera un message "mediaLoaded")
		 * @param	pPosterURL : L'URL de l'image avant la lecture de la vidéo
		 */
		public function loadVideo (pVideoURL:String = "", pAutoLoad:Boolean = true, pPosterURL:String = ""):void 
		{
			// On stock les params
			_videoURL = pVideoURL;
			_autoLoad = pAutoLoad;
			_posterURL = pPosterURL;
			
			// Charger la vidéo si le player est prêt
			if (_ready)
			{
				callJavascript("loadVid", [_videoURL, _autoLoad, _posterURL]);
			}
		}
		
		/**
		 * Lire la vidéo en cours
		 */
		public function playerCurrentVideo ():void
		{
			// Si le player est prêt
			if (_ready)
			{
				// On appel la fonction javascript
				callJavascript("playCurrentVideo", []);
			}
		}
		
		/**
		 * Le player est chargé
		 */
		override protected function completeHandler (event:Event):void 
		{
			// Relayer
			super.completeHandler(event);
			
			// Si on a un vidéo en attente
			if (_videoURL != null)
			{
				// Charger la vidéo
				callJavascript("loadVid", [_videoURL, _autoLoad, _posterURL]);
			}
		}
	}
}