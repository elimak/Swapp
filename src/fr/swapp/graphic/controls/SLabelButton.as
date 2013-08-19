package fr.swapp.graphic.controls
{
	import fr.swapp.graphic.text.SLabel;
	
	/**
	 * @author ZoulouX
	 */
	public class SLabelButton extends SButton
	{
		/**
		 * Button's label
		 */
		protected var _label				:SLabel;
		
		
		/**
		 * Button's label
		 */
		public function get label ():SLabel { return _label; }
		
		/**
		 * Label text
		 */
		public function get labelText ():String { return _label.value; }
		public function set labelText (value:String):void
		{
			_label.value = value;
		}
		
		
		
		
		/**
		 * Constructor
		 */
		public function SLabelButton (pLabel:String = "", pTapHandler:Function = null, pInteractionMode:String = "monotouchInteraction") 
		{
			// Relayer la construction
			super(pTapHandler, pInteractionMode);
			
			// Appliquer le label
			labelText = pLabel;
		}
		
		/**
		 * SubConstructor
		 */
		override protected function construct ():void
		{
			// Relayer la construction
			super.construct();
			
			// Créer le label
			_label = new SLabel(false, false);
			_label.into(this);
		}
	}
}