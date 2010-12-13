/**
 * @author ShaneJohnson
 * @link http://www.ultravisual.co.uk
 * created on 11 Sep 2009
 **/

package uk.co.ultravisual.LastFM.displayobjects
{
	import uk.co.ultravisual.LastFM.events.LastEvent;

	import com.greensock.TweenLite;

	import flash.display.MovieClip;
	import flash.events.MouseEvent;

	public class VolumeControl extends MovieClip 
	{
		public var volume:Number = 1;

		public function VolumeControl()
		{
			this["volumeBar"].mask = this["volumeMask"];
			this["hit"].addEventListener(MouseEvent.MOUSE_OVER, overVolume);
		}

		private function overVolume(e:MouseEvent):void
		{
			TweenLite.to(this["volumeBar"], .5, {tint:0xffffff});
			this["hit"].addEventListener(MouseEvent.MOUSE_DOWN, changeVolume);
			this["hit"].addEventListener(MouseEvent.MOUSE_OUT, mouseOff);
			this["hit"].removeEventListener(MouseEvent.MOUSE_OVER, overVolume);
		}

		private function changeVolume(e:MouseEvent):void
		{
			this["hit"].removeEventListener(MouseEvent.MOUSE_DOWN, changeVolume);
			this["hit"].addEventListener(MouseEvent.MOUSE_UP, mouseOff);
			this["hit"].addEventListener(MouseEvent.MOUSE_MOVE, changeValue);
		}

		private function mouseOff(e:MouseEvent):void
		{
			TweenLite.to(this["volumeBar"], .5, {removeTint:true});
			this["hit"].addEventListener(MouseEvent.MOUSE_OVER, overVolume);
			this["hit"].removeEventListener(MouseEvent.MOUSE_UP, mouseOff);
			this["hit"].removeEventListener(MouseEvent.MOUSE_OUT, mouseOff);
			this["hit"].removeEventListener(MouseEvent.MOUSE_MOVE, changeValue);
		}

		private function changeValue(e:MouseEvent):void
		{
			this["volumeBar"].y = mouseY;
			volume = 1 - (this["volumeBar"].y / 30);
			if(volume < 0) {
				volume = 0;
			}
			if(volume > 1) {
				volume = 1;
			}
			this.dispatchEvent(new LastEvent(LastEvent.VOLUME_CHANGE));
		}
	}
}
