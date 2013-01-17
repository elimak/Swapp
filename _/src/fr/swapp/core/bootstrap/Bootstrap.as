package fr.swapp.core.bootstrap 
{
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	import fr.swapp.core.actions.IAction;
	import fr.swapp.core.actions.IActionable;
	import fr.swapp.core.dependences.IDependencesManager;
	import fr.swapp.core.errors.SwappError;
	import fr.swapp.core.log.Log;
	import fr.swapp.core.mvc.abstract.IViewController;
	import fr.swapp.core.roles.IDisposable;
	import fr.swapp.utils.ObjectUtils;
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	
	/**
	 * 
	 * @author ZoulouX
	 */
	public class Bootstrap implements IBootstrap
	{
		/**
		 * Système de dévérouillage : Exécuter la dernière action en attente lors du dévérouillage
		 */
		public static const DO_LAST_ACTION_ON_UNLOCK		:int											= 0;
		
		/**
		 * Système de dévérouillage : Annuler la dernière action en attente lors du dévérouillage
		 */
		public static const CANCEL_LAST_ACTION_ON_UNLOCK	:int											= -1;
		
		
		/**
		 * Le delegate du bootstrap pour récupérer le container par défaut
		 */
		protected var _delegate								:IBootstrapDelegate;
		
		/**
		 * Le manager de dépendances
		 */
		protected var _dependencesManager					:IDependencesManager;
		
		/**
		 * La liste des controlleurs par rapport aux containers.
		 * Les containers en clé, le controlleurs en valeurs.
		 */
		protected var _controllersOnContainers				:Dictionary 									= new Dictionary();
		
		/**
		 * Les historiques des actions par containers. En weakReference en cas de leak au niveau de la suppression.
		 */
		protected var _historyOnContainers					:Dictionary										= new Dictionary(true);
		
		/**
		 * La liste des actions enregistrées et mappées sur des classes de controlleur
		 */
		protected var _mappedActions						:Vector.<BootstrapActionMapToController>		= new <BootstrapActionMapToController>[];
		
		/**
		 * Si le bootstrap est vérouillé
		 */
		protected var _locked								:Boolean;
		
		/**
		 * L'action globale en attente
		 */
		protected var _waitingAction						:IAction;
		
		/**
		 * Vérouillage automatique du bootstrap lorsqu'une commande est lancée.
		 * Le bootstrap se dévérouille une fois que tous les controlleurs sont démarrés.
		 */
		protected var _autoLock								:Boolean										= true;
		
		/**
		 * Le nombre de controlleur qui sont en travail (en démarrage)
		 */
		protected var _totalWorkingControllers				:int											= 0;
		
		/**
		 * Les controlleurs en travail (peuvent vérouiller le bootstrap tant qu'ils sont en travail)
		 */
		protected var _workingControllers					:Dictionary										= new Dictionary();
		
		/**
		 * Lorsqu'une action est appelée
		 */
		protected var _onAction								:Signal											= new Signal(BootstrapAction);
		
		/**
		 * Lorsque le nombre de controlleur en travail change
		 */
		protected var _onControllerWork						:Signal											= new Signal(int);
		
		/**
		 * Lorsqu'un container a un nouveau controlleur
		 */
		protected var _onContainerAddController				:Signal											= new Signal(DisplayObjectContainer, IViewController, BootstrapAction);
		
		/**
		 * Lorsqu'un container perd un controlleur
		 */
		protected var _onContainerRemoveController			:Signal											= new Signal(DisplayObjectContainer, IViewController, BootstrapAction);
		
		/**
		 * Un élément à été ajouté à un historique
		 */
		protected var _onHistoryAdded						:Signal											= new Signal(DisplayObjectContainer, IViewController, BootstrapAction);
		
		/**
		 * Lorsque le bootstrap est vérouillé
		 */
		protected var _onLocked								:Signal											= new Signal();
		
		/**
		 * Lorsque le bootstrap est dévérouillé
		 */
		protected var _onUnlocked							:Signal											= new Signal();
		
		/**
		 * Le contexte par défaut
		 */
		protected var _defaultContextInfos					:Object;
		
		
		/**
		 * Le delegate associé au bootstrap.
		 * Ce delegate permet de récupérer le displayContainer par défaut.
		 */
		public function get delegate ():IBootstrapDelegate { return _delegate };
		public function set delegate (value:IBootstrapDelegate):void
		{
			_delegate = value;
		}
		
		/**
		 * Le manager de dépendances associé au bootstrap.
		 * Le Bootstrap se servira de ce manager pour instancier et injecter les éléments d'architecture de l'application.
		 */
		public function get dependencesManager ():IDependencesManager { return _dependencesManager };
		public function set dependencesManager (value:IDependencesManager):void
		{
			_dependencesManager = value;
		}
		
		/**
		 * La liste des actions enregistrées et mappées sur des classes de controlleur.
		 * Un clone du vecteur sera renvoyé pour ne pas perturber le fonctionnement interne du bootstrap.
		 */
		public function get mappedActions ():Vector.<BootstrapActionMapToController> { return _mappedActions.concat(); }
		
		/**
		 * Si l'objet est vérouillé
		 */
		public function get locked ():Boolean { return _locked };
		
		/**
		 * Vérouillage automatique du bootstrap lorsqu'une commande est lancée.
		 * Le bootstrap se dévérouille une fois que tous les controlleurs sont démarrés.
		 */
		public function get autoLock ():Boolean { return _autoLock; }
		public function set autoLock (value:Boolean):void 
		{
			_autoLock = value;
		}
		
		/**
		 * Le nombre de controlleur qui sont en travail (en démarrage)
		 */
		public function get totalWorkingControllers ():int { return _totalWorkingControllers; }
		
		/**
		 * Lorsqu'une action est appelée
		 */
		public function get onAction ():ISignal { return _onAction; }
		
		/**
		 * Lorsque le nombre de controlleur en travail change
		 */
		public function get onControllerWork ():ISignal { return _onControllerWork; }
		
		/**
		 * Lorsqu'un container a un nouveau controlleur
		 */
		public function get onContainerAddController ():ISignal { return _onContainerAddController; }
		
		/**
		 * Lorsqu'un container perd un controlleur
		 */
		public function get onContainerRemoveController ():ISignal { return _onContainerRemoveController; }
		
		/**
		 * Un élément à été ajouté à un historique
		 */
		public function get onHistoryAdded ():ISignal { return _onHistoryAdded; }
		
		/**
		 * Lorsque le bootstrap est vérouillé
		 */
		public function get onLocked ():ISignal { return _onLocked; }
		
		/**
		 * Lorsque le bootstrap est dévérouillé
		 */
		public function get onUnlocked ():ISignal { return _onUnlocked; }
		
		/**
		 * Le contexte par défaut
		 */
		public function get defaultContextInfos ():Object { return _defaultContextInfos; }
		public function set defaultContextInfos (value:Object):void
		{
			_defaultContextInfos = value;
		}
		
		
		/**
		 * Le constructeur
		 */
		public function Bootstrap ()
		{
			// TODO: Désactivé l'interactivité sur les containers qui ont des controlleurs en traitement
		}
		
		
		/**
		 * Associer le nom d'une action à un controlleur
		 * @param	pActionName : Le nom de l'action
		 * @param	pControllerClass : La classe du controlleur à instancier (de type IViewController)
		 * @param	pDefaultParams : Les paramètres par défaut (seront écrasés à l'appel de l'action)
		 * @param	pDefaultContextInfos : Les informations du contexte par défaut (seront écrasés à l'appel de l'action)
		 */
		public function mapAction (pActionName:String, pControllerClass:Class, pDefaultParams:Object = null, pDefaultContextInfos:Object = null):void
		{
			// Créer le mapping et l'ajouter au tableau des actions mappées
			_mappedActions.push(new BootstrapActionMapToController(pActionName, pControllerClass, pDefaultParams, pDefaultContextInfos));
		}
		
		/**
		 * Dissocier le nom d'une action à un controlleur
		 * @param	pActionName : Le nom de l'action a détacher
		 * @param	pControllerClass : La classe associée à détacher
		 */
		public function unmapAction (pActionName:String, pControllerClass:Class):void
		{
			// Créer un nouveau vecteur
			var newMappedActions:Vector.<BootstrapActionMapToController> = new <BootstrapActionMapToController>[];
			
			// Parcourir le vecteur actuel
			for each (var mappedAction:BootstrapActionMapToController in _mappedActions)
			{
				// Si ça ne correspond pas
				if (mappedAction.actionName != pActionName || mappedAction.controllerClass != pControllerClass)
				{
					// On ajoute
					newMappedActions.push(mappedAction);
				}
			}
			
			// On enregistre le nouveau vecteur
			_mappedActions = newMappedActions;
		}
		
		/**
		 * Interprêter une action.
		 * @param	pAction : L'action (de type BootstrapAction)
		 */
		public function doAction (pAction:IAction):void
		{
			Log.notice("Bootstrap.doAction", pAction.name);
			
			// Cibler l'action comme étant une action bootstrap
			var bootstrapAction:BootstrapAction = pAction as BootstrapAction;
			
			// L'action clonée (une action clonée par bootstrap)
			var clonedAction:BootstrapAction;
			
			// Si le bootstrap n'est pas vérouillé
			if (!_locked)
			{
				// Signaler l'action
				_onAction.dispatch(bootstrapAction);
				
				// Parcourir les controlleurs, pour les prévenir de l'action qui va être déclanchée
				for each (var controller:IViewController in _controllersOnContainers)
				{
					controller.catchAction(pAction);
				}
				
				// Si l'action a été annulée
				if (pAction.canceled)
				{
					Log.warning("Bootstrap.doAction, Action canceled by catchers -> " + pAction.name);
					
					// On n'exécute pas l'action
					return;
				}
				
				// Parcourir les actions mappées, pour instancier les controlleurs
				for each (var mappedAction:BootstrapActionMapToController in _mappedActions)
				{
					// Si le nom de l'action mappée correspond
					if (mappedAction.actionName == bootstrapAction.name)
					{
						// Le displayContainer avec lequel sera associé le controlleur
						var displayContainer:DisplayObjectContainer;
						
						// Vérifier si on a l'info dans l'action
						if (bootstrapAction.contextDisplayContainer != null)
						{
							// On cible celui de l'action
							displayContainer = bootstrapAction.contextDisplayContainer;
						}
						
						// Sinon on regarde si on a un delegate
						else if (_delegate != null)
						{
							// On récupère celui du delegate
							displayContainer = _delegate.getDefaultDisplayContainer(pAction);
						}
						
						// Cloner l'action et reprenant les paramètres par défaut
						clonedAction = bootstrapAction.clone(
							mappedAction.defaultParams,
							ObjectUtils.extra(mappedAction.defaultContextInfos, _defaultContextInfos)
						) as BootstrapAction;
						
						// Appeler le controlleur pour le container
						var calledController:IViewController = callControllerForContainer(
							mappedAction.controllerClass,	// La classe du controlleur
							displayContainer,				// Le container avec lequel sera associé le controlleur
							clonedAction					// L'action bootstrap associée
						);
						
						// Si on a bien un controlleur qui a été créé
						if (calledController != null)
						{
							// Vérifier si cet historique existe
							if (!(displayContainer in _historyOnContainers))
							{
								// Il n'existe pas donc on le créé
								_historyOnContainers[displayContainer] = new <BootstrapAction>[];
							}
							
							// On ajoute cette action à l'historique de ce container
							(_historyOnContainers[displayContainer] as Vector.<BootstrapAction>).push(bootstrapAction);
							
							// Si le controller est déjà démarré
							if (calledController.turningOn || calledController.started)
							{
								// On signale directement
								_onHistoryAdded.dispatch(displayContainer, calledController, clonedAction);
							}
							else
							{
								// Sinon on attend que le controlleur démarre pour redispatcher
								calledController.onTurningOn.addOnce(function ():void {
									_onHistoryAdded.dispatch(displayContainer, calledController, clonedAction);
								});
							}
						}
					}
				}
			}
			else
			{
				Log.warning("Bootstrap.doAction, Requested action while bootstrap locked, controllers working : " + _totalWorkingControllers + ". Action is waiting.");
				
				// On enregitre cette action comme étant en attente
				_waitingAction = pAction;
			}
		}
		
		/**
		 * Un controlleur a fini son initialisation.
		 * On va vérifier ici si tous nos controlleurs en cours de travail on fini.
		 * Si tout le monde a fini, on peut dévérouiller le bootstrap.
		 * @param	pController : Le controlleur qui a fini de bosser
		 */
		protected function controllerCompleteHandler (pController:IViewController):void
		{
			// Un controlleur de moins
			_totalWorkingControllers --;
			
			// Le supprimer du dico
			delete _workingControllers[pController];
			
			// Signaler qu'un controlleur de moins est en travail
			_onControllerWork.dispatch(_totalWorkingControllers);
			
			// TODO:CHECK DEBUG sur controllerCompleteHandler
			if (_totalWorkingControllers < 0)
			{
				Log.error("FUCKING ERROR IN BOOTSTRAP : Negative working controller number? WTF?", 1);
			}
			
			// Si on est à 0 controlleur et si on est en vérouillage auto
			if (_totalWorkingControllers == 0 && _autoLock)
			{
				// On dévérouille le bootstrap
				unlock(DO_LAST_ACTION_ON_UNLOCK);
			}
		}
		
		/**
		 * Appeler un controlleur sur un container en particulier
		 * @param	pControllerClass : La classe du controlleur à appeler
		 * @param	pDisplayContainer : Le displayContainer avec lequel le controlleur va être associé
		 * @param	pBootstrapAction : L'action bootstrap associée à cet appel (optionnel)
		 * @param	pControllerCompleteHandler : Appelé lorsque le controlleur aura fini son travail (sera initialisé). Peut ne jamais être appelé (controlleur null)
		 * @return : La concrête du controlleur. Peut être null s'il y a déjà un controlleur (actif ou en attente) sur ce container.
		 */
		public function callControllerForContainer (pControllerClass:Class, pDisplayContainer:DisplayObjectContainer, pBootstrapAction:BootstrapAction = null, pControllerCompleteHandler:Function = null):IViewController
		{
			// Le nouveau controlleur (qui va être créé si besoin)
			var newController:IViewController;
			
			// Le controlleur actuel (s'il y en a un)
			var currentController:IViewController;
			
			// Le controlleur en attente (s'il y en a un)
			var waitingController:IViewController;
			
			// Si la classe du container est null
			if (pControllerClass == null)
			{
				// On déclanche une erreur et on arrête la méthode
				throw new SwappError("Bootstrap.callControllerForContainer", "pControllerClass can't be null");
				return newController;
			}
			
			// Si le displayContainer est null
			if (pDisplayContainer == null)
			{
				// On déclanche une erreur et on arrête la méthode
				throw new SwappError("Bootstrap.callControllerForContainer", "pDisplayContainer is null");
				return newController;
			}
			
			// Vérifier si on a déjà un controlleur sur ce container
			if (pDisplayContainer in _controllersOnContainers)
			{
				// Cibler ce controlleur
				currentController = _controllersOnContainers[pDisplayContainer] as IViewController;
				
				// Si on a une action et si cette action autorise la réutilisation d'un controlleur en cours
				if (pBootstrapAction != null && pBootstrapAction.contextAllowActionRecall)
				{
					// On regarde si ce controlleur à la même signature que celui que l'on veut instancier
					if (getQualifiedClassName(currentController) == getQualifiedClassName(pControllerClass))
					{
						Log.notice("Bootstrap.callControllerForContainer, the same controller is called, action recall on the same controller alowed.");
						
						// Appeler l'action sur le controlleur si on a une action
						if (pBootstrapAction != null)
							(currentController as IActionable).doAction(pBootstrapAction);
						
						// Ils ont le même nom de classe alors on n'a pas besoin d'instancier le nouveau controlleur
						// On arrête l'exécution
						return newController;
					}
				}
			}
			
			// Créer le nouveau controlleur
			newController = dependencesManager.instanciate(pControllerClass) as IViewController;
			
			///////////////////////// AUTO LOCK /////////////////////// 
			// TODO: Essayer de faire un autoLock qui puisse vérouiller par container.
			
			// On le compte comme étant en travail
			_totalWorkingControllers ++;
			
			// Enregistrer ce controlleur comme étant en travail
			_workingControllers[newController] = true;
			
			// Signaler qu'un controlleur de plus est en travail
			_onControllerWork.dispatch(_totalWorkingControllers);
			
			// Si on est en autolock et si on a une action
			if (_autoLock && pBootstrapAction != null)
			{
				// On vérouille car on a une action qui est en cours
				lock();
			}
			
			//
			////////////////////////////////////////////////////////////
			
			// Si on a un controlleur actuel, on doit le détruire
			if (currentController != null)
			{
				// Vérifier si selon le contexte on doit attendre la destruction du controlleur actuel
				if (pBootstrapAction.contextOverlayedTransition)
				{
					// Supprimer le controlleur actuel
					removeControllerFromContainer(currentController, pDisplayContainer, pBootstrapAction, function (pDisplayContainer:DisplayObjectContainer, pBootstrapAction:BootstrapAction):void
					{
						// Et activer le nouveau sur le turningOff
						addControllerToContainer(newController, pDisplayContainer, pBootstrapAction, pControllerCompleteHandler);
					});
				}
				else
				{
					// Supprimer le controlleur actuel
					removeControllerFromContainer(currentController, pDisplayContainer, pBootstrapAction, null, function (pDisplayContainer:DisplayObjectContainer, pBootstrapAction:BootstrapAction):void
					{
						// Puis activer le nouveau sur le turnedOff
						addControllerToContainer(newController, pDisplayContainer, pBootstrapAction, pControllerCompleteHandler);
					});
				}
			}
			else
			{
				// Ajouter directement le nouveau controller au container
				addControllerToContainer(newController, pDisplayContainer, pBootstrapAction, pControllerCompleteHandler);
			}
			
			// Retourner le nouveau controlleur
			return newController;
		}
		
		/**
		 * Un container a été supprimé de la displayList
		 * @param	event
		 */
		protected function containerRemovedHandler (event:Event):void
		{
			// Si ce container a un historique
			if (event.currentTarget in _historyOnContainers)
			{
				// Supprimer l'historique
				delete _historyOnContainers[event.currentTarget];
			}
			
			// Ne plus écouter les suppressions de ce container
			(event.currentTarget as DisplayObjectContainer).removeEventListener(Event.REMOVED_FROM_STAGE, containerRemovedHandler);
			
			// Si un controlleur est actif
			if (event.currentTarget in _controllersOnContainers)
			{
				// Cibler le controller qui va dégager
				var controller:IViewController = _controllersOnContainers[event.currentTarget];
				
				// Si ce controller est en travail
				if (controller in _workingControllers)
				{
					// Alors il ne bosser plus, on peut dévérouiller
					controllerCompleteHandler(controller);
				}
				
				// Supprimer l'association du container et du controlleur
				delete _controllersOnContainers[event.currentTarget];
				
				// Disposer le controlleur
				(controller as IDisposable).dispose();
				
				// Signaler qu'un controlleur est supprimé d'un container
				_onContainerRemoveController.dispatch(event.currentTarget as DisplayObjectContainer, controller, null);
			}
		}
		
		/**
		 * Supprimer un controlleur d'un container.
		 * @param	pController : Le controlleur à supprimer
		 * @param	pDisplayContainer : Le container avec lequel le controlleur est associé
		 * @param	pBootstrapAction : L'action bootstrap qui a entraîné cette suppression. Optionnel.
		 * @param	pTurningOffHandler : Handler appelé lorsque le controlleur commence son arrêt (les paramètres seront [pDisplayContainer:DisplayObjectContainer, pBootstrapAction:BootstrapAction])
		 * @param	pTurnedOffHandler : Handler appelé lorsque le controlleur est arrêté, optionnel (les paramètres seront [pDisplayContainer:DisplayObjectContainer, pBootstrapAction:BootstrapAction])
		 */
		protected function removeControllerFromContainer (pController:IViewController, pDisplayContainer:DisplayObjectContainer, pBootstrapAction:BootstrapAction = null, pTurningOffHandler:Function = null, pTurnedOffHandler:Function = null):void
		{
			// Ecouter lorsque le controlleur s'arrête
			pController.onTurnedOff.addOnce(function ():void
			{
				// Disposer le controlleur
				(pController as IDisposable).dispose();
				
				// TODO: Signal une fois qu'un controlleur est complètement supprimé (passer pDisplayContainer et pController en params)
				
				// Ractiver l'interactivité
				pDisplayContainer.mouseEnabled = true;
				pDisplayContainer.mouseChildren = true;
				
				// Si on a un turnOffHandler
				if (pTurnedOffHandler != null)
				{
					// Relayer au handler en lui passant le displayContainer et l'action bootstrap
					pTurnedOffHandler.apply(this, [pDisplayContainer, pBootstrapAction]);
				}
			});
			
			// Si on a un handler pour le turningOff
			if (pTurningOffHandler != null)
			{
				// Ecouter le controlleur
				pController.onTurningOff.addOnce(function ():void
				{
					// Et relayer au handler
					pTurningOffHandler.apply(this, [pDisplayContainer, pBootstrapAction]);
				});
			}
			
			// Désactiver l'interactivité
			pDisplayContainer.mouseEnabled = false;
			pDisplayContainer.mouseChildren = false;
			
			// Ne plus écouter les suppressions de ce container
			pDisplayContainer.removeEventListener(Event.REMOVED_FROM_STAGE, containerRemovedHandler);
			
			// Supprimer l'association du container et du controlleur
			delete _controllersOnContainers[pDisplayContainer];
			
			// Arrêter
			pController.turnOff(pBootstrapAction != null ? pBootstrapAction.contextInfos : null);
		}
		
		/**
		 * Ajouter un nouveau controlleur à un container
		 * @param	pController : L'instance du nouveau controlleur
		 * @param	pDisplayContainer : Le container
		 * @param	pBootstrapAction : L'action bootstrap qui à entraîné cet ajout. Optionnel.
		 * @param	pTurnedOnHandler : Handler appelé lorsque le controlleur est démarré, optionnel (les paramètres seront [pDisplayContainer:DisplayObjectContainer, pBootstrapAction:BootstrapAction])
		 */
		protected function addControllerToContainer (pController:IViewController, pDisplayContainer:DisplayObjectContainer, pBootstrapAction:BootstrapAction = null, pTurnedOnHandler:Function = null):void
		{
			// Ecouter lorsque le controlleur est démarré
			pController.onTurnedOn.addOnce(function ():void
			{
				// Signaler que ce controlleur n'est plus en train de travailler
				controllerCompleteHandler(pController);
				
				// Ractiver l'interactivité
				pDisplayContainer.mouseEnabled = true;
				pDisplayContainer.mouseChildren = true;
				
				// Si on a un handler
				if (pTurnedOnHandler != null)
				{
					// Relayer au handler en lui passant le container et l'action bootstrap
					pTurnedOnHandler.apply(this, [pDisplayContainer, pBootstrapAction]);
				}
			});
			
			// Désactiver l'interactivité
			pDisplayContainer.mouseEnabled = false;
			pDisplayContainer.mouseChildren = false;
			
			// Enregistrer l'association entre le controlleur et le displayContainer dans le dico
			_controllersOnContainers[pDisplayContainer] = pController;
			
			// Passer le viewContainer au controller
			pController.viewContainer = pDisplayContainer;
			
			// Le controlleur est prêt
			pController.init();
			
			// Démarrer le controlleur en lui passant le contexte, si disponible
			if (pBootstrapAction != null)
			{
				// Appeler l'action sur le controlleur si on a une action
				(pController as IActionable).doAction(pBootstrapAction);
			}
			
			// Démarrer
			pController.turnOn(pBootstrapAction != null ? pBootstrapAction.contextInfos : null);
			
			// Ecouter les suppression de ce container
			pDisplayContainer.addEventListener(Event.REMOVED_FROM_STAGE, containerRemovedHandler);
		}
		
		/**
		 * Dissocier un controlleur d'un container.
		 * Le controlleur sera désactivé proprement (turnOff puis dispose), puis le container sera débarassé.
		 * Un des 2 paramètres suffit étant donné qu'un controlleur ne peut avoir qu'un container et vice versa.
		 * @param	pController : Le controlleur à dissocier
		 * @param	pDisplayContainer : Le container à dissocier
		 * @param	pBootstrapAction : L'action associée a cette désactivation (peut contenir des informations sur le contexte). Optionnel, ne sera pas dispatché.
		 * @param	pCompleteHandler : Handler appelé une fois que le controlleur est bien désactivé, optionnel (les paramètres seront [pDisplayContainer:DisplayObjectContainer, pBootstrapAction:BootstrapAction])
		 */
		public function detachController (pController:IViewController = null, pDisplayContainer:DisplayObjectContainer = null, pBootstrapAction:BootstrapAction = null, pCompleteHandler:Function = null):void
		{
			// Si le controlleur et le container sont null
			if (pController == null && pDisplayContainer == null)
			{
				// On ne peut rien faire, le développeur se fout de notre gueule :)
				throw new SwappError("Bootstrap.detachController", "pController or pDisplayContainer can't be null, at less 1 of those :)");
				return;
			}
			
			// Sinon si on a juste un controlleur
			else if (pController != null && pDisplayContainer == null)
			{
				// Récupérer le container grâce au controlleur
				pDisplayContainer = getContainerFromController(pController);
			}
			
			// Sinon si on a juste le container
			else if (pController == null && pDisplayContainer != null)
			{
				// Récupérer le controlleur grâce au container
				pController = getControllerFromContainer(pDisplayContainer);
			}
			
			// Vérifier si un de nos éléments est null
			if (pController == null || pDisplayContainer == null)
			{
				// On ne peut rien faire, message d'erreur, arrêt
				throw new SwappError("Bootstrap.detachController", "Can't auto find pController or pDisplayContainer. Does this controller really active on bootstrap?");
				return;
			}
			
			// Vérifier si notre controlleur correspond bien à notre container
			if (_controllersOnContainers[pDisplayContainer] != pController)
			{
				// Ca ne correspond pas, message d'erreur, arrêt
				throw new SwappError("Bootstrap.detachController", "pController and pDisplayContainer don't match.");
				return;
			}
			
			// Après toutes ces vérifications on peut enfin supprimer
			removeControllerFromContainer(pController, pDisplayContainer, pBootstrapAction, null, pCompleteHandler);
		}
		
		/**
		 * Tuer immédiatement le controller d'un container. La méthode turnOff ne sera pas appelée
		 * @param	pDisplayContainer : Le displayContainer qui contient le controller à supprimer. Le delegate sera utilisé si null.
		 */
		public function killCurrentController (pDisplayContainer:DisplayObjectContainer):void
		{
			// Si on n'a pas de displayContainer mais un delegate
			if (pDisplayContainer == null && _delegate != null)
			{
				// On demande le displayContainer par défaut au delegate
				pDisplayContainer = _delegate.getDefaultDisplayContainer(null);
			}
			
			// Si on n'a toujours pas de displayContainer
			if (pDisplayContainer == null)
			{
				// On lève une erreur et on arrête la méthode
				throw new SwappError("Bootstrap.getLastActionForContainer", "pDisplayContainer is null and delegate don't give default displayContainer.");
				return null;
			}
			
			// Récupérer le controlleur grâce au container
			var controller:IViewController = getControllerFromContainer(pDisplayContainer);
			
			// Si on a trouvé un controller
			if (controller != null)
			{
				// Supprimer l'association du container et du controlleur
				delete _controllersOnContainers[pDisplayContainer];
				
				// Disposer le controlleur
				controller.dispose();
				
				// Signaler qu'un controlleur est supprimé d'un container
				_onContainerRemoveController.dispatch(pDisplayContainer, controller, null);
			}
			else
			{
				throw new SwappError("Bootstrap.killCurrentController", "No controller found on this displayContainer.");
				return;
			}
		}
		
		/**
		 * Savoir si un container a un controlleur associé
		 * @param	pDisplayContainer : Le container en question
		 */
		public function hasController (pDisplayContainer:DisplayObjectContainer):Boolean
		{
			return _controllersOnContainers[pDisplayContainer] != null;
		}
		
		/**
		 * Savoir si un controlleur est instancié sur un displayContainer
		 * @param	pController : Le controlleur en question
		 */
		public function hasContainer (pController:IViewController):Boolean
		{
			for each (var controller:IViewController in _controllersOnContainers)
			{
				if (controller == pController)
					return true;
			}
			
			return false;
		}
		
		/**
		 * Récupérer le container d'un controlleur
		 * @param	pController : Le controller associé au container
		 * @return : Le container associé au controller
		 */
		public function getContainerFromController (pController:IViewController):DisplayObjectContainer
		{
			for (var container:* in _controllersOnContainers)
			{
				if (_controllersOnContainers[container] == pController)
					return container as DisplayObjectContainer;
			}
			
			return null;
		}
		
		/**
		 * Récupérer le controlleur d'un container
		 * @param	pContainer : Le container associé au controlleur
		 * @return : Le controlleur associé au container
		 */
		public function getControllerFromContainer (pContainer:DisplayObjectContainer):IViewController
		{
			return _controllersOnContainers[pContainer] as IViewController;
		}
		
		/**
		 * Vérouiller le bootstrap
		 */
		public function lock ():void
		{
			// Si on n'est pas vérouillé
			if (!_locked)
			{
				// On vérouille le bootstrap
				_locked = true;
				
				// On balance le signal
				_onLocked.dispatch();
			}
		}
		
		/**
		 * Dévérouiller le bootstrap.
		 * @param	pUnlockSystem : -1 pour oublier la dernière action, 0 pour reprendre à la dernière action reçu pendant le lock.
		 */
		public function unlock (pUnlockSystem:int = -1):void
		{
			// Si on était vérouillé
			if (_locked)
			{
				// On dévérouille le bootstrap
				_locked = false;
				
				// Si on a une action en attente
				if (_waitingAction != null)
				{
					// Vérifier le système de vérouillage
					if (pUnlockSystem == DO_LAST_ACTION_ON_UNLOCK)
					{
						// On exécute l'action en attente
						doAction(_waitingAction);
					}
					else if (pUnlockSystem == CANCEL_LAST_ACTION_ON_UNLOCK)
					{
						// On annule l'action en attente
						_waitingAction.cancel();
					}
				}
				
				// Dans tous les cas on supprime la référence de l'action en attente
				_waitingAction = null;
				
				// On balance le signal
				_onUnlocked.dispatch();
			}
		}
		
		/**
		 * Récupérer la dernière action d'un container (peut donc être l'action en cours, l'action sera clonée)
		 * @param	pDisplayContainer : Le displayContainer de l'historique à récupérer. Le delegate sera utilisé si null.
		 */
		public function getLastActionForContainer (pDisplayContainer:DisplayObjectContainer):BootstrapAction
		{
			// Si on n'a pas de displayContainer mais un delegate
			if (pDisplayContainer == null && _delegate != null)
			{
				// On demande le displayContainer par défaut au delegate
				pDisplayContainer = _delegate.getDefaultDisplayContainer(null);
			}
			
			// Si on n'a toujours pas de displayContainer
			if (pDisplayContainer == null)
			{
				// On lève une erreur et on arrête la méthode
				throw new SwappError("Bootstrap.getLastActionForContainer", "pDisplayContainer is null and delegate don't give default displayContainer.");
				return null;
			}
			
			// Vérifier que ce container ai bien un historique
			if (pDisplayContainer in _historyOnContainers)
			{
				// Cibler le vecteur
				var history:Vector.<BootstrapAction> = (_historyOnContainers[pDisplayContainer] as Vector.<BootstrapAction>);
				
				// Vérifier que l'historique possède au moins un élément
				if (history.length > 0)
				{
					// Récupérer le dernier élément et le cloner
					return history[Math.max(0, history.length - 1)].clone() as BootstrapAction;
				}
				else
				{
					// Historique vide
					return null;
				}
			}
			else
			{
				// Pas d'historique
				return null;
			}
		}
		
		/**
		 * Supprimer l'historique d'un container
		 * @param	pDisplayContainer : Le displayContainer de l'historique à supprimer. Le delegate sera utilisé si null.
		 */
		public function deleteHistoryForContainer (pDisplayContainer:DisplayObjectContainer):void
		{
			// Si on n'a pas de displayContainer mais un delegate
			if (pDisplayContainer == null && _delegate != null)
			{
				// On demande le displayContainer par défaut au delegate
				pDisplayContainer = _delegate.getDefaultDisplayContainer(null);
			}
			
			// Si on n'a toujours pas de displayContainer
			if (pDisplayContainer == null)
			{
				// On lève une erreur et on arrête la méthode
				throw new SwappError("Bootstrap.hasHistory", "pDisplayContainer is null and delegate don't give default displayContainer.");
				return;
			}
			
			// Supprimer
			delete _historyOnContainers[pDisplayContainer];
		}
		
		/**
		 * Supprimer tout l'historique
		 * @param	pButContainer : Un container dont on veut garder l'historique
		 */
		public function deleteHistoryForAllContainers (pButContainer:DisplayObjectContainer = null):void
		{
			// L'historique du container dont on ne veut pas supprimer l'historique
			var historyForContainer:Vector.<BootstrapAction>;
			
			// Si on a un container dont on ne veut pas supprimer l'historique
			if (pButContainer != null)
			{
				// On récupère cet historique
				historyForContainer = getHistory(pButContainer);
			}
			
			// On recréé le dico (pour tout vider)
			_historyOnContainers = new Dictionary(true);
			
			// Si on a récupérer un historique a garder
			if (historyForContainer != null)
			{
				// On l'ajoute
				_historyOnContainers[pButContainer] = historyForContainer;
			}
		}
		
		/**
		 * Savoir si l'historique d'un container possède une action
		 * @param	pDisplayContainer : Le displayContainer de l'historique à récupérer. Le delegate sera utilisé si null.
		 */
		public function hasHistory (pDisplayContainer:DisplayObjectContainer):Boolean
		{
			// Si on n'a pas de displayContainer mais un delegate
			if (pDisplayContainer == null && _delegate != null)
			{
				// On demande le displayContainer par défaut au delegate
				pDisplayContainer = _delegate.getDefaultDisplayContainer(null);
			}
			
			// Si on n'a toujours pas de displayContainer
			if (pDisplayContainer == null)
			{
				// On lève une erreur et on arrête la méthode
				throw new SwappError("Bootstrap.hasHistory", "pDisplayContainer is null and delegate don't give default displayContainer.");
				return;
			}
			
			// Vérifier si on a un historique et vérifier si cet historique possède au moins une action
			return _historyOnContainers[pDisplayContainer] != null && (_historyOnContainers[pDisplayContainer] as Vector.<BootstrapAction>).length > 0;
		}
		
		/**
		 * Récupérer l'historique complet d'un container (sera cloné).
		 * Attention, les actions n'étant pas clonées, l'intégrité de l'historique peut être altérée via l'utilisation de cette méthode.
		 * @param	pDisplayContainer : Le displayContainer de l'historique à récupérer. Le delegate sera utilisé si null.
		 */
		public function getHistory (pDisplayContainer:DisplayObjectContainer):Vector.<BootstrapAction>
		{
			// Si on n'a pas de displayContainer mais un delegate
			if (pDisplayContainer == null && _delegate != null)
			{
				// On demande le displayContainer par défaut au delegate
				pDisplayContainer = _delegate.getDefaultDisplayContainer(null);
			}
			
			// Si on n'a toujours pas de displayContainer
			if (pDisplayContainer == null)
			{
				// On lève une erreur et on arrête la méthode
				throw new SwappError("Bootstrap.getHistory", "pDisplayContainer is null and delegate don't give default displayContainer.");
				return;
			}
			
			// Si l'historique de ce container existe bien
			if (pDisplayContainer in _historyOnContainers)
			{
				// Retourner l'historique
				return (_historyOnContainers[pDisplayContainer] as Vector.<BootstrapAction>).concat();
			}
			else
			{
				// Pas d'historique, on retourne null
				return null;
			}
		}
		
		/**
		 * Récupérer la dernière action d'un historique
		 * @param	pDisplayContainer : Le displayContainer de l'historique à récupérer. Le delegate sera utilisé si null.
		 */
		public function getLastHistoryAction (pDisplayContainer:DisplayObjectContainer):BootstrapAction
		{
			// Si on n'a pas de displayContainer mais un delegate
			if (pDisplayContainer == null && _delegate != null)
			{
				// On demande le displayContainer par défaut au delegate
				pDisplayContainer = _delegate.getDefaultDisplayContainer(null);
			}
			
			// Si on n'a toujours pas de displayContainer
			if (pDisplayContainer == null)
			{
				// On lève une erreur et on arrête la méthode
				throw new SwappError("Bootstrap.getLastHistoryAction", "pDisplayContainer is null and delegate don't give default displayContainer.");
				return null;
			}
			
			// Si l'historique de ce container existe bien
			if (pDisplayContainer in _historyOnContainers)
			{
				// Cibler le vecteur
				var history:Vector.<BootstrapAction> = (_historyOnContainers[pDisplayContainer] as Vector.<BootstrapAction>);
				
				// Si on a au moins un élément
				if (history.length > 0)
				{
					// Récupérer le dernier index et le retourner
					return history[Math.max(0, history.length - 1)];
				}
				else
				{
					// Pas assez d'élément, on retourne null
					return null;
				}
			}
			else
			{
				// Pas d'historique, on retourne null
				return null;
			}
		}
		
		/**
		 * Dépiller le dernier élément de l'historique d'un container.
		 * Les 2 derniers éléments seront dépilés, le dernier sera cloné et retourné.
		 * @param	pDisplayContainer : Le displayContainer de l'historique à récupérer. Le delegate sera utilisé si null.
		 */
		public function popHistory (pDisplayContainer:DisplayObjectContainer):BootstrapAction
		{
			// Si on n'a pas de displayContainer mais un delegate
			if (pDisplayContainer == null && _delegate != null)
			{
				// On demande le displayContainer par défaut au delegate
				pDisplayContainer = _delegate.getDefaultDisplayContainer(null);
			}
			
			// Si on n'a toujours pas de displayContainer
			if (pDisplayContainer == null)
			{
				// On lève une erreur et on arrête la méthode
				throw new SwappError("Bootstrap.popHistory", "pDisplayContainer is null and delegate don't give default displayContainer.");
				return null;
			}
			
			// Si l'historique de ce container existe bien et s'il possède une action
			if (pDisplayContainer in _historyOnContainers)
			{
				// Cibler le vecteur
				var history:Vector.<BootstrapAction> = (_historyOnContainers[pDisplayContainer] as Vector.<BootstrapAction>);
				
				// Vérifier qu'on ai au moins 2 éléments dans l'historique (1 pour la page courrante, un pour la page précédente)
				if (history.length > 1)
				{
					// On dépille 2 fois
					// Une fois pour virer l'action en cours
					history.pop();
					
					// Une seconde fois pour récupérer la dernière action (qui est en fait l'avant dernière)
					var bootstrapAction:BootstrapAction = history.pop()//.clone();
					
					// Retourner l'action
					return bootstrapAction;
				}
				else
				{
					// Historique vide
					return null;
				}
			}
			else
			{
				// Rien a dépiler
				return null;
			}
		}
		
		/**
		 * Supprimer le dernière élément de l'historique
		 */
		public function deleteLastActionInHistory (pDisplayContainer:DisplayObjectContainer):void
		{
			// Si on n'a pas de displayContainer mais un delegate
			if (pDisplayContainer == null && _delegate != null)
			{
				// On demande le displayContainer par défaut au delegate
				pDisplayContainer = _delegate.getDefaultDisplayContainer(null);
			}
			
			// Si on n'a toujours pas de displayContainer
			if (pDisplayContainer == null)
			{
				// On lève une erreur et on arrête la méthode
				throw new SwappError("Bootstrap.deleteLastActionInHistory", "pDisplayContainer is null and delegate don't give default displayContainer.");
				return null;
			}
			
			// Si l'historique de ce container existe bien et s'il possède une action
			if (pDisplayContainer in _historyOnContainers)
			{
				// Cibler le vecteur
				var history:Vector.<BootstrapAction> = (_historyOnContainers[pDisplayContainer] as Vector.<BootstrapAction>);
				
				// Si on a au moins un élément
				if (history.length > 0)
				{
					// On vire la dernière action
					history.pop();
				}
			}
		}
		
		/**
		 * Appeler l'action précédente sur un container
		 */
		public function backHistory (pDisplayContainer:DisplayObjectContainer):void
		{
			// Dépiler la dernière action
			var action:BootstrapAction = popHistory(pDisplayContainer);
			
			// Si on a une action
			if (action != null)
			{
				// On l'applique directement
				doAction(action);
			}
		}
		
		/**
		 * Destruction du bootstrap
		 */
		public function dispose ():void
		{
			// Supprimer les références externes
			_dependencesManager = null;
			_delegate = null;
			
			// Vider le tableau des action map
			_mappedActions = null;
			
			// Vider le dico des controlleurs / containers
			_controllersOnContainers = null;
			
			// Vider le dico de l'historique
			_historyOnContainers = null;
			
			// Vider les signaux
			_onAction.removeAll();
			_onContainerAddController.removeAll();
			_onContainerRemoveController.removeAll();
			_onHistoryAdded.removeAll();
			_onControllerWork.removeAll();
			_onLocked.removeAll();
			_onUnlocked.removeAll();
			
			// Supprimer les signaux
			_onAction = null;
			_onContainerAddController = null;
			_onContainerRemoveController = null;
			_onControllerWork = null;
			_onLocked = null;
			_onUnlocked = null;
		}
	}
}