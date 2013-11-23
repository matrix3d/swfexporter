package lz.tools 
{
	import com.codeazur.as3swf.SWF;
	import com.codeazur.as3swf.tags.IDefinitionTag;
	import com.codeazur.as3swf.tags.ITag;
	/**
	 * ...
	 * @author lizhi
	 */
	public class SwfUtil 
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
		
	}

}