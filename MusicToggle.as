package{
	import flash.display.MovieClip;
	import flash.filters.GlowFilter;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class MusicToggle extends MovieClip{
		var isMusicOn:Boolean;
		var glowHover:GlowFilter;
		function MusicToggle(){
			this.stop();
			isMusicOn = true;
			glowHover = new GlowFilter(0x39C0DB,0,2,2);
			this.filters = [glowHover];
			
			addEventListener("mouseOver", mouseHover);
		}
		
		function mouseHover(e:MouseEvent):void{
			removeEventListener("enterFrame",decreaseGlowHover);
			addEventListener("enterFrame",increaseGlowHover);
			addEventListener("mouseOut",mouseAway);
			addEventListener("mouseUp",toggleMusic);
		}
		function mouseAway(e:MouseEvent):void{
			removeEventListener("enterFrame",increaseGlowHover);
			removeEventListener("mouseUp",toggleMusic);
			removeEventListener("mouseOut",mouseAway);
			addEventListener("enterFrame",decreaseGlowHover);
		}
		function toggleMusic(e:MouseEvent):void{
			if(isMusicOn){
				Document.musicMenu.addEventListener("enterFrame", Document.musicMenu.musicFadeOut);
				this.gotoAndStop(2);
			}
			else{
				Document.musicMenu.playMusic(Document.musicMenu.songSelected);
				this.gotoAndStop(1);
			}
			isMusicOn = !isMusicOn;
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
		
		/** Fade the music out 
		function musicFadeOut(e:Event):void{
			removeEventListener("mouseUp",toggleMusic); // So that this isn't clicked while fading is occurring
			Document.bgmSoundTransform.volume -= .1;
			Document.bgmSoundChannel.soundTransform = Document.bgmSoundTransform;
			if(Document.bgmSoundTransform.volume <= 0){
				Document.bgmSoundTransform.volume = 0;
				Document.bgmSoundChannel.stop();
				removeEventListener("enterFrame",musicFadeOut);
				if(hasEventListener("mouseOut"))
					addEventListener("mouseUp",toggleMusic); // Make clickable if mouse hasn't moved away yet
			}
		}
		/*  */
		
		/** Fade the music in
			Not much of a fade, since the song starts from beginning anyway
		function musicFadeIn():void{
			Document.bgmSoundTransform.volume = 1;
			Document.bgmSoundChannel.soundTransform = Document.bgmSoundTransform;
			Document.bgmSoundChannel = Document.musicFairyTale.play();
		}
		/*  */
	}
}