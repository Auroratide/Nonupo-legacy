package{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.events.Event;
	public class StartGame extends MovieClip{
		var buttonText:TextField;
		var buttonFormat:TextFormat;
		var buttonBase:ButtonBase;
		function StartGame(){
			buttonFormat = new TextFormat(Document.segoeEmbed.fontName, 18, 0x444444);
			buttonFormat.align = "center";
			buttonText = new TextField();
			buttonText.selectable = false;
			buttonText.embedFonts = true;
			buttonText.defaultTextFormat = buttonFormat;
			buttonText.text = "Play";
			buttonText.y = -2;
			buttonText.width = 160;
			
			buttonBase = new ButtonBase(160,40);
			this.addChild(buttonBase);
			this.addChild(buttonText);
			buttonBase.addEventListener("enterFrame",buttonBase.idleAnimation);
			addEventListener("mouseOver",buttonBase.hoverAnimation);
		}
	}
}