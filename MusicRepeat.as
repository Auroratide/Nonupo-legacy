package{
	import flash.display.MovieClip;
	import flash.filters.GlowFilter;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class MusicRepeat extends MovieClip{
		var isRepeatOn:Boolean;
		var glowHover:GlowFilter;
		function MusicRepeat(){
			isRepeatOn = false;
			glowHover = new GlowFilter(0x39C0DB,0,2,2);
			this.filters = [glowHover];
			
			addEventListener("mouseOver", mouseHover);
		}
		
		function mouseHover(e:MouseEvent):void{
			removeEventListener("enterFrame",decreaseGlowHover);
			addEventListener("enterFrame",increaseGlowHover);
			addEventListener("mouseOut",mouseAway);
			addEventListener("mouseUp",toggleRepeat);
		}
		function mouseAway(e:MouseEvent):void{
			removeEventListener("enterFrame",increaseGlowHover);
			removeEventListener("mouseUp",toggleRepeat);
			removeEventListener("mouseOut",mouseAway);
			addEventListener("enterFrame",decreaseGlowHover);
		}
		function increaseGlowHover(e:Event):void{
			if(glowHover.alpha < .75) glowHover.alpha += .05;
			else removeEventListener("enterFrame",increaseGlowHover);
			this.filters = [glowHover];
		}
		function decreaseGlowHover(e:Event):void{
			if(glowHover.alpha > 0) glowHover.alpha -= .05;
			else removeEventListener("enterFrame",decreaseGlowHover);
			this.filters = [glowHover];
		}
		function toggleRepeat(e:MouseEvent):void{
			if(isRepeatOn) removeEventListener("enterFrame", rotateThis);
			else addEventListener("enterFrame", rotateThis);
			isRepeatOn = !isRepeatOn;
		}
		
		/** Rotates the object slowly; no need for a fade */
		function rotateThis(e:Event):void{
			this.rotation = this.rotation % 360 + 2;
		}
	}
}