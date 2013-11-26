package lz.tools 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	/**
	 * ...
	 * @author lizhi
	 */
	public class IDBitmap extends Bitmap
	{
		public var id:int;
		
		public function IDBitmap(id:int,bitmapData:BitmapData=null, pixelSnapping:String="auto", smoothing:Boolean=false) 
		{
			super(bitmapData, pixelSnapping, smoothing);
			this.id = id;
			
		}
		
	}

}