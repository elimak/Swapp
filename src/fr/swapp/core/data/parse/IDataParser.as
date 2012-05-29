package fr.swapp.core.data.parse 
{
	
	/**
	 * @author ZoulouX
	 */
	public interface IDataParser 
	{
		/**
		 * Récupérer les items à parser.
		 * Attention, ce tableau est associatif.
		 */
		function get items ():Array;
		
		/**
		 * Récupérer la liste des adapteurs.
		 * Attention, ce tableau est associatif.
		 */
		function get adapters ():Array;
		
		/**
		 * Parser en mode strict ou normal.
		 * En mode stricte, la méthode parse pourra retourner des erreurs et s'arrêter.
		 */
		function get strict ():Boolean;
		function set strict (pValue:Boolean):void;
		
		/**
		 * Ajouter un élément IDataItem à parser
		 * @param	pItemName : Le nom des items à parser
		 * @param	pItemClass : La classe de l'item à parser
		 */
		function addItemType (pItemName:String, pItemClass:Class, pAdapters:Object = null):void;
		
		/**
		 * Effacer un item par son nom.
		 * @param	pItemName : Le nom de l'item
		 */
		function removeItemType (pItemName:String):void;
		
		/**
		 * Parser des données brutes en données exploitables par les collections.
		 * @param	pData : Les données brutes
		 * @param	pClass : La classe de transfert, ne pas prendre en compte lors d'une utilisation publique de la méthode.
		 * @return : Les données parsées selon la classe de tranfert.
		 */
		function parse (pData:*, pClass:Class = null):*;
	}
}