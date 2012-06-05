package fr.swapp.graphic.components.bitmaps
{
	import flash.display.BitmapData;
	
	
	/**
	 * Constantes vers les modes de rendu d'AdvancedBitmap.
	 * Constantes vers plusieurs sortes de pixels pré-remplis.
	 * @author ZoulouX
	 */
	public class BitmapRender
	{
		/**
		 * Changement du mode de rendu, le rendu devient un bitmap et l'image sera étirée (la densité sera ignorée)
		 */
		public static const BITMAP_RENDER				:String 							= "bitmapRenderMode";
		
		/**
		 * Etirer l'image sur les 2 dimensions (la densité sera ignorée)
		 */
		public static const STRECH_RENDER				:String 							= "strechRenderMode";
		
		/**
		 * Pas de scaling appliqué (uniquement la densité)
		 */
		public static const NO_SCALE_RENDER				:String 							= "noScaleRenderMode";
		
		/**
		 * Répéter l'image (la densité sera appliquée)
		 */
		public static const REPEAT_RENDER				:String 							= "repeatRenderMode";
		
		/**
		 * Centrer l'image sans scaling
		 */
		public static const CENTER_RENDER				:String 							= "centerRenderMode";
		
		/**
		 * Scaler l'image par l'intérieur (spécifiez la couleur de fond pour voir les bordures)
		 */
		public static const INSIDE_RENDER				:String 							= "insideRenderMode";
		
		/**
		 * Scaler l'image par l'exérieur (image rognée)
		 */
		public static const OUTSIDE_RENDER				:String 							= "outsideRenderMode";
		
		/**
		 * Le composant fait la taille de l'image
		 */
		public static const AUTO_SIZE_RENDER			:String 							= "autoSizeRenderMode";
		
		/**
		 * Le composant est en mode sprite (utiliser les offsets pour afficher la bonne partie de l'image)
		 */
		public static const SPRITE_RENDER				:String 							= "spriteRenderMode";
		
		/**
		 * Le composant affichera avec un scaleNine automatique
		 */
		public static const AUTO_SCALE9_RENDER			:String								= "autoScale9RenderMode";
		
		
		
		
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