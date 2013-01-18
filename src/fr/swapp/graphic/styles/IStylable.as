package fr.swapp.graphic.styles 
{
	/**
	 * Stylable objects.
	 * @author ZoulouX
	 */
	public interface IStylable
	{
		/**
		 * If styles are enabled for this component.
		 * Disabled by default for performances.
		 */
		function get styleName ():String;
		function set styleName (value:String):void;
		
		/**
		 * Get the parent stylable object.
		 */
		function get parentStylable ():IStylable;
	}
}