package fr.swapptesting.recordapp
{
	import flash.events.MouseEvent;
	import fr.swapp.core.entries.Document;
	import fr.swapp.graphic.base.StageWrapper;
	import fr.swapp.graphic.components.bitmaps.AdvancedBitmap;
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
		
		
		public function RecordAppDocument ()
		{
			
		}
		
		override public function init ():void
		{
			super.init();
			
			_wrapper = new StageWrapper(stage);
			
			_encoder = new WaveEncoder(0.5);
			
			_recorder = new MicRecorder(_encoder);
			
			stage.addEventListener(MouseEvent.CLICK, clickHandler);
			
			_background = new AdvancedBitmap();
			_background.background(0xFF0000);
			_background.place(10, 10, 10, 10).into(_wrapper);
			_background.visible = false;
		}
		
		protected function clickHandler (event:MouseEvent):void
		{
			_recording = !_recording;
			
			_background.visible = true;
			
			if (_recording)
			{
				_background.background(0xFF0000);
				
				if (_channel != null)
				{
					_channel.stop();
				}
				
				_recorder.record();
			}
			else
			{
				_background.background(0xCCCCCC);
				
				_recorder.stop();
				
				_player = new WavSound(_recorder.output);
				_channel = _player.play();
			}
		}
	}
}