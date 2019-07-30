package{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	
	public class TextButton extends MovieClip{
		var theText:TextField;
		var textFormat:TextFormat;
		var isSelected:Boolean;
		var isURL:Boolean;
		var glowHover:GlowFilter;
		function TextButton(isSelectedTemp:Boolean = false, fontSize:Number = 12){
			isSelected = isSelectedTemp;
			textFormat = new TextFormat(Document.segoeEmbed.fontName, fontSize, 0x444444);
			// textFormat.align = "center";
			
			theText = new TextField();
			theText.selectable = false;
			theText.embedFonts = true;
			theText.defaultTextFormat = textFormat;
			theText.width = 1;
			theText.height = Math.floor(fontSize * 1.67);
			
			this.addChild(theText);
			
			if(!isSelected) glowHover = new GlowFilter(0x39C0DB,0,2,2);
			else glowHover = new GlowFilter(0xA6A6A6,1,2,2);
			theText.filters = [glowHover];
			
			if(!isSelected) addEventListener("mouseOver",mouseHover);
			isURL = false;
		}
		
		/* The Mouse Functions
		===============================*/
		function mouseHover(e:MouseEvent):void{
			removeEventListener("enterFrame",decreaseGlowHover);
			addEventListener("enterFrame",increaseGlowHover);
			addEventListener("mouseOut",mouseAway);
			if(!isURL) addEventListener("mouseUp",applySelectedGlow);
		}
		
		function mouseAway(e:MouseEvent):void{
			removeEventListener("enterFrame",increaseGlowHover);
			addEventListener("enterFrame",decreaseGlowHover);
		}
		
		function applySelectedGlow(e:MouseEvent):void{
			removeEventListener("mouseUp",applySelectedGlow);
			removeEventListener("mouseOver",mouseHover);
			removeEventListener("enterFrame",increaseGlowHover);
			removeEventListener("mouseOut",mouseAway);
			addEventListener("enterFrame",increaseSelectedGlow);
		}
		
		// Useful if you do not want the selection glow
		function mouseHoverNoSelect(e:MouseEvent):void{
			removeEventListener("enterFrame",decreaseGlowHover);
			addEventListener("enterFrame",increaseGlowHover);
			addEventListener("mouseOut",mouseAway);
		}
		
		/* The EnterFrame Functions
		===============================*/
		function increaseGlowHover(e:Event):void{
			if(glowHover.alpha < .75) glowHover.alpha += .05;
			else removeEventListener("enterFrame",increaseGlowHover);
			theText.filters = [glowHover];
		}
		
		function decreaseGlowHover(e:Event):void{
			if(glowHover.alpha > 0) glowHover.alpha -= .05;
			else removeEventListener("enterFrame",decreaseGlowHover);
			theText.filters = [glowHover];
		}
		
		function increaseSelectedGlow(e:Event):void{
			if(glowHover.alpha < 1) glowHover.alpha += .05;
			if(glowHover.color < 0xA6A6A6) glowHover.color += 0x0A0000 - 0x000205;
			if(glowHover.color > 0xA6A6A6) glowHover.color = 0xA6A6A6;
			if(glowHover.color == 0xA6A6A6 && glowHover.alpha >= 1) removeEventListener("enterFrame",increaseSelectedGlow);
			theText.filters = [glowHover];
		}
		
		function decreaseSelectedGlow(e:Event):void{
			if(glowHover.alpha > 0) glowHover.alpha -= .1;
			if(glowHover.color > 0x39C0DB) glowHover.color += 0x000205 - 0x0A0000;
			if(glowHover.color < 0x39C0DB) glowHover.color = 0x39C0DB;
			if(glowHover.color == 0x39C0DB) removeEventListener("enterFrame",decreaseSelectedGlow);
			theText.filters = [glowHover];
		}
		
		/*function calculateWidth():Number{
			var fontSize:Object = textFormat.size;
		}*/
	}
}