/**
 * @author ShaneJohnson
 * @link http://www.ultravisual.co.uk
 * created on 10 Sep 2009
 **/

package uk.co.ultravisual.LastFM.utilities
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	public class User 
	{
		public function User():void
		{
		}

		public function getInfo():void
		{
			var userSig:String = "api_key" + LastVars.KEY + "methoduser.getInfosk" + LastVars.Skey + LastVars.SECRET;
			var req:URLRequest = new URLRequest(LastVars.SCOB + "/?method=user.getInfo" + "&api_key=" + LastVars.KEY + "&api_sig=" + MD5.encrypt(userSig) + "&sk=" + LastVars.Skey);
			var userLoader:URLLoader = new URLLoader(req);
			trace("loaderLoading");
			userLoader.addEventListener(Event.COMPLETE, userLoaded);
			userLoader.addEventListener(ProgressEvent.PROGRESS, loading);
			userLoader.addEventListener(IOErrorEvent.IO_ERROR, error);	
		}

		private function userLoaded(e:Event):void
		{			
			var userXML:XML = new XML(e.currentTarget.data);
			
			LastVars.USER = userXML.user.name;
		}

		private function loading(e:ProgressEvent):void
		{
			trace("userLoading");
		}

		private function error(e:IOErrorEvent):void
		{
			trace(e.currentTarget.data);
		}
	}
}
