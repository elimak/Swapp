package fr.swapp.graphic.animation
{
	import flash.events.Event;
	import fr.swapp.graphic.atlas.SAtlasItem;
	import fr.swapp.graphic.base.SGraphic;
	import fr.swapp.graphic.base.SRenderMode;
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	
	/**
	 * @author ZoulouX
	 */
	public class SAtlasAnimation extends SGraphic
	{
		/**
		 * The atlas sequence.
		 * Can be automatically extracted from SAtlas
		 */
		protected var _atlasSequence			:Vector.<SAtlasItem>;
		
		/**
		 * Number of frames by second for the animation. Please set a value which can devide the stage FPS.
		 * Ex, if the stage FPS is 60fps, you can set : 60, 30, 20, 15, 10...
		 * Default is 30.
		 */
		protected var _framesPerSeconds			:uint							= 30;
		
		/**
		 * Loop animation
		 */
		protected var _loop						:Boolean						= true;
		
		/**
		 * Direction multiplier (1 to go forward, -1 to go backward, 2 to go fastward)
		 */
		protected var _directionMultiplier		:int							= 1;
		
		/**
		 * Current animation frame (from 0).
		 * If a requested frame is not available (> totalFrames), the currentFrame will loop with modulo.
		 */
		protected var _currentFrame				:uint							= 0;
		
		/**
		 * Current counter for stage frame to animation frame conversion
		 */
		protected var _currentStageFrame		:uint							= 0;
		
		/**
		 * If the animation is playing
		 */
		protected var _playing					:Boolean						= false;
		
		/**
		 * Destination frame. Animation will stop when reached.
		 * -1 to disable this feature.
		 */
		protected var _destinationFrame			:int							= -1;
		
		/**
		 * When animation is stopped
		 */
		protected var _onStopped				:Signal							= new Signal(SAtlasAnimation);
		
		
		/**
		 * The atlas sequence.
		 * Can be automatically extracted from SAtlas
		 */
		public function get atlasSequence ():Vector.<SAtlasItem> { return _atlasSequence; }
		public function set atlasSequence (value:Vector.<SAtlasItem>):void
		{
			// Enregistrer l'atlas sans vérifier les modifications
			_atlasSequence = value;
		}
		
		/**
		 * Number of frames by second for the animation. Please set a value which can devide the stage FPS.
		 * Ex, if the stage FPS is 60fps, you can set : 60, 30, 20, 15, 10...
		 * Default is 30.
		 */
		public function get framesPerSeconds ():uint { return _framesPerSeconds; }
		public function set framesPerSeconds (value:uint):void
		{
			// Si la valeur est différente
			if (_framesPerSeconds != value)
			{
				// Enregistrer la valeur
				_framesPerSeconds = value;
			}
		}
		
		/**
		 * Direction multiplier (1 to go forward, -1 to go backward, 2 to go fastward)
		 */
		public function get directionMultiplier ():int { return _directionMultiplier; }
		public function set directionMultiplier (value:int):void
		{
			// Si la valeur est différente
			if (_directionMultiplier != value)
			{
				// Enregistrer la valeur
				_directionMultiplier = value;
			}
		}
		
		/**
		 * Current animation frame (from 0).
		 * If a requested frame is not available (> totalFrames), the currentFrame will loop with modulo.
		 */
		public function get currentFrame ():uint { return _currentFrame; }
		public function set currentFrame (value:uint):void
		{
			// Si la valeur est différente
			if (_currentFrame != value)
			{
				// Enregistrer la frame avec le modulo
				_currentFrame = value % _atlasSequence.length;
				
				// Actualiser l'atlas
				updateAnimationAtlas();
			}
		}
		
		/**
		 * Number of frames available
		 */
		public function get totalFrames ():uint { return _atlasSequence == null ? 0 : _atlasSequence.length; }
		
		/**
		 * Loop animation
		 */
		public function get loop ():Boolean { return _loop; }
		public function set loop (value:Boolean):void
		{
			_loop = value;
		}
		
		/**
		 * If the animation is playing
		 */
		public function get playing ():Boolean { return _playing; }
		
		/**
		 * Destination frame. Animation will stop when reached.
		 * -1 to disable this feature.
		 */
		public function get destinationFrame ():int { return _destinationFrame; }
		public function set destinationFrame (value:int):void
		{
			_destinationFrame = value;
		}
		
		/**
		 * When animation is stopped
		 */
		public function get onStopped ():ISignal { return _onStopped; }
		
		
		/**
		 * Constructor
		 * @param	pAtlasSequence : The atlas sequence. Can be automatically extracted from SAtlas.
		 * @param	pRenderMode : The renderMode, please see SGraphic.atlas method documentation for accepted values
		 * @param	pFramesPerSecondes : Number of frames by second for the animation. Please set a value which can devide the stage FPS. Ex, if the stage FPS is 60fps, you can set : 60, 30, 20, 15, 10... Default is 30.
		 */
		public function SAtlasAnimation (pAtlasSequence:Vector.<SAtlasItem> = null, pRenderMode:String = "stretch", pFramesPerSecondes:uint = 30)
		{
			// Si on a une sequence atlas
			if (pAtlasSequence != null)
			{
				// On l'applique
				sequence(pAtlasSequence, pRenderMode, pFramesPerSecondes);
			}
		}
		
		/**
		 * Set the atals sequence.
		 * @param	pAtlasSequence : The atlas sequence. Can be automatically extracted from SAtlas.
		 * @param	pRenderMode : The renderMode, please see SGraphic.atlas method documentation for accepted values
		 * @param	pFramesPerSecondes : Number of frames by second for the animation. Please set a value which can devide the stage FPS. Ex, if the stage FPS is 60fps, you can set : 60, 30, 20, 15, 10... Default is 30.
		 */
		public function sequence (pAtlasSequence:Vector.<SAtlasItem>, pRenderMode:String = "stretch", pFramesPerSecondes:uint = 30):void
		{
			// Enregistrer le renderMode
			_renderMode = pRenderMode;
			
			// Enregistrer l'atlas
			_atlasSequence = pAtlasSequence;
			
			// Enregistrer les images par seconde
			_framesPerSeconds = pFramesPerSecondes;
			
			// Appliquer le premier atlas
			updateAnimationAtlas();
		}
		
		
		/**
		 * Start the animation timer
		 */
		protected function startTimer ():void
		{
			// Si on est pas en cours de lecture
			if (!_playing)
			{
				// On est en lecture
				_playing = true;
				
				// Remettre le compteur de frame stage à 0
				_currentStageFrame = 0;
				
				// Démarrer l'écoute des frames stage
				addEventListener(Event.ENTER_FRAME, atlasAnimationEnterFrameHandler);
			}
		}
		
		/**
		 * Stop the animation timer
		 */
		protected function stopTimer ():void
		{
			// Si on est en cours de lecture
			if (!_playing)
			{
				// On n'est plus en lecture
				_playing = false;
				
				// Arrêter l'écoute des frame stage
				removeEventListener(Event.ENTER_FRAME, atlasAnimationEnterFrameHandler);
			}
		}
		
		/**
		 * Every stage frame
		 */
		protected function atlasAnimationEnterFrameHandler (event:Event):void
		{
			// Si le stage est dispo
			if (stage != null)
			{
				// Incrémenter la frame
				_currentStageFrame ++;
				
				// Si on a passé assez de frame stage pour passer à la prochaine frame de l'atlas
				if (_currentStageFrame >= stage.frameRate / _framesPerSeconds)
				{
					// Remettre le compteur stage frame à 0
					_currentStageFrame = 0;
					
					// Si on va sur la frame de destination
					if (_currentFrame == _destinationFrame || _currentFrame == _destinationFrame + _directionMultiplier)
					{
						// S'arrêter sur cette frame
						_currentFrame = _destinationFrame;
						
						// Arrêter l'animation
						stop();
					}
					
					// Si on va dépasser le début
					else if (_currentFrame + _directionMultiplier < 0)
					{
						// Si on tourne en boucle
						if (_loop)
						{
							// On repart à la fin
							_currentFrame = _atlasSequence.length - 1 + _directionMultiplier;
						}
						else
						{
							// Rester sur la première frame
							_currentFrame = 0;
							
							// On s'arrête
							stop();
						}
					}
					
					// Si on va dépasser la fin
					else if (_currentFrame >= _atlasSequence.length)
					{
						// Si on tourne en boucle
						if (_loop)
						{
							// On repart à 0
							_currentFrame = 0;
						}
						else
						{
							// Rester sur la dernière frame
							_currentFrame = _atlasSequence.length - 1 + _directionMultiplier;
							
							// On s'arrête
							stop();
						}
					}
					
					// Si on est au milieu de la sequence
					else
					{
						// Incrémenter la frame
						_currentFrame += _directionMultiplier;
					}
					
					// Actualiser l'atlas
					updateAnimationAtlas();
				}
			}
		}
		
		/**
		 * Update current atlas for animation
		 */
		protected function updateAnimationAtlas ():void
		{
			// Si on a une séquence et que la frame demandée existe
			if (_atlasSequence != null && _currentFrame in _atlasSequence)
			{
				// Cibler l'atlas
				_atlasItem = _atlasSequence[_currentFrame];
				
				// Actualiser l'atlas
				updateAtlas("updateAnimationAtlas");
			}
		}
		
		
		/**
		 * Start the animation from the currentFrame
		 * @param	pDirection : Direction multiplier (1 to go forward, -1 to go backward, 2 to go fastward)
		 * @param	pFrame : Specific frame, if a requested frame is not available (> totalFrames), the currentFrame will loop with modulo.
		 * @return this
		 */
		public function play (pDirection:int = 1, pToFrame:int = -1):SAtlasAnimation
		{
			// Enregistrer la direction
			_directionMultiplier = pDirection;
			
			// Enregistrer la frame de destination
			_destinationFrame = pToFrame;
			
			// Démarrer le timer
			startTimer();
			
			// Retourner l'objet
			return this;
		}
		
		/**
		 * Stop the animation and stay to the currentFrame
		 * @return this
		 */
		public function stop ():SAtlasAnimation
		{
			// Arrêter le timer
			stopTimer();
			
			// Signaler le stop
			_onStopped.dispatch(this);
			
			// Retourner l'objet
			return this;
		}
		
		/**
		 * Go to a specific frame.
		 * @param	pFrame : Specific frame, if a requested frame is not available (> totalFrames), the currentFrame will loop with modulo.
		 * @return this
		 */
		public function goToFrame (pFrame:uint):SAtlasAnimation
		{
			// Appliquer la frame
			currentFrame = pFrame;
			
			// Retourner l'objet
			return this;
		}
		
		/**
		 * Destruction.
		 */
		override public function dispose ():void
		{
			// Arrêter le timer
			stop();
			
			// Supprimer les signaux
			_onStopped.removeAll();
			_onStopped = null;
			
			// Relayer
			super.dispose();
		}
	}
}