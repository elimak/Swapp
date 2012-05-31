package fr.swapp.graphic.components.navigation.items 
{
	import fr.swapp.utils.ObjectUtils;
	/**
	 * @author ZoulouX
	 */
	public class NavigationStackItem extends StackLayerItem
	{
		/**
		 * Le titre
		 */
		protected var _title							:String;
		
		/**
		 * Si l'item est visible (et donc accessible via le menu)
		 */
		protected var _visible							:Boolean;
		
		
		/**
		 * Le titre
		 */
		public function get title ():String { return _title; }
		public function set title (value:String):void 
		{
			_title = value;
		}
		
		
		/**
		 * Si l'item est visible (et donc accessible via le menu)
		 */
		public function get visible ():Boolean { return _visible };
		public function set visible (value:Boolean):void 
		{
			_visible = value;
		}
		
		
		/**
		 * Le constructeur
		 * @param	pData : Les données de cet objet
		 */
		public function NavigationStackItem (pData:Object = null)
		{
			ObjectUtils.extra(this, pData);
		}
	}
}