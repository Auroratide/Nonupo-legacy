package{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class ButtonBase extends MovieClip{
		var buttonHighlight:ButtonHighlight;
		var buttonHighlightTop:ButtonHighlight;
		var buttonMask:Sprite;
		var buttonMaskTop:Sprite;
		var animationCounter:Number;
		var isHovered:Boolean;
		var hoverHighlight:Sprite;
		function ButtonBase(w:Number,h:Number){
			this.width = w;
			this.height = h;
			animationCounter = Math.floor(Math.random()*100);
			
			buttonHighlight = new ButtonHighlight(0);
			buttonHighlightTop = new ButtonHighlight(-30);
			this.addChild(buttonHighlight);
			this.addChild(buttonHighlightTop);
			buttonHighlightTop.y = -30;
			buttonHighlight.width = 120;
			buttonHighlight.height = 30;
			buttonHighlightTop.width = 120;
			buttonHighlightTop.height = 30;
			
			// Create the mask for the highlight animation
			buttonMask = new Sprite();
			buttonMask.graphics.beginFill(0xFF0000);
			buttonMask.graphics.drawRect(0,0,120,30);
			this.addChild(buttonMask);
			buttonHighlight.mask = buttonMask;
			
			buttonMaskTop = new Sprite();
			buttonMaskTop.graphics.beginFill(0xFF0000);
			buttonMaskTop.graphics.drawRect(0,0,120,30);
			this.addChild(buttonMaskTop);
			buttonHighlightTop.mask = buttonMaskTop;
			
			// addEventListener("enterFrame",idleAnimation);
			
			// Used for hover animation; makes button lighter; has no fade for simplicity
			hoverHighlight = new Sprite();
			hoverHighlight.graphics.beginFill(0xFFFFFF);
			hoverHighlight.graphics.drawRect(0,0,120,30);
			hoverHighlight.alpha = 0;
			this.addChild(hoverHighlight);
		}
		
		function idleAnimation(e:Event):void{
			animationCounter++;
			if(isHovered) animationCounter = -30;
			if(animationCounter >= Math.random()*200 + 200){
				animationCounter = -30;
				buttonHighlight.addEventListener("enterFrame",buttonHighlight.animateHighlight);
				buttonHighlightTop.addEventListener("enterFrame",buttonHighlightTop.animateHighlight);
			}
		}
		
		function hoverAnimation(e:Event):void{
			(parent as MovieClip).addEventListener("mouseOut",hoverOff);
			/*buttonHighlight.addEventListener("enterFrame",buttonHighlight.animateHighlight);
			buttonHighlightTop.addEventListener("enterFrame",buttonHighlightTop.animateHighlight);*/
			hoverHighlight.alpha = .1;
		}
		function hoverOff(e:Event):void{
			(parent as MovieClip).removeEventListener("mouseOut",hoverOff);
			hoverHighlight.alpha = 0;
		}
	}
}