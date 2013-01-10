package fr.swapp.core.actions 
{
	import fr.swapp.utils.ObjectUtils;
	
	/**
	 * @author ZoulouX
	 */
	public class Action implements IAction
	{
		/**
		 * Créer une action de base. Si aucune classe concrête n'est passée en paramètres, une action de base sera créée
		 * @param	pActionName : Le nom de l'action
		 * @param	pParams : Les paramètres associées
		 * @param	pContextInfos : Les infos sur le contexte de l'action
		 * @param	pConcreteClass : La classe de cette action concrête
		 * @return : L'action de base
		 */
		public static function make (pActionName:String, pParams:Object = null, pContextInfos:Object = null, pConcreteClass:Class = null):IAction
		{
			// Si on n'a pas de concrête
			if (pConcreteClass == null)
			{
				// On utilise  la classe de base
				pConcreteClass = Action;
			}
			
			// On créé la concrête et on la retourne
			return new pConcreteClass (pActionName, pParams, pContextInfos) as IAction;
		}
		
		
		/**
		 * Le nom de l'action, pour être identifié
		 */
		protected var _name							:String;
		
		/**
		 * Les paramètres associées à cette action
		 */
		protected var _params						:Object;
		
		/**
		 * Les informations sur le contexte de cette action
		 */
		protected var _contextInfos					:Object;
		
		/**
		 * Si l'action est annulée
		 */
		protected var _canceled						:Boolean				= false;
		
		/**
		 * Les informations sur l'état de cette action
		 */
		protected var _stateInfos					:Object					= {};
		
		
		/**
		 * Le nom de l'action, pour être identifié
		 */
		public function get name ():String { return _name }
		
		/**
		 * Les paramètres associés à cette action
		 */
		public function get params ():Object { return _params }
		
		/**
		 * Les informations sur le contexte de cette action
		 */
		public function get contextInfos ():Object { return _contextInfos }
		
		/**
		 * Si l'action est annulée
		 */
		public function get canceled ():Boolean { return _canceled }
		
		/**
		 * Les informations sur l'état de cette action
		 */
		public function get stateInfos ():Object { return _stateInfos; }
		public function set stateInfos (value:Object):void
		{
			_stateInfos = value;
		}
		
		
		/**
		 * Le constructeur de l'action
		 * @param	pActionName : Le nom de l'action
		 * @param	pParams : Les paramètres associées
		 * @param	pContextInfos : Les infos sur le contexte de l'action
		 * @param	pStateInfos : Les infos sur l'état
		 */
		public function Action (pName:String, pParams:Object = null, pContextInfos:Object = null, pStateInfos:Object = null)
		{
			// Enregistrer les paramètres
			_name = pName;
			_params = (pParams == null ? {} : pParams);
			_contextInfos = (pContextInfos == null ? { } : pContextInfos);
			
			if (pStateInfos != null)
				_stateInfos = pStateInfos;
		}
		
		/**
		 * Annuler l'action
		 */
		public function cancel ():void
		{
			_canceled = true;
		}
		
		/**
		 * Cloner l'action. Le statut d'annulation ne sera pas cloné.
		 */
		public function clone (pBaseParams:Object = null, pBaseContextInfos:Object = null):IAction
		{
			return new Action(_name, ObjectUtils.extra(pBaseParams, _params), ObjectUtils.extra(pBaseContextInfos, _contextInfos), _stateInfos);
		}
	}
}