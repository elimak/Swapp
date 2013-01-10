package fr.swapp.graphic.components.bitmaps
{
	import flash.display.BitmapData;
	
	/**
	 * Constantes vers plusieurs sortes de pixels pré-remplis.
	 * @author ZoulouX
	 */
	public class BitmapPixels
	{
		/**
		 * BitmapData d'un pixel transparent
		 */
		public static const TRANSPARENT_PIXEL			:BitmapData 						= new BitmapData(1, 1, true, 0x00000000);
		
		/**
		 * BitmapData d'un pixel rouge
		 */
		public static const RED_PIXEL					:BitmapData 						= new BitmapData(1, 1, false, 0xFF0000);
		
		/**
		 * BitmapData d'un pixel vert
		 */
		public static const GREEN_PIXEL					:BitmapData 						= new BitmapData(1, 1, false, 0x00FF00);
		
		/**
		 * BitmapData d'un pixel bleu
		 */
		public static const BLUE_PIXEL					:BitmapData 						= new BitmapData(1, 1, false, 0x0000FF);
		
		/**
		 * BitmapData d'un pixel noir
		 */
		public static const BLACK_PIXEL					:BitmapData 						= new BitmapData(1, 1, false, 0x000000);
		
		/**
		 * BitmapData d'un pixel gris foncé
		 */
		public static const DARK_GREY_PIXEL				:BitmapData 						= new BitmapData(1, 1, false, 0x444444);
		
		/**
		 * BitmapData d'un pixel gris moyen
		 */
		public static const MIDDLE_GREY_PIXEL			:BitmapData 						= new BitmapData(1, 1, false, 0x888888);
		
		/**
		 * BitmapData d'un pixel gris clair
		 */
		public static const BRIGHT_GREY_PIXEL			:BitmapData 						= new BitmapData(1, 1, false, 0xCCCCCC);
		
		/**
		 * BitmapData d'un pixel blanc
		 */
		public static const WHITE_PIXEL					:BitmapData 						= new BitmapData(1, 1, false, 0xFFFFFF);
		
	}
}