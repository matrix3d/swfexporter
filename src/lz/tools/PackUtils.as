package lz.tools 
{
	import com.codeazur.as3swf.tags.IDefinitionTag;
	import com.codeazur.as3swf.tags.ITag;
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import org.villekoskela.utils.RectanglePacker;
	/**
	 * ...
	 * @author lizhi
	 */
	public class PackUtils 
	{
		public var packbmd:BitmapData;
		public var config:Object;
		public function PackUtils() 
		{
			
		}
		
		public function pack(tagid2bitmap:Object):void {
			config = {};
			var c:int = 0;
			for each(var obj:Object in tagid2bitmap) {
				c++;
			}
			for (var w:int = 2;;w*=2 ) {
				var rp:RectanglePacker=new RectanglePacker(w,w);
				for(var id:String in tagid2bitmap){
					var bmd:BitmapData = tagid2bitmap[id];
					rp.insertRectangle(bmd.width+1,bmd.height+1,int(id));
				}
				rp.packRectangles();
				if (rp.rectangleCount==c) {
					break;
				}
			}
			
			packbmd=new BitmapData(w,w,true,0);
			packbmd.lock();
			var rect:Rectangle = new Rectangle();
			for (var i:int = 0; i < rp.rectangleCount; i++) {
				rp.getRectangle(i, rect);
				var idi:int = rp.getRectangleId(i);
				bmd = tagid2bitmap[idi];
				var byte:ByteArray = bmd.getPixels(bmd.rect);
				byte.position = 0;
				rect.width -= 1;
				rect.height -= 1;
				packbmd.setPixels(rect, byte);
				config[idi]=[rect.x,rect.y,rect.width,rect.height];
			}
			packbmd.unlock();
		}
		
	}

}