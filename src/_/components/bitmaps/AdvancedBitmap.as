package fr.swapp.graphic._.components.bitmaps 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.CapsStyle;
	import flash.display.JointStyle;
	import flash.display.LineScaleMode;
	import flash.display.PixelSnapping;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import fr.swapp.graphic.base.ResizableComponent;
	
	/**
	 * @author ZoulouX
	 */
	public class AdvancedBitmap extends ResizableComponent 
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
		 * La couleur de fond (-1 pour aucun)
		 */
		protected var _backgroundColor					:int								= -1;
		
		/**
		 * La transparence de la couleur de fond
		 */
		protected var _backgroundAlpha					:Number								= 1;
		
		/**
		 * La taille du contour (0 pour pas de contour)
		 */
		protected var _outlineSize						:Number								= 0;
		
		/**
		 * La couleur du contour (noir par défaut)
		 */
		protected var _outlineColor						:uint								= 0x000000;
		
		/**
		 * L'alpha du contour
		 */
		protected var _outlineAlpha						:Number								= 1;
		
		
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
		 * Le bitmap pour le rendu bitmap
		 */
		protected var _bitmap							:Bitmap;
		
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
		 * Le nombre de tranches horizontales
		 */
		protected var _horizontalSlices					:uint;
		
		/**
		 * Le nombre de tranches verticales
		 */
		protected var _verticalSlices					:uint;
		
		/**
		 * La couleur limite pour le découpage
		 */
		protected var _cutThreshold						:uint							= 0x777777;
		
		
		/**
		 * Lisser l'image
		 */
		protected var _smoothing						:Boolean							= true;
		
		/**
		 * Si les bitmaps doivent coller au pixel (uniquement pour les modes de rendu BITMAP_RENDER_MODE et AUTO_SCALE9_RENDER_MODE)
		 */
		protected var _pixelSnapping					:String							= PixelSnapping.ALWAYS;
		
		/**
		 * Les bitmaps (1 par coupe)
		 */
		protected var _bitmaps							:Vector.<Vector.<Bitmap>>;
		
		/**
		 * Si le dessin est invalidé
		 */
		protected var _drawInvalidated					:Boolean						= false;
		
		
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
				
				// On prépare le mode de rendu bitmap si besoin
				prepareBitmapMode();
				
				// On prépare le scale9 si besoin
				prepareScale9Mode();
				
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
				
				// On prépare le mode de rendu bitmap si besoin
				prepareBitmapMode();
				
				// On prépare le scale9 si besoin
				prepareScale9Mode();
				
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
		public function get outlineSize ():Number { return _outlineSize; }
		public function set outlineSize (value:Number):void 
		{
			// Si c'est différent
			if (_outlineSize != value)
			{
				// Enregistrer
				_outlineSize = value;
				
				// Rendre le dessin invalide
				invalidateDraw();
			}
		}
		
		/**
		 * La couleur du contour (noir par défaut)
		 */
		public function get outlineColor ():uint { return _outlineColor; }
		public function set outlineColor (value:uint):void 
		{
			// Si c'est différent
			if (_outlineColor != value)
			{
				// Enregistrer
				_outlineColor = value;
				
				// Rendre le dessin invalide
				invalidateDraw();
			}
		}
		
		/**
		 * L'alpha du contour
		 */
		public function get outlineAlpha ():Number { return _outlineAlpha; }
		public function set outlineAlpha (value:Number):void 
		{
			// Si c'est différent
			if (_outlineAlpha != value)
			{
				// Enregistrer
				_outlineAlpha = value;
				
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
				updateBitmapProperties();
			}
		}
		
		/**
		 * Si les bitmaps doivent coller au pixel (uniquement pour les modes de rendu BitmapRender.BITMAP_RENDER_MODE et BitmapRender.AUTO_SCALE9_RENDER_MODE)
		 */
		public function get pixelSnapping ():Boolean { return _pixelSnapping == PixelSnapping.ALWAYS; }
		public function set pixelSnapping (value:Boolean):void
		{
			// Enregistrer
			_pixelSnapping = value ? PixelSnapping.ALWAYS : PixelSnapping.NEVER;
			
			// Actualiser les propriétés du bitmap
			updateBitmapProperties();
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
		 * Les coordonnées des tranches a suivre pour le découpage
		 */
		public function get slices ():Rectangle { return _slices; }
		
		/**
		 * Le nombre de tranches horizontales sur le scale9
		 */
		public function get horizontalSlices ():uint { return _horizontalSlices; }
		
		/**
		 * Le nombre de tranches verticales sur le scale9
		 */
		public function get verticalSlices ():uint { return _verticalSlices; }
		
		/**
		 * La couleur limite pour le découpage.
		 * La modification de cette valeur ne redéclanchera pas le découpage.
		 */
		public function get cutThreshold ():uint { return _cutThreshold; }
		public function set cutThreshold (value:uint):void
		{
			_cutThreshold = value;
		}
		
		
		/**
		 * Le constructeur
		 * @param	pBitmapData : Le bitmapData a afficher (optionnel, une couleur unie sera affichée si null)
		 * @param	pRenderMode : Le mode de rendu du bitmap (voir static)
		 * @param	pDensity : La densité de l'image. Par exemple si l'image est en format retina, la densité sera de 2. Ne servira que les modes de rendu BitmapRender.AUTO_SIZE_RENDER_MODE et BitmapRender.REPEAT_RENDER_MODE
		 * @param	pBackgroundColor La couleur de fond (optionnel, rien ne sera affiché si -1)
		 */
		public function AdvancedBitmap (pBitmapData:BitmapData = null, pRenderMode:String = "insideRenderMode", pDensity:Number = 1, pBackgroundColor:int = -1)
		{
			// Enregistrer
			_bitmapData = pBitmapData;
			_backgroundColor = pBackgroundColor;
			_density = pDensity;
			
			// Supprimer les slices
			deleteSlices();
			
			// Le mode de rendu en dernier pour invalider une première fois
			renderMode = pRenderMode;
		}
		
		
		/**
		 * Préparer le bitmap pour le mode de rendu bitmap
		 */
		protected function prepareBitmapMode ():void
		{
			// Si on n'est plus en mode bitmap mais qu'il reste un bitmap
			if (_bitmap != null)
			{
				// On le vire
				removeChild(_bitmap);
				_bitmap = null;
			}
			
			// Si on est en mode de rendu bitmap
			if (_renderMode == BitmapRender.BITMAP_RENDER)
			{
				// On créé le bitmap porteur
				_bitmap = new Bitmap(_bitmapData, _pixelSnapping ? PixelSnapping.ALWAYS : PixelSnapping.NEVER, _smoothing);
				
				// Et on l'ajoute
				addChild(_bitmap);
			}
			
			// Si on a un bitmap, on lui applique le bitmapData
			if (_bitmap != null)
			{
				_bitmap.bitmapData = _bitmapData;
			}
		}
		
		/**
		 * Préparer la découpe pour le scale9
		 */
		protected function prepareScale9Mode ():void
		{
			// Si on est plus en mode scale 9 mais qu'on a encore des slices
			if (_bitmaps.length > 0)
			{
				// Supprimer les slices
				deleteSlices();
			}
			
			// Si on est en mode de rendu scale9
			if (_renderMode == BitmapRender.AUTO_SCALE9_RENDER)
			{
				// Récupérer automatiquement les coupures depuis l'image source
				getSlices();
				
				// Couper le bitmap
				slice();
			}
		}
		
		
		/******************************************
					  Méthodes ouvertes
		 ******************************************/
		
		/**
		 * Définir le décallage du bitmap
		 * @param	pHorizontalOffset : Le décallage horizontal
		 * @param	pVerticalOffset : Le décallage vertical
		 * @return this, méthode chaînable
		 */
		public function bitmapOffset (pHorizontalOffset:int, pVerticalOffset:int):AdvancedBitmap
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
		 * La couleur de fond
		 * @param	pBackgroundColor : La couleur (-1 pour transparent)
		 * @param	pBackgroundAlpha : La transparence du fond
		 * @return this, méthode chaînable
		 */
		public function background (pBackgroundColor:int, pBackgroundAlpha:Number = 1):AdvancedBitmap
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
		 * Le contour.
		 * @param	pOutlineSize : La taille du contour (0 ou NaN pour aucun contour)
		 * @param	pOutlineColor : La couleur du contour
		 * @param	pOutlineAlpha : La transparence du contour
		 * @return this, méthode chaînable
		 */
		public function border (pOutlineSize:Number, pOutlineColor:uint = 0, pOutlineAlpha:Number = 1):AdvancedBitmap
		{
			// Enregistrer
			_outlineSize = pOutlineSize;
			_outlineColor = pOutlineColor;
			_outlineAlpha = pOutlineAlpha;
			
			// Rendre le dessin invalide
			invalidateDraw();
			
			// Méthode chaînable
			return this;
		}
		
		/**
		 * Bordures arrondies individuelles
		 * @param	pTopLeftRadius : La taille de l'arrondis du coin d'en haut à gauche
		 * @param	pTopRightRadius : La taille de l'arrondis du coin d'en haut à droite
		 * @param	pBottomRightRadius : La taille de l'arrondis du coin d'en bas à droite
		 * @param	pBottomLeftRadius : La taille de l'arrondis du coin d'en haut à gauche
		 * @return this, méthode chaînable
		 */
		public function radius (pTopLeftRadius:int, pTopRightRadius:int, pBottomRightRadius:int, pBottomLeftRadius:int):AdvancedBitmap
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
		 * Appliquer une valeur d'arrondis aux 4 coins.
		 * @param	pRadius : La taille de l'arrondis de tous les coins
		 * @return this, méthode chaînable
		 */
		public function allRadius (pRadius:int):AdvancedBitmap
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
		 * Invalider le dessin
		 */
		public function invalidateDraw ():void
		{
			// Si le dessin n'est pas déjà invalidé
			if (!_drawInvalidated)
			{
				// Invalider le dessin
				_drawInvalidated = true;
				
				// Lancer la phase de prérendu et de rendu
				launchRenderPhase();
				launchPreparePhase();
			}
		}
		
		/**
		 * Replacer le composant
		 */
		override protected function replace ():void
		{
			// Si on est en mode de rendu taille auto, et qu'on a une image
			if (_renderMode == BitmapRender.AUTO_SIZE_RENDER && _bitmapData != null)
			{
				// Appliquer les dimensions de l'image
				_localWidth = _bitmapData.width / _density;
				_localHeight = _bitmapData.height / _density;
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
			
			// Si on est en mode de rendu scaleNine
			if (_renderMode == BitmapRender.AUTO_SCALE9_RENDER && _bitmapData != null && _slices != null)
			{
				// Les dimensions de l'image avec ou sans les coupures
				//const imageOffset:uint = (_autoSliced ? 2 : 0);
				const imageOffset:uint = 2;
				
				// Les positions des lignes / colonnes
				var dRows	:Vector.<Number> = Vector.<Number>([
					0,
					_slices.top - imageOffset,
					(_localHeight * _density - (_bitmapData.height - _slices.bottom)),
					_localHeight * _density
				]);
				var dCols	:Vector.<Number> = Vector.<Number>([
					0,
					_slices.left - imageOffset,
					(_localWidth * _density - (_bitmapData.width - _slices.right)),
					_localWidth * _density
				]);
				
				// Le bitmap traité
				var currentBitmap:Bitmap;
				
				// Parcourir les blocs horizontalement
				for (var cx:uint = 0; cx < _horizontalSlices; cx++)
				{
					// Parcourir les blocs verticalement
					for (var cy:uint = 0; cy < _verticalSlices; cy++)
					{
						// Cibler le bitmap
						currentBitmap = _bitmaps[cx][cy];
						
						// Placer le bloc
						currentBitmap.x = int(dCols[cx] / _density + .5);
						currentBitmap.y = int(dRows[cy] / _density + .5);
						currentBitmap.width = int((dCols[cx + 1] - dCols[cx]) / _density + .5);
						currentBitmap.height = int((dRows[cy + 1] - dRows[cy]) / _density + .5);
					}
				}
			}
			else
			{
				// Si on a un bitmap
				if (_bitmap != null)
				{
					// On lui applique les dimensions
					_bitmap.width = _localWidth;
					_bitmap.height = _localHeight;
				}
				
				// Si on a des dimensions
				else if (_localWidth > 0 && _localHeight > 0)
				{
					// Si on a un contour
					if (_outlineSize > 0)
					{
						// On dessine le contour
						graphics.lineStyle(_outlineSize, _outlineColor, _outlineAlpha);
					}
					
					// Si on a un bitmapData
					if (_bitmapData != null)
					{
						// Actualiser la matrice
						updateMatrix();
						
						// Si on a une couleur de fond
						// Et si on est sur un mode de rendu ou le contenu peut être plus petit que la zone d'affichage
						if (_backgroundColor != -1 && _renderMode != BitmapRender.REPEAT_RENDER && _renderMode != BitmapRender.AUTO_SIZE_RENDER && _renderMode != BitmapRender.STRECH_RENDER)
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
						graphics.beginBitmapFill(_bitmapData, _matrix, _renderMode == BitmapRender.REPEAT_RENDER, _smoothing);
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
			if (_renderMode == BitmapRender.STRECH_RENDER)
			{
				// Scaler au composant
				horizontalScale = _localWidth / _bitmapData.width;
				verticalScale = _localHeight / _bitmapData.height;
			}
			else if (_renderMode == BitmapRender.INSIDE_RENDER || _renderMode == BitmapRender.OUTSIDE_RENDER)
			{
				// On applique les 2 dimensions sur le ratio horizontal
				verticalScale = horizontalScale = _localWidth / _bitmapData.width;
				
				// Et on regarde le comportement du ratio vertical
				if (
						_renderMode == BitmapRender.INSIDE_RENDER && _bitmapData.height * verticalScale > _localHeight
						||
						_renderMode == BitmapRender.OUTSIDE_RENDER && _bitmapData.height * verticalScale < _localHeight
					)
				{
					// On appliquer les 2 dimensions sur le ratio vertical
					verticalScale = horizontalScale = _localHeight / _bitmapData.height;
				}
			}
			
			// Appliquer la densité pour ces modes de rendu
			else if (_renderMode == BitmapRender.AUTO_SIZE_RENDER || _renderMode == BitmapRender.REPEAT_RENDER || _renderMode == BitmapRender.NO_SCALE_RENDER)
			{
				horizontalScale = 1 / _density;
				verticalScale = 1 / _density;
			}
			
			// Appliquer le scale
			_matrix.scale(horizontalScale, verticalScale);
			
			// Si on doit centrer
			if (_renderMode == BitmapRender.CENTER_RENDER || _renderMode == BitmapRender.INSIDE_RENDER || _renderMode == BitmapRender.OUTSIDE_RENDER)
			{
				// On centre par rapport aux précédentes modifications du scale
				_matrix.translate(
					_localWidth / 2 - _bitmapData.width * horizontalScale / 2 + _bitmapHorizontalOffset,
					_localHeight / 2 - _bitmapData.height * verticalScale / 2 + _bitmapVerticalOffset
				);
				
				// Si on autorise pas les dépassements de dessin de l'image
				if (_allowOverflow || _renderMode == BitmapRender.INSIDE_RENDER)
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
		 * Actualiser les propriété d'affichage des bitmaps
		 */
		protected function updateBitmapProperties ():void
		{
			// Si on est en mode bitmap
			if (_bitmap != null)
			{
				// Appliquer les valeurs sur le seul bitmap
				_bitmap.smoothing 		= _smoothing;
				_bitmap.pixelSnapping 	= _pixelSnapping;
			}
			else if (_bitmaps.length > 0)
			{
				// Parcourir les blocs horizontalement
				for (var cx:uint = 0; cx < _horizontalSlices; cx++)
				{
					// Parcourir les blocs verticalement
					for (var cy:uint = 0; cy < _verticalSlices; cy++)
					{
						// Cibler le bitmap et appliquer les valeurs
						_bitmaps[cx][cy].smoothing 		= _smoothing;
						_bitmaps[cx][cy].pixelSnapping 	= _pixelSnapping;
					}
				}
			}
			else
			{
				// Rendre le dessin invalide
				invalidateDraw();
			}
		}
		
		
		/******************************************
						  Découpe
		 ******************************************/
		
		/**
		 * Récupérer la position des coupures sur l'image
		 */
		protected function getSlices ():void
		{
			// Les limites
			var x1:uint = 1;
			var x2:uint = _bitmapData.width - 1;
			var y1:uint = 1;
			var y2:uint = _bitmapData.height - 1;
			
			// Récupérer le scale horizontal de gauche
			while (_bitmapData.getPixel(x1, 0) > _cutThreshold && x1 < _bitmapData.width)
			{
				// On va vers la droite
				x1 ++;
			}
			
			// Vérifier si on a trouvé un truc
			if (x1 < x2)
			{
				// On a 3 blocs horizontaux
				_horizontalSlices = 3;
				
				// Récupérer le scale horizontal de droite
				while (_bitmapData.getPixel(x2, 0) > _cutThreshold && x2 > 1)
				{
					// On va vers la gauche
					x2 --;
				}
			}
			else
			{
				// On a qu'un seul bloc horizontal
				_horizontalSlices = 1;
				
				// Remettre le premier à la fin
				x1 = x2;
			}
			
			// Récupérer le scale vertical du haut
			while (_bitmapData.getPixel(0, y1) > _cutThreshold && y1 < _bitmapData.height)
			{
				// On va vers le bas
				y1 ++;
			}
			
			// Vérifier si on a trouvé un truc
			if (y1 < y2)
			{
				// On a 3 blocs verticaux
				_verticalSlices = 3;
				
				// Récupérer le scale vertical du haut
				while (_bitmapData.getPixel(0, y2) > _cutThreshold && y2 > 1)
				{
					// On va vers le haut
					y2 --;
				}
			}
			else
			{
				// On a qu'un seul bloc vertical
				_verticalSlices = 1;
				
				// Remettre le premier à la fin
				y1 = y2;
			}
			
			// Enregistrer le rectangle
			_slices = new Rectangle(x1, y1, x2 - x1 + 1, y2 - y1 + 1);
		}
		
		/**
		 * Effacer les anciennes coupes
		 */
		protected function deleteSlices ():void
		{
			// Si on a des slices
			if (_bitmaps != null)
			{
				// Parcourir les blocs horizontalement
				for (var cx:uint = 0; cx < _bitmaps.length; cx++)
				{
					// Parcourir les blocs verticalement
					for (var cy:uint = 0; cy < _bitmaps[cx].length; cy++)
					{
						// Disposer le bitmapData
						_bitmaps[cx][cy].bitmapData.dispose();
						
						// Supprimer le bloc de la DisplayList
						removeChild(_bitmaps[cx][cy]);
					}
				}
			}
			
			// Réinitialiser les bitmaps
			_bitmaps = new Vector.<Vector.<Bitmap>>;
		}
		
		/**
		 * Couper
		 */
		protected function slice ():void
		{
			// Si on a une image source
			if (_bitmapData != null && _slices != null)
			{
				// Les dimensions de l'image avec ou sans les coupures
				//const imageOffset:uint = (_autoSliced ? 2 : 0);
				const imageOffset:uint = 2;
				
				// Les positions des lignes / colonnes
				var rows	:Vector.<Number> = Vector.<Number>([imageOffset, _slices.top, _slices.bottom, _bitmapData.height]);
				var cols	:Vector.<Number> = Vector.<Number>([imageOffset, _slices.left, _slices.right, _bitmapData.width]);
				
				// Les rectangles de placement
				var origin	:Rectangle;
				
				// Le bitmap et ses données qui vont être créés
				var currentBitmapData	:BitmapData;
				var currentBitmap		:Bitmap;
				
				// Le point pour la copie (origine)
				var topPoint			:Point = new Point(0, 0);
				
				// Parcourir les blocs horizontalement
				for (var cx:uint = 0; cx < _horizontalSlices; cx++)
				{
					// Créer la seconde dimension du vecteur
					_bitmaps[cx] = new Vector.<Bitmap>;
					
					// Parcourir les blocs verticalement
					for (var cy:uint = 0; cy < _verticalSlices; cy++)
					{
						// Cibler l'origine de la coupe
						origin = new Rectangle(cols[cx], rows[cy], cols[cx + 1] - cols[cx], rows[cy + 1] - rows[cy]);
						
						// Créer le bitmapData de ce bloc
						currentBitmapData = new BitmapData(origin.width, origin.height, _bitmapData.transparent);
						
						// Copier les pixels du bitmap d'origine vers le bitmap du bloc
						currentBitmapData.copyPixels(_bitmapData, origin, topPoint);
						
						// Créer le bloc et lui associer le bitmapData
						currentBitmap = new Bitmap(currentBitmapData, _pixelSnapping ? PixelSnapping.ALWAYS : PixelSnapping.NEVER, _smoothing);
						
						// Enregistrer ce bitmap dans le vecteur bi-dimensionnel
						_bitmaps[cx][cy] = currentBitmap;
						
						// L'ajouter à la scène
						addChild(_bitmaps[cx][cy]);
					}
				}
			}
		}
	}
}