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
			for each(var obj:FrameObject in frames[cframe].objects) {
				var dis:DisplayObject = tags[obj.placedAtIndex];
				if (dis) {
					addChild(dis);
				}else {
					trace("d");
				}
			}
			frame++;
		}
	}

}