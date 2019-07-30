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