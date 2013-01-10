package fr.swapp.core.entries 
{
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.system.Capabilities;
	
	/**
	 * @author ZoulouX
	 */
	public class Preloader extends MovieClip
	{
		/**
		 * Le chargeur
		 */
		protected var _loader				:Loader
		
		/**
		 * Les variables du loader
		 */
		protected var _variables			:URLVariables;
		
		/**
		 * Le nom du fichier à charger
		 */
		protected var _swfToLoad			:String;
		
		/**
		 * Récupérer le ratio de chargement
		 */
		public function get progress ():Number
		{
			return _loader.contentLoaderInfo.bytesLoaded / _loader.contentLoaderInfo.bytesTotal;
		}
		
		/**
		 * Le constructeur
		 */
		public function Preloader (pURL:String = "")
		{
			// L'adresse du SWF à charger
			_swfToLoad = pURL;
			
			// Attendre l'ajout au stage
			if (stage == null)
				addEventListener(Event.ADDED_TO_STAGE, initHandler);
			else
				initHandler();
		}
		
		/**
		 * Prêt
		 */
		public function initHandler (event:Event = null):void
		{
			// Ne plus écouter l'ajout
			if (event != null)
				removeEventListener(Event.ADDED_TO_STAGE, initHandler);
			
			// Charger automatiquement
			if (_swfToLoad != "")
			{
				load(_swfToLoad);
			}
			
			// Initialiser
			init();
			
			// Ecouter les redimensionnement du stage
			stage.addEventListener(Event.RESIZE, resizeHandler);
			
			// Placer au moins une fois
			resizeHandler();
		}
		
		/**
		 * Redimensionnement du stage
		 */
		protected function resizeHandler (event:Event = null):void
		{
			resized();
		}
		
		/**
		 * Démarrer le chargement
		 */
		public function load (pURL:String):void
		{
			// Créer le loader
			_loader = new Loader();
			
			// Les variables envoyées
			_variables = new URLVariables();
			
			// Parcourir les variables
			for (var i:String in loaderInfo.parameters)
			{
				// Ajouter chaque variable reçues pour les transmettre au flash chargé
				_variables[i] = loaderInfo.parameters[i];
			}
			
			// Ajouté une propriété noCache aléatoire pour éviter le cache
			if (loaderInfo.parameters.cache == null || loaderInfo.parameters.cache == "true")
				_variables["noCache"] = uint(Math.random() * 100000000).toString(10);
			
			// Signaler qu'on est passé par un loader
			_variables["fromLoader"] = "true";
			
			// Si on est pas en local, on ajoute les variables
			if (Capabilities.playerType != "StandAlone" && Capabilities.playerType != "External")
				pURL += "?" + _variables.toString();
			
			// Virer les // au début
			if (pURL.indexOf("//") == 0)
			{
				// Corriger
				pURL = pURL.substr(1, pURL.length - 1);
			}
			
			trace("LOADING", pURL);
			
			// Créer la requête
			var urlRequest:URLRequest = new URLRequest(pURL);
			
			// Lancer le chargement
			_loader.load(urlRequest);
			
			// Ecouter ce qu'il se passe
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadEndHandler);
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loadEndHandler);
			
			// La boucle
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		/**
		 * Boucle de chargement
		 */
		protected function enterFrameHandler (event:Event):void
		{
			loop();
		}
		
		/**
		 * Fin du chargement
		 */
		protected function loadEndHandler (event:Event):void
		{
			// Vérifier si c'est réussi
			if (event is IOErrorEvent)
			{
				// Erreur
				error();
			}
			else if (event.type == Event.COMPLETE)
			{
				// Réussite
				success();
			}
			
			// Ne plus écouter
			dispose();
		}
		
		/**
		 * Initialisation du chargement
		 */
		public function init ():void
		{
			
		}
		
		/**
		 * La boucle
		 */
		public function loop ():void
		{
			
		}
		
		/**
		 * Fin du chargement
		 */
		public function success ():void
		{
			
		}
		
		/**
		 * Echec du chargement
		 */
		public function error ():void
		{
			
		}
		
		/**
		 * Redimensionnement du stage
		 */
		public function resized ():void
		{
			
		}
		
		
		/**
		 * Afficher le contenu
		 */
		public function showContent (pIndex:int = -1):void
		{
			gotoAndStop("loaded");
			
			if (pIndex == -1)
				stage.addChild(_loader.content);
			else
				stage.addChildAt(_loader.content, pIndex);
			
			// Ne plus écouter les redimensionnement du stage
			stage.removeEventListener(Event.RESIZE, resizeHandler);
		}
		
		/**
		 * Tuer le loader
		 */
		public function dispose ():void
		{
			_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, loadEndHandler);
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loadEndHandler);
			removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
	}
}