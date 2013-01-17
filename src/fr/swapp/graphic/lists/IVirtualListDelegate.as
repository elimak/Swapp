package fr.swapp.graphic.lists 
{
	import fr.swapp.graphic.base.SComponent;
	
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
		function getFirstVirtualIndex (pTarget:SVirtualList):int;
		
		/**
		 * Récupérer l'index du dernier élément. Permet de régler la scrollBar
		 * @param	pTarget : La liste qui réclame cet index
		 * @return : L'index du dernier élément
		 */
		function getLastVirtualIndex (pTarget:SVirtualList):int;
		
		/**
		 * Récupérer un élément spécifique a index donné
		 * @param	pTarget : La liste qui réclame cet élément
		 * @param	pIndex : L'index demander
		 * @return : Doit retourner l'élément ou null si pas d'élément disponible a cet index (bord de liste)
		 */
		function getVirtualElement (pTarget:SVirtualList, pIndex:int):SComponent;
		
		/**
		 * Récupérer la taille moyenne des éléments qui vont être ajoutés
		 * @param	pTarget : La liste qui réclame cette hauteur
		 * @return : Doit retourner la taille moyenne des éléments qui vont être ajoutés
		 */
		function getVirtualTipicalElementSize (pTarget:SVirtualList):int;
	}	
}