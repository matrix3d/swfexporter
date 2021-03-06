package lz.tools 
{
	import com.codeazur.as3swf.data.SWFMatrix;
	import com.codeazur.as3swf.data.SWFSymbol;
	import com.codeazur.as3swf.exporters.core.IShapeExporter;
	import com.codeazur.as3swf.SWF;
	import com.codeazur.as3swf.SWFTimelineContainer;
	import com.codeazur.as3swf.tags.IDefinitionTag;
	import com.codeazur.as3swf.tags.ITag;
	import com.codeazur.as3swf.tags.TagDefineBits;
	import com.codeazur.as3swf.tags.TagDefineBitsLossless;
	import com.codeazur.as3swf.tags.TagDefineShape;
	import com.codeazur.as3swf.tags.TagDefineSprite;
	import com.codeazur.as3swf.tags.TagPlaceObject;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author lizhi
	 */
	public class SymbolView extends Sprite implements IShapeExporter
	{
		private var symbol:SWFSymbol;
		private var swf:SWF;
		private var tagid2bitmap:Object;
		private var deftag:IDefinitionTag;
		public var symbolWrapper:Sprite = new Sprite;
		private var currentShapeWrapper:ShapeSprite;
		private var startMouseX:Number;
		private var startMouseY:Number;
		private var startSymbolWrapperX:Number;
		private var startSymbolWrapperY:Number;
		private var depth2lastObj:Object;
		public var dis2name:Dictionary;
		public function SymbolView() 
		{
			addChild(symbolWrapper);
			symbolWrapper.graphics.lineStyle(0, 0xff0000);
			var len:int = 1000;
			symbolWrapper.graphics.moveTo( -len, 0);
			symbolWrapper.graphics.lineTo( len, 0);
			symbolWrapper.graphics.moveTo( 0, len);
			symbolWrapper.graphics.lineTo( 1, -len);
			addEventListener(Event.ADDED_TO_STAGE, addedToStage);
			addEventListener(Event.ENTER_FRAME, enterFrame);
		}
		
		private function enterFrame(e:Event):void 
		{
			doSprite(symbolWrapper);
		}
		
		private function doSprite(s:DisplayObject):void {
			if (s is TimelineSprite) {
				(s as TimelineSprite).update();
			}
			if (s is DisplayObjectContainer) {
				var c:DisplayObjectContainer = s as DisplayObjectContainer;
				for (var i:int = 0; i < c.numChildren;i++ ) {
					doSprite(c.getChildAt(i));
				}
			}
		}
		
		private function addedToStage(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, stage_keyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, stage_keyUp);
			stage.addEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, stage_middleMouseDown);
			stage.addEventListener(MouseEvent.MIDDLE_MOUSE_UP, stage_middleMouseUp);
		}
		
		private function stage_middleMouseDown(e:MouseEvent):void 
		{
			stage.addEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMove);
			Mouse.cursor = MouseCursor.HAND;
			startMouseX = mouseX;
			startMouseY = mouseY;
			startSymbolWrapperX = symbolWrapper.x;
			startSymbolWrapperY = symbolWrapper.y;
		}
		
		private function stage_middleMouseUp(e:MouseEvent):void 
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMove);
			Mouse.cursor = MouseCursor.ARROW;
		}
		
		private function stage_keyDown(e:KeyboardEvent):void 
		{
			if (e.keyCode==Keyboard.SPACE&&stage) {
				stage_middleMouseDown(null);
			}
		}
		private function stage_keyUp(e:KeyboardEvent):void 
		{
			if (e.keyCode==Keyboard.SPACE&&stage) {
				stage_middleMouseUp(null);
			}
		}
		private function stage_mouseMove(e:MouseEvent):void 
		{
			symbolWrapper.x = startSymbolWrapperX + mouseX - startMouseX;
			symbolWrapper.y = startSymbolWrapperY + mouseY - startMouseY;
		}
		
		public function reset(symbol:SWFSymbol, swf:SWF, tagid2bitmap:Object):void {
			depth2lastObj = { };
			symbolWrapper.x = symbolWrapper.y = 0;
			dis2name = new Dictionary;
			while (symbolWrapper.numChildren > 0) symbolWrapper.removeChildAt(0);
			this.tagid2bitmap = tagid2bitmap;
			this.swf = swf;
			this.symbol = symbol;
			deftag = Utils.getTagById(swf, symbol.tagId);
			symbolWrapper.addChild(getDisplay(deftag));
		}
		
		private function getDisplay(tag:ITag):DisplayObject {
			if (tag is TagDefineBitsLossless||tag is TagDefineBits) {
				return new IDBitmap((tag as Object).characterId,tagid2bitmap[(tag as Object).characterId]);
			}else if (tag is SWFTimelineContainer) {
				var wrapper:TimelineSprite = new TimelineSprite;
				var timeline:SWFTimelineContainer = tag as SWFTimelineContainer;
				wrapper.frames = timeline.frames;
				for each(var ctag:ITag in timeline.tags) {
					if (ctag is TagPlaceObject) {
						wrapper.tags.push(getDisplay(ctag));
					}else {
						//trace("error2",ctag);
						wrapper.tags.push(null);
					}
				}
				return wrapper;
			}else if (tag is TagPlaceObject) {
				var tagPlace:TagPlaceObject = tag as TagPlaceObject;
				ctag = Utils.getTagById(swf, tagPlace.characterId);
				var child:DisplayObject = getDisplay(ctag);
				dis2name[child] = tagPlace.instanceName;
				if (tagPlace.hasMatrix) {
					depth2lastObj[tagPlace.depth] = child;
					child.transform.matrix =new Matrix(tagPlace.matrix.scaleX,tagPlace.matrix.rotateSkew0,tagPlace.matrix.rotateSkew1, tagPlace.matrix.scaleY,tagPlace.matrix.translateX/20,tagPlace.matrix.translateY/20);
				}else if(depth2lastObj[tagPlace.depth]){
					child.transform.matrix = depth2lastObj[tagPlace.depth].transform.matrix;
				}
				return child;
			}else if (tag is TagDefineShape) {
				var tagShape:TagDefineShape = tag as TagDefineShape;
				currentShapeWrapper = new ShapeSprite;
				
				tagShape.export(this);
				currentShapeWrapper.bounds = tagShape.shapeBounds.rect;
				return currentShapeWrapper;
			}else {
				//trace("error1",tag);
			}
			return new Sprite();
		}
		
		/* INTERFACE com.codeazur.as3swf.exporters.core.IShapeExporter */
		
		public function beginShape():void 
		{
			
		}
		
		public function endShape():void 
		{
			
		}
		
		public function beginFills():void 
		{
			
		}
		
		public function endFills():void 
		{
			
		}
		
		public function beginLines():void 
		{
			
		}
		
		public function endLines():void 
		{
			
		}
		
		public function beginFill(color:uint, alpha:Number = 1):void 
		{
			
		}
		
		public function beginGradientFill(type:String, colors:Array, alphas:Array, ratios:Array, matrix:Matrix = null, spreadMethod:String = "pad", interpolationMethod:String = "rgb", focalPointRatio:Number = 0):void 
		{
			
		}
		
		public function beginBitmapFill(bitmapId:uint, matrix:Matrix = null, repeat:Boolean = true, smooth:Boolean = false):void 
		{
			var bmd:BitmapData = tagid2bitmap[bitmapId];
			if (bmd) {
				var image:IDBitmap = new IDBitmap(bitmapId,bmd,"auto",smooth);
				if (matrix) {
					image.transform.matrix = matrix;
				}
				currentShapeWrapper.addChild(image);
			}
		}
		
		public function endFill():void 
		{
			
		}
		
		public function lineStyle(thickness:Number = NaN, color:uint = 0, alpha:Number = 1, pixelHinting:Boolean = false, scaleMode:String = "normal", startCaps:String = null, endCaps:String = null, joints:String = null, miterLimit:Number = 3):void 
		{
			
		}
		
		public function lineGradientStyle(type:String, colors:Array, alphas:Array, ratios:Array, matrix:Matrix = null, spreadMethod:String = "pad", interpolationMethod:String = "rgb", focalPointRatio:Number = 0):void 
		{
			
		}
		
		public function moveTo(x:Number, y:Number):void 
		{
			
		}
		
		public function lineTo(x:Number, y:Number):void 
		{
			
		}
		
		public function curveTo(controlX:Number, controlY:Number, anchorX:Number, anchorY:Number):void 
		{
			
		}
		
		
		
	}

}