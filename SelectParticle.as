package{
	import flash.display.MovieClip;
	import flash.events.Event;
	
	public class SelectParticle extends MovieClip{
		var xVelo:Number;
		var yVelo:Number;
		var speed:Number;
		var xDeviation:Number;
		var yDeviation:Number;
		
		function SelectParticle(){
			speed = 3.5;
			xVelo = speed;
			yVelo = 0;
			xDeviation = 0;
			yDeviation = 0;
			addEventListener("enterFrame",moveParticle);
			addEventListener("enterFrame",addAlpha);
		}
		
		/** Moves the particle in a square, stopping it at checkpoints to flip direction.
		    Also includes random deviation at the end. */
		function moveParticle(e:Event):void{
			if(this.x >= 47 && xVelo > 0){
				this.x = 47;
				xDeviation = 0;
				xVelo = 0;
				yVelo = speed;
			}
			if(this.y >= 47 && yVelo > 0){
				this.y = 47;
				yDeviation = 0;
				xVelo = -speed;
				yVelo = 0;
			}
			if(this.x <= -3 && xVelo < 0){
				this.x = -3;
				xDeviation = 0;
				xVelo = 0;
				yVelo = -speed;
			}
			if(this.y <= -3 && yVelo < 0){
				this.y = -3;
				yDeviation = 0;
				xVelo = speed;
				yVelo = 0;
			}
			this.x += xVelo;
			this.y += yVelo;
			
			/* Deviation Algorithm; Particles randomly move around from their parent position,
			   but by no more than 2 pixels in any direction.  Subtle, but effective. */
			if(Math.random() > .5){
				var temp = Math.floor(Math.random()*3-1);
				// Select direction
				if(Math.random() > .5){
					if(xDeviation + temp > 2 || xDeviation + temp < -2) temp = -temp;
					xDeviation += temp;
					this.x += temp;
				}
				else{
					if(yDeviation + temp > 2 || yDeviation + temp < -2) temp = -temp;
					yDeviation += temp;
					this.y += temp;
				}
			}
		}
		
		// Makes less transparent
		function addAlpha(e:Event):void{
			this.alpha += .05;
			if(this.alpha >= 1) removeEventListener("enterFrame",addAlpha);
		}
		
		/** Makes transparent, then removes all listeners from itself.
		    After that, it tells its parent to remove it. */
		function removeAlpha(e:Event):void{
			this.alpha -= .1;
			if(this.alpha <= 0){
				removeEventListener("enterFrame",moveParticle);
				removeEventListener("enterFrame",removeAlpha);
				parent.removeChild(this);
			}
		}
	}
}