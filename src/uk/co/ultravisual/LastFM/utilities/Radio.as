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
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;

	public class Radio extends EventDispatcher
	{
		namespace ns = "http://xspf.org/ns/0/";
		use namespace ns;
		private var radioXML:XML;
		public var Artist:Array;
		public var Album:Array;
		public var Song:Array;
		public var TrackURL:Array;
		public var tracks:XMLList;
		public var playXML:XML;
		private var xmlData:XML;
		public var trackDuration:Array;

		public function tune():void
		{
			var tuneSig:Array = [];
			tuneSig.push("api_key" + LastVars.KEY);
			tuneSig.push("methodradio.tunesk" + LastVars.Skey);
			tuneSig.push("station" + LastVars.STATION + LastVars.STATION_STRING);
			
			var tuneL:URLRequest = new URLRequest(LastVars.SCOB + "/");
			tuneL.method = URLRequestMethod.POST;
 			
			var variables:URLVariables = new URLVariables();
			variables.method = "radio.tune";
			variables.station = LastVars.STATION + LastVars.STATION_STRING;
			trace("Station: " + variables.station);
			variables.api_key = LastVars.KEY;
			variables.api_sig = LastVars.createSignature(tuneSig);
			variables.sk = LastVars.Skey;
			tuneL.data = variables;
 			
			var tuneR:URLLoader = new URLLoader();
			tuneR.dataFormat = URLLoaderDataFormat.TEXT;
			tuneR.load(tuneL);
			tuneR.addEventListener(Event.COMPLETE, radioLoaded);	
			tuneR.addEventListener(IOErrorEvent.IO_ERROR, error);
		}

		public function getPlayList():void
		{	
			var getSig:Array = [];
			getSig.push("api_key" + LastVars.KEY);
			getSig.push("methodradio.getPlaylist");
			getSig.push("sk" + LastVars.Skey);
			var playURL:String = LastVars.SCOB + "?method=radio.getPlaylist" + "&api_key=" + LastVars.KEY + "&api_sig=" + LastVars.createSignature(getSig) + "&sk=" + LastVars.Skey;
			var request:URLRequest = new URLRequest(playURL); 
			request.method = URLRequestMethod.GET;
			//request.useCache = false;
			var playList:URLLoader = new URLLoader();
			playList.load(request);
			playList.addEventListener(Event.COMPLETE, playListLoaded);
			playList.addEventListener(IOErrorEvent.IO_ERROR, error);
		}

		private function playListLoaded(e:Event):void
		{
			e.currentTarget.removeEventListener(Event.COMPLETE, playListLoaded);
			e.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR, error);

			playXML = new XML(e.currentTarget.data);
			//trace(playXML);
			prepPlayList();
		}

		private function prepPlayList():XML
		{
			xmlData = new XML();
			xmlData = new XML(playXML.playlist.trackList);
			tracks = playXML.playlist.trackList.track;
			if(tracks.length() < 1) {
				getPlayList();
			} else {
				Song = [];
				TrackURL = [];
				Album = [];
				Artist = [];
				trackDuration = [];
				var i:int = 0;
				for each(var track:XML in tracks) {
					Song[i] = track.title;
					TrackURL[i] = track.location;
					Album[i] = track.album;
					Artist[i] = track.creator;
					trackDuration[i] = Number(track.duration) / 1000;
					trace(track.duration);
					++i;
				}
				
				dispatchEvent(new LastEvent(LastEvent.PLAYLIST_READY));				
			}
			return xmlData;
		}

		private function radioLoaded(e:Event):XML
		{
			e.currentTarget.removeEventListener(Event.COMPLETE, radioLoaded);
			e.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR, error);
 			
			radioXML = new XML(e.currentTarget.data);
 			
			dispatchEvent(new LastEvent(LastEvent.RADIO_TUNED));
 			
			return radioXML;
		}

		private function error(e:IOErrorEvent):void
		{
			trace("ERROR : " + e.currentTarget.data);
		}
	}
}
