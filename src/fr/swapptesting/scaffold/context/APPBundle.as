package fr.swapptesting.scaffold.context 
{
	import flash.display.DisplayObjectContainer;
	import fr.swapp.core.actions.IAction;
	import fr.swapp.core.bundle.Bundle;
	
	/**
	 * Le bundle principal de "APP"
	 * @author ZoulouX
	 */
	public class APPBundle extends Bundle 
	{
		
		public function APPBundle (pDisplayContainer:DisplayObjectContainer, pDefaultAction:IAction)
		{
			super(pDisplayContainer, pDefaultAction);
		}
		
	}

}