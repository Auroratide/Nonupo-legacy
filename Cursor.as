package{
	import flash.display.MovieClip;
	import flash.events.Event;
	
	public class Cursor extends MovieClip{
		function Cursor(){
			addEventListener("enterFrame",relocateCursor);
		}
		function relocateCursor(e:Event):void{
			this.x = stage.mouseX;
			this.y = stage.mouseY;
		}
	}
}