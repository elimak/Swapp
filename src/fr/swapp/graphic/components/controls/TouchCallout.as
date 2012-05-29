package fr.swapp.graphic.components.controls
{
	import com.greensock.TweenMax;
	import flash.events.MouseEvent;
	import fr.swapp.graphic.components.bitmaps.AdvancedBitmap;
	import org.osflash.signals.Signal;
	
	/**
	 * @author ZoulouX
	 */
	public class TouchCallout extends AdvancedBitmap
	{
		/**
		 * Lorsque ce callout est touché
		 */
		protected var _onTapped							:Signal 				= new Signal(TouchCallout);
		
		/**
		 * La durée d'affichage du callout
		 */
		protected var _duration							:Number;
		
		/**
		 * Si la disparition est animée
		 */
		protected var _animated							:Boolean;
		
		
		/**
		 * Lorsque ce callout est touché
		 */
		public function get onTapped ():Signal { return _onTapped; }
		
		/**
		 * La durée d'affichage du callout
		 */
		public function get duration ():Number { return _duration; }
		public function set duration (value:Number):void
		{
			_duration = value;
		}
		
		/**
		 * Si la disparition est animée
		 */
		public function get animated ():Boolean { return _animated; }
		public function set animated (value:Boolean):void
		{
			_animated = value;
		}
		
		
		/**
		 * Le constructeur
		 * @param	pColor : La couleur du callout (appliquée via background())
		 * @param	pAlpha : L'alpha du callout (appliqué via background())
		 * @param	pBorderRadius : Le border radius du callout (appliqué via radius)
		 * @param	pDuration : La durée d'affichage
		 * @param	pAnimated : Si la disparition est animée
		 */
		public function TouchCallout (pColor:uint = 0x888888, pAlpha:Number = .4, pBorderRadius:int = 5, pDuration:Number = .5, pAnimated:Boolean = true)
		{
			// Appliquer le fond
			background(pColor, pAlpha);
			
			// Le border radius
			radius(pBorderRadius);
			
			// La durée et l'animation
			_duration = pDuration;
			_animated = pAnimated;
			
			// Ecouter les clics sur ce callout
			addEventListener(MouseEvent.CLICK, mouseClickHandler);
			
			// Masquer
			alpha = 0;
			
			// Utiliser le curseur main
			useHandCursor = true;
			buttonMode = true;
		}
		
		/**
		 * Clic sur le callout
		 */
		protected function mouseClickHandler (event:MouseEvent):void 
		{
			// Afficher
			show();
			
			// Dispatcher
			_onTapped.dispatch(this);
		}
		
		/**
		 * Afficher
		 */
		public function show ():void
		{
			// Afficher
			alpha = 1;
			
			// Attendre
			TweenMax.killTweensOf(this);
			TweenMax.killDelayedCallsTo(hide);
			TweenMax.delayedCall(_duration, hide);
		}
		
		/**
		 * Masquer
		 */
		public function hide ():void
		{
			// Masquer avec ou sans animation
			TweenMax.to(this, _animated ? .5 : 0, {
				alpha: 0
			});
		}
		
		/**
		 * Destruction
		 */
		override public function dispose ():void
		{
			removeEventListener(MouseEvent.CLICK, mouseClickHandler);
			
			_onTapped.removeAll();
			_onTapped = null;
			
			super.dispose();
		}
	}
}