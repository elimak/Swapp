package fr.swapp.touch.delegate 
{
	import flash.display.DisplayObject;
	
	/**
	 * @author ZoulouX
	 */
	public interface ITouchTapDelegate extends ITouchDelegate
	{
		/**
		 * Un tap est effectué sur la cible (peut être déclanché avec un double tap)
		 * @param	pTarget : La cible
		 * @param	pIsPrimary : Si on est sur le touch principal
		 */
		function touchTapHandler (pTarget:DisplayObject, pIsPrimary:Boolean):void;
		
		/**
		 * Un touch est sur le target
		 */
		function touchPressHandler (pTarget:DisplayObject):void;
		
		/**
		 * Plus aucun touch n'est sur le target
		 */
		function touchReleaseHandler (pTarget:DisplayObject):void;
		
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