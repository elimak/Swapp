package fr.swapp.graphic.base 
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import fr.swapp.core.log.Log;
	import fr.swapp.core.roles.IDataContainer;
	import fr.swapp.core.roles.IDisposable;
	import fr.swapp.core.roles.IIndexable;
	import fr.swapp.core.roles.IInitializable;
	import fr.swapp.graphic.styles.IStylable;
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	
	/**
	 * Composant de base avec gestion des dimensions.
	 * @author ZoulouX
	 */
	public class SComponent extends Sprite implements IIndexable, IDataContainer, IStylable, IInitializable, IDisposable
	{
		/**
		 * Object index
		 */
		protected var _index						:int;
		
		/**
		 * Data associated to this object.
		 */
		protected var _data							:Object;
		
		/**
		 * When component is initialised
		 */
		protected var _onInit						:Signal						= new Signal();
		
		/**
		 * When component is disposed
		 */
		protected var _onDisposed					:Signal;
		
		/**
		 * When component is resized.
		 */
		protected var _onResized					:Signal						= new Signal();
		
		/**
		 * When component is moved.
		 */
		protected var _onReplaced					:Signal						= new Signal();
		
		/**
		 * When component visibility is changed.
		 */
		protected var _onStyleChanged				:Signal						= new Signal();
		
		/**
		 * When style has changed.
		 */
		protected var _onVisibilityChanged			:Signal						= new Signal();
		
		
		/**
		 * Le parent écouté
		 */
		protected var _watchedParent				:SComponent;
		
		
		/**
		 * La largeur du composant
		 */
		protected var _localWidth					:Number						= 0;
		
		/**
		 * La hauteur du composant
		 */
		protected var _localHeight					:Number						= 0;
		
		/**
		 * La largeur minimum
		 */
		protected var _minWidth						:Number						= 0;
		
		/**
		 * La hauteur minimum
		 */
		protected var _minHeight					:Number						= 0;
		
		/**
		 * La largeur maximum
		 */
		protected var _maxWidth						:Number						= Infinity;
		
		/**
		 * La hauteur maximum
		 */
		protected var _maxHeight					:Number						= Infinity;
		
		/**
		 * Position absolue par rapport au haut
		 */
		protected var _top							:Number;
		
		/**
		 * Position absolue par rapport à la droite
		 */
		protected var _right						:Number;
		
		/**
		 * Position absolue par rapport au bas
		 */
		protected var _bottom						:Number;
		
		/**
		 * Position absolue par rapport à la gauche
		 */
		protected var _left							:Number;
		
		/**
		 * Centrage horizontal du composant
		 */
		protected var _horizontalCenter				:Number;
		
		/**
		 * Centrage vertical du composant
		 */
		protected var _verticalCenter				:Number;
		
		/**
		 * Le décalage de placement horizontal
		 */
		protected var _horizontalOffset				:Number						= 0;
		
		/**
		 * Le décalage de placement vertical
		 */
		protected var _verticalOffset				:Number						= 0;
		
		/**
		 * La marge du haut
		 */
		protected var _topMargin					:int						= 0;
		
		/**
		 * La marge de droite
		 */
		protected var _rightMargin					:int						= 0;
		
		/**
		 * La marge du bas
		 */
		protected var _bottomMargin					:int						= 0;
		
		/**
		 * La marge de gauche
		 */
		protected var _leftMargin					:int						= 0;
		
		
		/**
		 * Masquer le contenu
		 */
		protected var _clipContent					:Boolean					= false;
		
		
		/**
		 * Si la position est invalidée
		 */
		protected var _positionInvalidated			:Boolean					= false;
		
		/**
		 * Si le style est invalidé
		 */
		protected var _styleInvalidated				:Boolean					= false;
		
		
		/**
		 * Si le composant est en rendu bitmap
		 */
		protected var _isFlattened					:Boolean					= false;
		
		/**
		 * Le nom du style associé
		 */
		protected var _styleName					:String;
		
		/**
		 * Le fond (généré à la demande)
		 */
		protected var _backgroundGraphic			:SGraphic;
		
		/**
		 * Si la stylisation de cet élément est activé.
		 * Désactivé par défaut pour gagner en performances.
		 */
		protected var _styleEnabled					:Boolean					= false;
		
		/**
		 * La visibilité de l'élément
		 */
		protected var _visible						:Boolean					= true;
		
		/**
		 * Auto-dispose component when removed from DisplayList
		 */
		protected var _autoDispose					:Boolean					= true;
		
		/**
		 * Snap position to round pixels
		 */
		protected var _snapToPixels					:Boolean;
		
		/**
		 * Current style
		 */
		protected var _currentStyle					:Object;
		
		/**
		 * Wrapper on this stage
		 */
		protected var _wrapper						:SWrapper;
		
		
		/**
		 * Les anciennes valeurs pour détécter les changements.
		 */
		private var _oldWidth						:Number						= 0;
		private var _oldHeight						:Number						= 0;
		private var _oldYPosition					:Number						= 0;
		private var _oldXPosition					:Number						= 0;
		
		
		/**
		 * L'index de cet élément
		 */
		public function get index ():int { return _index; }
		public function set index (value:int):void 
		{
			_index = value;
		}
		
		/**
		 * Les données arbitraires associées à cet élément
		 */
		public function get data ():Object { return _data; }
		public function set data (value:Object):void 
		{
			_data = value;
		}
		
		
		/******************************************
					   Signals getters
		 ******************************************/
		
		/**
		 * When component is resized.
		 */
		public function get onResized ():Signal { return _onResized; }
		
		/**
		 * When component is moved.
		 */
		public function get onReplaced ():Signal { return _onReplaced; }
		
		/**
		 * When component visibility is changed.
		 */
		public function get onVisibilityChanged ():Signal { return _onVisibilityChanged; }
		
		/**
		 * When style has changed.
		 */
		public function get onStyleChanged ():Signal { return _onStyleChanged; }
		
		
		/******************************************
			     Getters / setters for flow
		 ******************************************/
		
		/**
		 * DisplayList super-width
		 */
		public function get superWidth ():Number { return super.width; };
		public function set superWidth (value:Number):void
		{
			super.width = value;
		}
		
		/**
		 * DisplayList super-height
		 */
		public function get superHeight ():Number { return super.height; };
		public function set superHeight (value:Number):void
		{
			super.height = value;
		}
		
		/**
		 * Fluid width of the component
		 */
		override public function get width ():Number { return _localWidth; }
		override public function set width (value:Number):void
		{
			// Si la valeur est différente et définie
			if (value >= 0 && value != _localWidth)
			{
				// Enregistrer la nouvelle valeur
				_localWidth = value;
				
				// Invalider la position
				_positionInvalidated = true;
			}
		}
		
		/**
		 * Fluid height of the component
		 */
		override public function get height ():Number { return _localHeight; }
		override public function set height (value:Number):void
		{
			// Si la valeur est différente et définie
			if (value >= 0 && value != _localHeight)
			{
				// Enregistrer la nouvelle valeur
				_localHeight = value;
				
				// Invalider la position
				_positionInvalidated = true;
			}
		}
		
		/**
		 * Minimum width of the component
		 */
		public function get minWidth ():Number { return _minWidth; }
		public function set minWidth (value:Number):void
		{
			// Si la valeur est différente et définie
			if (value >= 0 && value != _minWidth)
			{
				// Enregistrer la nouvelle valeur
				_minWidth = value;
				
				// Invalider la position
				_positionInvalidated = true;
			}
		}
		
		/**
		 * Minimum height of the component
		 */
		public function get minHeight ():Number { return _minHeight; }
		public function set minHeight (value:Number):void
		{
			// Si la valeur est différente et définie
			if (value >= 0 && value != _minHeight)
			{
				// Enregistrer la nouvelle valeur
				_minHeight = value;
				
				// Invalider la position
				_positionInvalidated = true;
			}
		}
		
		/**
		 * Maximum width of the component
		 */
		public function get maxWidth ():Number { return _maxWidth; }
		public function set maxWidth (value:Number):void
		{
			// Si la valeur est différente et définie
			if (value >= 0 && value != _maxWidth)
			{
				// Enregistrer la nouvelle valeur
				_maxWidth = value;
				
				// Invalider la position
				_positionInvalidated = true;
			}
		}
		
		/**
		 * Maximum height of the component
		 */
		public function get maxHeight ():Number { return _maxHeight; }
		public function set maxHeight (value:Number):void
		{
			// Si la valeur est différente et définie
			if (value >= 0 && value != _maxHeight)
			{
				// Enregistrer la nouvelle valeur
				_maxHeight = value;
				
				// Invalider la position
				_positionInvalidated = true;
			}
		}
		
		/**
		 * Absolute top position of the component (NaN to ignore)
		 */
		public function get top ():Number { return _top; }
		public function set top (value:Number):void
		{
			// Si la valeur est différente
			if (value != _top)
			{
				// Enregistrer la nouvelle valeur
				_top = value;
				
				// Invalider la position
				_positionInvalidated = true;
			}
		}
		
		/**
		 * Absolute right position of the component (NaN to ignore)
		 */
		public function get right ():Number { return _right; }
		public function set right (value:Number):void
		{
			// Si la valeur est différente
			if (value != _right)
			{
				// Enregistrer la nouvelle valeur
				_right = value;
				
				// Invalider la position
				_positionInvalidated = true;
			}
		}
		
		/**
		 * Absolute bottom position of the component (NaN to ignore)
		 */
		public function get bottom ():Number { return _bottom; }
		public function set bottom (value:Number):void
		{
			// Si la valeur est différente
			if (value != _bottom)
			{
				// Enregistrer la nouvelle valeur
				_bottom = value;
				
				// Invalider la position
				_positionInvalidated = true;
			}
		}
		
		/**
		 * Absolute left position of the component (NaN to ignore)
		 */
		public function get left ():Number { return _left; }
		public function set left (value:Number):void
		{
			// Si la valeur est différente
			if (value != _left)
			{
				// Enregistrer la nouvelle valeur
				_left = value;
				
				// Invalider la position
				_positionInvalidated = true;
			}
		}
		
		/**
		 * Horizontal center offset of the component (NaN to ignore, 0 to center)
		 */
		public function get horizontalCenter ():Number { return _horizontalCenter; }
		public function set horizontalCenter (value:Number):void
		{
			// Si la valeur est différente
			if (value != _horizontalCenter)
			{
				// Enregistrer la nouvelle valeur
				_horizontalCenter = value;
				
				// Invalider la position
				_positionInvalidated = true;
			}
		}
		
		/**
		 * Vertical center offset of the component (NaN to ignore, 0 to center)
		 */
		public function get verticalCenter ():Number { return _verticalCenter; }
		public function set verticalCenter (value:Number):void
		{
			// Si la valeur est différente
			if (value != _verticalCenter)
			{
				// Enregistrer la nouvelle valeur
				_verticalCenter = value;
				
				// Invalider la position
				_positionInvalidated = true;
			}
		}
		
		/**
		 * Horizontal offset from the flow (0 to ignore)
		 */
		public function get horizontalOffset ():Number { return _horizontalOffset; }
		public function set horizontalOffset (value:Number):void 
		{
			// Si la valeur est différente
			// Et si la valeur est réelle
			if (value != _horizontalOffset && (value >= 0 || value < 0) && _onReplaced != null)
			{
				// Enregistrer la nouvelle valeur
				_horizontalOffset = value;
				
				// Invalider la position
				_positionInvalidated = true;
				
				// Placer
				//x = _horizontalOffset + _leftMargin;
				
				// Signaler
				//replaced();
				
				// Dispatcher
				//_onReplaced.dispatch();
			}
		}
		
		/**
		 * Vertical offset from the flow (0 to ignore)
		 */
		public function get verticalOffset ():Number { return _verticalOffset; }
		public function set verticalOffset (value:Number):void 
		{
			// Si la valeur est différente
			// Et si la valeur est réelle
			if (value != _verticalOffset && (value >= 0 || value < 0) && _onReplaced != null)
			{
				// Enregistrer la nouvelle valeur
				_verticalOffset = value;
				
				// Invalider la position
				_positionInvalidated = true;
				
				// Placer
				//y = _verticalOffset + _topMargin;
				
				// Signaler
				//replaced();
				
				// Dispatcher
				//_onReplaced.dispatch();
			}
		}
		
		/**
		 * Top margin from flow
		 */
		public function get topMargin ():int { return _topMargin; }
		public function set topMargin (value:int):void 
		{
			// Si la valeur est différente
			if (value != _topMargin)
			{
				// Enregistrer la nouvelle valeur
				_topMargin = value;
				
				// Invalider la position
				_positionInvalidated = true;
			}
		}
		
		/**
		 * Right margin from flow
		 */
		public function get rightMargin ():int { return _rightMargin; }
		public function set rightMargin (value:int):void 
		{
			// Si la valeur est différente
			if (value != _rightMargin)
			{
				// Enregistrer la nouvelle valeur
				_rightMargin = value;
				
				// Invalider la position
				_positionInvalidated = true;
			}
		}
		
		/**
		 * Bottom margin from flow
		 */
		public function get bottomMargin ():int { return _bottomMargin; }
		public function set bottomMargin (value:int):void 
		{
			// Si la valeur est différente
			if (value != _bottomMargin)
			{
				// Enregistrer la nouvelle valeur
				_bottomMargin = value;
				
				// Invalider la position
				_positionInvalidated = true;
			}
		}
		
		/**
		 * Left margin from flow
		 */
		public function get leftMargin ():int { return _leftMargin; }
		public function set leftMargin (value:int):void 
		{
			// Si la valeur est différente
			if (value != _leftMargin)
			{
				// Enregistrer la nouvelle valeur
				_leftMargin = value;
				
				// Invalider la position
				_positionInvalidated = true;
			}
		}
		
		/**
		 * Hide overflowing content
		 */
		public function get clipContent ():Boolean { return _clipContent; }
		public function set clipContent (value:Boolean):void
		{
			// Si la valeur est différente
			if (value != _clipContent)
			{
				// Enregistrer la nouvelle valeur
				_clipContent = value;
				
				// Invalider la position
				_positionInvalidated = true;
			}
		}
		
		/**
		 * Total width of the component (with margins, can't be NaN)
		 */
		public function get totalWidth ():Number { return _leftMargin + _localWidth + _rightMargin };
		
		/**
		 * Total height of the component (with margins, can't be NaN)
		 */
		public function get totalHeight ():Number { return _topMargin + _localHeight + _bottomMargin };
		
		/**
		 * If component is in GPU Texture mode
		 */
		public function get isFlattened ():Boolean { return _isFlattened; }
		
		/**
		 * On demand generated background. Getter will automagically add a void SGraphic instance.
		 * If styles are disabled, background will never added automagically.
		 * Default background name is "background".
		 * You can still set your own SGraphic instance, even if styles are disabled.
		 */
		public function get backgroundGraphic ():SGraphic
		{
			// Interdire si on n'a pas les styles
			if (!_styleEnabled)
				return null;
			
			// Si on n'a pas de fond
			if (_backgroundGraphic == null)
			{
				// On le créé
				_backgroundGraphic = new SGraphic();
				
				// Et on le place
				_backgroundGraphic.place(0, 0, 0, 0).into(this, 0, "background");
			}
			
			// Retourner le fond
			return _backgroundGraphic;
		}
		public function set backgroundGraphic (value:SGraphic):void
		{
			// Si c'est différent
			if (_backgroundGraphic != value)
			{
				// Si on a déjà un fond
				if (_backgroundGraphic != null)
				{
					// On le vire
					_backgroundGraphic.into(null);
				}
				
				// Si la valeur est différent de null
				if (value != null)
				{
					// On enregistre le nouveau
					_backgroundGraphic = value;
					
					// Et on le place
					_backgroundGraphic.place(0, 0, 0, 0).into(this, 0, "background");
				}
			}
		}
		
		/**
		 * Whether or not the display object is visible.
		 */
		override public function get visible ():Boolean { return _visible; }
		override public function set visible (value:Boolean):void
		{
			// Si c'est différent
			if (value != _visible)
			{
				// Enregistrer
				_visible = value;
				
				// Appliquer
				super.visible = value;
				
				// Invalider la position
				_positionInvalidated = true;
				
				// Dispatcher le changement
				if (_onVisibilityChanged != null)
					_onVisibilityChanged.dispatch();
			}
		}
		
		/**
		 * Associated style name.
		 * Styles have to be enabled to be used.
		 */
		public function get styleName ():String { return _styleName; }
		public function set styleName (value:String):void
		{
			// Si c'est différent
			if (_styleName != value)
			{
				// On enregistre
				_styleName = value;
				
				// Et on invalide le style
				_styleInvalidated = true;
			}
		}
		
		/**
		 * If styles are enabled for this component.
		 * Disabled by default for performances.
		 */
		public function get styleEnabled ():Boolean { return _styleEnabled; }
		public function set styleEnabled (value:Boolean):void
		{
			// Si c'est différent
			if (_styleEnabled != value)
			{
				// On enregistre
				_styleEnabled = value;
				
				// Et on invalide le style
				_styleInvalidated = true;
			}
		}
		
		/**
		 * Get the parent stylable object.
		 */
		public function get parentStylable ():IStylable
		{
			return (parent != null ? parent as IStylable : null);
		}
		
		/**
		 * When component is initialised
		 */
		public function get onInit ():ISignal { return _onInit; }
		
		/**
		 * When component is disposed
		 */
		public function get onDisposed ():ISignal { return _onDisposed; }
		
		/**
		 * Snap position to round pixels
		 */
		public function get snapToPixels ():Boolean { return _snapToPixels; }
		public function set snapToPixels (value:Boolean):void
		{
			_snapToPixels = value;
		}
		
		/**
		 * Current style
		 */
		public function get currentStyle ():Object { return _currentStyle; }
		
		
		/**
		 * Constructeur du composant avec gestion des dimensions
		 */
		public function SComponent ()
		{
			// TODO : Ajoute une méthode helper qui permet d'uploader au GPU sans être vu (alpha = 0 ou un draw add sur le stageWrapper en scale 0...)
			// TODO : puis de s'afficher une fois chargé et appeler un handler (voir TimerUtils)
			// TODO : Cette gestion de l'upload GPU permettra de ne pas avoir d'animation qui rame
			
			// Signaler que le composant n'est pas disposé pour être sûr qu'on passe bien par le constructeur
			_onDisposed = new Signal();
			
			// Ecouter les ajouts au stage
			if (stage != null)
			{
				addedHandler();
			}
			else
			{
				addEventListener(Event.ADDED_TO_STAGE, addedHandler);
			}
			
			// Ecouter la suppression
			addEventListener(Event.REMOVED_FROM_STAGE, removedHandler);
		}
		
		
		/******************************************
				Initialisation / Destruction
		 ******************************************/
		
		/**
		 * Component initialisation. Added to stage.
		 */
		protected function addedHandler (event:Event = null):void
		{
			// Récupérer le wrapper
			_wrapper = SWrapper.getInstance(stage);
			
			// Si on a un parent redimensionnable
			if (parent is SComponent)
			{
				// Supprimer l'ancien si besoin
				if (_watchedParent != null)
				{
					// On n'écoute plus les changements
					_watchedParent.onReplaced.remove(parentReplacedHandler);
					_watchedParent.onResized.remove(parentResizedHandler);
					_watchedParent.onStyleChanged.remove(parentStyleChangedHandler);
					_watchedParent.onVisibilityChanged.remove(parentVisibilityChangedHandler);
				}
				
				// On le mémorise
				_watchedParent = (parent as SComponent);
				
				// On écoute les changements
				_watchedParent.onReplaced.add(parentReplacedHandler);
				_watchedParent.onResized.add(parentResizedHandler);
				_watchedParent.onStyleChanged.add(parentStyleChangedHandler);
				_watchedParent.onVisibilityChanged.add(parentVisibilityChangedHandler);
			}
			
			// Ecouter la phase de rendu
			addEventListener(Event.FRAME_CONSTRUCTED, renderHandler);
			
			// Phase de rendu
			renderPhase();
			
			// Initialisation
			init();
		}
		
		/**
		 * Component deletion. Removed from stage.
		 */
		protected function removedHandler (event:Event):void
		{
			// Si on a déjà été disposé
			if (_onDisposed == null)
			{
				// C'est un problème OUPS
				Log.error("Multiple dispose detected in SComponent");
				return;
			}
			
			// Dispose
			if (_autoDispose)
			{
				dispose();
			}
			
			// Ne plus écouter les phases
			removeEventListener(Event.FRAME_CONSTRUCTED, renderHandler);
			
			// Supprimer tous les listeners
			_onResized.removeAll();
			_onReplaced.removeAll();
			_onStyleChanged.removeAll();
			_onVisibilityChanged.removeAll();
			
			// Supprimer les signaux
			_onResized = null;
			_onReplaced = null;
			_onStyleChanged = null;
			_onVisibilityChanged = null;
			
			// On n'écoute plus le parent
			if (_watchedParent != null && _watchedParent.onDisposed != null)
			{
				_watchedParent.onResized.remove(parentResizedHandler);
				_watchedParent.onReplaced.remove(parentReplacedHandler);
				_watchedParent.onStyleChanged.remove(parentStyleChangedHandler);
				_watchedParent.onVisibilityChanged.remove(parentVisibilityChangedHandler);
			}
			
			// Supprimer la référence au wrapper
			_wrapper = null;
			
			// Supprimer le style
			_currentStyle = null;
			
			// On n'a plus de parent
			_watchedParent = null;
		}
		
		/**
		 * Initialize
		 */
		public function init ():void
		{
			// Dispatcher
			_onInit.dispatch();
		}
		
		/**
		 * Dispose component from memory
		 */
		public function dispose ():void
		{
			// TODO : Vérifier les disposes de SComponent. Trouver aussi un moyen pour faire du pooling sans faire de remove.
			
			// Ne plus écouter l'ajout et la suppression
			removeEventListener(Event.ADDED_TO_STAGE, addedHandler);
			removeEventListener(Event.REMOVED_FROM_STAGE, removedHandler);
			
			// Supprimer l'init
			_onInit.removeAll();
			_onInit = null;
			
			// Signaler et supprimer
			_onDisposed.dispatch();
			_onDisposed.removeAll();
			_onDisposed = null;
		}
		
		
		/******************************************
					   Parent observé
		 ******************************************/
		
		/**
		 * Le parent a changé de position
		 */
		protected function parentReplacedHandler ():void
		{
			// Signal en local
			replaced();
			
			// Signaler à l'exterieur
			_onReplaced.dispatch();
		}
		
		/**
		 * Le parent a changé de taille
		 */
		protected function parentResizedHandler ():void
		{
			// Replacer
			replace();
		}
		
		/**
		 * Le parent a changé de style
		 */
		protected function parentStyleChangedHandler ():void
		{
			// Actualiser le style
			updateStyle();
		}
		
		/**
		 * Le parent a changé de visibilité
		 */
		protected function parentVisibilityChangedHandler ():void
		{
			// Signaler en local
			visibilityChanged();
			
			// Signaler à l'extérieur
			_onVisibilityChanged.dispatch();
		}
		
		
		/******************************************
					  Méthodes ouvertes
		 ******************************************/
		
		/**
		 * Set the size of this component.
		 * Correct values are between 0 and Infinity, NaN to ignore a parameter.
		 * @param	pWidth : Component's width (NaN to ignore).
		 * @param	pHeight : Component's height (NaN to ignore).
		 * @return this
		 */
		public function size (pWidth:Number = NaN, pHeight:Number = NaN):SComponent
		{
			// Si une des propriété a été changée
			var changed:Boolean;
			
			// Si la largeur est réelle et différente
			if (pWidth >= 0 && pWidth != _localWidth)
			{
				// Enregistrer la valeur
				_localWidth = pWidth;
				
				// Signaler qu'on a changer pour invalider
				changed = true;
			}
			
			// Si la hauteur est réelle et différente
			if (pHeight >= 0 && pHeight != _localHeight)
			{
				// Enregistrer la valeur
				_localHeight = pHeight;
				
				// Signaler qu'on a changer pour invalider
				changed = true;
			}
			
			// Invalider la position si besoin
			if (changed)
			{
				_positionInvalidated = true;
			}
			
			// Méthode chaînable
			return this;
		}
		
		/**
		 * Absolutely place the component. Enable to configure all placement variables and redispatching once.
		 * Correct values are between -Infinity and Infinity, NaN to ignore a parameter.
		 * @param	pTop : Top offset from parent (NaN to ignore)
		 * @param	pRight : Right offset from parent (NaN to ignore)
		 * @param	pBottom : Bottom offset from parent (NaN to ignore)
		 * @param	pLeft : Left offset from parent (NaN to ignore)
		 * @return this
		 */
		public function place (pTop:Number = NaN, pRight:Number = NaN, pBottom:Number = NaN, pLeft:Number = NaN):SComponent
		{
			// Tout enregistrer
			_top = pTop;
			_right = pRight;
			_bottom = pBottom;
			_left = pLeft;
			
			// Invalider la position
			_positionInvalidated = true;
			
			// Méthode chaînable
			return this;
		}
		
		/**
		 * Place this component like a rectangle. Set absolute left, top, and fixed width and height.
		 * @param	pTop : Top offset from parent (NaN to ignore)
		 * @param	pRight : Right offset from parent (NaN to ignore)
		 * @param	pWidth : Component's width (NaN to ignore).
		 * @param	pHeight : Component's height (NaN to ignore).
		 * @return this
		 */
		public function rectPlace (pLeft:Number = NaN, pTop:Number = NaN, pWidth:Number = NaN, pHeight:Number = NaN):SComponent
		{
			// Tout enregistrer
			_left = pLeft;
			_top = pTop;
			
			// Si la valeur existe, on l'enregistre
			if (_localWidth >= 0)
				_localWidth = pWidth;
			
			// Si la valeur existe, on l'enregistre
			if (_localHeight >= 0)
				_localHeight = pHeight;
			
			// Invalider la position
			_positionInvalidated = true;
			
			// Méthode chaînable
			return this;
		}
		
		/**
		 * Offset the component's content (the box model will not move).
		 * Correct values are between -Infinity and Infinity, NaN to ignore a parameter.
		 * @param	pHorizontalOffset : Horizontal offset (NaN to ignore)
		 * @param	pVerticalOffset : Vertical offset (NaN to ignore)
		 * @return this
		 */
		public function offset (pHorizontalOffset:Number = NaN, pVerticalOffset:Number = NaN):SComponent
		{
			// Si notre paramètres horizontal n'est pas null, on enregistre
			if (pHorizontalOffset >= 0 || pHorizontalOffset < 0)
				_horizontalOffset = pHorizontalOffset;
			
			// Si notre paramètres vertical n'est pas null, on enregistre
			if (pVerticalOffset >= 0 || pVerticalOffset < 0)
				_verticalOffset = pVerticalOffset;
			
			// Placer
			x = _horizontalOffset + _leftMargin;
			y = _verticalOffset + _topMargin;
			
			// Signaler
			replaced();
			
			// Dispatcher
			_onReplaced.dispatch();
			
			// Méthode chaînable
			return this;
		}
		
		/**
		 * Minimum sizes.
		 * Correct values are between 0 and Infinity, NaN to ignore a parameter.
		 * @param	pMinWidth : Minimum width (NaN to ignore)
		 * @param	pMinHeight : Minimum height (NaN to ignore)
		 * @return this
		 */
		public function minSize (pMinWidth:Number, pMinHeight:Number):SComponent
		{
			// Si notre paramètres horizontal n'est pas null, on enregistre
			if (pMinWidth >= 0 || pMinWidth < 0)
				_minWidth = Math.max(0, pMinWidth);
			
			// Si notre paramètres vertical n'est pas null, on enregistre
			if (pMinHeight >= 0 || pMinHeight < 0)
				_minHeight = Math.max(0, pMinHeight);
			
			// Invalider la position
			_positionInvalidated = true;
			
			// Méthode chaînable
			return this;
		}
		
		/**
		 * Maximum sizes.
		 * Correct values are between 0 and Infinity, NaN to ignore a parameter.
		 * @param	pMaxWidth : Minimum width (NaN to ignore)
		 * @param	pMaxHeight : Minimum height (NaN to ignore)
		 * @return this
		 */
		public function maxSize (pMaxWidth:Number, pMaxHeight:Number):SComponent
		{
			// Si notre paramètres horizontal n'est pas null, on enregistre
			if (pMaxWidth >= 0 || pMaxWidth < 0)
				_maxWidth = Math.max(0, pMaxWidth);
			
			// Si notre paramètres vertical n'est pas null, on enregistre
			if (pMaxHeight >= 0 || pMaxHeight < 0)
				_maxHeight = Math.max(0, pMaxHeight);
			
			// Invalider la position
			_positionInvalidated = true;
			
			// Méthode chaînable
			return this;
		}
		
		/**
		 * Margin around this component's box model.
		 * @param	pTopMargin : Top margin
		 * @param	pRightMargin : Right margin
		 * @param	pBottomMargin : Bottom margin
		 * @param	pLeftMargin : Left margin
		 * @return this
		 */
		public function margin (pTopMargin:int, pRightMargin:int, pBottomMargin:int, pLeftMargin:int):SComponent
		{
			// Enregistrer les valeurs
			_topMargin = pTopMargin;
			_rightMargin = pRightMargin;
			_bottomMargin = pBottomMargin;
			_leftMargin = pLeftMargin;
			
			// Invalider la position
			_positionInvalidated = true;
			
			// Méthode chaînable
			return this;
		}
		
		/**
		 * Center this element on horizontal and vertical axes, from its parent.
		 * Correct values are between -Infinity and Infinity, NaN to cancel a parameter.
		 * @param	pHorizontalCenter : Horizontal offset (NaN to cancel)
		 * @param	pVerticalCenter : Vertical offset (NaN to cancel)
		 * @return this
		 */
		public function center (pHorizontalCenter:Number = NaN, pVerticalCenter:Number = NaN):SComponent
		{
			// Enregistrer les valeurs
			_horizontalCenter = pHorizontalCenter;
			_verticalCenter = pVerticalCenter;
			
			// Invalider la position
			_positionInvalidated = true;
			
			// Méthode chaînable
			return this;
		}
		
		/**
		 * Place this component into another. This will start the reflow process and show the component.
		 * @param	pParent : Any DisplayObjectContainer object
		 * @param	pAt : Which level (optionnal, -1 to place on front, 0 to place behind)
		 * @param	pName : Name of this component (optionnal)
		 * @return this
		 */
		public function into (pParent:DisplayObjectContainer, pAt:int = -1, pName:String = ""):SComponent
		{
			// Définir le nom si besoin
			if (pName != "")
				name = pName;
			
			// Si le parent est null
			if (pParent == null && parent != null)
			{
				// On supprime
				parent.removeChild(this);
			}
			else if (pParent != null)
			{
				// Ajouter au parent au bon étage
				if (pAt == -1)
					pParent.addChild(this);
				else
					pParent.addChildAt(this, pAt);
			}
			
			// Méthode chaînable
			return this;
		}
		
		/**
		 * Set CacheAsBitmapMatrix with Flash fallback
		 */
		protected function setCacheAsBitmapMatrix (pValue:Matrix):void
		{
			// Le nom de la variable à vérifier
			const varName:String = "cacheAsBitmapMatrix";
			
			// Vérifier si ça existe
			if (varName in this)
			{
				// Ca existe, alors définir
				this[varName] = pValue;
			}
		}
		
		/**
		 * Convert this component to GPU Texture
		 * @param	pMatrixScale : Automatic scale of the bitmap (NaN to ignore)
		 * @param	pMatrix : CacheAsBitmap matrix (Scale will be ignored if non null)
		 * @return this
		 */
		public function flatten (pMatrixScale:Number = NaN, pMatrix:Matrix = null):SComponent
		{
			// Invalider la position
			_positionInvalidated = true;
			
			// Appliquer le cacheAsBitmap
			cacheAsBitmap = true;
			
			// Si on a une matrice
			if (pMatrix != null)
			{
				// On l'applique
				setCacheAsBitmapMatrix(pMatrix);
			}
			
			// Sinon si on a un scale
			else if (pMatrixScale > 0)
			{
				// On applique ce scale
				setCacheAsBitmapMatrix(new Matrix(pMatrixScale, 0, 0, pMatrixScale));
			}
			
			// Méthode chaînable
			return this;
		}
		
		/**
		 * Disable GPU Texture and reactive live component.
		 * @return this
		 */
		public function unflatten ():SComponent
		{
			// Virer le cacheAsBitmap
			cacheAsBitmap = false;
			setCacheAsBitmapMatrix(null);
			
			// Invalider la position
			_positionInvalidated = true;
			
			// Méthode chaînable
			return this;
		}
		
		/**
		 * Specify if the component is interactive.
		 * @return this
		 */
		public function interactive (pValue:Boolean):SComponent
		{
			// Appliquer
			mouseEnabled = pValue;
			mouseChildren = pValue;
			
			// Méthode chaînable
			return this;
		}
		
		/**
		 * Specify a styleName to apply.
		 * If styles are disabled, styles will be enabled automatically.
		 * @return this
		 */
		public function style (pStyleName:String):SComponent
		{
			// Appliquer le style
			styleName = pStyleName;
			
			// Si les styles sont désactivés, on les active
			if (!_styleEnabled)
				_styleEnabled = true;
			
			// Chaînable
			return this;
		}
		
		
		/******************************************
						Invalidation
		 ******************************************/
		
		/**
		 * Force rendering
		 */
		public function forceRender ():void
		{
			// Invalider les styles et la position
			_positionInvalidated = true;
			_styleInvalidated = true;
			
			// Activer la phase de rendu
			renderPhase();
		}
		
		/**
		 * Execute render of this component.
		 */
		protected function renderHandler (event:Event):void
		{
			// Phase de rendu
			renderPhase();
		}
		
		/**
		 * Render phase
		 */
		protected function renderPhase ():void
		{
			// Si le style est invalide
			if (_styleInvalidated)
			{
				// On l'actualise
				updateStyle();
				
				// Le style est valide
				_styleInvalidated = false;
			}
			
			// Si la position est invalidée
			if (_positionInvalidated)
			{
				// Replacer
				replace();
				
				// On est valide
				_positionInvalidated = false;
			}
		}
		
		
		/******************************************
						 Placement
		 ******************************************/
		
		/**
		 * Force component to replace
		 */
		protected function replace ():void
		{
			// Actualiser selon le flux
			updateFlow();
		}
		
		/**
		 * Force component to reflow
		 */
		protected function updateFlow ():void
		{
			// Si on est disposé
			if (_onDisposed == null)
			{
				// Afficher l'erreur
				Log.error("Trying to update a disposed component");
				
				// On n'actualise pas
				return;
			}
			
			// Minimiser / maximiser les valeurs
			_localWidth 		= Math.max(_minWidth, Math.min(_localWidth, _maxWidth));
			_localHeight 		= Math.max(_minHeight, Math.min(_localHeight, _maxHeight));
			
			// Si on a un parent
			if (_watchedParent != null)
			{
				// Centrer horizontalement ou placer
				if (_horizontalCenter >= 0 || _horizontalCenter < 0)
				{
					x = _watchedParent.width / 2 - _localWidth / 2 + _horizontalCenter + _horizontalOffset;
				}
				
				// A gauche et à droite
				else if ((_left >= 0 || _left < 0) && (_right >= 0 || _right < 0))
				{
					// Largeur fluide
					_localWidth = Math.max(_minWidth, Math.min(_watchedParent.width - _left - _right - _leftMargin - _rightMargin, _maxWidth));
					
					// Actualiser la position
					x = _left + _horizontalOffset + _leftMargin;
				}
				
				// Alignement sur la droite
				else if (!(_left >= 0 || _left < 0) && (_right >= 0 || _right < 0))
				{
					// Placer à droite
					x = _watchedParent.width - _localWidth - _right - _rightMargin + _horizontalOffset;
				}
				
				// Alignement sur la gauche
				else if (_left >= 0 || _left < 0)
				{
					// Placer à gauche
					x = _left + _horizontalOffset + _leftMargin;
				}
				
				// Placement normal sur les marges
				else
				{
					x = _horizontalOffset + _leftMargin;
				}
				
				
				// Centrer verticalement ou placer
				if (_verticalCenter >= 0 || _verticalCenter < 0)
				{
					y = _watchedParent.height / 2 - _localHeight / 2 + _verticalCenter + _verticalOffset;
				}
				
				// Alignement en haut et en bas
				else if ((_top >= 0 || _top < 0) && (_bottom >= 0 || _bottom < 0))
				{
					// Hauteur fluide
					_localHeight = Math.max(_minHeight, Math.min(_watchedParent.height - _top - _bottom - _topMargin - _bottomMargin, _maxHeight));
					
					// Placer
					y = _top + _verticalOffset + _topMargin;
				}
				
				// Alignement en bas
				else if (!(_top >= 0 || _top < 0) && (_bottom >= 0 || _bottom < 0))
				{
					// Placer en bas
					y = _watchedParent.height - _localHeight - _bottom - _bottomMargin + _verticalOffset;
				}
				
				// Alignement en haut
				else if (_top >= 0 || _top < 0)
				{
					// Placer en haut
					y = _top + _verticalOffset + _topMargin;
				}
				
				// Placement normal sur les marges
				else
				{
					y = _verticalOffset + _topMargin;
				}
			}
			
			// Actualiser le masque
			if (_clipContent && (_localWidth != _oldWidth || _localHeight != _oldHeight))
			{
				scrollRect = new Rectangle(0, 0, _localWidth, _localHeight);
			}
			else if (!_clipContent && scrollRect != null)
			{
				scrollRect = null;
			}
			
			// Si le composant a bougé
			if (super.x != _oldXPosition || super.y != _oldYPosition)
			{
				// Si on doit aligner sur les pixels
				if (_snapToPixels)
				{
					// Aligner sur les pixels
					super.x = int(super.x);
					super.y = int(super.y);
				}
				
				// Signaler
				replaced();
				
				// Dispatcher
				_onReplaced.dispatch();
			}
			
			// Si on a touché aux dimensions du composant
			if (_localWidth != _oldWidth || _localHeight != _oldHeight)
			{
				// Signaler
				resized();
				
				// Dispatcher
				_onResized.dispatch();
			}
			
			// Enregistrer les nouvelles positions / dimensions
			_oldWidth 			= _localWidth;
			_oldHeight 			= _localHeight;
			_oldXPosition 		= x;
			_oldYPosition 		= y;
		}
		
		/**
		 * Componenent has moved
		 */
		protected function replaced ():void
		{
			
		}
		
		/**
		 * Component's size has changed
		 */
		protected function resized ():void
		{
			
		}
		
		
		/******************************************
						    Style
		 ******************************************/
		
		/**
		 * Invalidation style
		 */
		public function invalidateStyle ():void
		{
			_styleInvalidated = true;
		}
		
		/**
		 * Update style (if style is enabled)
		 */
		protected function updateStyle ():void
		{
			// Si on a un wrapper et les styles d'activé
			if (_wrapper != null && _styleEnabled)
			{
				// Récupérer le style depuis le styleCentral
				_currentStyle = _wrapper.styleCentral.getComputedStyleFromStylable(this);
				
				// Injecter ce style
				injectCurrentStyle();
			}
		}
		
		/**
		 * Inject current style
		 */
		protected function injectCurrentStyle ():void
		{
			// Si on a un wrapper
			if (_wrapper != null)
			{
				// Injecter le style
				_wrapper.styleCentral.injectStyle(this, _currentStyle);
				
				// Le style a été changé
				styleInjected();
				
				// Signaler que le style a changé
				_onStyleChanged.dispatch();
			}
		}
		
		/**
		 * Style has changed
		 */
		protected function styleInjected ():void
		{
			
		}
		
		
		/******************************************
					Component Visibility
		 ******************************************/
		
		/**
		 * Knowing if this component is visible.
		 * If a parent is not visible or not added to the scene, false will be returned.
		 */
		public function isVisible ():Boolean
		{
			// TODO : Vérifier la propagation de la visibilité avec les stageWebView et stageVideo
			
			// Si on n'est pas visible
			if (!_visible)
				return false;
			
			// Si on a un stage
			if (stage != null)
			{
				// Commencer par le parent
				var parent:SComponent = _watchedParent;
				
				// Si le parent ciblé est présent
				while (parent != null)
				{
					// Si ce parent n'est pas visible
					if (!parent.visible)
					{
						// On n'est pas visible
						return false;
					}
					
					// Cibler le parent du parent
					parent = parent.parent as SComponent;
				}
			}
			
			// On est visible
			return true;
		}
		
		/**
		 * Visibility state has changed
		 */
		protected function visibilityChanged ():void
		{
			
		}
	}
}