package fr.swapp.graphic.popups
{
	import fr.swapp.core.mvc.abstract.IView;
	import fr.swapp.graphic.base.ComponentView;
	import fr.swapp.graphic.base.ResizableComponent;
	
	/**
	 * @author ZoulouX
	 */
	public class APopup extends ComponentView
	{
		/**
		 * Le contexte
		 */
		protected var _contextInfo					:Object;
		
		
		/**
		 * Récupérer le container pour le bootstrap
		 */
		public function get container ():ResizableComponent { return resizableComponent; }
		
		
		/**
		 * Constructeur
		 */
		public function APopup ()
		{
			// Supprimer la popup une fois qu'elle est désactivée
			_onTurnedOff.addOnce(removeFromParent);
		}
		
		
		/**
		 * Supprimer cette popup de son container
		 */
		public function removeFromParent ():void
		{
			// Si on a un parent, on delete
			if (resizableComponent.parent != null)
				resizableComponent.parent.removeChild(resizableComponent);
		}
		
		/**
		 * Démarrage
		 */
		override public function turnOn (pContextInfo:Object = null):void
		{
			// Enregistrer le contexte
			if (pContextInfo != null)
				_contextInfo = pContextInfo;
			
			// Relayer
			super.turnOn(pContextInfo);
		}
		
		/**
		 * Arrêter la vue associée
		 */
		protected function turnOffAssciatedView ():void
		{
			var associatedView:IView = _bundle.bootstrap.getControllerFromContainer(container).view;
			
			if (associatedView != null)
			{
				associatedView.turnOff();
			}
		}
		
		/**
		 * Arrêt
		 */
		override public function turnOff (pContextInfo:Object = null):void
		{
			// Arrêter la vue associée
			turnOffAssciatedView();
			
			// Inverser le sens
			if (_contextInfo != null)
				_contextInfo.direction = -1;
			
			// Relayer avec le bon contexte
			super.turnOff(pContextInfo == null ? _contextInfo : pContextInfo);
		}
	}
}