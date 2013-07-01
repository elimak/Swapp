package fr.swapptesting.global.app
{
	import fr.swapp.graphic.base.SComponent;
	import fr.swapp.graphic.base.SContainer;
	import fr.swapp.graphic.base.SGraphic;
	import fr.swapp.graphic.base.SView;
	import fr.swapp.graphic.text.SLabel;
	
	/**
	 * @author ZoulouX
	 */
	public class GlobalAppView extends SView
	{
		/**
		 * Constructor
		 */
		public function GlobalAppView () { }
		
		/**
		 * Construct interface
		 */
		override protected function buildInterface ():void
		{
			// Définir les composants
			setupComponents({
				titleBar: {
					leftButton	: new SGraphic().style("button"),
					rightButton	: new SGraphic().style("button"),
					title		: new SLabel()
				},
				content: {
					type: SContainer
				}
			});
			
			// Définir le style
			setStyleData(GlobalAppStyle);
		}
	}
}