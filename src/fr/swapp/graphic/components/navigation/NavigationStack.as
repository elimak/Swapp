package fr.swapp.graphic.components.navigation 
{
	import flash.display.DisplayObjectContainer;
	import fr.swapp.core.actions.IAction;
	import fr.swapp.core.bootstrap.BootstrapAction;
	import fr.swapp.core.bootstrap.IBootstrap;
	import fr.swapp.core.errors.SwappError;
	import fr.swapp.core.mvc.abstract.IViewController;
	import fr.swapp.graphic.animations.ITransition;
	import fr.swapp.graphic.base.ComponentView;
	import fr.swapp.graphic.base.ResizableComponent;
	import fr.swapp.graphic.components.controls.Button;
	import fr.swapp.graphic.components.navigation.items.NavigationStackItem;
	import fr.swapp.graphic.errors.GraphicalError;
	import fr.swapp.utils.ObjectUtils;
	
	/**
	 * ...
	 * @author ZoulouX
	 */
	public class NavigationStack extends ResizableComponent
	{
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
		 * L'index séléctionné (-1 pour aucune séléction)
		 */
		protected var _selectedIndex				:int					= -1;
		
		/**
		 * La classe du bouton back
		 */
		protected var _backButtonClass				:Class					= Button;
		
		/**
		 * Les extras du bouton back
		 */
		protected var _backButtonExtra				:Object;
		
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
		 * La classe du bouton back
		 */
		public function get backButtonClass ():Class { return _backButtonClass; }
		public function set backButtonClass (value:Class):void
		{
			_backButtonClass = value;
		}
		
		/**
		 * Les extras du bouton back
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
		 * @param	pItems : La liste des items (objets dynamiques ou objets de type NavigationStackItem)
		 * @param	pSelectedIndex : L'index séléctionné (aucun par défaut)
		 * @param	pTitleBar : Si la barre de titre doit être créée
		 * @param	pMenuBar : Si la barre de menu doit être créée
		 * @param	pMenuItemRenderer : L'item renderer des boutons de la menuBar. pItems ne doit pas être null pour que ce paramètre soit pris en compte.
		 */
		public function NavigationStack (pBootstrap:IBootstrap, pItems:Array = null, pSelectedIndex:int = -1, pTitleBar:Boolean = true, pMenuBar:Boolean = true, pMenuItemRenderer:Class = null)
		{
			// Activer les styles
			_styleEnabled = true;
			
			// Si on n'a pas de bootstrap
			if (pBootstrap == null)
			{
				// On déclanche une erreur et on stoppe
				throw new GraphicalError("NavigationStack{}", "pBootstrap can't be null.");
				return;
			}
			
			// On créé l'actionStack et lui donne un placement par défaut (un seul container si on n'a pas de menu)
			_actionStack = new ActionStack(null, null, -1, !pMenuBar);
			_actionStack.place(pTitleBar ? 44 : 0, 0, pMenuBar ? 50 : 0, 0);
			_actionStack.into(this);
			
			// Ecouter les changements sur l'actionStack
			_actionStack.onIndexChange.add(actionStackChangedHandler);
			
			// Si on a une titleBar
			if (pTitleBar)
			{
				// On l'ajoute
				_titleBar = new TitleBar();
				_titleBar.place(0, 0, NaN, 0).size(NaN, 44);
				_titleBar.into(this);
			}
			
			// Si on a une menuBar
			if (pMenuBar)
			{
				// On l'ajoute
				_menuBar = new MenuBar();
				_menuBar.place(NaN, 0, 0, 0).size(NaN, 50);
				_menuBar.into(this);
				
				// Ecouter les changements d'index sur le menu
				_menuBar.onChange.add(menuBarChangedHandler);
			}
			
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