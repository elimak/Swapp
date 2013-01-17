package fr.swapp.core.bootstrap 
{
	import flash.display.DisplayObjectContainer;
	import fr.swapp.core.actions.Action;
	import fr.swapp.core.actions.IAction;
	import fr.swapp.utils.ObjectUtils;
	
	/**
	 * Une action de bootstrap. Permet de récupérer de manière standardisée le displayContainer et le type d'animation depuis le context.
	 * @author ZoulouX
	 */
	public class BootstrapAction extends Action
	{
		/**
		 * Créer une BootstrapAction.
		 * @param	pActionName : Le nom de l'action
		 * @param	pParams : Les paramètres associées
		 * @param	pContextInfos : Les infos sur le contexte de l'action
		 * @param	pConcreteClass : La classe de cette action concrête
		 */
		public static function make (pActionName:String, pParams:Object = null, pContextInfos:Object = null):BootstrapAction
		{
			// On créé la concrête et on la retourne
			return Action.make(pActionName, pParams, pContextInfos, BootstrapAction) as BootstrapAction;
		}
		
		/**
		 * Le displayContainer depuis le contexte de l'action
		 */
		public function get contextDisplayContainer ():DisplayObjectContainer
		{
			return ("displayContainer" in _contextInfos && _contextInfos["displayContainer"] is DisplayObjectContainer) ? _contextInfos["displayContainer"] as DisplayObjectContainer : null;
		}
		public function set contextDisplayContainer (value:DisplayObjectContainer):void
		{
			_contextInfos["displayContainer"] = value;
		}
		
		/**
		 * La transition depuis le contexte de l'action
		 */
		public function get contextTransition ():Object
		{
			return "transition" in _contextInfos ? _contextInfos["transition"] : null;
		}
		public function set contextTransition (value:Object):void
		{
			_contextInfos["transition"] = value;
		}
		
		/**
		 * Si l'animation du nouveau contenu sera superposée à l'animation de l'ancien contenu.
		 * False par défaut si on n'a pas de transition, true par défaut si on a une transition
		 */
		public function get contextOverlayedTransition ():Boolean
		{
			return ("overlayedTransition" in _contextInfos && _contextInfos["overlayedTransition"] is Boolean ? _contextInfos["overlayedTransition"] as Boolean : _contextInfos["transition"] != null);
		}
		public function set contextOverlayedTransition (value:Boolean):void
		{
			_contextInfos["overlayedTransition"] = value;
		}
		
		/**
		 * Si cette action permet d'utiliser le controlleur en cours plutôt qu'un nouveau (false par défaut)
		 */
		public function get contextAllowActionRecall ():Boolean
		{
			return ("allowActionRecall" in _contextInfos && _contextInfos["allowActionRecall"] is Boolean ? _contextInfos["allowActionRecall"] as Boolean : false);
		}
		public function set contextAllowActionRecall (value:Boolean):void
		{
			_contextInfos["allowActionRecall"] = value;
		}
		
		/**
		 * La direction depuis le contexte de l'action
		 */
		public function get contextDirection ():int
		{
			return ("direction" in _contextInfos && _contextInfos["direction"] is int ? _contextInfos["direction"] as int : 1);
		}
		public function set contextDirection (value:int):void
		{
			_contextInfos["direction"] = value;
		}
		
		/**
		 * Le constructeur de l'action
		 * @param	pActionName : Le nom de l'action
		 * @param	pParams : Les paramètres associées
		 * @param	pContextInfos : Les infos sur le contexte de l'action
		 * @param	pStateInfos : Les infos sur l'état
		 */
		public function BootstrapAction (pName:String, pParams:Object = null, pContextInfos:Object = null, pStateInfos:Object = null)
		{
			// Relayer
			super(pName, pParams, pContextInfos, pStateInfos);
		}
		
		/**
		 * Cloner l'action. Le statut d'annulation ne sera pas cloné.
		 */
		override public function clone (pBaseParams:Object = null, pBaseContextInfos:Object = null):IAction
		{
			return new BootstrapAction(_name, ObjectUtils.extra(pBaseParams, _params), ObjectUtils.extra(pBaseContextInfos, _contextInfos), _stateInfos);
		}
	}	
}