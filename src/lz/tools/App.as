package lz.tools 
{
	CONFIG::air{
	import flash.desktop.NativeDragManager;
	import flash.events.NativeDragEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	}
	import com.bit101.components.PushButton;
	import com.codeazur.as3swf.SWF;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.FileReferenceList;
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author lizhi
	 */
	public class App extends Sprite
	{
		private var file:FileReference;
		private var swfTree:SwfTree = new SwfTree;
		
		public function App() 
		{
			if (stage)
			addedToStage(null);
			else
			addEventListener(Event.ADDED_TO_STAGE, addedToStage);
			
			addChild(swfTree);
			swfTree.y = 30;
			new PushButton(this, 10, 10, "openswf", openswf);
			new PushButton(this, 120, 10, "export", export);
		}
		
		private function addedToStage(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
			stage.align=StageAlign.TOP_LEFT;
			stage.scaleMode=StageScaleMode.NO_SCALE;
			CONFIG::air{
			addDragOpen();
			}
		}
		
		CONFIG::air{
		private function addDragOpen():void 
		{
			addEventListener(NativeDragEvent.NATIVE_DRAG_ENTER, nativeDragEnterHandler);
			addEventListener(NativeDragEvent.NATIVE_DRAG_DROP, nativeDragDropHandler);
		}
		private function nativeDragEnterHandler(event:NativeDragEvent):void {
			NativeDragManager.acceptDragDrop(this);
		}

		private function nativeDragDropHandler(event:NativeDragEvent):void {
			var data:Array=event.clipboard.formats;
			for each(var type:String in data){
				doFiles(event.clipboard.getData(type));
			}
		}
		
		private function doFiles(files:Object):void{
			for each(var file:File in files){
				if(file.isDirectory){
					continue;
				}
				var bytes:ByteArray = getBytesFromFile(file);
				swfTree.reset(new SWF(bytes));
				save(Utils.tozip(swfTree.export()), file.parent.url+"/"+file.name+".zip");
			}
		}
		
		private function getBytesFromFile(file:File,bytes:ByteArray=null):ByteArray{
			bytes=bytes||new ByteArray();
			var fs:FileStream=new FileStream();
			fs.open(file,FileMode.READ);
			fs.readBytes(bytes);
			fs.close();
			return bytes;
		}
		
		private function save(bytes:ByteArray,url:String):void{
			var file:File=new File(url);
			var fs:FileStream=new FileStream();
			fs.open(file,FileMode.WRITE);
			fs.writeBytes(bytes);
			fs.close();
		}
		}
		
		private function export(e:Event):void 
		{
			var file:FileReference = new FileReference;
			file.save(Utils.tozip(swfTree.export()), this.file.name+".zip");
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