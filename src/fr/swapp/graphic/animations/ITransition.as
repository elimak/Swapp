package fr.swapp.graphic.animations
{
	import fr.swapp.graphic.components.base.ResizableComponent;
	
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
		 * Animation d'intro
		 * @param	pTarget
		 * @param	pContextInfo
		 * @param	pStartHandler
		 * @param	pStartHandlerParams
		 * @param	pEndHandler
		 * @param	pEndHandlerParams
		 */
		function playIn (pTarget:ResizableComponent, pContextInfo:Object = null, pStartHandler:Function = null, pStartHandlerParams:Array = null, pEndHandler:Function = null, pEndHandlerParams:Array = null):void;
		
		/**
		 * Animation de sortie
		 * @param	pTarget
		 * @param	pContextInfo
		 * @param	pStartHandler
		 * @param	pStartHandlerParams
		 * @param	pEndHandler
		 * @param	pEndHandlerParams
		 */
		function playOut (pTarget:ResizableComponent, pContextInfo:Object = null, pStartHandler:Function = null, pStartHandlerParams:Array = null, pEndHandler:Function = null, pEndHandlerParams:Array = null):void;
	}
}