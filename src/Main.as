package 
{
	import flash.display.Sprite;
	import flash.external.ExternalInterface;
	import lz.tools.App;
	
	/**
	 * ...
	 * @author lizhi
	 */
	public class Main extends Sprite 
	{
		
		public function Main():void 
		{
			var app:App = new App();
			addChild (app);
			if (ExternalInterface.available) {
				ExternalInterface.addCallback("openSwfFromBase64", app.openSwfFromBase64);
			}
		}
		
	}
	
}