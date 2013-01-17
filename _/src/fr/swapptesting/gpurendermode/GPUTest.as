package fr.swapptesting.gpurendermode
{
	import com.greensock.TweenMax;
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.display3D.textures.TextureBase;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	import fr.swapp.graphic.base.StageWrapper;
	import fr.swapp.graphic.components.bitmaps.AdvancedBitmap;
	import fr.swapp.graphic.components.bitmaps.BitmapRender;
	import flash.events.Event;
	
	/**
	 * @author ZoulouX
	 */
	public class GPUTest extends Sprite
	{
		protected var _url				:String = "http://search.twitter.com/search.json?q=stage3d&rpp=";
		protected var _maxObjects		:uint = 100;
		protected var _objects			:Vector.<AdvancedBitmap>;
		protected var _velocities		:Dictionary;
		protected var _wrapper			:StageWrapper;
		
		public function GPUTest ()
		{
			(new URLLoader(new URLRequest(_url + _maxObjects))).addEventListener(Event.COMPLETE, queryCompleteHandler);
		}
		
		protected function queryCompleteHandler (event:flash.events.Event):void 
		{
			_wrapper = new StageWrapper();
			
			addChild(_wrapper);
			
			init(JSON.parse((event.currentTarget as URLLoader).data as String));
		}
		
		protected function init (pData:Object):void
		{
			_objects = new Vector.<AdvancedBitmap>;
			_velocities = new Dictionary();
			
			var loader:Loader;
			for each (var tweet:Object in pData.results)
			{
				loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, imageCompleteHandler);
				loader.load(new URLRequest(tweet.profile_image_url));
			}
			
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		protected function imageCompleteHandler (event:Event):void 
		{
			var image:AdvancedBitmap = new AdvancedBitmap(((event.currentTarget as LoaderInfo).content as Bitmap).bitmapData, BitmapRender.AUTO_SIZE_RENDER);
			_wrapper.addChild(image);
			
			image.x = _wrapper.width / 2;
			image.y = _wrapper.height / 2;
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
		
		protected function enterFrameHandler (event:Event):void
		{
			for each (var image:AdvancedBitmap in _objects)
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