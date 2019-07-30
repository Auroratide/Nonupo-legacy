package{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.events.Event;
	import flash.display.Sprite;
	public class TitleScreen extends MovieClip{
		var gameTitle:TextField;
		var titleFormat:TextFormat;
		var subTitle:TextField;
		var subTitleFormat:TextFormat;
		var versionNumber:TextField;
		var versionFormat:TextFormat;
		var gameButton:StartGame;
		var logoName:AuthorLogo;
		function TitleScreen(){
			titleFormat = new TextFormat(Document.segoeEmbed.fontName, 64, 0x444444);
			subTitleFormat = new TextFormat(Document.segoeEmbed.fontName, 22, 0x444444);
			versionFormat = new TextFormat(Document.segoeEmbed.fontName, 10, 0x777777);
			versionFormat.align = "right";
			gameTitle = new TextField();
			gameTitle.embedFonts = true;
			gameTitle.selectable = false;
			gameTitle.defaultTextFormat = titleFormat;
			gameTitle.width = 250;
			gameTitle.height = 110;
			gameTitle.x = -22.5;
			gameTitle.y = -27.5;
			gameTitle.text = "Nonupo";
			gameTitle.alpha = 0;
			
			subTitle = new TextField();
			subTitle.embedFonts = true;
			subTitle.selectable = false;
			subTitle.defaultTextFormat = subTitleFormat;
			subTitle.width = 340;
			subTitle.height = 80;
			subTitle.x = 110;
			subTitle.y = 105;
			subTitle.text = "A Game of Numeric Strategy";
			subTitle.alpha = 0;
			
			versionNumber = new TextField();
			versionNumber.embedFonts = true;
			versionNumber.selectable = false;
			versionNumber.defaultTextFormat = versionFormat;
			versionNumber.width = 80;
			versionNumber.height = 25;
			versionNumber.x = 460;
			versionNumber.y = 378;
			versionNumber.text = Document.VERSION_BUILD;
			versionNumber.alpha = 0;
			
			gameButton = new StartGame();
			gameButton.alpha = 0;
			gameButton.x = 200;
			gameButton.y = 250;
			var newMask:Sprite = new Sprite();
			newMask.graphics.beginFill(0xFF0000);
			newMask.graphics.drawRect(gameButton.x-2,gameButton.y-2,161,41);
			newMask.alpha = .5;
			this.addChild(newMask);
			gameButton.mask = newMask;
			
			logoName = new AuthorLogo();
			this.addChild(logoName);
			logoName.x = 55;
			
			//playTitleMovie();
		}
		
		// First
		function playTitleMovie():void{
			this.removeChild(logoName);
			Document.musicMenu.playMusic(1);
			var largeNumber:LargeNumber = new LargeNumber();
			largeNumber.isTitle = true;
			this.addChild(largeNumber);
		}
		
		// Second
		function revealTitle():void{
			this.addChild(gameTitle);
			this.addChild(subTitle);
			this.addChild(versionNumber);
			this.addChild(gameButton);
			gameTitle.scaleX = 1.5;
			gameTitle.scaleY = 1.5;
			addEventListener("enterFrame",bringUpTitle);
		}
		
		// Title
		function bringUpTitle(e:Event):void{
			gameTitle.alpha += .05;
			gameTitle.scaleX -= .025;
			gameTitle.scaleY -= .025;
			gameTitle.x += 3.125;
			gameTitle.y += 1.375;
			if(Math.floor(gameTitle.alpha*100) >= 50 && Math.floor(gameTitle.alpha*100) < 55) addEventListener("enterFrame",bringUpEverythingElse);
			if(gameTitle.alpha >= 1){
				gameTitle.alpha = 1;
				gameTitle.scaleX = 1;
				gameTitle.scaleY = 1;
				gameTitle.x = 40;
				gameTitle.y = 0;
				removeEventListener("enterFrame",bringUpTitle);
			}
		}
		
		// Fourth
		function bringUpEverythingElse(e:Event):void{
			subTitle.alpha += .1;
			versionNumber.alpha += .1;
			gameButton.alpha += .1;
			if(subTitle.alpha >= 1){
				subTitle.alpha = 1;
				versionNumber.alpha = 1;
				gameButton.alpha = 1;
				removeEventListener("enterFrame",bringUpEverythingElse);
				gameButton.addEventListener("mouseUp",removeTitleScreen);
			}
		}
		
		// Last
		function removeTitleScreen(e:Event):void{
			gameButton.removeEventListener("mouseUp",removeTitleScreen);
			addEventListener("enterFrame",screenFadeOut);
		}
		
		function screenFadeOut(e:Event):void{
			this.alpha -= .05;
			if(this.alpha <= 0){
				removeEventListener("enterFrame",screenFadeOut);
				this.x = 800;
			}
		}
	}
}