package fr.swapp.core.entries 
{
	import flash.events.Event;
	import fr.swapp.core.display.MasterMovieClip;
	import fr.swapp.core.log.Log;
	
	/**
	 * Le document de base.
	 * @author ZoulouX
	 */
	public class Document extends MasterMovieClip implements IDocument
	{
		/**
		 * La version du framework
		 */
		public static const FRAMEWORK_VERSION		:Number					= 1.0;
		
		/**
		 * Le constructeur
		 */
		public function Document ()
		{
			// Afficher la version du Framework
			Log.log("");
			Log.log("-------------------------");
			Log.log("-- Swapp AS3 Framework --");
			Log.log("--                v"
								 +FRAMEWORK_VERSION+
											  " --");
			Log.log("--     www.swapp.fr    --");
			Log.log("-------------------------");
			Log.log("");
			
			// Relayer
			super();
		}
	}
}