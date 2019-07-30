package{
	import flash.display.MovieClip;
	import flash.events.Event;
	
	public class ButtonHighlight extends MovieClip{
		var time:Number;
		var initialPosition:Number;
		function ButtonHighlight(initial:Number){
			time = 0;
			initialPosition = initial;
		}
		
		function animateHighlight(e:Event):void{
			time++;
			// this.y += (-actualHeight * (3*time*time - 93*time + 46)) / 13500;
			this.y += 31*time/150 - time*time/150 - 23/225;
			if(time != 15) this.alpha += .04*Math.abs(time-15)/(time-15);
			if(time >= 30){
				time = 0;
				this.y = initialPosition;
				this.alpha = 1;
				removeEventListener("enterFrame",animateHighlight);
			}
		}
	}
}