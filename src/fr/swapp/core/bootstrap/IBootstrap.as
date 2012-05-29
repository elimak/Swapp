package fr.swapp.core.bootstrap 
{
	import flash.display.DisplayObjectContainer;
	import fr.swapp.core.actions.IActionable;
	import fr.swapp.core.dependences.IDependencesManager;
	import fr.swapp.core.mvc.abstract.IViewController;
	import fr.swapp.core.roles.IDisposable;
	import fr.swapp.core.roles.ILockable;
	import org.osflash.signals.ISignal;
	
	/**
	 * @author ZoulouX
	 */
	public interface IBootstrap extends IDisposable, ILockable, IActionable
	{
		/**
		 * Le delegate associé au bootstrap.
		 * Ce delegate permet de récupérer le displayContainer par défaut.
		 */
		function get delegate ():IBootstrapDelegate;
		function set delegate (value:IBootstrapDelegate):void;
		
		/**
		 * Le manager de dépendances associé au bootstrap.
		 * Le Bootstrap se servira de ce manager pour instancier et injecter les éléments d'architecture de l'application.
		 */
		function get dependencesManager ():IDependencesManager;
		function set dependencesManager (value:IDependencesManager):void;
		
		/**
		 * La liste des actions enregistrées et mappées sur des classes de controlleur
		 */
		function get mappedActions ():Vector.<BootstrapActionMapToController>;
		
		/**
		 * Vérouillage automatique du bootstrap lorsqu'une commande est lancée.
		 * Le bootstrap se dévérouille une fois que tous les controlleurs sont démarrés.
		 */
		function get autoLock ():Boolean;
		function set autoLock (value:Boolean):void;
		
		/**
		 * Le nombre de controlleur qui sont en travail (en démarrage)
		 */
		function get totalWorkingControllers ():int;
		
		/**
		 * Lorsqu'une action est appelée
		 */
		function get onAction ():ISignal;
		
		/**
		 * Lorsque le nombre de controlleur en travail change
		 */
		function get onControllerWork ():ISignal;
		
		/**
		 * Lorsqu'un container a un nouveau controlleur
		 */
		function get onContainerAddController ():ISignal;
		
		/**
		 * Lorsqu'un container perd un controlleur
		 */
		function get onContainerRemoveController ():ISignal;
		
		/**
		 * Un élément à été ajouté dans un historique
		 */
		function get onHistoryAdded ():ISignal;
		
		/**
		 * Lorsque le bootstrap est vérouillé
		 */
		function get onLocked ():ISignal;
		
		/**
		 * Lorsque le bootstrap est dévérouillé
		 */
		function get onUnlocked ():ISignal;
		
		/**
		 * Le contexte par défaut
		 */
		function get defaultContextInfos ():Object;
		function set defaultContextInfos (value:Object):void;
		
		/**
		 * Associer le nom d'une action à un controlleur
		 * @param	pActionName : Le nom de l'action
		 * @param	pControllerClass : La classe du controlleur à instancier
		 * @param	pDefaultParams : Les paramètres par défaut (seront écrasés à l'appel de l'action)
		 * @param	pDefaultContextInfos : Les informations du contexte par défaut (seront écrasés à l'appel de l'action)
		 */
		function mapAction (pActionName:String, pControllerClass:Class, pDefaultParams:Object = null, pDefaultContextInfos:Object = null):void;
		
		/**
		 * Dissocier le nom d'une action à un controlleur
		 * @param	pActionName : Le nom de l'action a détacher
		 * @param	pControllerClass : La classe associée à détacher
		 */
		function unmapAction (pActionName:String, pControllerClass:Class):void;
		
		/**
		 * Appeler un controlleur sur un container en particulier
		 * @param	pControllerClass : La classe du controlleur à appeler
		 * @param	pDisplayContainer : Le displayContainer avec lequel le controlleur va être associé
		 * @param	pBootstrapAction : L'action bootstrap associée à cet appel (optionnel)
		 * @param	pControllerCompleteHandler : Appelé lorsque le controlleur aura fini son travail (sera initialisé). Peut ne jamais être appelé (controlleur null)
		 * @return : La concrête du controlleur. Peut être null s'il y a déjà un controlleur (actif ou en attente) sur ce container.
		 */
		function callControllerForContainer (pControllerClass:Class, pDisplayContainer:DisplayObjectContainer, pBootstrapAction:BootstrapAction = null, pControllerCompleteHandler:Function = null):IViewController;
		
		/**
		 * Dissocier un controlleur d'un container.
		 * Le controlleur sera désactivé proprement (turnOff puis dispose), puis le container sera débarassé.
		 * Un des 2 paramètres suffit étant donné qu'un controlleur ne peut avoir qu'un container et vice versa.
		 * @param	pController : Le controlleur à dissocier
		 * @param	pDisplayContainer : Le container à dissocier
		 * @param	pBootstrapAction : L'action associée a cette désactivation (peut contenir des informations sur le contexte). Optionnel, ne sera pas dispatché.
		 * @param	pCompleteHandler : Handler appelé une fois que le controlleur est bien désactivé, optionnel (les paramètres seront [pDisplayContainer:DisplayObjectContainer, pBootstrapAction:BootstrapAction])
		 */
		function detachController (pController:IViewController = null, pDisplayContainer:DisplayObjectContainer = null, pBootstrapAction:BootstrapAction = null, pCompleteHandler:Function = null):void;
		
		/**
		 * Tuer immédiatement le controller d'un container. La méthode turnOff ne sera pas appelée
		 * @param	pDisplayContainer : Le displayContainer qui contient le controller à supprimer. Le delegate sera utilisé si null.
		 */
		function killCurrentController (pDisplayContainer:DisplayObjectContainer):void;
		
		/**
		 * Savoir si un container a un controlleur associé
		 * @param	pDisplayContainer : Le container en question
		 */
		function hasController (pDisplayContainer:DisplayObjectContainer):Boolean;
		
		/**
		 * Savoir si un controlleur est instancié sur un displayContainer
		 * @param	pController : Le controlleur en question
		 */
		function hasContainer (pController:IViewController):Boolean;
		
		/**
		 * Récupérer le container d'un controlleur
		 * @param	pController : Le controller associé au container
		 * @return : Le container associé au controller
		 */
		function getContainerFromController (pController:IViewController):DisplayObjectContainer;
		
		/**
		 * Récupérer le controlleur d'un container
		 * @param	pContainer : Le container associé au controlleur
		 * @return : Le controlleur associé au container
		 */
		function getControllerFromContainer (pContainer:DisplayObjectContainer):IViewController;
		
		/**
		 * Récupérer la dernière action d'un container (peut donc être l'action en cours, l'action sera clonée)
		 * @param	pDisplayContainer : Le displayContainer de l'historique à récupérer. Le delegate sera utilisé si null.
		 */
		function getLastActionForContainer (pDisplayContainer:DisplayObjectContainer):BootstrapAction;
		
		/**
		 * Supprimer l'historique d'un container
		 * @param	pDisplayContainer : Le displayContainer de l'historique à supprimer. Le delegate sera utilisé si null.
		 */
		function deleteHistoryForContainer (pDisplayContainer:DisplayObjectContainer):void
		
		/**
		 * Supprimer tout l'historique
		 * @param	pButContainer : Un container dont on veut garder l'historique
		 */
		function deleteHistoryForAllContainers (pButContainer:DisplayObjectContainer = null):void
		
		/**
		 * Savoir si l'historique d'un container possède une action
		 * @param	pDisplayContainer : Le displayContainer de l'historique à récupérer. Le delegate sera utilisé si null.
		 */
		function hasHistory (pDisplayContainer:DisplayObjectContainer):Boolean;
		
		/**
		 * Récupérer l'historique complet d'un container (sera cloné).
		 * Attention, les actions n'étant pas clonées, l'intégrité de l'historique peut être altérée via l'utilisation de cette méthode.
		 * @param	pDisplayContainer : Le displayContainer de l'historique à récupérer. Le delegate sera utilisé si null.
		 */
		function getHistory (pDisplayContainer:DisplayObjectContainer):Vector.<BootstrapAction>;
		
		/**
		 * Récupérer la dernière action d'un historique
		 * @param	pDisplayContainer : Le displayContainer de l'historique à récupérer. Le delegate sera utilisé si null.
		 */
		function getLastHistoryAction (pDisplayContainer:DisplayObjectContainer):BootstrapAction;
		
		/**
		 * Dépiller le dernier élément de l'historique d'un container.
		 * Les 2 derniers éléments seront dépilés, le dernier sera cloné et retourné.
		 * @param	pDisplayContainer : Le displayContainer de l'historique à récupérer. Le delegate sera utilisé si null.
		 */
		function popHistory (pDisplayContainer:DisplayObjectContainer):BootstrapAction;
		
		/**
		 * Supprimer le dernière élément de l'historique
		 */
		function deleteLastActionInHistory (pDisplayContainer:DisplayObjectContainer):void;
		
		/**
		 * Appeler l'action précédente sur un container
		 */
		function backHistory (pDisplayContainer:DisplayObjectContainer):void;
	}
}