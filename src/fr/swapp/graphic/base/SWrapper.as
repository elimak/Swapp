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
	
	/**
	 * @author ZoulouX
	 */
	public class SWrapper implements IDisposable
	{
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
		 * Private constructor. Please use SWrapper.getInstance to create a new instance of SWrapper.
		 * SWrapper is singleton and can't be instanciated several times.
		 * @param	pMultitonKey : Private key to secure instanciation
		 * @param	pStage : The native associated stage instance from the document class
		 * @param	pAutoRatio : Use auto ratio scaling (only if this is the first getInstance for this stage)
		 */
		public function SWrapper (pMultitonKey:MultitonKey, pStage:Stage, pAutoRatio:Boolean = true)
		{
			// Vérifier la clé pour la création multiton
			if (pMultitonKey == null)
			{
				// Déclancher l'erreur singleton
				throw new GraphicalError("SWrapper.construct", "Direct instancation not allowed, please use SWrapper.getInstance instead.");
			}
			else
			{
				// Vérifier la validité du stage
				if (pStage == null)
				{
					// Déclancher l'erreur singleton
					throw new GraphicalError("SWrapper.construct", "Stage is null.");
				}
				else
				{
					// Enregistrer le stage
					_stage = pStage;
					
					// Ne jamais redimensionner l'UI
					_stage.scaleMode = StageScaleMode.NO_SCALE;
					_stage.align = StageAlign.TOP_LEFT;
					
					// Passer en basse qualité
					_stage.quality = StageQuality.LOW;
					
					// Créer la racine
					_root = new SComponent();
					
					// Le nom de la racine
					_root.name = "root";
					
					// Ajouter la racine
					_stage.addChild(_root);
					
					// Ecouter les redimentionnements
					_stage.addEventListener(Event.RESIZE, stageResizedHandler);
					
					// Appliquer une première fois la taille du viewPort
					//stageResizedHandler();
					
					// Initialiser le styleCentral
					//initStyleCentral();
				}
			}
		}
		
		
		/**
		 * Native stage is resized
		 */
		protected function stageResizedHandler (event:Event = null):void
		{
			// Si les dimensions du root et du stage sont différentes
			if (_root.width != _stage.stageWidth || _root.height != _stage.stageHeight)
			{
				// Définir la taille du root
				_root.size(_stage.stageWidth, _stage.stageHeight);
			}
		}
		
		/**
		 * Initialize style manager
		 */
		protected function initStyleCentral ():void
		{
			// Créer le centre de gestion des styles
			_styleCentral = new StyleCentral();
			
			// Ecouter lorsque le style change
			_styleCentral.onStyleChanged.add(root.invalidateStyle);
			
			// Activer les styles sur ce container
			_root.styleEnabled = true;
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
		}
	}
}

/**
 * Private key to secure multiton providing.
 */
internal class MultitonKey {}