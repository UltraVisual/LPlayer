/**
 * @author shanejohnson 
 * {@link http://www.ultravisual.co.uk}
 * created on 16 Apr 2009
 */
package uk.co.ultravisual.LastFM.utilities 
{
	import uk.co.ultravisual.LastFM.events.LastEvent;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	public class GetSession extends EventDispatcher
	{
		private var sessionAttempts:int = 0;
		private var sessionAttemptsLimit:int = 200;

		public function GetSession():void
		{
			getSession();
		}

		private function getSession():void
		{
			try {
				var sessSig:String = "api_key" + LastVars.KEY + "methodauth.getSessiontoken" + LastVars.TOKEN + LastVars.SECRET;
				trace("getting session");
				var l:URLLoader = new URLLoader(new URLRequest(LastVars.SCOB + "/?method=auth.getSession" + "&token=" + LastVars.TOKEN + "&api_key=" + LastVars.KEY + "&api_sig=" + MD5.encrypt(sessSig)));
				l.addEventListener(Event.COMPLETE, sessLoaded);
				l.addEventListener(IOErrorEvent.IO_ERROR, error);
			}
			catch(error:Error) {
			}
		}

		private function sessLoaded(e:Event):void
		{
			e.currentTarget.removeEventListener(Event.COMPLETE, sessLoaded);
			e.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR, error);
			var sessXML:XML = new XML(e.currentTarget.data);
			LastVars.Skey = sessXML.session.key;
			dispatchEvent(new LastEvent(LastEvent.SESSION_GOT));
		}

		private function error(e:IOErrorEvent):void
		{
			e.currentTarget.removeEventListener(Event.COMPLETE, sessLoaded);
			e.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR, error);
	 		
			sessionAttempts += 1;
			if(sessionAttempts > sessionAttemptsLimit) {
				sessionAttempts = 0;
				dispatchEvent(new LastEvent(LastEvent.SESSION_FAILURE));
			} else {
				getSession();
			}
		}
	}
}
