package fr.swapp.graphic.document
{
	/**
	 * @author ZoulouX
	 */
	public class SExternalCommands
	{
		/**
		 * Android commands
		 */
		public static const BACK_COMMAND			:String 			= "back";
		public static const MENU_COMMAND			:String 			= "menu";
		public static const SEARCH_COMMAND			:String 			= "search";
		
		/**
		 * Activation / deactivation
		 */
		public static const ACTIVATE_COMMAND		:String 			= "activate";
		public static const DEACTIVATE_COMMAND		:String 			= "deactivate";
		
		/**
		 * Quitting application
		 */
		public static const SUSPEND_COMMAND			:String 			= "suspend";
		public static const EXITING_COMMAND			:String 			= "exiting";
		
		/**
		 * Network
		 */
		public static const NETWORK_CHANGE_COMMAND	:String 			= "networkChange";
		
		/**
		 * User
		 */
		public static const USER_IDLE_COMMAND		:String 			= "userIdle";
		public static const USER_PRESENT_COMMAND	:String 			= "userPresent";
		
		/**
		 * External invoke
		 */
		public static const INVOKE_COMMAND			:String 			= "invoke";
	}
}