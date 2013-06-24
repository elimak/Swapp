package fr.swapp.graphic.tools
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.system.ImageDecodingPolicy;
	import flash.system.LoaderContext;
	import flash.utils.Dictionary;
	import fr.swapp.core.log.Log;
	import fr.swapp.core.roles.IDisposable;
	import fr.swapp.graphic.errors.GraphicalError;
	import fr.swapp.utils.EnvUtils;
	import fr.swapp.utils.StageUtils;
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	
	/**
	 * @author ZoulouX
	 */
	public class BitmapCache implements IDisposable
	{
		/**
		 * Associated BitmapCache to displayObject instances
		 */
		protected static const __instances					:Dictionary					= new Dictionary();
		
		
		/**
		 * Instanciate a bitmapCache a associate it to a displayObject.
		 * @param	pTarget : Associated displayObject. If null, mainStage will be used.
		 */
		public static function create (pTarget:DisplayObject = null):BitmapCache
		{
			// Si le clip cible est null
			if (pTarget == null && StageUtils.throwErrorIfMainStageNotDefined("BitmapCache.create"))
			{
				// Récupérer le mainStage
				pTarget = StageUtils.mainStage;
			}
			
			// Si l'instance de ce clip cible n'est pas déjà créée
			if (!(pTarget in __instances))
			{
				// Loguer l'ajout
				Log.core("BitmapCache.create", [pTarget]);
				
				// Créer l'instance
				__instances[pTarget] = new BitmapCache(new MultitonKey());
				
				// Ecouter lorsque le clip est supprimé du stage
				pTarget.addEventListener(Event.REMOVED_FROM_STAGE, associatedTargetRemovedFromStage);
			}
			
			// Retourner l'instance, qu'elle soit fraichement créée ou non
			return __instances[pTarget];
		}
		
		/**
		 * When associated displayObject is removed from stage.
		 */
		protected static function associatedTargetRemovedFromStage (event:Event):void 
		{
			// Ne plus écouter
			event.currentTarget.removeEventListener(Event.REMOVED_FROM_STAGE, associatedTargetRemovedFromStage);
			
			// Détruire le bitmapCache associé
			destroy(event.currentTarget as DisplayObject);
		}
		
		/**
		 * Distroy a bitmapCache instance.
		 * @param	pTarget : The displayObject target associated. If null, mainStage, will be used.
		 */
		public static function destroy (pTarget:DisplayObject = null):void
		{
			// Si le clip cible est null
			if (pTarget == null && StageUtils.throwErrorIfMainStageNotDefined("BitmapCache.destroy"))
			{
				// Récupérer le mainStage
				pTarget = StageUtils.mainStage;
			}
			
			// Si l'instance de bitmapCache associée à ce clip existe
			if (__instances[pTarget] != null)
			{
				// Loguer l'ajout
				Log.core("BitmapCache.destroy", [pTarget]);
				
				// On le dispose
				IDisposable(__instances[pTarget]).dispose();
				
				// Virer l'instance du dico
				delete __instances[pTarget];
			}
			else
			{
				// Déclancher l'erreur
				throw new GraphicalError("BitmapCache.destroy", "Associated BitmapCache to this DisplayObject target was not found.");
			}
		}
		
		
		/**
		 * La liste des bitmaps stockés
		 */
		protected var _bitmaps							:Array 						= [];
		
		/**
		 * Le contexte de chargement des images
		 */
		protected var _loaderContext					:LoaderContext;
		
		/**
		 * Les loaders associés à leurs handlers
		 */
		protected var _loaders							:Dictionary					= new Dictionary();
		
		/**
		 * When disposed
		 */
		protected var _onDisposed						:Signal						= new Signal();
		
		
		/**
		 * Le contexte de chargement des images
		 */
		public function get loaderContext ():LoaderContext 
		{
			return _loaderContext;
		}
		
		/**
		 * When disposed
		 */
		public function get onDisposed ():ISignal { return _onDisposed; }
		
		
		/**
		 * Private constructor.
		 * Please use BitmapCache.getInstance to create a new instance of BitmapCache.
		 */
		public function BitmapCache (pMultitonKey:MultitonKey)
		{
			// Vérifier la clé pour la création multiton
			if (pMultitonKey == null)
			{
				// déclencher l'erreur singleton
				throw new GraphicalError("SWrapper.construct", "Direct instancation not allowed, please use SWrapper.getInstance instead.");
			}
			else
			{
				// Lancer le sous-constructeur
				construct();
			}
		}
		
		/**
		 * Sub-constructor
		 */
		protected function construct ():void
		{
			// Créer le contexte de chargement
			_loaderContext = new LoaderContext();
			
			// Décoder l'image avant de dispatcher le complete
			_loaderContext.imageDecodingPolicy = ImageDecodingPolicy.ON_LOAD;
			
			// Interdire l'exécution de scripts
			_loaderContext.allowCodeImport = false;
		}
		
		
		/**
		 * Load a BitmapData and keep it in cache.
		 * @param	pURL : L'URL de l'image a charger / récupérer
		 * @param	pSuccessHandler : Le callback appelé lorsque l'image est prête (avec le BitmapData en paramètre 0 et un boolean pour signaler si l'image vient du cache en paramètre 1)
		 * @param	pErrorHandler : Le callback appelé lorsque n'arrive pas à être chargée (avec une erreur passée en paramètre)
		 */
		public function load (pURL:String, pSuccessHandler:Function = null, pErrorHandler:Function = null):void
		{
			// Si on a un bitmap en cache sur cette URL
			if (_bitmaps[pURL] != null)
			{
				pSuccessHandler(_bitmaps[pURL], true);
				return;
			}
			
			// Créer le loader
			var loader:Loader = new Loader();
			
			// Ajouter ce loader au dico
			_loaders[loader] = {
				success: pSuccessHandler,
				error: pErrorHandler,
				url: pURL
			};
			
			// Ecouter les évènements sur le chargement
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, imageLoadEventHandler);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, imageLoadEventHandler);
			
			// Lancer le chargement avec l'URL et le contexte
			loader.load(new URLRequest(pURL), _loaderContext);
		}
		
		/**
		 * Event sur le loading des bitmaps
		 */
		protected function imageLoadEventHandler (event:Event):void
		{
			// Cibler le loaderInfo
			var loaderInfo:LoaderInfo = (event.currentTarget as LoaderInfo);
			
			// Si on a un loader
			if (loaderInfo.loader in _loaders)
			{
				// Si c'est une réussite
				if (event.type == Event.COMPLETE)
				{
					const url:String = _loaders[loaderInfo.loader].url;
					
					// Récupérer le bitmapData
					_bitmaps[url] = (loaderInfo.content as Bitmap).bitmapData;
					
					// Appeler le handler s'il existe
					if (_loaders[loaderInfo.loader].success != null)
						_loaders[loaderInfo.loader].success(_bitmaps[url], false);
				}
				else
				{
					// C'est une erreur
					// Appeler le handler s'il existe (et lui passer l'event)
					if (_loaders[loaderInfo.loader].error != null)
						_loaders[loaderInfo.loader].error(event);
				}
				
				// Supprimer ce loader du dico
				_loaders[_loaders] = null;
				delete _loaders[_loaders];
			}
		}
		
		/**
		 * Charger un BitmapData directement dans un Bitmap.
		 * Utiliser le BitmapData en cache si possible.
		 * @param	pURL : L'URL de l'image a charger / récupérer
		 * @param	pBitmapContainer : Le Bitmap sur lequel l'image sera chargée
		 * @param	pDisposeOldBitmapData : Si l'ancien bitmapData doit être vidé de la mémoire
		 */
		public function loadInto (pURL:String, pBitmapContainer:Object, pDisposeOldBitmapData:Boolean = false):void
		{
			// Charger l'image
			load(pURL, function (pBitmapData:BitmapData, pFromCache:Boolean):void
			{
				// L'image est chargée, la définir dans le bitmap
				if (pBitmapContainer != null && "bitmapData" in pBitmapContainer)
				{
					// Si on doit disposer l'ancien bitmapData et que ce bitmapData existe
					if (pDisposeOldBitmapData && pBitmapContainer.bitmapData != null && pBitmapContainer.bitmapData is BitmapData)
					{
						// On le dispose
						(pBitmapContainer.bitmapData as BitmapData).dispose();
					}
					
					// On applique le nouveau bitmapData
					pBitmapContainer.bitmapData = pBitmapData;
				}
			});
		}
		
		/**
		 * Vérifier si une clé a un BitmapData associé
		 * @param	pKey : La clé du BitmapData a vérifier
		 */
		public function check (pKey:String):Boolean
		{
			return _bitmaps[pKey] != null;
		}
		
		/**
		 * Enregistrer un BitmapData en cache
		 * @param	pKey : La clé pour enregistrer le BitmapData
		 * @param	pBitmapData : Le BitmapData qui va être mis en cache
		 */
		public function write (pKey:String, pBitmapData:BitmapData):void
		{
			_bitmaps[pKey] = pBitmapData;
		}
		
		/**
		 * Récupérer un BitmapData par rapport à une URL.
		 * Le BitmapData sera null s'il n'est pas en cache
		 */
		public function read (pKey:String):BitmapData
		{
			return check(pKey) ? _bitmaps[pKey] : null;
		}
		
		/**
		 * Vider tous les BitmapData sans les disposer.
		 * Attention aux fuites mémoire.
		 */
		public function clear ():void
		{
			// Vider le tableau
			_bitmaps = [];
		}
		
		/**
		 * Virer tous les bitmaps et les disposer.
		 * Attention : les BitmapData à l'écran deviendront noirs
		 */
		public function dispose ():void
		{
			// Parcourir le tableau
			for (var i:uint = 0, total = _bitmaps.length; i < total; i++)
			{
				// Dispose ce bitmapData
				(_bitmaps as BitmapData).dispose();
			}
			
			// Vider le tableau
			clear();
			
			// Signaler et supprimer
			_onDisposed.dispatch();
			_onDisposed.removeAll();
			_onDisposed = null;
		}
	}
}

/**
 * Private key to secure multiton providing.
 */
internal class MultitonKey {}