package fr.swapp.touch.delegate 
{
	import flash.display.DisplayObject;
	import flash.geom.Point;
	
	/**
	 * @author ZoulouX
	 */
	public interface ITouchDragDelegate extends ITouchDelegate
	{
		/**
		 * Le déplacement est vérouillé (au moins un point est appuyé sur la cible mais le point n'a pas forcément bougé)
		 * @param	pTarget : La cible
		 */
		function touchDragLock (pTarget:DisplayObject):void;
		
		/**
		 * Le déplacement est dévérouillé (plus aucun point ne bloque la cible)
		 * @param	pTarget : La cible
		 */
		function touchDragUnlock (pTarget:DisplayObject):void;
		
		/**
		 * Le ou les points vérouillant le déplacement sont en mouvement. Les données renvoyées sont une moyenne.
		 * @param	pTarget : La cible
		 * @param	pDirection : La direction du drag (calculé au premier déplacement donc ne changera pas dans cette session de déplacement). Voir les statiques de TouchEmulator.
		 * @param	pXDelta : La différence de position horizontale depuis le dernier appel
		 * @param	pYDelta : La différence de position horizontale depuis le dernier appel
		 * @param	pPoints : La liste des points en fonction pour le déplacement
		 * @return : L'autorisation aux parents de recevoir des touchDragging
		 */
		function touchDragging (pTarget:DisplayObject, pDirection:String, pXDelta:Number, pYDelta:Number, pPoints:Vector.<Point>):Boolean;
	}
}