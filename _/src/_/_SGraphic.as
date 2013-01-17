package fr.swapp.graphic.base
{
	import flash.geom.Matrix;
	import flash.geom.Point;
	import fr.swapp.graphic.errors.GraphicalError;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.textures.Texture;
	import starling.textures.TextureSmoothing;
	
	/**
	 * @author ZoulouX
	 */
	public class SGraphic extends SComponent
	{
		/**
		 * If draw is out of date
		 */
		protected var _drawInvalidated					:Boolean 							= false;
		
		/**
		 * If background is out of date
		 */
		protected var _backgroundInvalidated			:Boolean							= false;
		
		/**
		 * Texture to draw
		 */
		protected var _texture							:Texture;
		
		/**
		 * Quad showing the background
		 */
		protected var _quad								:Quad;
		
		/**
		 * Image showing the texture
		 */
		protected var _image							:Image;
		
		/**
		 * Actual render mode for graphics (accepted values from SRenderMode)
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
		 * Transformation matrix for texture
		 */
		protected var _matrix							:Matrix								= new Matrix();
		
		/**
		 * Allow content overflow with OUTSIDE render mode.
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
		 * Image smoothing type
		 */
		protected var _smoothing						:String								= TextureSmoothing.NONE;
		
		
		
		/**
		 * Texture to draw. Null to ignore.
		 */
		public function get texture ():Texture { return _texture; }
		public function set texture (value:Texture):void 
		{
			// Si c'est différent
			if (value != _texture)
			{
				// Si on n'a plus de texture
				if (_texture != null && value == null)
				{
					// Supprimer l'image
					removeChild(_image);
					
					// La disposer
					_image.dispose();
					_image = null;
				}
				
				// Si on n'avait pas de texture et qu'on en a une
				else if (_texture == null && value != null)
				{
					// On créé l'image
					_image = new Image(value);
					
					// Et on l'ajoute
					addChild(_image);
				}
				
				// Sinon
				else
				{
					// On réutilise l'image
					_image.texture = value;
				}
				
				// Enregistrer la texture
				_texture = value;
				
				// Actualiser les propriétés du bitmap
				updateTextureProperties();
				
				// Rendre la position invalide
				invalidatePosition();
				
				// Rendre le dessin invalide
				invalidateDraw();
			}
		}
		
		/**
		 * Actual render mode for graphics (accepted values from SRenderMode)
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
				invalidateDraw();
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
				invalidateDraw();
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
				invalidateDraw();
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
				invalidateDraw();
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
				// Si on n'a plus de background
				if (_backgroundType != SBackgroundType.NONE && value == SBackgroundType.NONE)
				{
					// Supprimer l'image
					removeChild(_quad);
					
					// La disposer
					_quad.dispose();
					_quad = null;
				}
				
				// Si on n'avait pas de background et qu'on en a un
				else if (_backgroundType == SBackgroundType.NONE && value != SBackgroundType.NONE)
				{
					// Créer le quad du background
					_quad = new Quad(1, 1, 0, true);
					
					// Appliquer les dimensions du composant au background
					_quad.width = _localWidth;
					_quad.height = _localHeight;
					
					// L'ajouter au fond
					addChildAt(_quad, 0);
				}
				
				// Enregistrer
				_backgroundType = value;
				
				// Invalider le background
				invalidatateBackground();
			}
		}
		
		/**
		 * Smoothing type for the image.
		 */
		public function get smoothing ():String { return _smoothing; }
		public function set smoothing (value:String):void 
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
		 * Allow content overflow for SRenderMode.OUTSIDE.
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
		 * Image density. Default is 1, retina will be 2.
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
		 * Horizontal image offset.
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
		 * Vertical image offset.
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
			// Enregistrer la texture
			image(pTexture, pRenderMode, pDensity);
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
			// Enregistrer le mode de rendu
			_renderMode = pRenderMode;
			
			// Enregistrer la densité
			_density = pDensity;
			
			// Définir la texture par son setter pour tout invalider et définir le besoin d'une image ou non
			texture = pTexture;
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
		 * @param	pBackgroundType : Type of background (accepted values from SBackgroundType)
		 * @param	pBackgroundColor1 : First color of the background
		 * @param	pBackgroundAlpha1 : First alpha of the background
		 * @param	pBackgroundColor2 : Second color of the background (ignored in SBackgroundType.FLAT)
		 * @param	pBackgroundAlpha2 : Second alpha of the background (ignored in SBackgroundType.FLAT)
		 * @return this
		 */
		public function background (pBackgroundType:String, pBackgroundColor1:int = 0, pBackgroundAlpha1:Number = 1, pBackgroundColor2:int = 0, pBackgroundAlpha2:Number = 1):SGraphic
		{
			// Enregistrer
			_backgroundColor1 = pBackgroundColor1;
			_backgroundColor2 = pBackgroundColor2;
			_backgroundAlpha1 = pBackgroundAlpha1;
			_backgroundAlpha2 = pBackgroundAlpha2;
			
			// Enregistrer le type de background
			backgroundType = pBackgroundType;
			
			// Méthode chaînable
			return this;
		}
		
		
		/******************************************
						  Phases
		 ******************************************/
		
		/**
		 * Drawing is out of date
		 */
		public function invalidateDraw ():void
		{
			// Invalider le dessin
			_drawInvalidated = true;
		}
		
		/**
		 * Background is out of date
		 */
		protected function invalidatateBackground ():void
		{
			// Invalider le background
			_backgroundInvalidated = true;
		}
		
		/**
		 * The component has been replaced
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
			
			// Relayer pour actualiser le flux de positionnement
			super.replace();
			
			// Actualiser le background
			invalidatateBackground();
			
			// Actualiser le dessin
			invalidateDraw();
		}
		
		/**
		 * Render phase
		 */
		override protected function renderPhase ():void 
		{
			// Relayer
			super.renderPhase();
			
			// Si le background est invalidé
			if (_backgroundInvalidated)
			{
				// Actualiser le background
				updateBackground();
				
				// Le background est valide
				_backgroundInvalidated = false;
			}
			
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
		 * Update background properties
		 */
		protected function updateBackground ():void
		{
			// Si on a un background
			if (_quad != null)
			{
				// Appliquer les dimensions du composant au background
				_quad.width = _localWidth;
				_quad.height = _localHeight;
				
				// La valeur a prendre selon le vertex
				var firstValue:Boolean;
				
				// Parcourir les 4 vertex
				for (var i:uint = 0; i < 4; i++)
				{
					// Définir si on prend la valeur 1 ou 2 selon le vertex
					firstValue = (
						// Si on est en couleur pleine
						_backgroundType == SBackgroundType.FLAT
						||
						// Si on est en dégradé vertical
						(
							_backgroundType == SBackgroundType.VERTICAL_GRADIENT
							&&
							i < 2
						)
						||
						// Si on est en dégradé horizontal
						(
							_backgroundType == SBackgroundType.HORIZONTAL_GRADIENT
							&&
							(i == 0 || i == 2)
						)
					);
					
					// Appliquer la couleur et l'alpha sur ce vertex
					_quad.setVertexColor(i, firstValue ? _backgroundColor1 : _backgroundColor2);
					_quad.setVertexAlpha(i, firstValue ? _backgroundAlpha1 : _backgroundAlpha2);
				}
			}
		}
		
		/**
		 * Update drawing properties
		 */
		protected function redraw ():void
		{
			// Si on a des dimensions
			if (_localWidth > 0 && _localHeight > 0)
			{
				// Si on a une image
				if (_image != null)
				{
					// Actualiser la matrice
					updateMatrix();
					
					// Si on est en repeat / stretch / outside sans overflow
					if (_renderMode == SRenderMode.REPEAT || _renderMode == SRenderMode.STRECH || (_renderMode == SRenderMode.OUTSIDE && !_allowOverflow))
					{
						// Appliquer les dimensions du composant sur l'image
						_image.x = 0;
						_image.y = 0;
						_image.width = _localWidth;
						_image.height = _localHeight;
						
						// Le point qui va être utilisé pour positionner les 4 points UV de l'image
						var point:Point = new Point();
						
						// L'itérateur du point
						var i:uint;
						
						// Si on est en repeat
						if (_renderMode == SRenderMode.REPEAT)
						{
							// Parcourir les 4 points de l'image
							for (i = 0; i < 4; i ++)
							{
								// Placer le point selon la matrice
								point.x = - _matrix.tx / _texture.width + ((i == 1 || i == 3) ? _matrix.a : 0);
								point.y = - _matrix.ty / _texture.height + ((i == 2 || i == 3) ? _matrix.d : 0);
								
								// Appliquer cette position sur l'image
								_image.setTexCoords(i, point);
							}
						}
						
						// Si on est en outside
						else if (_renderMode == SRenderMode.OUTSIDE)
						{
							// Calculer les placements U et V
							var u:Number = - (_matrix.tx / _texture.width) / _matrix.a;
							var v:Number = - (_matrix.ty / _texture.height) / _matrix.d;
							
							// Parcourir les 4 points de l'image
							for (i = 0; i < 4; i ++)
							{
								// Placer le point selon la matrice
								point.x = ((i == 0 || i == 2) ? u : 1 - u);
								point.y = ((i == 0 || i == 1) ? v : 1 - v);
								
								// Appliquer cette position sur l'image
								_image.setTexCoords(i, point);
							}
						}
					}
					else
					{
						// Appliquer simplement la transformation calculée
						_image.transformationMatrix = _matrix;
					}
				}
				else
				{
					// Sinon on n'a pas de dépassement
					_xDrawDecay = _yDrawDecay = 0;
				}
			}
		}
		
		/**
		 * Update scaling and translating matrix for drawing
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
			else if (_renderMode == SRenderMode.AUTO_SIZE || _renderMode == SRenderMode.NO_SCALE)
			{
				horizontalScale = 1 / _density;
				verticalScale = 1 / _density;
			}
			
			// Appliquer la densité spéciale du mode repeat
			else if (_renderMode == SRenderMode.REPEAT)
			{
				horizontalScale = _localWidth / _texture.width;
				verticalScale = _localHeight / _texture.height;
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
		 * Update texture properties for render mode
		 */
		protected function updateTextureProperties ():void
		{
			// Si on a bien une texture
			if (_texture != null)
			{
				// Appliquer le repeat sur la texture
				_texture.repeat = (_renderMode == SRenderMode.REPEAT);
				
				// Appliquer le smoothing
				_image.smoothing = _smoothing;
			}
		}
	}
}