package fr.swapp.graphic.base 
{
	import flash.display.BitmapData;
	import flash.display.CapsStyle;
	import flash.display.GradientType;
	import flash.display.JointStyle;
	import flash.display.LineScaleMode;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import fr.swapp.graphic.atlas.SAtlasItem;
	import fr.swapp.graphic.errors.GraphicalError;
	
	// TODO : Importer et utiliser IAtlasItem au lieu de SAtlasItem

	/**
	 * @author ZoulouX
	 */
	public class SGraphic extends SComponent 
	{
		/**
		 * Le bitmapData pour le fond (null pour utiliser la couleur de fond)
		 */
		protected var _bitmapData						:BitmapData;
		
		/**
		 * Le mode de rendu de l'image
		 */
		protected var _renderMode						:String;
		
		/**
		 * Background color 1
		 */
		protected var _backgroundColor1					:int								= 0;
		
		/**
		 * Background color 2
		 */
		protected var _backgroundColor2					:int								= 0;
		
		/**
		 * Background opacity 1
		 */
		protected var _backgroundAlpha1					:Number								= 1;
		
		/**
		 * Background opacity 2
		 */
		protected var _backgroundAlpha2					:Number								= 1;
		
		/**
		 * Type of background (accepted values from ABackgroundType)
		 */
		protected var _backgroundType					:String								= SBackgroundType.NONE;
		
		/**
		 * La taille du contour (0 pour pas de contour)
		 */
		protected var _borderSize						:Number								= 0;
		
		/**
		 * La couleur du contour (noir par défaut)
		 */
		protected var _borderColor						:uint								= 0x000000;
		
		/**
		 * L'alpha du contour
		 */
		protected var _borderAlpha						:Number								= 1;
		
		
		/**
		 * Arrondi d'en haut à gauche (0 pour dessiner un rectangle)
		 */
		protected var _topLeftRadius					:int;
		
		/**
		 * Arrondi d'en haut à droite (0 pour dessiner un rectangle)
		 */
		protected var _topRightRadius					:int;
		
		/**
		 * Arrondi d'en bas à droite (0 pour dessiner un rectangle)
		 */
		protected var _bottomRightRadius				:int;
		
		/**
		 * Arrondi d'en bas à gauche (0 pour dessiner un rectangle)
		 */
		protected var _bottomLeftRadius					:int;
		
		
		/**
		 * La matrice de transformation
		 */
		protected var _matrix							:Matrix								= new Matrix();
		
		/**
		 * Autoriser les dépassements sur les mode INSIDE et OUTSIDE
		 */
		protected var _allowOverflow					:Boolean							= false;
		
		/**
		 * Décallage du dessin en X
		 */
		protected var _xDrawDecay						:Number;
		
		/**
		 * Décallage du dessin en Y
		 */
		protected var _yDrawDecay						:Number;
		
		/**
		 * La densité de l'image. Par exemple si l'image est en format retina, la densité sera de 2.
		 */
		protected var _density							:Number;
		
		/**
		 * Le décallage horizontal de l'image
		 */
		protected var _bitmapHorizontalOffset			:int;
		
		/**
		 * Le décallage vertical de l'image
		 */
		protected var _bitmapVerticalOffset				:int;
		
		/**
		 * Les coordonnées des tranches a suivre pour le découpage
		 */
		protected var _slices							:Rectangle;
		
		/**
		 * La couleur limite pour le découpage
		 */
		protected var _cutThreshold						:uint							= 0x777777;
		
		/**
		 * Lisser l'image
		 */
		protected var _smoothing						:Boolean						= true;
		
		/**
		 * Si le dessin est invalidé
		 */
		protected var _drawInvalidated					:Boolean						= false;
		
		/**
		 * AtlasItem to show
		 */
		protected var _atlasItem						:SAtlasItem;
		
		/**
		 * Image inner offset from all sides
		 */
		protected var _frameOffset						:uint;
		
		/**
		 * Show only wires
		 */
		protected var _wireFrames						:int							= -1;
		
		/**
		 * Pivot point X position
		 */
		protected var _pivotX							:Number							= 0;
		
		/**
		 * Pivot point Y position
		 */
		protected var _pivotY							:Number							= 0;
		
		
		/**
		 * Le bitmapData pour le fond (null pour utiliser la couleur de fond)
		 */
		public function get bitmapData ():BitmapData { return _bitmapData; }
		public function set bitmapData (value:BitmapData):void 
		{
			// Si c'est différent
			if (value != _bitmapData)
			{
				// Enregistrer
				_bitmapData = value;
				
				// Rendre la position invalide
				_positionInvalidated = true;
				
				// Rendre le dessin invalide
				_drawInvalidated = true;;
			}
		}
		
		/**
		 * Le mode de rendu de l'image
		 */
		public function get renderMode ():String { return _renderMode; }
		public function set renderMode (value:String):void 
		{
			// Si c'est différent
			if (_renderMode != value)
			{
				// Enregistrer le nouveau mode
				_renderMode = value;
				
				// Vérifier le nouveau renderMode
				if (!checkRenderMode())
				{
					// S'il n'est pas bon on déclenche un erreur
					throw new GraphicalError("SGraphic.renderMode", "Invalid render mode.");
					return;
				}
				
				// Si on est en mode auto slice
				if (_renderMode == SRenderMode.AUTO_SCALE_RENDER)
				{
					// Slicer
					autoSlice();
				}
				
				// Rendre la position invalide
				_positionInvalidated = true;
				
				// Rendre le dessin invalide
				_drawInvalidated = true;;
			}
		}
		
		/**
		 * Background first color.
		 */
		public function get backgroundColor1 ():int { return _backgroundColor1; }
		public function set backgroundColor1 (value:int):void 
		{
			// Si c'est différent
			if (_backgroundColor1 != value)
			{
				// Enregistrer
				_backgroundColor1 = value;
				
				// Rendre le dessin invalide
				_drawInvalidated = true;;
			}
		}
		
		/**
		 * Background second color.
		 */
		public function get backgroundColor2 ():int { return _backgroundColor2; }
		public function set backgroundColor2 (value:int):void 
		{
			// Si c'est différent
			if (_backgroundColor2 != value)
			{
				// Enregistrer
				_backgroundColor2 = value;
				
				// Rendre le dessin invalide
				_drawInvalidated = true;;
			}
		}
		
		/**
		 * Background first opacity.
		 */
		public function get backgroundAlpha1 ():Number { return _backgroundAlpha1; }
		public function set backgroundAlpha1 (value:Number):void 
		{
			// Si c'est différent
			if (_backgroundAlpha1 != value)
			{
				// Enregistrer
				_backgroundAlpha1 = value;
				
				// Rendre le dessin invalide
				_drawInvalidated = true;;
			}
		}
		
		/**
		 * Background second opacity.
		 */
		public function get backgroundAlpha2 ():Number { return _backgroundAlpha2; }
		public function set backgroundAlpha2 (value:Number):void 
		{
			// Si c'est différent
			if (_backgroundAlpha2 != value)
			{
				// Enregistrer
				_backgroundAlpha2 = value;
				
				// Rendre le dessin invalide
				_drawInvalidated = true;;
			}
		}
		
		
		/**
		 * Type of background (accepted values from ABackgroundType)
		 */
		public function get backgroundType ():String { return _backgroundType; }
		public function set backgroundType (value:String):void
		{
			// Si c'est différent
			if (_backgroundType != value)
			{
				// Enregistrer
				_backgroundType = value;
				
				// Invalider le dessin
				_drawInvalidated = true;;
			}
		}
		
		/**
		 * La taille du contour (0 pour pas de contour)
		 */
		public function get borderSize ():Number { return _borderSize; }
		public function set borderSize (value:Number):void 
		{
			// Si c'est différent
			if (_borderSize != value)
			{
				// Enregistrer
				_borderSize = value;
				
				// Rendre le dessin invalide
				_drawInvalidated = true;;
			}
		}
		
		/**
		 * La couleur du contour (noir par défaut)
		 */
		public function get borderColor ():uint { return _borderColor; }
		public function set borderColor (value:uint):void 
		{
			// Si c'est différent
			if (_borderColor != value)
			{
				// Enregistrer
				_borderColor = value;
				
				// Rendre le dessin invalide
				_drawInvalidated = true;;
			}
		}
		
		/**
		 * L'alpha du contour
		 */
		public function get borderAlpha ():Number { return _borderAlpha; }
		public function set borderAlpha (value:Number):void 
		{
			// Si c'est différent
			if (_borderAlpha != value)
			{
				// Enregistrer
				_borderAlpha = value;
				
				// Rendre le dessin invalide
				_drawInvalidated = true;;
			}
		}
		
		
		/**
		 * Arrondi d'en haut à gauche (0 pour dessiner un rectangle)
		 */
		public function get topLeftRadius ():int { return _topLeftRadius; }
		public function set topLeftRadius (value:int):void 
		{
			// Si c'est différent
			if (_topLeftRadius != value)
			{
				// Enregistrer
				_topLeftRadius = value;
				
				// Rendre le dessin invalide
				_drawInvalidated = true;;
			}
		}
		
		/**
		 * Arrondi d'en haut à droite (0 pour dessiner un rectangle)
		 */
		public function get topRightRadius ():int { return _topRightRadius; }
		public function set topRightRadius (value:int):void 
		{
			// Si c'est différent
			if (_topRightRadius != value)
			{
				// Enregistrer
				_topRightRadius = value;
				
				// Rendre le dessin invalide
				_drawInvalidated = true;;
			}
		}
		
		/**
		 * Arrondi d'en bas à droite (0 pour dessiner un rectangle)
		 */
		public function get bottomRightRadius ():int { return _bottomRightRadius; }
		public function set bottomRightRadius (value:int):void 
		{
			// Si c'est différent
			if (_bottomRightRadius != value)
			{
				// Enregistrer
				_bottomRightRadius = value;
				
				// Rendre le dessin invalide
				_drawInvalidated = true;;
			}
		}
		
		/**
		 * Arrondi d'en bas à gauche (0 pour dessiner un rectangle)
		 */
		public function get bottomLeftRadius ():int { return _bottomLeftRadius; }
		public function set bottomLeftRadius (value:int):void 
		{
			// Si c'est différent
			if (_bottomLeftRadius != value)
			{
				// Enregistrer
				_bottomLeftRadius = value;
				
				// Rendre le dessin invalide
				_drawInvalidated = true;;
			}
		}
		
		
		/**
		 * Lisser l'image.
		 */
		public function get smoothing ():Boolean { return _smoothing; }
		public function set smoothing (value:Boolean):void 
		{
			// Si c'est différent
			if (_smoothing != value)
			{
				// Enregistrer
				_smoothing = value;
				
				// Rendre le dessin invalide
				_drawInvalidated = true;;
			}
		}
		
		/**
		 * Autoriser les dépassements de l'image par rapport aux règles de placement.
		 */
		public function get allowOverflow ():Boolean { return _allowOverflow; }
		public function set allowOverflow (value:Boolean):void 
		{
			// Si c'est différent
			if (_allowOverflow != value)
			{
				// Enregistrer
				_allowOverflow = value;
				
				// Rendre le dessin invalide
				_drawInvalidated = true;;
			}
		}
		
		/**
		 * La densité de l'image. Par exemple si l'image est en format retina, la densité sera de 2.
		 */
		public function get density ():Number { return _density; }
		public function set density (value:Number):void
		{
			// Si c'est différent et supérieure à 0
			if (_density != value && value > 0)
			{
				// Enregistrer
				_density = value;
				
				// Rendre la position invalide
				_positionInvalidated = true;
				
				// Rendre le dessin invalide
				_drawInvalidated = true;;
			}
		}
		
		/**
		 * Le décallage horizontal de l'image.
		 */
		public function get bitmapHorizontalOffset ():int { return _bitmapHorizontalOffset; }
		public function set bitmapHorizontalOffset (value:int):void
		{
			// Si on a un bitmapData
			if (_bitmapData != null)
			{
				// On gère le modulo pour le repeat
				// Cette technique évite pas mal d'overhead sur le renderMode GPU en repeat
				value %= _bitmapData.width;
			}
			
			// Si c'est différent
			if (_bitmapHorizontalOffset != value)
			{
				// Enregistrer
				_bitmapHorizontalOffset = value;
				
				// Rendre le dessin invalide
				_drawInvalidated = true;;
			}
		}
		
		/**
		 * Le décallage vertical de l'image.
		 */
		public function get bitmapVerticalOffset ():int { return _bitmapVerticalOffset; }
		public function set bitmapVerticalOffset (value:int):void
		{
			// Si on a un bitmapData
			if (_bitmapData != null)
			{
				// On gère le modulo pour le repeat
				// Cette technique évite pas mal d'overhead sur le renderMode GPU en repeat
				value %= _bitmapData.height;
			}
			
			// Si c'est différent
			if (_bitmapVerticalOffset != value)
			{
				// Enregistrer
				_bitmapVerticalOffset = value;
				
				// Rendre le dessin invalide
				_drawInvalidated = true;;
			}
		}
		
		/**
		 * Les coordonnées des tranches a suivre pour le découpage
		 */
		public function get slices ():Rectangle { return _slices; }
		public function set slices (value:Rectangle):void
		{
			_slices = value;
		}
		
		/**
		 * La couleur limite pour le découpage.
		 * La modification de cette valeur ne redéclenchera pas le découpage.
		 */
		public function get cutThreshold ():uint { return _cutThreshold; }
		public function set cutThreshold (value:uint):void
		{
			_cutThreshold = value;
		}
		
		/**
		 * AtlasItem to show, null to cancel atlas rendering. Warning, only these SRenderMode will work :
		 * - STRETCH
		 * - AUTO_SIZE
		 * - HORIZONTAL_SCALE_3_RENDER
		 * - VERTICAL_SCALE_3_RENDER
		 * - SCALE_9_RENDER
		 */
		public function get atlasItem ():SAtlasItem  { return _atlasItem; }
		public function set atlasItem (value:SAtlasItem):void 
		{
			// Si c'est différent
			if (value != _atlasItem)
			{
				// Enregistrer la valeur
				_atlasItem = value;
				
				// Actualiser l'atlas
				updateAtlas("atlasItem");
			}
		}
		
		/**
		 * Image inner offset from all sides
		 */
		public function get frameOffset ():uint { return _frameOffset; }
		public function set frameOffset (value:uint):void
		{
			// Si c'est différent
			if (value != _frameOffset)
			{
				// On enregistre
				_frameOffset = value;
				
				// Besoin de rafraichir l'image
				_drawInvalidated = true;;
			}
		}
		
		/**
		 * Show only wires (-1 to avoid)
		 */
		public function get wireFrames ():int { return _wireFrames; }
		public function set wireFrames (value:int):void
		{
			// Si c'est différent
			if (value != _wireFrames)
			{
				// On enregistre
				_wireFrames = value;
				
				// Besoin de rafraichir l'image
				_drawInvalidated = true;;
			}
		}
		
		/**
		 * Pivot point X poisition
		 */
		public function get pivotX ():Number { return _pivotX; }
		public function set pivotX (value:Number):void
		{
			// Si c'est différent
			if (value != _pivotX)
			{
				// Enregistrer la valeur
				_pivotX = value;
				
				// Appliquer l'offset
				super.horizontalOffset = _horizontalOffset + _pivotX;
				
				// Besoin de rafraichir l'image
				_drawInvalidated = true;;
			}
		}
		
		/**
		 * Pivot point Y poisition
		 */
		public function get pivotY ():Number { return _pivotY; }
		public function set pivotY (value:Number):void
		{
			// Si c'est différent
			if (value != _pivotY)
			{
				// Enregistrer la valeur
				_pivotY = value;
				
				// Appliquer l'offset
				super.horizontalOffset = _horizontalOffset + _pivotY;
				
				// Besoin de rafraichir l'image
				_drawInvalidated = true;;
			}
		}
		
		/**
		 * Horizontal offset from the flow (0 to ignore)
		 */
		override public function get horizontalOffset ():Number { return _horizontalOffset - _pivotX; }
		override public function set horizontalOffset (value:Number):void 
		{
			// Relayer en ajoutant la valeur du pivot de manière transparent
			super.horizontalOffset = value + _pivotX;
		}
		
		/**
		 * Vertical offset from the flow (0 to ignore)
		 */
		override public function get verticalOffset ():Number { return _verticalOffset - _pivotY; }
		override public function set verticalOffset (value:Number):void 
		{
			// Relayer en ajoutant la valeur du pivot de manière transparent
			super.horizontalOffset = value + _pivotY;
		}
		
		
		/**
		 * Constructor.
		 * Set texture to draw. If pSource is null, it will be ignored.
		 * pSource can be BitmapData or SAtlasItem. Please see corresponding documentations (for SGraphic.atlas and SGraphic.image methods).
		 * Set renderMode to specify how the texture will fit in this component.
		 * @param	pSource : Texture to be drawn. Null to ignore.
		 * @param	pRenderMode : RenderMode from SRenderMode to fit texture in this component.
		 * @param	pDensity : Pixels density of the texture. Default is 1.
		 * @param	pAutoSetLimitSize : Automatically set min and max size to respect scale9-3 ratios. (only for atlas)
		 */
		public function SGraphic (pSource:Object = null, pRenderMode:String = null, pDensity:Number = 1, pAutoSetLimitSize:Boolean = false)
		{
			// Vérifier si on a une source
			if (pSource != null)
			{
				// Si c'est un bitmap
				if (pSource is BitmapData)
				{
					image(pSource as BitmapData, pRenderMode, pDensity);
				}
				
				// Si c'est un atlas
				else if (pSource is SAtlasItem)
				{
					atlas(pSource as SAtlasItem, pRenderMode, pDensity, pAutoSetLimitSize);
				}
				
				else
				{
					// On nous a passé une mauvaise source
					throw new GraphicalError("SGraphic.construct", "Bad source format. (accepted formats are BitmapData and SAtlasItem.)");
				}
			}
		}
		
		
		/******************************************
					  Méthodes ouvertes
		 ******************************************/
		
		/**
		 * Set texture to draw. If pBitmapData is null, it will be ignored.
		 * Set renderMode to specify how the texture will fit in this component.
		 * Set density for retina images for exemple.
		 * @param	pBitmapData : Texture to be drawn. Null to ignore.
		 * @param	pRenderMode : RenderMode from SRenderMode to fit texture in this component.
		 * @param	pDensity : Density of the texture.
		 */
		public function image (pBitmapData:BitmapData = null, pRenderMode:String = null, pDensity:Number = 1):void
		{
			// Enregistrer le mode de rendu
			_renderMode = pRenderMode;
			
			// Enregistrer la densité
			_density = pDensity;
			
			// Définir la texture par son setter pour tout invalider et définir le besoin d'une image ou non
			bitmapData = pBitmapData;
		}
		
		/**
		 * Set image drawing offset
		 * @param	pHorizontalOffset : Horizontal offset
		 * @param	pVerticalOffset : Vertical offset
		 * @return this
		 */
		public function bitmapOffset (pHorizontalOffset:int, pVerticalOffset:int):SGraphic
		{
			// Enregistrer les valeurs
			bitmapHorizontalOffset = pHorizontalOffset;
			bitmapVerticalOffset = pVerticalOffset;
			
			// Méthode chaînable
			return this;
		}
		
		/**
		 * Set a background color to this component.
		 * @param	pBackgroundColor1 : First color of the background
		 * @param	pBackgroundAlpha1 : First background alpha
		 * @param	pBackgroundType : Type of background (accepted values from SBackgroundType, default is flat)
		 * @param	pBackgroundColor2 : Second color of the background (ignored in SBackgroundType.FLAT)
		 * @param	pBackgroundAlpha2 : Second background alpha (ignored in SBackgroundType.FLAT)
		 * @return this
		 */
		public function background (pBackgroundColor1:int = 0, pBackgroundAlpha1:Number = 1, pBackgroundType:String = "flat", pBackgroundColor2:int = 0, pBackgroundAlpha2:Number = 1):SGraphic
		{
			// Enregistrer
			_backgroundColor1 = pBackgroundColor1;
			_backgroundColor2 = pBackgroundColor2;
			_backgroundAlpha1 = pBackgroundAlpha1;
			_backgroundAlpha2 = pBackgroundAlpha2;
			
			// Enregistrer le type de background
			_backgroundType = pBackgroundType;
			
			// Invalider le dessin
			_drawInvalidated = true;;
			
			// Méthode chaînable
			return this;
		}
		
		/**
		 * Le contour.
		 * @param	pBorderSize : La taille du contour (0 ou NaN pour aucun contour)
		 * @param	pBorderColor : La couleur du contour
		 * @param	pBorderAlpha : La transparence du contour
		 * @return this
		 */
		public function border (pBorderSize:Number, pBorderColor:uint = 0, pBorderAlpha:Number = 1):SGraphic
		{
			// Enregistrer
			_borderSize = pBorderSize;
			_borderColor = pBorderColor;
			_borderAlpha = pBorderAlpha;
			
			// Rendre le dessin invalide
			_drawInvalidated = true;;
			
			// Méthode chaînable
			return this;
		}
		
		/**
		 * Bordures arrondies individuelles
		 * @param	pTopLeftRadius : La taille de l'arrondis du coin d'en haut à gauche
		 * @param	pTopRightRadius : La taille de l'arrondis du coin d'en haut à droite
		 * @param	pBottomRightRadius : La taille de l'arrondis du coin d'en bas à droite
		 * @param	pBottomLeftRadius : La taille de l'arrondis du coin d'en haut à gauche
		 * @param	pOnlyFirst : If only the first value is applyed to all corners.
		 * @return this
		 */
		public function radius (pTopLeftRadius:int, pTopRightRadius:int = 0, pBottomRightRadius:int = 0, pBottomLeftRadius:int = 0, pOnlyFirst:Boolean = true):SGraphic
		{
			// Si on doit prendre que la première valeur
			if (pOnlyFirst)
			{
				pTopRightRadius = pBottomLeftRadius = pBottomRightRadius = pTopLeftRadius;
			}
			
			// Enregistrer
			_topLeftRadius 		= pTopLeftRadius;
			_topRightRadius 	= pTopRightRadius;
			_bottomRightRadius 	= pBottomRightRadius;
			_bottomLeftRadius 	= pBottomLeftRadius;
			
			// Rendre le dessin invalide
			_drawInvalidated = true;;
			
			// Méthode chaînable
			return this;
		}
		
		/**
		 * Pivot point
		 * @param	pPivotX : X position of the pivot point.
		 * @param	pPivotY : Y position of the pivot point.
		 * @return this
		 */
		public function pivot (pPivotX:Number = 0, pPivotY:Number = 0):SGraphic
		{
			// Enregistrer les valeurs
			_pivotX = pPivotX;
			_pivotY = pPivotY;
			
			// Appliquer les offsets
			super.horizontalOffset = _horizontalOffset + _pivotX;
			super.verticalOffset = _verticalOffset + _pivotY;
			
			// Rendre le dessin invalide
			_drawInvalidated = true;;
			
			// Méthode chaînable
			return this;
		}
		
		/**
		 * AtlasItem to show, null to cancel atlas rendering. Warning, only these SRenderMode will work :
		 * - STRETCH
		 * - AUTO_SIZE
		 * - HORIZONTAL_SCALE_3_RENDER
		 * - VERTICAL_SCALE_3_RENDER
		 * - SCALE_9_RENDER
		 * - AUTO_SCALE_RENDER
		 * @param	pAtlasItem : AtlasItem to show. Set to null to disable Atlas rendering.
		 * @param	pRenderMode : Render mode to use if AtlasItem is provided, not all available with atlas mode. Default is AUTO_SIZE.
		 * @param	pDensity : Pixels density of the texture. Default is 1.
		 * @param	pAutoSetLimitSize : Automatically set min and max size to respect scale9-3 ratios.
		 */
		public function atlas (pAtlasItem:SAtlasItem, pRenderMode:String = "autoSize", pDensity:Number = 1, pAutoSetLimitSize:Boolean = false):SGraphic
		{
			// Enregistrer l'item
			_atlasItem = pAtlasItem;
			
			// Enregistrer la densité
			_density = pDensity;
			
			// Si on a un atlas
			if (_atlasItem != null)
			{
				// Appliquer le mode de rendu
				_renderMode = pRenderMode;
			}
			
			// Actualiser
			updateAtlas("atlas");
			
			// Si on est en mode auto scale
			if (_renderMode == SRenderMode.AUTO_SCALE_RENDER)
			{
				// On applique l'autoSlice
				autoSlice(pAutoSetLimitSize);
			}
			
			// Méthode chaînable
			return this;
		}
		
		/**
		 * Check validity of provided SRenderMode.
		 * Will return false if provided SRenderMode is invalid.
		 */
		protected function checkRenderMode ():Boolean
		{
			return (
				// Si c'est un des modes de rendu compatible avec ou sans atlas
				_renderMode == SRenderMode.AUTO_SIZE
				||
				_renderMode == SRenderMode.STRECH
				||
				_renderMode == SRenderMode.HORIZONTAL_SCALE_3_RENDER
				||
				_renderMode == SRenderMode.VERTICAL_SCALE_3_RENDER
				||
				_renderMode == SRenderMode.SCALE_9_RENDER
				||
				_renderMode == SRenderMode.AUTO_SCALE_RENDER
				||
				(
					// Sinon si on n'a pas d'atlas
					_atlasItem == null ? (
						// Et que c'est un des modes de rendu compatible sans atlas
						_renderMode == SRenderMode.CENTER
						||
						_renderMode == SRenderMode.INSIDE
						||
						_renderMode == SRenderMode.NO_SCALE
						||
						_renderMode == SRenderMode.OUTSIDE
						||
						_renderMode == SRenderMode.REPEAT
					)
					
					// Sinon c'est qu'on a un atlas avec un mode incompatible
					: false
				)
			)
		}
		
		/**
		 * Update atlas properties from atlas item
		 */
		protected function updateAtlas (pFromMethodName:String = null):void
		{
			// TODO : AtlasItem stretch mode ne marche pas
			// TODO : Vérifier AtlasItem autoSize avec density
			
			// Si on a un item
			if (_atlasItem != null)
			{
				// Appliquer les valeurs de l'atlas
				_bitmapData = _atlasItem.associatedAtlas.bitmapData;
				_density = _atlasItem.associatedAtlas.density;
				_bitmapHorizontalOffset = - _atlasItem.x / _density;
				_bitmapVerticalOffset = - _atlasItem.y / _density;
				
				// Vérifier le renderMode
				if (!checkRenderMode())
				{
					// déclencher une erreur
					throw new GraphicalError("SGraphic." + (pFromMethodName == null ? "updateAtlas" : pFromMethodName), "Atlas setted with incompatible RenderMode.");
					return;
				}
			}
			else
			{
				// Remettre les valeurs modifiées par l'atlas à leurs valeurs par défaut
				_bitmapData = null;
				_density = 1;
				_bitmapHorizontalOffset = 0;
				_bitmapVerticalOffset = 0;
			}
			
			// Invalider le dessin
			_drawInvalidated = true;;
		}
		
		/**
		 * Auto-slice current bitmapData.
		 * RenderMode will be changed.
		 * FrameOffset will be changed.
		 * @param	pAutoSetLimitSize : Automatically set min and max size to respect scale9-3 ratios.
		 * @param	pCutThreshold : Limit color between black and white
		 */
		public function autoSlice (pAutoSetLimitSize:Boolean = false, pCutThreshold:uint = 0x777777):void
		{
			// Vérifier si on a un bitmapData
			if (_bitmapData == null)
			{
				// Sinon on déclenche une erreur
				throw new GraphicalError("SGraphic.autoSlice", "Can't slice a null bitmapData.");
				return;
			}
			
			// Les positions et dimensions
			var bitmapWidth		:uint	= 0;
			var bitmapHeight	:uint	= 0;
			var bitmapOriginX	:uint	= 0;
			var bitmapOriginY	:uint	= 0;
			
			// Si on est sur un atlas
			if (_atlasItem != null)
			{
				// Récupérer les valeurs de l'atlas
				bitmapWidth = _atlasItem.width;
				bitmapHeight = _atlasItem.height;
				bitmapOriginX = _atlasItem.x;
				bitmapOriginY = _atlasItem.y;
			}
			else
			{
				// Sinon on récupère les valeurs depuis le bitmapData
				bitmapWidth = _bitmapData.width;
				bitmapHeight = _bitmapData.height;
			}
			
			// Vérifier le mode de scale
			var hs:Boolean = (_bitmapData.getPixel(bitmapOriginX + 1, bitmapOriginY) < _cutThreshold);
			var vs:Boolean = (_bitmapData.getPixel(bitmapOriginX, bitmapOriginY + 1) < _cutThreshold);
			
			// Si on est en mode horizontal et vertical
			if (hs && vs)
			{
				// On est en scale 9
				_renderMode = SRenderMode.SCALE_9_RENDER;
			}
			
			// Si on est en horizontal mais pas en vertical
			else if (hs && !vs)
			{
				// On est en scale 3 horizontal
				_renderMode = SRenderMode.HORIZONTAL_SCALE_3_RENDER;
			}
			
			// Si on est en vertical mais pas en horizontal
			else if (!hs && vs)
			{
				// On est en scale 3 vertical
				_renderMode = SRenderMode.VERTICAL_SCALE_3_RENDER;
			}
			else
			{
				// On est en rien du tout donc on déclenche une erreur
				throw new GraphicalError("SGraphic.autoSlice", "Invalid autoSlice markup in bitmapData. Please follow autoSlicing rules.");
				return;
			}
			
			// Si on est allé jusqu'ici, alors on sait que le frame offset est bien de 2
			_frameOffset = 2;
			
			// Les limites
			var x1:uint = bitmapOriginX + _frameOffset;
			var x2:uint = bitmapOriginX + bitmapWidth - _frameOffset;
			var y1:uint = bitmapOriginY + _frameOffset;
			var y2:uint = bitmapOriginY + bitmapHeight - _frameOffset;
			
			// Si on doit parser le côté horizontal
			if (hs)
			{
				// Récupérer le scale horizontal de gauche
				while (_bitmapData.getPixel(x1, bitmapOriginY) > _cutThreshold && x1 < x2)
				{
					// On va vers la droite
					x1 ++;
				}
				
				// Récupérer le scale horizontal de droite
				while (_bitmapData.getPixel(x2, bitmapOriginY) > _cutThreshold && x2 > x1)
				{
					// On va vers la gauche
					x2 --;
				}
			}
			
			// Si on doit parser le côté vertical
			if (vs)
			{
				// Récupérer le scale vertical du haut
				while (_bitmapData.getPixel(bitmapOriginX, y1) > _cutThreshold && y1 < y2)
				{
					// On va vers le bas
					y1 ++;
				}
				
				// Récupérer le scale vertical du bas
				while (_bitmapData.getPixel(bitmapOriginX, y2) > _cutThreshold && y2 > y1)
				{
					// On va vers le haut
					y2 --;
				}
			}
			
			// Enregistrer le rectangle
			_slices = new Rectangle(x1, y1, x2 - x1 + 1, y2 - y1 + 1);
			
			// Si on doit limiter la taille
			if (pAutoSetLimitSize)
			{
				// Définir les tailles min et max selon les slices et le mode de rendu
				if (_renderMode == SRenderMode.HORIZONTAL_SCALE_3_RENDER)
				{
					// Largeur et haute minimum
					minSize(
						(bitmapWidth - _slices.width) / _density + _frameOffset * 2,
						bitmapHeight / _density - _frameOffset * 2
					);
					
					// Hauteur maximum (largeur max inifine)
					maxSize(
						NaN,
						_minHeight
					);
				}
				else if (_renderMode == SRenderMode.VERTICAL_SCALE_3_RENDER)
				{
					// Largeur et haute minimum
					minSize(
						bitmapWidth / _density - _frameOffset * 2,
						(bitmapHeight - _slices.height) / _density + _frameOffset * 2
					);
					
					// Largeur maximum (hauteur max inifine)
					maxSize(
						_minWidth,
						NaN
					);
				}
				else
				{
					// Largeur et haute minimum, largeur et hauteur maximum infinies
					minSize(
						(bitmapWidth - _slices.width) / _density + _frameOffset * 2,
						(bitmapHeight - _slices.height) / _density + _frameOffset * 2
					);
				}
			}
			
			// Invalider le dessin
			_drawInvalidated = true;;
		}
		
		
		/******************************************
						  Phases
		 ******************************************/
		
		/**
		 * Replacer le composant
		 */
		override protected function replace ():void
		{
			// Si on est en mode de rendu taille auto, et qu'on a une image
			if (_renderMode == SRenderMode.AUTO_SIZE && _bitmapData != null)
			{
				// Si on est en mode atlas
				if (_atlasItem != null)
				{
					// Appliquer les dimensions de l'atlas
					_localWidth = _atlasItem.width / _density;
					_localHeight = _atlasItem.height / _density;
				}
				else
				{
					// Appliquer les dimensions de l'image
					_localWidth = _bitmapData.width / _density;
					_localHeight = _bitmapData.height / _density;
				}
			}
			
			// Actualiser le flux de positionnement
			updateFlow();
			
			// Actualiser le dessin
			_drawInvalidated = true;;
		}
		
		/**
		 * Phase de rendu
		 */
		override protected function renderPhase ():void 
		{
			// Relayer
			super.renderPhase();
			
			// Si le dessin est invalidé
			if (_drawInvalidated)
			{
				// Actualiser le dessin
				redraw();
				
				// Le dessin est valide
				_drawInvalidated = false;
			}
		}
		
		
		/******************************************
						   Drawing
		 ******************************************/
		
		/**
		 * Forcer le rafraichissement
		 */
		public function redraw ():void
		{
			// Virer l'ancienne image
			graphics.clear();
			
			// Si le composant a une taille
			if (_localWidth > 0 && _localHeight > 0)
			{
				// Si on a un contour
				if (_borderSize > 0 && _wireFrames < 0)
				{
					// On dessine le contour
					//graphics.lineStyle(_borderSize, _borderColor, _borderAlpha, _snapToPixels, LineScaleMode.NORMAL, CapsStyle.SQUARE, JointStyle.MITER);
					graphics.lineStyle(_borderSize, _borderColor, _borderAlpha, true, LineScaleMode.NORMAL, CapsStyle.SQUARE, JointStyle.MITER);
				}
				
				// Si on a un bitmapData
				if (_bitmapData != null)
				{
					// Si on a un fond
					// Et si on est sur un mode de rendu ou le contenu peut être plus petit que la zone d'affichage
					if (_backgroundType != SBackgroundType.NONE && _renderMode != SRenderMode.REPEAT && _renderMode != SRenderMode.AUTO_SIZE && _renderMode != SRenderMode.STRECH && _atlasItem == null)
					{
						// Actualiser la matrice
						updateMatrix();
						
						// Dessiner le background
						drawBackground();
						
						// Si on a des arrondis
						if (
								_topLeftRadius != 0
								||
								_topRightRadius != 0
								||
								_bottomRightRadius != 0
								||
								_bottomLeftRadius != 0
							)
						{
							// Avec bords arrondis
							graphics.drawRoundRectComplex(
								- _pivotX,
								- _pivotY,
								_localWidth,
								_localHeight,
								_topLeftRadius, _topRightRadius,
								_bottomLeftRadius, _bottomRightRadius
							);
						}
						else
						{
							// Sans bords arrondis
							graphics.drawRect(
								- _pivotX,
								- _pivotY,
								_localWidth,
								_localHeight
							);
						}
						
						// Arrêter le style de trait et le remplissage couleur
						graphics.lineStyle(NaN);
						graphics.endFill();
					}
					
					// Sinon si on est dans un rendu scale
					else if (
							// Si on a des slices
							_slices != null
							&&
							(
								// Et un mode de rendu compatible
								_renderMode == SRenderMode.SCALE_9_RENDER
								||
								_renderMode == SRenderMode.HORIZONTAL_SCALE_3_RENDER
								||
								_renderMode == SRenderMode.VERTICAL_SCALE_3_RENDER
							)
						)
					{
						// TODO : Vérifier les scale3 sur les atlas
						// TODO : Tester sur android ou avec un ratio pourri sur le stage
						// TODO : Revoir les méthodes helper (voir si on peut faire une méthode helper en slice manuel : mode + rectangle)
						// TODO : Revoir les méthodes helper pour AtlasItem -> manual slice et auto slice
						// TODO : Il doit y avoir un problème avec le +1 du slice sur les dimensions, les vPosition et hPosition tombe pas rond si density != 1
						// TODO : Un dernier coup de refacto (refacto et renommage des helpers / doc en anglais / peut être passer un atlas via le constructeur)
						
						// Annuler le trait
						graphics.lineStyle(NaN);
						
						// Calculer le nombre de slices horizontales et verticales
						var hSlices:uint = (_renderMode == SRenderMode.SCALE_9_RENDER || _renderMode == SRenderMode.HORIZONTAL_SCALE_3_RENDER) ? 3 : 2;
						var vSlices:uint = (_renderMode == SRenderMode.SCALE_9_RENDER || _renderMode == SRenderMode.VERTICAL_SCALE_3_RENDER) ? 3 : 2;
						
						// Les index des blocs horizontaux et verticaux
						var cx:uint;
						var cy:uint;
						
						// Les positions et dimensions
						var bitmapWidth		:uint	= 0;
						var bitmapHeight	:uint	= 0;
						var bitmapOriginX	:uint	= 0;
						var bitmapOriginY	:uint	= 0;
						
						// Si on est sur un atlas
						if (_atlasItem != null)
						{
							// Récupérer les valeurs de l'atlas
							bitmapWidth = _atlasItem.width;
							bitmapHeight = _atlasItem.height;
							bitmapOriginX = _atlasItem.x;
							bitmapOriginY = _atlasItem.y;
						}
						else
						{
							// Sinon on récupère les valeurs depuis le bitmapData
							bitmapWidth = _bitmapData.width;
							bitmapHeight = _bitmapData.height;
						}
						
						// La matrice temporaire pour chaque bloc
						var matrix:Matrix = new Matrix();
						
						// Les positions des blocs horizontaux et verticaux
						var hPositions			:Vector.<Number> = Vector.<Number>([
							0,																			// La position horizontale du premier bloc
							(_slices.left - bitmapOriginX - _frameOffset) / _density,					// La position horizontale du second bloc
							(_localWidth - (bitmapWidth - _slices.right + bitmapOriginX) / _density),	// La position horizontale de la fin du second bloc
							_localWidth																	// La position horizontale de la fin du troisième bloc
						]);
						var vPositions			:Vector.<Number> = Vector.<Number>([
							0,																			// La position verticale du premier bloc
							(_slices.top - bitmapOriginY - _frameOffset) / _density,					// La position verticale du second bloc
							(_localHeight - (bitmapHeight - _slices.bottom + bitmapOriginY) / _density),// La position verticale de la fin du second bloc
							_localHeight																// La position verticale de la fin du troisième bloc
						]);
						
						// Les scales des blocs horizontaux et verticaux
						var hScales				:Vector.<Number> = Vector.<Number>([
							1 / _density,												// Le ratio horizontal du coin de gauche
							((hPositions[2] - hPositions[1]) / _slices.width),			// Le ratio horizontal du côté du milieu
							1 / _density												// Le ratio horizontal du coin de droite
						]);
						var vScales				:Vector.<Number> = Vector.<Number>([
							1 / _density,												// Le ratio vertical du coin du haut
							((vPositions[2] - vPositions[1]) / _slices.height),			// Le ratio vertical du côté du milieu
							1 / _density												// Le ratio vertical du coin du bas
						]);
						
						// Les position sur la texture
						var hTexturePosition	:Vector.<Number> = Vector.<Number>([
							bitmapOriginX + _frameOffset,															// La position horizontale de la texture pour le premier bloc
							_slices.left - ((_slices.left - bitmapOriginX - _frameOffset) / hScales[1] / _density),	// La position horizontale de la texture pour le second bloc
							bitmapOriginX + bitmapWidth - _localWidth * _density									// La position horizontale de la texture pour le troisième bloc
						]);
						var vTexturePosition	:Vector.<Number> = Vector.<Number>([
							bitmapOriginY + _frameOffset,															// La position verticale de la texture pour le premier bloc
							_slices.top - ((_slices.top - bitmapOriginY - _frameOffset) / vScales[1] / _density),	// La position verticale de la texture pour le second bloc
							bitmapOriginY + bitmapHeight - _localHeight * _density									// La position verticale de la texture pour le troisième bloc
						]);
						
						// Parcourir les blocs horizontaux
						for (cx = (hSlices == 1 ? 1 : 0); cx < hSlices; cx++)
						{
							// Parcourir les blocs verticaux
							for (cy = (vSlices == 1 ? 1 : 0); cy < vSlices; cy++)
							{
								// Remettre la matrice à 0
								matrix.identity();
								
								// Placer la matrice selon le bloc
								matrix.translate(- hTexturePosition[cx], - vTexturePosition[cy]);
								
								// La taille de la matrice selon le bloc
								matrix.scale(hScales[cx], vScales[cy]);
								
								// Dessiner le bitmap grâce à la matrice temporaire
								if (_wireFrames < 0)
								{
									graphics.beginBitmapFill(_bitmapData, matrix, false, _smoothing);
								}
								else
								{
									graphics.lineStyle(1, _wireFrames);
								}
								
								// Tracer le bloc
								graphics.drawRect(
									hPositions[cx] - _pivotX,
									vPositions[cy] - _pivotY,
									hPositions[cx + 1] - hPositions[cx],
									vPositions[cy + 1] - vPositions[cy]
								);
							}
						}
						
						// Terminer le dessin
						graphics.endFill();
						
						// Ne pas aller plus loin
						return;
					}
					else
					{
						// Actualiser la matrice
						updateMatrix();
						
						// Dessiner le bitmap grâce à la matrice
						if (_wireFrames < 0)
						{
							graphics.beginBitmapFill(_bitmapData, _matrix, _renderMode == SRenderMode.REPEAT, _smoothing);
						}
						else
						{
							graphics.lineStyle(1, _wireFrames);
						}
					}
				}
				else
				{
					// Sinon on n'a pas de dépassement
					_xDrawDecay = _yDrawDecay = 0;
					
					// Dessiner le background
					drawBackground();
				}
				
				// Si on a des arrondis
				if (
						_topLeftRadius != 0
						||
						_topRightRadius != 0
						||
						_bottomRightRadius != 0
						||
						_bottomLeftRadius != 0
					)
				{
					// Avec bords arrondis
					graphics.drawRoundRectComplex(
						_xDrawDecay - _pivotX,
						_yDrawDecay - _pivotY,
						_localWidth - _xDrawDecay * 2,
						_localHeight - _yDrawDecay * 2,
						_topLeftRadius, _topRightRadius,
						_bottomLeftRadius, _bottomRightRadius
					);
				}
				else
				{
					// Sans bords arrondis
					graphics.drawRect(
						_xDrawDecay - _pivotX,
						_yDrawDecay - _pivotY,
						_localWidth - _xDrawDecay * 2,
						_localHeight - _yDrawDecay * 2
					);
				}
				
				// Terminer le dessin
				graphics.endFill();
			}
		}
		
		/**
		 * Draw background
		 */
		protected function drawBackground ():void
		{
			// Si on n'est pas en wireframe
			if (_wireFrames < 0)
			{
				// Si on doit faire un fond avec une couleur pleine
				if (_backgroundType == SBackgroundType.FLAT)
				{
					// On commence le déssin avec la première couleur et le premier alpha
					graphics.beginFill(_backgroundColor1, _backgroundAlpha1);
				}
				
				// Si on doit faire un background avec un dégradé
				else if (_backgroundType != SBackgroundType.NONE)
				{
					// Créer la matrice du dégradé
					var gradientMatrix:Matrix = new Matrix()
					gradientMatrix.createGradientBox(_localWidth, _localHeight, _backgroundType == SBackgroundType.VERTICAL_GRADIENT ? Math.PI / 2 : 0, 0, 0);
					
					// Déssiner le dégradé
					graphics.beginGradientFill(
						GradientType.LINEAR,
						[_backgroundColor1, _backgroundColor2],
						[_backgroundAlpha1, _backgroundAlpha2],
						[0, 0xFF],
						gradientMatrix
					);
				}
			}
			else
			{
				graphics.lineStyle(1, _wireFrames);
			}
		}
		
		/**
		 * Actualiser la matrice selon le mode de redimensionnement
		 */
		protected function updateMatrix ():void
		{
			// Replacer la matrice à 0
			_matrix.identity();
			
			// Les scales par défaut
			var horizontalScale	:Number	= 1;
			var verticalScale	:Number	= 1;
			
			// Calculer le scale
			if (_atlasItem == null && _renderMode == SRenderMode.STRECH)
			{
				// Scaler au composant
				horizontalScale = _localWidth / _bitmapData.width;
				verticalScale = _localHeight / _bitmapData.height;
			}
			
			// Sinon si on a un atlas
			else if (_atlasItem != null)
			{
				// Scaler l'atlas au composant
				horizontalScale = _localWidth / _atlasItem.width;
				verticalScale = _localHeight / _atlasItem.height;
			}
			else if (_renderMode == SRenderMode.INSIDE || _renderMode == SRenderMode.OUTSIDE)
			{
				// On applique les 2 dimensions sur le ratio horizontal
				verticalScale = horizontalScale = _localWidth / _bitmapData.width;
				
				// Et on regarde le comportement du ratio vertical
				if (
						_renderMode == SRenderMode.INSIDE && _bitmapData.height * verticalScale > _localHeight
						||
						_renderMode == SRenderMode.OUTSIDE && _bitmapData.height * verticalScale < _localHeight
					)
				{
					// On appliquer les 2 dimensions sur le ratio vertical
					verticalScale = horizontalScale = _localHeight / _bitmapData.height;
				}
			}
			
			// Appliquer la densité pour ces modes de rendu
			else if (_renderMode == SRenderMode.AUTO_SIZE || _renderMode == SRenderMode.REPEAT || _renderMode == SRenderMode.NO_SCALE || _renderMode == SRenderMode.CENTER)
			{
				horizontalScale = 1 / _density;
				verticalScale = 1 / _density;
			}
			
			// Appliquer le scale
			_matrix.scale(horizontalScale, verticalScale);
			
			// Si on doit centrer
			if (_renderMode == SRenderMode.CENTER || _renderMode == SRenderMode.INSIDE || _renderMode == SRenderMode.OUTSIDE)
			{
				// On centre par rapport aux précédentes modifications du scale
				_matrix.translate(
					_localWidth / 2 - _bitmapData.width * horizontalScale / 2 + _bitmapHorizontalOffset,
					_localHeight / 2 - _bitmapData.height * verticalScale / 2 + _bitmapVerticalOffset
				);
				
				// Si on autorise pas les dépassements de dessin de l'image
				if (_allowOverflow || _renderMode == SRenderMode.INSIDE)
				{
					// On enregistre les dépassements
					_xDrawDecay = _matrix.tx;
					_yDrawDecay = _matrix.ty;
				}
				else
				{
					// Sinon on n'a pas de dépassement
					_xDrawDecay = _yDrawDecay = 0;
				}
			}
			else
			{
				// Sinon on n'a pas de dépassement
				_xDrawDecay = _yDrawDecay = 0;
				
				if (_atlasItem != null && _renderMode == SRenderMode.STRECH)
				{
					// Déplacer selon les offsets
					_matrix.translate(_bitmapHorizontalOffset * horizontalScale, _bitmapVerticalOffset * verticalScale);
				}
				else
				{
					// Déplacer selon les offsets
					_matrix.translate(_bitmapHorizontalOffset, _bitmapVerticalOffset);
				}
			}
		}
		
		/**
		 * Dispose
		 */
		override public function dispose ():void
		{
			// Supprimer les références
			_bitmapData = null;
			_atlasItem = null;
			_slices = null;
			
			// Relayer
			super.dispose();
		}
	}
}
