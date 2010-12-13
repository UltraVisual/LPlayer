/**
 * @author ShaneJohnson
 * @link http://www.ultravisual.co.uk
 * created on 12 Sep 2009
 **/

package uk.co.ultravisual.LastFM.utilities 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;

	public class Track extends EventDispatcher 
	{
		public function Track(target:IEventDispatcher = null)
		{
			super(target);
		}

		public function love(artist:String, track:String):void
		{			
			var sigVars:Array = [];
			sigVars.push("api_key" + LastVars.KEY);
			sigVars.push("methodtrack.love"); 
			sigVars.push("artist" + artist); 
			sigVars.push("sk" + LastVars.Skey); 
			sigVars.push("track" + track);
			
			sendVariables(sigVars, "love", track, artist);	
		}

		private function sendVariables(data:Array, type:String, track:String, artist:String):void
		{
			var trackL:URLRequest = new URLRequest("http://ws.audioscrobbler.com/2.0/");
			trackL.method = URLRequestMethod.POST;
 			
			var variables:URLVariables = new URLVariables();
			variables.method = "track." + type;
			variables.track = track;
			variables.artist = artist;
			variables.api_key = LastVars.KEY;
			variables.api_sig = LastVars.createSignature(data);
			variables.sk = LastVars.Skey;
			trackL.data = variables;
 			
			var libLoader:URLLoader = new URLLoader();
			libLoader.dataFormat = URLLoaderDataFormat.TEXT;
			libLoader.load(trackL);
			libLoader.addEventListener(Event.COMPLETE, userLoaded);
			libLoader.addEventListener(ProgressEvent.PROGRESS, loading);
			libLoader.addEventListener(IOErrorEvent.IO_ERROR, error);
		}

		public function ban(artist:String, track:String):void
		{
			var sigVars:Array = [];
			sigVars.push("api_key" + LastVars.KEY);
			sigVars.push("methodtrack.ban"); 
			sigVars.push("artist" + artist); 
			sigVars.push("sk" + LastVars.Skey); 
			sigVars.push("track" + track);
			
			sendVariables(sigVars, "ban", track, artist);
		}

		private function userLoaded(e:Event):void
		{
			trace(e.currentTarget.data);
		}

		private function loading(e:ProgressEvent):void
		{
			trace("libLoading");
		}

		private function error(e:IOErrorEvent):void
		{
			trace("Error: " + e.currentTarget.data);
		}
	}
}
