package lz.tools 
{
	import adobe.utils.CustomActions;
	import com.codeazur.as3swf.SWF;
	import com.codeazur.as3swf.tags.IDefinitionTag;
	import com.codeazur.as3swf.tags.ITag;
	import com.codeazur.as3swf.tags.TagPlaceObject;
	import com.codeazur.as3swf.timeline.Frame;
	import com.codeazur.as3swf.timeline.FrameObject;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import nochump.util.zip.ZipEntry;
	import nochump.util.zip.ZipOutput;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Utils 
	{
		public static function getTagById(swf:SWF, id:int):IDefinitionTag {
			for each(var tag:ITag in swf.tags) {
				if (tag is IDefinitionTag) {
					var deftag:IDefinitionTag = tag as IDefinitionTag;
					if (deftag.characterId==id) {
						return deftag;
					}
				}
			}
			return null;
		}
		
		public static function export(disobj:DisplayObject,dis2name:Dictionary,writeBounds:Boolean):Object {
			if(disobj)
			var m:Array = [disobj.transform.matrix.a, disobj.transform.matrix.b, disobj.transform.matrix.c, disobj.transform.matrix.d, disobj.transform.matrix.tx, disobj.transform.matrix.ty];
			if (disobj is IDBitmap) {
				var retArr:Object = { id:(disobj as IDBitmap).id, t:Type.BITMAP, m:m };
			}else if (disobj is TimelineSprite) {
				var timeline:TimelineSprite = disobj as TimelineSprite;
				var obj:Object = { t:Type.TIMELINE, c:[], f:[],m:m };
				for (var i:int = 0; i < timeline.tags.length;i++ ) {
					obj.c[i] = export(timeline.tags[i],dis2name,writeBounds);
				}
				for (i = 0; i < timeline.frames.length;i++ ) {
					var frame:Frame = timeline.frames[i];
					var o:Array = [];
					obj.f.push(o);
					var objc:Array = [];
					for each(var fo:FrameObject in frame.objects) {
						objc.push(fo);
					}
					objc.sortOn("depth", Array.NUMERIC);
					for each(fo in objc)
					o.push([fo.placedAtIndex,fo.lastModifiedAtIndex]);
				}
				retArr = obj;
			}else if (disobj is Sprite) {
				var wrapper:Sprite = disobj as Sprite;
				obj = { t:Type.SPRITE, c:[], m:m };
				if (wrapper is ShapeSprite) {
					var ss:ShapeSprite = wrapper as ShapeSprite;
					var bounds:Rectangle = ss.bounds;
					obj.b = [bounds.x,bounds.y,bounds.width,bounds.height];
				}
				for (i = 0; i < wrapper.numChildren;i++ ) {
					var child:DisplayObject = wrapper.getChildAt(i);
					obj.c.push(export(child,dis2name,writeBounds));
				}
				retArr = obj;
			}
			if (retArr && dis2name[disobj]) {
				retArr.n = dis2name[disobj];
			}
			return retArr;
		}
		
		public static function tozip(files:Vector.<ExportData>):ByteArray {
			var out:ZipOutput = new ZipOutput;
			for each(var file:ExportData in files) {
				var entry:ZipEntry = new ZipEntry(file.name);
				out.putNextEntry(entry);
				out.write(file.getBytes());
				out.closeEntry();
			}
			out.finish();
			return out.byteArray;
		}
	}

}