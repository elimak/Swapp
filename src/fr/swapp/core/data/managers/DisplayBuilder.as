package fr.swapp.core.data.managers 
{
	/**
	 * Les imports
	 */
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import fr.swapp.core.data.collect.DataCollection;
	import fr.swapp.core.data.collect.IDataCollection;
	import fr.swapp.core.data.items.IItemContainer;
	import fr.swapp.core.errors.SwappError;
	import fr.swapp.core.masters.IDisplayObject;
	
	/**
	 * Permet de générer un DataCollection et ses displayObjects directement depuis un IDataCollection. Les items sont associés.
	 * @author ZoulouX
	 */
	public class DisplayBuilder
	{
		/**
		 * Construire une collection de IItemContainer selon une collection de IDataItem. Les items sont automatiquement associés.
		 * Cette méthode permet par exemple de créer tous les displayObjects d'une collection contenant des items.
		 * Tous les displayObjects sont instanciés, leur item est ajouté, et le tout est ajouté dans un IDataCollection retourné.
		 * @param	pCollection : La collection source
		 * @param	pGraphicClass : La classe des items graphiques à créer
		 * @param	pHandler : Le handler appelé à chaque création, le displayObject et son item sont passés en paramètre suivant cette signature: handler (pDisplayObject:DisplayObject, pItem:IDataItem, pIndex:uint):void. Facultatif.
		 * @param	pParams : Les paramètres du handlers (ajoutés après les 3 premiers paramètres). Facultatif.
		 * @param	pContainer : Le container où sont ajouté automatiquement les items graphiques créés. Facultatif.
		 * @return : La collection finale d'items graphiques
		 */
		public static function build (pCollection:IDataCollection, pGraphicClass:Class, pHandler:Function = null, pParams:Array = null, pContainer:DisplayObjectContainer = null):IDataCollection
		{
			// Initialiser les paramètres s'il sont nulls
			if (pHandler != null && pParams == null)
				pParams = [];
			
			// Créer la collection de sortie
			var outCollection:IDataCollection = new DataCollection();
			
			// Essayer de convertir l'item
			//try
			//{
				// Hopla, on itère
				while (pCollection.iterator.hasNext())
				{
					// Instancier le displayObject
					var displayObject:IItemContainer = new pGraphicClass() as IItemContainer;
					
					// Lui ajouter l'item
					displayObject.item = pCollection.iterator.next();
					
					// On ajoute le tout dans la collection de sortie
					outCollection.add(displayObject);
					
					// Si le container n'est pas null, on ajoute
					if (pContainer != null)
					{
						pContainer.addChild((displayObject as IDisplayObject).getDisplayObject());
					}
					
					// S'il n'est pas null
					if (pHandler != null)
					{
						// Appeler le handler avec les 3 paramètres de base + les optionnels
						pHandler.apply(null, [displayObject as pGraphicClass, pCollection.iterator.current, pCollection.iterator.index].concat(pParams));
					}
				}
				
				// Reset de l'itérateur
				pCollection.iterator.reset();
			/*}
			catch (e:Error)
			{
				throw new SwappError("DisplayBuilder.build", "pItem Class must implement IItemContainer and extend DisplayObject.");
			}*/
			
			// Retourner la collection
			return outCollection;
		}
	}
}