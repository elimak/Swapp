package fr.swapp.graphic.base
{
	import flash.display.Sprite;
	import flash.events.Event;
	import fr.swapp.core.roles.IDisposable;
	import fr.swapp.core.roles.IInitializable;
	
	/**
	 * @author ZoulouX
	 */
	public class SDocument extends Sprite implements IInitializable, IDisposable
	{
		/**
		 * Components wrapper
		 */
		protected var _wrapper				:SWrapper;
		
		
		/**
		 * Constructeur
		 */
		public function SDocument ()
		{
			// TODO : Intégrer Log (méthode helper, voir si avec une sorte de paramètre debug on pourrait pas automatiser)
			// TODO : Peut être passer quelques compositions de SWrapper à Document (touch, emulator, etc...)
			// TODO : Faire un helper pour les paramètres (flashVars) et les InvokeEvent. Cette classe doit faire passerelle vers l'extérieur.
			
			// Ecouter les ajouts au stage
			if (stage != null)
			{
				addedHandler();
			}
			else
			{
				addEventListener(Event.ADDED_TO_STAGE, addedHandler);
			}
		}
		
		
		/**
		 * When stage is available
		 * @param	event
		 */
		protected function addedHandler (event:Event = null):void
		{
			// Ne plus écouter
			removeEventListener(Event.ADDED_TO_STAGE, addedHandler);
			
			// Créer le wrapper
			_wrapper = SWrapper.getInstance(stage, true);
			
			// Lancer l'initialisation
			init();
		}
		
		/**
		 * Initialize
		 */
		public function init ():void
		{
			
		}
		
		/**
		 * Dispose this document
		 */
		public function dispose ():void
		{
			_wrapper.dispose();
		}
	}
}