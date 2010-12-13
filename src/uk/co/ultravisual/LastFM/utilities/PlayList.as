/**
 * @author shanejohnson 
 * {@link http://www.ultravisual.co.uk}
 * created on 16 Apr 2009
 */
 
package uk.co.ultravisual.LastFM.utilities
{
	import uk.co.ultravisual.LastFM.events.LastEvent;

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	/*
	 *  test ASDoc
	 */

	public class PlayList extends Radio
	{	
		public var listXML:XML;

		public function PlayList():void
		{
		}

		public function create(title:String = "", description:String = "none"):void
		{
			LastVars.SIG = "api_key" + LastVars.KEY + "description" + description + "methodplaylist.createsk" + LastVars.Skey + "title" + title + LastVars.SECRET;
			
			var createURL:URLRequest = new URLRequest(LastVars.SCOB + "/");
			createURL.method = URLRequestMethod.POST;
 			
			var urlVariables:URLVariables = new URLVariables();
			urlVariables.title = title;
			urlVariables.description = description;
			urlVariables.method = "playlist.create";
			urlVariables.api_key = LastVars.KEY;
			urlVariables.sk = LastVars.Skey;
			urlVariables.api_sig = MD5.encrypt(LastVars.SIG);
			createURL.data = urlVariables;
			
			var createLoader:URLLoader = new URLLoader();
			createLoader.dataFormat = URLLoaderDataFormat.TEXT;
			createLoader.load(createURL);
			createLoader.addEventListener(Event.COMPLETE, playListCreated);
			createLoader.addEventListener(ProgressEvent.PROGRESS, loading);	
			createLoader.addEventListener(IOErrorEvent.IO_ERROR, error);			
		}

		private function playListCreated(e:Event):void
		{
			listXML = new XML(e.currentTarget.data);
			dispatchEvent(new LastEvent(LastEvent.PLAYLIST_CREATED));
		}

		public function getPlaylists():void
		{
			var getURL:String = LastVars.SCOB + "?method=user.getplaylists&user=ultravisual" + "&api_key=" + LastVars.KEY;
			var getList:URLLoader = new URLLoader(new URLRequest(getURL));
			getList.addEventListener(Event.COMPLETE, getListLoaded);
			getList.addEventListener(ProgressEvent.PROGRESS, loading);
			getList.addEventListener(IOErrorEvent.IO_ERROR, error);
		}

		private function getListLoaded(e:Event):XMLList
		{
			e.currentTarget.removeEventListener(Event.COMPLETE, fetchListLoaded);
			e.currentTarget.removeEventListener(ProgressEvent.PROGRESS, loading);
			e.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR, error);
 			
			var getXML:XMLList = new XMLList(e.currentTarget.data);
 			
			return getXML;
			fetch("lastfm://playlist/" + getXML.playlists.playlist.id[0]);
		}

		public function fetch(playListURL:String = ""):void
		{
			var fetchURL:String = LastVars.SCOB + "?method=playlist" + ".fetch&playlistURL=" + playListURL + "&api_key=" + LastVars.KEY;
			var fetchList:URLLoader = new URLLoader(new URLRequest(fetchURL));
			fetchList.addEventListener(Event.COMPLETE, fetchListLoaded);
			fetchList.addEventListener(ProgressEvent.PROGRESS, loading);
			fetchList.addEventListener(IOErrorEvent.IO_ERROR, error);
		}

		private function fetchListLoaded(e:Event):XML
		{
			e.currentTarget.removeEventListener(Event.COMPLETE, fetchListLoaded);
			e.currentTarget.removeEventListener(ProgressEvent.PROGRESS, loading);
			e.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR, error);
 			
			var playXML:XML = new XML(e.currentTarget.data);
 			
			return playXML;
		}

		private function loading(e:ProgressEvent):void
		{
			trace("play list loading");
		}

		private function error(e:IOErrorEvent):void
		{
			trace("PLAY LIST ERROR : " + e.currentTarget.data);
		}
	}
}
