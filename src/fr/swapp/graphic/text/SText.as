package fr.swapp.graphic.text 
{
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.text.AntiAliasType;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.text.TextLineMetrics;
	import fr.swapp.graphic.base.SComponent;
	import fr.swapp.graphic.base.SWrapper;
	
	/**
	 * La classe de base pour tous les champs texte.
	 * @author ZoulouX
	 */
	public class SText extends SComponent 
	{
		/**
		 * La limite du scale pour passer en matrice
		 */
		static public var DEFAULT_CAB_ENABLED		:Boolean 					= false;
		
		/**
		 * La limite du scale pour passer en matrice
		 */
		static public var DEFAULT_SCALE_LIMIT		:Number 					= 1;
		
		/**
		 * Le facteur sur le scale lorsqu'on est au dessus de la limit
		 */
		static public var DEFAULT_SCALE_FACTOR		:Number 					= .75;
		
		
		/**
		 * Le texteField qui va afficher le texte
		 */
		protected var _textField					:TextField;
		
		/**
		 * Taille automatique du composant selon le contenu
		 */
		protected var _autoSize						:Boolean					= false;
		
		/**
		 * Multiligne
		 */
		protected var _multiline					:Boolean					= false;
		
		
		/**
		 * Le textField
		 */
		public function get textField ():TextField { return _textField; }
		
		
		/**
		 * Taille automatique du composant selon le contenu
		 */
		public function get autoSize ():Boolean { return _autoSize; }
		public function set autoSize (value:Boolean):void
		{
			// Si la valeur est différente
			if (_autoSize != value)
			{
				// Enregistrer
				_autoSize = value;
				
				// Actualiser l'autosize
				updateAutoSize();
				
				// Invalider le placement
				invalidatePosition();
			}
		}
		
		/**
		 * Multiligne
		 */
		public function get multiline ():Boolean { return _multiline; }
		public function set multiline (value:Boolean):void 
		{
			// Si la valeur est différente
			if (_multiline != value)
			{
				// Enregistrer
				_multiline = value;
				
				// Utiliser toute la largeur ou non
				_textField.wordWrap = _multiline;
				_textField.multiline = _multiline;
				
				// Actualiser l'autosize
				updateAutoSize();
				
				// Invalider le placement
				invalidatePosition();
			}
		}
		
		/**
		 * Si le texte est séléctionnable
		 */
		public function get selectable ():Boolean { return _textField.selectable; }
		public function set selectable (value:Boolean):void 
		{
			_textField.selectable = value;
		}
		
		/**
		 * La valeur du champs texte
		 */
		public function get value ():String { return _textField.text; }
		public function set value (value:String):void 
		{
			// Si c'est différent
			if (_textField.text != value)
			{
				// Appliquer le texte
				_textField.text = value;
				
				// Invalider le placement
				invalidatePosition();
			}
		}
		
		/**
		 * La transparence (reportée directement sur le textField)
		 */
		override public function get alpha ():Number { return _textField.alpha; }
		override public function set alpha (value:Number):void
		{
			_textField.alpha = value;
		}
		
		/**
		 * Si on doit afficher la bordure
		 */
		public function get showBorder ():Boolean { return _textField.border; }
		public function set showBorder (value:Boolean):void
		{
			_textField.border = value;
		}
		
		/**
		 * La couleur de la bordure
		 */
		public function get borderColor ():uint { return _textField.borderColor; }
		public function set borderColor (value:uint):void
		{
			_textField.borderColor = value;
		}
		
		/**
		 * Si on doit utiliser un antialias avancé (optimisé pour la lisibilité des textes de petite taille)
		 */
		public function get advancedAntiAlias ():Boolean { return _textField.antiAliasType == AntiAliasType.ADVANCED; }
		public function set advancedAntiAlias (value:Boolean):void
		{
			_textField.antiAliasType = value ? AntiAliasType.ADVANCED : AntiAliasType.NORMAL;
		}
		
		/**
		 * Si on doit utiliser les typos embarquées
		 */
		public function get embedFonts ():Boolean { return _textField.embedFonts; }
		public function set embedFonts (value:Boolean):void
		{
			// Si c'est différent
			if (_textField.embedFonts != value)
			{
				// Enregistrer
				_textField.embedFonts = value;
				
				// Invalider le placement
				invalidatePosition();
			}
		}
		
		
		/**
		 * Le constructeur
		 */
		public function SText ()
		{
			// TODO : Vérifier le snapToPixels avec l'aligne center (peut être qu'il faut décaller d'un demi justement)
			// TODO : Vérifier la propagation des positions / dimensions qui ont l'air foireuses dès qu'on veut aligner des éléments avec un texte
			
			// Snap to pixels
			_snapToPixels = true;
			
			// Activer les styles
			_styleEnabled = true;
			
			// Construire le textField
			buildTextField();
		}
		
		
		/**
		 * Construire le textField
		 */
		protected function buildTextField ():void
		{
			// Créer le textField
			_textField = new TextField();
			_textField.width = 0;
			_textField.height = 0;
			
			// Le configurer
			_textField.mouseWheelEnabled = false;
			_textField.selectable = false;
			_textField.mouseEnabled = false;
			
			// Activer le cache as bitmap sur le texte
			enableFlatText();
			
			// L'ajouter
			addChild(_textField);
		}
		
		/**
		 * Initialisation
		 */
		override public function init ():void 
		{
			// Force render
			renderPhase();
			
			// Relayer
			super.init();
		}
		
		/**
		 * Activer le cache as bitmap
		 */
		protected function enableFlatText ():void
		{
			// Si le CAB est activé
			if (DEFAULT_CAB_ENABLED && _wrapper)
			{
				// Récupérer le facteur d'échelle
				var scaleFactor:Number = _wrapper.ratio;
				
				// S'il est supérieur à la densité par défaut
				if (scaleFactor > DEFAULT_SCALE_LIMIT)
				{
					// On le réduit en le limitant au scale par défaut
					scaleFactor = Math.max(DEFAULT_SCALE_LIMIT, scaleFactor * DEFAULT_SCALE_FACTOR);
					
					// Et on applique la matrice sur le textField
					_textField.cacheAsBitmapMatrix = new Matrix(scaleFactor, 0, 0, scaleFactor);
				}
				
				// Activer le stockage bitmap
				_textField.cacheAsBitmap = true;
			}
		}
		
		/**
		 * Bordure sur le texte (par défaut une bordure de debug)
		 * @param	pBorder : Si on doit afficher la bordure
		 * @param	pBorderColor : La couleur de la bordure à afficher
		 */
		public function border (pBorder:Boolean = true, pBorderColor:Number = 0xFF0000):SText
		{
			// Appliquer
			_textField.border = pBorder;
			_textField.borderColor = pBorderColor;
			
			// Méthode chaînable
			return this;
		}
		
		/**
		 * Définir l'affichage de la font
		 * @param	pEmbedFont : Si on doit utiliser les typos embarquées
		 * @param	pAdvancedAntiAlias : Si on doit utiliser l'antialiasing avancé
		 */
		public function fontRender (pEmbedFont:Boolean, pAdvancedAntiAlias:Boolean):SText
		{
			// Appliquer sur le textField
			embedFonts = pEmbedFont;
			advancedAntiAlias = pAdvancedAntiAlias;
			
			// Méthode chaînable
			return this;
		}
		
		/**
		 * Actualiser l'autosize
		 */
		protected function updateAutoSize ():void
		{
			if (_autoSize)
			{
				_textField.autoSize = TextFieldAutoSize.LEFT;
			}
			else
			{
				_textField.autoSize = TextFieldAutoSize.NONE;
			}
		}
		
		/**
		 * Définir le texte affiché (pas d'HTML)
		 * @param	pValue : Le texte à afficher
		 */
		public function text (pValue:String):SText
		{
			// Si on a une valeur définie et différente
			if (pValue != null && _textField.text != pValue)
			{
				// Appliquer
				_textField.text = pValue;
				
				// Invalider le placement
				invalidatePosition();
			}
			
			// Méthode chaînable
			return this;
		}
		
		/**
		 * Ajouter du texte (pas d'HTML)
		 * @param	pValue : Le texte à ajouter
		 */
		public function append (pValue:String):SText
		{
			// Si on a une valeur
			if (pValue != null)
			{
				// Appliquer
				_textField.appendText(pValue);
				
				// Invalider le placement
				invalidatePosition();
			}
			
			// Méthode chaînable
			return this;
		}
		
		/**
		 * Définir le texte HTML affiché
		 * @param	pValue : Le texte HTML à afficher
		 */
		public function html (pValue:String):SText
		{
			// Si on a une valeur définie et différente
			if (pValue != null && _textField.htmlText != pValue)
			{
				// Appliquer
				_textField.htmlText = pValue;
				
				// Invalider le placement
				invalidatePosition();
			}
			
			// Méthode chaînable
			return this;
		}
		
		/**
		 * Besoin d'être replacé
		 */
		override protected function replace ():void
		{
			// Si on est en taille automatique
			if (_autoSize)
			{
				// Si on est en multiligne
				if (_multiline)
				{
					// Si la hauteur est différente
					if (_localHeight != _textField.height)
					{
						// On spécifie la hauteur
						_localHeight = _textField.height;
					}
				}
				else
				{
					// On récupère les mesures de la première ligne
					var metrics:TextLineMetrics = _textField.getLineMetrics(0);
					
					// On applique la hauteur au textField
					if (_textField.height != metrics.height)
					{
						_textField.height = metrics.height;
					}
					
					// Si la taille du composant est différente de la taille du texte
					if (_localWidth != _textField.width || _localHeight != _textField.height)
					{
						// La taille du composant est selon le texte
						_localWidth = _textField.width;
						_localHeight = _textField.height;
					}
				}
				
				// Replacer l'élément
				updateFlow();
				
				// Si on est en multiligne
				if (_multiline)
				{
					// Imposer la largeur
					if (_textField.width != _localWidth)
					{
						_textField.width = _localWidth;
					}
				}
			}
			else
			{
				// Replacer l'élément
				updateFlow();
				
				// Appliquer les dimensions du composant sur le textField
				_textField.width = _localWidth;
				_textField.height = _localHeight;
			}
		}
	}
}