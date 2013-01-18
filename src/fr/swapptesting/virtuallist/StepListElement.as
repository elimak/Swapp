package fr.swapptesting.virtuallist 
{
	import fr.swapp.graphic.base.ResizableComponent;
	import fr.swapp.graphic.components.text.Label;
	/**
	 * ...
	 * @author ZoulouX
	 */
	public class StepListElement extends ResizableComponent 
	{
		public function StepListElement (pIndex:int)
		{
			index = pIndex;
			_styleEnabled = true;
			backgroundImage.background(0xFFFFFF * Math.random(), 1);
			(new Label(true)).text(index + " - " + Math.random()).rectPlace(10, 10).into(this);
		}
	}
}