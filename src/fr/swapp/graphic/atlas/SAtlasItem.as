package fr.swapp.graphic.atlas
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import fr.swapp.graphic.errors.GraphicalError;
	
	/**
	 * @author ZoulouX
	 */
	public class SAtlasItem
	{
		/**
		 * Texture name
		 */
		protected var _name					:String;
		
		/**
		 * X offset from the atlas
		 */
		protected var _x					:int;
		
		/**
		 * Y offset from the atlas
		 */
		protected var _y					:int;
		
		/**
		 * Texture width
		 */
		protected var _width				:int;
		
		/**
		 * Texture height
		 */
		protected var _height				:int;
		
		/**
		 * Associated Atlas to get this texture
		 */
		protected var _associatedAtlas		:SAtlas;
		
		
		/**
		 * Texture name
		 */
		public function get name ():String { return _name; }
		
		/**
		 * X offset from the atlas
		 */
		public function get x ():int { return _x; }
		
		/**
		 * Y offset from the atlas
		 */
		public function get y ():int { return _y; }
		
		/**
		 * Texture width
		 */
		public function get width ():int { return _width; }
		
		/**
		 * Texture height
		 */
		public function get height ():int { return _height; }
		
		/**
		 * Associated Atlas to get this texture
		 */
		public function get associatedAtlas ():SAtlas { return _associatedAtlas; }
		
		
		/**
		 * Constructor.
		 * Will parse data from Atlas XML
		 * @param	pData : XML node from the Atlas XML
		 * @param	pAtlas : Associated Atlas
		 */
		public function SAtlasItem (pData:XML, pAtlas:SAtlas)
		{
			// Vérifier les données
			if (pData == null || pAtlas == null)
			{
				// Lever une erreur
				throw new GraphicalError("SAtlasItem.construct", "Data and Atlas can't be null.");
			}
			else
			{
				// On parse les données qu'on nous a donné
				parse(pData, pAtlas);
			}
		}
		
		/**
		 * Parse data from Atlas XML
		 * @param	pData : XML node from the Atlas XML
		 * @param	pAtlas : Associated Atlas
		 */
		protected function parse (pData:XML, pAtlas:SAtlas):void
		{
			// TODO : Atlas frames from XML
			
			// Enregistrer l'atlas associé
			_associatedAtlas = pAtlas;
			
			// Récupérer les infos depuis l'XML
			_name 	= pData.@name.toString();
			_x 		= parseInt(pData.@x, 10);
			_y 		= parseInt(pData.@y, 10);
			_width 	= parseInt(pData.@width, 10);
			_height = parseInt(pData.@height, 10);
		}
		
		/**
		 * Get the slices bitmapData
		 */
		public function extractBitmapData ():BitmapData
		{
			// Créer le bitmapData de sortie aux bonnes dimensions
			var out:BitmapData = new BitmapData(_width, _height, _associatedAtlas.bitmapData.transparent, 0);
			
			// Copier les pixels depuis le sprite à la bonne position
			out.copyPixels(_associatedAtlas.bitmapData, new Rectangle(_x, _y, _width, _height), new Point());
			
			// Retourner l'image découpée
			return out;
		}
		
		/**
		 * String representation
		 */
		public function toString ():String
		{
			return "SAtlasItem {" + _name + ", " + _x + ", " + _y + ", " + _width + ", " + _height + "}";
		}
	}
}