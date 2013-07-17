package fr.swapp.graphic.styles 
{
	import fr.swapp.graphic.errors.GraphicalError;
	import fr.swapp.utils.ObjectUtils;
	
	/**
	 * @author ZoulouX
	 */
	public class StyleData implements IStyleData
	{
		/**
		 * Style data
		 */
		protected var _styleData			:Object				= { };
		
		/**
		 * Style base class.
		 */
		protected var _baseClassName		:String				= "";
		
		
		/**
		 * Get style data
		 */
		public function get styleData ():Object { return _styleData; }
		
		/**
		 * Style base class
		 */
		public function get baseClassName ():String { return _baseClassName; }
		public function set baseClassName (value:String):void
		{
			_baseClassName = value;
		}
		
		
		/**
		 * Constructor
		 */
		public function StyleData ()
		{
			
		}
		
		/**
		 * Data initialization
		 */
		public function init ():void
		{
			throw new GraphicalError("StyleData.init", "Please override StyleData.init method to set style data.");
		}
		
		
		/**
		 * Internal style setter (usefull when added via overrided constructor)
		 */
		protected function setData (pData:Object):void
		{
			// Ajouter le nom de la classe de base sur ces sélécteurs
			pData = prependClassName(pData);
			
			// Enregistrer les données
			_styleData = pData;
		}
		
		/**
		 * Add data if you extend another style class
		 */
		protected function appendData (pData:Object):void
		{
			// Ajouter le nom de la classe de base sur ces sélécteurs
			pData = prependClassName(pData);
			
			// Ajouter les données
			ObjectUtils.extra(_styleData, pData, true, true);
		}
		
		/**
		 * Prepend base class name from all selectors
		 */
		protected function prependClassName (pData:Object):Object
		{
			// Le nouveau sélécteur
			var newSelector:String
			
			// Les nouvelles données
			var newData:Object = { };
			
			// Le sélécteur qui va être splitté sur le #
			var splittedSelector:Array;
			
			// Parcourir les données
			for (var i:String in pData)
			{
				// Si on a un dièze
				if (i.indexOf("#") != -1 && _baseClassName != null && _baseClassName != "")
				{
					// Splitter sur le # pour avoir le séparateur en 2 parties
					splittedSelector = i.split("#", 2);
					
					// Remplacer la partie du dièze par le nouveau sélécteur
					newSelector = splittedSelector[0] + "." + _baseClassName + splittedSelector[1];
					
					// Ajouter les données sur ce nouveau sélécteur
					newData[newSelector] = pData[i];
				}
				else
				{
					// Copier la règle sans la modifier
					newData[i] = pData[i];
				}
			}
			
			// Retourner la nouvelle liste de sélécteurs
			return newData;
		}
	}
}