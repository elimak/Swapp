package fr.swapp.core.actions
{
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
		 */
		public static function create (pName:String, pParams:Object = null, pContext:Object = null):Action
		{
			// Créer l'action et la retourner
			return new Action(pName, pParams, pContext);
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
		 * Constructor.
		 * @param	pName : Action name (required)
		 * @param	pParams : Action params (optionnal)
		 * @param	pContext : Action context (optionnal)
		 */
		public function Action (pName:String, pParams:Object = null, pContext:Object = null)
		{
			// Enregistrer les infos de l'action
			_name = pName;
			_params = pParams;
			_context = pContext;
		}
	}
}