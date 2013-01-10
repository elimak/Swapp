package fr.swapp.touch.indicator 
{
	import flash.display.Shape;
	import flash.display.Sprite;
	
	/**
	 * @author ZoulouX
	 */
	public class VisualCross extends Sprite
	{
		/**
		 * Dessiner une croix
		 * @param	pHeight
		 * @param	pWidth
		 * @param	pColor
		 * @param	pThikness
		 * @param	pAlpha
		 */
		public function VisualCross (pHeight:Number = 20, pWidth:Number = 20, pColor:uint = 0x121212, pThikness:Number = 2, pAlpha:Number = 1)
		{
			// Paramétrer le dessin
			graphics.lineStyle(pThikness, pColor, pAlpha);
			
			// Tracer la croix
			graphics.moveTo(0, -pHeight / 2 + pThikness / 2);
			graphics.lineTo(0, pHeight / 2 - pThikness / 2);
			graphics.moveTo(-pWidth / 2 + pThikness / 2, 0);
			graphics.lineTo(pWidth / 2 - pThikness / 2, 0);
			
			// Désactiver les intéractions sur cet élément
			hitArea = new Sprite();
			mouseEnabled = false;
		}
	}
}