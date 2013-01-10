package fr.swapp.graphic.components.controls
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import fr.swapp.graphic.base.ResizableComponent;
	import org.osflash.signals.Signal;
	
	/**
	 * @author ZoulouX
	 */
	public class Button extends ResizableComponent
	{
		/**
		 * Lorsqu'on tap sur ce bouton
		 */
		protected var _onTap							:Signal 					= new Signal();
		
		/**
		 * Lorsqu'on est en rollOver
		 */
		protected var _onRollOver						:Signal						= new Signal();
		
		/**
		 * Lorsqu'on est en rollOut
		 */
		protected var _onRollOut						:Signal						= new Signal();
		
		/**
		 * Lorsque le bouton est enfoncé
		 */
		protected var _onPress							:Signal						= new Signal();
		
		/**
		 * Lorsque le bouton est relâché
		 */
		protected var _onRelease						:Signal						= new Signal();
		
		/**
		 * Lorsque la séléction du bouton a changé (appelé uniquement par l'utilisateur)
		 */
		protected var _onSelectedChange					:Signal						= new Signal();
		
		
		/**
		 * Si le bouton est séléctionnable
		 */
		protected var _selectable						:Boolean					= false;
		
		/**
		 * Si le bouton est séléctionné
		 */
		protected var _selected							:Boolean					= false;
		
		/**
		 * Si le bouton est activé
		 */
		protected var _enabled							:Boolean					= true;
		
		/**
		 * Si le bouton est enfoncé
		 */
		protected var _isPressed							:Boolean					= false;
		
		/**
		 * Si le bouton est en rollOver
		 */
		protected var _isRolledOver						:Boolean					= false;
		
		
		/**
		 * La zone d'interaction
		 */
		protected var _zone								:Sprite;
		
		/**
		 * La marge du haut pour la zone d'interaction
		 */
		protected var _zoneTopMargin					:int;
		
		/**
		 * La marge de droite pour la zone d'interaction
		 */
		protected var _zoneRightMargin					:int;
		
		/**
		 * La marge du bas pour la zone d'interaction
		 */
		protected var _zoneBottomMargin					:int;
		
		/**
		 * La marge de gauche pour la zone d'interaction
		 */
		protected var _zoneLeftMargin					:int;
		
		
		/**
		 * La marge du haut pour la zone d'interaction
		 */
		public function get zoneTopMargin ():int { return _zoneTopMargin; }
		public function set zoneTopMargin (value:int):void
		{
			_zoneTopMargin = value;
		}
		
		/**
		 * La marge de droite pour la zone d'interaction
		 */
		public function get zoneRightMargin ():int { return _zoneRightMargin; }
		public function set zoneRightMargin (value:int):void
		{
			_zoneRightMargin = value;
		}
		
		/**
		 * La marge du bas pour la zone d'interaction
		 */
		public function get zoneBottomMargin ():int { return _zoneBottomMargin; }
		public function set zoneBottomMargin (value:int):void
		{
			_zoneBottomMargin = value;
		}
		
		/**
		 * La marge de gauche pour la zone d'interaction
		 */
		public function get zoneLeftMargin ():int { return _zoneLeftMargin; }
		public function set zoneLeftMargin (value:int):void
		{
			_zoneLeftMargin = value;
		}
		
		/**
		 * Determines whether or not the children of the object are mouse, or user input device, enabled. 
		 * If an object is enabled, a user can interact with it by using a mouse or user input device. The default is true.
		 * 
		 *   This property is useful when you create a button with an instance of the Sprite class
		 * (instead of using the SimpleButton class). When you use a Sprite instance to create a button,
		 * you can choose to decorate the button by using the addChild() method to add additional
		 * Sprite instances. This process can cause unexpected behavior with mouse events because
		 * the Sprite instances you add as children can become the target object of a mouse event
		 * when you expect the parent instance to be the target object. To ensure that the parent
		 * instance serves as the target objects for mouse events, you can set the 
		 * mouseChildren property of the parent instance to false. No event is dispatched by setting this property. You must use the
		 * addEventListener() method to create interactive functionality.
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 * @playerversion	Lite 4
		 */
		override public function get mouseChildren ():Boolean { return super.mouseChildren; }
		override public function set mouseChildren (value:Boolean):void
		{
			// Enregistrer
			super.mouseChildren = value;
			
			// Invalider
			invalidate();
		}
		
		/**
		 * Lorsqu'on tap sur ce bouton
		 */
		public function get onTap ():Signal { return _onTap; }
		
		/**
		 * Lorsqu'on est en rollOver
		 */
		public function get onRollOver ():Signal { return _onRollOver; }
		
		/**
		 * Lorsqu'on est en rollOut
		 */
		public function get onRollOut ():Signal { return _onRollOut; }
		
		/**
		 * Lorsque le bouton est enfoncé
		 */
		public function get onPress ():Signal { return _onPress; }
		
		/**
		 * Lorsque le bouton est relâché
		 */
		public function get onRelease ():Signal { return _onRelease; }
		
		/**
		 * Lorsque la séléction du bouton a changé (appelé uniquement par l'utilisateur)
		 */
		public function get onSelectedChange ():Signal { return _onSelectedChange; }
		
		/**
		 * Si le bouton est séléctionnable
		 */
		public function get selectable ():Boolean { return _selectable; }
		public function set selectable (value:Boolean):void
		{
			// Si c'est différent
			if (_selectable != value)
			{
				// On enregistre
				_selectable = value;
			}
		}
		
		/**
		 * Si le bouton est séléctionné
		 */
		public function get selected ():Boolean { return _selected; }
		public function set selected (value:Boolean):void
		{
			// Si c'est différent
			if (_selected != value)
			{
				// Enregistrer
				_selected = value;
				
				// Invalider
				invalidate();
			}
		}
		
		/**
		 * Si le bouton est activé
		 */
		public function get enabled ():Boolean { return _enabled; }
		public function set enabled (value:Boolean):void
		{
			// Si c'est différent
			if (_enabled != value)
			{
				// Enregistrer
				_enabled = value;
				
				// Invalider
				invalidate();
			}
		}
		
		/**
		 * Si le bouton est enfoncé
		 */
		public function get isPressed ():Boolean { return _isPressed; }
		
		/**
		 * Si le bouton est en rollOver
		 */
		public function get isRolledOver ():Boolean { return _isRolledOver; }
		
		
		
		/**
		 * Constructeur du bouton.
		 * Par défaut mouseChildren est désactivé.
		 * Si mouseChildren est réactivé manuellement, la zone d'interaction sera desactivée.
		 */
		public function Button ()
		{
			// Activer les styles
			_styleEnabled = true;
			
			// Ne pas gérer l'intéractivité sur le contenu
			mouseChildren = false;
			buttonMode = true;
			useHandCursor = true;
			
			// Créer la zone d'interactivité
			createZone();
			
			// Initialiser l'interactivité
			initInteractivity();
		}
		
		/**
		 * Initialiser l'interactivité
		 */
		protected function initInteractivity ():void
		{
			addEventListener(MouseEvent.CLICK, globalInteractivityHandler);
			addEventListener(MouseEvent.ROLL_OVER, globalInteractivityHandler);
			addEventListener(MouseEvent.MOUSE_DOWN, globalInteractivityHandler);
		}
		
		/**
		 * Créer la zone d'intéraction
		 */
		protected function createZone ():void
		{
			// Créer la zone d'intéraction
			_zone = new Sprite();
			_zone.graphics.beginFill(0xFF0000);
			_zone.graphics.drawRect(0, 0, 1, 1);
			_zone.graphics.endFill();
			
			// Ajouter mais masquer cette zone
			addChild(_zone);
			_zone.visible = false;
			
			// La zone de clic c'est la zone que l'on vient de crée
			hitArea = _zone;
		}
		
		
		/**
		 * Redimensionné
		 */
		override protected function needReplace ():void
		{
			// Actualiser selon le flux
			updateFlow();
			
			// Replacer la zone
			if (_zone != null)
			{
				// Si on autorise les clics sur les children
				if (mouseChildren && hitArea != null)
				{
					hitArea = null;
				}
				else if (!mouseChildren && hitArea != _zone)
				{
					hitArea = _zone;
				}
				
				// Appliquer les dimension
				_zone.width = _zoneLeftMargin + _localWidth + _zoneRightMargin;
				_zone.height = _zoneTopMargin + _localHeight + _zoneBottomMargin;
				
				// Placer
				_zone.x = _zoneLeftMargin;
				_zone.y = _zoneTopMargin;
			}
		}
		
		/**
		 * Définir les marges de la zone d'interaction
		 */
		public function zoneMargin (pTopMargin:int = 0, pRightMargin:int = 0, pBottomMargin:int = 0, pLeftMargin:int = 0):Button
		{
			// Enregistrer
			_zoneTopMargin = pTopMargin;
			_zoneRightMargin = pRightMargin;
			_zoneBottomMargin = pBottomMargin;
			_zoneLeftMargin = pLeftMargin;
			
			// Invalider
			invalidate();
			
			// Méthode chaînable
			return this;
		}
		
		/**
		 * Le handler global pour l'interaction
		 */
		protected function globalInteractivityHandler (event:MouseEvent):void 
		{
			// Si c'est un click
			if (event.type == MouseEvent.CLICK)
			{
				// On dispatch un tap
				tapped();
				_onTap.dispatch();
				
				// Si on est en mode séléctable
				if (_selectable)
				{
					// Inverser l'état de séléction
					_selected = !_selected;
					
					// Dispatcher
					selectedChange();
					_onSelectedChange.dispatch();
				}
			}
			
			// Si c'est un rollOver
			else if (event.type == MouseEvent.ROLL_OVER)
			{
				// Si le bouton est activé
				if (_enabled)
				{
					// Actualiser l'état
					_isRolledOver = true
					
					// Dispatcher
					rolledOver();
					_onRollOver.dispatch();
					
					// Ecouter les rollOuts sur le stage
					stage.addEventListener(MouseEvent.ROLL_OUT, globalInteractivityHandler, false, 0, true);
				}
			}
			
			// Si c'est un rollOut
			else if (event.type == MouseEvent.ROLL_OUT)
			{
				// Si on est en rollOver
				if (_isRolledOver)
				{
					// Ne plus écouter les rollOuts sur le stage
					stage.removeEventListener(MouseEvent.ROLL_OUT, globalInteractivityHandler);
					
					// On ne l'est plus
					_isRolledOver = false;
					
					// Dispatcher
					rolledOut();
					_onRollOut.dispatch();
				}
			}
			
			// Clic enfoncé
			else if (event.type == MouseEvent.MOUSE_DOWN)
			{
				// Si le bouton est activé
				if (_enabled)
				{
					// Actualiser l'état
					_isPressed = true;
					
					// Dispatcher
					pressed();
					_onPress.dispatch();
					
					// Ecouter les release
					stage.addEventListener(MouseEvent.MOUSE_UP, globalInteractivityHandler, false, 0, true);
				}
			}
			
			// Clic relâché
			else if (event.type == MouseEvent.MOUSE_UP)
			{
				// Si on est en press
				if (_isPressed)
				{
					// Ne plus écouter les rollOuts sur le stage
					stage.removeEventListener(MouseEvent.MOUSE_UP, globalInteractivityHandler);
					
					// On ne l'est plus
					_isPressed = false;
					
					// Dispatcher
					released();
					_onRelease.dispatch();
				}
			}
		}
		
		/**
		 * Tap sur le bouton
		 */
		protected function tapped ():void
		{
			
		}
		
		/**
		 * Curseur au dessus de la zone
		 */
		protected function rolledOver ():void
		{
			
		}
		
		/**
		 * Curseur en dehors de la zone
		 */
		protected function rolledOut ():void
		{
			
		}
		
		/**
		 * Clic enfoncé
		 */
		protected function pressed ():void
		{
			
		}
		
		/**
		 * Clic relâché
		 */
		protected function released ():void
		{
			
		}
		
		/**
		 * Le status de séléction change
		 */
		protected function selectedChange ():void
		{
			
		}
		
		/**
		 * Le status d'activation change
		 */
		protected function enabledChange ():void
		{
			
		}
		
		/**
		 * Destruction
		 */
		override public function dispose ():void
		{
			// Supprimer les signaux
			_onTap.removeAll();
			_onRollOver.removeAll();
			_onRollOut.removeAll();
			_onPress.removeAll();
			_onRelease.removeAll();
			_onSelectedChange.removeAll();
			
			_onTap = null;
			_onRollOver = null;
			_onRollOut = null;
			_onPress = null;
			_onRelease = null;
			_onSelectedChange = null;
			
			// Supprimer les events
			removeEventListener(MouseEvent.CLICK, globalInteractivityHandler);
			removeEventListener(MouseEvent.ROLL_OVER, globalInteractivityHandler);
			removeEventListener(MouseEvent.MOUSE_DOWN, globalInteractivityHandler);
		}
	}
}