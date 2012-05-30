package fr.swapp.graphic.components.navigation 
{
	import flash.display.DisplayObjectContainer;
	import fr.swapp.core.actions.IAction;
	import fr.swapp.core.actions.IActionable;
	import fr.swapp.core.bootstrap.BootstrapAction;
	import fr.swapp.core.bootstrap.IBootstrap;
	import fr.swapp.core.mvc.abstract.IViewController;
	import fr.swapp.graphic.base.ResizableComponent;
	import fr.swapp.graphic.components.navigation.items.IStackLayerItem;
	import fr.swapp.graphic.errors.GraphicalError;
	import org.osflash.signals.Signal;
	
	/**
	 * ...
	 * @author ZoulouX
	 */
	public class ActionStack extends ResizableComponent implements IActionable
	{
		/**
		 * Les couches de ce container stack
		 */
		protected var _items							:Vector.<IStackLayerItem>;
		
		/**
		 * Les containers pour chaque index
		 */
		protected var _containers						:Array							= [];
		
		/**
		 * L'index séléctionné (-1 pour aucune séléction)
		 */
		protected var _selectedIndex					:int							= -1;
		
		/**
		 * Le bootstrap associé pour appeler les action
		 */
		protected var _bootstrap						:IBootstrap;
		
		/**
		 * Lorsque l'index selectionné change (paramètre 1 : le nouvel index)
		 */
		protected var _onIndexChange					:Signal							= new Signal(int);
		
		/**
		 * Utiliser un seul container
		 */
		protected var _oneContainer						:Boolean;
		
		
		/**
		 * Les couches de ce container stack
		 */
		public function get items ():Vector.<IStackLayerItem> { return _items; }
		
		/**
		 * L'index séléctionné (-1 pour aucune séléction)
		 */
		public function get selectedIndex ():int { return _selectedIndex; }
		public function set selectedIndex (value:int):void 
		{
			// Vérifier si l'index ne sort pas des limites
			if (!(value in _items) && _selectedIndex != -1)
			{
				// Déclancher une erreur et arrêter le script
				throw new GraphicalError("ActionStack", "selectedIndex is out of bounds (" + _items.length + ")");
				return;
			}
			
			// L'index à supprimer
			var indexToDelete:int = _selectedIndex;
			
			// Dispatcher le changement
			if (_selectedIndex != value)
				_onIndexChange.dispatch(value);
			
			// Actualiser le nouvel indexs
			if (updateSelected(value))
			{
				// Si nos index ont changés
				if (indexToDelete != _selectedIndex)
				{
					// Virer l'index actuel
					destroySelected(indexToDelete);
				}
			}
		}
		
		/**
		 * Le bootstrap associé pour appeler les action
		 */
		public function get bootstrap ():IBootstrap { return _bootstrap; }
		public function set bootstrap (value:IBootstrap):void 
		{
			_bootstrap = value;
		}
		
		/**
		 * Lorsque l'index selectionné change (paramètre 1 : le nouvel index)
		 */
		public function get onIndexChange ():Signal { return _onIndexChange; }
		
		/**
		 * Utiliser un seul container
		 */
		public function get oneContainer ():Boolean { return _oneContainer; }
		
		/**
		 * Récupérer le container en cours
		 */
		public function get currentContainer ():DisplayObjectContainer
		{
			if (_selectedIndex in _containers)
				return _containers[_selectedIndex];
			else
				return null;
		}
		
		
		/**
		 * Le constructeur
		 * @param	pBootstrap : Le bootstrap associé pour déclancher les actions
		 * @param	pItems : La liste des couches, de type IStackLayerItem ou objets dynamiques qui seront convertis.
		 * @param	pSelectedIndex : L'index séléctionné par défaut (-1 pour aucune séléction)
		 * @param	pOneContainer : Un container pour tous les index
		 */
		public function ActionStack (pBootstrap:IBootstrap = null, pItems:Array = null, pSelectedIndex:int = -1, pOneContainer:Boolean = false)
		{
			// TODO: Signal onChange sur le actionStack (le layerstackitem en paramètre)
			// TODO: Implémenter la gestion d'un seul container
			
			// Enregistrer
			_oneContainer = pOneContainer;
			
			// Enregistrer l'actionnable
			_bootstrap = pBootstrap;
			
			// Si on a des items, on les défini
			if (pItems != null)
				setItems(pItems);
			
			// Si on n'a qu'un container
			if (_oneContainer)
			{
				updateSelected(0);
				return;
			}
			
			// Séléctionner l'index
			if (pSelectedIndex != -1)
				selectedIndex = pSelectedIndex;
		}
		
		
		/**
		 * Définir le comportement des couches
		 * @param	pItems : La liste des couches, de type IStackLayerItem ou objets dynamiques qui seront convertis.
		 */
		public function setItems (pItems:Array):void
		{
			// Remettre le tableau à 0
			_items = new <IStackLayerItem>[];
			
			// Parcourir les items
			for each (var item:Object in pItems)
			{
				// Créer l'objet et l'ajouter aux couches
				_items.push(item is IStackLayerItem ? item : new StackLayerItem(item));
			}
		}
		
		/**
		 * Faire une action sur le container en cours
		 * @param	pAction : L'action à exécuter
		 */
		public function doAction (pAction:IAction):void
		{
			// Si on a un container
			if (currentContainer != null)
			{
				updateSelected(_selectedIndex, pAction);
			}
		}
		
		/**
		 * Détruire le container de l'index en cours
		 */
		protected function destroySelected (pSelectedIndex:int):void
		{
			// Vérifier si on a un container à détruire
			if (pSelectedIndex != -1 && pSelectedIndex in _items && pSelectedIndex in _containers)
			{
				// Le container ciblé
				var container:ResizableComponent = _containers[pSelectedIndex];
				
				// Le controlleur associé
				var viewController:IViewController = _bootstrap.getControllerFromContainer(container);
				
				if (viewController != null)
				{
					// Si on a un viewController et une vue associée a ce controller
					if (viewController.view != null && viewController.view.displayObject.parent != null && viewController.view.displayObject.parent == container)
					{
						// Vérifier le type de destruction
						if (_items[pSelectedIndex].destructionPolicy == StackLayerItem.REMOVE_POLICY)
						{
							// Supprimer cette vue
							container.removeChild(viewController.view.displayObject);
						}
						else
						{
							// Signaler qu'on masque la vue
							viewController.view.deactivate();
							
							// Masquer la vue
							viewController.view.displayObject.visible = false;
						}
					}
				}
			}
		}
		
		/**
		 * Actualiser l'index séléctionné
		 */
		protected function updateSelected (pSelectedIndex:int, pCustomAction:IAction = null):Boolean
		{
			// Le container
			var container:ResizableComponent;
			
			// Vérifier si on a un container pour l'index séléctionné
			if (!(pSelectedIndex in _containers))
			{
				// Créer le container, le placer et l'enregistrer dans le tableau via son index
				_containers[pSelectedIndex] = (new ResizableComponent()).place(0, 0, 0, 0).into(this, "ActionStack" + pSelectedIndex);
			}
			
			// Si on a qu'un container
			if (_oneContainer)
			{
				// Séléctionner l'index
				_selectedIndex = pSelectedIndex;
				
				// On n'appel rien
				return false;
			}
			
			// Cibler le container
			container = _containers[pSelectedIndex];
			
			// Récupérer le controlleur associé a ce container
			var viewController:IViewController = _bootstrap.getControllerFromContainer(_containers[pSelectedIndex]);
			
			// Si le controller existe et si sa vue est masquée
			if (viewController != null && viewController.view != null && !viewController.view.displayObject.visible)
			{
				// Activer la vue
				viewController.view.activate();
				
				// Afficher la vue
				viewController.view.displayObject.visible = true;
				
				// C'est ok
				return true;
			}
			else
			{
				// Récupérer l'action
				var action:BootstrapAction;
				
				// Le sens de l'animation
				var animation:Number = NaN;
				
				// Récupérer la dernière action
				var lastAction:BootstrapAction = _bootstrap.getLastHistoryAction(container);
				
				// Si on a une action particulière
				if (pCustomAction != null && pCustomAction is BootstrapAction)
				{
					// On la récupère
					action = pCustomAction as BootstrapAction;
				}
				
				// Si on est déjà sur le bon index
				else if (pSelectedIndex == _selectedIndex && lastAction != null)
				{
					// Si l'action en cours est la même
					if (lastAction == _items[pSelectedIndex].action)
					{
						// On ne fait rien
						return false;
					}
					else
					{
						// Sinon l'animation est inversée
						animation = -1;
					}
				}
				
				// Si on n'a pas de customAction
				if (pCustomAction == null)
				{
					// Sinon si on avait une action
					if (lastAction != null && pSelectedIndex != _selectedIndex && lastAction != _items[pSelectedIndex].action)
					{
						// On prend la dernière action
						action = lastAction;
						
						// Supprimer la dernière action
						_bootstrap.deleteLastActionInHistory(container);
						
						// Pas d'animation
						animation = 0;
					}
					
					// Sinon on prend l'action des items
					else
					{
						// Sinon on prend l'action de l'item
						action = _items[pSelectedIndex].action;
						
						// Pas d'animation
						if (pSelectedIndex == _selectedIndex)
							animation = -1;
						else
							animation = 0;
						
						// Supprimer l'historique
						_bootstrap.deleteHistoryForContainer(container);
					}
				}
				
				// Passer le container au contexte de l'action
				action.contextDisplayContainer = _containers[pSelectedIndex];
				
				// Spécifier l'animation
				if (animation >= 0 || animation < 0)
					action.contextDirection = animation;
				
				// Séléctionner l'index
				_selectedIndex = pSelectedIndex;
				
				// Exécuter l'action
				if (_bootstrap != null)
					_bootstrap.doAction(action);
				
				// Vérifier si l'action a été annulée
				if (action.canceled)
				{
					// On remet l'état précédent
					return false;
				}
				else
				{
					// Changement ok
					return true;
				}
			}
		}
		
		/**
		 * Destruction
		 */
		override public function dispose ():void
		{
			_onIndexChange.removeAll();
			_onIndexChange = null;
			
			super.dispose();
		}
	}
}