package lz.tools 
{
	import adobe.utils.CustomActions;
	import com.bit101.components.List;
	import com.codeazur.as3swf.data.SWFSymbol;
	import com.codeazur.as3swf.SWF;
	import com.codeazur.as3swf.tags.ITag;
	import com.codeazur.as3swf.tags.TagDefineBits;
	import com.codeazur.as3swf.tags.TagDefineBitsLossless2;
	import com.codeazur.as3swf.tags.TagSymbolClass;
	import flash.display.BitmapData;
	import flash.display.PNGEncoderOptions;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author lizhi
	 */
	public class SwfTree extends Sprite
	{
		private var swf:SWF;
		private var menu:List;
		private var symbolTag:TagSymbolClass;
		private var symbolView:SymbolView = new SymbolView;
		private var tagid2bitmap:Object;
		public function SwfTree() 
		{
			addChild(symbolView);
			symbolView.x = 410;
			symbolView.y = 210;
			menu = new List(this, 10, 10, ["1", "2"]);
			menu.setSize(200, 200);
			menu.addEventListener(Event.SELECT, menu_select);
		}
		
		private function menu_select(e:Event):void 
		{
			if (swf&&symbolTag) {
				for each(var symbol:SWFSymbol in symbolTag.symbols) {
					if (menu.selectedItem == symbol.name) {
						symbolView.reset(symbol, swf,tagid2bitmap);
						break;
					}
				}
			}
		}
		
		public function reset(swf:SWF):void {
			this.swf = swf;
			//trace(swf);
			tagid2bitmap = { };
			menu.removeAll();
			for each(var tag:ITag in swf.tags) {
				if (tag is TagSymbolClass) {
					symbolTag = tag as TagSymbolClass;
					for each(var symbol:SWFSymbol in symbolTag.symbols) {
						menu.addItem(symbol.name);
					}
				}else if (tag is TagDefineBitsLossless2) {
					var bits2:TagDefineBitsLossless2 = tag as TagDefineBitsLossless2;
					var image:BitmapData = new BitmapData(bits2.bitmapWidth, bits2.bitmapHeight, true, 0);
					bits2.zlibBitmapData.uncompress();
					image.setPixels(image.rect, bits2.zlibBitmapData);
					tagid2bitmap[bits2.characterId] = image;
					//trace(bits2.characterId);
				}else if (tag is TagDefineBits) {
					var tagdb:TagDefineBits = tag as TagDefineBits;
					var exp:ExportBitmapOver = new ExportBitmapOver;
					exp.tag = tagdb;
					exp.tagid2bitmap = tagid2bitmap;
					tagdb.exportBitmapData(exp.onover);
				}
			}
		}
		
		public function export():Vector.<ExportData> {
			var pack:PackUtils = new PackUtils;
			pack.pack(tagid2bitmap);
			
			var obj:Object = { };
			if(symbolTag)
			for each(var symbol:SWFSymbol in symbolTag.symbols) {
				symbolView.reset(symbol, swf, tagid2bitmap);
				obj[symbol.name] = Utils.export(symbolView.symbolWrapper.getChildAt(0),symbolView.dis2name,symbol.name.indexOf("bounds")==0);
			}
			return Vector.<ExportData>([
				new ExportData("sheet.png", pack.packbmd.encode(pack.packbmd.rect, new PNGEncoderOptions())),
				new ExportData("objs.json", JSON.stringify(obj)),
				new ExportData("sheet.json", JSON.stringify(pack.config))
			]);
		}
	}
}
import com.codeazur.as3swf.tags.ITag;
import com.codeazur.as3swf.tags.TagDefineBits;
import com.codeazur.as3swf.tags.TagDefineBitsJPEG3;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.events.Event;
import flash.utils.ByteArray;
import flash.utils.Dictionary;

class ExportBitmapOver {
	public var tagid2bitmap:Object;
	public var tag:TagDefineBits;
	public function onover(bmd:BitmapData):void {
		tagid2bitmap[tag.characterId] = bmd;
		if (tag is TagDefineBitsJPEG3) {
			var jpg3:TagDefineBitsJPEG3 = tag as TagDefineBitsJPEG3;
			if (jpg3.bitmapAlphaData.bytesAvailable>0) {
				jpg3.bitmapAlphaData.uncompress();
				bmd.unlock();
				var bd:ByteArray = bmd.getPixels(bmd.rect);
				for (var i:int = 0, len:int = jpg3.bitmapAlphaData.length; i < len; i ++ ) {
					bd[i * 4] = jpg3.bitmapAlphaData[i];
				}
				bd.position = 0;
				bmd.setPixels(bmd.rect, bd);
				bmd.unlock();
			}
		}
	}
}