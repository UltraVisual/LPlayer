/**
 * @author shanejohnson 
 * {@link http://www.ultravisual.co.uk}
 * created on 17 Apr 2009
 */
package uk.co.ultravisual.LastFM.utilities
{
	import uk.co.ultravisual.LastFM.events.LastEvent;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	public class Artist extends EventDispatcher
	{
		private var _artist:String;
		public var artistData:XML;
		public var artists:XMLList;
		public var artistImageLge:Array;
		public var artistImageSml:Array;
		public var artistName:Array;
		public var bio:String = "";

		public function Artists():void
		{
		}

		public function getSimilar(artist:String):void
		{
			_artist = artist;
		}

		public function search(artist:String):void
		{
		
			var searchString:String = LastVars.SCOB + "?method=artist.search&artist=" + artist + "&api_key=" + LastVars.KEY;
			
			var ul:URLLoader = new URLLoader();
			ul.addEventListener(Event.COMPLETE, searchLoaded);
			ul.load(new URLRequest(searchString));			
		}

		public function getInfo(artist:String):void
		{
			var infoString:String = LastVars.SCOB + "?method=artist.getinfo&artist=" + artist + "&api_key=" + LastVars.KEY;
			
			var ul:URLLoader = new URLLoader();
			ul.addEventListener(Event.COMPLETE, infoLoaded);
			ul.load(new URLRequest(infoString));
		}

		private function infoLoaded(e:Event):void
		{
			artistImageLge = [];
			artistImageSml = [];
			
			e.currentTarget.removeEventListener(Event.COMPLETE, infoLoaded);
			artistData = new XML(e.currentTarget.data);
			
			//trace(artistData);
			artistImageLge.push(artistData.artist.image[3]);
			bio = artistData.artist.bio.summary;
			
			this.dispatchEvent(new LastEvent(LastEvent.ARTIST_DATA_GOT));
		}

		private function searchLoaded(e:Event):void
		{		
			artistImageLge = [];
			artistImageSml = [];
			artistName = [];
			
			e.currentTarget.removeEventListener(Event.COMPLETE, searchLoaded);			
			artistData = new XML(e.currentTarget.data);	
			artists = new XMLList(artistData.results.artistmatches);
			
			//trace(artists);
			for(var i:int = 0;i < artists.children().length();i++) {
				if(artists.artist[i].image[3] != "") {
					artistImageLge.push(artists.artist[i].image[3]);
				}
				if(artists.artist[i].image[2] != "") {
					artistImageSml.push(artists.artist[i].image[2]);
				}
				artistName.push(artists.artist[i].name);
			}						
			this.dispatchEvent(new LastEvent(LastEvent.ARTIST_DATA_GOT));						
		}
	}
}
