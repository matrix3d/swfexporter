package lz.tools 
{
	import com.bit101.components.PushButton;
	import com.codeazur.as3swf.SWF;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.FileReference;
	/**
	 * ...
	 * @author lizhi
	 */
	public class App extends Sprite
	{
		private var file:FileReference;
		private var swfTree:SwfTree=new SwfTree;
		public function App() 
		{
			new PushButton(this, 10, 10, "openswf", openswf);
			addChild(swfTree);
			swfTree.y = 30;
		}
		
		private function openswf(e:Event):void 
		{
			file = new FileReference;
			file.browse();
			file.addEventListener(Event.SELECT, file_select);
		}
		
		private function file_select(e:Event):void 
		{
			file.load();
			file.addEventListener(Event.COMPLETE, file_complete);
		}
		
		private function file_complete(e:Event):void 
		{
			swfTree.reset(new SWF(file.data));
		}
		
	}

}