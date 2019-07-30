package{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class InputField extends MovieClip{
		var field:TextField;
		var textFormat:TextFormat;
		function InputField(){
			textFormat = new TextFormat(Document.segoeEmbed.fontName, 24, 0x444444);
			field = new TextField;
			field.embedFonts = true;
			field.defaultTextFormat = textFormat;
			field.width = 240;
			field.height = 50;
			field.type = "input";
			field.maxChars = 15;
			field.restrict = "A-Za-z0-9 !@#$%\\^&*()-=+<>?:,./;[]~";
			this.addChild(field);
			field.x = 5;
		}
	}
}