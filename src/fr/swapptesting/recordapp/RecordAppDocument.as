package fr.swapptesting.recordapp
{
	import com.greensock.TweenMax;
	import flash.events.MouseEvent;
	import flash.media.Microphone;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.SharedObject;
	import fr.swapp.core.entries.Document;
	import fr.swapp.graphic.base.ResizableComponent;
	import fr.swapp.graphic.base.StageWrapper;
	import fr.swapp.graphic.components.bitmaps.AdvancedBitmap;
	import fr.swapp.utils.DisplayObjectUtils;
	import org.as3wavsound.sazameki.core.AudioSetting;
	import org.as3wavsound.WavSound;
	import org.as3wavsound.WavSoundChannel;
	import org.bytearray.micrecorder.encoder.WaveEncoder;
	import org.bytearray.micrecorder.MicRecorder;
	
	/**
	 * @author ZoulouX
	 */
	public class RecordAppDocument extends Document
	{
		protected var _wrapper:StageWrapper;
		protected var _encoder:WaveEncoder;
		protected var _recording:Boolean;
		protected var _recorder:MicRecorder;
		protected var _player:WavSound;
		protected var _channel:WavSoundChannel;
		protected var _background:AdvancedBitmap;
		protected var _soundButton:SoundButton;
		protected var _sharedObject:SharedObject;
		protected var _titleBar:ResizableComponent;
		protected var _buttons:Vector.<SoundButton>;
		protected var _changeModeButton:ResizableComponent;
		
		
		public function RecordAppDocument ()
		{
			
		}
		
		override public function init ():void
		{
			_encoder = new WaveEncoder(1);
			
			var mic:Microphone
			
			if (Microphone.names.length > 1)
				mic = Microphone.getMicrophone(1);
			else
				mic = Microphone.getMicrophone();
			
			mic.rate = 22;
			mic.setSilenceLevel(0, 0);
			mic.setUseEchoSuppression(false);
			
			_recorder = new MicRecorder(_encoder, mic, 100, 22, 0, 4000);
			_sharedObject = SharedObject.getLocal("records");
			
			setupUI();
		}
		
		protected function setupUI ():void
		{
			setupWrapper();
			createTitleBar();
			createButtons();
		}
		
		protected function setupWrapper ():void
		{
			// Créer le wrapper
			_wrapper = new StageWrapper(stage);
			
			// Le style de l'application
			_wrapper.styleCentral.styleData = {
				"StageWrapper" : {
					backgroundImage: {
						background: [0x333333]
					}
				},
				
				".titleBar" : {
					place: [0, 0, NaN, 0],
					size: [0, 44],
					backgroundImage: {
						background: [0x000000, 0.2]
					}
				},
				".titleBar .changeModeButton" : {
					place: [8, 8, 9, NaN],
					size: [100, NaN],
					backgroundImage: {
						background: [0xCCCCCC]
					}
				},
				
				"SoundButton" : {
					size: [160, 120]
				},
				"SoundButton .playButton" : {
					backgroundImage: {
						background: [0xCCCCCC],
						allRadius: [5]
					}
				},
				"SoundButton .recordContainer" : {
					backgroundImage: {
						background: [0x0000FF],
						allRadius: [5]
					}
				},
				"SoundButton .name" : {
					font: "HelveticaNeue",
					embedFont: false
				},
				"SoundButton .nameLine" : {
					background: [0xFFFFFF]
				}
			};
		}
		
		/**
		 * Créer la barre de titre
		 */
		protected function createTitleBar ():void
		{
			// Créer la barre de titre
			_titleBar = new ResizableComponent();
			_titleBar.style("titleBar").into(_wrapper);
			
			// Créer le bouton de changement de mode
			_changeModeButton = new ResizableComponent();
			_changeModeButton.style("changeModeButton").into(_titleBar);
			_changeModeButton.addEventListener(MouseEvent.CLICK, changeModeClickHandler);
		}
		
		/**
		 * Créer les boutons
		 */
		protected function createButtons ():void
		{
			// La liste des boutons
			_buttons = new Vector.<SoundButton>;
			
			// Le bouton et son index
			var button:SoundButton;
			var index:int;
			
			const totalColumns:int = 4;
			const totalRows:int = 4;
			
			var i:int;
			var j:int;
			
			var horizontalMargin:int = - 100;
			var verticalMargin:int = - 100;
			
			var columnWidth:int = (stage.stageWidth - horizontalMargin) / (totalColumns + 1);
			var columnHeight:int = (stage.stageHeight - verticalMargin - _titleBar.height) / (totalRows + 1);
			
			// Colonnes
			for (i = 0; i < totalColumns; i++) 
			{
				// Lignes
				for (j = 0; j < totalRows; j++) 
				{
					// Créer le bouton
					button = new SoundButton(index ++, _recorder, _sharedObject);
					
					// Le placer
					button.horizontalOffset = columnWidth * (i + 1) + horizontalMargin / 2;
					button.verticalOffset = columnHeight * (j + 1) + _titleBar.height + verticalMargin / 2;
					
					// Ajouter à la scène
					button.into(_wrapper);
					
					// L'ajouter au tableau
					_buttons.push(button);
				}
			}
			
			// Centrer la perspective
			DisplayObjectUtils.quickProjection(_wrapper, stage.stageWidth / 2, stage.stageHeight / 2, 40);
		}
		
		/**
		 * Changer le mode (lecture / enregistrement)
		 */
		protected function changeModeClickHandler (event:MouseEvent):void 
		{
			var buttonMode:SoundButton;
			var i:int = _buttons.length;
			
			while (--i >= 0)
			{
				buttonMode = _buttons[i];
				
				//TweenMax.delayedCall(i * 0.05, buttonMode.toggleMode);
				TweenMax.delayedCall(Math.random() / 2, buttonMode.toggleMode);
			}
		}
	}
}