package fr.swapp.touch.delegate
{
	import flash.display.DisplayObject;
	/**
	 * @author ZoulouX
	 */
	public interface ITouchDoubleTapDelegate
	{
		/**
		 * Un double tap est effectué sur la cible
		 * @param	pTarget : La cible
		 * @param	pTimeOffset : Le nombre de ms entre le premier et le second tap
		 */
		function touchDoubleTapHandler (pTarget:DisplayObject, pTimeOffset:int):void;
		
		/**
		 * Un tap simple est effectué sur la cible (si double tap non détécté
		 * @param	pTarget : La cible
		 */
		function touchSingleTapHandler (pTarget:DisplayObject):void;
	}
}