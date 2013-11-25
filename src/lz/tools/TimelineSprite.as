package lz.tools 
{
	import com.codeazur.as3swf.timeline.Frame;
	import com.codeazur.as3swf.timeline.FrameObject;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TimelineSprite extends Sprite
	{
		public var tags:Array=[];
		public var frames:Vector.<Frame>;
		public var frame:int;
		public function TimelineSprite() 
		{
			
		}
		
		public function update():void {
			while (numChildren > 0) {
				removeChildAt(0);
			}
			var cframe:int = frame % frames.length;
			var objs:Array = [];
			for each(var obj:FrameObject in frames[cframe].objects) {
				objs.push(obj);
			}
			objs.sortOn("depth", Array.NUMERIC);
			for each(obj in objs) {
				var dis:DisplayObject = tags[obj.placedAtIndex];
				var tdis:DisplayObject = tags[obj.lastModifiedAtIndex];
				if (dis) {
					if(obj.lastModifiedAtIndex)
					dis.transform.matrix = tdis.transform.matrix;
					addChild(dis);
				}
			}
			frame++;
		}
	}

}