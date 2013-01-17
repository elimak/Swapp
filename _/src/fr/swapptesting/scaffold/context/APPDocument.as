package fr.swapptesting.scaffold.context 
{
	import fr.swapp.core.actions.Action;
	import fr.swapp.graphic.base.StageWrapper;
	
	/**
	 * ...
	 * @author ZoulouX
	 */
	public class APPDocument extends StageWrapper 
	{
		/**
		 * Le bundle principal
		 */
		protected var _bundle					:APPBundle;
		
		/**
		 * Le constructeur
		 */
		public function APPDocument ()
		{
			// Définir les DPI en auto
			setAutoDPI(true);
			
			// Relayer
			super();
		}
		
		
		/**
		 * Initialisation
		 */
		override public function init ():void
		{
			// Créer le bundle principal
			_bundle = new APPBundle(this, new Action(APPActions.DEFAULT_ACTION));
		}
	}
}