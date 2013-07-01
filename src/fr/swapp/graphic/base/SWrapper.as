package fr.swapp.graphic.base
{
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageAspectRatio;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.utils.Dictionary;
	import fr.swapp.core.log.Log;
	import fr.swapp.core.roles.IDisposable;
	import fr.swapp.core.roles.IReadyable;
	import fr.swapp.graphic.errors.GraphicalError;
	import fr.swapp.graphic.styles.StyleCentral;
	import fr.swapp.utils.DisplayObjectUtils;
	import fr.swapp.utils.EnvUtils;
	import fr.swapp.utils.StageUtils;
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	
	/**
	 * Gives root to component flow.
	 * Give style to all components.
	 * Set ratio on all devices.
	 * Compatible with Flash and Air runtime.
	 * @author ZoulouX
	 */
	public class SWrapper implements IDisposable, IReadyable
	{
		/**
		 * Default ratio round slices
		 */
		public static const DEFAULT_RATIO_ROUND_SLICES	:uint					= 6;
		
		/**
		 * SWrapper instances
		 */
		protected static var __instances				:Dictionary				= new Dictionary(false);
		
		
		/**
		 * Get an instance of SWrapper.
		 * Instances are associated to given stages.
		 * @param	pStage : The native associated stage instance from the document class. If stage is null, MainStage will be used.
		 * @param	pAutoRatio : Use auto ratio scaling (only if this is the first getInstance for this stage)
		 * @param	pRatioRoundSlices : Used to round the computed ratio (for exemple 1.85431 can be rounded to 1.8, NaN to Ignore.)
		 * @param	pMinWidth : Minimum stage width. Ratio will be changed if the screen is too small. NaN to ignore.
		 * @param	pMinHeight : Minimum stage height. Ratio will be changed if the screen is too small. NaN to ignore.
		 * @param	pDefaultAspectRatio : Default aspect ratio. Use StageAspectRatio statics. (Only available on Air runtime)
		 * @return : SWrapper instance from given stage
		 */
		public static function getInstance (
												pStage						:Stage		= null,
												pAutoRatio					:Boolean 	= true,
												pRatioRoundSlices			:Number 	= NaN,
												pMinWidth					:Number 	= NaN,
												pMinHeight					:Number 	= NaN,
												pDefaultAspectRatio			:String		= "any"
											):SWrapper
		{
			// Vérifier la validité du stage
			if (pStage == null)
			{
				// Vérifier si on a l'instance du mainStage
				if (StageUtils.throwErrorIfMainStageNotDefined("SWrapper.getInstance"))
				{
					// On récupère le main stage en cas de problème
					pStage = StageUtils.mainStage;
				}
			}
			
			// Si on n'a pas d'instance
			if (!(pStage in __instances))
			{
				// On créé l'instance avec la clé et on stoque dans le dico
				new SWrapper(new MultitonKey(), pStage, pAutoRatio, pRatioRoundSlices, pMinWidth, pMinHeight, pDefaultAspectRatio);
			}
			
			// Retourner l'instance
			return __instances[pStage];
		}
		
		
		/**
		 * Associated stage
		 */
		protected var _stage							:Stage;
		
		/**
		 * Component Root
		 */
		protected var _root								:SComponent;
		
		/**
		 * Style manager
		 */
		protected var _styleCentral						:StyleCentral;
		
		
		/**
		 * If the wrapper is ready
		 */
		protected var _ready							:Boolean					= false;
		
		/**
		 * When the wrapper is ready
		 */
		protected var _onReady							:Signal						= new Signal();
		
		/**
		 * When disposed
		 */
		protected var _onDisposed						:Signal;
		
		/**
		 * Total resize event fired to get the real size
		 */
		protected var _resizeFired						:uint						= 0;
		
		/**
		 * If we are on air runtime
		 */
		protected var _isAirRuntime						:Boolean;
		
		
		/**
		 * If auto ratio is enabled
		 */
		protected var _autoRatio						:Boolean;
		
		/**
		 * Current stage ratio (if autoRatio is true, default is 1)
		 */
		protected var _ratio							:Number						= 1;
		
		/**
		 * Ratio round slices
		 */
		protected var _ratioRoundSlices					:Number;
		
		/**
		 * Minimum root width
		 */
		protected var _minWidth							:Number;
		
		/**
		 * Minimum root height
		 */
		protected var _minHeight						:Number;
		
		/**
		 * All aspect ratios registered
		 */
		protected var _aspectRatios						:Vector.<String>			= new Vector.<String>;
		
		
		/**
		 * Associated stage
		 */
		public function get stage ():Stage { return _stage; }
		
		/**
		 * The root component
		 */
		public function get root ():SComponent { return _root; }
		
		/**
		 * Style manager
		 */
		public function get styleCentral ():StyleCentral { return _styleCentral; }
		
		/**
		 * If auto ratio is enabled
		 */
		public function get autoRatio ():Boolean { return _autoRatio; }
		
		/**
		 * Current stage ratio (if autoRatio is true, default is 1)
		 */
		public function get ratio ():Number { return _ratio; }
		
		
		/**
		 * If the wrapper is ready
		 */
		public function get ready ():Boolean { return _ready; }
		
		/**
		 * When the wrapper is ready
		 */
		public function get onReady ():ISignal { return _onReady; }
		
		/**
		 * When disposed
		 */
		public function get onDisposed ():ISignal { return _onDisposed; }
		
		
		/**
		 * Minimum root width
		 */
		public function get minWidth ():Number { return _minWidth; }
		public function set minWidth (value:Number):void
		{
			// Si la valeur est différente
			if (_minWidth != value)
			{
				// Enregistrer la valeur
				_minWidth = value;
				
				// Prendre en compte le changement
				updateRootSizeWithRatioAndMinSizes();
			}
		}
		
		/**
		 * Minimum root height
		 */
		public function get minHeight ():Number { return _minHeight; }
		public function set minHeight (value:Number):void
		{
			// Si la valeur est différente
			if (_minHeight != value)
			{
				// Enregistrer la valeur
				_minHeight = value;
				
				// Prendre en compte le changement
				updateRootSizeWithRatioAndMinSizes();
			}
		}
		
		
		
		/**
		 * Protected constructor.
		 * Please use SWrapper.getInstance to create a new instance of SWrapper.
		 */
		public function SWrapper (
									pMultitonKey		:MultitonKey, 
									pStage				:Stage,
									pAutoRatio			:Boolean,
									pRatioRoundSlices	:Number,
									pMinWidth			:Number,
									pMinHeight			:Number,
									pDefaultAspectRatio	:String
								)
		{
			// Vérifier la clé pour la création multiton
			if (pMultitonKey == null)
			{
				// déclencher l'erreur singleton
				throw new GraphicalError("SWrapper.construct", "Direct instancation not allowed, please use SWrapper.getInstance instead.");
			}
			else
			{
				// Relayer vers le sous-constructeur
				construct(pStage, pAutoRatio, pRatioRoundSlices, pMinWidth, pMinHeight, pDefaultAspectRatio);
			}
		}
		
		/**
		 * Sub constructor
		 */
		protected function construct (pStage:Stage, pAutoRatio:Boolean, pRatioRoundSlices:Number, pMinWidth:Number, pMinHeight:Number, pDefaultAspectRatio:String):void
		{
			// Enregistrer l'instance
			__instances[pStage] = this;
			
			// Vérifier si on est sur Air
			_isAirRuntime = EnvUtils.isRuntime(EnvUtils.AIR_RUNTIME);
			
			// Enregistrer le stage
			_stage = pStage;
			
			// Enregistrer les tailles min
			_minWidth = pMinWidth;
			_minHeight = pMinHeight;
			
			// Enregistrer l'arrondi pour le ratio
			_ratioRoundSlices = pRatioRoundSlices;
			
			// Si on est en ratio auto
			_autoRatio = pAutoRatio;
			
			// Créer la racine
			_root = new SComponent();
			
			// Le nom de la racine
			_root.name = "root";
			
			// Ne jamais redimensionner l'UI
			_stage.scaleMode = StageScaleMode.NO_SCALE;
			_stage.align = StageAlign.TOP_LEFT;
			
			// Qualité au minimum
			_stage.quality = StageQuality.LOW;
			
			// Initialiser le wrapper de DPI automatique
			initDPIWrapper();
			
			// Ecouter les redimentionnements
			_stage.addEventListener(Event.RESIZE, stageResizedHandler);
			
			// Si on n'est pas sur air
			if (!_isAirRuntime)
			{
				// On est prêt
				dispatchReady();
			}
			
			// Si on est sur desktop
			else if (EnvUtils.isDesktop())
			{
				// On skip une frame avant de démarrer
				DisplayObjectUtils.wait(_stage, 1, pushAspectRatio, [pDefaultAspectRatio, dispatchReady]);
			}
			else
			{
				// Sinon on ajoute l'orientation
				pushAspectRatio(pDefaultAspectRatio, dispatchReady);
			}
		}
		
		/**
		 * Initialize DPI wrapper (only if autoSize is true at construction)
		 * And set quality from devices type.
		 */
		protected function initDPIWrapper ():void
		{
			// Si on doit adapter
			if (_autoRatio)
			{
				// Récupérer le ratio et l'enregistrer
				_ratio = EnvUtils.getRatioForMainStage();
			}
		}
		
		/**
		 * Native stage is resized
		 */
		protected function stageResizedHandler (event:Event = null):void
		{
			_resizeFired ++;
			
			Log.notice("stageResizedHandler", _ready, _resizeFired, _stage.stageWidth, _stage.stageHeight);
			
			// Appliquer les dimensions
			updateRootSizeWithRatioAndMinSizes();
		}
		
		/**
		 * Set aspect ratio.
		 * To remove this aspect ratio restriction, use popAspectRatio
		 * @param	pNewAspectRatio : The new aspect ratio restriction
		 * @param	pHandler : Called when the new aspect ratio is fully setted
		 */
		public function pushAspectRatio (pNewAspectRatio:String, pHandler:Function = null):void
		{
			// Ajouter ce ratio
			_aspectRatios.push(pNewAspectRatio);
			
			// Si on est sur Air
			if (_isAirRuntime)
			{
				// Attendre pour le dispatch du handler
				waitHandlerDispatch(pNewAspectRatio, pHandler);
				
				// On actualise
				updateAspectRatio();
			}
			else
			{
				// On appel directement le handler
				if (pHandler != null)
					pHandler();
			}
		}
		
		/**
		 * Remove last aspect ratio restriction.
		 * @param	pHandler : Called when the new aspect ratio is fully setted
		 * @param	pDontRemoveLast : If false, this method can throw an error if there is no more aspectRatio to delete. At least one aspect ratio is mandatory.
		 * @return : the last aspect ratio restriction removed
		 */
		public function popAspectRatio (pHandler:Function = null, pDontRemoveLast:Boolean = true):String
		{
			// Si c'est le dernier
			if (_aspectRatios.length == 1)
			{
				// Si on ne doit pas virer le dernier
				if (!pDontRemoveLast)
				{
					// On déclanche une erreur
					throw new GraphicalError("SWrapper.popAspectRatio", "Can't delete last aspect ratio. Please pop only pushed aspect ratios.");
				}
				return null;
			}
			else
			{
				// Supprimer le dernier et le retourner
				var last:String =  _aspectRatios.pop();
				
				// Si on est sur Air
				if (_isAirRuntime)
				{
					// Attendre pour le dispatch du handler
					waitHandlerDispatch(last, pHandler);
					
					// On actualise
					updateAspectRatio();
				}
				else
				{
					// On appel directement le handler
					if (pHandler != null)
						pHandler();
				}
				
				// Retourner le ratio qui a été supprimé
				return last;
			}
		}
		
		/**
		 * Check if an aspect ratio is already setted.
		 * @param	pAspectRatio : The aspect ratio to check.
		 */
		protected function isAspectRatioSetted (pAspectRatio:String):Boolean
		{
			return (
				// Si on est sur du any et qu'on est pas sur un format carré
				(pAspectRatio == StageAspectRatio.ANY && _stage.stageWidth != _stage.stageHeight)
				||
				// Si on demande de du landscape et qu'on est déjà en landscape
				(pAspectRatio == StageAspectRatio.LANDSCAPE && _stage.stageWidth > _stage.stageHeight)
				||
				// Si on demande du portrait et qu'on est déjà en portrait
				(pAspectRatio == StageAspectRatio.PORTRAIT && _stage.stageWidth < _stage.stageHeight)
			);
		}
		
		/**
		 * Wait the orientation change to dispatch handler.
		 * Only for Air
		 */
		protected function waitHandlerDispatch (pNewAspectRatio:String, pHandler:Function):void
		{
			// Si on a un handler
			if (pHandler != null)
			{
				// Si on est sur le bon ratio
				if (isAspectRatioSetted(pNewAspectRatio))
				{
					// Appeler directement le handler
					pHandler();
				}
				
				// Sinon attendre qu'on tombe sur le bon ratio
				else
				{
					// Appelé à chaque resize pour vérifier que l'orientation est bien appliquée
					function checkStageResizedHandler (event:Event):void
					{
						Log.notice("- checkStageResizedHandler", _stage.stageWidth, _stage.stageHeight);
						
						// Si on est sur le bon ratio
						if (isAspectRatioSetted(pNewAspectRatio))
						{
							// On n'écoute plus
							_stage.removeEventListener(Event.RESIZE, checkStageResizedHandler);
							
							// Et on appel le handler
							pHandler();
						}
					}
					
					// Ecouter les resizes
					_stage.addEventListener(Event.RESIZE, checkStageResizedHandler);
				}
			}
		}
		
		/**
		 * Update aspect ratio from the last pushed aspect ratio.
		 * Call only on Air.0
		 */
		protected function updateAspectRatio ():void
		{
			// Appliquer le dernier ratio
			_stage["setAspectRatio"](_aspectRatios[_aspectRatios.length == 0 ? 0 : _aspectRatios.length - 1]);
		}
		
		/**
		 * Dispatch ready and setup root
		 */
		protected function dispatchReady ():void
		{
			// On est prêt
			_ready = true;
			
			// Actualiser le ratio et la taille du stage
			updateRootSizeWithRatioAndMinSizes();
			
			// Ajouter la racine
			_stage.addChild(_root);
			
			// Signaler qu'on est prêt
			_onReady.dispatch();
		}
		
		/**
		 * Compute the root size from ratio and min sizes.
		 * Will call updateRootSizeWidthRatio.
		 */
		protected function updateRootSizeWithRatioAndMinSizes ():void
		{
			// Actualiser la taille du stage selon les tailles minimum
			//updateRootSizeWithRatioAndMinSizes();
			
			// Si on a un ratio automatique
			if (_autoRatio && _ready)
			{
				// Définir la taille du root
				updateRootSizeWithRatio();
				
				// Si on a une largeur minimum
				if (_minWidth >= 0)
				{
					// Si on est en dessous la largeur minimum
					if (_root.width < _minWidth)
					{
						// On modifie le ratio
						_ratio = _stage.stageWidth / _minWidth;
						
						// Redéfinir la taille du root
						updateRootSizeWithRatio(false);
					}
				}
				
				// Si on a une hauteur minimum
				if (_minHeight >= 0)
				{
					// Si on est en dessous de la hauteur minimum
					if (_root.height < _minHeight)
					{
						// On modifie le ratio
						_ratio = _stage.stageHeight / _minHeight;
						
						// Redéfinir la taille du root
						updateRootSizeWithRatio(false);
					}
				}
			}
			else
			{
				// Définir la taille du root directement par rapport à la taille du stage
				_root.size(_stage.stageWidth, _stage.stageHeight);
			}
		}
		
		/**
		 * Update root size
		 */
		protected function updateRootSizeWithRatio (pRound:Boolean = true):void
		{
			// Arrondir le ratio
			if (pRound && _ratioRoundSlices > 0)
			{
				_ratio = Math.round(_ratio * _ratioRoundSlices) / _ratioRoundSlices;
			}
			
			// Appliquer le ratio
			_root.scaleX = _root.scaleY = _ratio;
			
			// Définir la taille par rapport au ratio
			_root.size(_stage.stageWidth / _ratio, _stage.stageHeight / _ratio);
		}
		
		
		
		/**
		 * Initialize style manager
		 */
		public function enableStyleCentral ():void
		{
			// Créer le centre de gestion des styles
			_styleCentral = new StyleCentral();
			
			// Ecouter lorsque le style change et invalider le style du stage pour actualiser en cascade
			_styleCentral.onStyleChanged.add(_root.invalidateStyle);
			
			// Activer les styles sur ce container
			_root.styleEnabled = true;
		}
		
		/**
		 * Set the minimum size for the root.
		 * @param	pMinWidth : Minimum stage width. Ratio will be changed if the screen is too small. NaN to ignore.
		 * @param	pMinHeight : Minimum stage height. Ratio will be changed if the screen is too small. NaN to ignore.
		 */
		public function setMinSize (pMinWidth:Number = NaN, pMinHeight:Number = NaN):void
		{
			// Enregistrer les valeurs
			_minWidth = pMinWidth;
			_minHeight = pMinHeight;
			
			// Prendre en compte le changement
			updateRootSizeWithRatioAndMinSizes();
		}
		
		/**
		 * Dispose this instance of SWrapper
		 */
		public function dispose ():void
		{
			// Virer la racine
			_stage.removeChild(_root);
			
			// Disposer la racine
			_root.dispose();
			
			// Ne plus écouter les resizes
			_stage.removeEventListener(Event.RESIZE, stageResizedHandler);
			
			// Disposer le styleCentral
			if (_styleCentral != null)
			{
				_styleCentral.dispose();
			}
			
			// Virer l'instance du dico
			delete __instances[_stage];
			__instances[_stage] = null;
			
			// Tout passer à null
			_stage = null;
			_root = null;
			_styleCentral = null;
			
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