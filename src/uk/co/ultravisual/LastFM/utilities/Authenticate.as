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
	import flash.html.HTMLLoader;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;

	public class Authenticate extends EventDispatcher
	{
		public var win:HTMLLoader;
		public var isHTMLLoader:Boolean = true;

		public function authorise():void
		{
			
			var authentcateURL:URLRequest = new URLRequest(LastVars.SCOB + "?method=auth.gettoken&api_key=" + LastVars.KEY);
			var authL:URLLoader = new URLLoader(authentcateURL);
			authL.addEventListener(IOErrorEvent.IO_ERROR, authError);
			authL.addEventListener(Event.COMPLETE, authLoaded);
		}

		private function authError(e:IOErrorEvent):void
		{
			dispatchEvent(new LastEvent(LastEvent.AUTHENTICATION_FAILURE));
		}

		private function authLoaded(e:Event):void
		{
			e.currentTarget.removeEventListener(Event.COMPLETE, authLoaded);
			var authXML:XML = new XML(e.currentTarget.data);
			LastVars.TOKEN = authXML.token;
 			
			if(isHTMLLoader) {
				win = new HTMLLoader();
				win.load(new URLRequest("http://www.last.fm/api/auth/?api_key=" + LastVars.KEY + "&token=" + LastVars.TOKEN.toString()));
			} else {
				navigateToURL(new URLRequest("http://www.last.fm/api/auth/?api_key=" + LastVars.KEY + "&token=" + LastVars.TOKEN.toString()), "_blank");
			}											
			dispatchEvent(new LastEvent(LastEvent.HTML_LOADED));
		}
	}
}
