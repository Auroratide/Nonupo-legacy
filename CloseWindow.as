package{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class CloseWindow extends MovieClip{
		var closeText:TextField;
		var textFormat:TextFormat;
		var buttonBase:ButtonBase;
		function CloseWindow(){
			closeText = new TextField();
			closeText.embedFonts = true;
			var textFormat:TextFormat = new TextFormat(Document.segoeEmbed.fontName, 22, 0x444444);
			textFormat.align = "center";
			closeText.defaultTextFormat = textFormat;
			closeText.selectable = false;
			closeText.width = 180;
			closeText.y = -2;
			
			buttonBase = new ButtonBase(180,45);
			this.addChild(buttonBase);
			this.addChild(closeText);
		}
	}
}