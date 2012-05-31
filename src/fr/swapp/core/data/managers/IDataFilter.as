package fr.swapp.core.data.managers 
{
	/**
	 * Les imports
	 */
	import fr.swapp.core.data.collect.IDataCollection;
	
	/**
	 * Permet de créer des filtres de collection. Les DataFilters doivent implément IDataFilter et étendre ADataFilter.
	 * Ces classes concrêtes devront aussi overrider la méthode abstraite protégée filterElement (pElement:IDataItem, pIndex:uint):Boolean
	 * Cette méthode doit retourner true ou false pour garder ou non l'élément selon vos conditions.
	 * Le filtre pourra être éxécuté par la méthode filter ():IDataCollection, la collection filtrée pourra en être récupérée.
	 * Cette collection filtrée est aussi disponible par le getter filteredCollection.
	 * La collection à filtrer peut être automatiquement changée/récupérer par la variable collection.
	 * @author ZoulouX
	 */
	public interface IDataFilter 
	{
		/**
		 * La collection à filtrer
		 */
		function get dataCollection ():IDataCollection;
		function set dataCollection (value:IDataCollection):void;
		
		/**
		 * Récupérer la collection filtrée
		 */
		function get filteredCollection ():IDataCollection;
		function set filteredCollection (value:IDataCollection):void;
		
		/**
		 * Exécuter le filtre de la collection
		 */
		function filter ():void;
	}
}