package fr.swapp.graphic.popups
{
	import flash.display.DisplayObjectContainer;
	import fr.swapp.core.bundle.IBundle;
	import fr.swapp.utils.ObjectUtils;
	/**
	 * @author ZoulouX
	 */
	public class PopupProvider
	{
		/**
		 * Le lien vers le bundle
		 */
		protected var _bundle					:IBundle;
		
		/**
		 * La liste des popups par nom
		 */
		protected var _popups					:Array						= [];
		
		
		/**
		 * Le lien vers le bundle
		 */
		public function get bundle ():IBundle { return _bundle; }
		public function set bundle (value:IBundle):void
		{
			_bundle = value;
		}
		
		
		/**
		 * Le constructeur
		 */
		public function PopupProvider ()
		{
			
		}
		
		
		/**
		 * Récupérer une instance de popup
		 * @param	pPopupClass : La classe de la popup a créer
		 * @param	pPopupName : Le nom de la popup pour pouvoir l'identifier
		 * @param	pContextInfos : Les infos sur le contexte d'affichage de la popup
		 * @param	pPopupExtra : Propriété à injecter dans la popup
		 * @return L'instance de la popup
		 */
		public function getPopup (pPopupClass:Class, pPopupName:String, pContextInfos:Object, pPopupExtra:Object = null, pOverridePopup:Boolean = false):APopup
		{
			// Si on a pas déjà une popup de ce nom
			if (!(pPopupName in _popups) || pOverridePopup)
			{
				// Contexte par défaut
				if (pContextInfos == null)
					pContextInfos = { };
				
				// Si on n'a pas de container
				if (!("displayContainer" in pContextInfos) || pContextInfos.displayContainer == null)
				{
					// On prend la racine du bundle
					pContextInfos.displayContainer = _bundle.displayContainer;
				}
				
				// Créer l'instance de la popup via le manager de dépendances
				var popupInstance:APopup = _bundle.dependencesManager.instanciate(pPopupClass) as APopup;
				
				// Si on a une popup
				if (popupInstance != null)
				{
					// Ajouter la popup
					_popups[pPopupName] = popupInstance;
					
					// Regarder quand cette popup est supprimée
					popupInstance.onTurnedOff.addOnce(function ():void {
						trace("DELETE POPUP" + pPopupName);
						delete _popups[pPopupName];
					});
					
					// Lui injecter les extras
					ObjectUtils.extra(popupInstance, pPopupExtra);
					
					// Lui passer le bundle
					popupInstance.bundle = _bundle;
					
					// Ajouter cette popup au container
					(pContextInfos.displayContainer as DisplayObjectContainer).addChild(popupInstance.displayObject);
					
					// Démarrer cette popup
					popupInstance.turnOn(pContextInfos);
					
					// Activer la popup
					popupInstance.activate();
				}
				
				// Retourner la popup
				return popupInstance;
			}
			return null;
		}
		
		/**
		 * Récupérer une popup par son nom
		 */
		public function getPopupByName (pPopupName:String):APopup
		{
			if (pPopupName in _popups)
				return _popups[pPopupName] as APopup;
			else
				return null;
		}
	}
}