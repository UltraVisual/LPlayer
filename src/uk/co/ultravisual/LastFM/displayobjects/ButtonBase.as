/**
 * @author ShaneJohnson
 * @link http://www.ultravisual.co.uk
 * created on 8 Sep 2009
 **/

package uk.co.ultravisual.LastFM.displayobjects 
{
	import com.greensock.TweenLite;

	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	public class ButtonBase extends MovieClip 
	{
		public var toolTip:String = "";
		private var tt:ToolTip;
		private var toolTimer:Timer = new Timer(3000, 0);
		private var isTiming:Boolean = false;

		public function ButtonBase()
		{
			this.buttonMode = true;
			this.addEventListener(MouseEvent.MOUSE_OVER, mouseOver);
		}						

		private function showToolTip(e:TimerEvent):void
		{
			isTiming = false;
			toolTimer.removeEventListener(TimerEvent.TIMER, showToolTip);
			toolTimer.stop();
			
			addToolTip();
		}

		private function mouseOver(e:MouseEvent):void
		{
			TweenLite.to(this, .5, {tint:0xffffff});
			this.removeEventListener(MouseEvent.MOUSE_OVER, mouseOver);
			this.addEventListener(MouseEvent.MOUSE_OUT, mouseOut);
			if(this.toolTip != "") {
				isTiming = true;
				toolTimer.addEventListener(TimerEvent.TIMER, showToolTip);
				toolTimer.start();
			}
		}

		private function mouseOut(e:MouseEvent):void
		{
			TweenLite.to(this, .5, {removeTint:true});
			this.addEventListener(MouseEvent.MOUSE_OVER, mouseOver);
			this.removeEventListener(MouseEvent.MOUSE_OUT, mouseOut);
			if(this.toolTip != "" && isTiming) {
				isTiming = false;
				toolTimer.removeEventListener(TimerEvent.TIMER, showToolTip);
				toolTimer.stop();
			}
			if(tt) {
				tt.fadeOut();
			}
		}

		private function addToolTip():void
		{
			tt = new ToolTip(toolTip);
			tt.x = this.x - tt.width;
			tt.y = this.y - (tt.height * 4);
			stage.addChild(tt);
			tt.fadeIn();
		}
	}
}

import com.greensock.TweenLite;

import flash.display.Sprite;
import flash.filters.DropShadowFilter;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

class ToolTip extends Sprite
{
	private var tip:Sprite;
	public var text:TextField = new TextField();
	private var shadow:DropShadowFilter = new DropShadowFilter(2, 45, 0x000000, .6, 4, 4, 1, 2);

	public function ToolTip(label:String)
	{
		var format:TextFormat = new TextFormat("Arial", 10, 0x000000);
		format.align = TextFormatAlign.CENTER;
		text.defaultTextFormat = format;
		
		text.selectable = false;
		text.text = label;
		text.multiline = true;
		text.wordWrap = true;		
		text.autoSize = TextFieldAutoSize.CENTER;
		
		tip = new Sprite();
		tip.filters = [shadow];
		tip.graphics.beginFill(0xf9f6c7);
		tip.graphics.lineStyle(0, 0, 0);
		tip.graphics.drawRect(0, 0, text.width + 4, text.height + 4);
		tip.graphics.endFill();
		
		text.x = 4;
		text.y = 4;
		
		this.alpha = 0;
	}	

	public function fadeIn():void
	{
		this.addChild(tip);
		tip.addChild(text);
		TweenLite.to(this, .2, {alpha: 1});
	}

	public function fadeOut():void
	{
		TweenLite.to(this, .2, {alpha: 0, onComplete:removeTip});
	}

	private function removeTip():void
	{
		for(var i:int = 0;i < this.numChildren;i++) {
			this.removeChildAt(i);
		}
	}
}
