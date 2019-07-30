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