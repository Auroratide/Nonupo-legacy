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