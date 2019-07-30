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