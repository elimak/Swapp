package fr.swapp.graphic.document
{
	import flash.desktop.NativeApplication;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import fr.swapp.graphic.base.SWrapper;
	
	/**
	 * @author ZoulouX
	 */
	public class SAirDocument extends SFlashDocument
	{
		/**
		 * Constructor
		 */
		public function SAirDocument ()
		{
			
		}
		
		/**
		 * Sub-constructor
		 */
		override protected function construct ():void
		{
			// Ecouter les backs pour android
			NativeApplication.nativeApplication.addEventListener(KeyboardEvent.KEY_DOWN, nativeApplicationKeyDownHandler, false, 0, true);
			
			// Relayer la construction
			super.construct();
		}
		
		/**
		 * Key down on native application
		 */
		protected function nativeApplicationKeyDownHandler (event:KeyboardEvent):void 
		{
			// Si on a appuyé sur le bouton back / menu d'android
			if (event.keyCode == Keyboard.BACK || event.keyCode == Keyboard.MENU)
			{
				// Si on doit annuler le comportement par défaut de la plateforme
				var cancelDefault:Boolean = true;
				
				// Si on a un appController de dispo
				if (_appViewController != null)
				{
					// Le nom de la commande
					var commandName:String;
					
					// Convertir la commande Android en string
					if (event.keyCode == Keyboard.BACK)
					{
						commandName = "back";
					}
					else if (event.keyCode == Keyboard.MENU)
					{
						commandName = "menu";
					}
					
					// Appeler le handler sur l'appController et récupérer l'annulation
					cancelDefault = _appViewController.externalCommand(commandName);
				}
				
				// Si on doit annuler le comportement par défaut de la plateforme
				if (cancelDefault)
				{
					event.preventDefault();
					event.stopImmediatePropagation();
				}
			}
		}
	}
}