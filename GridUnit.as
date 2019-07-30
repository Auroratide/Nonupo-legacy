package{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.events.Event;

	public class GridUnit extends MovieClip{
		var gridNumber:TextField;
		var gridID:Number;
		var gridNumberFormat:TextFormat;
		var delayDisappear:Number;
		var colorDiff:Number;
		function GridUnit(){
			delayDisappear = 0;
			gridNumber = new TextField();
			gridNumber.embedFonts = true;
			this.addChild(gridNumber);
			gridNumberFormat = new TextFormat(Document.segoeEmbed.fontName,40,0x444444);
			gridNumberFormat.align = "center";
			gridNumber.defaultTextFormat = gridNumberFormat;
			// gridNumber.x = 8;  If the alignment is set to "left"
			gridNumber.y = -15;
			gridNumber.selectable = false;
			gridNumber.width = 50;
			gridNumber.height = 65;
			gridNumber.text = "";
			gridNumber.alpha = 0;

			/* The Event Listeners
			===================================*/
			// addEventListener("mouseUp",clickMe);
			// addEventListener("mouseOver",performSelection);
		}
		
		function replaceNum():void{
			gridNumber.text = Grid.numArray[gridID];
		}
		
		function activateSelf():void{
			addEventListener("mouseOver",performSelection);
			addEventListener("mouseUp",selectGridUnit);
		}
		function deactivateSelf():void{
			removeEventListener("mouseOver",performSelection);
			removeEventListener("mouseUp",selectGridUnit);
		}
		
		function resetGridUnit():void{
			removeSelection(null);
			addEventListener("mouseUp",selectGridUnit);
			addEventListener("mouseOver",performSelection);
		}
		
		/* The Event Listeners
		===================================*/
		/* clickMe was used for developer purposes.
		function clickMe(e:Event):void{
			var num = Math.floor(10*Math.random());
			gridNumber.text = String(num);
			Grid.numArray[gridID] = String(num);
			addEventListener("enterFrame",numberAppear);
			removeEventListener("mouseUp",clickMe);
			removeEventListener("mouseOver",performSelection);
			removeSelection(null);
		}
		/*  */
		
		/** Selection Animation */
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
			for(var i:int = 1; i < numChildren; i++){
				var child = getChildAt(i);
				child.addEventListener("enterFrame",child.removeAlpha);
			}
		}
		/* End Selection animation **/
		
		function numberAppear(e:Event):void{
			if(gridNumber.alpha < 1) gridNumber.alpha += .05;
			if(gridNumber.alpha >= 1) removeEventListener("enterFrame",numberAppear);
		}
		
		function numberDisappear(e:Event):void{
			if(delayDisappear <= 0){
				if(gridNumber.scaleY > 0){
					gridNumber.scaleY -= .1;
					gridNumber.scaleX -= .1;
					gridNumber.x += 2.5;
					gridNumber.y += 4;
				}
				if(gridNumber.scaleY <= 0){
					removeEventListener("enterFrame",numberDisappear);
					gridNumber.scaleY = 1;
					gridNumber.scaleX = 1;
					gridNumber.x = 0;
					gridNumber.y = -15;
					gridNumber.text = "";
					gridNumber.alpha = 0;
				}
			}
			else delayDisappear--;
		}
		
		function selectGridUnit(e:Event):void{
			if(Grid.gridUnitSelected != -1){
				var gridTemp:GridUnit = Grid.gridArray[Grid.gridUnitSelected];
				gridTemp.resetGridUnit();
			}
			
			Grid.gridUnitSelected = gridID;
			removeEventListener("mouseOut",removeSelection); // Keeps selection animation on as indicator
			removeEventListener("mouseUp",selectGridUnit);
			removeEventListener("mouseOver",performSelection);
			
			var isAdj:Boolean = false;
			if(Grid.gridPlaceSelected != "") Grid.assignGridValue();
			else{
				if(gridID-6 >= 0) isAdj = isAdjToPM(gridID-6);
				if(gridID-1 >= 0 && gridID%6 != 0 && !isAdj) isAdj = isAdjToPM(gridID-1);
				if(gridID+6 <= 35 && !isAdj) isAdj = isAdjToPM(gridID+6);
				if(gridID+1 <= 35 && gridID%6 != 5 && !isAdj) isAdj = isAdjToPM(gridID+1);
				if(isAdj){
					Document.actionArea.gridPlus.disableSelf();
					Document.actionArea.gridMinus.disableSelf();
				}
				else{
					Document.actionArea.gridPlus.disableSelf();
					Document.actionArea.gridMinus.disableSelf();
					Document.actionArea.gridNum.disableSelf();
					Document.actionArea.gridPlus.enableSelf();
					Document.actionArea.gridMinus.enableSelf();
					Document.actionArea.gridNum.enableSelf();
				}
			}
		}
		function isAdjToPM(spotToCheck:Number):Boolean{
			return Grid.numArray[spotToCheck] == "+" || Grid.numArray[spotToCheck] == "-";
		}
		
		function changeTextColor(newColor:Object = 0x444444):void{
			var tempFormat:TextFormat = new TextFormat(Document.segoeEmbed.fontName,40, newColor);
			gridNumber.defaultTextFormat = tempFormat;
			gridNumber.text = gridNumber.text; // Has to be rewritten to work...
		}
		
		function fadeToGrey():void{
			if(gridNumber.defaultTextFormat.color == 0x2A8C9E)
				colorDiff = 1;  // essentially a type
			else colorDiff = 2;
			addEventListener(Event.ENTER_FRAME, commenceFade);
		}
		
		function commenceFade(e:Event):void{
			var newColor:uint;
			if(colorDiff == 1)
				newColor = uint(gridNumber.defaultTextFormat.color) + 0x020000 - 0x000506;
			else
				newColor = uint(gridNumber.defaultTextFormat.color) - 0x050000;
			var newTf:TextFormat = new TextFormat(Document.segoeEmbed.fontName,40,newColor);
			gridNumber.defaultTextFormat = newTf;
			gridNumber.text = gridNumber.text;
			if(gridNumber.defaultTextFormat.color > 0x424242 && gridNumber.defaultTextFormat.color < 0x464646){
				newTf.color = 0x444444;
				gridNumber.defaultTextFormat = newTf;
				gridNumber.text = gridNumber.text;
				removeEventListener(Event.ENTER_FRAME, commenceFade);
			}
		}
	}
}