/**
 * @author shanejohnson 
 * {@link http://www.ultravisual.co.uk}
 * created on 16 Apr 2009
 */
 
package uk.co.ultravisual.LastFM.utilities
{

	public class LastVars 
	{
		public static const SCOB:String = "http://ws.audioscrobbler.com/2.0/";
		public static const SECRET:String = "4966631d278e89d35c44f74a7d2be16c"; // API secret
		public static const KEY:String = "d8bacab462323995ebadb7edfb40d293"; //API Key
		public static var STATION:String = "lastfm://";
		public static var STATION_STRING:String = "";
		public static var Skey:String = ""; // sk
		public static var TOKEN:String = "";
		public static var SIG:String = "";
		public static var PLAYLIST_URL:String = "";
		public static var PLAYLIST_ID:String = "";
		public static var CURRENT_ARTIST:String = "";
		public static var CURRENT_TRACK:String = "";
		public static var CURRENT_TRACK_INFO:String = "";
		public static var USER:String = "";

		public static function createSignature(variables:Array):String
		{
			variables.sort();
			var string:String = variables.toString() + LastVars.SECRET;
			var pattern:RegExp = /,/;  
			for (var i:uint = 0;i < variables.length;i++) { 
				string = string.replace(pattern, "");
			}
			return MD5.encrypt(string);		
		}
	}
}
