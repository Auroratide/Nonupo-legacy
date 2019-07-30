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