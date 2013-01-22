package fr.swapp.graphic.base
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.utils.getQualifiedClassName;
	import fr.swapp.core.mvc.IView;
	import fr.swapp.graphic.styles.IStyleData;
	import fr.swapp.utils.ClassUtils;
	
	/**
	 * @author ZoulouX
	 */
	public class SView extends SComponent implements IView
	{
		/**
		 * Style data
		 */
		protected var _styleData							:IStyleData;
		
		
		/**
		 * Get DisplayObject instance of this view
		 */
		public function get displayObject ():DisplayObject { return this; }
		
		
		/**
		 * Constructor
		 */
		public function SView ()
		{
			
		}
		
		
		/**
		 * Set style data class. Will be automatically added at init.
		 */
		protected function setStyle (pStyleDataClass:Class):void
		{
			// Définir le nom de style par le nom de class
			style(ClassUtils.getClassNameFromInstance(this));
			
			// Enregistrer l'instance
			_styleData = new pStyleDataClass as IStyleData;
		}
		
		/**
		 * Initialization
		 */
		override public function init ():void 
		{
			// Appliquer le style si disponible
			if (_styleData != null)
			{
				SWrapper.getInstance(stage).styleCentral.addStyleData(_styleData);
			}
			
			// Relayer
			super.init();
		}
		
		/**
		 * Dispose
		 */
		override public function dispose ():void
		{
			// Supprimer le style si disponible
			if (_styleData != null)
			{
				SWrapper.getInstance(stage).styleCentral.removeStyleData(_styleData);
			}
			
			// Relayer
			super.dispose();
		}
	}
}