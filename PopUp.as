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