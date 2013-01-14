package fr.swapp.graphic.animations
{
	import fr.swapp.graphic.base.ResizableComponent;
	
	/**
	 * @author ZoulouX
	 */
	public interface ITransition
	{
		/**
		 * La durée de l'animation (en secondes)
		 */
		function get duration ():Number;
		function set duration (value:Number):void;
		
		/**
		 * Animation d'intro.
		 * @param	pTarget : La cible qui va subir l'animation
		 * @param	pContextInfo : Les infos sur le context de l'animation (peut provenir d'une action)
		 * @param	pStartHandler : Appelé au démarrage de l'animation
		 * @param	pStartHandlerParams : Les paramètres du handler de démarrage
		 * @param	pEndHandler : Appelé à la fin de l'animation
		 * @param	pEndHandlerParams : Les paramètres du handler d'arrêt
		 */
		function playIn (pTarget:ResizableComponent, pContextInfo:Object = null, pStartHandler:Function = null, pStartHandlerParams:Array = null, pEndHandler:Function = null, pEndHandlerParams:Array = null):void;
		
		/**
		 * Animation de sortie.
		 * @param	pTarget : La cible qui va subir l'animation
		 * @param	pContextInfo : Les infos sur le context de l'animation (peut provenir d'une action)
		 * @param	pStartHandler : Appelé au démarrage de l'animation
		 * @param	pStartHandlerParams : Les paramètres du handler de démarrage
		 * @param	pEndHandler : Appelé à la fin de l'animation
		 * @param	pEndHandlerParams : Les paramètres du handler d'arrêt
		 */
		function playOut (pTarget:ResizableComponent, pContextInfo:Object = null, pStartHandler:Function = null, pStartHandlerParams:Array = null, pEndHandler:Function = null, pEndHandlerParams:Array = null):void;
	}
}