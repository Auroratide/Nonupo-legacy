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