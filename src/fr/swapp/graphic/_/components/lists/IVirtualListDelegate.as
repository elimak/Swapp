package fr.swapp.graphic.components.lists 
{
	import fr.swapp.graphic.base.ResizableComponent;
	
	/**
	 * L'implementation réglementaire pour être le delegate d'une liste virtuelle.
	 * @author ZoulouX
	 */
	public interface IVirtualListDelegate
	{
		/**
		 * Récupérer l'index du premier élément. Permet de régler la scrollBar
		 * @param	pTarget : La liste qui réclame cet index
		 * @return : L'index du premier élément
		 */
		function getVListFirstElementIndex (pTarget:AVirtualList):int;
		
		/**
		 * Récupérer l'index du dernier élément. Permet de régler la scrollBar
		 * @param	pTarget : La liste qui réclame cet index
		 * @return : L'index du dernier élément
		 */
		function getVListLastElementIndex (pTarget:AVirtualList):int;
		
		/**
		 * Récupérer un élément spécifique a index donné
		 * @param	pTarget : La liste qui réclame cet élément
		 * @param	pIndex : L'index demander
		 * @return : Doit retourner l'élément ou null si pas d'élément disponible a cet index (bord de liste)
		 */
		function getVListElementAt (pTarget:AVirtualList, pIndex:int):ResizableComponent;
		
		/**
		 * Récupérer la taille moyenne des éléments qui vont être ajoutés
		 * @param	pTarget : La liste qui réclame cette hauteur
		 * @return : Doit retourner la taille moyenne des éléments qui vont être ajoutés
		 */
		function getVListTipicalElementSize (pTarget:AVirtualList):int;
	}	
}