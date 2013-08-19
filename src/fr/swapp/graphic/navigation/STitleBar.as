package fr.swapp.graphic.navigation
{
	import fr.swapp.graphic.base.SComponent;
	import fr.swapp.graphic.transition.ITransition;
	
	/**
	 * @author ZoulouX
	 */
	public class STitleBar extends SComponent
	{
		/**
		 * Left component
		 */
		protected var _leftComponent				:SComponent;
		
		/**
		 * Middle component
		 */
		protected var _middleComponent				:SComponent;
		
		/**
		 * Right component
		 */
		protected var _rightComponent				:SComponent;
		
		
		/**
		 * Left component
		 */
		public function get leftComponent ():SComponent { return _leftComponent; }
		
		/**
		 * Middle component
		 */
		public function get middleComponent ():SComponent { return _middleComponent; }
		
		/**
		 * Right component
		 */
		public function get rightComponent ():SComponent { return _rightComponent; }
		
		
		/**
		 * Constructor
		 */
		public function STitleBar () { }
		
		
		/**
		 * Define the left component.
		 * @param	pComponent : The component instance to set. Let null to destroy current component.
		 * @param	pTransition : The transition to use between old and new component.
		 */
		public function setLeftComponent (pComponent:SComponent, pTransition:ITransition = null):void
		{
			replaceComponent("_leftComponent", pComponent, pTransition);
		}
		
		/**
		 * Define the middle component.
		 * @param	pComponent : The component instance to set. Let null to destroy current component.
		 * @param	pTransition : The transition to use between old and new component.
		 */
		public function setMiddleComponent (pComponent:SComponent, pTransition:ITransition = null):void
		{
			replaceComponent("_middleComponent", pComponent, pTransition);
		}
		
		/**
		 * Define the right component.
		 * @param	pComponent : The component instance to set. Let null to destroy current component.
		 * @param	pTransition : The transition to use between old and new component.
		 */
		public function setRightComponent (pComponent:SComponent, pTransition:ITransition = null):void
		{
			replaceComponent("_rightComponent", pComponent, pTransition);
		}
		
		/**
		 * Define the 3 components in one call.
		 * @param	pLeftComponent : The component instance to set. Let null to destroy current component.
		 * @param	pMiddleComponent : The component instance to set. Let null to destroy current component.
		 * @param	pRightComponent : The component instance to set. Let null to destroy current component.
		 * @param	pTransition : The transition to use between old and new component.
		 */
		public function setComponents (pLeftComponent:SComponent, pMiddleComponent:SComponent, pRightComponent:SComponent, pTransition:ITransition = null):void
		{
			// Replacer les 3 composants
			replaceComponent("_leftComponent", pComponent, pTransition);
			replaceComponent("_middleComponent", pComponent, pTransition);
			replaceComponent("_rightComponent", pComponent, pTransition);
		}
		
		/**
		 * Replace a component
		 * @param	pComponentName
		 * @param	pComponentInstance
		 * @param	pTransition
		 */
		protected function replaceComponent (pComponentName:String, pComponentInstance:SComponent, pTransition:ITransition = null):void
		{
			// Si le composant actuel est null
			if (this[pComponentName] == null)
			{
				
			}
		}
	}
}