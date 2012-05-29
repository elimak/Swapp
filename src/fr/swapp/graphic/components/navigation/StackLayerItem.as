package fr.swapp.graphic.components.containers.stacks 
{
	import fr.swapp.core.bootstrap.BootstrapAction;
	import fr.swapp.utils.ObjectUtils;
	
	/**
	 * Une couche dans un container stack
	 * @author ZoulouX
	 */
	public class StackLayerItem implements IStackLayerItem
	{
		/**
		 * Supprimer les éléments déselectionnés
		 */
		public static const REMOVE_POLICY					:String 			= "removePolicy";
		
		/**
		 * Masquer les éléments déselectionnés
		 */
		public static const HIDE_POLICY						:String 			= "hidePolicy"
		
		
		/**
		 * L'action déclanchée à la séléction d'un index
		 */
		protected var _action								:BootstrapAction;
		
		/**
		 * Le type de destruction de cette couche
		 */
		protected var _destructionPolicy					:String				= HIDE_POLICY;
		
		
		/**
		 * L'action déclanchée à la séléction d'un index
		 */
		public function get action ():BootstrapAction { return _action; }
		public function set action (value:BootstrapAction):void 
		{
			_action = value;
		}
		
		/**
		 * Le type de destruction de cette couche
		 */
		public function get destructionPolicy ():String { return _destructionPolicy; }
		public function set destructionPolicy (value:String):void 
		{
			_destructionPolicy = value;
		}
		
		
		/**
		 * Constructeur
		 */
		public function StackLayerItem (pData:Object = null)
		{
			ObjectUtils.extra(this, pData);
		}
	}
}