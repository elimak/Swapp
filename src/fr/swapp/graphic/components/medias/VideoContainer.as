package fr.swapp.graphic.components.medias 
{
	import flash.net.NetStream;
	import fr.swapp.graphic.base.ResizableComponent;
	import org.osflash.signals.Signal;
	
	/**
	 * Container Video avec StageVideo et fallback automatique.
	 * @author ZoulouX
	 */
	public class VideoContainer extends ResizableComponent
	{
		protected var _onStart							:Signal;
		protected var _onStop							:Signal;
		protected var _onBuffering						:Signal;
		protected var _onEnd							:Signal;
		
		/**
		 * isPaused
		 * isStageVideo
		 * url
		 * 
		 */
		
		
		
		/**
		 * Le volume de la vidéo
		 */
		protected var _volume:Number;
		
		
		/**
		 * Le volume de la vidéo
		 */
		public function get volume ():Number { return _volume; }
		public function set volume (value:Number):void
		{
			_volume = value;
		}
		
		
		/**
		 * Le constructeur
		 */
		public function VideoContainer ()
		{
			
		}
		
		public function attachNetStream (pNetStream:NetStream):void
		{
			
		}
		
		public function load (pURL:String):void
		{
			
		}
		
		
		public function play ():void
		{
			
		}
		
		public function pause ():void
		{
			
		}
		
		public function seek (pAt:Number):void
		{
			
		}
		
		/**
		 * Destruction
		 */
		override public function dispose ():void
		{
			super.dispose();
		}
	}
}