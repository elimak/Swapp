package fr.swapp.graphic.tools 
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import fr.swapp.graphic.errors.GraphicalError;
	
	/**
	 * ...
	 * @author ZoulouX
	 */
	public class BitmapSlicer 
	{
		/**
		 * Découper un bitmap en plusieurs petits bitmaps.
		 * @param	pBitmapData : L'image source qui va être découpée
		 * @param	pWidth : La largeur des éléments à découper
		 * @param	pHeight : La hauteur des éléments à découper
		 * @return : Une liste à 2 dimensions des découpes de l'image source
		 */
		public static function sliceBitmap (pBitmapData:BitmapData, pWidth:uint, pHeight:uint):Vector.<Vector.<BitmapData>>
		{
			// On vérifier si nos dimensions sont valides
			if (pWidth == 0 || pHeight == 0)
			{
				// On déclanche une erreur
				throw new GraphicalError("BitmapSlicer.sliceBitmap", "pWidth and pHeight must be > to 0");
				return;
			}
			
			// On récupère les dimensions de l'image
			const totalWidth:uint = pBitmapData.width;
			const totalHeight:uint = pBitmapData.height;
			const isTransparent:Boolean = pBitmapData.transparent;
			
			// On récupère le nombre d'éléments
			const totalHorizontalElements:uint = totalWidth / pWidth;
			const totalVerticalElements:uint = totalHeight / pHeight;
			
			// Nos itérateurs
			var i:uint;
			var j:uint;
			
			// Les coupes horizontale en cours
			var currentSlices:Vector.<BitmapData>;
			
			// La coupe en cours
			var currentBitmapData:BitmapData;
			
			// La zone de découpage
			var spriteZone:Rectangle = new Rectangle(0, 0, pWidth, pHeight);
			
			// Le point de destination pour la copie
			const destinationPoint:Point = new Point();
			
			// Les coupes (qui seront retournées)
			const slices:Vector.<Vector.<BitmapData>> = new <Vector.<BitmapData>>[];
			
			// Parcourir les coupes horizontales
			for (i = 0; i < totalHorizontalElements; i ++)
			{
				// Les coupes horizontales en cours
				currentSlices = new <BitmapData>[];
				
				// L'ajouter au total des coupes
				slices[i] = currentSlices;
				
				// Parcourir les coupes verticales
				for (j = 0; j < totalVerticalElements; j ++)
				{
					// Créer le bitmap de la coupe
					currentBitmapData = new BitmapData(pWidth, pHeight, isTransparent, 0);
					
					// Placer le rectangle de l'origine de la coupe
					spriteZone.x = i * pWidth;
					spriteZone.y = j * pHeight;
					
					// Copier les pixels du bitmap d'origine vers la coupe
					currentBitmapData.copyPixels(pBitmapData, spriteZone, destinationPoint);
					
					// Ajouter la coupe à la liste des coupes horizontales
					currentSlices[j] = currentBitmapData;
				}
			}
			
			// Retourner les coupes
			return slices;
		}
	}
}