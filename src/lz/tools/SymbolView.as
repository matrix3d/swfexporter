package lz.tools 
{
	import com.codeazur.as3swf.data.SWFSymbol;
	import com.codeazur.as3swf.SWF;
	import com.codeazur.as3swf.SWFTimelineContainer;
	import com.codeazur.as3swf.tags.IDefinitionTag;
	import com.codeazur.as3swf.tags.ITag;
	import com.codeazur.as3swf.tags.TagDefineSprite;
	import com.codeazur.as3swf.tags.TagPlaceObject;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author lizhi
	 */
	public class SymbolView extends Sprite
	{
		private var symbol:SWFSymbol;
		private var swf:SWF;
		private var tag2bitmap:Dictionary;
		private var deftag:IDefinitionTag;
		private var symbolWrapper:Sprite = new Sprite;
		public function SymbolView() 
		{
			addChild(symbolWrapper);
		}
		
		public function reset(symbol:SWFSymbol, swf:SWF, tag2bitmap:Dictionary):void {
			while (symbolWrapper.numChildren > 0) symbolWrapper.removeChildAt(0);
			this.tag2bitmap = tag2bitmap;
			this.swf = swf;
			this.symbol = symbol;
			deftag = SwfUtil.getTagById(swf,symbol.tagId);
			var bmd:BitmapData = tag2bitmap[deftag];
			if (bmd) {
				symbolWrapper.addChild(new Bitmap(bmd));
			}else if (deftag is SWFTimelineContainer) {
				var timeline:SWFTimelineContainer = deftag as SWFTimelineContainer;
				for each(var tag:ITag in timeline.tags) {
					if (tag is TagPlaceObject) {
						var tagPlace:TagPlaceObject = tag as TagPlaceObject;
						symbolWrapper.addChild(getDisplay(tagPlace));
					}
				}
			}
		}
		
		private function getDisplay(place:TagPlaceObject):DisplayObjectContainer {
			var dtag:ITag = SwfUtil.getTagById(swf,place.characterId);
			var bmd:BitmapData = tag2bitmap[dtag];
			var wrapper:Sprite = new Sprite;
			if (bmd) {
				var image:Bitmap = new Bitmap(bmd);
				wrapper.addChild(image);
				if (tagPlace.hasMatrix) {
					image.transform.matrix =new Matrix(tagPlace.matrix.scaleX,tagPlace.matrix.rotateSkew0,tagPlace.matrix.rotateSkew1, tagPlace.matrix.scaleY,tagPlace.matrix.translateX/20,tagPlace.matrix.translateY/20);
				}
			}else if (dtag is SWFTimelineContainer) {
				var timeline:SWFTimelineContainer = dtag as SWFTimelineContainer;
				for each(var tag:ITag in timeline.tags) {
					if (tag is TagPlaceObject) {
						var tagPlace:TagPlaceObject = tag as TagPlaceObject;
						wrapper.addChild(getDisplay(tagPlace));
					}
				}
			}else if (dtag is TagPlaceObject) {
				wrapper.addChild(getDisplay(dtag as TagPlaceObject));
			}
			return wrapper;
		}
		
	}

}