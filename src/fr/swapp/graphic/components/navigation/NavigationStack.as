package fr.swapp.graphic.components.navigation 
{
	import flash.display.DisplayObjectContainer;
	import fr.swapp.core.actions.IAction;
	import fr.swapp.core.bootstrap.BootstrapAction;
	import fr.swapp.core.bootstrap.IBootstrap;
	import fr.swapp.core.errors.SwappError;
	import fr.swapp.core.mvc.abstract.IViewController;
	import fr.swapp.graphic.animations.ITransition;
	import fr.swapp.graphic.components.base.ComponentView;
	import fr.swapp.graphic.components.base.ResizableComponent;
	import fr.swapp.graphic.components.containers.stacks.ActionStack;
	import fr.swapp.graphic.components.controls.menus.MenuBar;
	import fr.swapp.graphic.components.controls.title.TitleBar;
	import fr.swapp.graphic.errors.GraphicalError;
	import fr.swapp.utils.ObjectUtils;
	import fr.zapiks.app.views.elements.controls.BackButton;
	
	/**
	 * ...
	 * @author ZoulouX
	 */
	public class NavigationStack extends ResizableComponent
	{
		/**
		 * Les noms des éléments pour les layouts
		 */
		public static const TITLE_BAR							:String 		= "TITLE_BAR";
		public static const MENU_BAR							:String 		= "MENU_BAR";
		public static const ACTION_STACK						:String 		= "ACTION_STACK";
		
		/**
		 * Layout sans titleBar, avec un menuBar de 50px en bas
		 */
		public static const NO_TITLE_BAR_LAYOUT					:Object = {
			// Layout de l'actionStack
			ACTION_STACK: {
				top: 0,
				right: 0,
				bottom: 50,
				left: 0
			},
			
			// Layout de la menuBar
			MENU_BAR: {
				right: 0,
				bottom: 0,
				left: 0,
				height: 50
			}
		};
		
		/**
		 * Layout sans menu
		 */
		static public const NO_MENU_BAR_LAYOUT					:Object = {
			// Layout de la titleBar
			TITLE_BAR: {
				top: 0,
				right: 0,
				left: 0,
				height: 44
			},
			
			// Layout de l'actionStack
			ACTION_STACK: {
				top: 44,
				right: 0,
				bottom: 0,
				left: 0
			}
		};
		
		/**
		 * Layout iOS par défaut, titleBar de 44px et menuBar de 50px en bas
		 */
		public static const DEFAULT_IOS_LAYOUT					:Object = {
			// Layout de la titleBar
			TITLE_BAR: {
				top: 0,
				right: 0,
				left: 0,
				height: 44
			},
			
			// Layout de l'actionStack
			ACTION_STACK: {
				top: 44,
				right: 0,
				bottom: 50,
				left: 0
			},
			
			// Layout de la menuBar
			MENU_BAR: {
				right: 0,
				bottom: 0,
				left: 0,
				height: 50
			}
		};
		
		/**
		 * Layout Android par défaut, titleBar de 44px suivit de la menuBar de 50px. L'actionStack est en bas.
		 */
		public static const DEFAULT_ANDROID_LAYOUT				:Object = {
			// Layout de la titleBar
			TITLE_BAR: {
				top: 0,
				right: 0,
				left: 0,
				height: 44
			},
			
			// Layout de la menuBar
			MENU_BAR: {
				top: 44,
				right: 0,
				left: 0,
				height: 50
			},
			
			// Layout de l'actionStack
			ACTION_STACK: {
				top: 94,
				right: 0,
				bottom: 0,
				left: 0
			}
		};
		
		
		/**
		 * La titleBar
		 */
		protected var _titleBar						:TitleBar
		
		/**
		 * L'actionStack
		 */
		protected var _actionStack					:ActionStack;
		
		/**
		 * La menuBar
		 */
		protected var _menuBar						:MenuBar;
		
		/**
		 * La class du bouton retour sur la titleBar
		 */
		protected var _backButtonClass				:Class;
		
		/**
		 * Les injections du bouton back
		 */
		protected var _backButtonExtra				:Object;
		
		/**
		 * L'index séléctionné (-1 pour aucune séléction)
		 */
		protected var _selectedIndex				:int					= -1;
		
		/**
		 * La transition par défaut pour le bouton back
		 */
		protected var _defaultBackTransition		:ITransition;
		
		
		/**
		 * Le bootstrap associé
		 */
		public function get bootstrap ():IBootstrap { return _actionStack.bootstrap; }
		
		/**
		 * La titleBar
		 */
		public function get titleBar ():TitleBar { return _titleBar; }
		
		/**
		 * L'actionStack
		 */
		public function get actionStack ():ActionStack { return _actionStack; }
		
		/**
		 * La menuBar
		 */
		public function get menuBar ():MenuBar { return _menuBar; }
		
		/**
		 * L'index séléctionné (-1 pour aucune séléction)
		 */
		public function get selectedIndex ():int { return _actionStack.selectedIndex; }
		public function set selectedIndex (value:int):void 
		{
			_actionStack.selectedIndex = value;
		}
		
		/**
		 * La class du bouton retour sur la titleBar
		 */
		public function get backButtonClass ():Class { return _backButtonClass; }
		public function set backButtonClass (value:Class):void
		{
			_backButtonClass = value;
		}
		
		/**
		 * Les injections du bouton back
		 */
		public function get backButtonExtra ():Object { return _backButtonExtra; }
		public function set backButtonExtra (value:Object):void
		{
			_backButtonExtra = value;
		}
		
		/**
		 * La transition par défaut pour le bouton back
		 */
		public function get defaultBackTransition ():ITransition { return _defaultBackTransition; }
		public function set defaultBackTransition (value:ITransition):void
		{
			_defaultBackTransition = value;
		}
		
		
		/**
		 * Le constructeur
		 * @param	pBootstrap : Le bootstrap qui va permettre d'instancier dans l'actionStack. Obligatoire.
		 * @param	pLayout : Le layout pour placer les 3 éléments de la navigationStack (titleBar / actionStack / menuBar). La titleBar et la menuBar sont optionnelles, le layout peut les supprimer. Obligatoire.
		 * @param	pItems : La liste des items (objets dynamiques ou objets de type NavigationStackItem)
		 * @param	pMenuItemRenderer : L'item renderer des boutons de la menuBar. pItems ne doit pas être null pour que ce paramètre soit pris en compte.
		 * @param	pSelectedIndex : L'index séléctionné 
		 * @param	pTitleBar : La concrête de la titleBar (une titleBar par défaut sera créée si null et si spécifiée dans le layout)
		 * @param	pMenuBar : La concrête de la menuBar (une menuBar par défaut sera créée si null et si spécifiée dans le layout)
		 */
		public function NavigationStack (pBootstrap:IBootstrap, pLayout:Object, pItems:Array = null, pMenuItemRenderer:Class = null, pSelectedIndex:int = -1, pTitleBar:TitleBar = null, pMenuBar:MenuBar = null)
		{
			// Si on n'a pas de bootstrap
			if (pBootstrap == null)
			{
				// On déclanche une erreur et on stoppe
				throw new GraphicalError("NavigationStack{}", "pBootstrap can't be null.");
				return;
			}
			
			// Si on n'a pas de layout
			if (pLayout == null)
			{
				// On déclanche une erreur et on stoppe
				throw new GraphicalError("NavigationStack{}", "pLayout can't be null.");
				return;
			}
			
			// Si on a une titleBar
			if (pTitleBar != null)
			{
				// On l'ajoute
				_titleBar = pTitleBar;
				_titleBar.into(this, TITLE_BAR);
			}
			
			// Si on a une menuBar
			if (pMenuBar != null)
			{
				// On l'ajoute
				_menuBar = pMenuBar;
				_menuBar.into(this, MENU_BAR);
				_menuBar.onChange.add(menuBarChangedHandler);
			}
			
			// Le layout
			setLayout(pLayout);
			
			// Les items
			if (pItems != null)
			{
				// Définir les items
				setItems(pItems, pMenuItemRenderer);
			}
			
			// Donner le bootstrap à l'actionStack
			_actionStack.bootstrap = pBootstrap;
			
			// Ecouter les changements de l'historique
			_actionStack.bootstrap.onHistoryAdded.add(updateTitleBar);
			
			// Ecouter lorsque le bootstrap est locké/délocké
			_actionStack.bootstrap.onLocked.add(bootstrapLockedHandler);
			_actionStack.bootstrap.onUnlocked.add(bootstrapUnlockedHandler);
			
			// L'élément séléctionné par défaut
			if (pSelectedIndex != -1)
			{
				// Appliquer sur le menu et sur la stack
				_actionStack.selectedIndex = pSelectedIndex;
			}
		}
		
		/**
		 * Bootstrap locké
		 */
		protected function bootstrapLockedHandler ():void
		{
			// Désactiver la menuBar
			if (_menuBar != null)
				_menuBar.interactive(false);
		}
		
		/**
		 * Bootstrap délocké
		 */
		protected function bootstrapUnlockedHandler ():void
		{
			// Réactiver la menuBar
			if (_menuBar != null)
				_menuBar.interactive(true);
		}
		
		/**
		 * Définnir le placement des éléments de cette navigationStack. Les clés sont :
		 * "titleBar", "actionStack" et "menuBar". Voir constantes statiques pour plus d'info sur la création de layout personnalisé.
		 * @param	pLayout : Le layout pour le placement des éléments. Si une clé n'existe pas, l'élément sera supprimé.
		 * @return : Méthode chaînable
		 */
		public function setLayout (pLayout:Object):NavigationStack
		{
			// Vérifier qu'on ai bien un layout
			if (pLayout == null)
			{
				// On déclanche une erreur et on arrête le script
				throw new GraphicalError("NavigationStack.setLayout", "pLayout can't be null.");
				return this;
			}
			
			// Si le layout a des infos sur la titleBar
			if (TITLE_BAR in pLayout)
			{
				// Si on n'a pas de titleBar
				if (_titleBar == null)
				{
					// On en créé une par défaut
					_titleBar = new TitleBar();
					_titleBar.into(this, TITLE_BAR);
				}
				
				// On configure cette titleBar
				ObjectUtils.extra(_titleBar, pLayout[TITLE_BAR]);
			}
			
			// Sinon si on a une titleBar déjà présente
			else if (_titleBar != null && contains(_titleBar))
			{
				// On la supprime
				removeChild(_titleBar);
				_titleBar = null;
			}
			
			// Si on n'a pas d'actionStack
			if (_actionStack == null)
			{
				// On créé l'actionBar et lui donne un placement par défaut
				_actionStack = new ActionStack(null, null, -1, !(MENU_BAR in pLayout));
				_actionStack.into(this, ACTION_STACK, 0);
				
				// Ecouter les changements sur l'actionStack
				_actionStack.onIndexChange.add(actionStackChangedHandler);
			}
			
			// Si le layout a des infos sur l'actionStack
			if (ACTION_STACK in pLayout)
			{
				ObjectUtils.extra(_actionStack, pLayout[ACTION_STACK]);
			}
			
			// Si le layout a des infos sur la menuBar
			if (MENU_BAR in pLayout)
			{
				// Si on n'a pas de menuBar
				if (_menuBar == null)
				{
					// On en créé une par défaut
					_menuBar = new MenuBar();
					_menuBar.into(this, MENU_BAR);
					_menuBar.onChange.add(menuBarChangedHandler);
				}
				
				// On configure cette menuBar
				ObjectUtils.extra(_menuBar, pLayout[MENU_BAR]);
			}
			
			// Sinon, si on a une menuBar déjà présente
			else if (_menuBar != null && contains(_menuBar))
			{
				// On la supprime
				_menuBar.onChange.remove(menuBarChangedHandler);
				removeChild(_menuBar);
				_menuBar = null;
			}
			
			// Méthode chaînable
			return this;
		}
		
		/**
		 * L'index de la menuBar à été changé via une interaction utilisateur
		 */
		protected function menuBarChangedHandler (pIndex:int):void
		{
			// Appliquer sur la stack
			_actionStack.selectedIndex = pIndex;
		}
		
		/**
		 * L'index de la stack a changé
		 */
		protected function actionStackChangedHandler (pIndex:int):void
		{
			// Actualiser le menu
			if (_menuBar != null)
				_menuBar.selectedIndex = pIndex;
			
			// Changement d'onglet, tout virer
			setComponentOnTitleBar(_titleBar.setLeftComponent, null);
			setComponentOnTitleBar(_titleBar.setCenterComponent, null);
			setComponentOnTitleBar(_titleBar.setRightComponent, null);
		}
		
		/**
		 * Définir les items de la navigationStack.
		 * Ces items définissent les boutons et les actions associées qui vont être déclanchées dans l'actionStack.
		 * @param	pItems : La liste des items (objets dynamiques ou objets de type NavigationStackItem)
		 * @param	pMenuItemRenderer : L'item renderer des boutons de la menuBar. pItems ne doit pas être null pour que ce paramètre soit pris en compte.
		 * @return : Méthode chaînable
		 */
		public function setItems (pItems:Array, pMenuItemRenderer:Class = null):NavigationStack
		{
			// Le tableau des concrêtes d'items
			var items:Array = [];
			
			// Parcourir les items
			for each (var item:Object in pItems)
			{
				// Si cet objet est visible
				if (!("visible" in item) || item.visible)
				{
					// Créer l'objet et l'ajouter aux couches
					items.push(item is NavigationStackItem ? item : new NavigationStackItem(item));
				}
			}
			
			// Passer les items à l'actionStack
			_actionStack.setItems(items);
			
			// Si on a une menuBar, lui passer aussi les items
			if (_menuBar)
				_menuBar.setItems(items, pMenuItemRenderer);
			
			// Méthode chaînable
			return this;
		}
		
		/**
		 * Actualiser la titleBar
		 */
		protected function updateTitleBar (pDisplayObjectContainer:DisplayObjectContainer, pViewController:IViewController, pBootstrapAction:BootstrapAction):void
		{
			// Tout ça ne sert à rien sans titleBar
			if (_titleBar != null)
			{
				// Si le controlleur est null
				if (pViewController == null)
				{
					// On le récupère depuis le bootstrap
					pViewController = _actionStack.bootstrap.getControllerFromContainer(pDisplayObjectContainer);
				}
				
				// Si le container est le même que celui en cours sur la stack
				// Et si on a un controlleur
				if (pDisplayObjectContainer == _actionStack.currentContainer && pViewController != null)
				{
					// La vue
					var currentView:ComponentView;
					
					// Récupérer l'animation depuis l'action bootstrap (par défaut pas d'anim)
					var animation:int = pBootstrapAction == null ? 0 : pBootstrapAction.contextDirection;
					
					// Le contenu de la titleBar proposé par la vue
					var titleBarContent:Object
					
					// Si on a une vue sur ce controlleur
					// Et si cette vue est de type ComponentView
					if (pViewController.view != null && pViewController.view is ComponentView)
					{
						// Récupérer la vue et la transtyper
						currentView = pViewController.view as ComponentView;
					}
					
					// Le contenu de la titleBar proposé par la vue
					titleBarContent = (currentView != null && currentView.titleBarContent != null ? currentView.titleBarContent : {})
					
					// Si on n'a pas de composant à gauche et si on a un bouton back
					if (!("left" in titleBarContent) && _backButtonClass != null)
					{
						// Récupérer l'historique
						var history:Vector.<BootstrapAction> = _actionStack.bootstrap.getHistory(_actionStack.currentContainer);
						
						// Si on a un historique avec au moins 2 pages
						if (history != null && history.length > 1)
						{
							// On créé un bouton back
							var backButton:Object = new _backButtonClass();
							
							// Vérifier que ça soit bien un bouton back
							if (!(backButton is ResizableComponent))
							{
								throw new SwappError("NavigationStack.onBootstrapContainerAddControllerHandler", "backButtonClass must extends ResizableComponent");
								return;
							}
							
							// Lui donner ses extras si besoin
							if (_backButtonExtra != null)
							{
								ObjectUtils.extra(backButton, _backButtonExtra);
							}
							
							// Ajouter le bouton retour à la titleBar
							titleBarContent.left = {
								component: backButton,
								handler: backButtonTapHandler
							};
						}
					}
					
					// Appliquer les 3 éléments de la titleBar
					setComponentOnTitleBar(_titleBar.setLeftComponent, "left" in titleBarContent ? titleBarContent.left : null, pBootstrapAction != null ? pBootstrapAction.contextTransition as ITransition : null, pBootstrapAction != null ? pBootstrapAction.contextInfos : null);
					setComponentOnTitleBar(_titleBar.setCenterComponent, "center" in titleBarContent ? titleBarContent.center : null, pBootstrapAction != null ? pBootstrapAction.contextTransition as ITransition : null, pBootstrapAction != null ? pBootstrapAction.contextInfos : null);
					setComponentOnTitleBar(_titleBar.setRightComponent, "right" in titleBarContent ? titleBarContent.right : null, pBootstrapAction != null ? pBootstrapAction.contextTransition as ITransition : null, pBootstrapAction != null ? pBootstrapAction.contextInfos : null);
					
					// Ne pas aller plus loin
					return;
				}
				
				// Pas de vue, tout virer
				//setComponentOnTitleBar(_titleBar.setLeftComponent, null);
				//setComponentOnTitleBar(_titleBar.setCenterComponent, null);
				//setComponentOnTitleBar(_titleBar.setRightComponent, null);
			}
		}
		
		/**
		 * Tap sur le bouton back
		 */
		protected function backButtonTapHandler ():void
		{
			// Récupérer l'action précédente depuis le bootstrap
			var backAction:IAction = _actionStack.bootstrap.popHistory(_actionStack.currentContainer);
			
			// Si on a une action, on l'appel sur la stack
			if (backAction != null)
			{
				// On cible en tant que bootstrapAction
				var backBootstrapAction:BootstrapAction = (backAction as BootstrapAction);
				
				// On inverse la direction de l'action
				backBootstrapAction.contextDirection = - 1;
				
				// Si cette action n'a pas de transition et qu'on a une transition de retour par défaut prédéfinie
				if (_defaultBackTransition != null && backBootstrapAction.contextTransition == null)
				{
					backBootstrapAction.contextTransition = _defaultBackTransition;
				}
				
				// On l'appel sur la stack
				_actionStack.doAction(backAction);
			}
		}
		
		/**
		 * Définir un composant sur la titleBar
		 * @param	pSideFunction : La méthode d'ajout de composant sur la titleBar
		 * @param	pSideObject : L'objet de configuration (peut être null)
		 * @param	pTransition : La transition
		 * @param	pContextInfos : Le contexte de la transition
		 */
		protected function setComponentOnTitleBar (pSideFunction:Function, pSideObject:Object, pTransition:ITransition = null, pContextInfos:Object = null):void
		{
			pSideFunction(
				pSideObject != null && "component" in pSideObject && pSideObject.component is ResizableComponent ? pSideObject.component as ResizableComponent : null,
				pTransition,
				pContextInfos,
				pSideObject != null && "handler" in pSideObject && pSideObject.handler is Function ? pSideObject.handler as Function : null
			);
		}
		
		/**
		 * Spécifier le bouton retour
		 * @param	pBackButtonClass : La classe du bouton retour (doit étendre ResizableComponent)
		 * @param	pExtra : Les injections du bouton 
		 * @param	pDefaultBackTransition : La transition par défaut pour les retours
		 */
		public function backButton (pBackButtonClass:Class, pExtra:Object = null, pDefaultBackTransition:ITransition = null):void
		{
			_backButtonClass = pBackButtonClass;
			_backButtonExtra = pExtra;
			_defaultBackTransition = pDefaultBackTransition;
		}
		
		/**
		 * Destruction
		 */
		override public function dispose ():void
		{
			if (_menuBar != null)
				_menuBar.onChange.remove(menuBarChangedHandler);
			
			_actionStack.onIndexChange.remove(actionStackChangedHandler);
			
			_actionStack.bootstrap.onHistoryAdded.remove(updateTitleBar);
			
			_actionStack.bootstrap.onLocked.remove(bootstrapLockedHandler);
			_actionStack.bootstrap.onUnlocked.remove(bootstrapUnlockedHandler);
			
			super.dispose();
		}
	}
}