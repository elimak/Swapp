package fr.swapp.utils
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	
	/**
	 * @author ZoulouX
	 */
	public class EmbedUtils
	{
		/**
		 * Get bitmapData from embedded bitmap class
		 */
		public static function getBitmapData (pEmbeddedClass:Class):BitmapData
		{
			return (new pEmbeddedClass as Bitmap).bitmapData;
		}
		
		/**
		 * Get XML from embedded XML class
		 */
		public static function getXML (pEmbeddedClass:Class):XML
		{
			// Créer le byteArray depuis la class embed
			var ba:ByteArray = (new pEmbeddedClass as ByteArray);
			
			// Retourner l'XML
			return new XML(ba.readUTFBytes(ba.length));
		}
		
		/**
		 * Get JSON from embedded class
		 */
		public static function getJSON (pEmbeddedClass):Object
		{
			// Créer le byteArray depuis la class embed
			var ba:ByteArray = (new pEmbeddedClass as ByteArray);
			
			// Retourner l'XML
			return JSON.parse(ba.readUTFBytes(ba.length));
		}
	}
}