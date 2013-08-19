package fr.swapp.graphic.transition
{
	import fr.swapp.graphic.base.SComponent;
	
	/**
	 * @author ZoulouX
	 */
	public interface ITransition
	{
		/**
		 * Animation duration in seconds
		 */
		function get duration ():Number;
		function set duration (value:Number):void;
		
		/**
		 * Intro animation for any component
		 * @param	pTarget : The component to animate
		 * @param	pContextInfo : Additionnal context information depending of the transition
		 * @param	pStartHandler : When the animation starts
		 * @param	pStartHandlerParams : Params array for pStartHandler
		 * @param	pEndHandler : When the animation stops
		 * @param	pEndHandlerParams : Params array for pEndHandler
		 */
		function playIn (pTarget:SComponent, pContextInfo:Object = null, pStartHandler:Function = null, pStartHandlerParams:Array = null, pEndHandler:Function = null, pEndHandlerParams:Array = null):void;
		
		/**
		 * Outro animation for any component
		 * @param	pTarget : The component to animate
		 * @param	pContextInfo : Additionnal context information depending of the transition
		 * @param	pStartHandler : When the animation starts
		 * @param	pStartHandlerParams : Params array for pStartHandler
		 * @param	pEndHandler : When the animation stops
		 * @param	pEndHandlerParams : Params array for pEndHandler
		 */
		function playOut (pTarget:SComponent, pContextInfo:Object = null, pStartHandler:Function = null, pStartHandlerParams:Array = null, pEndHandler:Function = null, pEndHandlerParams:Array = null):void;
	}
}