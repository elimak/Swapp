package fr.swapptesting.starling
{
	import com.greensock.TweenMax;
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display3D.textures.TextureBase;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.textures.Texture;
	//import starling.events.Event;
	import flash.events.Event;
	
	/**
	 * @author ZoulouX
	 */
	public class StarlingContext extends Sprite
	{
		protected var _url				:String = "http://search.twitter.com/search.json?q=stage3d&rpp=";
		protected var _maxObjects		:uint = 100;
		protected var _objects			:Vector.<Image>;
		protected var _velocities		:Dictionary;
		
		public function StarlingContext ()
		{
			(new URLLoader(new URLRequest(_url + _maxObjects))).addEventListener(Event.COMPLETE, queryCompleteHandler);
		}
		
		protected function queryCompleteHandler (event:flash.events.Event):void 
		{
			init(JSON.parse((event.currentTarget as URLLoader).data as String));
		}
		
		protected function init (pData:Object):void
		{
			_objects = new Vector.<Image>;
			_velocities = new Dictionary();
			
			var loader:Loader;
			for each (var tweet:Object in pData.results)
			{
				loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, imageCompleteHandler);
				loader.load(new URLRequest(tweet.profile_image_url));
				
				/*
				for (var i:* in tweet)
				{
					trace(i + " : " + tweet[i]);
					
				}
				trace("------");
				*/
			}
			
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		protected function imageCompleteHandler (event:Event):void 
		{
			var image:Image = new Image(Texture.fromBitmap((event.currentTarget as LoaderInfo).content as Bitmap, true, true, 0.5));
			addChild(image);
			
			image.x = stage.stageWidth / 2;
			image.y = stage.stageHeight / 2;
			image.alpha = 0;
			
			TweenMax.to(image, .5, {
				alpha: 1
			});
			
			_velocities[image] = {
				x: Math.random() * 40 - 20,
				y: Math.random() * 40 - 20,
				rotation: (Math.random() - 0.5) / 100
			};
			
			_objects.push(image);
		}
		
		protected function enterFrameHandler (event:Object):void
		{
			for each (var image:Image in _objects)
			{
				if (image.x > stage.stageWidth || image.x < 0)
				{
					_velocities[image].x = - _velocities[image].x;
				}
				if (image.y > stage.stageHeight || image.y < 0)
				{
					_velocities[image].y = - _velocities[image].y;
				}
				
				if (Math.abs(_velocities[image].x) > 2)
				{
					_velocities[image].x /= 1.05;
				}
				if (Math.abs(_velocities[image].y) > 2)
				{
					_velocities[image].y /= 1.05;
				}
				
				image.x += _velocities[image].x;
				image.y += _velocities[image].y;
				image.rotation += _velocities[image].rotation;
			}
		}
	}
}