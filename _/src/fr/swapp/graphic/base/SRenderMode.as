package fr.swapp.graphic.base
{
	/**
	 * @author ZoulouX
	 */
	public class SRenderMode
	{
		// TODO : Ajoute un mode de rendu qui permet de déplacement l'image dans le composant (ex : photo multitouch)
		
		/**
		 * Stretch the image to the component size. Image proportions are not respected.
		 */
		public static const STRECH						:String 							= "strechRenderMode";
		
		/**
		 * Don't scale the image. The image have its original size, computed with the density.
		 * Component size will not be changed.
		 */
		public static const NO_SCALE					:String 							= "noScaleRenderMode";
		
		/**
		 * Repeat the image through the component. The image have the same size as NO_SCALE mode.
		 * Be carefull about x² size which can create blank areas if not respected.
		 */
		public static const REPEAT						:String 							= "repeatRenderMode";
		
		/**
		 * Center the image in the component. The image have the same size as NO_SCALE mode.
		 */
		public static const CENTER						:String 							= "centerRenderMode";
		
		/**
		 * Maximise the image size in the component. Proportions will be respected and image is showed entirely.
		 */
		public static const INSIDE						:String 							= "insideRenderMode";
		
		/**
		 * Maximise the image size in the component. Proportions will be respected but image can overflow the component.
		 * Property allowOverflow on SGraphic prevent the overflow and the image will be cutted.
		 */
		public static const OUTSIDE						:String 							= "outsideRenderMode";
		
		/**
		 * The component will automatically have the size of the image, with proportions respected and computed with density.
		 */
		public static const AUTO_SIZE					:String 							= "autoSizeRenderMode";
		
		/**
		 * Show image from atlas
		 */
		public static const ATLAS						:String 							= "atlasRenderMode";
		
		/**
		 * Use Scale 3 grid to show a fluid image with 3 horizontal slices.
		 */
		public static const HORIZONTAL_SCALE_3_RENDER	:String								= "horizontalScale3RenderMode"
		
		/**
		 * Use Scale 3 grid to show a fluid image with 3 vertical slices.
		 */
		public static const VERTICAL_SCALE_3_RENDER		:String								= "verticalScale3RenderMode";
		
		/**
		 * Use Scale 9 grid to show a fluid image with 9 slices.
		 */
		public static const SCALE_9_RENDER				:String								= "scale9RenderMode";
		
		/**
		 * Use Scale grid automatically from image.
		 */
		public static const AUTO_SCALE_RENDER			:String								= "autoScaleRenderMode";
	}
}