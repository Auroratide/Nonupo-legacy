package{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.events.Event;
	import flash.display.Sprite;
	
	public class ActionArea extends MovieClip{
		var currentPlayer:TextField;
		var playerFormat:TextFormat;
		var gridPlus:GridPlace;
		var gridMinus:GridPlace;
		var gridNum:GridPlace;
		var rollButton:RollDie;
		var isCurPlayAnimFlipped:Boolean;
		
		var isWon:Boolean;
		var currentOverwrite:String;
		
		var winText:TextField;
		var p1Text:TextField;
		var p2Text:TextField;
		var p1ScoreText:TextField;
		var p2ScoreText:TextField;
		function ActionArea(){
			currentPlayer = new TextField();
			winText = new TextField();
			p1Text = new TextField();
			p2Text = new TextField();
			p1ScoreText = new TextField();
			p2ScoreText = new TextField();
			playerFormat = new TextFormat(Document.segoeEmbed.fontName, 16, 0x444444);
			playerFormat.align = "center";
			
			setDefaultTextParameters(currentPlayer);
			setDefaultTextParameters(winText);
			setDefaultTextParameters(p1Text);
			setDefaultTextParameters(p2Text);
			setDefaultTextParameters(p1ScoreText);
			setDefaultTextParameters(p2ScoreText);
			winText.x = -17;
			winText.y = 25;
			winText.scaleX = 1.25;
			winText.scaleY = 1.25;
			p1Text.y = 68;
			p1ScoreText.y = 90;
			p2Text.y = 124;
			p2ScoreText.y = 146;
			
			currentPlayer.text = "";
			this.addChild(currentPlayer);
			isCurPlayAnimFlipped = false;
			
			gridPlus = new GridPlace("+");
			this.addChild(gridPlus);
			gridPlus.x = 15;
			gridPlus.y = 150;
			
			gridMinus = new GridPlace("-");
			this.addChild(gridMinus);
			gridMinus.x = 85;
			gridMinus.y = 150;
			
			gridNum = new GridPlace("num");
			this.addChild(gridNum);
			gridNum.x = 50;
			gridNum.y = 85;
			
			rollButton = new RollDie();
			this.addChild(rollButton);
			rollButton.x = 15;
			rollButton.y = 38;
			var rollMask:Sprite = new Sprite();
			rollMask.graphics.beginFill(0xFF0000);
			rollMask.graphics.drawRect(12,35,126,36);
			this.addChild(rollMask);
			rollButton.mask = rollMask;
			
			isWon = false;
		}
		
		function setDefaultTextParameters(field:TextField):void{
			field.embedFonts = true;
			field.defaultTextFormat = playerFormat;
			field.selectable = false;
			field.x = 5;
			field.width = 140;
			field.alpha = 0;
		}
		
		function changeCurrentPlayer():void{
			addEventListener("enterFrame",changeCurrentPlayerAnim);
		}
		
		function deactivateGridPlaces():void{
			gridPlus.deactivateSelf();
			gridMinus.deactivateSelf();
			gridNum.deactivateSelf();
		}
		
		function revealWinner(winner:String, isDraw:Boolean = false):void{
			isWon = true;
			gridPlus.addEventListener("enterFrame",gridPlus.disappear);
			gridMinus.addEventListener("enterFrame",gridMinus.disappear);
			gridNum.addEventListener("enterFrame",gridNum.disappear);
			rollButton.addEventListener("enterFrame",rollButton.disappear);
			
			if(!isDraw) winText.text = "Wins";
			else winText.text = "Draw";
			
			p1Text.text = Grid.player1Name;
			p2Text.text = Grid.player2Name;
			this.addChild(winText);
			this.addChild(p1Text);
			this.addChild(p2Text);
			this.addChild(p1ScoreText);
			this.addChild(p2ScoreText);
			
			currentOverwrite = winner;
			addEventListener("enterFrame",changeCurrentPlayerAnim);
			addEventListener("enterFrame",revealWinScreen);
		}
		
		/* Event Listeners
		=================================*/
		function changeCurrentPlayerAnim(e:Event):void{
			if(!isCurPlayAnimFlipped && currentPlayer.alpha > 0) currentPlayer.alpha -= .1;
			if(currentPlayer.alpha <= 0){
				currentPlayer.alpha = 0; // Lots of redundancy code to fix rounding errors
				if(!isWon){
					if(Grid.turn % 2 == 1) currentPlayer.text = Grid.player1Name;
					else currentPlayer.text = Grid.player2Name;
				}
				else currentPlayer.text = currentOverwrite;
				isCurPlayAnimFlipped = true;
			}
			if(isCurPlayAnimFlipped && currentPlayer.alpha < 1) currentPlayer.alpha += .1;
			if(isCurPlayAnimFlipped && currentPlayer.alpha >= 1){
				currentPlayer.alpha = 1;
				removeEventListener("enterFrame",changeCurrentPlayerAnim);
				isCurPlayAnimFlipped = false;
			}
		}
		function revealWinScreen(e:Event):void{
			winText.alpha += .05;
			p1Text.alpha += .05;
			p2Text.alpha += .05;
			p1ScoreText.alpha += .05;
			p2ScoreText.alpha += .05;
			if(winText.alpha >= 1){
				winText.alpha = 1;
				p1Text.alpha = 1;
				p2Text.alpha = 1;
				p1ScoreText.alpha = 1;
				p2ScoreText.alpha = 1;
				removeEventListener("enterFrame",revealWinScreen);
			}
		}
		function destroyWinScreen(e:Event){
			winText.alpha -= .05;
			p1Text.alpha -= .05;
			p2Text.alpha -= .05;
			p1ScoreText.alpha -= .05;
			p2ScoreText.alpha -= .05;
			if(winText.alpha <= 0){
				this.removeChild(winText);
				this.removeChild(p1Text);
				this.removeChild(p2Text);
				this.removeChild(p1ScoreText);
				this.removeChild(p2ScoreText);
				removeEventListener("enterFrame",destroyWinScreen);
			}
		}
	}
}

package{
	import flash.display.MovieClip;
	import flash.geom.Matrix;
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.globalization.NumberParseResult;
	
	/** This is the logo screen.  To use, import the following files to your library:
		  1: logo_aurora
		  2: logo_name
		  3: logo_ardeol
		  4: logo_subtitle
		  5: auroraFull.png
		Paste the following scripts:
		  1: AuthorAurora
		  2: AuthorLogo
		Uncomment the last line of code (!)
		Create a function, logoIsDone() in the parent instance
		*/

	public class AuthorLogo extends MovieClip{
		var aurora:AuthorAurora;
		var alphaChannel:Sprite;
		var alphaMatrix:Matrix;
		var colors:Array;
		var alphas:Array;
		var limits:Array;
		var directions:Vector.<Number>;
		var speeds:Vector.<Number>;
		var trueFrameRate:int;
		var delay:Number;
		var introSound:AuthorSound;
		function AuthorLogo(){
			// The ratio is 1.098901:1
			/* */
			this.width = 550;
			this.height = 400;
			/* */
			
			introSound = new AuthorSound();
			
			//trueFrameRate = stage.frameRate;
			//stage.frameRate = 24; // Controls framerate; returns it later
			delay = 0;
			this.alpha = 0;
			aurora = new AuthorAurora();
			aurora.y = 100;
			this.addChild(aurora);
			// Each array has 17 slots
			colors = [0x000000,0x000000,0x000000,0x000000,0x000000,0x000000,0x000000,0x000000,0x000000,0x000000,0x000000,0x000000,0x000000,0x000000,0x000000,0x000000,0x000000];
			alphas = [       0,      .5,      .9,      .5,      .2,      .5,      .9,      .5,      .2,      .5,      .9,      .5,      .2,      .5,      .9,      .5,       0];
			limits = [       0,      41,      51,      61,      77,      92,     102,     112,     128,     143,     153,     163,     179,     194,     204,     214,     255];
			// Each element in directions matches with one of the main branches (ie. alpha = 1)
			directions = Vector.<Number>([-.5, .5, -.5, .5]);
			speeds = Vector.<Number>([0, 0, 0, 0]);
			alphaChannel = new Sprite();
			alphaMatrix = new Matrix();
			alphaMatrix.createGradientBox(1000, 1000, Math.PI/13);
			alphaChannel.graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, limits, alphaMatrix);
			alphaChannel.graphics.drawRect(0,0,1000,1000);
			alphaChannel.graphics.endFill();
			this.addChild(alphaChannel);
			aurora.cacheAsBitmap = true;
			alphaChannel.cacheAsBitmap = true;
			aurora.mask = alphaChannel;
			this.addEventListener(Event.ENTER_FRAME, sparkleAurora);
			this.addEventListener(Event.ENTER_FRAME, fadeIn);
		}
		
		/*  Controls four independent spires.
			Each spire has a speed and direction which change semi-randomly.  This in turn affects
			a subspire on each side of the main spire.
			*/
		function sparkleAurora(e:Event):void{
			for(var i=0; i < 4; i++){
				if(Math.random() > .75) directions[i] *= -1;
				speeds[i] += directions[i];
				if(speeds[i] > 3){
					speeds[i] = 2;
					directions[i] = -.5;
				}
				else if(speeds[i] < -3){
					speeds[i] = -2;
					directions[i] = .5;
				}
				limits[4*i+2] += speeds[i];
				if(limits[4*i+2] > 51*(i+1)+14){
					limits[4*i+2] = 51*(i+1)+14;
					directions[i] = -1;
				}
				else if(limits[4*i+2] < 51*(i+1)-14){
					limits[4*i+2] = 51*(i+1)-14;
					directions[i] = 1;
				}
				limits[4*i+1] = limits[4*i+2] - leftLimit(limits[4*i+2] - 51*i);
				limits[4*i+3] = limits[4*i+2] + rightLimit(limits[4*i+2] - 51*i);
			}
			for(var j=1; j < 4; j++){
				limits[4*j] = (limits[4*j-1] + limits[4*j+1])/2;
				alphas[4*j] = .3+3*Math.abs(limits[4*j]-51*(j-1)-77)/77;
			}
			alphaChannel.graphics.clear();
			alphaChannel.graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, limits, alphaMatrix);
			alphaChannel.graphics.drawRect(0,0,1000,1000);
			alphaChannel.graphics.endFill();
			aurora.mask = alphaChannel;
		}
		
		/*  The following math functions cause the spacing on the subspires to differ depending on
			where the main spire is.  The function is a bell-curve added to an exponential expression.
			*/
		function leftLimit(lim:Number):Number{
			return 7*Math.pow(Math.E, -(Math.pow(lim-51, 2)/200)) + Math.pow(10/9, lim-39);
		}
		function rightLimit(lim:Number):Number{
			return 7*Math.pow(Math.E, -(Math.pow(lim-51, 2)/200)) + Math.pow(10/9, 63-lim);
		}
		
		function fadeIn(e:Event):void{
			this.alpha += .025;
			if(this.alpha >= .5 && this.alpha < .525) introSound.play();
			if(this.alpha >= 1){
				this.alpha = 1;
				removeEventListener(Event.ENTER_FRAME, fadeIn);
				addEventListener(Event.ENTER_FRAME, fadeOut);
			}
		}
		function fadeOut(e:Event):void{
			delay++;
			if(delay >= 120){
				this.alpha -= 0.025;
				if(this.alpha <= 0){
					this.alpha = 0;
					removeEventListener(Event.ENTER_FRAME, fadeOut);
					//stage.frameRate = trueFrameRate;
					//Document.logoIsDone();
					(parent as MovieClip).playTitleMovie();
				}
			}
		}
	}
}

package{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class ButtonBase extends MovieClip{
		var buttonHighlight:ButtonHighlight;
		var buttonHighlightTop:ButtonHighlight;
		var buttonMask:Sprite;
		var buttonMaskTop:Sprite;
		var animationCounter:Number;
		var isHovered:Boolean;
		var hoverHighlight:Sprite;
		function ButtonBase(w:Number,h:Number){
			this.width = w;
			this.height = h;
			animationCounter = Math.floor(Math.random()*100);
			
			buttonHighlight = new ButtonHighlight(0);
			buttonHighlightTop = new ButtonHighlight(-30);
			this.addChild(buttonHighlight);
			this.addChild(buttonHighlightTop);
			buttonHighlightTop.y = -30;
			buttonHighlight.width = 120;
			buttonHighlight.height = 30;
			buttonHighlightTop.width = 120;
			buttonHighlightTop.height = 30;
			
			// Create the mask for the highlight animation
			buttonMask = new Sprite();
			buttonMask.graphics.beginFill(0xFF0000);
			buttonMask.graphics.drawRect(0,0,120,30);
			this.addChild(buttonMask);
			buttonHighlight.mask = buttonMask;
			
			buttonMaskTop = new Sprite();
			buttonMaskTop.graphics.beginFill(0xFF0000);
			buttonMaskTop.graphics.drawRect(0,0,120,30);
			this.addChild(buttonMaskTop);
			buttonHighlightTop.mask = buttonMaskTop;
			
			// addEventListener("enterFrame",idleAnimation);
			
			// Used for hover animation; makes button lighter; has no fade for simplicity
			hoverHighlight = new Sprite();
			hoverHighlight.graphics.beginFill(0xFFFFFF);
			hoverHighlight.graphics.drawRect(0,0,120,30);
			hoverHighlight.alpha = 0;
			this.addChild(hoverHighlight);
		}
		
		function idleAnimation(e:Event):void{
			animationCounter++;
			if(isHovered) animationCounter = -30;
			if(animationCounter >= Math.random()*200 + 200){
				animationCounter = -30;
				buttonHighlight.addEventListener("enterFrame",buttonHighlight.animateHighlight);
				buttonHighlightTop.addEventListener("enterFrame",buttonHighlightTop.animateHighlight);
			}
		}
		
		function hoverAnimation(e:Event):void{
			(parent as MovieClip).addEventListener("mouseOut",hoverOff);
			/*buttonHighlight.addEventListener("enterFrame",buttonHighlight.animateHighlight);
			buttonHighlightTop.addEventListener("enterFrame",buttonHighlightTop.animateHighlight);*/
			hoverHighlight.alpha = .1;
		}
		function hoverOff(e:Event):void{
			(parent as MovieClip).removeEventListener("mouseOut",hoverOff);
			hoverHighlight.alpha = 0;
		}
	}
}

package{
	import flash.display.MovieClip;
	import flash.events.Event;
	
	public class ButtonHighlight extends MovieClip{
		var time:Number;
		var initialPosition:Number;
		function ButtonHighlight(initial:Number){
			time = 0;
			initialPosition = initial;
		}
		
		function animateHighlight(e:Event):void{
			time++;
			// this.y += (-actualHeight * (3*time*time - 93*time + 46)) / 13500;
			this.y += 31*time/150 - time*time/150 - 23/225;
			if(time != 15) this.alpha += .04*Math.abs(time-15)/(time-15);
			if(time >= 30){
				time = 0;
				this.y = initialPosition;
				this.alpha = 1;
				removeEventListener("enterFrame",animateHighlight);
			}
		}
	}
}

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

