package fr.swapp.graphic.components.misc 
{
	import fr.swapp.graphic.base.ResizableComponent;
	
	/**
	 * @author ZoulouX
	 */
	public class BorderComponent extends ResizableComponent 
	{
		/**
		 * La couleur de la bordure
		 */
		protected var _borderColor							:uint;
		
		/**
		 * L'épaisseur de la bordure
		 */
		protected var _borderWidth							:Number;
		
		
		/**
		 * La couleur de la bordure
		 */
		public function get borderColor ():uint { return _borderColor; }
		public function set borderColor (value:uint):void 
		{
			_borderColor = value;
			
			updateDraw();
		}
		
		/**
		 * L'épaisseur de la bordure
		 */
		public function get borderWidth ():Number {return _borderWidth; }
		public function set borderWidth (value:Number):void 
		{
			_borderWidth = value;
			
			updateDraw();
		}
		
		
		/**
		 * Le constructeur
		 * @param	pBorderColor : La couleur de la bordure
		 * @param	pBorderWidth : L'épaisseur de la bordure
		 */
		public function BorderComponent (pBorderColor:uint = 0xFF0000, pBorderWidth:Number = 1)
		{
			// Activer les styles
			_styleEnabled = true;
			
			// Enregistrer
			_borderColor = pBorderColor;
			_borderWidth = pBorderWidth;
		}
		
		/**
		 * Les dimensions du composant ont changées
		 */
		override protected function resized ():void
		{
			// Actualiser
			updateDraw();
			
			// Relayer
			super.resized();
		}
		
		/**
		 * Actualiser le dessin
		 */
		public function updateDraw ():void
		{
			// Effacer
			graphics.clear();
			
			// Si on a des dimensions
			if (_localWidth > 0 && _localHeight > 0 && _borderWidth > 0)
			{
				// On dessine
				graphics.lineStyle(_borderWidth, _borderColor);
				graphics.drawRect(0, 0, _localWidth, _localHeight);
			}
		}
	}
}