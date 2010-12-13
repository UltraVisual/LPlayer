/**
 * @author ShaneJohnson
 * @link http://www.ultravisual.co.uk
 * created on 10 Sep 2009
 **/

package uk.co.ultravisual.LastFM.displayobjects
{
	import flash.display.MovieClip;

	//import flash.display.Sprite;
	public class ProgressBar extends MovieClip 
	{
		private var targetWidth:Number = 258;
		
		public function ProgressBar()
		{
			resetBar();
			
			/*a.x = 20;
			a.y = 50;
			this.addChild(a);
			
			b.x = 20;
			b.y = 100;
			this.addChild(b);*/
		}

		public function  setProgress(currentPos:Number, finalPos:Number):void
		{
			targetWidth = 258;
			
			var curWidth:Number = (targetWidth / finalPos) * currentPos;
			if(curWidth > targetWidth) {
				curWidth = targetWidth;
			}			
			this["bar"].width = curWidth;
			
			/*trace(((100 / finalPos) * curWidth).toFixed(2) + "% of progressBar done");
			
			a.graphics.clear();;
			a.graphics.lineStyle(0, 0, 0);
			a.graphics.beginFill(0xaa2db5);
			a.graphics.drawRect(0, 0, targetWidth, 2);
			a.graphics.endFill();
			
			b.graphics.clear();;
			b.graphics.lineStyle(0, 0, 0);
			b.graphics.beginFill(0xaa2db5);
			b.graphics.drawRect(0, 0, curWidth, 4);
			b.graphics.endFill();*/
		}

		public function resetBar():void
		{
			this["bar"].width = 0;
		}
	}
}
