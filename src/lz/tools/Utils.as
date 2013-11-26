package lz.tools 
{
	import com.codeazur.as3swf.SWF;
	import com.codeazur.as3swf.tags.IDefinitionTag;
	import com.codeazur.as3swf.tags.ITag;
	import com.codeazur.as3swf.tags.TagPlaceObject;
	import com.codeazur.as3swf.timeline.Frame;
	import com.codeazur.as3swf.timeline.FrameObject;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.utils.ByteArray;
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
		
		public static function export(disobj:DisplayObject):Object {
			if (disobj is IDBitmap) {
				return {id:(disobj as IDBitmap).id,t:Type.BITMAP};
			}else if (disobj is TimelineSprite) {
				var timeline:TimelineSprite = disobj as TimelineSprite;
				var obj:Object = { t:Type.TIMELINE, c:[], f:[] };
				for (var i:int = 0; i < timeline.tags.length;i++ ) {
					obj.c[i] = export(timeline.tags[i]);
				}
				for (i = 0; i < timeline.frames.length;i++ ) {
					var frame:Frame = timeline.frames[i];
					var o:Array = [];
					obj.f.push(o);
					for each(var fo:FrameObject in frame.objects) {
						o.push({i:fo.placedAtIndex,mi:fo.lastModifiedAtIndex});
					}
				}
				return obj;
			}else if (disobj is Sprite) {
				var wrapper:Sprite = disobj as Sprite;
				obj = {t:Type.SPRITE,c:[]};
				for (i = 0; i < wrapper.numChildren;i++ ) {
					var child:DisplayObject = wrapper.getChildAt(i);
					obj.c.push(export(child));
				}
				return obj;
			}
			return null;
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