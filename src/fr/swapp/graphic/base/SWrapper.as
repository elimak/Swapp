package fr.swapp.graphic.base
{
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.utils.Dictionary;
	import fr.swapp.core.roles.IDisposable;
	import fr.swapp.graphic.errors.GraphicalError;
	import fr.swapp.graphic.styles.StyleCentral;
	import fr.swapp.touch.dispatcher.TouchDispatcher;
	import fr.swapp.touch.emulator.MouseToTouchEmulator;
	import fr.swapp.utils.EnvUtils;
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	
	/**
	 * @author ZoulouX
	 */
	public class SWrapper implements IDisposable
	{
		/**
		 * Ratio rounded slices
		 */
		public static var ratioRoundSlices				:Number 				= 6;
		
		
		/**
		 * SWrapper instances
		 */
		protected static var __instances				:Dictionary				= new Dictionary(false);
		
		
		/**
		 * Get an instance of SWrapper. Instances are associated to stages.
		 * @param	pStage : The native associated stage instance from the document class
		 * @param	pAutoRatio : Use auto ratio scaling (only if this is the first getInstance for this stage)
		 * @return : SWrapper instance
		 */
		public static function getInstance (pStage:Stage, pAutoRatio:Boolean = true):SWrapper
		{
			// Vérifier la validité du stage
			if (pStage == null)
			{
				// déclencher l'erreur singleton
				throw new GraphicalError("SWrapper.getInstance", "Stage can't be null.");
				return null;
			}
			
			// Si on n'a pas d'instance
			if (!(pStage in __instances))
			{
				// On créé l'instance avec la clé et on stoque dans le dico
				__instances[pStage] = new SWrapper(new MultitonKey(), pStage, pAutoRatio);
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
		 * Touch dispatcher
		 */
		protected var _touchDispatcher					:TouchDispatcher;
		
		/**
		 * If auto ratio is enabled
		 */
		protected var _autoRatio						:Boolean;
		
		/**
		 * Current stage ratio (if autoRatio is true, default is 1)
		 */
		protected var _ratio							:Number						= 1;
		
		/**
		 * When disposed
		 */
		protected var _onDisposed						:Signal;
		
		
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
		 * Touch dispatcher
		 */
		public function get touchDispatcher ():TouchDispatcher { return _touchDispatcher; }
		
		/**
		 * If auto ratio is enabled
		 */
		public function get autoRatio ():Boolean { return _autoRatio; }
		
		/**
		 * Current stage ratio (if autoRatio is true, default is 1)
		 */
		public function get ratio ():Number { return _ratio; }
		
		/**
		 * When disposed
		 */
		public function get onDisposed ():ISignal { return _onDisposed; }
		
		
		/**
		 * Private constructor. Please use SWrapper.getInstance to create a new instance of SWrapper.
		 * SWrapper is singleton and can't be instanciated several times.
		 * @param	pMultitonKey : Private key to secure instanciation
		 * @param	pStage : The native associated stage instance from the document class
		 * @param	pAutoRatio : Use auto ratio scaling (only if this is the first getInstance for this stage)
		 */
		public function SWrapper (pMultitonKey:MultitonKey, pStage:Stage, pAutoRatio:Boolean)
		{
			// Vérifier la clé pour la création multiton
			if (pMultitonKey == null)
			{
				// déclencher l'erreur singleton
				throw new GraphicalError("SWrapper.construct", "Direct instancation not allowed, please use SWrapper.getInstance instead.");
			}
			else
			{
				// Enregistrer le stage
				_stage = pStage;
				
				// Si on est en ratio auto
				_autoRatio = pAutoRatio;
				
				// Ne jamais redimensionner l'UI
				_stage.scaleMode = StageScaleMode.NO_SCALE;
				_stage.align = StageAlign.TOP_LEFT;
				
				// Qualité au minimum
				_stage.quality = StageQuality.LOW;
				
				// Créer la racine
				_root = new SComponent();
				
				// Le nom de la racine
				_root.name = "root";
				
				// Initialiser le wrapper de DPI automatique
				initDPIWrapper();
			}
		}
		
		/**
		 * Démarrer le stageWrapper
		 */
		public function start ():void
		{
			// S'il n'est pas déjà démarré
			if (!_stage.contains(_root))
			{
				// Ajouter la racine
				_stage.addChild(_root);
				
				// Ecouter les redimentionnements
				_stage.addEventListener(Event.RESIZE, stageResizedHandler);
				
				// Appliquer une première fois la taille du viewPort
				stageResizedHandler();
			}
		}
		
		/**
		 * Initialize style manager
		 */
		public function enableStyleCentral ():void
		{
			// Créer le centre de gestion des styles
			_styleCentral = new StyleCentral();
			
			// Ecouter lorsque le style change
			_styleCentral.onStyleChanged.add(_root.invalidateStyle);
			
			// Activer les styles sur ce container
			_root.styleEnabled = true;
		}
		
		/**
		 * Native stage is resized
		 */
		protected function stageResizedHandler (event:Event = null):void
		{
			// Si les dimensions du root et du stage sont différentes
			if (_root.width != _stage.stageWidth || _root.height != _stage.stageHeight)
			{
				// Si on a un ratio automatique
				if (_autoRatio)
				{
					// Définir la taille du root
					_root.size(_stage.stageWidth / _ratio, _stage.stageHeight / _ratio);
				}
				else
				{
					// Définir la taille du root
					_root.size(_stage.stageWidth, _stage.stageHeight);
				}
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
				_ratio = EnvUtils.getInstance().getRatioForStage();
				
				// Arrondir le ratio
				_ratio = Math.round(_ratio * ratioRoundSlices) / ratioRoundSlices;
				
				// Appliquer le ratio
				_root.scaleX = _root.scaleY = _ratio;
			}
			
			// Configurer la qualité
			/*
			if (EnvUtils.getInstance().isiOSSpecificDevice(EnvUtils.IPAD_1_DEVICE))
			{
				// Passer en basse qualité sur iPad 1
				_stage.quality = StageQuality.LOW;
			}
			else
			{
				// Sinon qualité moyenne
				_stage.quality = StageQuality.MEDIUM;
			}*/
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