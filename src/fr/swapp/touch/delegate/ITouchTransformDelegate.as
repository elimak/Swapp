package fr.swapp.touch.delegate 
{
	import flash.display.DisplayObject;
	import flash.geom.Point;
	
	/**
	 * @author ZoulouX
	 */
	public interface ITouchTransformDelegate extends ITouchDelegate
	{
		/**
		 * Une transformation commence (il y a au moins 2 points sont sur la cible)
		 * @param	pTarget : La cible
		 */
		function touchTransformStartHandler (pTarget:DisplayObject):void;
		
		/**
		 * La transformation s'arrête (il à a moins de 2 points sur la cible)
		 * @param	pTarget : La cible
		 */
		function touchTransformStopHandler (pTarget:DisplayObject):void;
		
		/**
		 * Une transformation est opérée (par 2 points ou plus)
		 * @param	pTarget : La cible
		 * @param	pScaleDelta : La différence de scale depuis le dernier appel
		 * @param	pRotationDelta : La différence de rotation depuis le dernier appel
		 * @param	pXDelta : La différence de position horizontale depuis le dernier appel
		 * @param	pYDelta : La différence de position horizontale depuis le dernier appel
		 * @param	pPoints : La liste des points en fonction pour la transformation
		 * @return : L'autorisation aux parents de recevoir des touchDragging
		 */
		function touchTransformHandler (pTarget:DisplayObject, pScaleDelta:Number, pRotationDelta:Number, pXDelta:Number, pYDelta:Number, pPoints:Vector.<Point>):Boolean;
	}
}