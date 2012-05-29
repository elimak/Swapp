package fr.swapp.graphic.components.controls.title 
{
	import com.greensock.easing.Quad;
	import com.greensock.easing.Strong;
	import com.greensock.TweenMax;
	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import fr.swapp.graphic.animations.ITransition;
	import fr.swapp.graphic.components.base.ResizableComponent;
	import fr.swapp.utils.ObjectUtils;
	import org.osflash.signals.Signal;
	
	/**
	 * ...
	 * @author ZoulouX
	 */
	public class TitleBar extends ResizableComponent 
	{
		/**
		 * Lorsque le composant de gauche est utilisé
		 */
		protected var _onLeftTapped						:Signal						= new Signal()
		
		/**
		 * Lorsque le composant de droite est utilisé
		 */
		protected var _onRightTapped					:Signal						= new Signal()
		
		/**
		 * Lorsque le composant du centre est utilisé
		 */
		protected var _onCenterTapped					:Signal						= new Signal();
		
		
		/**
		 * Le composant de gauche
		 */
		protected var _leftComponent					:ResizableComponent;
		
		/**
		 * Le composant de droite
		 */
		protected var _rightComponent					:ResizableComponent;
		
		/**
		 * Le composant du centre
		 */
		protected var _centerComponent					:ResizableComponent;
		
		
		/**
		 * Le fond
		 */
		protected var _back								:ResizableComponent;
		
		
		/**
		 * L'amplitude de l'animation (le décallage du composant sur l'axe x)
		 */
		protected var _animationAmplitude				:int						= 50;
		
		
		/**
		 * Les handlers
		 */
		protected var _leftHandler						:Function;
		protected var _rightHandler						:Function;
		protected var _centerHandler					:Function;
		
		
		/**
		 * Les paddings
		 */
		protected var _topPadding						:int						= 6;
		protected var _rightPadding						:int						= 8;
		protected var _leftPadding						:int						= 8;
		
		
		/**
		 * Lorsque le composant de gauche est utilisé
		 */
		public function get onLeftTapped ():Signal { return _onLeftTapped; }
		
		/**
		 * Lorsque le composant de droite est utilisé
		 */
		public function get onRightTapped ():Signal { return _onRightTapped; }
		
		/**
		 * Lorsque le composant du centre est utilisé
		 */
		public function get onCenterTapped ():Signal { return _onCenterTapped; }
		
		/**
		 * Le composant de gauche
		 */
		public function get leftComponent ():ResizableComponent { return _leftComponent; }
		
		/**
		 * Le composant de droite
		 */
		public function get rightComponent ():ResizableComponent { return _rightComponent; }
		
		/**
		 * Le composant du centre
		 */
		public function get centerComponent ():ResizableComponent { return _centerComponent; }
		
		/**
		 * Le fond
		 */
		public function get back ():ResizableComponent { return _back; }
		
		/**
		 * L'amplitude de l'animation (le décallage du composant sur l'axe x)
		 */
		public function get animationAmplitude ():int { return _animationAmplitude; }
		public function set animationAmplitude (value:int):void 
		{
			_animationAmplitude = value;
		}
		
		/**
		 * Le padding du haut
		 */
		public function get topPadding ():int { return _topPadding; }
		public function set topPadding (value:int):void 
		{
			_topPadding = value;
		}
		
		/**
		 * Le padding de droite
		 */
		public function get rightPadding ():int { return _rightPadding; }
		public function set rightPadding (value:int):void 
		{
			_rightPadding = value;
		}
		
		/**
		 * Le padding de gauche
		 */
		public function get leftPadding ():int { return _leftPadding; }
		public function set leftPadding (value:int):void 
		{
			_leftPadding = value;
		}
		
		
		/**
		 * Le constructeur
		 */
		public function TitleBar ()
		{
			// Ecouter les clics
			addEventListener(MouseEvent.CLICK, clickHandler);
		}
		
		
		/**
		 * Définir le fond
		 */
		public function setBack (pComponent:ResizableComponent):void
		{
			// Enregistrer et placer le fond
			_back = pComponent.place(0, 0, 0, 0).into(this, "back", 0);
		}
		
		/**
		 * Masquer le composant en cours
		 * @param	pCurrentComponent : Le composant en cours
		 * @param	pNewComponent : Le nouveau composant (qui sera affiché après)
		 * @param	pTransition : La transition
		 * @param	pContextInfos : Le contexte de la transition
		 */
		protected function hideCurrentComponent (pCurrentComponent:ResizableComponent, pNewComponent:ResizableComponent, pTransition:ITransition = null, pContextInfos:Object = null):void
		{
			// Vérouiller les taps
			mouseEnabled = false;
			mouseChildren = false;
			
			// Si on a un composant actuel
			if (pCurrentComponent != null)
			{
				// Si on a une transition
				if (pTransition != null)
				{
					// On fait la transition en ajoutant l'amplitude au contexte et on détruit l'objet une fois l'animation terminée
					pTransition.playOut(pCurrentComponent, ObjectUtils.extra(ObjectUtils.extra( { }, pContextInfos), {
						amplitude: - _animationAmplitude,
						useAlpha: true,
						useBitmap: false,
						useIntroDelay: false
					}), null, null, deleteCurrentComponent, [pCurrentComponent]);
				}
				else
				{
					deleteCurrentComponent(pCurrentComponent);
				}
			}
			
			// Afficher directement le nouveau composant
			showNewComponent(pNewComponent, pTransition, pContextInfos);
		}
		
		/**
		 * Supprimer le composant actuel
		 * @param	pCurrentComponent
		 */
		protected function deleteCurrentComponent (pCurrentComponent:ResizableComponent):void
		{
			// Si on a un composant actuel
			if (pCurrentComponent != null)
			{
				// On le vire de la displayList
				removeChild(pCurrentComponent);
			}
		}
		
		/**
		 * Afficher le nouveau composant
		 * @param	pNewComponent : Le nouveau composant
		 * @param	pTransition : La transition
		 * @param	pContextInfos : Le contexte de la transition
		 */
		protected function showNewComponent (pNewComponent:ResizableComponent, pTransition:ITransition = null, pContextInfos:Object = null):void
		{
			// Si on a un nouveau composant
			if (pNewComponent != null)
			{
				// Afficher le composant
				pNewComponent.visible = true;
				
				// Si on a une transition
				if (pTransition != null)
				{
					// On fait la transition en ajoutant l'amplitude au contexte et on active l'interactivité à la fin
					pTransition.playIn(pNewComponent, ObjectUtils.extra(ObjectUtils.extra( { }, pContextInfos), {
						amplitude: _animationAmplitude,
						useAlpha: true,
						useBitmap: false,
						useIntroDelay: false
					}), null, null, enableInteractivity);
				}
				else
				{
					// Réactiver l'interactivité
					enableInteractivity();
				}
			}
			else
			{
				// Réactiver l'interactivité
				enableInteractivity();
			}
		}
		
		/**
		 * Réactiver l'interactivité
		 */
		protected function enableInteractivity ():void
		{
			mouseEnabled = true;
			mouseChildren = true;
		}
		
		/**
		 * Définir le composant de gauche. L'ancien sera supprimé.
		 * @param	pComponent : Le composant à afficher (null pour virer le composant actuel)
		 * @param	pHandler : Le handler à l'utilisation du composant
		 * @param	pTransition : La transition
		 * @param	pContextInfos : Le contexte de la transition
		 */
		public function setLeftComponent (pComponent:ResizableComponent, pTransition:ITransition = null, pContextInfos:Object = null, pHandler:Function = null):void
		{
			// Récupérer le composant actuel
			const currentComponent:ResizableComponent = _leftComponent;
			
			// Enregistrer le nouveau composant
			_leftComponent = pComponent;
			
			// Effacer le handler si le nouveau composant est null
			if (pComponent == null)
			{
				pHandler = null;
			}
			else
			{
				pComponent.visible = false;
				pComponent.place(_topPadding, NaN, NaN, _leftPadding).into(this, "left");
			}
			
			// Enregistrer le handler
			_leftHandler = pHandler;
			
			// Faire la transition
			hideCurrentComponent(currentComponent, _leftComponent, pTransition, pContextInfos);
		}
		
		/**
		 * Définir le composant de droite. L'ancien sera supprimé.
		 * @param	pComponent : Le composant à afficher (null pour virer le composant actuel)
		 * @param	pHandler : Le handler à l'utilisation du composant
		 * @param	pTransition : La transition
		 * @param	pContextInfos : Le contexte de la transition
		 */
		public function setRightComponent (pComponent:ResizableComponent, pTransition:ITransition = null, pContextInfos:Object = null, pHandler:Function = null):void
		{
			// Récupérer le composant actuel
			const currentComponent:ResizableComponent = _rightComponent;
			
			// Enregistrer le nouveau composant
			_rightComponent = pComponent;
			
			// Effacer le handler si le nouveau composant est null
			if (pComponent == null)
			{
				pHandler = null;
			}
			else
			{
				pComponent.visible = false;
				pComponent.place(_topPadding, _rightPadding).into(this, "right");
			}
			
			// Enregistrer le handler
			_rightHandler = pHandler;
			
			// Faire la transition
			hideCurrentComponent(currentComponent, _rightComponent, pTransition, pContextInfos);
		}
		
		/**
		 * Définir le composant du centre. L'ancien sera supprimé.
		 * @param	pComponent : Le composant du titre (null pour virer l'actuel)
		 * @param	pAnimation : L'animation (0 pour aucune animation, -1 pour une animation vers la gauche, 1 pour une animation vers la droite)
		 * @param	pHandler : Le handler à l'utilisation du composant
		 */
		public function setCenterComponent (pComponent:ResizableComponent, pTransition:ITransition = null, pContextInfos:Object = null, pHandler:Function = null):void
		{
			// Récupérer le composant actuel
			const currentComponent:ResizableComponent = _centerComponent;
			
			// Enregistrer le nouveau composant
			_centerComponent = pComponent;
			
			// Effacer le handler si le nouveau composant est null
			if (pComponent == null)
			{
				pHandler = null;
			}
			else
			{
				pComponent.visible = false;
				pComponent.place(_topPadding).center(0, NaN).into(this, "center");
			}
			
			// Enregistrer le handler
			_centerHandler = pHandler;
			
			// Faire la transition
			hideCurrentComponent(currentComponent, _centerComponent, pTransition, pContextInfos);
		}
		
		/**
		 * Click sur un élément
		 */
		protected function clickHandler (event:MouseEvent):void
		{
			// Composant de gauche
			if (_leftHandler != null && event.target == _leftComponent)
			{
				_leftHandler();
			}
			
			// Composant du centre
			else if (_centerHandler != null && event.target == _centerComponent)
			{
				_centerHandler();
			}
			
			// Composant de droite
			else if (_rightHandler != null && event.target == _rightComponent)
			{
				_rightHandler();
			}
		}
		
		/**
		 * Destruction du composant
		 */
		override public function dispose ():void
		{
			// Ne plus écouter les clics
			removeEventListener(MouseEvent.CLICK, clickHandler);
		}
	}
}