package{
	import flash.display.MovieClip;
	import flash.ui.Mouse;
	import flash.text.*;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	
	public class Document extends MovieClip{
		// Version format: Major_Build.Year.MonthDay
		public static const VERSION_BUILD:String = "1.13.0302";
		public static const CPU_NAME:String = "The Computer\b"; // \b is used to indicate that currentPlayer really is the cpu and not somebody trolling
																// The \b is otherwise impossible to obtain by input
		static var segoeEmbed:SegoeEmbed = new SegoeEmbed(); // The Font
		
		// In layering order; the bottom is on the top of the layer stack
		static var cpu:TheComputer;
		static var grid:Grid;
		static var actionArea:ActionArea;
		static var mainMenu:MainMenu;
		static var musicMenu:MusicMenu;
		static var titleScreen:TitleScreen;
		static var screenMask:ScreenMask;
		static var popUp:PopUp;
		static var cursor:Cursor;
		
		// Musics
		static var musicSoulHeals:SoulHeals;
		static var musicLargerThanLife:LargerThanLife;
		static var musicPulsedImpression:PulsedImpression;
		static var bgmSoundChannel:SoundChannel;
		static var bgmSoundTransform:SoundTransform;
		
		// Preloaders
		//static var preloader:Preloader;
		
		public function Document(){
			if(stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void{
			this.stop();
			removeEventListener(Event.ADDED_TO_STAGE, init);
			loaderInfo.addEventListener(ProgressEvent.PROGRESS, preloadProgress);
			loaderInfo.addEventListener(Event.COMPLETE, preloadComplete);
		}
		
		private function preloadProgress(e:ProgressEvent):void{
			// trace(e.bytesLoaded + "/" + e.bytesTotal);
			Preloader.guts.width = 200*(e.bytesLoaded/e.bytesTotal);
		}
		
		private function preloadComplete(e:Event):void{
			loaderInfo.removeEventListener(ProgressEvent.PROGRESS, preloadProgress);
			loaderInfo.removeEventListener(Event.COMPLETE, preloadComplete);
			this.gotoAndStop(2);
			
			/* Instantiate The Computer */
			cpu = new TheComputer();
			stage.addChild(cpu);
			
			/* Instantiate the Grid
			   Holds the Game Board */
			grid = new Grid();
			stage.addChild(grid);
			grid.x = 50;
			grid.y = 50;
			
			/* Instantiate the Action Area
			   Essentially the Gaming Menu; control rolls and determine actions here */
			actionArea = new ActionArea();
			stage.addChild(actionArea);
			actionArea.x = 375;
			actionArea.y = 40;
			
			/* Instantiate the Main Menu
			   Starts a new game with the highlighted game settings.
			   Also, instructions. */
			mainMenu = new MainMenu();
			stage.addChild(mainMenu);
			mainMenu.x = 375;
			mainMenu.y = 260;
			
			/* Instantiate the Music Menu
			   Allows for user control of the music being played */
			musicMenu = new MusicMenu();
			stage.addChild(musicMenu);
			musicMenu.x = 8;
			musicMenu.y = 372;
			
			/* Instantiate the Title Screen */
			titleScreen = new TitleScreen();
			stage.addChild(titleScreen);
			titleScreen.x = 0;
			titleScreen.y = 0;
			
			/* Instantiate the Screen Mask
			   This essentially masks the screen to prevent buttons from working
			   without the need to remove listeners and add them back.
			   Incredibly convenient, but probably unconventional. */
			screenMask = new ScreenMask();
			stage.addChild(screenMask);
			screenMask.x = 560;
			
			/* Instantiate the PopUp Window
			   Sits off screen until called */
			popUp = new PopUp();
			stage.addChild(popUp);
			popUp.x = -560;
			
			musicSoulHeals = new SoulHeals();
			musicLargerThanLife = new LargerThanLife();
			musicPulsedImpression = new PulsedImpression();
			bgmSoundChannel = new SoundChannel();
			bgmSoundTransform = new SoundTransform();
			//musicMenu.playMusic(1);
			
			/* Instantiate Custom Cursor
			   Done last to make it on top of the z-stack */
			/* REMOVE COMMENT FOR CUSTOM CURSOR
			Mouse.hide();
			cursor = new Cursor();
			stage.addChild(cursor);
			/*  */
			/* Test Score System
			Grid.numArray = ["2","4","+","3","7","0","0","4","9","-","7","+","+","8","1","0","+","9","7","5","4","8","6","3","-","2","+","7","-","3","2","4","0","+","1","4"];
			Grid.finishGame();
			/*  */
		}
	}
}

package{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;

	public class Grid extends MovieClip{
		static var gridA1:GridUnit;
		static var gridA2:GridUnit;
		static var gridA3:GridUnit;
		static var gridA4:GridUnit;
		static var gridA5:GridUnit;
		static var gridA6:GridUnit;
		
		static var gridB1:GridUnit;
		static var gridB2:GridUnit;
		static var gridB3:GridUnit;
		static var gridB4:GridUnit;
		static var gridB5:GridUnit;
		static var gridB6:GridUnit;
		
		static var gridC1:GridUnit;
		static var gridC2:GridUnit;
		static var gridC3:GridUnit;
		static var gridC4:GridUnit;
		static var gridC5:GridUnit;
		static var gridC6:GridUnit;
		
		static var gridD1:GridUnit;
		static var gridD2:GridUnit;
		static var gridD3:GridUnit;
		static var gridD4:GridUnit;
		static var gridD5:GridUnit;
		static var gridD6:GridUnit;
		
		static var gridE1:GridUnit;
		static var gridE2:GridUnit;
		static var gridE3:GridUnit;
		static var gridE4:GridUnit;
		static var gridE5:GridUnit;
		static var gridE6:GridUnit;
		
		static var gridF1:GridUnit;
		static var gridF2:GridUnit;
		static var gridF3:GridUnit;
		static var gridF4:GridUnit;
		static var gridF5:GridUnit;
		static var gridF6:GridUnit;
		
		// Game Data
		static var numArray:Array;
		static var gridArray:Array;
		static var player1Name:String;
		static var player2Name:String;
		static var cpuDiff:Number;
		static var turn:Number;
		static var gridPlaceSelected:String; // Either "+", "-", "", or "Num", where num is the current number
		static var gridUnitSelected:Number; // Range on interval [0,35].  -1 means none selected.
		
		static var player1Array:Array;
		static var player2Array:Array;
		
		static var tf:TextFormat;
		
		static var prevIndex:Number;
		
		function Grid(){
			tf = new TextFormat(Document.segoeEmbed.fontName, 16, 0x444444);
			
			gridA1 = new GridUnit();
			gridA2 = new GridUnit();
			gridA3 = new GridUnit();
			gridA4 = new GridUnit();
			gridA5 = new GridUnit();
			gridA6 = new GridUnit();
			
			gridB1 = new GridUnit();
			gridB2 = new GridUnit();
			gridB3 = new GridUnit();
			gridB4 = new GridUnit();
			gridB5 = new GridUnit();
			gridB6 = new GridUnit();
			
			gridC1 = new GridUnit();
			gridC2 = new GridUnit();
			gridC3 = new GridUnit();
			gridC4 = new GridUnit();
			gridC5 = new GridUnit();
			gridC6 = new GridUnit();
			
			gridD1 = new GridUnit();
			gridD2 = new GridUnit();
			gridD3 = new GridUnit();
			gridD4 = new GridUnit();
			gridD5 = new GridUnit();
			gridD6 = new GridUnit();
			
			gridE1 = new GridUnit();
			gridE2 = new GridUnit();
			gridE3 = new GridUnit();
			gridE4 = new GridUnit();
			gridE5 = new GridUnit();
			gridE6 = new GridUnit();
			
			gridF1 = new GridUnit();
			gridF2 = new GridUnit();
			gridF3 = new GridUnit();
			gridF4 = new GridUnit();
			gridF5 = new GridUnit();
			gridF6 = new GridUnit();
			
			numArray = new Array(36);
			resetNumArray();
			
			gridArray = [gridA1,gridA2,gridA3,gridA4,gridA5,gridA6,gridB1,gridB2,gridB3,gridB4,gridB5,gridB6,gridC1,gridC2,gridC3,gridC4,gridC5,gridC6,gridD1,gridD2,gridD3,gridD4,gridD5,gridD6,gridE1,gridE2,gridE3,gridE4,gridE5,gridE6,gridF1,gridF2,gridF3,gridF4,gridF5,gridF6];
			prevIndex = 0;
			
			// Done in reverse order in order to make the depths proper; otherwise they overlap
			// The masks prevent the top from having a 15 pixel select area
			for(var i:int = gridArray.length-1; i >=0; i--){
				var tile:GridUnit = gridArray[i];
				this.addChild(tile)
				tile.x = (i % 6)*50;
				tile.y = Math.floor(i / 6)*50;
				tile.gridID = i;
				
				var tileMask:Sprite = new Sprite();
				tileMask.graphics.beginFill(0xFF0000);
				tileMask.graphics.drawRect(tile.x - 4, tile.y - 4, 58, 58);
				this.addChild(tileMask);
				tile.mask = tileMask;
			}
			
			// Game Data
			player1Name = "Player 1";
			player2Name = "Player 2";
			cpuDiff = 0;
			turn = 0;
			gridPlaceSelected = "";
			gridUnitSelected = -1;
			
			player1Array = [];
			player2Array = [];
		}
		
		static function resetNumArray():void{
			for(var j:int; j < numArray.length; j++){
				numArray[j] = "";
			}
		}
		
		static function activateRollButton():void{
			turn++;
			Document.actionArea.changeCurrentPlayer();
			Document.actionArea.rollButton.activateSelf();
			gridPlaceSelected = "";
			gridUnitSelected = -1;
		}
		
		static function activateAvailableGridUnits():void{
			for(var i:int; i < gridArray.length; i++){
				var gridTemp:GridUnit = gridArray[i];
				if(numArray[i] == "") gridTemp.activateSelf();
			}
		}
		
		// If a + or - is selected
		static function deactivateUnavailableGridUnits():void{
			for(var i:int; i < gridArray.length; i++){
				var gridAdj:GridUnit;
				if(numArray[i] == "+" || numArray[i] == "-"){
					if(i-6 >= 0){
						gridAdj = gridArray[i-6];
						gridAdj.deactivateSelf();
					}
					if(i-1 >= 0 && i%6 != 0){
						gridAdj = gridArray[i-1];
						gridAdj.deactivateSelf();
					}
					if(i+6 <= 35){
						gridAdj = gridArray[i+6];
						gridAdj.deactivateSelf();
					}
					if(i+1 <= 35 && i%6 != 5){
						gridAdj = gridArray[i+1];
						gridAdj.deactivateSelf();
					}
				}
			}
		}
		
		// Yes, it does more than it needs to
		static function deactivateAllGridUnits():void{
			for(var i:int; i < gridArray.length; i++){
				var gridTemp:GridUnit = gridArray[i];
				gridTemp.deactivateSelf();
			}
		}
		
		/** Places the number in the gridUnit
			Also changes to the next turn by activating the Roll Button */
		static function assignGridValue():void{
			numArray[gridUnitSelected] = gridPlaceSelected;
			if(turn > 1)
				gridArray[prevIndex].fadeToGrey();
			prevIndex = gridUnitSelected;
			var tempPlace:GridPlace;
			if(gridPlaceSelected == "+") tempPlace = Document.actionArea.gridPlus;
			else if(gridPlaceSelected == "-") tempPlace = Document.actionArea.gridMinus;
			else tempPlace = Document.actionArea.gridNum;
			var tempGrid:GridUnit = gridArray[gridUnitSelected];
			tempGrid.replaceNum();
			if(turn % 2 == 1) tempGrid.changeTextColor(0x2A8C9E);
			else tempGrid.changeTextColor(0x9B3946);
			tempGrid.removeSelection(null);
			tempGrid.removeEventListener("mouseOut",tempGrid.removeSelection);
			tempGrid.addEventListener("enterFrame",tempGrid.numberAppear);
			tempPlace.removeSelection(null);
			tempPlace.removeEventListener("mouseOut",tempPlace.removeSelection);
			
			deactivateAllGridUnits();
			Document.actionArea.deactivateGridPlaces();
			
			// Finishes the game or starts a new turn
			if(turn >= 36) finishGame();
			else activateRollButton();
		}
		
		static function cpuAssignGridValue(unitSelected:Number, type:String = "num"):void{
			if(turn > 1)
				gridArray[prevIndex].fadeToGrey();
			prevIndex = unitSelected;
			if(type == "num") numArray[unitSelected] = Document.actionArea.gridNum.gridCharacter.text;
			else numArray[unitSelected] = type;
			var tempGrid:GridUnit = gridArray[unitSelected];
			tempGrid.replaceNum();
			if(player1Name == Document.CPU_NAME) tempGrid.changeTextColor(0x2A8C9E);
			else tempGrid.changeTextColor(0x9B3946);
			tempGrid.addEventListener("enterFrame",tempGrid.numberAppear);
			Document.actionArea.gridNum.addEventListener("enterFrame",Document.actionArea.gridNum.numberDisappear);
			
			if(turn >= 36) finishGame();
			else activateRollButton();
		}
		
		/** Calculates the scores
			Displays scores in the Action Area */
		static function finishGame():void{
			var p1Score:Number = 0;
			var p2Score:Number = 0;
			p1Score = calculateScore(6,1);			
			p2Score = calculateScore(1,6);
			if(Math.abs(p1Score) < Math.abs(p2Score))
				Document.actionArea.revealWinner(player1Name);
			else if(Math.abs(p2Score) < Math.abs(p1Score))
				Document.actionArea.revealWinner(player2Name);
			else
				Document.actionArea.revealWinner("It's a", true); // in the off chance of a draw
			Document.actionArea.p1ScoreText.text = String(p1Score);
			Document.actionArea.p2ScoreText.text = String(p2Score);
		}
		
		static function calculateScore(c:Number, r:Number):Number{
			var runningScore:Number = 0;
			for(var i:int = 0; i <= 5; i++){
				var scoreArray:Array = [];
				for(var j:int = 0; j <= 5; j++){
					var numElement:String = numArray[c*i+r*j];
					if(scoreArray.length < 1) scoreArray.push(numElement);
					else if(numElement == "+" || numElement == "-") scoreArray.push(numElement);
					else scoreArray[scoreArray.length-1] = scoreArray[scoreArray.length-1].concat(numElement);
				}
				while(scoreArray.length > 0){
					if(scoreArray[0] != "+" && scoreArray[0] != "-")
						runningScore += Number(scoreArray.shift());
					else scoreArray.shift();
				}
			}
			return runningScore;
		}
		
		/** Places the names on the top and side of the grid
			Used so players know which direction they are going */
		function placeOrientingNames():void{
			var cumulativeWidth:Number = 10;
			for(var i:int; i < player1Name.length; i++){
				var letter:OrientText = new OrientText(player1Name.charAt(i), "left", cumulativeWidth);
				this.addChild(letter);
				//letter.x = cumulativeWidth;
				//letter.y = -40;
				cumulativeWidth += Math.floor(letter.field.width);
				player1Array.push(letter);
				letter.performWhip("right",5*i);
			}
			
			var cumulativeHeight = 10;
			for(var j:int; j < player2Name.length; j++){
				var letter2:OrientText = new OrientText(player2Name.charAt(j), "center", -75, cumulativeHeight);
				this.addChild(letter2);
				letter2.x = -75;
				var regHook:RegExp = /[gjpqy]/;
				var regTall:RegExp = /[A-Z0-9bdfhklt/;
				var curHeight:Number;
				if(regHook.test(player2Name.charAt(j))) curHeight = 18;
				else curHeight = 15;
				var heightMod:Number = 0;
				if(regTall.test(player2Name.charAt(j))) heightMod = 4;
				letter2.y = cumulativeHeight + heightMod;
				cumulativeHeight += curHeight + heightMod;
				player2Array.push(letter2);
				letter2.performWhip("down",5*j);
			}
		}
		function removeOrientingNames():void{
			while(player1Array.length > 0){
				this.removeChild(player1Array.shift());
			}
			while(player2Array.length > 0){
				this.removeChild(player2Array.shift());
			}
		}
	}
}

package{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.events.Event;
	
	public class GridPlace extends MovieClip{
		var type:String;
		var gridCharacter:TextField;
		function GridPlace(typeOfGrid:String){
			type = typeOfGrid;
			gridCharacter = new TextField();
			gridCharacter.embedFonts = true;
			this.addChild(gridCharacter);
			var gridCharFormat:TextFormat = new TextFormat(Document.segoeEmbed.fontName, 40, 0x444444);
			gridCharFormat.align = "center";
			gridCharacter.defaultTextFormat = gridCharFormat;
			gridCharacter.y = -15;
			gridCharacter.selectable = false;
			gridCharacter.width = 50;
			gridCharacter.height = 65;
			if(typeOfGrid == "num") gridCharacter.text = "";
			else gridCharacter.text = typeOfGrid;
			this.alpha = .25;
		}
		
		function activateSelf():void{
			addEventListener("enterFrame",increaseAlpha);
			addEventListener("mouseOver",performSelection);
		}
		function deactivateSelf():void{
			disableSelf();
			addEventListener("enterFrame",decreaseAlpha);
			if(type == "num") addEventListener("enterFrame",numberDisappear);
		}
		function disableSelf():void{
			removeEventListener("mouseOver",performSelection);
			removeEventListener("mouseUp",selectGridPlace);
		}
		function enableSelf():void{
			addEventListener("mouseOver",performSelection);
			addEventListener("mouseUp",selectGridPlace);
		}
		
		function finishRoll(num:Number):void{
			gridCharacter.alpha = 0;
			gridCharacter.scaleX = 2;
			gridCharacter.scaleY = 2;
			gridCharacter.x = -25;
			gridCharacter.y = -55;
			gridCharacter.text = String(num);
			addEventListener("enterFrame",numberAppear);
		}
		
		// Resets a tile if it had been selected but a new one is selected instead
		function resetGridPlace():void{
			removeSelection(null);
			addEventListener("mouseUp",selectGridPlace);
			addEventListener("mouseOver",performSelection);
		}
		
		/* Event Listeners
		===============================*/
		function increaseAlpha(e:Event):void{
			this.alpha += .05;
			if(this.alpha >= 1){
				removeEventListener("enterFrame",increaseAlpha);
				addEventListener("mouseUp",selectGridPlace);
				this.alpha = 1;
			}
		}
		function decreaseAlpha(e:Event):void{
			this.alpha -= .05;
			if(this.alpha <= .25){
				removeEventListener("enterFrame",decreaseAlpha);
				this.alpha = .25;
			}
		}
		function disappear(e:Event):void{
			this.alpha -= .05;
			if(this.alpha <= 0){
				removeEventListener("enterFrame",disappear);
				this.alpha = 0;
			}
		}
		
		function numberAppear(e:Event):void{
			gridCharacter.alpha += .05;
			gridCharacter.scaleX -= .05;
			gridCharacter.scaleY -= .05;
			gridCharacter.x += 1.25;
			gridCharacter.y += 2;
			if(gridCharacter.alpha >= 1){
				gridCharacter.alpha = 1;
				gridCharacter.scaleX = 1;
				gridCharacter.scaleY = 1;
				gridCharacter.x = 0;
				gridCharacter.y = -15;
				removeEventListener("enterFrame",numberAppear);
			}
		}
		function numberDisappear(e:Event):void{
			gridCharacter.alpha -= .05;
			if(gridCharacter.alpha <= 0){
				gridCharacter.alpha = 0;
				removeEventListener("enterFrame",numberDisappear);
			}
		}
		
		function performSelection(e:Event):void{
			addEventListener("mouseOut",removeSelection);
			for(var i:int; i <= 22; i++){
				var initialY:Number = Math.floor(Math.random()*6-6);
				var particle:SelectParticle = new SelectParticle();
				this.addChild(particle);
				if(i <= 12) particle.x = Math.floor(Math.random()*20+20);
				else if(i >= 13 && i <= 18) particle.x = Math.floor(Math.random()*20+10);
				else particle.x = Math.floor(Math.random()*25-5);
				particle.y = -3;
				particle.alpha = 0;
			}
		}
		function removeSelection(e:Event):void{
			removeEventListener("mouseOut",removeSelection);
			for(var i:int = 2; i < numChildren; i++){
				var child = getChildAt(i);
				child.addEventListener("enterFrame",child.removeAlpha);
			}
		}
		
		function selectGridPlace(e:Event):void{
			if(Grid.gridPlaceSelected == "+") Document.actionArea.gridPlus.resetGridPlace();
			else if(Grid.gridPlaceSelected == "-") Document.actionArea.gridMinus.resetGridPlace();
			else if(Grid.gridPlaceSelected != "") Document.actionArea.gridNum.resetGridPlace();
			
			Grid.gridPlaceSelected = gridCharacter.text;
			removeEventListener("mouseOut",removeSelection); // Keeps selection animation on as indicator
			removeEventListener("mouseUp",selectGridPlace); // Added in increaseAlpha
			removeEventListener("mouseOver",performSelection);
			
			if(Grid.gridUnitSelected != -1) Grid.assignGridValue();
			else if(type == "num"){
				Grid.deactivateAllGridUnits(); // Kind of redundant, but good Garbage Collection and insurance
				Grid.activateAvailableGridUnits();
			}
			else Grid.deactivateUnavailableGridUnits();
		}
	}
}

package{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.events.Event;

	public class GridUnit extends MovieClip{
		var gridNumber:TextField;
		var gridID:Number;
		var gridNumberFormat:TextFormat;
		var delayDisappear:Number;
		var colorDiff:Number;
		function GridUnit(){
			delayDisappear = 0;
			gridNumber = new TextField();
			gridNumber.embedFonts = true;
			this.addChild(gridNumber);
			gridNumberFormat = new TextFormat(Document.segoeEmbed.fontName,40,0x444444);
			gridNumberFormat.align = "center";
			gridNumber.defaultTextFormat = gridNumberFormat;
			// gridNumber.x = 8;  If the alignment is set to "left"
			gridNumber.y = -15;
			gridNumber.selectable = false;
			gridNumber.width = 50;
			gridNumber.height = 65;
			gridNumber.text = "";
			gridNumber.alpha = 0;

			/* The Event Listeners
			===================================*/
			// addEventListener("mouseUp",clickMe);
			// addEventListener("mouseOver",performSelection);
		}
		
		function replaceNum():void{
			gridNumber.text = Grid.numArray[gridID];
		}
		
		function activateSelf():void{
			addEventListener("mouseOver",performSelection);
			addEventListener("mouseUp",selectGridUnit);
		}
		function deactivateSelf():void{
			removeEventListener("mouseOver",performSelection);
			removeEventListener("mouseUp",selectGridUnit);
		}
		
		function resetGridUnit():void{
			removeSelection(null);
			addEventListener("mouseUp",selectGridUnit);
			addEventListener("mouseOver",performSelection);
		}
		
		/* The Event Listeners
		===================================*/
		/* clickMe was used for developer purposes.
		function clickMe(e:Event):void{
			var num = Math.floor(10*Math.random());
			gridNumber.text = String(num);
			Grid.numArray[gridID] = String(num);
			addEventListener("enterFrame",numberAppear);
			removeEventListener("mouseUp",clickMe);
			removeEventListener("mouseOver",performSelection);
			removeSelection(null);
		}
		/*  */
		
		/** Selection Animation */
		function performSelection(e:Event):void{
			addEventListener("mouseOut",removeSelection);
			for(var i:int; i <= 22; i++){
				var initialY:Number = Math.floor(Math.random()*6-6);
				var particle:SelectParticle = new SelectParticle();
				this.addChild(particle);
				if(i <= 12) particle.x = Math.floor(Math.random()*20+20);
				else if(i >= 13 && i <= 18) particle.x = Math.floor(Math.random()*20+10);
				else particle.x = Math.floor(Math.random()*25-5);
				particle.y = -3;
				particle.alpha = 0;
			}
		}
		function removeSelection(e:Event):void{
			removeEventListener("mouseOut",removeSelection);
			for(var i:int = 1; i < numChildren; i++){
				var child = getChildAt(i);
				child.addEventListener("enterFrame",child.removeAlpha);
			}
		}
		/* End Selection animation **/
		
		function numberAppear(e:Event):void{
			if(gridNumber.alpha < 1) gridNumber.alpha += .05;
			if(gridNumber.alpha >= 1) removeEventListener("enterFrame",numberAppear);
		}
		
		function numberDisappear(e:Event):void{
			if(delayDisappear <= 0){
				if(gridNumber.scaleY > 0){
					gridNumber.scaleY -= .1;
					gridNumber.scaleX -= .1;
					gridNumber.x += 2.5;
					gridNumber.y += 4;
				}
				if(gridNumber.scaleY <= 0){
					removeEventListener("enterFrame",numberDisappear);
					gridNumber.scaleY = 1;
					gridNumber.scaleX = 1;
					gridNumber.x = 0;
					gridNumber.y = -15;
					gridNumber.text = "";
					gridNumber.alpha = 0;
				}
			}
			else delayDisappear--;
		}
		
		function selectGridUnit(e:Event):void{
			if(Grid.gridUnitSelected != -1){
				var gridTemp:GridUnit = Grid.gridArray[Grid.gridUnitSelected];
				gridTemp.resetGridUnit();
			}
			
			Grid.gridUnitSelected = gridID;
			removeEventListener("mouseOut",removeSelection); // Keeps selection animation on as indicator
			removeEventListener("mouseUp",selectGridUnit);
			removeEventListener("mouseOver",performSelection);
			
			var isAdj:Boolean = false;
			if(Grid.gridPlaceSelected != "") Grid.assignGridValue();
			else{
				if(gridID-6 >= 0) isAdj = isAdjToPM(gridID-6);
				if(gridID-1 >= 0 && gridID%6 != 0 && !isAdj) isAdj = isAdjToPM(gridID-1);
				if(gridID+6 <= 35 && !isAdj) isAdj = isAdjToPM(gridID+6);
				if(gridID+1 <= 35 && gridID%6 != 5 && !isAdj) isAdj = isAdjToPM(gridID+1);
				if(isAdj){
					Document.actionArea.gridPlus.disableSelf();
					Document.actionArea.gridMinus.disableSelf();
				}
				else{
					Document.actionArea.gridPlus.disableSelf();
					Document.actionArea.gridMinus.disableSelf();
					Document.actionArea.gridNum.disableSelf();
					Document.actionArea.gridPlus.enableSelf();
					Document.actionArea.gridMinus.enableSelf();
					Document.actionArea.gridNum.enableSelf();
				}
			}
		}
		function isAdjToPM(spotToCheck:Number):Boolean{
			return Grid.numArray[spotToCheck] == "+" || Grid.numArray[spotToCheck] == "-";
		}
		
		function changeTextColor(newColor:Object = 0x444444):void{
			var tempFormat:TextFormat = new TextFormat(Document.segoeEmbed.fontName,40, newColor);
			gridNumber.defaultTextFormat = tempFormat;
			gridNumber.text = gridNumber.text; // Has to be rewritten to work...
		}
		
		function fadeToGrey():void{
			if(gridNumber.defaultTextFormat.color == 0x2A8C9E)
				colorDiff = 1;  // essentially a type
			else colorDiff = 2;
			addEventListener(Event.ENTER_FRAME, commenceFade);
		}
		
		function commenceFade(e:Event):void{
			var newColor:uint;
			if(colorDiff == 1)
				newColor = uint(gridNumber.defaultTextFormat.color) + 0x020000 - 0x000506;
			else
				newColor = uint(gridNumber.defaultTextFormat.color) - 0x050000;
			var newTf:TextFormat = new TextFormat(Document.segoeEmbed.fontName,40,newColor);
			gridNumber.defaultTextFormat = newTf;
			gridNumber.text = gridNumber.text;
			if(gridNumber.defaultTextFormat.color > 0x424242 && gridNumber.defaultTextFormat.color < 0x464646){
				newTf.color = 0x444444;
				gridNumber.defaultTextFormat = newTf;
				gridNumber.text = gridNumber.text;
				removeEventListener(Event.ENTER_FRAME, commenceFade);
			}
		}
	}
}

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

package{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.events.Event;
	
	public class LargeNumber extends MovieClip{
		var field:TextField;
		var format:TextFormat;
		var isTitle:Boolean;
		var isCPU:Boolean;
		
		/** NOTES:
			If using as a child of RollDie, then use the following:
			x = -600;
			y = -400; */
		
		function LargeNumber(){
			field = new TextField();
			format = new TextFormat(Document.segoeEmbed.fontName, 100, 0x444444);
			format.align = "center";
			field.embedFonts = true;
			field.selectable = false;
			field.width = 120;
			field.height = 130;
			field.scaleX = 6;
			field.scaleY = 6;
			field.defaultTextFormat = format;
			this.addChild(field);
			this.x = -200;
			this.y = -325;
			field.text = String(Math.floor(Math.random()*10));
			this.alpha = 0;
			
			addEventListener("enterFrame",moveRight);
			isTitle = false;
			isCPU = false;
		}
		
		/** Moves a ghost number to the right while causing it to occasionally
			change numbers.  Fades in the end. */
		function moveRight(e:Event):void{
			this.x += 3;
			if(this.x + 200 < 30) this.alpha += .01;
			if(this.x + 200 > 130) this.alpha -= .01;
			if((this.x + 200) % 36 == 0){
				var randNum:Number = Math.floor(Math.random()*10);
				var checker:Number = 0;
				// Ensure that I always get a different number, unless rolled 25 times in a row
				while(randNum == Number(field.text) && checker < 25){
					randNum = Math.floor(Math.random()*10);
					checker++;
				}
				field.text = String(randNum);
			}
			/*if(this.x + 600 >= 150){
				removeEventListener("enterFrame",moveRight);
				parent.addEventListener("enterFrame",(this.parent as MovieClip).decreaseAlpha);
				(this.parent as MovieClip).performRollSecond();
				parent.removeChild(this);
			}*/
			if(this.x + 200 >= 150){
				removeEventListener("enterFrame",moveRight);
				if(isTitle){
					Document.titleScreen.revealTitle();
				}
				else if(isCPU){
					var numRolled:Number = Math.floor(Math.random()*10);
					Document.cpu.currentNumber = numRolled;
					Document.actionArea.gridNum.finishRoll(numRolled);
					Document.cpu.beginThinking();
				}
				else{
					Document.actionArea.rollButton.addEventListener("enterFrame",Document.actionArea.rollButton.decreaseAlpha);
					Document.actionArea.rollButton.performRollSecond();
				}
				parent.removeChild(this);
			}
		}
	}
}

package{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class MainMenu extends MovieClip{
		var vsText:TextField;
		var newGame:NewGame;
		var humanButton:TextButton;
		var humanMask:Sprite;
		var cpuButton:TextButton;
		var cpuMask:Sprite;
		var instructions:TextButton;
		var isInstructionsOn:Boolean;
		var credits:TextButton;
		var isCreditsOn:Boolean;
		function MainMenu(){
			newGame = new NewGame();
			this.addChild(newGame);
			newGame.x = 25;
			newGame.y = 8;
			var newMask:Sprite = new Sprite();
			newMask.graphics.beginFill(0xFF0000);
			newMask.graphics.drawRect(newGame.x-2,newGame.y-2,101,26);
			newMask.alpha = .5;
			this.addChild(newMask);
			newGame.mask = newMask;
			
			var optionsFormat:TextFormat = new TextFormat(Document.segoeEmbed.fontName, 12, 0x444444);
			
			vsText = new TextField();
			vsText.selectable = false;
			vsText.embedFonts = true;
			vsText.defaultTextFormat = optionsFormat;
			
			this.addChild(vsText);
			
			vsText.text = "Vs.";
			vsText.x = 5;
			vsText.y = 34;
			
			humanButton = new TextButton(true);
			this.addChild(humanButton);
			humanButton.theText.text = "Human";
			humanButton.x = 38;
			humanButton.y = 34;
			humanButton.theText.width = 47;
			humanMask = new Sprite();
			humanMask.graphics.beginFill(0xFF0000);
			humanMask.graphics.drawRect(humanButton.x,humanButton.y+8,47,12);
			this.addChild(humanMask);
			humanButton.mask = humanMask;
			
			cpuButton = new TextButton();
			this.addChild(cpuButton);
			cpuButton.theText.text = "CPU";
			cpuButton.x = 104;
			cpuButton.y = 34;
			cpuButton.theText.width = 30;
			cpuMask = new Sprite();
			cpuMask.graphics.beginFill(0xFF0000);
			cpuMask.graphics.drawRect(cpuButton.x,cpuButton.y+8,30,12);
			this.addChild(cpuMask);
			cpuButton.mask = cpuMask;
			cpuButton.addEventListener("mouseUp",toggleHumanCPU);
			
			// The Instructions of Importance
			instructions = new TextButton();
			this.addChild(instructions);
			instructions.theText.text = "Instructions";
			instructions.x = 38;
			instructions.y = 50;
			instructions.theText.width = 75;
			var instructionsMask:Sprite = new Sprite();
			instructionsMask.graphics.beginFill(0xFF0000);
			instructionsMask.graphics.drawRect(instructions.x,instructions.y+8,75,12);
			this.addChild(instructionsMask);
			instructions.mask = instructionsMask;
			instructions.addEventListener("mouseUp",playInstructions);
			isInstructionsOn = false;
			
			// Credits
			credits = new TextButton();
			this.addChild(credits);
			credits.theText.text = "Credits";
			credits.x = 50;
			credits.y = 66;
			credits.theText.width = 48;
			var creditsMask:Sprite = new Sprite();
			creditsMask.graphics.beginFill(0xFF0000);
			creditsMask.graphics.drawRect(credits.x,credits.y+8,48,12);
			this.addChild(creditsMask);
			credits.mask = creditsMask;
			credits.addEventListener("mouseUp",playCredits);
			isCreditsOn = false;
		}
		
		function toggleHumanCPU(e:Event):void{
			var selectedButton:TextButton = humanButton; // Currently selected button
			var unselectedButton:TextButton = cpuButton;
			if(!humanButton.isSelected){
				selectedButton = cpuButton;
				unselectedButton = humanButton;
			}
			selectedButton.addEventListener("mouseUp",toggleHumanCPU);
			unselectedButton.removeEventListener("mouseUp",toggleHumanCPU);
			selectedButton.addEventListener("enterFrame",selectedButton.decreaseSelectedGlow);
			selectedButton.addEventListener("mouseOver",selectedButton.mouseHover);
			
			selectedButton.isSelected = false;
			unselectedButton.isSelected = true;
		}
		
		function playInstructions(e:Event):void{
			isInstructionsOn = true;
			Document.popUp.placeScreen();
			Document.popUp.scaleX = .5;
			Document.popUp.scaleY = .5;
			Document.popUp.x = Document.popUp.determineX();
			Document.popUp.addEventListener("enterFrame",Document.popUp.rollIn);
			Document.popUp.y = Document.popUp.determineY()+75;
			
			Document.popUp.popUpInstructions();
		}
		
		function playCredits(e:Event):void{
			isCreditsOn = true;
			Document.popUp.placeScreen();
			Document.popUp.scaleX = .5;
			Document.popUp.scaleY = .5;
			Document.popUp.x = Document.popUp.determineX();
			Document.popUp.addEventListener("enterFrame",Document.popUp.rollIn);
			Document.popUp.y = Document.popUp.determineY()+75;
			
			Document.popUp.popUpCredits();
		}
	}
}

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

package{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.events.Event;
	
	public class NewGame extends MovieClip{
		var gameText:TextField;
		var buttonBase:ButtonBase;
		function NewGame(){
			gameText = new TextField();
			gameText.embedFonts = true;
			var gameFormat:TextFormat = new TextFormat(Document.segoeEmbed.fontName, 12, 0x444444);
			gameFormat.align = "center";
			gameText.defaultTextFormat = gameFormat;
			gameText.selectable = false;
			gameText.width = 100;
			gameText.y = -1;
			
			buttonBase = new ButtonBase(100,25);
			this.addChild(buttonBase);
			this.addChild(gameText);
			gameText.text = "New Game";
			
			buttonBase.addEventListener("enterFrame",buttonBase.idleAnimation);
			addEventListener("mouseOver",buttonBase.hoverAnimation);
			addEventListener("mouseUp",initializeNewGame);
		}
		
		function initializeNewGame(e:Event):void{
			Document.popUp.placeScreen();
			Document.popUp.scaleX = .5;
			Document.popUp.scaleY = .5;
			Document.popUp.x = Document.popUp.determineX();
			Document.popUp.addEventListener("enterFrame",Document.popUp.rollIn);
			Document.popUp.y = Document.popUp.determineY()+75;
			
			// For a human game
			if(Document.mainMenu.humanButton.isSelected){
				Document.popUp.popUpPlayerInquiry();
			}
			
			//For a CPU Game
			if(Document.mainMenu.cpuButton.isSelected){
				Document.popUp.isCPUGame = true;
				Document.popUp.popUpCPUInquiry();
			}
		}
	}
}
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

package{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.events.Event;
	import flash.filters.DropShadowFilter;
	import flash.display.Sprite;
	
	public class PopUp extends MovieClip{
		var closeWindow:CloseWindow;
		var cancelWindow:CloseWindow;
		var popUpFilter:DropShadowFilter;
		var accel:Number;
		var time:Number;
		var textFormat:TextFormat;
		
		// For starting a Human Game
		var humanInst:TextField;
		var player1Inst:TextField;
		var player2Inst:TextField;
		var inputPlayer1:InputField;
		var inputPlayer2:InputField;
		
		// For starting a CPU Game
		/*var firstInst:TextField;
		var playerInst:TextField;
		var inputPlayer:InputField;*/
		var isCPUGame:Boolean;
		var inputHuman:InputField;
		var playerFirst:TextButton;
		var playerSecond:TextButton;
		
		var oneButton:TextButton;
		var twoButton:TextButton;
		var thrButton:TextButton;
		var fouButton:TextButton;
		var fivButton:TextButton;
		var numButtonArray:Array;
		
		// For Instructions
		var currentPage:Number;
		var instGoal:TextField;
		var instProcedure:TextField;
		var instComplete:TextField;
		var prevButton:TextButton;
		var nextButton:TextButton;
		var gridExample:GridExample;
		var instScoring:TextField;
		var instMinute:TextField;
		
		// For Credits
		var programCredits:TextField;
		var musicURL:TextURL;
		var musicCredits:TextField;
		
		function PopUp(){
			textFormat = new TextFormat(Document.segoeEmbed.fontName, 24, 0x444444);
			humanInst = new TextField();
			player1Inst = new TextField();
			player2Inst = new TextField();
			humanInst.selectable = false;
			player1Inst.selectable = false;
			player2Inst.selectable = false;
			humanInst.embedFonts = true;
			player1Inst.embedFonts = true;
			player2Inst.embedFonts = true;
			humanInst.defaultTextFormat = textFormat;
			player1Inst.defaultTextFormat = textFormat;
			player2Inst.defaultTextFormat = textFormat;
			
			inputPlayer1 = new InputField();
			inputPlayer2 = new InputField();
			
			isCPUGame = false;
			inputHuman = new InputField();
			playerFirst = new TextButton(true, 24);
			playerSecond = new TextButton(false, 24);
			playerFirst.theText.text = "First";
			playerSecond.theText.text = "Second";
			playerFirst.x = 175;
			playerFirst.y = 190;
			playerFirst.theText.width = 60;
			playerSecond.x = 285;
			playerSecond.y = 190;
			playerSecond.theText.width = 91;
			playerSecond.addEventListener("mouseUp",toggleFirstSecond);
			
			oneButton = new TextButton(false, 24);
			twoButton = new TextButton(false, 24);
			thrButton = new TextButton(true, 24);
			fouButton = new TextButton(false, 24);
			fivButton = new TextButton(false, 24);
			numButtonArray = [oneButton, twoButton, thrButton, fouButton, fivButton];
			for(var i:int = 0; i < numButtonArray.length; i++){
				var numButton = numButtonArray[i];
				numButton.theText.text = String(i+1);
				numButton.x = 190 + 40*i;
				numButton.y = 250;
				numButton.theText.width = 20;
				var numButtonMask:Sprite = new Sprite();
				numButtonMask.graphics.beginFill(0xFF0000);
				numButtonMask.graphics.drawRect(numButton.x, numButton.y + 8, 20, 24);
				this.addChild(numButtonMask);
				numButton.mask = numButtonMask;
				switch(i){
					case 0:
						numButton.addEventListener("mouseUp",toggleNumButtonOne);
						break;
					case 1:
						numButton.addEventListener("mouseUp",toggleNumButtonTwo);
						break;
					case 2:
						// Nothing, since this is already selected
						break;
					case 3:
						numButton.addEventListener("mouseUp",toggleNumButtonFou);
						break;
					case 4:
						numButton.addEventListener("mouseUp",toggleNumButtonFiv);
						break
					default: break;
				}
			}
			
			closeWindow = new CloseWindow();
			this.addChild(closeWindow);
			closeWindow.x = 360;
			closeWindow.y = 345;
			
			cancelWindow = new CloseWindow();
			this.addChild(cancelWindow);
			cancelWindow.x = 170;
			cancelWindow.y = 345;
			
			// Mask the two buttons
			for(var i:int = 0; i < 2; i++){
				var temp:Sprite = new Sprite();
				temp.graphics.beginFill(0xFF0000);
				temp.graphics.drawRect(168+190*i, 343, 184, 49);
				this.addChild(temp);
				switch(i){
					case 0: cancelWindow.mask = temp; break;
					case 1: closeWindow.mask = temp; break
					default: break;
				}
			}
			
			popUpFilter = new DropShadowFilter(0, 0, 0, .3, 10, 10);
			this.filters = [popUpFilter];
			this.alpha = 0;
			time = 0;
			
			// Specific to Instructions
			currentPage = 1;
			instGoal = new TextField();
			instProcedure = new TextField();
			instComplete = new TextField();
			instScoring = new TextField();
			instMinute = new TextField();
			
			initializeText(instGoal);
			initializeText(instProcedure);
			initializeText(instComplete);
			initializeText(instScoring);
			initializeText(instMinute);
			prevButton = new TextButton(false, 24);
			nextButton = new TextButton(false, 24);
			gridExample = new GridExample();
			
			// Credits
			programCredits = new TextField();
			musicCredits = new TextField();
			musicURL = new TextURL(24);
			musicURL.theText.text = "freeplaymusic.com";
			musicURL.hyperlink.url = "http://www.freeplaymusic.com";
			musicURL.x = 160;
			musicURL.y = 60;
			musicURL.theText.width = 225;
			musicURL.theText.height = 44;
			initializeText(programCredits);
			initializeText(musicCredits);
			programCredits.x = 10;
			programCredits.y = 10;
			programCredits.width = 530;
			programCredits.text = "Game and program design by Ardeol";
			musicCredits.x = 10;
			musicCredits.y = 60;
			musicCredits.width = 530;
			musicCredits.height = 300;
			musicCredits.text = "Music from\n    1. Soul Heals (Benjamin Riordan)\n    2. Larger than Life (Simon Smart)\n    3. Pulsed Impression (Riordan)";
		}
		function initializeText(field:TextField){
			field.selectable = false;
			field.embedFonts = true;
			field.defaultTextFormat = textFormat;
		}
		
		/** Supposed to memorize the current listeners in order to apply them later
		    Stores them in an array */ // <-- lol, what is this...?
		function placeScreen():void{
			Document.screenMask.x = 0;
		}
		function removeScreen():void{
			Document.screenMask.x = 560;
			if(Document.mainMenu.isInstructionsOn){
				Document.mainMenu.instructions.addEventListener("enterFrame", Document.mainMenu.instructions.decreaseSelectedGlow);
				Document.mainMenu.instructions.addEventListener("mouseOver", Document.mainMenu.instructions.mouseHover);
			}
			if(Document.mainMenu.isCreditsOn){
				Document.mainMenu.credits.addEventListener("enterFrame", Document.mainMenu.credits.decreaseSelectedGlow);
				Document.mainMenu.credits.addEventListener("mouseOver", Document.mainMenu.credits.mouseHover);
			}
		}
		
		function determineY():Number{    return this.scaleY*200; }
		function determineX():Number{    return this.scaleX*275; }
		
		function rollIn(e:Event):void{
			time++;
			this.y -= 341*time/450 - 11*time*time/450 - 253/675;
			this.alpha += .025;
			if(time >= 40){
				time = 0;
				this.y = determineY();
				this.alpha = 1;
				removeEventListener("enterFrame",rollIn);
				if(Document.mainMenu.isInstructionsOn || Document.mainMenu.isCreditsOn){
					closeWindow.addEventListener("mouseUp", cancelStart);
				}
				else{
					closeWindow.addEventListener("mouseUp",startGame);
					cancelWindow.addEventListener("mouseUp",cancelStart);
				}
			}
		}
		
		function rollOff(e:Event):void{
			this.y += 5;
			this.alpha -= .05;
			if(this.alpha <= 0){
				this.alpha = 0;
				this.x = -560;
				this.scaleX = 1;
				this.scaleY = 1;
				this.y = 0;
				removeEventListener("enterFrame",rollOff);
				if(Document.mainMenu.isInstructionsOn){
					this.removeChild(instGoal);
					this.removeChild(instProcedure);
					this.removeChild(instComplete);
					this.removeChild(instScoring);
					this.removeChild(instMinute);
					this.removeChild(prevButton);
					this.removeChild(nextButton);
					this.removeChild(gridExample);
					Document.mainMenu.isInstructionsOn = false;
				}
				else if(Document.mainMenu.isCreditsOn){
					this.removeChild(programCredits);
					this.removeChild(musicCredits);
					this.removeChild(musicURL);
					Document.mainMenu.isCreditsOn = false;
				}
				else{
					this.removeChild(humanInst);
					this.removeChild(player1Inst);
					this.removeChild(player2Inst);
					this.removeChild(inputPlayer1);
					this.removeChild(inputPlayer2);
					if(isCPUGame){
						this.removeChild(playerFirst);
						this.removeChild(playerSecond);
						this.removeChild(inputHuman);
						this.removeChild(oneButton);
						this.removeChild(twoButton);
						this.removeChild(thrButton);
						this.removeChild(fouButton);
						this.removeChild(fivButton);
						isCPUGame = false;
					}
					//else this.removeChild(player2Inst);
				}
			}
		}
		
		function popUpPlayerInquiry():void{
			closeWindow.buttonBase.addEventListener("enterFrame",closeWindow.buttonBase.idleAnimation);
			closeWindow.addEventListener("mouseOver",closeWindow.buttonBase.hoverAnimation);
			closeWindow.closeText.text = "Begin";
			cancelWindow.buttonBase.addEventListener("enterFrame",cancelWindow.buttonBase.idleAnimation);
			cancelWindow.addEventListener("mouseOver",cancelWindow.buttonBase.hoverAnimation);
			cancelWindow.closeText.text = "Cancel";
			cancelWindow.alpha = 1;
			this.addChild(humanInst);
			this.addChild(player1Inst);
			this.addChild(player2Inst);
			this.addChild(inputPlayer1);
			this.addChild(inputPlayer2);
			humanInst.x = 20;
			humanInst.y = 20;
			humanInst.text = "Specify Player Names";
			humanInst.width = 400;
			player1Inst.x = 40;
			player1Inst.y = 100;
			player1Inst.text = "Player 1:";
			player1Inst.width = 120;
			player2Inst.x = 40;
			player2Inst.y = 200;
			player2Inst.text = "Player 2:";
			player2Inst.width = 120;
			
			inputPlayer1.x = 200;
			inputPlayer1.y = 100;
			inputPlayer2.x = 200;
			inputPlayer2.y = 200;
			inputPlayer1.field.text = "";
			inputPlayer2.field.text = "";
		}
		
		function popUpCPUInquiry():void{
			closeWindow.buttonBase.addEventListener("enterFrame",closeWindow.buttonBase.idleAnimation);
			closeWindow.addEventListener("mouseOver",closeWindow.buttonBase.hoverAnimation);
			closeWindow.closeText.text = "Begin";
			cancelWindow.buttonBase.addEventListener("enterFrame",cancelWindow.buttonBase.idleAnimation);
			cancelWindow.addEventListener("mouseOver",cancelWindow.buttonBase.hoverAnimation);
			cancelWindow.closeText.text = "Cancel";
			cancelWindow.alpha = 1;
			this.addChild(humanInst);
			this.addChild(player1Inst);
			this.addChild(player2Inst);
			this.addChild(inputHuman);
			this.addChild(inputPlayer1); // Used to display names; cannot actually input to these
			this.addChild(inputPlayer2);
			this.addChild(playerFirst);
			this.addChild(playerSecond);
			this.addChild(oneButton);
			this.addChild(twoButton);
			this.addChild(thrButton);
			this.addChild(fouButton);
			this.addChild(fivButton);
			humanInst.x = 20;
			humanInst.y = 20;
			humanInst.text = "Specify Player Name";
			humanInst.width = 400;
			player1Inst.x = 40;
			player1Inst.y = 190;
			player1Inst.text = "I will go:";
			player1Inst.width = 120;
			player2Inst.x = 40;
			player2Inst.y = 250;
			player2Inst.text = "Difficulty:";
			player2Inst.width = 125;
			
			inputHuman.x = 150;
			inputHuman.y = 110;
			inputHuman.field.text = "";
			inputPlayer1.x = -1000; // Offscreen
			inputPlayer1.y = -1000;
			inputPlayer2.x = -1000;
			inputPlayer2.y = -1000;
		}
		
		// Basically Identical to the toggleHumanCPU() in class MainMenu
		function toggleFirstSecond(e:Event):void{
			var selectedButton:TextButton = playerFirst; // Currently selected button
			var unselectedButton:TextButton = playerSecond;
			if(!playerFirst.isSelected){
				selectedButton = playerSecond;
				unselectedButton = playerFirst;
			}
			selectedButton.addEventListener("mouseUp",toggleFirstSecond);
			unselectedButton.removeEventListener("mouseUp",toggleFirstSecond);
			selectedButton.addEventListener("enterFrame",selectedButton.decreaseSelectedGlow);
			selectedButton.addEventListener("mouseOver",selectedButton.mouseHover);
			
			selectedButton.isSelected = false;
			unselectedButton.isSelected = true;
		}
		
		/* The Number Functions
		   They lead to a master toggle function, with the selected number as the argument */
		function toggleNumButtonOne(e:Event):void{
			toggleNumButton(0);
		}
		function toggleNumButtonTwo(e:Event):void{
			toggleNumButton(1);
		}
		function toggleNumButtonThr(e:Event):void{
			toggleNumButton(2);
		}
		function toggleNumButtonFou(e:Event):void{
			toggleNumButton(3);
		}
		function toggleNumButtonFiv(e:Event):void{
			toggleNumButton(4);
		}
		
		function toggleNumButton(newNum:Number):void{
			var oldNum:Number;
			if(oneButton.isSelected) oldNum = 0;
			else if(twoButton.isSelected) oldNum = 1;
			else if(thrButton.isSelected) oldNum = 2;
			else if(fouButton.isSelected) oldNum = 3;
			else oldNum = 4;
			
			var oldNumButton:TextButton = numButtonArray[oldNum];
			var newNumButton:TextButton = numButtonArray[newNum];
			
			switch(oldNum){
				case 0:
					oldNumButton.addEventListener("mouseUp",toggleNumButtonOne);
					break;
				case 1:
					oldNumButton.addEventListener("mouseUp",toggleNumButtonTwo);
					break;
				case 2:
					oldNumButton.addEventListener("mouseUp",toggleNumButtonThr);
					break;
				case 3:
					oldNumButton.addEventListener("mouseUp",toggleNumButtonFou);
					break;
				case 4:
					oldNumButton.addEventListener("mouseUp",toggleNumButtonFiv);
					break;
				default: break;
			}
			oldNumButton.addEventListener("enterFrame",oldNumButton.decreaseSelectedGlow);
			oldNumButton.addEventListener("mouseOver",oldNumButton.mouseHover);
			
			switch(newNum){
				case 0:
					newNumButton.removeEventListener("mouseUp",toggleNumButtonOne);
					break;
				case 1:
					newNumButton.removeEventListener("mouseUp",toggleNumButtonTwo);
					break;
				case 2:
					newNumButton.removeEventListener("mouseUp",toggleNumButtonThr);
					break;
				case 3:
					newNumButton.removeEventListener("mouseUp",toggleNumButtonFou);
					break;
				case 4:
					newNumButton.removeEventListener("mouseUp",toggleNumButtonFiv);
					break;
				default: break;
			}
			
			newNumButton.isSelected = true;
			oldNumButton.isSelected = false;
		}
		
		// Actually Start the Game
		function startGame(e:Event):void{
			var delayNum = -2;
			// Resets all of the gridUnits in the Grid
			// This is the only entity that can clear the screen
			for(var i:int; i < Grid.numArray.length; i++){
				var tile:GridUnit = Grid.gridArray[i];
				if(Grid.numArray[i] != ""){
					delayNum += 2;
					tile.delayDisappear = delayNum;
					tile.addEventListener("enterFrame",tile.numberDisappear);
				}
			}
			
			cancelStart(null);
			
			// Configure all of the Game data
			Grid.resetNumArray();
			Grid.cpuDiff = 0;
			// Define exceptions for a CPU game
			if(isCPUGame){
				if(playerFirst.isSelected){
					inputPlayer1.field.text = inputHuman.field.text;
					inputPlayer2.field.text = Document.CPU_NAME;
				}
				else{
					inputPlayer1.field.text = Document.CPU_NAME;
					inputPlayer2.field.text = inputHuman.field.text;
				}
				var temp:Number = 0;
				//while(!Document.mainMenu.numButtonArray[temp].isSelected && temp < 5) temp++;
				//Grid.cpuDiff = temp+1;
				while(!numButtonArray[temp].isSelected && temp < 5) temp++;
				Grid.cpuDiff = temp+1;
			}
			Grid.player1Name = inputPlayer1.field.text;
			Grid.player2Name = inputPlayer2.field.text;
			if(Grid.player1Name == "") Grid.player1Name = "Player 1";
			if(Grid.player2Name == "") Grid.player2Name = "Player 2";
			// Remove roll option if it was active and the cpu is starting the next game
			if(Grid.player1Name == Document.CPU_NAME && Document.actionArea.rollButton.alpha > .5){
				Document.actionArea.rollButton.addEventListener("enterFrame",Document.actionArea.rollButton.decreaseAlpha);
				Document.actionArea.rollButton.removeEventListener("mouseUp", Document.actionArea.rollButton.performRoll);
			}
			Grid.turn = 0;
			if(Grid.gridUnitSelected > -1){
				var tileToDeselect:GridUnit = Grid.gridArray[Grid.gridUnitSelected];
				tileToDeselect.removeSelection(null);
			}
			if(Grid.gridPlaceSelected != ""){
				var placeToDeselect:GridPlace;
				if(Grid.gridPlaceSelected == "+") placeToDeselect = Document.actionArea.gridPlus;
				else if(Grid.gridPlaceSelected == "-") placeToDeselect = Document.actionArea.gridMinus;
				else placeToDeselect = Document.actionArea.gridNum;
				placeToDeselect.removeSelection(null);
			}
			if(Document.actionArea.isWon){
				Document.actionArea.addEventListener("enterFrame",Document.actionArea.destroyWinScreen);
				Document.actionArea.isWon = false;
			}
			
			Grid.gridPlaceSelected = "";
			Grid.gridUnitSelected = -1;
			if(Document.actionArea.rollButton.buttonBase.currentFrame == 30) Document.actionArea.rollButton.buttonBase.gotoAndPlay(31);
			Grid.deactivateAllGridUnits();
			Document.actionArea.deactivateGridPlaces();
			Document.grid.removeOrientingNames();
			Document.grid.placeOrientingNames();
			
			// Officially Start The Game
			//Document.actionArea.currentPlayer.text = Grid.player2Name;
			Grid.activateRollButton();
		}
		
		function cancelStart(e:Event):void{
			closeWindow.removeEventListener("mouseUp",startGame);
			closeWindow.buttonBase.removeEventListener("enterFrame",closeWindow.buttonBase.idleAnimation);
			closeWindow.removeEventListener("mouseOver",closeWindow.buttonBase.hoverAnimation);
			cancelWindow.removeEventListener("mouseUp",cancelStart);
			cancelWindow.buttonBase.removeEventListener("enterFrame",cancelWindow.buttonBase.idleAnimation);
			cancelWindow.removeEventListener("mouseOver",cancelWindow.buttonBase.hoverAnimation);
			addEventListener("enterFrame",rollOff);
			removeScreen();
		}
		
		// Instructions:
		function popUpInstructions():void{
			currentPage = 1;
			cancelWindow.alpha = 0;
			closeWindow.buttonBase.addEventListener("enterFrame",closeWindow.buttonBase.idleAnimation);
			closeWindow.addEventListener("mouseOver",closeWindow.buttonBase.hoverAnimation);
			closeWindow.closeText.text = "Close";
			
			// text
			this.addChild(instGoal);
			this.addChild(instProcedure);
			this.addChild(instComplete);
			instGoal.alpha = 1;
			instProcedure.alpha = 1;
			instComplete.alpha = 1;
			
			// The buttons
			this.addChild(prevButton);
			this.addChild(nextButton);
			prevButton.x = 10;
			prevButton.y = 344;
			nextButton.x = 120;
			nextButton.y = 344;
			prevButton.theText.text = "< Prev";
			prevButton.theText.width = 95;
			nextButton.theText.text = "Next >";
			nextButton.theText.width = 95;
			prevButton.alpha = 0;
			nextButton.addEventListener("mouseUp",flipNext);
			nextButton.removeEventListener("mouseOver",Document.popUp.nextButton.mouseHover);
			nextButton.addEventListener("mouseOver",Document.popUp.nextButton.mouseHoverNoSelect);
			prevButton.removeEventListener("mouseOver",Document.popUp.prevButton.mouseHover);
			prevButton.addEventListener("mouseOver",Document.popUp.prevButton.mouseHoverNoSelect);
			nextButton.alpha = 1;
			
			instGoal.text = "  In Nonupo, the goal is to achieve a score \n\t\t  closest to zero.";
			instGoal.x = 10;
			instGoal.y = 6;
			instGoal.width = 530;
			instGoal.height = 100;
			
			instProcedure.text = "Two players take turns rolling a 10-sided \ndie labeled 0-9.  Upon a roll, the player \nmay choose to fill an empty grid slot with \n   either the rolled number or a + or -.";
			instProcedure.x = 10;
			instProcedure.y = 100;
			instProcedure.width = 530;
			instProcedure.height = 250;
			
			instComplete.text = "  The game ends when all slots are filled.";
			instComplete.x = 10;
			instComplete.y = 280;
			instComplete.width = 530;
			instComplete.height = 40;
			
			// The Example
			this.addChild(gridExample);
			gridExample.x = 356;
			gridExample.y = 15;
			gridExample.alpha = 0;
			
			this.addChild(instScoring);
			instScoring.alpha = 0;
			instScoring.x = 10;
			instScoring.y = 6;
			instScoring.width = 530;
			instScoring.height = 340;
			instScoring.text = "To tally scores, player one\nsums each row, and player\ntwo sums each column. In\nthe example, Aurora would\nbe player one.  Adjacent\ndigits merge into a single number.\nAurora's score: -3+2+5+13 = 17\nArdeol's score: -20+3+1+53 = 37";
			
			this.addChild(instMinute);
			instMinute.alpha = 0;
			instMinute.x = 10;
			instMinute.y = 6;
			instMinute.width = 530;
			instMinute.height = 340;
			instMinute.text = "Additional Details:\nSigns may be placed on edges\nSigns cannot be next to each other\nTurns cannot be passed\nIn the end, the game automatically\n     tallies the scores for you\nHave fun!";
		}
		
		/*  Functions for flipping Inst. pages
		=========================================*/
		function flipNext(e:Event):void{
			currentPage++;
			this.addEventListener("enterFrame",fadeOut);
			this.addEventListener("enterFrame",fadeIn);
			if(currentPage == 3) prevButton.removeEventListener("mouseUp",flipPrev);
			nextButton.removeEventListener("mouseUp",flipNext);
		}
		function flipPrev(e:Event):void{
			currentPage--;
			this.addEventListener("enterFrame",fadeOut);
			this.addEventListener("enterFrame",fadeIn);
			if(currentPage == 1) nextButton.removeEventListener("mouseUp",flipNext);
			prevButton.removeEventListener("mouseUp",flipPrev);
		}
		function fadeIn(e:Event):void{
			switch(currentPage){
				case 1:
					instGoal.alpha += .1;
					instProcedure.alpha += .1;
					instComplete.alpha += .1;
					if(instGoal.alpha >= 1){
						instGoal.alpha = 1;
						instProcedure.alpha = 1;
						instComplete.alpha = 1;
						this.removeEventListener("enterFrame",fadeIn);
						nextButton.addEventListener("mouseUp",flipNext);
					}
					break;
				case 2:
					gridExample.alpha += .1;
					prevButton.alpha += .1;
					nextButton.alpha += .1;
					instScoring.alpha += .1;
					if(gridExample.alpha >=1){
						gridExample.alpha = 1;
						prevButton.alpha = 1;
						nextButton.alpha = 1;
						instScoring.alpha = 1;
						this.removeEventListener("enterFrame",fadeIn);
						prevButton.addEventListener("mouseUp",flipPrev);
						nextButton.addEventListener("mouseUp",flipNext);
					}
					break;
				case 3:
					instMinute.alpha += .1;
					if(instMinute.alpha >= 1){
						instMinute.alpha = 1;
						this.removeEventListener("enterFrame",fadeIn);
						prevButton.addEventListener("mouseUp",flipPrev);
					}
					break;
				default: break;
			}
		}
		function fadeOut(e:Event):void{
			if(currentPage != 2){
				if(currentPage == 1) prevButton.alpha -= .1;
				if(currentPage == 3) nextButton.alpha -= .1;
				gridExample.alpha -= .1;
				instScoring.alpha -= .1;
				if(instScoring.alpha <= 0){
					instScoring.alpha = 0;
					gridExample.alpha = 0;
					if(currentPage == 1) prevButton.alpha = 0;
					if(currentPage == 3) nextButton.alpha = 0;
					this.removeEventListener("enterFrame",fadeOut);
				}
			}
			else if(currentPage == 2){
				instGoal.alpha -= .1;
				instProcedure.alpha -= .1;
				instComplete.alpha -= .1;
				instMinute.alpha -= .1;
				if(instGoal.alpha <= 0 && instMinute.alpha <= 0){
					instGoal.alpha = 0;
					instProcedure.alpha = 0;
					instComplete.alpha = 0;
					instMinute.alpha = 0;
					this.removeEventListener("enterFrame",fadeOut);
				}
			}
		}
		
		// Credits:
		function popUpCredits():void{
			cancelWindow.alpha = 0;
			closeWindow.buttonBase.addEventListener("enterFrame",closeWindow.buttonBase.idleAnimation);
			closeWindow.addEventListener("mouseOver",closeWindow.buttonBase.hoverAnimation);
			closeWindow.closeText.text = "Close";
			
			this.addChild(programCredits);
			this.addChild(musicCredits);
			this.addChild(musicURL);
		}
	}
}

package{
	import flash.display.MovieClip;
	public class Preloader extends MovieClip{
		static var guts:*;
		public function Preloader(){
			guts = this.getChildAt(0);
		}
	}
}

package{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class RollDie extends MovieClip{
		var rollText:TextField;
		var buttonBase:ButtonBase;
		var isSelectable:Boolean;
		function RollDie(){
			isSelectable = false;
			
			rollText = new TextField();
			rollText.embedFonts = true;
			var rollFormat:TextFormat = new TextFormat(Document.segoeEmbed.fontName, 16, 0x444444);
			rollFormat.align = "center";
			rollText.defaultTextFormat = rollFormat;
			rollText.selectable = false;
			rollText.width = 120;
			rollText.y = -2;
			
			buttonBase = new ButtonBase(120,30);
			this.addChild(buttonBase);
			this.addChild(rollText);
			rollText.text = "Roll";
			
			this.alpha = .25;
		}
		
		// Causes itself to be selectable
		function activateSelf():void{
			if(Grid.turn > 1) buttonBase.gotoAndPlay(buttonBase.currentFrame+1);
			if(Grid.player1Name == Document.CPU_NAME && Grid.turn % 2 == 1 ||
			   Grid.player2Name == Document.CPU_NAME && Grid.turn % 2 == 0){
				Document.cpu.initiateComputerSequence(Grid.cpuDiff);
			}
			else{
				addEventListener("enterFrame",increaseAlpha);
				addEventListener("mouseOver",buttonBase.hoverAnimation);
				buttonBase.addEventListener("enterFrame",buttonBase.idleAnimation);
			}
		}
		
		/* Event Listeners
		=============================*/
		function increaseAlpha(e:Event):void{
			this.alpha += .05;
			if(this.alpha >= 1){
				removeEventListener("enterFrame",increaseAlpha);
				this.alpha = 1;
				addEventListener("mouseUp",performRoll);
			}
		}
		function decreaseAlpha(e:Event):void{
			this.alpha -= .05;
			if(this.alpha <= .25){
				removeEventListener("enterFrame",decreaseAlpha);
				this.alpha = .25;
				buttonBase.removeEventListener("enterFrame",buttonBase.idleAnimation);
				removeEventListener("mouseOver",buttonBase.hoverAnimation);
			}
		}
		function disappear(e:Event):void{
			this.alpha -= .05;
			if(this.alpha <= 0){
				removeEventListener("enterFrame",disappear);
				this.alpha = 0;
				buttonBase.removeEventListener("enterFrame",buttonBase.idleAnimation);
				removeEventListener("mouseOver",buttonBase.hoverAnimation);
			}
		}
		
		/** The first deactivates roll
			The second activates the GridPlaces */
		function performRoll(e:MouseEvent):void{
			var largeNum:LargeNumber = new LargeNumber();
			stage.addChild(largeNum);
			removeEventListener("mouseUp",performRoll);
		}
		
		function performRollSecond():void{
			Document.actionArea.gridMinus.activateSelf();
			Document.actionArea.gridPlus.activateSelf();
			Document.actionArea.gridNum.activateSelf();
			Grid.activateAvailableGridUnits();
			Document.actionArea.gridNum.finishRoll(Math.floor(Math.random()*10));
		}
	}
}

package{
	import flash.display.MovieClip;
	import flash.events.Event;
	
	public class SelectParticle extends MovieClip{
		var xVelo:Number;
		var yVelo:Number;
		var speed:Number;
		var xDeviation:Number;
		var yDeviation:Number;
		
		function SelectParticle(){
			speed = 3.5;
			xVelo = speed;
			yVelo = 0;
			xDeviation = 0;
			yDeviation = 0;
			addEventListener("enterFrame",moveParticle);
			addEventListener("enterFrame",addAlpha);
		}
		
		/** Moves the particle in a square, stopping it at checkpoints to flip direction.
		    Also includes random deviation at the end. */
		function moveParticle(e:Event):void{
			if(this.x >= 47 && xVelo > 0){
				this.x = 47;
				xDeviation = 0;
				xVelo = 0;
				yVelo = speed;
			}
			if(this.y >= 47 && yVelo > 0){
				this.y = 47;
				yDeviation = 0;
				xVelo = -speed;
				yVelo = 0;
			}
			if(this.x <= -3 && xVelo < 0){
				this.x = -3;
				xDeviation = 0;
				xVelo = 0;
				yVelo = -speed;
			}
			if(this.y <= -3 && yVelo < 0){
				this.y = -3;
				yDeviation = 0;
				xVelo = speed;
				yVelo = 0;
			}
			this.x += xVelo;
			this.y += yVelo;
			
			/* Deviation Algorithm; Particles randomly move around from their parent position,
			   but by no more than 2 pixels in any direction.  Subtle, but effective. */
			if(Math.random() > .5){
				var temp = Math.floor(Math.random()*3-1);
				// Select direction
				if(Math.random() > .5){
					if(xDeviation + temp > 2 || xDeviation + temp < -2) temp = -temp;
					xDeviation += temp;
					this.x += temp;
				}
				else{
					if(yDeviation + temp > 2 || yDeviation + temp < -2) temp = -temp;
					yDeviation += temp;
					this.y += temp;
				}
			}
		}
		
		// Makes less transparent
		function addAlpha(e:Event):void{
			this.alpha += .05;
			if(this.alpha >= 1) removeEventListener("enterFrame",addAlpha);
		}
		
		/** Makes transparent, then removes all listeners from itself.
		    After that, it tells its parent to remove it. */
		function removeAlpha(e:Event):void{
			this.alpha -= .1;
			if(this.alpha <= 0){
				removeEventListener("enterFrame",moveParticle);
				removeEventListener("enterFrame",removeAlpha);
				parent.removeChild(this);
			}
		}
	}
}

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

package{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.globalization.NumberParseResult;

	public class TheComputer extends MovieClip{
		// PATHETIC HUMAN.  I WILL DESTROY YOU.
		/** Here is how the computer operates, according to level:
			  Lv 1: Performs runAnalysis for numbers and runSignAnalysis for signs (which subsequentially calls runAnalysis)
			        Level 1 ignores good moves that the opponent might make and purely goes for an offensive strategy
			  Lv 2: Performs runAnalysis for numbers and runSignAnalysis for signs
			        Unlike level 1, level 2 will take into account the negative aspects of the moves it makes as well as
					find potentially good moves the opponent may make
			  Lv 3: Performs runAdvancedAnalysis for both signs and numbers.  In the above analyses, the computer only determines
			        the value of the rows/columns affected by its move.  The advanced analysis determines the change in the current scores
					made by the move in question.  Generally, this causes the computer to ignore spaces that are guaranteed
					numbers, unless it rolls a low or high number.
			  Lv 4: Performs runForesightAnalysis for both signs and numbers.  The foresight analysis looks to see what moves
			  		the opponent might make if the computer makes a particular move.  It records the worst score the oppoent can make
					(which is the score the opponent favors) and uses those as values.  The advanced analysis is used to determine
					values.  Basically, this computer looks one move ahead.  It switches to the level 3 computer after some turns
					goes by, since looking ahead only helps during the sign phase.
			  Lv 5: Uses an advanced current score measure which attempts to guage the value of a row's potential.  For instance, it awards
			  		points if the row COULD BE some number in one or two moves.  It acts basically identically to the level 4 computer.
					I only could not get it to look three moves ahead because of the ridiculous early game lag.
			*/
		var delayCounter:Number;
		var delayCounterMax:Number;
		var currentNumber:Number;
		var countLoops:Number;
		var rolledNumber:Number;
		var availableUnitIndices:Array;
		var currentUnitToAnalyze:Number;
		
		var theoreticalGrid:Array; // Holds a theoretical grid.  ie.  What if space 4 were a +?
		/*  All the theo Arrays correspond with each other.  They ought to have the same number of elements.
		    Indices holds the indices
			Postulates hold the symbols to go in the above indices
			Scores hold the value of putting a postulate into an index
			*/
		var theoIndices:Array;
		var theoPostulates:Array;
		var theoScores:Array;
		
		function TheComputer(){
			theoreticalGrid = new Array();
			theoIndices = new Array();
			theoPostulates = new Array();
			theoScores = new Array();
		}
		
		function initiateComputerSequence(difficulty:Number):void{
			// Deactivate new game.  Causes all sorts of problems if activated during cpu's turn.
			Document.mainMenu.newGame.removeEventListener("mouseUp", Document.mainMenu.newGame.initializeNewGame);
			Document.mainMenu.newGame.removeEventListener("mouseOver", Document.mainMenu.newGame.buttonBase.hoverAnimation);
			if(Grid.turn == 1) setDelay(90);
			else setDelay(30);
			currentNumber = -1;
			addEventListener("enterFrame",displayLargeNumber);
			//trace("=========================");
		}
		
		function displayLargeNumber(e:Event):void{
			if(testDelay()){
				var largeNumber:LargeNumber = new LargeNumber();
				largeNumber.isCPU = true;
				stage.addChild(largeNumber);
				removeEventListener("enterFrame",displayLargeNumber);
			}
		}
		
		function setDelay(max:Number = 0):void{
			delayCounter = 0;
			delayCounterMax = max;
		}
		// Returns true if delay is done
		function testDelay():Boolean{
			delayCounter++;
			return delayCounter >= delayCounterMax;
		}
		
		function beginThinking():void{
			rolledNumber = Number(Document.actionArea.gridNum.gridCharacter.text);
			availableUnitIndices = determineAvailableGridUnits(Grid.numArray);
			theoreticalGrid = Grid.numArray;
			theoScores = flushArray(theoScores);
			theoIndices = flushArray(theoIndices);
			theoPostulates = flushArray(theoPostulates);
			if(Grid.turn == 1){
				setDelay(25);
				// On first turn, make a random move; creates game variety
				addEventListener("enterFrame",makeRandomDecision);
			}
			else{
				currentUnitToAnalyze = 0;
				if(Grid.cpuDiff < 5 || numberOfNonNumberUnits(Grid.numArray) <= 2)
					addEventListener("enterFrame", analyzeUnit);
				else{
					generateTheoLists();
					addEventListener("enterFrame", advancedAnalyzeUnit);
				}
			}
		}
		
		function makeRandomDecision(e:Event):void{
			if(testDelay()){
				var selectedSquare:Number = Math.floor(Math.random()*availableUnitIndices.length);
				var type:String = "num";
				switch(Math.floor(Math.random()*3)){
					case 0:
						type = "+"; break;
					case 1:
						type = "-"; break;
					default: break;
				}
				Grid.cpuAssignGridValue(availableUnitIndices[selectedSquare], type);
				Document.mainMenu.newGame.addEventListener("mouseUp", Document.mainMenu.newGame.initializeNewGame);
				Document.mainMenu.newGame.addEventListener("mouseOver", Document.mainMenu.newGame.buttonBase.hoverAnimation);
				removeEventListener("enterFrame",makeRandomDecision);
			}
		}
		
		function determineAvailableGridUnits(numberArray:Array):Array{
			var temp:Array = new Array();
			for(var i:int = 0; i < numberArray.length; i++){
				if(numberArray[i] == "")
					temp.push(i);
			}
			return temp;
		}
		
		function analyzeUnit(e:Event):void{
			if(Grid.cpuDiff <= 2){
				//if(numberOfNonNumberUnits(Grid.numArray) <= 0 || isANumber(Grid.numArray, availableUnitIndices[currentUnitToAnalyze]) == 0){
					theoScores.push(runAnalysis(Grid.numArray, availableUnitIndices[currentUnitToAnalyze], Document.actionArea.gridNum.gridCharacter.text, 1));
					theoIndices.push(currentUnitToAnalyze);
					theoPostulates.push(Document.actionArea.gridNum.gridCharacter.text);
				//}
			}
			else if(Grid.cpuDiff == 3){
				//if(numberOfNonNumberUnits(Grid.numArray) <= 0 || isANumber(Grid.numArray, availableUnitIndices[currentUnitToAnalyze]) == 0){
					theoScores.push(runAdvancedAnalysis(Grid.numArray, availableUnitIndices[currentUnitToAnalyze], Document.actionArea.gridNum.gridCharacter.text));
					theoIndices.push(currentUnitToAnalyze);
					theoPostulates.push(Document.actionArea.gridNum.gridCharacter.text);
				//}
			}
			else if(Grid.cpuDiff >= 4){
				if(numberOfNonNumberUnits(Grid.numArray) > 2){
					theoScores.push(runForesightAnalysis(Grid.numArray, availableUnitIndices[currentUnitToAnalyze], Document.actionArea.gridNum.gridCharacter.text));
					theoIndices.push(currentUnitToAnalyze);
					theoPostulates.push(Document.actionArea.gridNum.gridCharacter.text);
				}
				else{
					theoScores.push(runAdvancedAnalysis(Grid.numArray, availableUnitIndices[currentUnitToAnalyze], Document.actionArea.gridNum.gridCharacter.text));
					theoIndices.push(currentUnitToAnalyze);
					theoPostulates.push(Document.actionArea.gridNum.gridCharacter.text);
				}
			}
			
			/* */
			if(isANumber(Grid.numArray, availableUnitIndices[currentUnitToAnalyze]) == 0){
				if(Grid.cpuDiff <= 2){
				// Analyze +
				theoScores.push(runSignAnalysis(Grid.numArray, availableUnitIndices[currentUnitToAnalyze], "+", 1));
				theoIndices.push(currentUnitToAnalyze);
				theoPostulates.push("+");
				// Analyze -
				theoScores.push(runSignAnalysis(Grid.numArray, availableUnitIndices[currentUnitToAnalyze], "-", 1));
				theoIndices.push(currentUnitToAnalyze);
				theoPostulates.push("-");
				}
				else if(Grid.cpuDiff == 3 || (Grid.cpuDiff == 4 && numberOfNonNumberUnits(Grid.numArray) <= 2)){
					theoScores.push(runAdvancedAnalysis(Grid.numArray, availableUnitIndices[currentUnitToAnalyze], "+"));
					theoIndices.push(currentUnitToAnalyze);
					theoPostulates.push("+");
					// Analyze -
					theoScores.push(runAdvancedAnalysis(Grid.numArray, availableUnitIndices[currentUnitToAnalyze], "-"));
					theoIndices.push(currentUnitToAnalyze);
					theoPostulates.push("-");
				}
				else if(Grid.cpuDiff >= 4 && numberOfNonNumberUnits(Grid.numArray) > 2){
					theoScores.push(runForesightAnalysis(Grid.numArray, availableUnitIndices[currentUnitToAnalyze], "+"));
					theoIndices.push(currentUnitToAnalyze);
					theoPostulates.push("+");
					// Analyze -
					theoScores.push(runForesightAnalysis(Grid.numArray, availableUnitIndices[currentUnitToAnalyze], "-"));
					theoIndices.push(currentUnitToAnalyze);
					theoPostulates.push("-");
				}
			}
			/* */
			currentUnitToAnalyze++;
			if(currentUnitToAnalyze >= availableUnitIndices.length){
				setDelay(25);  // The delay causes the computer not to make a move too quickly
				addEventListener("enterFrame", determineBestChoice);
				removeEventListener("enterFrame", analyzeUnit);
			}
		}
		
		/* */
		function runForesightAnalysis(gridToUse:Array, gridIndex:Number, postulate:String):Number{
			var tempGrid:Array = gridToUse.slice(0, gridToUse.length);
			var firstScore:Number = runAdvancedAnalysis(tempGrid, gridIndex, postulate);
			tempGrid[gridIndex] = postulate;
			var newAvailableUnits:Array = determineAvailableGridUnits(tempGrid);
			var secondScore:Number = 9999999;
			for(var i:int = 0; i < newAvailableUnits.length; i++){
				var temp:Number;
				temp = runAdvancedAnalysis(tempGrid, newAvailableUnits[i],"5");
				if(temp < secondScore) secondScore = temp;
			}
			for(var i:int = 0; i < newAvailableUnits.length; i++){
				var temp:Number;
				var tempNeg:Number;
				if(isANumber(tempGrid, newAvailableUnits[i]) == 0){
					temp = runAdvancedAnalysis(tempGrid, newAvailableUnits[i],"+");
					tempNeg = runAdvancedAnalysis(tempGrid, newAvailableUnits[i], "-");
					if(tempNeg < temp) temp = tempNeg;
					if(temp < secondScore) secondScore = temp;
				}
			}
			//trace(gridIndex + ", " + postulate +  ": " + firstScore + ", " + String(secondScore));
			if(firstScore < secondScore || firstScore > Math.abs(secondScore))
				return firstScore;
			return secondScore;
		}
		/* */
		
		/* 
		function runForesightAnalysis(gridToUse:Array, gridIndex:Number, postulate:String, color:Number = 1):Number{
			var tempGrid:Array = gridToUse.slice(0, gridToUse.length);
			var firstScore:Number = runAdvancedAnalysis(tempGrid, gridIndex, postulate);
			tempGrid[gridIndex] = postulate;
			var newAvailableUnits:Array = determineAvailableGridUnits(tempGrid);
			var secondScore:Number = 9999999*color;
			for(var i:int = 0; i < newAvailableUnits.length; i++){
				var temp:Number;
				temp = runAdvancedAnalysis(tempGrid, newAvailableUnits[i],"5");
				if(temp < secondScore && color == 1) secondScore = temp;
				else if(temp > secondScore && color == -1) secondScore = temp;
			}
			for(var i:int = 0; i < newAvailableUnits.length; i++){
				var temp:Number;
				var tempNeg:Number;
				if(isANumber(tempGrid, newAvailableUnits[i]) == 0){
					temp = runAdvancedAnalysis(tempGrid, newAvailableUnits[i],"+");
					tempNeg = runAdvancedAnalysis(tempGrid, newAvailableUnits[i], "-");
					if(tempNeg < temp && color == 1) temp = tempNeg;
					else if(tempNeg > temp && color == -1) temp = tempNeg;
					if(temp < secondScore && color == 1) secondScore = temp;
					else if(temp > secondScore && color == -1) secondScore = temp;
				}
			}
			//trace(gridIndex + ", " + postulate +  ": " + firstScore + ", " + String(secondScore));
			if(Math.abs(secondScore) > Math.abs(firstScore))
				return secondScore;
			//return firstScore+Math.floor(secondScore/10);
			if(color == 1){
				if(firstScore < secondScore || firstScore > Math.abs(secondScore))
					return firstScore;
				return secondScore;
			}
			else{
				if(firstScore > secondScore || secondScore > Math.abs(firstScore))
				   return firstScore;
				return secondScore;
			}
			return secondScore;
		}
		/* */
		
		/*  The advanced algorithm tests for more than just rows; it considers net worth
			*/
		function runAdvancedAnalysis(gridToUse:Array, gridIndex:Number, postulate:String):Number{
			var tempGrid:Array = gridToUse.slice(0, gridToUse.length);
			var curHorizScore:Number;
			var curVertScore:Number;
			if(Grid.cpuDiff < 5){
				curHorizScore = currentScore(tempGrid, 6, 1);
				curVertScore = currentScore(tempGrid, 1, 6);
			}
			else{
				curHorizScore = advancedCurrentScore(tempGrid, 6, 1);
				curVertScore = advancedCurrentScore(tempGrid, 1, 6);
			}
			tempGrid[gridIndex] = postulate;
			var newHorizScore:Number;
			var newVertScore:Number;
			if(Grid.cpuDiff < 5){
				newHorizScore = currentScore(tempGrid, 6, 1);
				newVertScore = currentScore(tempGrid, 1, 6);
			}
			else{
				newHorizScore = advancedCurrentScore(tempGrid, 6, 1);
				newVertScore = advancedCurrentScore(tempGrid, 1, 6);
			}
			var horizNet:Number = newHorizScore - curHorizScore;
			var vertNet:Number = newVertScore - curVertScore;
			if(currentScore(tempGrid, 1, 6) < 0) vertNet *= -1;
			if(currentScore(tempGrid, 6, 1) < 0) horizNet *= -1;
			//trace(gridIndex + ", " + postulate + ": " + String(horizNet-vertNet));
			if(Grid.player1Name == Document.CPU_NAME) // if cpu is player 1...
				return vertNet - horizNet;
			return horizNet - vertNet;
		}
		
		function runAnalysis(gridToUse:Array, gridIndex:Number, postulate:String, depth:int = 2, color:Number = 1):Number{
			var tempGrid:Array = gridToUse.slice(0, gridToUse.length);
			tempGrid[gridIndex] = postulate;
			// Depth is theoretical; so far does not work in practice
			// The cpu seems to be better at looking 1 move ahead than two...
			if(depth > 1){
				/* */
				var newAvailableUnits:Array = determineAvailableGridUnits(tempGrid);
				var bestScore:Number = 999999999;
				for(var i:int = 0; i < newAvailableUnits.length; i++){
					var temp:Number = runAnalysis(tempGrid, newAvailableUnits[i], "5", depth - 1, -color);
					if(temp < bestScore && color == -1) bestScore = temp;
					else if(temp > bestScore && color == 1) bestScore = temp;
				}
				/* */
				return bestScore;
			}
			else{
				var horizString:String = tempGrid[gridIndex];
				var factor:Number = 1;
				var safety:Number = 0;
				/*  */
				// Horiz Calc
				while(gridIndex-factor > 6*Math.floor(1.0/6.0*gridIndex)-1 && safety < 10){
					if(isANumber(tempGrid, gridIndex - factor) != 0){
						if(tempGrid[gridIndex-factor] == "") horizString = "5" + horizString;
						else horizString = tempGrid[gridIndex-factor] + horizString;
					}
					else if(tempGrid[gridIndex-factor] == "-"){
						horizString = "-" + horizString;
						break;
					}
					else break;  // breaks if the slot is ""
					factor++;
					safety++;
				}
				if(safety >= 10) trace("Loop 1 safety broken");
				factor = 1;
				safety = 0;
				/* */
				while(gridIndex+factor < 6*Math.ceil(1.0/6.0*(gridIndex+1)) && safety < 10){
					if(isANumber(tempGrid, gridIndex + factor) != 0){
						if(tempGrid[gridIndex+factor] == "") horizString += "5";
						else horizString += tempGrid[gridIndex+factor];
					}
					else break;
					factor++;
					safety++;
				}
				/* */
				if(safety >= 10) trace("Loop 2 safety broken");
				// Vert Calc
				var vertString:String = tempGrid[gridIndex];
				factor = 1;
				safety = 0;
				/* */
				while(gridIndex-6*factor >= 0 && safety < 10){
					if(isANumber(tempGrid, gridIndex - 6*factor) != 0){
						if(tempGrid[gridIndex-6*factor] == "") vertString = "5" + vertString;
						else vertString = tempGrid[gridIndex-6*factor] + vertString;
					}
					else if(tempGrid[gridIndex-6*factor] == "-"){
						vertString = "-" + vertString;
						break;
					}
					else break;  // breaks if the slot is ""
					factor++;
					safety++;
				}
				if(safety >= 10) trace("Loop 3 safety broken");
				factor = 1;
				safety = 0;
				/* */
				while(gridIndex+6*factor <= 35 && safety < 10){
					if(isANumber(tempGrid, gridIndex + 6*factor) != 0){
						if(tempGrid[gridIndex+6*factor] == "") vertString += "5";
						else vertString += tempGrid[gridIndex+6*factor];
					}
					else break;
					factor++;
					safety++;
				}
				/* */
				if(safety >= 10) trace("Loop 4 safety broken");
				var vertScore:Number = Number(vertString);
				var horizScore:Number = Number(horizString);
				if(currentScore(tempGrid, 1, 6) < 0) vertScore *= -1;
				if(currentScore(tempGrid, 6, 1) < 0) horizScore *= -1;
				if(Grid.player1Name == Document.CPU_NAME) // if cpu is player 1...
					return vertScore - horizScore*(Grid.cpuDiff-1);
				//trace("Score " + gridIndex + " : " + String(horizScore - vertScore));
				return horizScore - vertScore*(Grid.cpuDiff-1);
			}
			return 0;
		}
		
		/*  The sign analysis runs four of the above analyses.
			The total score is the aggregate of the results
			*/
		function runSignAnalysis(gridToUse:Array, gridIndex:Number, sign:String, depth:int = 2):Number{
			var tempGrid:Array = gridToUse.slice(0, gridToUse.length);
			tempGrid[gridIndex] = sign;
			var score1:Number = 0;
			var score2:Number = 0;
			var score3:Number = 0;
			var score4:Number = 0;
			if(gridIndex-6 >= 0){
				score1 = runAnalysis(tempGrid, gridIndex-6, "5", 1);
			}
			if(gridIndex-1 >= 0 && gridIndex%6 != 0){
				score2 = runAnalysis(tempGrid, gridIndex-1, "5", 1);
			}
			if(gridIndex+6 <= 35){
				score3 = runAnalysis(tempGrid, gridIndex+6, "5", 1);
			}
			if(gridIndex+1 <= 35 && gridIndex%6 != 5){
				score4 = runAnalysis(tempGrid, gridIndex+1, "5", 1);
			}
			//trace(gridIndex + ": " + String(score1+score2+score3+score4));
			return score1+score2+score3+score4;
		}
		
		/*  Determines the best choice from the theo Arrays.
			The best offensive choice is the one with the highest number.
			The best defensive choice is the lowest number, assuming it is possible to defend
			The logic behind the defensive choice is that by putting a number in that spot, obviously the computer
			severely hurts itself.  Therefore, it is logical to assume that if the computer moves elsewhere, then
			the player will instead play that square.  Therefore, if the absolute value of the worst score is
			greater than the best score, it is better to defend than to attack.  If possible, place a sign there.
			*/
		function determineBestChoice(e:Event):void{
			if(testDelay()){
				var curHighestIndex:Number = 0;
				for(var i:int = 1; i < theoScores.length; i++){
					if(theoScores[i] > theoScores[curHighestIndex])
						curHighestIndex = i;
				}
				var curLowestIndex:Number = 0;
				for(var j:int = 1; j < theoScores.length; j++){
					if(Grid.cpuDiff <=4 && theoScores[j] < theoScores[curLowestIndex] && theoPostulates[j] != "+" && theoPostulates[j] != "-")
						curLowestIndex = j;
					if(Grid.cpuDiff == 6 && theoScores[j] < theoScores[curLowestIndex])
						curLowestIndex = j;
				}
								
				/*
				trace("Highest: " + theoScores[curHighestIndex]);
				trace("Highest At: " + availableUnitIndices[theoIndices[curHighestIndex]]);
				trace("Lowest: " + theoScores[curLowestIndex]);
				trace("Lowest Postulate: " + theoPostulates[curLowestIndex]);
				trace("Lowest At: " + availableUnitIndices[theoIndices[curLowestIndex]]);
				/* */
				
				/*if(Math.abs(theoScores[curLowestIndex]) > Math.abs(theoScores[curHighestIndex]) && isANumber(Grid.numArray, availableUnitIndices[theoIndices[curLowestIndex]]) == 0){
					trace("I defended!");
					var plusScore:Number = runSignAnalysis(Grid.numArray, availableUnitIndices[theoIndices[curLowestIndex]], "+", 1);
					var minusScore:Number = runSignAnalysis(Grid.numArray, availableUnitIndices[theoIndices[curLowestIndex]], "-", 1);
					if(plusScore > minusScore)
						Grid.cpuAssignGridValue(availableUnitIndices[theoIndices[curLowestIndex]], "+");
					else
						Grid.cpuAssignGridValue(availableUnitIndices[theoIndices[curLowestIndex]], "-");
				}*/
				if(!defenseAlgorithm(Grid.numArray, curLowestIndex, curHighestIndex)){
					var postulateType:String = "num";
					if(theoPostulates[curHighestIndex] == "+")
						postulateType = "+";
					else if(theoPostulates[curHighestIndex] == "-")
						postulateType = "-";
					Grid.cpuAssignGridValue(availableUnitIndices[theoIndices[curHighestIndex]], postulateType);
				}
				// Reactivate new game.
				Document.mainMenu.newGame.addEventListener("mouseUp", Document.mainMenu.newGame.initializeNewGame);
				Document.mainMenu.newGame.addEventListener("mouseOver", Document.mainMenu.newGame.buttonBase.hoverAnimation);
				removeEventListener("enterFrame", determineBestChoice);
			}
		}
		
		/*  Returns true if the algorithm produced a move
			*/
		function defenseAlgorithm(gridToUse:Array, lowest:Number, highest:Number):Boolean{
			if(Grid.cpuDiff == 2){
				if(Math.abs(theoScores[lowest]) > Math.abs(theoScores[highest]) && isANumber(gridToUse, availableUnitIndices[theoIndices[lowest]]) == 0){
					//trace("I defended!");
					var plusScore:Number = runSignAnalysis(gridToUse, availableUnitIndices[theoIndices[lowest]], "+", 1);
					var minusScore:Number = runSignAnalysis(gridToUse, availableUnitIndices[theoIndices[lowest]], "-", 1);
					if(plusScore > minusScore)
						Grid.cpuAssignGridValue(availableUnitIndices[theoIndices[lowest]], "+");
					else
						Grid.cpuAssignGridValue(availableUnitIndices[theoIndices[lowest]], "-");
					return true;
				}
			}
			else if(Grid.cpuDiff == 3 && Math.abs(theoScores[lowest]) > Math.abs(theoScores[highest])){
				/*
				if(theoPostulates[lowest] == "+" || theoPostulates[lowest] == "-"){
					// Can defend this either by placing a sign to an orthogonal square or a number on the square itself
					//trace("I special defended!");
					var post:String = "num";
					var lowestIndex:Number = availableUnitIndices[theoIndices[lowest]];
					var highestOption:Number = 1;
					var highestScore:Number = runAdvancedAnalysis(gridToUse, lowestIndex, Document.actionArea.gridNum.gridCharacter.text);
					if(lowestIndex-6 >= 0){
						if(isANumber(gridToUse, lowestIndex-6) == 0){
							var upScore:Number = runAdvancedAnalysis(gridToUse, lowestIndex - 6, "+");
							if(upScore > highestScore) post = "+";
							var temp:Number = runAdvancedAnalysis(gridToUse, lowestIndex - 6, "-");
							if(temp > upScore){    upScore = temp; post = "-"; }
							if(upScore > highestScore){
								highestScore = upScore;
								highestOption = 2;
							}
						}
					}
					if(lowestIndex-1 >= 0 && lowestIndex%6 != 0){
						if(isANumber(gridToUse, lowestIndex-1) == 0){
							var leftScore:Number = runAdvancedAnalysis(gridToUse, lowestIndex - 1, "+");
							if(leftScore > highestScore) post = "+";
							var temp:Number = runAdvancedAnalysis(gridToUse, lowestIndex - 1, "-");
							if(temp > leftScore){    leftScore = temp; post = "-"; }
							if(leftScore > highestScore){
								highestScore = leftScore;
								highestOption = 3;
							}
						}
					}
					if(lowestIndex+6 <= 35){
						if(isANumber(gridToUse, lowestIndex+6) == 0){
							var downScore:Number = runAdvancedAnalysis(gridToUse, lowestIndex + 6, "+");
							if(downScore > highestScore) post = "+";
							var temp:Number = runAdvancedAnalysis(gridToUse, lowestIndex + 6, "-");
							if(temp > downScore){    downScore = temp; post = "-"; }
							if(downScore > highestScore){
								highestScore = downScore;
								highestOption = 4;
							}
						}
					}
					if(lowestIndex+1 <= 35 && lowestIndex%6 != 5){
						if(isANumber(gridToUse, lowestIndex+1) == 0){
							var rightScore:Number = runAdvancedAnalysis(gridToUse, lowestIndex + 1, "+");
							if(rightScore > highestScore) post = "+";
							var temp:Number = runAdvancedAnalysis(gridToUse, lowestIndex + 1, "-");
							if(temp > rightScore){    rightScore = temp; post = "-"; }
							if(rightScore > highestScore){
								highestScore = rightScore;
								highestOption = 5;
							}
						}
					}
					switch(highestOption){
						case 1: Grid.cpuAssignGridValue(availableUnitIndices[theoIndices[lowest]]); break;
						case 2: Grid.cpuAssignGridValue(availableUnitIndices[theoIndices[lowest]]-6, post); break;
						case 3: Grid.cpuAssignGridValue(availableUnitIndices[theoIndices[lowest]]-1, post); break;
						case 4: Grid.cpuAssignGridValue(availableUnitIndices[theoIndices[lowest]]+6, post); break;
						case 5: Grid.cpuAssignGridValue(availableUnitIndices[theoIndices[lowest]]+1, post); break;
						default: return false; break;
					}
					return true;
				}
				/* */
				if(isANumber(gridToUse, availableUnitIndices[theoIndices[lowest]]) == 0){
					//trace("I defended!");
					var plusScore:Number = runAdvancedAnalysis(gridToUse, availableUnitIndices[theoIndices[lowest]], "+");
					var minusScore:Number = runAdvancedAnalysis(gridToUse, availableUnitIndices[theoIndices[lowest]], "-");
					if(plusScore > minusScore)
						Grid.cpuAssignGridValue(availableUnitIndices[theoIndices[lowest]], "+");
					else
						Grid.cpuAssignGridValue(availableUnitIndices[theoIndices[lowest]], "-");
					return true;
				}
			}
			return false;
		}
		
		// c = 6, r = 1 for horizontal
		function currentScore(gridToUse:Array, c:Number, r:Number):Number{
			var runningScore:Number = 0;
			for(var i:int = 0; i <= 5; i++){
				var scoreArray:Array = [];
				for(var j:int = 0; j <= 5; j++){
					var numElement:String = gridToUse[c*i+r*j];
					if(isANumber(gridToUse, c*i+r*j) == 2) numElement = "5"; // Why 5?  Iunno.
					if(numElement == "")
						scoreArray.push("+");
					else if(scoreArray.length < 1) scoreArray.push(numElement);
					else if(numElement == "+" || numElement == "-") scoreArray.push(numElement);
					else scoreArray[scoreArray.length-1] = scoreArray[scoreArray.length-1].concat(numElement);
				}
				while(scoreArray.length > 0){
					if(scoreArray[0] != "+" && scoreArray[0] != "-")
						runningScore += Number(scoreArray.shift());
					else scoreArray.shift();
				}
			}
			return runningScore;
		}
		
		/*  This is used by the level 5 cpu.  It computes the current score as the above function
			but also factors potentials (ie. the next move could create a 4 digit number, and therefore the opponent must block).
			This is not expected to vary much from the level 4 algorithm, but it is a difference.
			*/
		function advancedCurrentScore(gridToUse:Array, c:Number, r:Number):Number{
			var runningScore:Number = 0;
			for(var i:int = 0; i <= 5; i++){
				var scoreArray:Array = [];
				for(var j:int = 0; j <= 5; j++){
					var numElement:String = gridToUse[c*i+r*j];
					if(isANumber(gridToUse, c*i+r*j) == 2) numElement = "5"; // Why 5?  Iunno.
					if(numElement == "")
						scoreArray.push("+");
					else if(scoreArray.length < 1) scoreArray.push(numElement);
					else if(numElement == "+" || numElement == "-") scoreArray.push(numElement);
					else scoreArray[scoreArray.length-1] = scoreArray[scoreArray.length-1].concat(numElement);
				}
				while(scoreArray.length > 0){
					if(scoreArray[0] != "+" && scoreArray[0] != "-")
						runningScore += Number(scoreArray.shift());
					else scoreArray.shift();
				}
				
				var indices:Array = new Array();
				var values:Array = new Array();
				var modifiedGrid:Array = gridToUse.slice(0,gridToUse.length);
				var safety:Number = 0;
				var scaleFactor = 1;
				while(doesRowHaveNonNumbers(modifiedGrid, i, c, r) && safety < 10){
					safety++;
					indices = flushArray(indices);
					values = flushArray(values);
					for(var k:int = 0; k <= 5; k++){
						if(isANumber(modifiedGrid, c*i+r*k) == 0 && modifiedGrid[c*i+r*k] == ""){
							modifiedGrid[c*i+r*k] = "5";
							indices.push(k);
							values.push(currentRowScore(modifiedGrid, i, c, r));
							modifiedGrid[c*i+r*k] = "";
						}
					}
					var curHighest:Number = 0;
					for(var n:int = 1; n < values.length; n++){
						if(values[n] > values[curHighest])
							curHighest = n;
					}
					runningScore += values[curHighest] / Math.pow(10, 2*scaleFactor);
					//trace("Added Score: " + String(values[curHighest]) + "/" + String(Math.pow(10, 2*scaleFactor)));
					scaleFactor++;
					modifiedGrid[c*i+r*indices[curHighest]] = "5";
				}
				//trace("Running Score: " + runningScore);
				if(safety >= 9) trace("advancedCurrentScore() safety broken");
			}
			return runningScore;
		}
		
		function doesRowHaveNonNumbers(gridToUse:Array, row:Number, c:Number, r:Number):Boolean{
			for(var i:int = 0; i <= 5; i++){
				if(isANumber(gridToUse, c*row+r*i) == 0 && gridToUse[c*row+r*i] == "") return true;
			}
			return false;
		}
		function currentRowScore(gridToUse:Array, row:Number, c:Number, r:Number):Number{
			var currentTot:Number = 0;
			var scoreArray:Array = [];
			for(var j:int = 0; j <= 5; j++){
				var numElement:String = gridToUse[c*row+r*j];
				if(isANumber(gridToUse, c*row+r*j) == 2) numElement = "5"; // Why 5?  Iunno.
				if(numElement == "")
					scoreArray.push("+");
				else if(scoreArray.length < 1) scoreArray.push(numElement);
				else if(numElement == "+" || numElement == "-") scoreArray.push(numElement);
				else scoreArray[scoreArray.length-1] = scoreArray[scoreArray.length-1].concat(numElement);
			}
			while(scoreArray.length > 0){
				if(scoreArray[0] != "+" && scoreArray[0] != "-")
					currentTot += Number(scoreArray.shift());
				else scoreArray.shift();
			}
			return currentTot;
		}
		
		/*  Returns the number of indices that are still not numbers
			*/
		function numberOfNonNumberUnits(gridToUse:Array):Number{
			var temp:Number = 0;
			for(var i:int = 0; i < availableUnitIndices.length; i++){
				if(isANumber(gridToUse, availableUnitIndices[i]) == 0)
					temp++;
			}
			return temp;
		}
		
		/*  Determines whether or not a slot is a number.
		    A slot is a number if it is filled with a number (obv) or is adjacent to a sign
			1 means the element is itself a number
			2 means the element is implicitly a number
			0 means the element is not necessarily a number
			*/
		function isANumber(gridToUse:Array, index:Number):Number{
			if(gridToUse[index] != "" && gridToUse[index] != "+" && gridToUse[index] != "-") return 1;
			if(index-6 >= 0){
				if(gridToUse[index-6] == "+" || gridToUse[index-6] == "-") return 2;
			}
			if(index-1 >= 0 && index%6 != 0){
				if(gridToUse[index-1] == "+" || gridToUse[index-1] == "-") return 2;
			}
			if(index+6 <= 35){
				if(gridToUse[index+6] == "+" || gridToUse[index+6] == "-") return 2;
			}
			if(index+1 <= 35 && index%6 != 5){
				if(gridToUse[index+1] == "+" || gridToUse[index+1] == "-") return 2;
			}
			return 0;
		}
		
		function flushArray(arrayToFlush:Array):Array{
			while(arrayToFlush.length > 0)
				arrayToFlush.shift();
			return arrayToFlush;
		}
		
		/*  Level 5 Architecture
		===================================*/
		/* */
		function generateTheoLists():void{
			for(var i:int = 0; i < availableUnitIndices.length; i++){
				theoIndices.push(i);
				theoPostulates.push(Document.actionArea.gridNum.gridCharacter.text);
				if(isANumber(Grid.numArray, availableUnitIndices[i]) == 0){
					theoIndices.push(i);
					theoPostulates.push("+");
					theoIndices.push(i);
					theoPostulates.push("-");
				}
			}
		}
		function advancedAnalyzeUnit(e:Event):void{
			theoScores.push(runForesightAnalysis(Grid.numArray, availableUnitIndices[theoIndices[currentUnitToAnalyze]], theoPostulates[currentUnitToAnalyze]));
			currentUnitToAnalyze++;
			if(currentUnitToAnalyze >= theoIndices.length){
				setDelay(25);  // The delay causes the computer not to make a move too quickly
				addEventListener("enterFrame", determineBestChoice);
				removeEventListener("enterFrame", advancedAnalyzeUnit);
			}
		}
		/*
		function runPropheticAnalysis(gridToUse:Array, gridIndex:Number, postulate:String):Number{
			var tempGrid:Array = gridToUse.slice(0, gridToUse.length);
			var firstScore:Number = runAdvancedAnalysis(tempGrid, gridIndex, postulate);
			tempGrid[gridIndex] = postulate;
			var newAvailableUnits:Array = determineAvailableGridUnits(tempGrid);
			var secondScore:Number = 9999999;
			for(var i:int = 0; i < newAvailableUnits.length; i++){
				var temp:Number;
				temp = runForesightAnalysis(tempGrid, newAvailableUnits[i],"5", -1);
				if(temp < secondScore) secondScore = temp;
			}
			for(var i:int = 0; i < newAvailableUnits.length; i++){
				var temp:Number;
				var tempNeg:Number;
				if(isANumber(tempGrid, newAvailableUnits[i]) == 0){
					temp = runForesightAnalysis(tempGrid, newAvailableUnits[i],"+", -1);
					tempNeg = runForesightAnalysis(tempGrid, newAvailableUnits[i], "-", -1);
					if(tempNeg < temp) temp = tempNeg;
					if(temp < secondScore) secondScore = temp;
				}
			}
			//trace(gridIndex + ", " + postulate +  ": " + firstScore + ", " + String(secondScore));
			if(firstScore < secondScore || firstScore > Math.abs(secondScore))
				return firstScore;
			return secondScore;
		}
		/* */
	}
}

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
