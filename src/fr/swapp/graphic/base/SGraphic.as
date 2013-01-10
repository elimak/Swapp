package fr.swapp.graphic.base
{
	import flash.geom.Matrix;
	import flash.geom.Point;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.textures.Texture;
	
	/**
	 * @author ZoulouX
	 */
	public class SGraphic extends SComponent
	{
		/**
		 * If draw is out of date
		 */
		protected var _drawInvalidated					:Boolean 							= true;
		
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
		 * Type of background gradient (look AGradientType
		 */
		protected var _backgroundGradientType			:String;
		
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
		protected var _smoothing						:Boolean							= true;
		
		
		
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
			
			// Relayer pour actualiser le flux de positionnement
			super.replace();
			
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
			// Si on a des dimensions
			if (_localWidth > 0 && _localHeight > 0)
			{
				// Si on a un fond
				if (_quad != null)
				{
					// Appliquer les dimensions du composant sur le quad
					_quad.width = _localWidth;
					_quad.height = _localHeight;
					
					//if (_backgroundGradient)
					{
						
					}
					//_quad.
				}
				
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
							// TODO : Corriger le placement du mode outside
							// TODO : Ajoute un mode de rendu qui permet de déplacement l'image dans le composant (ex : photo multitouch)
							
							// Parcourir les 4 points de l'image
							for (i = 0; i < 4; i ++)
							{
								//
								var a:Number = - _matrix.tx / _texture.width / 2;
								var b:Number = _matrix.tx / _texture.width / 2 + 1;
								var c:Number = - _matrix.ty / _texture.height / 2;
								var d:Number = _matrix.ty / _texture.height / 2 + 1;
								
								if (i == 0)
								{
									point.x = a;
									point.y = c;
								}
								else if (i == 1)
								{
									point.x = b;
									point.y = c;
								}
								else if (i == 2)
								{
									point.x = a;
									point.y = d;
								}
								else if (i == 3)
								{
									point.x = b;
									point.y = d;
								}
								
								// Placer le point selon la matrice
								//point.x = - _matrix.tx + ((i == 1 || i == 3) ? _matrix.a : 0);
								//point.y = - _matrix.ty + ((i == 2 || i == 3) ? _matrix.d : 0);
								
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