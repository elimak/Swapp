package fr.swapp.graphic.animations
{
	import com.greensock.easing.Quad;
	import com.greensock.TweenMax;
	import fr.swapp.graphic.base.ResizableComponent;
	import fr.swapp.utils.TimerUtils;
	
	/**
	 * @author ZoulouX
	 */
	public class SlideTransition implements ITransition
	{
		/**
		 * La durée de l'animation (en secondes)
		 */
		protected var _duration						:Number;
		
		/**
		 * Utiliser un bitmap pour l'animation
		 */
		protected var _useBitmap					:Boolean				= true;
		
		/**
		 * Le easing
		 */
		protected var _ease							:Function;
		
		/**
		 * Le délais (en frames)
		 */
		protected var _delay						:uint;
		
		/**
		 * Les variables de placement
		 */
		protected var _offsetVar					:String;
		protected var _sizeVar						:String;
		
		
		/**
		 * La durée de l'animation (en secondes)
		 */
		public function get duration ():Number { return _duration; }
		public function set duration (value:Number):void
		{
			_duration = value;
		}
		
		/**
		 * Utiliser des bitmap pour les transition
		 */
		public function get useBitmap ():Boolean { return _useBitmap; }
		public function set useBitmap (value:Boolean):void
		{
			_useBitmap = value;
		}
		
		/**
		 * Le easing
		 */
		public function get ease ():Function { return _ease; }
		public function set ease (value:Function):void
		{
			_ease = value;
		}
		
		/**
		 * Le délais (en frames)
		 */
		public function get delay ():uint { return _delay; }
		public function set delay (value:uint):void
		{
			_delay = value;
		}
		
		
		/**
		 * Le constructeur
		 * @param	pVertical : Orientation
		 * @param	pEasing : Le easing (un default est utilisé si null)
		 * @param	pDuration : La durée de l'animation (en secondes)
		 * @param	pDelay : Le délais (en frames)
		 */
		public function SlideTransition (pVertical:Boolean = false, pEasing:Function = null, pDuration:Number = .3, pDelay:Number = 5)
		{
			_offsetVar = pVertical ? "verticalOffset" : "horizontalOffset";
			_sizeVar = pVertical ? "totalHeight" : "totalWidth";
			_ease = (pEasing == null ? Quad.easeInOut : pEasing);
			_duration = pDuration;
			_delay = pDelay;
		}
		
		
		/**
		 * Récupérer la durée en frames
		 */
		protected function getFramesDuration (pTarget:ResizableComponent, pContextInfo:Object = null):int
		{
			return int((pContextInfo.duration ? pContextInfo.duration : _duration) * (pTarget.stage == null ? 30 : pTarget.stage.frameRate) + .5);
		}
		
		
		/**
		 * Animation d'intro
		 */
		public function playIn (pTarget:ResizableComponent, pContextInfo:Object = null, pStartHandler:Function = null, pStartHandlerParams:Array = null, pEndHandler:Function = null, pEndHandlerParams:Array = null):void
		{
			// Si on n'a pas de direction pour l'animation
			if (pContextInfo.direction == 0)
			{
				// Pas d'animation
				pEndHandler.apply(null, pEndHandlerParams);
				return;
			}
			
			// Masquer le contenu
			pTarget.clipContent = true;
			
			// Si on doit déplacer en bitmap
			if ("useBitmap" in pContextInfo)
			{
				// Passer en bitmap
				if (pContextInfo.useBitmap)
					pTarget.flatten();
			}
			else if (_useBitmap)
			{
				// Passer en bitmap
				pTarget.flatten();
			}
			
			// Signaler que l'animation démarre
			if (pStartHandler != null)
				pStartHandler.apply(null, pStartHandlerParams);
			
			// Placer la vue hors champ
			if ("amplitude" in pContextInfo && pContextInfo.amplitude != -1)
				pTarget[_offsetVar] = pContextInfo.amplitude;
			else
				pTarget[_offsetVar] = pTarget[_sizeVar];
			
			// La direction
			pTarget[_offsetVar] *= (pContextInfo.direction ? pContextInfo.direction : 1);
			
			// Si on doit jouer sur l'alpha
			if ("useAlpha" in pContextInfo && pContextInfo.useAlpha)
				pTarget.alpha = 0;
			
			// Les variables de tween
			var tweenVars:Object = {
				ease: _ease,
				alpha: pTarget.alpha == 0 ? 1 : null,
				useFrames: true,
				onComplete: animationEndHandler,
				onCompleteParams: [true, pTarget, pEndHandler, pEndHandlerParams]
			};
			
			// Spécifier la destination
			tweenVars[_offsetVar] = 0;
			
			// Animer
			TweenMax.to(pTarget, getFramesDuration(pTarget, pContextInfo), tweenVars);
		}
		
		/**
		 * Animation de sortie
		 */
		public function playOut (pTarget:ResizableComponent, pContextInfo:Object = null, pStartHandler:Function = null, pStartHandlerParams:Array = null, pEndHandler:Function = null, pEndHandlerParams:Array = null):void
		{
			// Si on n'a pas de direction pour l'animation
			if (pContextInfo.direction == 0)
			{
				pEndHandler.apply(null, pEndHandlerParams);
				return;
			}
			
			// Récupérer le délais
			var delay:int = ("useIntroDelay" in pContextInfo && !pContextInfo.useIntroDelay) ? 0 : _delay;
			
			// Attendre une frame
			TimerUtils.wait(pTarget, delay, false, function ():void
			{
				// Masquer le contenu
				pTarget.clipContent = true;
				
				// Si on doit déplacer en bitmap
				if ("useBitmap" in pContextInfo)
				{
					// Passer en bitmap
					if (pContextInfo.useBitmap)
						pTarget.flatten();
				}
				else if (_useBitmap)
				{
					// Passer en bitmap
					pTarget.flatten();
				}
				
				// Signaler que l'animation démarre
				if (pStartHandler != null)
					pStartHandler.apply(null, pStartHandlerParams);
				
				// La destination
				var destination:Number;
				if ("amplitude" in pContextInfo && pContextInfo.amplitude != -1)
					destination = pContextInfo.amplitude;
				else
					destination = - pTarget[_sizeVar];
				
				// La direction
				destination *= (pContextInfo.direction ? pContextInfo.direction : 1);
				
				// Les variables de tween
				var tweenVars:Object = {
					ease: _ease,
					alpha: "useAlpha" in pContextInfo && pContextInfo.useAlpha ? 0 : null,
					useFrames: true,
					onComplete: animationEndHandler,
					onCompleteParams: [false, pTarget, pEndHandler, pEndHandlerParams]
				};
				
				// Spécifier la destination
				tweenVars[_offsetVar] = destination;
				
				// Animer
				TweenMax.to(pTarget, getFramesDuration(pTarget, pContextInfo), tweenVars);
			});
		}
		
		/**
		 * Fin d'une animation
		 */
		protected function animationEndHandler (pPlayIn:Boolean, pTarget:ResizableComponent, pEndHandler:Function, pEndHandlerParams:Array):void
		{
			// On vire le masque si on est en playIn
			if (pPlayIn)
				pTarget.clipContent = false;
			
			// Si on était en bitmap
			if (pTarget.cacheAsBitmap && pPlayIn)
			{
				// On vire le bitmap
				pTarget.unflatten();
			}
			
			// Attendre pour appeler le handler
			TimerUtils.wait(pTarget, _delay, true, pEndHandler, pEndHandlerParams);
		}
	}
}