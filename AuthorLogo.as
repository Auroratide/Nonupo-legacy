package{
	import flash.display.MovieClip;
	import flash.geom.Matrix;
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.globalization.NumberParseResult;
	
	/** This is the logo screen.  To use, import the following files to your library:
		  1: logo_aurora
		  2: logo_name
		  3: logo_ardeol
		  4: logo_subtitle
		  5: auroraFull.png
		Paste the following scripts:
		  1: AuthorAurora
		  2: AuthorLogo
		Uncomment the last line of code (!)
		Create a function, logoIsDone() in the parent instance
		*/

	public class AuthorLogo extends MovieClip{
		var aurora:AuthorAurora;
		var alphaChannel:Sprite;
		var alphaMatrix:Matrix;
		var colors:Array;
		var alphas:Array;
		var limits:Array;
		var directions:Vector.<Number>;
		var speeds:Vector.<Number>;
		var trueFrameRate:int;
		var delay:Number;
		var introSound:AuthorSound;
		function AuthorLogo(){
			// The ratio is 1.098901:1
			/* */
			this.width = 550;
			this.height = 400;
			/* */
			
			introSound = new AuthorSound();
			
			//trueFrameRate = stage.frameRate;
			//stage.frameRate = 24; // Controls framerate; returns it later
			delay = 0;
			this.alpha = 0;
			aurora = new AuthorAurora();
			aurora.y = 100;
			this.addChild(aurora);
			// Each array has 17 slots
			colors = [0x000000,0x000000,0x000000,0x000000,0x000000,0x000000,0x000000,0x000000,0x000000,0x000000,0x000000,0x000000,0x000000,0x000000,0x000000,0x000000,0x000000];
			alphas = [       0,      .5,      .9,      .5,      .2,      .5,      .9,      .5,      .2,      .5,      .9,      .5,      .2,      .5,      .9,      .5,       0];
			limits = [       0,      41,      51,      61,      77,      92,     102,     112,     128,     143,     153,     163,     179,     194,     204,     214,     255];
			// Each element in directions matches with one of the main branches (ie. alpha = 1)
			directions = Vector.<Number>([-.5, .5, -.5, .5]);
			speeds = Vector.<Number>([0, 0, 0, 0]);
			alphaChannel = new Sprite();
			alphaMatrix = new Matrix();
			alphaMatrix.createGradientBox(1000, 1000, Math.PI/13);
			alphaChannel.graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, limits, alphaMatrix);
			alphaChannel.graphics.drawRect(0,0,1000,1000);
			alphaChannel.graphics.endFill();
			this.addChild(alphaChannel);
			aurora.cacheAsBitmap = true;
			alphaChannel.cacheAsBitmap = true;
			aurora.mask = alphaChannel;
			this.addEventListener(Event.ENTER_FRAME, sparkleAurora);
			this.addEventListener(Event.ENTER_FRAME, fadeIn);
		}
		
		/*  Controls four independent spires.
			Each spire has a speed and direction which change semi-randomly.  This in turn affects
			a subspire on each side of the main spire.
			*/
		function sparkleAurora(e:Event):void{
			for(var i=0; i < 4; i++){
				if(Math.random() > .75) directions[i] *= -1;
				speeds[i] += directions[i];
				if(speeds[i] > 3){
					speeds[i] = 2;
					directions[i] = -.5;
				}
				else if(speeds[i] < -3){
					speeds[i] = -2;
					directions[i] = .5;
				}
				limits[4*i+2] += speeds[i];
				if(limits[4*i+2] > 51*(i+1)+14){
					limits[4*i+2] = 51*(i+1)+14;
					directions[i] = -1;
				}
				else if(limits[4*i+2] < 51*(i+1)-14){
					limits[4*i+2] = 51*(i+1)-14;
					directions[i] = 1;
				}
				limits[4*i+1] = limits[4*i+2] - leftLimit(limits[4*i+2] - 51*i);
				limits[4*i+3] = limits[4*i+2] + rightLimit(limits[4*i+2] - 51*i);
			}
			for(var j=1; j < 4; j++){
				limits[4*j] = (limits[4*j-1] + limits[4*j+1])/2;
				alphas[4*j] = .3+3*Math.abs(limits[4*j]-51*(j-1)-77)/77;
			}
			alphaChannel.graphics.clear();
			alphaChannel.graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, limits, alphaMatrix);
			alphaChannel.graphics.drawRect(0,0,1000,1000);
			alphaChannel.graphics.endFill();
			aurora.mask = alphaChannel;
		}
		
		/*  The following math functions cause the spacing on the subspires to differ depending on
			where the main spire is.  The function is a bell-curve added to an exponential expression.
			*/
		function leftLimit(lim:Number):Number{
			return 7*Math.pow(Math.E, -(Math.pow(lim-51, 2)/200)) + Math.pow(10/9, lim-39);
		}
		function rightLimit(lim:Number):Number{
			return 7*Math.pow(Math.E, -(Math.pow(lim-51, 2)/200)) + Math.pow(10/9, 63-lim);
		}
		
		function fadeIn(e:Event):void{
			this.alpha += .025;
			if(this.alpha >= .5 && this.alpha < .525) introSound.play();
			if(this.alpha >= 1){
				this.alpha = 1;
				removeEventListener(Event.ENTER_FRAME, fadeIn);
				addEventListener(Event.ENTER_FRAME, fadeOut);
			}
		}
		function fadeOut(e:Event):void{
			delay++;
			if(delay >= 120){
				this.alpha -= 0.025;
				if(this.alpha <= 0){
					this.alpha = 0;
					removeEventListener(Event.ENTER_FRAME, fadeOut);
					//stage.frameRate = trueFrameRate;
					//Document.logoIsDone();
					(parent as MovieClip).playTitleMovie();
				}
			}
		}
	}
}