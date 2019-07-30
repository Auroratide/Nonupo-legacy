package{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class MusicMenu extends MovieClip{
		var musicToggle:MusicToggle;
		var musicRepeat:MusicRepeat;
		var song1Text:TextButton;
		var song2Text:TextButton;
		var song3Text:TextButton;
		var songFormat:TextFormat;
		
		var songSelected:Number;
		function MusicMenu(){
			musicToggle = new MusicToggle();
			this.addChild(musicToggle);
			musicRepeat = new MusicRepeat();
			this.addChild(musicRepeat);
			musicRepeat.x = 100;
			musicRepeat.y = 10;
			
			song1Text = new TextButton(true,14);
			this.addChild(song1Text);
			initializeText(song1Text,1);
			
			song2Text = new TextButton(false,14);
			this.addChild(song2Text);
			initializeText(song2Text,2);
			
			song3Text = new TextButton(false,14);
			this.addChild(song3Text);
			initializeText(song3Text,3);
			
			songSelected = 1;
			
			song2Text.addEventListener("mouseUp", activateSong2);
			song3Text.addEventListener("mouseUp", activateSong3);
		}
		
		function initializeText(field:TextButton,num:Number):void{
			field.theText.text = String(num);
			field.x = 20*num+10;
			field.y = -5;
			field.theText.width = 14;
			var fieldMask:Sprite = new Sprite();
			fieldMask.graphics.beginFill(0xFF0000);
			fieldMask.graphics.drawRect(field.x,field.y+8,14,14);
			this.addChild(fieldMask);
			field.mask = fieldMask;
		}
		
		function activateSong1(e:MouseEvent):void{
			switchSongs(1);
		}
		function activateSong2(e:MouseEvent):void{
			switchSongs(2);
		}
		function activateSong3(e:MouseEvent):void{
			switchSongs(3);
		}
		
		/** Manuel click of the song */
		function switchSongs(song:Number):void{
			// Don't forget to remove soundComplete listener!
			var oldSong:TextButton;
			if(song1Text.isSelected) oldSong = song1Text;
			else if(song2Text.isSelected) oldSong = song2Text;
			else oldSong = song3Text;
			fadeOldSong(oldSong);
			songSelected = song;
			oldSong.isSelected = false;
			switch(song){
				case 1: song1Text.isSelected = true; song1Text.removeEventListener("mouseUp",activateSong1); break;
				case 2: song2Text.isSelected = true; song2Text.removeEventListener("mouseUp",activateSong2); break;
				case 3: song3Text.isSelected = true; song3Text.removeEventListener("mouseUp",activateSong3); break;
				default: song1Text.isSelected = true; song1Text.removeEventListener("mouseUp",activateSong1); break;
			}
		}
		
		function fadeOldSong(song:TextButton):void{
			if(song == song1Text)
				song.addEventListener("mouseUp", activateSong1);
			else if(song == song2Text)
				song.addEventListener("mouseUp", activateSong2);
			else
				song.addEventListener("mouseUp", activateSong3);
			if(!musicRepeat.isRepeatOn) song.addEventListener("enterFrame", song.decreaseSelectedGlow);
			song.addEventListener("mouseOver", song.mouseHover);
			addEventListener("enterFrame", musicFadeOut);
		}
		
		/** Fade the music out */
		function musicFadeOut(e:Event):void{
			musicToggle.removeEventListener("mouseUp",musicToggle.toggleMusic); // So that this isn't clicked while fading is occurring
			Document.bgmSoundTransform.volume -= .1;
			Document.bgmSoundChannel.soundTransform = Document.bgmSoundTransform;
			if(Document.bgmSoundTransform.volume <= 0){
				Document.bgmSoundTransform.volume = 0;
				Document.bgmSoundChannel.stop();
				removeEventListener("enterFrame",musicFadeOut);
				if(musicToggle.hasEventListener("mouseOut"))
					musicToggle.addEventListener("mouseUp",musicToggle.toggleMusic); // Make clickable if mouse hasn't moved away yet
				if(musicToggle.currentFrame == 1)
					playMusic(songSelected);
			}
		}
		/** Fade the music in
			Not much of a fade, since the song starts from beginning anyway */
		function playMusic(song:Number):void{
			Document.bgmSoundTransform.volume = 1;
			Document.bgmSoundChannel.soundTransform = Document.bgmSoundTransform;
			switch(song){
				case 1: Document.bgmSoundChannel = Document.musicSoulHeals.play(); break;
				case 2: Document.bgmSoundChannel = Document.musicLargerThanLife.play(); break;
				case 3: Document.bgmSoundChannel = Document.musicPulsedImpression.play(); break;
				default: Document.bgmSoundChannel = Document.musicSoulHeals.play(); break;
			}
			Document.bgmSoundChannel.addEventListener(Event.SOUND_COMPLETE, playNextSong);
		}
		
		function playNextSong(e:Event):void{
			var newNumber:Number;
			if(musicRepeat.isRepeatOn) newNumber = songSelected;
			else newNumber = songSelected%3 + 1;
			switch(newNumber){
				case 1: song1Text.applySelectedGlow(null); break;
				case 2: song2Text.applySelectedGlow(null); break;
				case 3: song3Text.applySelectedGlow(null); break;
				default: song1Text.applySelectedGlow(null); break;
			}
			switchSongs(newNumber);
		}
	}
}