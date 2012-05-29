package fr.swapp.core.display 
{
	/**
	 * Imports
	 */
	import flash.display.DisplayObject;
	import fr.swapp.core.display.IDisplayObject;
	import fr.swapp.core.roles.IDisposable;
	import fr.swapp.core.roles.IInitializable;
	
	/**
	 * L'interface DisplayObjet
	 * @author ZoulouX
	 */
	public interface IMasterDisplayObject extends IDisplayObject, IInitializable, IDisposable
	{
		/**
		 * Si on doit l'initialiser automatiquement à l'ajout sur la scène
		 */
		function get autoInit ():Boolean;
		function set autoInit (pValue:Boolean):void;
		
		/**
		 * Si on doit disposer automatiquement à la suppression du clip de la scène
		 */
		function get autoDispose ():Boolean;
		function set autoDispose (pValue:Boolean):void;
	}	
}