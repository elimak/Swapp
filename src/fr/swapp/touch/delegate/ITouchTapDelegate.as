package fr.swapp.touch.delegate 
{
	import flash.display.DisplayObject;
	/**
	 * @author ZoulouX
	 */
	public interface ITouchTapDelegate extends ITouchDelegate
	{
		/**
		 * Un tap simple est effectué sur la cible
		 * @param	pTarget : La cible
		 */
		function touchTapHandler (pTarget:DisplayObject):void
		
		/**
		 * Un double tap est effectué sur la cible
		 * @param	pTarget : La cible
		 * @param	pTimeOffset : Le nombre de ms entre le premier et le second tap
		 */
		function touchDoubleTapHandler (pTarget:DisplayObject, pTimeOffset:int):void
	}
}