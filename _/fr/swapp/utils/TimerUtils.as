package fr.swapp.utils
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	/**
	 * @author ZoulouX
	 */
	public class TimerUtils
	{
		/**
		 * Attendre un nombre de frames, basé sur enterFrame
		 * @param	pDisplayTarget : Le clip qui servira a compter les frames (doit être sur le stage pour compter, peut être le stage lui même)
		 * @param	pFrames : Le nombre de frames à attendre (0 pour appel direct)
		 * @param	pDirectIfNoStage : Appeler directement le handler s'il n'y a pas de stage. Si false, l'écoute sera faite en weakReference pour éviter un possible memory leak
		 * @param	pHandler : La fonction a appeler une fois le délais passer
		 * @param	pHandlerParams : Les paramètres à passer à la fonction
		 */
		public static function wait (pDisplayTarget:DisplayObject, pFrames:uint, pDirectIfNoStage:Boolean, pHandler:Function, pHandlerParams:Array = null):void
		{
			// Si on a n'a pas de handler on quitte
			if (pHandler == null)
				return;
			
			// Appelé a chaque frame
			function waitTick (event:Event = null):void
			{
				// Si le nombre de frames est écoulé
				if (--pFrames == 0 || event == null)
				{
					// Ne plus écouter les frames et les suppressions
					pDisplayTarget.removeEventListener(Event.ENTER_FRAME, waitTick);
					pDisplayTarget.removeEventListener(Event.REMOVED_FROM_STAGE, waitTick);
					
					// Appeler le handler
					pHandler.apply(pDisplayTarget, pHandlerParams);
				}
				else if (event.type == Event.REMOVED_FROM_STAGE)
				{
					// Supprimer les listeners si le clip est supprimé
					pDisplayTarget.removeEventListener(Event.ENTER_FRAME, waitTick);
					pDisplayTarget.removeEventListener(Event.REMOVED_FROM_STAGE, waitTick);
				}
			}
			
			// Si on a besoin d'attendre quelques frames
			if (pFrames > 0 && (pDisplayTarget.stage != null || !pDirectIfNoStage))
			{
				// Ecouter les frames sur le clip
				pDisplayTarget.addEventListener(Event.ENTER_FRAME, waitTick);
				pDisplayTarget.addEventListener(Event.REMOVED_FROM_STAGE, waitTick);
			}
			else
			{
				// On lance directement
				waitTick();
			}
		}
	}
}