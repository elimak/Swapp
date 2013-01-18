package fr.swapp.graphic.base 
{
	import flash.display.BitmapData;
	import flash.display.CapsStyle;
	import flash.display.GradientType;
	import flash.display.JointStyle;
	import flash.display.LineScaleMode;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import fr.swapp.graphic.atlas.SAtlasItem;
	import fr.swapp.graphic.errors.GraphicalError;
	
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
		protected var _smoothing						:Boolean						= true;
		
		/**
		 * Si le dessin est invalidé
		 */
		protected var _drawInvalidated					:Boolean						= false;
		
		/**
		 * Spécific texture width for atlas
		 */
		protected var _bitmapSpecificWidth				:int							= 0;
		
		/**
		 * Spécific texture height for atlas
		 */
		protected var _bitmapSpecificHeight				:int							= 0;
		
		
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
			// Si on est en mode de rendu atlas
			if (_renderMode == SRenderMode.ATLAS)
			{
				// On lève une erreur
				throw new GraphicalError("SGraphic.renderMode", "Can't change renderMode while atlas is setted. Cancel Atlas with the atlas method with null SAtlasItem in parameter.");
				return;
			}
			
			// Si c'est différent
			if (_renderMode != value)
			{
				// Enregistrer le nouveau mode
				_renderMode = value;
				
				// On prépare le scale9 si besoin
				prepareScale9Mode();
				
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
				// Enregistrer
				_backgroundType = value;
				
				// Invalider le dessin
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
				updateBitmapProperties();
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
			if (_bitmapData != null)
			{
				value %= _bitmapData.width;
			}
			
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
			if (_bitmapData != null)
			{
				value %= _bitmapData.height;
			}
			
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
		 * Constructor
		 * Set texture to draw. If pBitmapData is null, it will be ignored.
		 * Set renderMode to specify how the texture will fit in this component.
		 * Set density for retina images for exemple.
		 * @param	pBitmapData : Texture to be drawn. Null to ignore.
		 * @param	pRenderMode : RenderMode from SRenderMode to fit texture in this component.
		 * @param	pDensity : Density of the texture.
		 */
		public function SGraphic (pBitmapData:BitmapData = null, pRenderMode:String = null, pDensity:Number = 1)
		{
			image(pBitmapData, pRenderMode, pDensity);
		}
		
		
		/**
		 * Préparer la découpe pour le scale9
		 */
		protected function prepareScale9Mode ():void
		{
			/*
			// Si on est plus en mode scale 9 mais qu'on a encore des slices
			if (_bitmaps.length > 0)
			{
				// Supprimer les slices
				deleteSlices();
			}
			
			// Si on est en mode de rendu scale9
			if (_renderMode == SRenderMode.AUTO_SCALE9)
			{
				// Récupérer automatiquement les coupures depuis l'image source
				getSlices();
				
				// Couper le bitmap
				slice();
			}
			*/
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
			backgroundType = pBackgroundType;
			
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
			invalidateDraw();
			
			// Méthode chaînable
			return this;
		}
		
		/**
		 * Show Atlas Texture
		 * @param	pAtlasItem : AtlasItem to show. Set to null to disable Atlas renderMode.
		 */
		public function atlas (pAtlasItem:SAtlasItem):void
		{
			// Si on a un atlas
			if (pAtlasItem != null)
			{
				// On enregistre toutes les coordonnées
				_density = pAtlasItem.associatedAtlas.density;
				_bitmapHorizontalOffset = - pAtlasItem.x / _density;
				_bitmapVerticalOffset = - pAtlasItem.y / _density;
				_bitmapSpecificWidth = pAtlasItem.width;
				_bitmapSpecificHeight = pAtlasItem.height;
				_bitmapData = pAtlasItem.associatedAtlas.bitmapData;
				
				// Appliquer la size de la texture au composant
				size(_bitmapSpecificWidth / _density, _bitmapSpecificHeight / _density);
				
				// On passe le mode de rendu en atlas
				_renderMode = SRenderMode.ATLAS;
			}
			else
			{
				// Sinon on vire toutes les propriété atlas
				_bitmapHorizontalOffset = 0;
				_bitmapVerticalOffset = 0;
				_bitmapSpecificWidth = 0;
				_bitmapSpecificHeight = 0;
				_bitmapData = null;
				_density = 1;
				_renderMode = "";
			}
			
			// Invalider le dessin
			invalidateDraw();
		}
		
		
		/******************************************
						  Phases
		 ******************************************/
		
		/**
		 * Invalider le dessin
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
			if (_renderMode == SRenderMode.AUTO_SIZE && _bitmapData != null)
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
			//if (_renderMode == SRenderMode.AUTO_SCALE9 && _bitmapData != null && _slices != null)
			/*if (_bitmapData != null)
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
			{*/
				// Si le composant a une taille
				if (_localWidth > 0 && _localHeight > 0)
				{
					// Si on a un contour
					if (_borderSize > 0)
					{
						// On dessine le contour
						graphics.lineStyle(_borderSize, _borderColor, _borderAlpha, true, LineScaleMode.NORMAL, CapsStyle.SQUARE, JointStyle.MITER);
					}
					
					// Si on a un bitmapData
					if (_bitmapData != null)
					{
						// Actualiser la matrice
						updateMatrix();
						
						// Si on a un fond
						// Et si on est sur un mode de rendu ou le contenu peut être plus petit que la zone d'affichage
						if (_backgroundType != SBackgroundType.NONE && _renderMode != SRenderMode.REPEAT && _renderMode != SRenderMode.AUTO_SIZE && _renderMode != SRenderMode.STRECH && _renderMode != SRenderMode.ATLAS)
						{
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
						graphics.beginBitmapFill(_bitmapData, _matrix, _renderMode == SRenderMode.REPEAT, _smoothing);
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
			//}
		}
		
		/**
		 * Draw background
		 */
		protected function drawBackground ():void
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
					[0, 255],
					gradientMatrix
				);
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
				horizontalScale = _localWidth / _bitmapData.width;
				verticalScale = _localHeight / _bitmapData.height;
			}
			else if (_renderMode == SRenderMode.ATLAS)
			{
				// Scaler l'atlas au composant
				horizontalScale = _localWidth / _bitmapSpecificWidth;
				verticalScale = _localHeight / _bitmapSpecificHeight;
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
				
				// Déplacer selon les offsets
				_matrix.translate(_bitmapHorizontalOffset, _bitmapVerticalOffset);
			}
		}
		
		/**
		 * Actualiser les propriété d'affichage des bitmaps
		 */
		protected function updateBitmapProperties ():void
		{
			/*
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
			*/
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
			/*
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
			*/
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
				//var currentBitmap		:Bitmap;
				
				// Le point pour la copie (origine)
				var topPoint			:Point = new Point(0, 0);
				
				// Parcourir les blocs horizontalement
				for (var cx:uint = 0; cx < _horizontalSlices; cx++)
				{
					// Créer la seconde dimension du vecteur
					//_bitmaps[cx] = new Vector.<Bitmap>;
					
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
						//currentBitmap = new Bitmap(currentBitmapData, _pixelSnapping ? PixelSnapping.ALWAYS : PixelSnapping.NEVER, _smoothing);
						
						// Enregistrer ce bitmap dans le vecteur bi-dimensionnel
						//_bitmaps[cx][cy] = currentBitmap;
						
						// L'ajouter à la scène
						//addChild(_bitmaps[cx][cy]);
					}
				}
			}
		}
	}
}