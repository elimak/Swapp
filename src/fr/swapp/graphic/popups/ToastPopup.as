package fr.swapp.graphic.components.containers.popups
{
	import com.greensock.easing.Strong;
	import com.greensock.TweenMax;
	import flash.text.AntiAliasType;
	import flash.text.TextFormatAlign;
	import fr.swapp.graphic.components.bitmaps.AdvancedBitmap;
	import fr.swapp.graphic.components.controls.text.Label;
	import fr.swapp.graphic.components.controls.text.TextSkin;
	/**
	 * @author ZoulouX
	 */
	public class ToastPopup extends APopup
	{
		protected static var __textSkin:TextSkin = new TextSkin( {
			font: "Arial",
			color: 0xFFFFFF,
			size: 13,
			align: TextFormatAlign.CENTER
		}, null, true, AntiAliasType.ADVANCED);
		
		protected var _background					:AdvancedBitmap;
		
		protected var _label						:Label;
		
		
		public function ToastPopup ()
		{
			
		}
		
		override public function init ():void
		{
			resizableComponent.size(200, 50).center(0, 0);
			
			_background = new AdvancedBitmap(null, null, 1, 0);
			_background.alpha = .6;
			_background.radius(10);
			_background.place(0, 0, 0, 0).into(resizableComponent);
			
			_background.cab(true, _background.transform.concatenatedMatrix.clone());
			
			_label = new Label(true, true);
			_label.place(NaN, 10, NaN, 10).center(NaN, 0).into(resizableComponent);
		}
		
		override public function turnOn (pContextInfo:Object = null):void
		{
			dispatchEngineSignal(_onTurningOn);
			
			_label.text(pContextInfo.message as String);
			
			if ("textSkin" in pContextInfo)
				_label.textSkin(pContextInfo.textSkin as TextSkin)
			else
				_label.textSkin(__textSkin);
			
			if ("verticalOffset" in pContextInfo)
				resizableComponent.verticalOffset = pContextInfo.verticalOffset;
			
			const scale:Number = .5;
			
			TweenMax.from(resizableComponent, .5, {
				ease: Strong.easeOut,
				scaleX: scale,
				scaleY: scale,
				horizontalOffset: resizableComponent.horizontalOffset + (resizableComponent.width - resizableComponent.width * scale) / 2,
				verticalOffset: resizableComponent.verticalOffset + (resizableComponent.height - resizableComponent.height * scale) / 2,
				alpha: 0,
				onComplete: dispatchEngineSignal,
				onCompleteParams: [_onTurnedOn]
			});
			
			TweenMax.delayedCall("duration" in pContextInfo ? pContextInfo.duration : 3.2, turnOff);
		}
		
		override public function turnOff (pContextInfo:Object = null):void
		{
			dispatchEngineSignal(_onTurningOff);
			
			const scale:Number = 1.5;
			
			TweenMax.to(resizableComponent, .5, {
				ease: Strong.easeIn,
				scaleX: scale,
				scaleY: scale,
				horizontalOffset: resizableComponent.horizontalOffset + (resizableComponent.width - resizableComponent.width * scale) / 2,
				verticalOffset: resizableComponent.verticalOffset + (resizableComponent.height - resizableComponent.height * scale) / 2,
				alpha: 0,
				onComplete: dispatchEngineSignal,
				onCompleteParams: [_onTurnedOff]
			});
		}
	}
}