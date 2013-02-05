package fr.swapp.graphic.base
{
	/**
	 * @author ZoulouX
	 */
	public class SRenderMode
	{
		// TODO : Ajoute un mode de rendu qui permet de déplacement l'image dans le composant (ex : photo multitouch)
		// TODO : Implémenter le fait de continuer le dessin du bitmap ou non (avec le paramètre allowOverflow) en renderMode NO_SCALE / CENTER
		// TODO : Peut être implémenter des alignements de base ? Peut être pas utile vue qu'on a SCompoent qui le gère bien
		// TODO : Finir de traduire / refacto SGraphic
		// TODO : Ajouter un mode qui permet d'animer dans un Atlas, peut être faire un nouvelle classe qui étend SGraphic
		
		/**
		 * Stretch the image to the component size. Image proportions are not respected.
		 */
		public static const STRECH						:String 							= "strech";
		
		/**
		 * Don't scale the image. The image have its original size, computed with the density.
		 * Component size will not be changed.
		 */
		public static const NO_SCALE					:String 							= "noScale";
		
		/**
		 * Repeat the image through the component. The image have the same size as NO_SCALE mode.
		 * Be carefull about x² size which can create blank areas if not respected.
		 */
		public static const REPEAT						:String 							= "repeat";
		
		/**
		 * Center the image in the component. The image have the same size as NO_SCALE mode.
		 */
		public static const CENTER						:String 							= "center";
		
		/**
		 * Maximise the image size in the component. Proportions will be respected and image is showed entirely.
		 */
		public static const INSIDE						:String 							= "inside";
		
		/**
		 * Maximise the image size in the component. Proportions will be respected but image can overflow the component.
		 * Property allowOverflow on SGraphic prevent the overflow and the image will be cutted.
		 */
		public static const OUTSIDE						:String 							= "outside";
		
		/**
		 * The component will automatically have the size of the image, with proportions respected and computed with density.
		 */
		public static const AUTO_SIZE					:String 							= "autoSize";
		
		/**
		 * Use Scale 3 grid to show a fluid image with 3 horizontal slices.
		 */
		public static const HORIZONTAL_SCALE_3_RENDER	:String								= "horizontalScale3"
		
		/**
		 * Use Scale 3 grid to show a fluid image with 3 vertical slices.
		 */
		public static const VERTICAL_SCALE_3_RENDER		:String								= "verticalScale3";
		
		/**
		 * Use Scale 9 grid to show a fluid image with 9 slices.
		 */
		public static const SCALE_9_RENDER				:String								= "scale9";
		
		/**
		 * Use auto scaling mode. Will be converted to HORIZONTAL_SCALE_3_RENDER or VERTICAL_SCALE_3_RENDER or SCALE_9_RENDER immediatly after be applyed.
		 */
		public static const AUTO_SCALE_RENDER			:String								= "autoScale";
	}
}