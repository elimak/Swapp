package fr.swapp.core.actions 
{
	/**
	 * L'interface pour les actions de base
	 * @author ZoulouX
	 */
	public interface IAction
	{
		/**
		 * Le nom de l'action, pour être identifié
		 */
		function get name ():String;
		
		/**
		 * Les paramètres associés à cette action
		 */
		function get params ():Object;
		
		/**
		 * Les informations sur le contexte de cette action
		 */
		function get contextInfos ():Object;
		
		/**
		 * Si l'action est annulée
		 */
		function get canceled ():Boolean;
		
		/**
		 * Les informations sur l'état de cette action
		 */
		function get stateInfos ():Object;
		function set stateInfos (value:Object):void;
		
		/**
		 * Annuler l'action
		 */
		function cancel ():void;
		
		/**
		 * Cloner l'action
		 */
		function clone (pBaseParams:Object = null, pBaseContextInfos:Object = null):IAction;
	}
}