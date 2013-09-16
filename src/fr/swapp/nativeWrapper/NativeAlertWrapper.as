package fr.swapp.nativeWrapper
{
	import pl.mateuszmackowiak.nativeANE.dialogs.NativeAlertDialog;
	import pl.mateuszmackowiak.nativeANE.events.NativeDialogEvent;
	
	/**
	 * @author ZoulouX
	 */
	public class NativeAlertWrapper
	{
		/**
		 * Constructor
		 */
		public function NativeAlertWrapper () { }
		
		/**
		 * 
		 */
		public static function showAlert (pTitle:String, pMessage:String, pButtons:Vector.<String> = null, pHandler:Function = null):void
		{
			// Si le natif est disponible
			var nativeExtensionAvailable:Boolean = false;
			
			// Vérifier si le natif est disponible
			try
			{
				nativeExtensionAvailable = NativeAlertDialog.isSupported;
			}
			catch (e:Error) { }
			
			// Si le natif est dispo
			if (nativeExtensionAvailable)
			{
				// Lancer la méthode interne pour le natif
				internalShowAlert(pTitle, pMessage, pButtons, pHandler);
			}
			else
			{
				// TODO : Virer cette méthode temporaire et réussir à faire des alertes sur desktop
				pHandler(-1);
			}
		}
		
		/**
		 * 
		 */
		protected static function internalShowAlert (pTitle:String, pMessage:String, pButtons:Vector.<String>, pHandler:Function = null):void
		{
			// Lancer l'alerte
			var nativeAlertDialog:NativeAlertDialog  = NativeAlertDialog.showAlert(pMessage, pTitle, pButtons, null, false);
			
			// Le handler lors de la fermeture de cette alert
			var handlerWrapper:Function = function (event:NativeDialogEvent):void
			{
				// Ne plus écouter la fermeture
				nativeAlertDialog.removeEventListener(NativeDialogEvent.CLOSED, handlerWrapper);
				
				// Appeler le handler en lui passant le bouton utilisé
				pHandler(event.index);
			};
			
			// Ecouter la fermeture de cette alerte
			nativeAlertDialog.addEventListener(NativeDialogEvent.CLOSED, handlerWrapper);
		}
	}
}