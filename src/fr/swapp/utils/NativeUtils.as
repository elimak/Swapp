package fr.swapp.utils
{
	import flash.display.Stage;
	import flash.geom.Rectangle;
	import flash.media.StageWebView;
	import flash.utils.Dictionary;
	import fr.swapp.core.roles.IDisposable;
	import org.osflash.signals.Signal;
	
	/**
	 * @author ZoulouX
	 */
	public class NativeUtils implements IDisposable
	{
		protected static var __instances:Dictionary = new Dictionary(false);
		
		public static function getInstance (pStage:Stage):NativeUtils
		{
			if (pStage == null)
			{
				throw new Error("NO STAGE");
				return null;
			}
			
			if (!(pStage in __instances))
			{
				__instances[pStage] = new NativeUtils(pStage);
			}
			
			return __instances[pStage];
		}
		
		
		protected var _onStatusBarTap:Signal = new Signal();
		protected var _webview:StageWebView;
		protected var _stage:Stage;
		
		public function get onStatusBarTap ():Signal { return _onStatusBarTap; }
		
		
		public function NativeUtils (pStage:Stage)
		{
			_stage = pStage;
			
			
			initPhatomWebview();
		}
		
		protected function initPhatomWebview ():void
		{
			_webview = new StageWebView();
			_webview.stage = stage;
			_webview.viewPort = new Rectangle(-1, -1, 1, 1);
			_webview.loadString(<text>
				<html>
					<head>
					</head>
				</html>
			</text>.toString());
		}
		
		public function alert ():void
		{
			
		}
		
		public function prompt ():void
		{
			
		}
		
		public function confirm ():void
		{
			
		}
		
		public function getUserAgent ():String
		{
			
		}
		
		public function dispose ()
		{
			delete __instances[_stage];
			__instances[_stage] = null;
			
			_webview.stage = null;
			_stage = null;
			
			_webview.dispose();
		}
	}
}