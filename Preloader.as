package{
	import flash.display.MovieClip;
	public class Preloader extends MovieClip{
		static var guts:*;
		public function Preloader(){
			guts = this.getChildAt(0);
		}
	}
}