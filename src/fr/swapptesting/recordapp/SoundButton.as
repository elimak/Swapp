package fr.swapptesting.recordapp
{
	import com.greensock.easing.Back;
	import com.greensock.easing.Quad;
	import com.greensock.easing.Strong;
	import com.greensock.TweenMax;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.media.Microphone;
	import flash.media.Sound;
	import flash.net.SharedObject;
	import flash.utils.ByteArray;
	import fr.swapp.graphic.base.ResizableComponent;
	import fr.swapp.graphic.components.bitmaps.AdvancedBitmap;
	import fr.swapp.graphic.components.text.Input;
	import fr.swapp.graphic.components.text.Label;
	import fr.swapp.utils.DisplayObjectUtils;
	import org.as3wavsound.sazameki.core.AudioSetting;
	import org.as3wavsound.WavSound;
	import org.as3wavsound.WavSoundChannel;
	import org.bytearray.micrecorder.MicRecorder;
	
	/**
	 * @author ZoulouX
	 */
	public class SoundButton extends ResizableComponent
	{
		/**
		 * L'enregistreur audio
		 */
		protected var _recorder						:MicRecorder;
		
		/**
		 * L'objet partagé pour enregistrer les données
		 */
		protected var _sharedObject					:SharedObject;
		
		/**
		 * Si on est en mode enregistrement
		 */
		protected var _recordMode					:Boolean;
		
		/**
		 * Le bouton de lecture
		 */
		protected var _playButton					:ResizableComponent;
		
		/**
		 * Le container d'enregistrement
		 */
		protected var _recordContainer				:ResizableComponent;
		
		/**
		 * Le label du nom
		 */
		protected var _nameLabel					:Input;
		
		/**
		 * Le trait sous le label
		 */
		protected var _nameLabelLine				:AdvancedBitmap;
		
		protected var _recording					:Boolean;
		
		protected var _player						:WavSound;
		
		protected var _channel						:WavSoundChannel;
		protected var _playing						:Boolean;
		protected var _audioSettings				:AudioSetting;
		
		
		/**
		 * Si on est en mode enregistrement
		 */
		public function get recordMode ():Boolean { return _recordMode; }
		public function set recordMode (value:Boolean):void 
		{
			// Si c'est différent
			if (_recordMode != value)
			{
				// Enregistrer
				_recordMode = value;
				
				// Actualiser
				updateMode();
			}
		}
		
		
		/**
		 * Le constructeur
		 * @param	pIndex : L'index du son
		 * @param	pRecorder : L'enregistreur audio
		 * @param	pAudioSettings : Les paramètres de lecture
		 * @param	pSharedObject : L'objet partagé pour enregistrer les données
		 */
		public function SoundButton (pIndex:int, pRecorder:MicRecorder, pAudioSettings:AudioSetting, pSharedObject:SharedObject)
		{
			// Activer les styles
			_styleEnabled = true;
			
			// Enregistrer l'index
			_index = pIndex;
			
			// Enregistrer le recorder,, les paramètres de lecture et le sharedObject
			_recorder = pRecorder;
			_sharedObject = pSharedObject;
			_audioSettings = pAudioSettings
			
			// Si ce bouton n'a pas de données
			if (!(pIndex in _sharedObject.data))
			{
				// On créé l'entrée par défaut
				_sharedObject.data[pIndex] = {
					name: "Sound " + pIndex,
					data: null
				};
			}
			else if (_sharedObject.data[pIndex].data != null)
			{
				// Préparer le son avec les données qu'on a sauvegardé
				prepareSound(_sharedObject.data[pIndex].data);
			}
		}
		
		/**
		 * Changer de mode (lecture / enregistrement)
		 */
		public function toggleMode ():void
		{
			// Inverser le mode
			recordMode = !_recordMode;
		}
		
		override protected function styleInjected ():void 
		{
			// Configurer l'interface utilisateur
			setupUI();
			
			// Activer la boucle principale
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		/**
		 * Configurer l'interface utilisateur
		 */
		protected function setupUI ():void
		{
			// Le label
			_nameLabel = new Input(false);
			_nameLabel.style("name");
			_nameLabel.text(_sharedObject.data[index].name);
			_nameLabel.editable = false;
			_nameLabel.place(-25, 4, NaN, 3).size(NaN, 20).offset( -_localWidth / 2, -_localHeight / 2);
			_nameLabel.into(this);
			
			// Le trait sous le nom
			_nameLabelLine = new AdvancedBitmap();
			_nameLabelLine.style("nameLine");
			_nameLabelLine.place(-6, 4, NaN, 4).size(NaN, 1).offset( -_localWidth / 2, -_localHeight / 2);
			_nameLabelLine.into(this);
			
			// Le bouton de lecture
			_playButton = new ResizableComponent();
			_playButton.style("playButton");
			_playButton.size(_localWidth, _localHeight).into(this);
			_playButton.backgroundImage.offset( -_localWidth / 2, -_localHeight / 2);
			
			// Le container de la partie d'enregistrement
			_recordContainer = new ResizableComponent();
			_recordContainer.style("recordContainer");
			_recordContainer.size(_localWidth, _localHeight).into(this);
			_recordContainer.backgroundImage.offset( -_localWidth / 2, -_localHeight / 2);
			
			// Bouton d'enregistrement
			
			// Bouton de suppression
			
			// Slider de volume
			
			// Bouton de mode multiplay
			
			// Label de la durée du son
			
			
			// TEMP
			_playButton.addEventListener(MouseEvent.CLICK, clickHandler);
			_recordContainer.addEventListener(MouseEvent.CLICK, clickHandler);
			
			
			
			// Actualiser le mode une première fois
			updateMode(0);
			
			// Appeler la frame directement une première fois
			enterFrameHandler();
		}
		
		protected function enterFrameHandler (event:Event = null):void 
		{
			if (_recording)
			{
				_recordContainer.backgroundImage.backgroundColor = (_recorder.microphone.activityLevel / 100 * 0xFF) << 8 + 0xFFFF;
			}
			
			if (_playing && _channel != null)
			{
				trace(_channel.leftPeak, _channel.rightPeak, _channel.position);
				
				/*if (_channel.position == 0)
				{
					_playing = false;
					_channel = null;
				}*/
			}
			
			// La visibilité des zones selon le mode
			_playButton.visible = (_playButton.rotationX < -90);
			_recordContainer.visible = (_recordContainer.rotationX > 90);
		}
		
		protected function clickHandler (event:MouseEvent):void 
		{
			if (event.currentTarget == _recordContainer)
			{
				_recording ? stopRecording() : startRecording();
			}
			else if (event.currentTarget == _playButton)
			{
				/*TweenMax.fromTo(_playButton, .5, {
					glowFilter: {
						color: 0xFFFFFF,
						alpha: 1,
						blurX: 20,
						blurY: 20
					}
				}, {
					glowFilter: {
						color: 0xFFFFFF,
						alpha: 0,
						blurX: 2,
						blurY: 2,
						remove: true
					}
				});*/
				
				//startPlaying();
				
				//var sound:Sound = new Sound();
				//sound.loadPCMFromByteArray
			}
		}
		
		
		protected function prepareSound (pData:ByteArray):void
		{
			_player = new WavSound(pData, _audioSettings);
			
			_sharedObject.data[index].data = pData;
			
			//_sharedObject.flush();
			
			//pData.position = 0;
			//Sound.
			//var sound:Sound = new Sound()
			//sound.loadPCMFromByteArray(pData, pData.bytesAvailable / 8, "float", false, 22050);
			//sound.play();
		}
		
		protected function startPlaying ():void
		{
			trace("startPlaying");
			
			if (_player != null)
			{
				// Arrêter le son courrant
				if (_playing && _channel != null)
				{
					_channel.stop();
				}
				
				_playing = true;
				
				//_channel = _player.play(600);
				_channel = _player.play();
			}
		}
		
		protected function channelEndHandler (event:Event):void
		{
			trace("channelEndHandler");
			
			_playing = false;
			_channel = null;
		}
		
		protected function stopPlaying ():void
		{
			trace("stopPlaying");
			
			// Si on a un channel
			if (_channel != null)
			{
				// On le stoppe
				_channel.stop();
				
				// Et on le vire
				_channel = null;
			}
		}
		
		protected function startRecording ():void
		{
			// On est en enregistrement
			_recording = true;
			
			// On commence l'enregistrement
			_recorder.record();
			
			// Notifier l'enregistrement par le bouton
			/*TweenMax.to(_recordContainer, .5, {
				glowFilter: {
					color: 0xFF3333,
					alpha: 1,
					blurX: 20,
					blurY: 20
				}
			});*/
		}
		
		protected function stopRecording ():void
		{
			// On n'est plus en enregistrement
			_recording = false;
			
			// Arrêter l'enregistrement
			_recorder.stop();
			
			// Créer le player avec le son enregistré
			prepareSound(_recorder.output);
			
			// Remettre le bouton dans son état visuel normal
			_recordContainer.invalidateStyle();
			
			// Ne plus notifier l'enregistrement par le bouton
			/*TweenMax.to(_recordContainer, .5, {
				glowFilter: {
					color: 0xFF3333,
					alpha: 0,
					blurX: 0,
					blurY: 0,
					remove: true
				}
			});*/
		}
		
		/**
		 * Actualiser le mode
		 * @param	pDuration : Durée de l'animation
		 */
		protected function updateMode (pDuration:Number = .5):void
		{
			// Si on était en enregistrement et qu'on passe en mode lecture
			if (!_recordMode && _recording)
			{
				// On stoppe l'enregistrement
				stopRecording();
			}
			
			// Si on était en lecture et qu'on passe en mode enregistrement
			if (_recordMode && _playing)
			{
				// Stopper le son
				stopPlaying();
			}
			
			// Enregistrer le nom
			_sharedObject.data[index].name = _nameLabel.value;
			
			// Le label devient éditable en mode enregistrement
			_nameLabel.editable = _recordMode;
			
			// Animer la couleur du label
			TweenMax.to(_nameLabel, pDuration, {
				hexColors: {
					color: _recordMode ? 0xFFFFFF : 0xBBBBBB
				}
			});
			
			// Animer le trait sous le label
			TweenMax.to(_nameLabelLine, pDuration, {
				alpha: _recordMode ? 1 : 0
			});
			
			// Animer le côté lecture
			TweenMax.to(_playButton, pDuration, {
				rotationX: _recordMode ? 0 : -180,
				ease: Quad.easeInOut
			});
			
			// Animer le côté enregistrement
			TweenMax.to(_recordContainer, pDuration, {
				rotationX: _recordMode ? 180 : 0,
				ease: Quad.easeInOut
			});
		}
	}
}