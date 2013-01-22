package fr.swapp.graphic.styles 
{
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
	}
}