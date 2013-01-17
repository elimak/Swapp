package fr.swapp.graphic.base 
{
	import flash.display.DisplayObjectContainer;
	import fr.swapp.core.bundle.IBundle;
	import fr.swapp.core.mvc.concrete.View;
	import fr.swapp.graphic.animations.ITransition;
	import fr.swapp.graphic.components.navigation.ActionStack;
	import fr.swapp.graphic.components.navigation.NavigationStack;
	import fr.swapp.graphic.components.navigation.ViewStack;
	import fr.swapp.utils.DisplayObjectUtils;
	
	/**
	 * Une vue dont le displayObject est un ResizableComponent.
	 * @author ZoulouX
	 */
	public class ComponentView extends View
	{
		/**
		 * Les éléments à afficher dans la titleBar à l'affichage de cette vue
		 */
		protected var _titleBarContent					:Object;
		
		
		/**
		 * Récupérer le displayObject en tant que sprite
		 */
		public function get resizableComponent ():ResizableComponent { return _displayObject as ResizableComponent }
		
		/**
		 * Récupérer la viewStack parent
		 */
		public function get parentViewStack ():ViewStack
		{
			// Récupérer le parent
			var parentViewStack:DisplayObjectContainer = DisplayObjectUtils.getParentOfType(resizableComponent, ViewStack);
			
			// Retourner correctement typé si présent
			return (parentViewStack != null ? parentViewStack as ViewStack : null);
		}
		
		/**
		 * Récupérer l'actionStack parent
		 */
		public function get parentActionStack ():ActionStack
		{
			// Récupérer le parent
			var parentActionStack:DisplayObjectContainer = DisplayObjectUtils.getParentOfType(resizableComponent, ActionStack);
			
			// Retourner correctement typé si présent
			return (parentActionStack != null ? parentActionStack as ActionStack : null);
		}
		
		/**
		 * Récupérer le navigationStack parent
		 */
		public function get parentNavigationStack ():NavigationStack
		{
			// Récupérer le parent
			var parentNavigationStack:DisplayObjectContainer = DisplayObjectUtils.getParentOfType(resizableComponent, NavigationStack);
			
			// Retourner correctement typé si présent
			return (parentNavigationStack != null ? parentNavigationStack as NavigationStack : null);
		}
		
		
		/**
		 * Le Bundle auquel appartient ce controlleur
		 */
		override public function set bundle (value:IBundle):void
		{
			// Enregistrer le Bundle
			_bundle = value;
			
			// Une fois qu'on a le Bundle, on peut créer le ResizableComponent
			attachDefaultDisplayObject();
		}
		
		/**
		 * Les éléments à afficher dans la titleBar à l'affichage de cette vue
		 */
		public function get titleBarContent ():Object { return _titleBarContent; }
		
		
		/**
		 * Le constructeur
		 */
		public function ComponentView ()
		{
			
		}
		
		
		/**
		 * Création du displayObject par défaut
		 */
		protected function attachDefaultDisplayObject ():void
		{
			// Le type par défaut
			createAndAttachDisplayObject(ResizableComponent);
			
			// Le placement par défaut
			resizableComponent.place(0, 0, 0, 0);
		}
		
		
		/**
		 * Animation par défaut
		 * @param	pContextInfo
		 */
		override public function turnOn (pContextInfo:Object = null):void
		{
			// Si on a une transition
			if (pContextInfo != null && "transition" in pContextInfo && pContextInfo.transition is ITransition)
			{
				// Animation d'intro sur la transition
				(pContextInfo.transition as ITransition).playIn(resizableComponent, pContextInfo, dispatchEngineSignal, [_onTurningOn], dispatchEngineSignal, [_onTurnedOn]);
			}
			else
			{
				// Démarrage instantanné
				super.turnOn(pContextInfo);
			}
		}
		
		/**
		 * Animation par défaut
		 */
		override public function turnOff (pContextInfo:Object = null):void
		{
			// Si on a une transition
			if (pContextInfo != null && "transition" in pContextInfo && pContextInfo.transition is ITransition)
			{
				// Animation de sortie sur la transition
				(pContextInfo.transition as ITransition).playOut(resizableComponent, pContextInfo, dispatchEngineSignal, [_onTurningOff], dispatchEngineSignal, [_onTurnedOff]);
			}
			else
			{
				// Arrêt instantanné
				super.turnOff(pContextInfo);
			}
		}
	}
}