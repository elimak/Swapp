package fr.swapp.core.mvc
{
	import fr.swapp.core.dependences.IDependencesManager;
	
	/**
	 * @author ZoulouX
	 */
	public interface IAppViewController extends IViewController
	{
		/**
		 * Application dependences manager
		 */
		function get dependencesManager ():IDependencesManager;
		
		/**
		 * Handle external command Document.
		 * @param	pCommand : Command name. On android, "back" and "menu" are sended.
		 * @return : Return true to cancel default behavior.
		 */
		function externalCommand (pCommand:String):Boolean;
	}
}