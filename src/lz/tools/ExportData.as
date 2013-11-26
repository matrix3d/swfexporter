package lz.tools 
{
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author lizhi
	 */
	public class ExportData 
	{
		public var name:String;
		public var data:Object;
		public function ExportData(name:String,data:Object) 
		{
			this.data = data;
			this.name = name;
			
		}
		
		public function getBytes():ByteArray {
			if (data is ByteArray) {
				return data as ByteArray;
			}
			
			var b:ByteArray = new ByteArray;
			b.writeMultiByte(data+"", "utf-8");
			return b;
		}
		
	}

}