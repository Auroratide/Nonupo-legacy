package{
	import flash.display.MovieClip;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.text.TextFormat;

	public class TextURL extends TextButton{
		var hyperlink:URLRequest;
		var altTextFormat:TextFormat;
		function TextURL(fontSize:Number = 12){
			hyperlink = new URLRequest();
			addEventListener(MouseEvent.MOUSE_UP, gotoURL);
			altTextFormat = new TextFormat(Document.segoeEmbed.fontName, fontSize, 0x444444);
			theText.defaultTextFormat = altTextFormat;
			isURL = true;
		}
		function gotoURL(e:MouseEvent):void{
			navigateToURL(hyperlink, "_blank");
			addEventListener(Event.ENTER_FRAME, decreaseGlowHover);
		}
	}
}