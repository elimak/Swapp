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
	}
}