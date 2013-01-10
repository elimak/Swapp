package fr.swapp.graphic.components.misc
{
	import com.greensock.TweenMax;
	import flash.display.BitmapData;
	import fr.swapp.graphic.base.ResizableComponent;
	import fr.swapp.graphic.components.bitmaps.AdvancedBitmap;
	import fr.swapp.graphic.components.bitmaps.BitmapRender;
	import fr.swapp.graphic.errors.GraphicalError;
	
	/**
	 * @author ZoulouX
	 */
	public class DotIndicator extends ResizableComponent
	{
		/**
		 * L'image des points
		 */
		protected var _dotsBitmapData				:BitmapData;
		
		/**
		 * Le nombre de points à afficher
		 */
		protected var _totalDots					:int;
		
		/**
		 * La taille d'un point
		 */
		protected var _dotSize						:int;
		
		/**
		 * La marge entre chaque point
		 */
		protected var _dotMargin					:int;
		
		/**
		 * L'alpha d'un point désactivé
		 */
		protected var _disableAlpha					:Number;
		
		/**
		 * Le point séléctionné
		 */
		protected var _selectedIndex				:int							 = -1;
		
		/**
		 * La liste des points
		 */
		protected var _dots							:Vector.<AdvancedBitmap>;
		
		
		/**
		 * L'image des points
		 */
		public function get dotsBitmapData ():BitmapData { return _dotsBitmapData; }
		public function set dotsBitmapData (value:BitmapData):void
		{
			// Si on n'a pas d'image
			if (value == null)
			{
				// On déclanche une erreur et on arrête
				throw new GraphicalError("DotIndicator.dotsBitmapData", "Can't set null bitmapData");
				return;
			}
			
			// Enregistrer l'image
			_dotsBitmapData = value;
			
			// Reconstruire
			rebuild();
		}
		
		/**
		 * Le nombre de points à afficher
		 */
		public function get totalDots ():int { return _totalDots; }
		public function set totalDots (value:int):void
		{
			// Si la valeur est différente
			if (value != _totalDots)
			{
				// Enregistrer
				_totalDots = value;
				
				// Reconstruire
				rebuild();
			}
		}
		
		/**
		 * La taille d'un point
		 */
		public function get dotSize ():int { return _dotSize; }
		public function set dotSize (value:int):void
		{
			// Si la valeur est différente
			if (value != _dotSize)
			{
				// Enregistrer
				_dotSize = value;
				
				// Replacer
				updateLayout();
			}
		}
		
		/**
		 * La marge entre chaque point
		 */
		public function get dotMargin ():int { return _dotMargin; }
		public function set dotMargin (value:int):void
		{
			// Si la valeur est différente
			if (value != _dotMargin)
			{
				// Enregistrer
				_dotMargin = value;
				
				// Replacer
				updateLayout();
			}
		}
		
		/**
		 * L'alpha d'un point désactivé
		 */
		public function get disableAlpha ():Number { return _disableAlpha; }
		public function set disableAlpha (value:Number):void
		{
			// Si la valeur est différente
			if (value != _disableAlpha)
			{
				// Enregistrer
				_disableAlpha = value;
				
				// Actualiser le point séléctionné
				instantSelectPoint();
			}
		}
		
		/**
		 * Le point séléctionné
		 */
		public function get selectedIndex ():int { return _selectedIndex; }
		public function set selectedIndex (value:int):void
		{
			// Si la valeur est différente
			if (value != _selectedIndex)
			{
				// Enregistrer
				_selectedIndex = value;
				
				// Actualiser le point séléctionné
				instantSelectPoint();
			}
		}
		
		
		/**
		 * Le constructeur
		 * @param	pDotBitmapData : L'image des points
		 * @param	pTotalDots : Le nombre de points à afficher
		 * @param	pSelectedIndex : Le point séléctionné (aucun par défaut)
		 * @param	pDotSize : La taille d'un point
		 * @param	pDotMargin : La marge entre chaque point
		 * @param	pDisableAlpha : L'alpha d'un point désactivé
		 */
		public function DotIndicator (pDotBitmapData:BitmapData, pTotalDots:int = 0, pSelectedIndex:int = -1, pDotSize:int = 6, pDotMargin:int = 5, pDisableAlpha:Number = .6)
		{
			// Activer les styles
			_styleEnabled = true;
			
			// Si on n'a pas d'image
			if (pDotBitmapData == null)
			{
				// On déclanche une erreur et on arrête
				throw new GraphicalError("DotIndicator{}", "pDotBitmapData can't be null");
				return;
			}
			
			// TODO: Refaire le dotIndicator avec invalidate.
			
			// Enregistrer l'image
			_dotsBitmapData = pDotBitmapData;
			
			// Appliquer le layout
			dotsLayout(pTotalDots, pDotSize, pDotMargin, pDisableAlpha);
			
			// Séléctionner
			selectedIndex = pSelectedIndex;
		}
		
		
		/**
		 * Règles de positionnements de points
		 * @param	pTotalDots : Le nombre de points à afficher
		 * @param	pDotSize : La taille d'un point
		 * @param	pDotMargin : La marge entre chaque point
		 * @param	pDisableAlpha : L'alpha d'un point désactivé
		 */
		public function dotsLayout (pTotalDots:int = 0, pDotSize:int = 6, pDotMargin:int = 5, pDisableAlpha:Number = .6):void
		{
			// Enregistrer les valeurs
			_totalDots = pTotalDots;
			_dotSize = pDotSize;
			_dotMargin = pDotMargin;
			_disableAlpha = pDisableAlpha;
			
			// Construire
			rebuild();
		}
		
		/**
		 * Séléctionner un point avec une animation
		 * @param	pIndex : Le point à séléctionner
		 * @param	pAnimationDuration : la durée de l'animation
		 */
		public function select (pIndex:int, pAnimationDuration:Number = .4):void
		{
			// Enregistrer
			_selectedIndex = pIndex;
			
			// Parcourir tous les points
			var i:int = _dots.length;
			while (--i >= 0)
			{
				// Définir l'alpha selon la séléction
				TweenMax.to(_dots[i], pAnimationDuration, {
					alpha: (i == _selectedIndex ? 1 : _disableAlpha)
				});
			}
		}
		
		/**
		 * Séléctionner directement le bon point, sans animation
		 */
		protected function instantSelectPoint ():void
		{
			// Parcourir tous les points
			var i:int = _dots.length;
			while (--i >= 0)
			{
				// Définir l'alpha selon la séléction
				_dots[i].alpha = (i == _selectedIndex ? 1 : _disableAlpha);
			}
		}
		
		/**
		 * Reconstruire les points
		 */
		protected function rebuild ():void
		{
			// Le point traité
			var dot:AdvancedBitmap
			
			// Si on a déjà des points
			if (_dots != null)
			{
				// On les détruit tous
				for each (dot in _dots)
				{
					removeChild(dot);
				}
			}
			
			// Nouveau tableau de points
			_dots = new <AdvancedBitmap>[];
			
			// Créer le nombre de points demandé
			for (var i:int = 0; i < _totalDots; i++) 
			{
				// Créer le point
				dot = new AdvancedBitmap(_dotsBitmapData, BitmapRender.BITMAP_RENDER_MODE);
				
				// L'enregistrer dans le vecteur
				_dots[i] = dot;
				
				// Cache as bitmap
				//dot.cab(true, dot.transform.concatenatedMatrix);
				
				// L'afficher
				addChild(dot);
			}
			
			// Replacer
			updateLayout();
		}
		
		/**
		 * Actualiser le positionnement des points
		 */
		protected function updateLayout ():void
		{
			// Parcourir les points
			var dot:AdvancedBitmap;
			var i:int = _dots.length;
			while (--i >= 0)
			{
				// Cibler
				dot = _dots[i];
				
				// Spécifier la taille
				dot.size(_dotSize, _dotSize);
				
				// Placer
				dot.x = i * _dotSize;
				
				// Décaller
				if (i > 0)
				{
					dot.x += i * _dotMargin;
				}
			}
			
			// Définir la taille du composant
			size(_dots.length * _dotSize + Math.max(0, _dots.length - 1) * _dotMargin, _dotSize);
		}
	}
}