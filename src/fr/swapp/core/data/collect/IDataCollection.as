package fr.swapp.core.data.collect 
{
	/**
	 * Les imports
	 */
	import fr.swapp.core.data.items.IDataItem;
	import fr.swapp.core.data.managers.IDataIterator;
	import fr.swapp.core.roles.IChangeable;
	import fr.swapp.core.roles.ILockable;
	
	/**
	 * L'interface du DataCollection.
	 * @author ZoulouX
	 */
	public interface IDataCollection extends ICollection, IChangeable, ILockable
	{
		/**
		 * Récupérer le tableau des données.
		 * Attention, aucune copie n'est générée, le tableau modifé à l'extérieur modifira donc le tableau interne
		 * à la collection.
		 */
		function get data ():Array;
		
		/**
		 * Le type de IDataItem forcé.
		 */
		function get dataType ():Class;
		function set dataType (pValue:Class):void;
		
		/**
		 * Récupérer tous les éléments sous forme de tableau indexé.
		 * Ce tableau est une copie du tableau interne à la collection.
		 * Les éléments stockés ne sont pas copié.
		 */
		function get all ():Array;
		
		/**
		 * Récupérer le premier élément
		 */
		function get first ():IDataItem;
		
		/**
		 * Récupérer le dernier élément
		 */
		function get last ():IDataItem;
		
		/**
		 * Récupérer l'itérator
		 */
		function get iterator ():IDataIterator;
		
		/**
		 * Récupérer un élément à un index donné
		 * @param	pIndex : L'index de l'élément à récupérer
		 * @return : L'élément de type IDataItem
		 */
		function getItem (pIndex:uint):IDataItem;
		
		/**
		 * Savoir si un élément est contenu dans la collection
		 * @param	pDataItem : L'item en question
		 * @return : true si l'élément à été trouvé
		 */
		function contains (pDataItem:IDataItem):Boolean;
		
		/**
		 * Ajouter un élément dans la collection
		 */
		function add (pDataItem:IDataItem):void;
		
		/**
		 * Ajouter un tableau d'éléments à la collection
		 * @param	pData : Le tableau d'éléments IDataItem
		 */
		function addAll (pData:Array):void;
		
		/**
		 * Ajouter un élément à un endroit spécifique de la collection
		 */
		function addAt (pDataItem:IDataItem, pAt:uint = 0):void;
		
		/**
		 * Effacer un élément de la collection
		 * @param	pDataItem : L'item qui doit être supprimé
		 */
		function remove (pDataItem:IDataItem):void;
		
		/**
		 * Effacer un élément par son index
		 * @param	pAt : L'index qui doit être supprimé
		 */
		function removeAt (pAt:uint):void;
		
		/**
		 * Vider la collection
		 */
		function clear ():void;
		
		/**
		 * Appèle une méthode sur chaque élément de cette collection.
		 * La méthode doit accueillr les paramètres suivants :
		 * 1. Récéption du IDataItem
		 * 2. Récéption de l'index
		 * Les paramètres optionnels seront ajoutés aux paramètres de la méthode.
		 * Par exemple, si vous faites:
		 * myCollection.forEach(myHandler, myCollection);
		 * 
		 * Il faut que votre handler ai cette signature:
		 * public function myHandler (pItem:IDataItem, pIndex:uint, pCollection:DataCollection = null):void
		 * 
		 * @param	pHandler : La méthode appelée pour chaque élément.
		 * @param	pParams : Les paramètres en plus des 2 obligatoires.
		 */
		function forEach (pHandler:Function, pParams:Array = null):void;
		
		/**
		 * Trier la collection selon un ou plusieurs champs des items.
		 * @param	pFields : Les champs à trier. Ce tableau doit être composé de string uniquement. ex: ['id', 'name']
		 * @param	pAscending : L'ordre de tri. Par défaut l'ordre est ascendant (le plus bas en premier)
		 * @param	pCaseSensitive : La prise en compte de la casse. Par défaut la casse n'est pas prise en compte.
		 * @param	pNumeric : Valeurs numériques, par défaut le filtre se comporte pour des tri non numériques (10 est trié avant 2)
		 */
		function sort (pFields:Array, pAscending:Boolean = true, pCaseSensitive:Boolean = false, pNumeric:Boolean = false):void;
		
		/**
		 * Filtrer la collection grâce à une méthode callback.
		 * @param	pCallback : Le callback permettant de filtrer la collection. Se référer à la documentation de Array.filter.
		 */
		function filterCollection (pCallback:Function):void;
		
		/**
		 * La méthode toString
		 */
		function toString ():String;
	}
}