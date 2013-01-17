package fr.swapp.graphic.base
{
	import flash.geom.Matrix;
	import starling.display.Graphics;
	import starling.display.Image;
	import starling.display.materials.IMaterial;
	import starling.display.materials.TextureMaterial;
	import starling.textures.Texture;
	
	/**
	 * @author ZoulouX
	 */
	public class SGraphic extends SComponent
	{
		/**
		 * If draw is out of date
		 */
		protected var _drawInvalidated					:Boolean 			= true;
		
		/**
		 * Texture to draw
		 */
		protected var _texture							:Texture;
		
		/**
		 * Image showing the texture
		 */
		protected var _image							:Image;
		
		/**
		 * Actual render mode for graphics
		 */
		protected var _renderMode						:String;
		
		/**
		 * Background color (-1 to ignore)
		 */
		protected var _backgroundColor					:int								= -1;
		
		/**
		 * Background opacity
		 */
		protected var _backgroundAlpha					:Number								= 1;
		
		/**
		 * Border size in pixels
		 */
		protected var _borderSize						:Number								= 0;
		
		/**
		 * Border color
		 */
		protected var _borderColor						:uint								= 0x000000;
		
		/**
		 * Border opacity
		 */
		protected var _borderAlpha						:Number								= 1;
		
		
		/**
		 * Top left border radius
		 */
		protected var _topLeftRadius					:int;
		
		/**
		 * Top right border radius
		 */
		protected var _topRightRadius					:int;
		
		/**
		 * Bottom right border radius
		 */
		protected var _bottomRightRadius				:int;
		
		/**
		 * Bottom left border radius
		 */
		protected var _bottomLeftRadius					:int;
		
		
		/**
		 * Transformation matrix for texture
		 */
		protected var _matrix							:Matrix								= new Matrix();
		
		/**
		 * Allow content overflow with INSIDE and OUTSIDE render modes.
		 */
		protected var _allowOverflow					:Boolean							= false;
		
		/**
		 * Horizontal inside drawing offset.
		 */
		protected var _xDrawDecay						:Number;
		
		/**
		 * Vertical inside drawing offset.
		 */
		protected var _yDrawDecay						:Number;
		
		/**
		 * Image density (ex: retina will be 2)
		 */
		protected var _density							:Number;
		
		/**
		 * Outside bitmap horizontal offset
		 */
		protected var _bitmapHorizontalOffset			:int;
		
		/**
		 * Outside bitmap horizontal offset
		 */
		protected var _bitmapVerticalOffset				:int;
		
		/**
		 * Smooth the texture
		 */
		protected var _smoothing						:Boolean						= true;
		
		
		
		/**
		 * Texture to draw. Null to ignore.
		 */
		public function get texture ():Texture { return _texture; }
		public function set texture (value:Texture):void 
		{
			// Si c'est différent
			if (value != _texture)
			{
				// Enregistrer la texture
				_texture = value;
				
				// Convertir en material
				if (_texture == null)
				{
					_material = null;
				}
				else
				{
					_material = new TextureMaterial(_texture);
				}
				
				// Actualiser les propriétés du bitmap
				updateTextureProperties();
				
				// Rendre la position invalide
				invalidatePosition();
				
				// Rendre le dessin invalide
				invalidateDraw();
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
				
				// Actualiser les propriétés du bitmap
				updateTextureProperties();
				
				// Rendre la position invalide
				invalidatePosition();
				
				// Rendre le dessin invalide
				invalidateDraw();
			}
		}
		
		/**
		 * La couleur de fond (blanc par défaut)
		 */
		public function get backgroundColor ():int { return _backgroundColor; }
		public function set backgroundColor (value:int):void 
		{
			// Si c'est différent
			if (_backgroundColor != value)
			{
				// Enregistrer
				_backgroundColor = value;
				
				// Rendre le dessin invalide
				invalidateDraw();
			}
		}
		
		/**
		 * La transparence de la couleur de fond
		 */
		public function get backgroundAlpha ():Number { return _backgroundAlpha; }
		public function set backgroundAlpha (value:Number):void 
		{
			// Si c'est différent
			if (_backgroundAlpha != value)
			{
				// Enregistrer
				_backgroundAlpha = value;
				
				// Rendre le dessin invalide
				invalidateDraw();
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
				invalidateDraw();
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
				invalidateDraw();
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
				invalidateDraw();
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
				invalidateDraw();
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
				invalidateDraw();
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
				invalidateDraw();
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
				invalidateDraw();
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
				
				// Actualiser les propriétés du bitmap
				updateTextureProperties();
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
				invalidateDraw();
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
				invalidatePosition();
				
				// Rendre le dessin invalide
				invalidateDraw();
			}
		}
		
		/**
		 * Le décallage horizontal de l'image.
		 */
		public function get bitmapHorizontalOffset ():int { return _bitmapHorizontalOffset; }
		public function set bitmapHorizontalOffset (value:int):void
		{
			// Si c'est différent
			if (_bitmapHorizontalOffset != value)
			{
				// Enregistrer
				_bitmapHorizontalOffset = value;
				
				// Rendre le dessin invalide
				invalidateDraw();
			}
		}
		
		/**
		 * Le décallage vertical de l'image.
		 */
		public function get bitmapVerticalOffset ():int { return _bitmapVerticalOffset; }
		public function set bitmapVerticalOffset (value:int):void
		{
			// Si c'est différent
			if (_bitmapVerticalOffset != value)
			{
				// Enregistrer
				_bitmapVerticalOffset = value;
				
				// Rendre le dessin invalide
				invalidateDraw();
			}
		}
		
		/**
		 * Graphics API
		 */
		public function get graphics ():Graphics { return _graphics; }
		
		
		/**
		 * Constructor.
		 * Set texture to draw. If pTexture is null, it will be ignored.
		 * Set renderMode to specify how the texture will fit in this component.
		 * Set density for retina images for exemple.
		 * @param	pTexture : Starling texture to be drawn. Null to ignore.
		 * @param	pRenderMode : RenderMode from SRenderMode to fit texture in this component.
		 * @param	pDensity : Density of the texture.
		 */
		public function SGraphic (pTexture:Texture = null, pRenderMode:String = null, pDensity:Number = 1)
		{
			// Initialiser l'API graphique qui est vitale pour cette classe
			initGraphics();
			
			// Enregistrer la texture
			image(pTexture, pRenderMode, pDensity);
		}
		
		/**
		 * Init Graphics API
		 */
		protected function initGraphics ():void
		{
			_graphics = new Graphics(this);
		}
		
		
		/******************************************
					  Méthodes ouvertes
		 ******************************************/
		
		/**
		 * Set texture to draw. If pTexture is null, it will be ignored.
		 * Set renderMode to specify how the texture will fit in this component.
		 * Set density for retina images for exemple.
		 * @param	pTexture : Starling texture to be drawn. Null to ignore.
		 * @param	pRenderMode : RenderMode from SRenderMode to fit texture in this component.
		 * @param	pDensity : Density of the texture.
		 */
		public function image (pTexture:Texture = null, pRenderMode:String = null, pDensity:Number = 1):void
		{
			// Enregistrer la texture
			texture = pTexture;
			
			// Enregistrer la densité
			_density = pDensity;
			
			// Le mode de rendu en dernier pour invalider une première fois
			renderMode = pRenderMode;
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
			_bitmapHorizontalOffset = pHorizontalOffset;
			_bitmapVerticalOffset = pVerticalOffset;
			
			// Rendre le dessin invalide
			invalidateDraw();
			
			// Méthode chaînable
			return this;
		}
		
		/**
		 * Set a background color to this component.
		 * @param	pBackgroundColor : Background color (-1 to ignore)
		 * @param	pBackgroundAlpha : Background opacity
		 * @return this
		 */
		public function background (pBackgroundColor:int, pBackgroundAlpha:Number = 1):SGraphic
		{
			// Enregistrer
			_backgroundColor = pBackgroundColor;
			_backgroundAlpha = pBackgroundAlpha
			
			// Rendre le dessin invalide
			invalidateDraw();
			
			// Méthode chaînable
			return this;
		}
		
		/**
		 * Set a border to this component.
		 * @param	pBorderSize : Size of the border in px (0 to ignore)
		 * @param	pBorderColor : Border color
		 * @param	pBorderAlpha : Border opacity
		 * @return this, méthode chaînable
		 */
		public function border (pBorderSize:Number, pBorderColor:uint = 0, pBorderAlpha:Number = 1):SGraphic
		{
			// Enregistrer
			_borderSize = pBorderSize;
			_borderColor = pBorderColor;
			_borderAlpha = pBorderAlpha;
			
			// Rendre le dessin invalide
			invalidateDraw();
			
			// Méthode chaînable
			return this;
		}
		
		/**
		 * Individual border radius.
		 * @param	pTopLeftRadius : Top left border radius (0 to draw square)
		 * @param	pTopRightRadius : Top right border radius (0 to draw square)
		 * @param	pBottomRightRadius : Bottom right border radius (0 to draw square)
		 * @param	pBottomLeftRadius : Bottom left border radius (0 to draw square)
		 * @return this
		 */
		public function radius (pTopLeftRadius:int, pTopRightRadius:int, pBottomRightRadius:int, pBottomLeftRadius:int):SGraphic
		{
			// Enregistrer
			_topLeftRadius 		= pTopLeftRadius;
			_topRightRadius 	= pTopRightRadius;
			_bottomRightRadius 	= pBottomRightRadius;
			_bottomLeftRadius 	= pBottomLeftRadius;
			
			// Rendre le dessin invalide
			invalidateDraw();
			
			// Méthode chaînable
			return this;
		}
		
		/**
		 * Set all border radius in one call.
		 * @param	pRadius : Size of all border radius (0 to draw square)
		 * @return this
		 */
		public function allRadius (pRadius:int):SGraphic
		{
			// Enregistrer
			_topLeftRadius 		= pRadius;
			_topRightRadius 	= pRadius;
			_bottomRightRadius 	= pRadius;
			_bottomLeftRadius 	= pRadius;
			
			// Rendre le dessin invalide
			invalidateDraw();
			
			// Méthode chaînable
			return this;
		}
		
		
		/******************************************
						  Phases
		 ******************************************/
		
		/**
		 * Draw is out of date
		 */
		public function invalidateDraw ():void
		{
			// Invalider le dessin
			_drawInvalidated = true;
		}
		
		/**
		 * Replacer le composant
		 */
		override protected function replace ():void
		{
			// Si on est en mode de rendu taille auto, et qu'on a une image
			if (_renderMode == SRenderMode.AUTO_SIZE && _texture != null)
			{
				// Appliquer les dimensions de l'image
				_localWidth = _texture.width / _density;
				_localHeight = _texture.height / _density;
			}
			
			// Actualiser le flux de positionnement
			updateFlow();
			
			// Actualiser le dessin
			invalidateDraw();
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
						   Dessin
		 ******************************************/
		
		/**
		 * Forcer le rafraichissement
		 */
		public function redraw ():void
		{
			// Virer l'ancienne image
			graphics.clear();
			
			// Si on a des dimensions
			if (_localWidth > 0 && _localHeight > 0)
			{
				// Si on a un contour
				if (_borderSize > 0)
				{
					// On dessine le contour
					_graphics.lineStyle(_borderSize, _borderColor, _borderAlpha);
				}
				
				// Si on a un bitmapData
				if (_texture != null)
				{
					// Actualiser la matrice
					updateMatrix();
					
					// Si on a une couleur de fond
					// Et si on est sur un mode de rendu ou le contenu peut être plus petit que la zone d'affichage
					if (_backgroundColor != -1 && _renderMode != SRenderMode.REPEAT && _renderMode != SRenderMode.AUTO_SIZE && _renderMode != SRenderMode.STRECH)
					{
						// On commence le déssin
						graphics.beginFill(_backgroundColor, _backgroundAlpha);
						
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
								0,
								0,
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
								0,
								0,
								_localWidth,
								_localHeight
							);
						}
						
						// Arrêter le style de trait et le remplissage couleur
						graphics.lineStyle(NaN);
						graphics.endFill();
					}
					
					// On dessiner le bitmap avec la nouvelle matrice
					graphics.beginMaterialFill(_material, _matrix);
				}
				else
				{
					// Sinon on n'a pas de dépassement
					_xDrawDecay = _yDrawDecay = 0;
					
					// Démarrer le dessin avec une couleur pleine
					if (_backgroundColor != -1)
						graphics.beginFill(_backgroundColor, _backgroundAlpha);
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
						_xDrawDecay,
						_yDrawDecay,
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
						_xDrawDecay,
						_yDrawDecay,
						_localWidth - _xDrawDecay * 2,
						_localHeight - _yDrawDecay * 2
					);
				}
				
				// Terminer le dessin
				graphics.endFill();
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
			if (_renderMode == SRenderMode.STRECH)
			{
				// Scaler au composant
				horizontalScale = _localWidth / _texture.width;
				verticalScale = _localHeight / _texture.height;
			}
			else if (_renderMode == SRenderMode.INSIDE || _renderMode == SRenderMode.OUTSIDE)
			{
				// On applique les 2 dimensions sur le ratio horizontal
				verticalScale = horizontalScale = _localWidth / _texture.width;
				
				// Et on regarde le comportement du ratio vertical
				if (
						_renderMode == SRenderMode.INSIDE && _texture.height * verticalScale > _localHeight
						||
						_renderMode == SRenderMode.OUTSIDE && _texture.height * verticalScale < _localHeight
					)
				{
					// On applique les 2 dimensions sur le ratio vertical
					verticalScale = horizontalScale = _localHeight / _texture.height;
				}
			}
			
			// Appliquer la densité pour ces modes de rendu
			else if (_renderMode == SRenderMode.AUTO_SIZE || _renderMode == SRenderMode.REPEAT || _renderMode == SRenderMode.NO_SCALE)
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
					_localWidth / 2 - _texture.width * horizontalScale / 2 + _bitmapHorizontalOffset,
					_localHeight / 2 - _texture.height * verticalScale / 2 + _bitmapVerticalOffset
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
				
				// Déplacer selon les offsets
				_matrix.translate(_bitmapHorizontalOffset, _bitmapVerticalOffset);
			}
		}
		
		/**
		 * Actualiser les propriété d'affichage de la texture
		 */
		protected function updateTextureProperties ():void
		{
			// Si on a bien une texture
			if (_texture != null)
			{
				// Appliquer les valeurs sur le seul bitmap
				_texture.repeat = (_renderMode == SRenderMode.REPEAT);
			}
		}
	}
}