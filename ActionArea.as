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