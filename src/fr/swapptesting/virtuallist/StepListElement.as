package fr.swapptesting.virtuallist 
{
	import fr.swapp.graphic.base.ResizableComponent;
	/**
	 * ...
	 * @author ZoulouX
	 */
	public class StepListElement extends ResizableComponent 
	{
		public function StepListElement ()
		{
			_styleEnabled = true;
			backgroundImage.background(0xFFFFFF * Math.random(), 1);
		}
	}
}