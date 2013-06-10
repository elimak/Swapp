package fr.swapp.touch.delegate 
{
	import flash.display.DisplayObject;
	import flash.geom.Matrix;
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
		function touchTransformStartHandler (pTarget:DisplayObject):DisplayObject;
		
		/**
		 * La transformation s'arrête (il à a moins de 2 points sur la cible)
		 * @param	pTarget : La cible
		 * @return : Le target à prendre en compte (le target sera gardé si null est retourné)
		 */
		function touchTransformStopHandler (pTarget:DisplayObject):void;
		
		/**
		 * Définir le type de touchTransform à prendre en compte
		 * @return
		 */
		function touchTransformMatrixType (pTarget:DisplayObject):uint;
		
		/**
		 * Une transformation est opérée (par 2 points ou plus).
		 * Les différents paramètres de transformations différentiels seront utilisés.
		 * @param	pTarget : La cible
		 * @param	pScaleDelta : La différence de scale depuis le dernier appel
		 * @param	pRotationDelta : La différence de rotation depuis le dernier appel
		 * @param	pXDelta : La différence de position horizontale depuis le dernier appel
		 * @param	pYDelta : La différence de position horizontale depuis le dernier appel
		 * @param	pPoints : Le nombre de points utilisés
		 * @return : Bloquer la propagation par les transformations parentes
		 */
		function touchTransformHandler (pTarget:DisplayObject, pScaleDelta:Number, pRotationDelta:Number, pXDelta:Number, pYDelta:Number, pPoints:uint):Boolean;
		
		/**
		 * Une transformation est opérée (par 2 points ou plus).
		 * Une matrice de transformation différentielle sera utilisée.
		 * @param	pTarget : La cible
		 * @param	pTransformationMatrix : La matrice de transformation depuis le dernier appel
		 * @param	pPoints : Le nombre de points utilisés
		 * @return : Bloquer la propagation par les transformations parentes
		 */
		function touchMatrixTransformHandler (pTarget:DisplayObject, pTransformationMatrix:Matrix, pPoints:uint):Boolean
	}
}