package fr.swapptesting.touch
{
	import flash.geom.Matrix;
	import flash.display.DisplayObject;
	import fr.swapp.graphic.base.SComponent;
	import fr.swapp.graphic.base.SGraphic;
	import fr.swapp.touch.delegate.ITouchTransformDelegate;
	import fr.swapp.touch.dispatcher.TouchMatrixOptions;
	
	/**
	 * @author ZoulouX
	 */
	public class TransformContainer extends SComponent implements ITouchTransformDelegate
	{
		protected var _graphics:Vector.<SGraphic>;
		
		public function TransformContainer ()
		{
			buildInterface();
		}
		
		/* INTERFACE fr.swapp.touch.delegate.ITouchTransformDelegate */
		
		protected function buildInterface ():void
		{
			size(1024, 768);
			
			_graphics = new Vector.<SGraphic>;
			
			var graph:SGraphic;
			
			for (var i:int = 0; i < 6; i++) 
			{
				graph = new SGraphic();
				
				graph.index = i;
				
				graph.horizontalOffset = Math.random() * 1024;
				graph.verticalOffset = Math.random() * 768;
				
				graph.size(200 + Math.random() * 200, 200 + Math.random() * 200);
				graph.rotation = Math.random() * 360;
				
				graph.background(0xFF0000 * Math.random() | 0x006600);
				
				_graphics.push(graph);
				
				graph.into(this);
			}
		}
		
		public function touchTransformStartHandler (pTarget:DisplayObject):DisplayObject
		{
			trace("START", (pTarget as SComponent).index);
			
			return pTarget;
		}
		
		public function touchTransformStopHandler (pTarget:DisplayObject):void
		{
			trace("STOP", (pTarget as SComponent).index);
		}
		
		public function touchTransformHandler (pTarget:DisplayObject, pScaleDelta:Number, pRotationDelta:Number, pXDelta:Number, pYDelta:Number, pPoints:uint):Boolean
		{
			var componentTarget:SComponent = (pTarget as SComponent);
			
			//trace("touchTransformHandler", componentTarget.index, pRotationDelta);
			
			return true;
			
			componentTarget.horizontalOffset += pXDelta;
			componentTarget.verticalOffset += pYDelta;
			componentTarget.rotation += pRotationDelta;
			componentTarget.scaleX *= pScaleDelta;
			componentTarget.scaleY *= pScaleDelta;
			
			//return true;
		}
		
		public function touchMatrixTransformHandler (pTarget:DisplayObject, pTransformationMatrix:Matrix, pPoints:uint):Boolean
		{
			//return true;
			
			trace("touchMatrixTransformHandler", (pTarget as SComponent).index, pTransformationMatrix);
			
			//var targetMatrix:Matrix = pTarget.transform.matrix.clone();
			
			//targetMatrix.concat(pTransformationMatrix);
			
			pTarget.transform.matrix = pTransformationMatrix;
			
			return true;
		}
		
		/* INTERFACE fr.swapp.touch.delegate.ITouchTransformDelegate */
		
		public function touchTransformMatrixType (pTarget:DisplayObject):uint
		{
			return TouchMatrixOptions.DRAG_OPTION | TouchMatrixOptions.SCALE_OPTION;
		}
	}
}