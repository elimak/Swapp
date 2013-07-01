package fr.swapp.graphic.styles 
{
	/**
	 * ...
	 * @author ZoulouX
	 */
	public interface IStyleData 
	{
		/**
		 * Get style data
		 */
		function get styleData ():Object;
		
		/**
		 * Style base class
		 */
		function get baseClassName ():String;
		function set baseClassName (value:String):void;
		
		/**
		 * Data initialization
		 */
		function init ():void;
	}
}