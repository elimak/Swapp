package fr.swapp.graphic.styles 
{
	import fr.swapp.utils.ObjectUtils;
	/**
	 * ...
	 * @author ZoulouX
	 */
	public class StyleData implements IStyleData 
	{
		/**
		 * Style data
		 */
		protected var _styleData:Object = {};
		
		/**
		 * Get style data
		 */
		public function get styleData ():Object { return _styleData; }
		
		
		/**
		 * Useless constructor
		 */
		public function StyleData () { }
		
		
		/**
		 * Internal style setter (usefull when added via overrided constructor)
		 */
		protected function setData (pData:Object):void
		{
			_styleData = pData;
		}
		
		/**
		 * Add data if you extend another style class
		 */
		protected function appendData (pData:Object):void
		{
			ObjectUtils.extra(_styleData, pData);
		}
	}
}