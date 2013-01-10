package fr.swapp.graphic.components.medias 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.LocationChangeEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.StageWebView;
	import fr.swapp.core.log.Log;
	import fr.swapp.core.roles.IReadyable;
	import fr.swapp.graphic.base.ResizableComponent;
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	
	/**
	 * ...
	 * @author ZoulouX
	 */
	public class WebViewContainer extends ResizableComponent implements IReadyable
	{
		/**
		 * Le StageWebView
		 */
		protected var _stageWebView				:StageWebView;
		
		/**
		 * Le style CSS additionnel
		 */
		protected var _additionalStyle			:String					= "";
		
		/**
		 * Le script Javascript additionnel
		 */
		protected var _additionalScript			:String					= "";
		
		/**
		 * Structure HTML additionnelle
		 */
		protected var _additionalStruct			:String					= "";
		
		/**
		 * Lorsque la webview est chargée
		 */
		protected var _onReady					:Signal					= new Signal();
		
		/**
		 * Si la webview est prête
		 */
		protected var _ready					:Boolean				= false;
		
		/**
		 * Lorsque l'HTML envoie un message
		 */
		protected var _onMessage				:Signal					= new Signal(String, Array);
		
		
		/**
		 * La structure HTML5
		 */
		protected var _htmlStruct				:XML 					= <root>
			<part1><![CDATA[<!doctype html>
					<html>
						<head>
							<meta charset="utf-8" />
							<meta name="viewport" content="initial-scale=1.0, user-scalable=no">
							<style type="text/css">
								* {
									margin: 0;
									padding: 0;
								}
								html, body {
									position: absolute;
									top: 0;
									right: 0;
									bottom: 0;
									left: 0;
									overflow: hidden;
								}
				]]></part1>
			<part2><![CDATA[
							</style>
							<script type="text/javascript">
								// Le body
								var body;
								
								/**
								 * Bloquer les mouvements
								 */
								function preventMove (event)
								{
									event.preventDefault();
								}
								
								/**
								 * Construire la base de la vue HTML
								 */
								function construct ()
								{
									// Cibler le body
									body = document.getElementsByTagName("body")[0];
									
									// Bloquer les mouvements sur le body
									body.addEventListener("touchstart", preventMove);
									body.addEventListener("touchmove", preventMove);
									
									// Initialiser
									if ("init" in window)
										init();
								}
								
								/**
								 * Envoyer un message à la WebView
								 * @param	pMessageName : Le nom du message (String)
								 * @param	pMessageParams : Les paramètres du message (Array)
								 */
								function sendMessage (pMessageName, pMessageParams)
								{
									// Construire l'URL avec les paramètres
									var params = "";
									var totalParams = pMessageParams.length;
									for (var i = 0; i < totalParams; i++ )
									{
										params += typeof(pMessageParams[i]) + "," + encodeURIComponent(encodeURIComponent(pMessageParams[i])) + "//";
									}
									
									// Changer l'URL avec un prefix particulier pour que la webview puisse l'intercepter
									window.location = "http://webviewmessage//" + encodeURIComponent(pMessageName) + "//" + params;
								}
				]]></part2>
			<part3><![CDATA[
							</script>
						</head>
						<body onload="construct()">
				]]></part3>
			<part4><![CDATA[
						</body>
					</html>
				]]></part4>
		</root>;
		
		/**
		 * Afficher la webview en bitmap
		 */
		protected var _rasterize				:Boolean				= false;
		
		/**
		 * Si on doit convertir le champ texte en bitmap automatiquement (lorsqu'il n'est pas focus)
		 */
		protected var _autoRasterize			:Boolean;
		
		/**
		 * Le bitmap qui va servire à raterize
		 */
		protected var _rasterizeBitmap			:Bitmap;
		
		/**
		 * Autoriser les changements de page
		 */
		protected var _allowLocationChange		:Boolean				= true;
		
		/**
		 * Les noms des messages et leurs handlers
		 */
		protected var _messageHandlers			:Array					= [];
		
		/**
		 * Utiliser l'HTML interne
		 */
		protected var _useInternalStructure		:Boolean				= true;
		
		/**
		 * Bloquer les drag and drop sur l'HTML de la structure
		 */
		protected var _preventMoveOnStructure	:Boolean				= true;
		
		
		/**
		 * Le style CSS additionnel
		 */
		public function get additionalStyle ():String { return _additionalStyle; }
		public function set additionalStyle (value:String):void 
		{
			_additionalStyle = value;
		}
		
		/**
		 * Le script Javascript additionnel
		 */
		public function get additionalScript ():String { return _additionalScript; }
		public function set additionalScript (value:String):void 
		{
			_additionalScript = value;
		}
		
		/**
		 * Structure HTML additionnelle
		 */
		public function get additionalStruct ():String { return _additionalStruct; }
		public function set additionalStruct (value:String):void 
		{
			_additionalStruct = value;
		}
		
		/**
		 * Afficher / masquer la vidéo
		 */
		override public function get visible ():Boolean { return super.visible; }
		override public function set visible (value:Boolean):void
		{
			super.visible = value;
			
			refreshPosition();
		}
		
		/**
		 * Le stageWebView
		 */
		public function get stageWebView ():StageWebView { return _stageWebView; }
		
		/**
		 * Lorsque la webview est chargée
		 */
		public function get onReady ():ISignal { return _onReady; }
		
		/**
		 * Si la webview est prête
		 */
		public function get ready ():Boolean { return _ready; }
		
		/**
		 * Lorsque l'HTML envoie un message [String, Array]
		 */
		public function get onMessage ():Signal { return _onMessage; }
		
		/**
		 * Afficher la webview en bitmap
		 */
		public function get rasterize ():Boolean { return _rasterize; }
		public function set rasterize (value:Boolean):void
		{
			// Enregistrer
			_rasterize = value;
			
			// Si on passe en mode rasterize
			if (_rasterize)
			{
				// On créé le bitmap porteur, son bitmapData à la taille de la webview
				_rasterizeBitmap = new Bitmap();
				
				// Actualiser le raster
				updateRaster();
				
				// On ajoute le bitmap porteur
				addChild(_rasterizeBitmap);
			}
			else
			{
				// On supprime le bitmap porteur et son bitmapData
				removeChild(_rasterizeBitmap);
				_rasterizeBitmap.bitmapData.dispose();
				_rasterizeBitmap = null;
			}
			
			// Actualiser
			refreshPosition();
		}
		
		/**
		 * Si on doit convertir le champ texte en bitmap automatiquement (lorsqu'il n'est pas focus)
		 */
		public function get autoRasterize ():Boolean { return _autoRasterize; }
		public function set autoRasterize (value:Boolean):void
		{
			// Enregistrer
			_autoRasterize = value;
			
			// Passer en rasterize si on est en auto
			rasterize = _autoRasterize;
			
			// Actualiser le rendu bitmap
			updateRaster();
		}
		
		/**
		 * Autoriser les changements de page
		 */
		public function get allowLocationChange ():Boolean { return _allowLocationChange; }
		public function set allowLocationChange (value:Boolean):void
		{
			_allowLocationChange = value;
		}
		
		/**
		 * Utiliser l'HTML interne
		 */
		public function get useInternalStructure():Boolean { return _useInternalStructure; }
		
		/**
		 * Bloquer les drag and drop sur l'HTML de la structure
		 */
		public function get preventMoveOnStructure ():Boolean { return _preventMoveOnStructure; }
		public function set preventMoveOnStructure (value:Boolean):void
		{
			_preventMoveOnStructure = value;
			
			// TODO: Le preventMoveOnStructure n'a pas d'effet sur l'HTML
		}
		
		
		/**
		 * Le constructeur
		 * @param	pUseInternalStructure : Utiliser l'HTML interne
		 */
		public function WebViewContainer (pUseInternalStructure:Boolean = true)
		{
			// Activer les styles
			_styleEnabled = true;
			
			// Enregistrer
			_useInternalStructure = pUseInternalStructure;
		}
		
		
		/**
		 * Initialisation
		 */
		override public function init ():void
		{
			// Construire la webview
			buildStageWebView();
			
			// Charger la structure
			if (_useInternalStructure)
				updateStructure();
			
			// Ecouter lorsque le stage change de taille
			stage.addEventListener(Event.RESIZE, stageResizedHandler);
		}
		
		/**
		 * Le stage a changé de taille
		 */
		protected function stageResizedHandler (event:Event):void
		{
			// Replacer
			refreshPosition();
		}
		
		/**
		 * Actualiser la structure
		 */
		public function updateStructure ():void
		{
			// Charger la structure
			_stageWebView.loadString(compileHTML());
		}
		
		/**
		 * Créer le stageWebView.
		 */
		protected function buildStageWebView ():void 
		{
			// Créer la vue
			_stageWebView = new StageWebView();
			
			// On écoute
			_stageWebView.addEventListener(Event.COMPLETE, completeHandler);
			_stageWebView.addEventListener(LocationChangeEvent.LOCATION_CHANGE, locationChangeHandler);
			_stageWebView.addEventListener(LocationChangeEvent.LOCATION_CHANGING, locationChangingHandler);
			_stageWebView.addEventListener(ErrorEvent.ERROR, errorHandler);
			
			_stageWebView.addEventListener(FocusEvent.FOCUS_IN, stageWebViewHandler);
			_stageWebView.addEventListener(FocusEvent.FOCUS_OUT, stageWebViewHandler);
			
			// Ecouter les clics sur ce composant
			addEventListener(MouseEvent.MOUSE_DOWN, clickHandler);
			
			// Le placer
			refreshPosition();
			
			// On le configure
			_stageWebView.stage = stage;
		}
		
		/**
		 * Clic sur ce composant
		 */
		protected function clickHandler (event:MouseEvent):void 
		{
			// Si on est en autorasterize et qu'on est en mode bitmap
			if (_autoRasterize && _rasterize)
			{
				// On désactive le mode bitmap
				rasterize = false;
				
				// Et on assigne le focus à la webView
				_stageWebView.assignFocus();
			}
		}
		
		/**
		 * Evènement d'intération sur la stageWebVoew
		 */
		protected function stageWebViewHandler (event:Event):void 
		{
			// Si c'est une sortie de focus est qu'on est en autoRasterize
			if (event.type == FocusEvent.FOCUS_OUT && _autoRasterize)
			{
				// On active le mode de rendu bitmap
				rasterize = true;
			}
			
			// Relayer tous les events
			// Attentions, ces events ne bubble pas à travers la displayList, il faut écouter directement cet objet
			dispatchEvent(event);
		}
		
		/**
		 * Compiler l'HTML
		 */
		protected function compileHTML ():String
		{
			return _htmlStruct.part1 + _additionalStyle + _htmlStruct.part2 + _additionalScript + _htmlStruct.part3 + _additionalStruct + _htmlStruct.part4;
		}
		
		/**
		 * Ajouter un callback pour un message. Un seul callback par message.
		 * Pour plusieurs callback par message, utiliser le signal onMessage
		 * @param	pMessageName : Le nom du message surlequel appeler le handler
		 * @param	pHandler : Le handler à appeler à la récéption du message
		 */
		public function registerMessage (pMessageName:String, pHandler:Function):void
		{
			// Enregistrer
			_messageHandlers[pMessageName] = pHandler;
		}
		
		/**
		 * Supprimer un callBack d'un message.
		 * @param	pMessageName : Le nom du message surlequel appeler le handler
		 */
		public function unregisterMessage (pMessageName:String):void
		{
			// Détruire
			delete _messageHandlers[pMessageName];
		}
		
		/**
		 * Appeler une méthode JS sur le stageWebView
		 */
		public function callJavascript (pFunctionName:String, pParams:Array = null):void
		{
			if (pParams == null)
				pParams = [];
			
			// Ouverture de la fonction
			var functionCall:String = "javascript:" + pFunctionName + "(";
			
			// Ajouter tous les paramètres
			const total:uint = pParams.length;
			for (var i:uint = 0; i < total; i++)
			{
				if (typeof(pParams[i]) == "string")
					functionCall += '"' + (pParams[i].replace(/"/g, '\\"')) + '"';
				else
					functionCall += (pParams[i]);
				
				if (i != total -1)
					functionCall += ", ";
			}
			
			// Fermeture
			functionCall += ")";
			
			// Appeler la fonction sur le player
			_stageWebView.loadURL(functionCall);
		}
		
		/**
		 * Le composant est replacé
		 */
		override protected function replaced ():void
		{
			// Replacer la webview
			needReplace();
		}
		
		/**
		 * Besoin de rafraichir la position
		 */
		override protected function needReplace ():void 
		{
			// Relayer
			super.needReplace();
			
			// Réappliquer au stageWebView
			refreshPosition();
			
			// Si on est en autoRasterize
			if (_autoRasterize)
			{
				// On rasterize
				updateRaster();
			}
		}
		
		/**
		 * Actualiser le bitmap du raster
		 */
		public function updateRaster ():void
		{
			// Si on est en mode de rendu bitmap
			if (_rasterize && _stageWebView != null)
			{
				// Vérifier si la taille a changé ou si on n'a pas de bitmapData
				if (_rasterizeBitmap.bitmapData == null || _rasterizeBitmap.bitmapData.width != _stageWebView.viewPort.width || _rasterizeBitmap.bitmapData.height != _stageWebView.viewPort.height)
				{
					// Virer l'ancien bitmapData si besoin
					if (_rasterizeBitmap.bitmapData != null)
						_rasterizeBitmap.bitmapData.dispose();
					
					// Actualiser le bitmapData
					_rasterizeBitmap.bitmapData = new BitmapData(_stageWebView.viewPort.width, _stageWebView.viewPort.height, false);
				}
				
				// Dessiner la webview dans le bitmapData
				_stageWebView.drawViewPortToBitmapData(_rasterizeBitmap.bitmapData);
				
				// Appliquer la taille au bitmap
				_rasterizeBitmap.width = _localWidth;
				_rasterizeBitmap.height = _localHeight;
			}
		}
		
		
		/**
		 * Actualiser les positions / dimensions du stageWebView
		 */
		public function refreshPosition ():void 
		{
			// Si on a un stageWebView
			if (_stageWebView != null && _localWidth > 0 && _localHeight > 0 && wrapper != null)
			{
				// Récupérer le ratio du stage
				var ratio:Number = wrapper.ratio;
				
				// Si cette webview est visible
				if (super.visible && !_rasterize && _ready)
				{
					// Récupérer le point de référence de la position de notre clip
					var registerPoint:Point = new Point();
					registerPoint = localToGlobal(registerPoint);
					
					// On lui applique un viewPort
					_stageWebView.viewPort = new Rectangle(
						registerPoint.x,
						registerPoint.y,
						_localWidth * ratio,
						_localHeight * ratio
					);
				}
				else
				{
					// Sinon on sort simplement la vue de la zone visible
					_stageWebView.viewPort = new Rectangle(
						- _localWidth * ratio - 1,
						- _localHeight * ratio - 1,
						_localWidth * ratio,
						_localHeight * ratio
					);
				}
			}
		}
		
		/**
		 * Le chargement du StageWebView est terminé.
		 */
		protected function completeHandler (event:Event):void 
		{
			if (!_ready)
			{
				Log.notice("WebViewContainer.completeHandler");
				
				// Signaler que c'est prêt
				_ready = true;
				_onReady.dispatch();
				
				// Afficher
				refreshPosition();
			}
		}
		
		/**
		 * Un changement de location va s'opérer
		 */
		protected function locationChangingHandler (event:LocationChangeEvent):void 
		{
			Log.notice("WebViewContainer.locationChangingHandler " + event.location);
			
			// Couper la location sur les //
			var locationSplit:Array = event.location.split("//");
			
			// Si c'est un message
			if (locationSplit[0] == "http:" && locationSplit[1] == "webviewmessage")
			{
				// Les paramètres
				var params:Array = [];
				
				// Parser les paramètres
				var sepIndex:int;
				var type:String;
				var value:String;
				var totalParams:int = locationSplit.length - 1;
				for (var i:int = 3; i < totalParams; i ++)
				{
					// Récupérer la séparation
					sepIndex = locationSplit[i].indexOf(",");
					
					// Récupérer le type et la valeur
					type = locationSplit[i].substr(0, sepIndex);
					value = decodeURIComponent(decodeURIComponent(locationSplit[i].substr(sepIndex + 1, locationSplit[i].length - sepIndex)));
					
					// Parser les paramètres
					if (type == "number")
					{
						params.push(parseFloat(value));
					}
					else if (type == "boolean")
					{
						params.push(value == "true");
					}
					else if (type == "string")
					{
						params.push(value);
					}
					else
					{
						Log.warning("WebViewContainer.locationChangingHandler unallowed params type in message.");
					}
				}
				
				// Dispatcher le message
				dispatchMessage(unescape(locationSplit[2]), params);
				
				// Annuler
				event.preventDefault();
			}
			
			// Si on n'autorise pas les changements d'adresse
			if (!_allowLocationChange)
			{
				Log.notice("WebViewContainer.locationChangingHandler Location change prevented.");
				
				// Annuler
				event.preventDefault();
			}
		}
		
		/**
		 * Dispatcher un message reçu depuis la webview
		 * @param	messageName : Le nom du message
		 * @param	params : Les paramètres associées
		 */
		protected function dispatchMessage (messageName:String, params:Array):void
		{
			// Dispatcher
			_onMessage.dispatch(messageName, params);
			
			// Si on a un handler associé
			if (messageName in _messageHandlers)
			{
				// Appeler le handler
				(_messageHandlers[messageName] as Function).apply(null, params);
			}
		}
		
		/**
		 * Le Location du StageWebView change
		 */
		protected function locationChangeHandler (event:LocationChangeEvent):void 
		{
			Log.notice("WebViewContainer.locationChangeHandler");
		}
		
		/**
		 * Il y a une erreur dans le StageWebView
		 */
		protected function errorHandler (event:ErrorEvent):void 
		{
			Log.error("WebViewContainer.errorHandler " + event.toString());
		}
		
		/**
		 * Destruction
		 */
		override public function dispose ():void
		{
			// Si on a un stageWebView
			if (_stageWebView != null)
			{
				// On vire l'écoute
				_stageWebView.removeEventListener(Event.COMPLETE, completeHandler);
				_stageWebView.removeEventListener(ErrorEvent.ERROR, errorHandler);
				_stageWebView.removeEventListener(LocationChangeEvent.LOCATION_CHANGE, locationChangeHandler);
				_stageWebView.removeEventListener(LocationChangeEvent.LOCATION_CHANGING, locationChangingHandler);
				
				_stageWebView.removeEventListener(FocusEvent.FOCUS_IN, stageWebViewHandler);
				_stageWebView.removeEventListener(FocusEvent.FOCUS_OUT, stageWebViewHandler);
				
				_stageWebView.stage.removeEventListener(Event.RESIZE, stageResizedHandler);
				
				// On le supprime
				_stageWebView.viewPort = null;
				_stageWebView.stage = null;
				_stageWebView.dispose();
				_stageWebView = null;
			}
			
			_messageHandlers = null;
			
			removeEventListener(MouseEvent.MOUSE_DOWN, clickHandler);
			
			// Relayer
			super.dispose();
		}
	}
}