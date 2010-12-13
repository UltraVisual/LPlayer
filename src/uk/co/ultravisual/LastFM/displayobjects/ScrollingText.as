/**
 * @author ShaneJohnson
 * @link http://www.ultravisual.co.uk
 * created on 11 Sep 2009
 **/

package  uk.co.ultravisual.LastFM.displayobjects
{
	import flash.display.MovieClip;
	import flash.text.TextFieldAutoSize;

	public class ScrollingText extends MovieClip 
	{	
		public function ScrollingText()
		{
			this["infoText"].autoSize = TextFieldAutoSize.LEFT;
		}
	}
}
