package{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.events.Event;
	
	public class OrientText extends MovieClip{
		var field:TextField;
		var format:TextFormat;
		var time:Number;
		var originalX:Number;
		var originalY:Number;
		function OrientText(letter:String, alignment:String, xPlace:Number = -75, yPlace:Number = -40){
			format = new TextFormat(Document.segoeEmbed.fontName, 14, 0x444444);
			format.align = alignment;
			field = new TextField();
			field.embedFonts = true;
			field.selectable = false;
			field.defaultTextFormat = format;
			field.text = letter;
			field.autoSize = alignment;
			this.addChild(field);
			this.alpha = 0;
			this.x = xPlace;
			this.y = yPlace;
			originalX = xPlace;
			originalY = yPlace;
			time = 0;
		}
		
		function performWhip(type:String, delay:Number):void{
			time = -delay;
			if(type == "right") addEventListener("enterFrame",whipRight);
			else if(type == "down") addEventListener("enterFrame",whipDown);
		}
		function whipRight(e:Event):void{
			time++;
			if(time > 0) this.alpha += .066;
			if(time != 12 && time > 0) this.x -= Math.abs(time-12) / (time - 12);
			if(time >= 15){
				time = 0;
				this.alpha = 1;
				this.x = originalX + 8;
				removeEventListener("enterFrame",whipRight);
			}
		}
		function whipDown(e:Event):void{
			time++;
			if(time > 0) this.alpha += .066;
			if(time != 12 && time > 0) this.y -= Math.abs(time-12) / (time - 12);
			if(time >= 15){
				time = 0;
				this.alpha = 1;
				this.y = originalY + 8;
				removeEventListener("enterFrame",whipDown);
			}
		}
	}
}