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