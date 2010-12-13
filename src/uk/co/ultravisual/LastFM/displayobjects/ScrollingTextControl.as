/**
 * @author ShaneJohnson
 * @link http://www.ultravisual.co.uk
 * created on 11 Sep 2009
 **/

package uk.co.ultravisual.LastFM.displayobjects   
{
	import com.greensock.TweenLite;

	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	public class ScrollingTextControl extends MovieClip 
	{
		public var aSprite:Sprite;
		public var bSprite:Sprite;
		private var flashText:Sprite;
		private var delay:int = 0;
		private var delayTarget:int = 10;
		private var gap:int = 20;
		private var flashTimer:Timer;

		public function ScrollingTextControl()
		{
			aSprite = new ScrollingText();
			addChild(aSprite);
			bSprite = new ScrollingText();
			addChild(bSprite);
		}

		public function scrollText():void
		{	
			if(delay < delayTarget) {
				delay += 1;	
			} else {
				loop();
			}
		}

		public function flash(text:String):void
		{
			flashText = new ScrollingText();
			flashText["infoText"].text = text;
			flashText.alpha = 0;
			
			addChild(flashText);
			
			flashTimer = new Timer(3000, 0);
			flashTimer.addEventListener(TimerEvent.TIMER, flashTimerEnd);
			flashTimer.start();
			
			TweenLite.to(flashText, .4, {alpha: 1});
			TweenLite.to(aSprite, .4, {alpha: 0});
			TweenLite.to(bSprite, .4, {alpha: 0});
		}

		private function flashTimerEnd(e:TimerEvent):void
		{
			flashTimer.removeEventListener(TimerEvent.TIMER, flashTimerEnd);
			flashTimer.stop();
			
			TweenLite.to(flashText, .4, {alpha: 0});
			TweenLite.to(aSprite, .4, {alpha: 1});
			TweenLite.to(bSprite, .4, {alpha: 1, onComplete: removeFlashText});
		}		

		private function removeFlashText():void
		{
			removeChild(flashText);
		}

		private function loop():void
		{
			aSprite.x -= 1;
			bSprite.x -= 1;
			
			if(aSprite.x < 0 - aSprite.width) {
				aSprite.x = bSprite.x + bSprite.width + gap;
			}
			if(bSprite.x < 0 - bSprite.width) {
				bSprite.x = aSprite.x + aSprite.width + gap;
			}
		}

		public function removeScroll():void
		{
			aSprite["infoText"].text = "";
			bSprite["infoText"].text = "";
		}

		public function resetPositions():void
		{
			delay = 0;
			aSprite.x = 0;
			bSprite.x = aSprite.x + aSprite.width;
		}
	}
}
