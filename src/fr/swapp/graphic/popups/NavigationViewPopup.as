package fr.swapp.graphic.popups
{
	import flash.events.MouseEvent;
	import fr.swapp.graphic.base.ResizableComponent;
	import fr.swapp.graphic.components.bitmaps.AdvancedBitmap;
	import fr.swapp.graphic.components.navigation.NavigationStack;
	
	/**
	 * @author ZoulouX
	 */
	public class NavigationViewPopup extends APopup
	{
		/**
		 * La navigationStack
		 */
		protected var _navigationStack					:NavigationStack;
		
		/**
		 * Le fond
		 */
		protected var _background						:AdvancedBitmap;
		
		/**
		 * Le bouton fermer
		 */
		protected var _closeBtn							:ResizableComponent;
		
		
		/**
		 * Récupérer le container pour le bootstrap
		 */
		override public function get container ():ResizableComponent { return _navigationStack.actionStack.currentContainer as ResizableComponent; }
		
		/**
		 * La navigationStack
		 */
		public function get navigationStack ():NavigationStack { return _navigationStack; }
		
		
		/**
		 * Le fond
		 */
		public function get background ():AdvancedBitmap { return _background; }
		public function set background (value:AdvancedBitmap):void
		{
			_background = value;
		}
		
		/**
		 * Le bouton fermer
		 */
		public function get closeBtn ():ResizableComponent { return _closeBtn; }
		public function set closeBtn (value:ResizableComponent):void
		{
			_closeBtn = value;
		}
		
		
		/**
		 * Constructeur
		 */
		public function NavigationViewPopup ()
		{
			
		}
		
		
		/**
		 * Création du displayObject par défaut
		 */
		override protected function attachDefaultDisplayObject ():void
		{
			// Créer la navigationStack
			_navigationStack = new NavigationStack(_bundle.bootstrap, null, -1, true, false)
			
			// Si on a un fond
			if (_background != null)
				_background.place(0, 0, 0, 0).into(_navigationStack.actionStack, "back", 0);
			
			// Si on a un bouton fermer
			if (_closeBtn != null)
			{
				_closeBtn.place(NaN, _navigationStack.titleBar.rightPadding).center(NaN, 0).into(_navigationStack.titleBar, "close");
				_closeBtn.addEventListener(MouseEvent.CLICK, closeClickHandler);
			}
			
			// Spécifier que c'est le displayObject
			_displayObject = _navigationStack;
			
			// Injecter
			_bundle.dependencesManager.inject(_navigationStack);
			
			// Le placement par défaut
			resizableComponent.place(0, 0, 0, 0);
		}
		
		/**
		 * Clic sur le bouton fermer
		 */
		protected function closeClickHandler (event:MouseEvent):void
		{
			// Ne plus écouter
			_closeBtn.removeEventListener(MouseEvent.CLICK, closeClickHandler);
			
			// Fermer
			turnOff();
		}
	}
}