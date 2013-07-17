package fr.swapp.graphic.document
{
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.events.InvokeEvent;
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
			
			// Ecouter les suspends
			NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, nativeApplicationEventHandler, false, 0, true);
			NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, nativeApplicationEventHandler, false, 0, true);
			NativeApplication.nativeApplication.addEventListener(Event.SUSPEND, nativeApplicationEventHandler, false, 0, true);
			NativeApplication.nativeApplication.addEventListener(Event.EXITING, nativeApplicationEventHandler, false, 0, true);
			NativeApplication.nativeApplication.addEventListener(Event.NETWORK_CHANGE, nativeApplicationEventHandler, false, 0, true);
			NativeApplication.nativeApplication.addEventListener(Event.USER_IDLE, nativeApplicationEventHandler, false, 0, true);
			NativeApplication.nativeApplication.addEventListener(Event.USER_PRESENT, nativeApplicationEventHandler, false, 0, true);
			NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, nativeApplicationEventHandler, false, 0, true);
			
			// Relayer la construction
			super.construct();
		}
		
		/**
		 * Send a command to AppController. AppController can cancel event.
		 */
		protected function sendCommandToAppController (pEvent:Event, pCommandName:String, pParameters:Object):void
		{
			// Si on doit annuler le comportement par défaut de la plateforme
			var cancelDefault:Boolean = true;
			
			// Si on a reçu une commande
			if (pCommandName != null && pCommandName != "" && _appViewController != null)
			{
				// Appeler le handler sur l'appController et récupérer l'annulation
				cancelDefault = _appViewController.externalCommand(pCommandName, pParameters);
			}
			
			// Si on doit annuler le comportement par défaut de la plateforme
			if (cancelDefault)
			{
				pEvent.preventDefault();
				pEvent.stopImmediatePropagation();
			}
		}
		
		/**
		 * Key down on native application
		 */
		protected function nativeApplicationKeyDownHandler (event:KeyboardEvent):void 
		{
			// Si on a appuyé sur le bouton back / menu / search d'android
			if (event.keyCode == Keyboard.BACK || event.keyCode == Keyboard.MENU || event.keyCode == Keyboard.SEARCH)
			{
				// Si on a un appController de dispo
				if (_appViewController != null)
				{
					// Le nom de la commande
					var commandName:String;
					
					// Convertir la commande Android en SExternalCommands
					if (event.keyCode == Keyboard.BACK)
					{
						commandName = SExternalCommands.BACK_COMMAND;
					}
					else if (event.keyCode == Keyboard.MENU)
					{
						commandName = SExternalCommands.MENU_COMMAND;
					}
					else if (event.keyCode == Keyboard.SEARCH)
					{
						commandName = SExternalCommands.SEARCH_COMMAND;
					}
					
					// Envoyer la commande à l'AppController
					sendCommandToAppController(event, commandName, {});
				}
			}
		}
		
		/**
		 * When events occurs in NativeApplication
		 */
		protected function nativeApplicationEventHandler (event:Event):void 
		{
			// Activate / deactivate
			if (event.type == Event.ACTIVATE)
			{
				sendCommandToAppController(event, SExternalCommands.ACTIVATE_COMMAND, {});
			}
			else if (event.type == Event.DEACTIVATE)
			{
				sendCommandToAppController(event, SExternalCommands.DEACTIVATE_COMMAND, {});
			}
			
			// Quitting
			else if (event.type == Event.SUSPEND)
			{
				sendCommandToAppController(event, SExternalCommands.SUSPEND_COMMAND, {});
			}
			else if (event.type == Event.EXITING)
			{
				sendCommandToAppController(event, SExternalCommands.EXITING_COMMAND, {});
			}
			
			// Network
			else if (event.type == Event.NETWORK_CHANGE)
			{
				sendCommandToAppController(event, SExternalCommands.NETWORK_CHANGE_COMMAND, {});
			}
			
			// User
			else if (event.type == Event.USER_IDLE)
			{
				sendCommandToAppController(event, SExternalCommands.USER_IDLE_COMMAND, {});
			}
			else if (event.type == Event.USER_PRESENT)
			{
				sendCommandToAppController(event, SExternalCommands.USER_PRESENT_COMMAND, {});
			}
			
			// Invoke
			else if (event is InvokeEvent && event.type == InvokeEvent.INVOKE)
			{
				// Récupérer l'invokeEvent
				var invokeEvent:InvokeEvent = (event as InvokeEvent);
				
				// Envoyer la comande
				sendCommandToAppController(event, SExternalCommands.INVOKE_COMMAND, {
					reason: invokeEvent.reason,
					args: invokeEvent.arguments,
					url: invokeEvent.currentDirectory.url
				});
			}
		}
	}
}