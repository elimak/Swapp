package fr.swapp.core.actions
{
	import flash.display.DisplayObjectContainer;
	
	/**
	 * @author ZoulouX
	 */
	public class Action implements IAction
	{
		/**
		 * Create an action
		 * @param	pName : Action name (required)
		 * @param	pParams : Action params (optionnal)
		 * @param	pContext : Action context (optionnal)
		 * @param	pContainer : Action container (optionnal)
		 */
		public static function create (pName:String, pParams:Object = null, pContext:Object = null, pContainer:DisplayObjectContainer = null):Action
		{
			// Créer l'action et la retourner
			return new Action(pName, pParams, pContext, pContainer);
		}
		
		/**
		 * Action name
		 */
		protected var _name					:String;
		
		/**
		 * Action context
		 */
		protected var _context				:Object;
		
		/**
		 * Action params
		 */
		protected var _params				:Object;
		
		/**
		 * Action container
		 */
		protected var _container			:DisplayObjectContainer;
		
		
		/**
		 * Action name
		 */
		public function get name ():String { return _name; }
		
		/**
		 * Action context
		 */
		public function get context ():Object { return _context; }
		
		/**
		 * Action params
		 */
		public function get params ():Object { return _params; }
		
		/**
		 * Action container
		 */
		public function get container ():DisplayObjectContainer { return _container; }
		
		
		/**
		 * Constructor.
		 * @param	pName : Action name (required)
		 * @param	pParams : Action params (optionnal)
		 * @param	pContext : Action context (optionnal)
		 * @param	pContainer : Action container (optionnal)
		 */
		public function Action (pName:String, pParams:Object = null, pContext:Object = null, pContainer:DisplayObjectContainer = null)
		{
			// Enregistrer les infos de l'action
			_name = pName;
			_params = pParams;
			_context = pContext;
			_container = pContainer;
		}
	}
}