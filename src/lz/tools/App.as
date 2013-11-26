package lz.tools 
{
	import com.bit101.components.PushButton;
	import com.codeazur.as3swf.SWF;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	/**
	 * ...
	 * @author lizhi
	 */
	public class App extends Sprite
	{
		private var file:FileReference;
		private var swfTree:SwfTree = new SwfTree;
		
		private var waitSaves:Vector.<ExportData>;
		public function App() 
		{
			addChild(swfTree);
			swfTree.y = 30;
			new PushButton(this, 10, 10, "openswf", openswf);
			new PushButton(this, 120, 10, "export", export);
		}
		
		private function export(e:Event):void 
		{
			waitSaves = swfTree.export();
			saveOne();
		}
		
		private function saveOne():void {
			if (waitSaves.length) {
				var data:ExportData = waitSaves.pop();
				var file:FileReference = new FileReference;
				file.save(data.data, data.name);
				file.addEventListener(Event.COMPLETE, save_file_complete);
			}
		}
		
		private function save_file_complete(e:Event):void 
		{
			saveOne();
		}
		
		private function openswf(e:Event):void 
		{
			file = new FileReference;
			file.browse([new FileFilter("swf","*.swf"),new FileFilter("*","*.*")]);
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