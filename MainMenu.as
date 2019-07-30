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