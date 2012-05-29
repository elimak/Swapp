package fr.swapp.graphic.components.controls.menus 
{
	import fr.swapp.graphic.components.controls.buttons.Button;
	
	/**
	 * @author ZoulouX
	 */
	public class MenuBarElement extends Button 
	{
		/**
		 * Le constructeur
		 */
		public function MenuBarElement ()
		{
			_label.multiline = true;
			_label.autoSize = true;
			_label.place(NaN, 0, 1, 0);
		}
	}
}