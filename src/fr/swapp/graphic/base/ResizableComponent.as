package fr.swapp.graphic.base 
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import fr.swapp.core.display.MasterSprite;
	import fr.swapp.core.log.Log;
	import fr.swapp.core.roles.IDataContainer;
	import fr.swapp.core.roles.IIndexable;
	import fr.swapp.graphic.components.bitmaps.AdvancedBitmap;
	import fr.swapp.graphic.styles.IStylable;
	import org.osflash.signals.Signal;
	
	/**
	 * Composant de base avec gestion des dimensions.
	 * @author ZoulouX
	 */
    [DefaultProperty("children")]
	public class ResizableComponent extends MasterSprite implements IIndexable, IDataContainer, IStylable
	{
		/**
		 * Le stage wrapper par défaut (injecté par le stagewrapper)
		 */
		public static var wrapper					:StageWrapper;
		
		
		/**
		 * L'index de cet élément
		 */
		protected var _index						:int;
		
		/**
		 * Les données arbitraires associées à cet élément
		 */
		protected var _data							:Object;
		
		
		/**
		 * Le signal du redimensionnement
		 */
		protected var _onResized					:Signal						= new Signal();
		
		/**
		 * Le signal du repositionnement
		 */
		protected var _onReplaced					:Signal						= new Signal();
		
		/**
		 * Le signal du style changé
		 */
		protected var _onStyleChanged				:Signal						= new Signal();
		
		/**
		 * Lorsque la visibilité de l'élément change
		 */
		protected var _onVisibilityChanged			:Signal						= new Signal();
		
		
		/**
		 * Le parent écouté
		 */
		protected var _watchedParent				:ResizableComponent;
		
		
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
		 * Si on autorise le redraw par les enfants
		 */
		protected var _allowRedraw					:Boolean					= true;
		
		/**
		 * Le nom du style associé
		 */
		protected var _styleName					:String;
		
		/**
		 * Le fond (généré à la demande)
		 */
		protected var _backgroundImage				:AdvancedBitmap;
		
		/**
		 * La liste des enfants pour le wrapper MXML
		 */
        protected var _children						:Vector.<DisplayObject>;
		
		/**
		 * Si la stylisation de cet élément est activé.
		 * Désactivé par défaut pour gagner en performances.
		 */
		protected var _styleEnabled					:Boolean					= false;
		
		/**
		 * Si l'élément a été disposé
		 */
		protected var _disposed						:Boolean;
		
		/**
		 * La visibilité de l'élément
		 */
		protected var _visible						:Boolean					= true;
		
		
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
		
		/**
		 * Le signal du redimensionnement
		 */
		public function get onResized ():Signal { return _onResized; }
		
		/**
		 * Le signal du repositionnement
		 */
		public function get onReplaced ():Signal { return _onReplaced; }
		
		/**
		 * La largeur en passant par la superclasse
		 */
		public function get superWidth ():Number { return super.width; };
		public function set superWidth (value:Number):void
		{
			super.width = value;
		}
		
		/**
		 * La hauter en passant par la superclasse
		 */
		public function get superHeight ():Number { return super.height; };
		public function set superHeight (value:Number):void
		{
			super.height = value;
		}
		
		/**
		 * La largeur du composant
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
				invalidatePosition();
			}
		}
		
		/**
		 * La hauteur du composant
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
				invalidatePosition();
			}
		}
		
		/**
		 * La largeur minimum
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
				invalidatePosition();
			}
		}
		
		/**
		 * La hauteur minimum
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
				invalidatePosition();
			}
		}
		
		/**
		 * La largeur maximum
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
				invalidatePosition();
			}
		}
		
		/**
		 * La largeur maximum
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
				invalidatePosition();
			}
		}
		
		/**
		 * Position absolue par rapport au haut (peut être NaN)
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
				invalidatePosition();
			}
		}
		
		/**
		 * Position absolue par rapport à la droite (peut être NaN)
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
				invalidatePosition();
			}
		}
		
		/**
		 * Position absolue par rapport au bas (peut être NaN)
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
				invalidatePosition();
			}
		}
		
		/**
		 * Position absolue par rapport à la gauche (peut être NaN)
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
				invalidatePosition();
			}
		}
		
		/**
		 * Centrage horizontal du composant (peut être NaN)
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
				invalidatePosition();
			}
		}
		
		/**
		 * Centrage vertical du composant (peut être NaN)
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
				invalidatePosition();
			}
		}
		
		/**
		 * Le décalage de placement horizontal
		 */
		public function get horizontalOffset ():Number { return _horizontalOffset; }
		public function set horizontalOffset (value:Number):void 
		{
			// Si la valeur est différente
			// Et si la valeur est réelle
			if (value != _horizontalOffset && (value >= 0 || value < 0))
			{
				// Enregistrer la nouvelle valeur
				_horizontalOffset = value;
				
				// Placer
				x = _horizontalOffset + _leftMargin;
				
				// Signaler
				replaced();
				
				// Dispatcher
				_onReplaced.dispatch();
			}
		}
		
		/**
		 * Le décalage de placement vertical
		 */
		public function get verticalOffset ():Number { return _verticalOffset; }
		public function set verticalOffset (value:Number):void 
		{
			// Si la valeur est différente
			// Et si la valeur est réelle
			if (value != _verticalOffset && (value >= 0 || value < 0))
			{
				// Enregistrer la nouvelle valeur
				_verticalOffset = value;
				
				// Placer
				y = _verticalOffset + _topMargin;
				
				// Signaler
				replaced();
				
				// Dispatcher
				_onReplaced.dispatch();
			}
		}
		
		/**
		 * La marge du haut
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
				invalidatePosition();
			}
		}
		
		/**
		 * La marge de droite
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
				invalidatePosition();
			}
		}
		
		/**
		 * La marge du bas
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
				invalidatePosition();
			}
		}
		
		/**
		 * La marge de gauche
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
				invalidatePosition();
			}
		}
		
		/**
		 * Masquer le contenu
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
				invalidatePosition();
			}
		}
		
		/**
		 * La largeur totale du composant (avec les marges, ne peut pas être NaN)
		 */
		public function get totalWidth ():Number { return _leftMargin + _localWidth + _rightMargin };
		
		/**
		 * La hauteur totale du composant (avec les marges, ne peut pas être NaN)
		 */
		public function get totalHeight ():Number { return _topMargin + _localHeight + _bottomMargin };
		
		/**
		 * Si le composant est en rendu bitmap
		 */
		public function get isFlattened ():Boolean { return _isFlattened; }
		
		/**
		 * Si on autorise le redraw par les enfants
		 */
		public function get allowRedraw ():Boolean { return _allowRedraw; }
		
		/**
		 * Le fond généré à la demande (le getter ajoute un background vide par défaut).
		 * Si les styles sont désactivés, le fond ne sera pas créé automatiquement.
		 */
		public function get backgroundImage ():AdvancedBitmap
		{
			// Interdire si on n'a pas les styles
			if (!_styleEnabled)
				return null;
			
			// Si on n'a pas de fond
			if (_backgroundImage == null)
			{
				// On le créé
				_backgroundImage = new AdvancedBitmap();
				
				// Et on le place
				_backgroundImage.place(0, 0, 0, 0).into(this, "background", 0);
			}
			
			// Retourner le fond
			return _backgroundImage;
		}
		public function set backgroundImage (value:AdvancedBitmap):void
		{
			// Si c'est différent
			if (_backgroundImage != value)
			{
				// Si on a déjà un fond
				if (_backgroundImage != null)
				{
					// On le vire
					_backgroundImage.into(null);
				}
				
				// Si la valeur est différent de null
				if (value != null)
				{
					// On enregistre le nouveau
					_backgroundImage = value;
					
					// Et on le place
					_backgroundImage.place(0, 0, 0, 0).into(this, "background", 0);
				}
			}
		}
		
		/**
		 * Whether or not the display object is visible. Display objects that are not visible
		 * are disabled. For example, if visible=false for an InteractiveObject instance,
		 * it cannot be clicked.
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 * @playerversion	Lite 4
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
				invalidatePosition();
				
				// Dispatcher le changement
				_onVisibilityChanged.dispatch();
			}
		}
		
        /**
         * Liste des enfants à ajouter
         */
        public function get children ():Vector.<DisplayObject> { return _children; }
        public function set children (value:Vector.<DisplayObject>):void
        {
			// Si c'est différent
            if (_children != value)
            {
				// On enregistrer
                _children = value;
                
				// Tous les réajouter
                for each (var child:DisplayObject in _children)
                {
                    addChild(child);
                }
            }
        }
		
		/**
		 * Le nom du style associé
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
				invalidateStyle();
			}
		}
		
		/**
		 * Si la stylisation de cet élément est activé.
		 * Désactivé par défaut pour gagner en performances.
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
				invalidateStyle();
			}
		}
		
		/**
		 * Récupérer l'élément stylisable parent
		 */
		public function get parentStylable ():IStylable
		{
			return (parent != null ? parent as IStylable : null);
		}
		
		/**
		 * Si l'élément a été disposé
		 */
		public function get disposed ():Boolean { return _disposed; }
		
		/**
		 * Le style a changé
		 */
		public function get onStyleChanged ():Signal { return _onStyleChanged; }
		
		/**
		 * Lorsque la visibilité de l'élément change
		 */
		public function get onVisibilityChanged ():Signal { return _onVisibilityChanged; }
		
		
		
		/**
		 * Constructeur du composant avec gestion des dimensions
		 */
		public function ResizableComponent ()
		{
			
		}
		
		
		/******************************************
				Initialisation / Destruction
		 ******************************************/
		
		/**
		 * Initialisation du composant
		 */
		override protected function addedHandler (event:Event = null):void
		{
			// Si on a un parent redimensionnable
			if (parent is ResizableComponent)
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
				_watchedParent = (parent as ResizableComponent);
				
				// On écoute les changements
				_watchedParent.onReplaced.add(parentReplacedHandler);
				_watchedParent.onResized.add(parentResizedHandler);
				_watchedParent.onStyleChanged.add(parentStyleChangedHandler);
				_watchedParent.onVisibilityChanged.add(parentVisibilityChangedHandler);
			}
			
			// Invalider le rendu
			//launchRenderPhase();
			
			// Invalider une première fois
			//invalidatePosition();
			//invalidateStyle();
			//launchPreparePhase();
			//preparePhase();
			
			// Relayer
			super.addedHandler(event);
			
			// Préparer le rendu et rafraichir
			preparePhase();
			renderPhase();
		}
		
		/**
		 * Destruction du composant
		 */
		override protected function removedHandler (event:Event):void
		{
			// Ne plus écouter les phases
			removeEventListener(Event.FRAME_CONSTRUCTED, constructHandler);
			stage.removeEventListener(Event.RENDER, renderHandler);
			
			// Si on a déjà été disposé
			if (_disposed)
			{
				// C'est un problème
				Log.error("Multiple dispose detected in ResizableComponent");
			}
			else
			{
				// On est disposé
				_disposed = true;
				
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
				if (_watchedParent != null && _watchedParent.onResized != null)
				{
					_watchedParent.onResized.remove(parentResizedHandler);
					_watchedParent.onReplaced.remove(parentReplacedHandler);
					_watchedParent.onStyleChanged.remove(parentStyleChangedHandler);
					_watchedParent.onVisibilityChanged.remove(parentVisibilityChangedHandler);
				}
				
				// On n'a plus de parent
				_watchedParent = null;
				
				// Relayer
				super.removedHandler(event);
			}
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
		 * Définir la taille du composant.
		 * Valeurs entre 0 et Infinity, NaN pour ignorer une valeur.
		 * @param	pWidth : La largeur
		 * @param	pHeight : La hauteur (entre 0 et Infinity, NaN pour ignorer)
		 * @return this, méthode chaînable
		 */
		public function size (pWidth:Number, pHeight:Number):ResizableComponent
		{
			// Enregistrer les nouvelles dimensions
			if (pWidth >= 0)
				_localWidth = pWidth;
			
			if (pHeight >= 0)
				_localHeight = pHeight;
			
			// Invalider la position
			invalidatePosition();
			
			// Méthode chaînable
			return this;
		}
		
		/**
		 * Placer le composant. Permet de configurer toutes les variables de placement en redispatchant qu'un seul signal.
		 * Valeurs entre -Infinity et Infinity, NaN pour annuler le décallage sur cet axe.
		 * @param	pTop : Le décallage depuis le haut
		 * @param	pRight : Le décallage depuis la droite
		 * @param	pBottom : Le décallage depuis le bas
		 * @param	pLeft : Le décallage depuis la gauche
		 * @return this, méthode chaînable
		 */
		public function place (pTop:Number = NaN, pRight:Number = NaN, pBottom:Number = NaN, pLeft:Number = NaN):ResizableComponent
		{
			// Tout enregistrer
			_top = pTop;
			_right = pRight;
			_bottom = pBottom;
			_left = pLeft;
			
			// Invalider la position
			invalidatePosition();
			
			// Méthode chaînable
			return this;
		}
		
		/**
		 * Placer comme un rectangle (x, y, width, height)
		 * @param	pLeft : Le décallage depuis la gauche
		 * @param	pTop : Le décallage depuis le haut
		 * @param	pWidth : Largeur
		 * @param	pHeight : Hauteur
		 * @return this, méthode chaînable
		 */
		public function rectPlace (pLeft:Number = NaN, pTop:Number = NaN, pWidth:Number = 0, pHeight:Number = 0):ResizableComponent
		{
			// Tout enregistrer
			_left = pLeft;
			_top = pTop;
			_localWidth = pWidth;
			_localHeight = pHeight;
			
			// Invalider la position
			invalidatePosition();
			
			// Méthode chaînable
			return this;
		}
		
		/**
		 * Décaller le contenu du composant (la box ne bougera pas).
		 * Valeurs entre -Infinity et Infinity, NaN pour ignorer une valeur.
		 * @param	pHorizontalOffset : Le décallage horizontal
		 * @param	pVerticalOffset : Le décallage vertical
		 * @return this, méthode chaînable
		 */
		public function offset (pHorizontalOffset:Number = NaN, pVerticalOffset:Number = NaN):ResizableComponent
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
		 * Les tailles minimum
		 * Valeurs entre 0 et Infinity, NaN pour ignorer une valeur.
		 * @param	pMinWidth : La largeur minimum
		 * @param	pMinHeight : La hauteur minimum
		 * @return this, méthode chaînable
		 */
		public function minSize (pMinWidth:Number, pMinHeight:Number):ResizableComponent
		{
			// Si notre paramètres horizontal n'est pas null, on enregistre
			if (pMinWidth >= 0 || pMinWidth < 0)
				_minWidth = Math.max(0, pMinWidth);
			
			// Si notre paramètres vertical n'est pas null, on enregistre
			if (pMinHeight >= 0 || pMinHeight < 0)
				_minHeight = Math.max(0, pMinHeight);
			
			// Invalider la position
			invalidatePosition();
			
			// Méthode chaînable
			return this;
		}
		
		/**
		 * Les tailles maximum
		 * Valeurs entre 0 et Infinity, NaN pour ignorer une valeur.
		 * @param	pMinWidth : La largeur maximum
		 * @param	pMinHeight : La hauteur maximum
		 * @return this, méthode chaînable
		 */
		public function maxSize (pMaxWidth:Number, pMaxHeight:Number):ResizableComponent
		{
			// Si notre paramètres horizontal n'est pas null, on enregistre
			if (pMaxWidth >= 0 || pMaxWidth < 0)
				_maxWidth = Math.max(0, pMaxWidth);
			
			// Si notre paramètres vertical n'est pas null, on enregistre
			if (pMaxHeight >= 0 || pMaxHeight < 0)
				_maxHeight = Math.max(0, pMaxHeight);
			
			// Invalider la position
			invalidatePosition();
			
			// Méthode chaînable
			return this;
		}
		
		/**
		 * Les marges autour de la box de ce composant
		 * @param	pTopMargin : La marge du haut
		 * @param	pRightMargin : La marge de droite
		 * @param	pBottomMargin : La marge du bas
		 * @param	pLeftMargin : La marge de gauche
		 * @return this, méthode chaînable
		 */
		public function margin (pTopMargin:int, pRightMargin:int, pBottomMargin:int, pLeftMargin:int):ResizableComponent
		{
			// Enregistrer les valeurs
			_topMargin = pTopMargin;
			_rightMargin = pRightMargin;
			_bottomMargin = pBottomMargin;
			_leftMargin = pLeftMargin;
			
			// Invalider la position
			invalidatePosition();
			
			// Méthode chaînable
			return this;
		}
		
		/**
		 * Centrer l'élément sur les axes horizontaux et verticaux, par rapport au parent.
		 * Valeurs entre -Infinity et Infinity, NaN pour annuler le décallage sur cet axe.
		 * @param	pHorizontalCenter : Le décallage par rapport au centre horizontal
		 * @param	pVerticalCenter : Le décallage par rapport au centre vertical
		 * @return this, méthode chaînable
		 */
		public function center (pHorizontalCenter:Number = NaN, pVerticalCenter:Number = NaN):ResizableComponent
		{
			// Enregistrer les valeurs
			_horizontalCenter = pHorizontalCenter;
			_verticalCenter = pVerticalCenter;
			
			// Invalider la position
			invalidatePosition();
			
			// Méthode chaînable
			return this;
		}
		
		/**
		 * Spécifier le parent de ce composant
		 * @param	pParent : Le parent auquel ajouter ce composant. Null pour supprimer du parent.
		 * @param	pName : Le nom de ce composant
		 * @param	pAt : A quel niveau (-1 pour au dessus, 0 pour en dessous)
		 * @return this, méthode chaînable
		 */
		public function into (pParent:DisplayObjectContainer, pName:String = "", pAt:int = -1):ResizableComponent
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
		 * Passer ce composant en bitmap
		 * @param	pMatrixScale : Le scale de la matrix (NaN pour ignorer)
		 * @param	pMatrix : La matrice pour le cacheAsBitmap (si différent de null, le scale sera ignoré)
		 * @param	pAllowRedraw : Si on doit bloquer le rafraichissement des enfants pour éviter les redraw
		 * @return this, méthode chaînable
		 */
		public function flatten (pMatrixScale:Number = NaN, pMatrix:Matrix = null, pAllowRedraw:Boolean = true):ResizableComponent
		{
			// Si on va interdire les redraw
			if (!pAllowRedraw)
			{
				// Invalider la position
				invalidatePosition();
				
				// Interdire les redraw
				_allowRedraw = false;
			}
			
			// Appliquer le cacheAsBitmap
			cacheAsBitmap = true;
			
			// Si on a une matrice
			if (pMatrix != null)
			{
				// On l'appliquer
				cacheAsBitmapMatrix = pMatrix;
			}
			
			// Sinon si on a un scale
			else if (pMatrixScale > 0)
			{
				// On applique ce scale
				cacheAsBitmapMatrix = new Matrix(pMatrixScale, 0, 0, pMatrixScale);
			}
			
			// Méthode chaînable
			return this;
		}
		
		/**
		 * Ne plus passer ce composant en bitmap
		 * @return this, méthode chaînable
		 */
		public function unflatten ():ResizableComponent
		{
			// Virer le cacheAsBitmap
			cacheAsBitmap = false;
			cacheAsBitmapMatrix = null;
			
			// Si les redraw étaient interdits
			if (!_allowRedraw)
			{
				// Réautoriser les redraw
				_allowRedraw = true;
				
				// Invalider la position
				invalidatePosition();
			}
			
			// Méthode chaînable
			return this;
		}
		
		/**
		 * Si le composant est interactif
		 * @return this, méthode chaînable
		 */
		public function interactive (pValue:Boolean):ResizableComponent
		{
			// Appliquer
			mouseEnabled = pValue;
			mouseChildren = pValue;
			
			// Méthode chaînable
			return this;
		}
		
		/**
		 * Spécifier un style
		 * @return this, méthode chaînable
		 */
		public function style (pStyleName:String):ResizableComponent
		{
			// Appliquer le style
			styleName = pStyleName;
			
			// Chaînable
			return this;
		}
		
		
		/******************************************
						Invalidation
		 ******************************************/
		
		/**
		 * Invalider la position
		 */
		public function invalidatePosition ():void
		{
			// Si la position n'a pas déjà été invalidée
			if (!_positionInvalidated)
			{
				// On invalide la position
				_positionInvalidated = true;
				
				// Lancer la phase de préparation
				launchPreparePhase();
			}
		}
		
		/**
		 * Invalider le style
		 */
		public function invalidateStyle ():void
		{
			// Si le style n'est pas déjà invalidé
			if (!_styleInvalidated)
			{
				// On invalide le style
				_styleInvalidated = true;
				
				// Lancer la phase de préparation
				launchPreparePhase();
			}
		}
		
		/**
		 * Lancer la phase de préparation
		 */
		protected function launchPreparePhase ():void
		{
			// Si on a un stage et qu'on n'écoute pas déjà la phase de rendu
			if (stage != null && !hasEventListener(Event.FRAME_CONSTRUCTED))
			{
				// Ecouter la sortie de frame
				addEventListener(Event.FRAME_CONSTRUCTED, constructHandler);
			}
		}
		
		/**
		 * Lancer la phase de rendu
		 */
		protected function launchRenderPhase ():void
		{
			// Si on a un stage
			if (stage != null)
			{
				// Ecouter l'entrée en phase de rendu
				stage.addEventListener(Event.RENDER, renderHandler);
				
				// Invalider le stage
				stage.invalidate();
			}
		}
		
		/**
		 * Sortie de frame détéctée
		 */
		protected function constructHandler (event:Event):void
		{
			// Ne plus écouter les rendus
			removeEventListener(Event.FRAME_CONSTRUCTED, constructHandler);
			
			// Phase de préparation
			preparePhase();
		}
		
		/**
		 * Phase de rendu détéctée
		 */
		protected function renderHandler (event:Event):void
		{
			// Ne plus écouter les rendus
			stage.removeEventListener(Event.RENDER, renderHandler);
			
			// Phase de rendu
			renderPhase();
		}
		
		/**
		 * Phase de préparation des données d'affichage
		 */
		protected function preparePhase ():void
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
		
		/**
		 * Phase de rendu de l'affichage
		 */
		protected function renderPhase ():void
		{
			
		}
		
		
		/******************************************
						 Placement
		 ******************************************/
		
		/**
		 * Replacer le composant
		 */
		protected function replace ():void
		{
			// Actualiser selon le flux
			updateFlow();
		}
		
		/**
		 * Replacer selon le flux
		 */
		protected function updateFlow ():void
		{
			// Si on n'autorise pas les redraw
			if (!_allowRedraw || _disposed)
			{
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
		 * Le composant est replacé
		 */
		protected function replaced ():void
		{
			
		}
		
		/**
		 * Le composant est redimentionné
		 */
		protected function resized ():void
		{
			
		}
		
		
		/******************************************
						    Style
		 ******************************************/
		
		/**
		 * Actualiser le style
		 */
		protected function updateStyle ():void
		{
			// Si on a un wrapper et si les styles sont autorisés
			if (wrapper != null && _styleEnabled)
			{
				// Récupérer la liste des styles des parents
				var style:Object = wrapper.styleCentral.getComputedStyleFromStylable(this);
				
				// Injecter le style
				wrapper.styleCentral.injectStyle(this, style);
				
				// Le style a été changé
				styleInjected();
			}
			
			// Signaler que le style a changé
			_onStyleChanged.dispatch();		
		}
		
		/**
		 * Le composant a reçu un nouveau style
		 */
		protected function styleInjected ():void
		{
			
		}
		
		
		/******************************************
						Visibilité
		 ******************************************/
		
		/**
		 * Savoir si cet élément est visible.
		 * Si un parent est en visible false ou si cet élément n'a pas été ajouté à la scène, false sera retourné.
		 */
		public function isVisible ():Boolean
		{
			// Si on n'est pas visible
			if (!_visible)
				return false;
			
			// Si on a un stage
			if (stage != null)
			{
				// Commencer par le parent
				var parent:ResizableComponent = _watchedParent;
				
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
					parent = parent.parent as ResizableComponent;
				}
			}
			
			// On est visible
			return true;
		}
		
		/**
		 * Le composant à changé de visibilité
		 */
		protected function visibilityChanged ():void
		{
			
		}
	}
}