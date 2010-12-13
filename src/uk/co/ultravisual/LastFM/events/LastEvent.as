/**
 * @author shanejohnson 
 * {@link http://www.ultravisual.co.uk}
 * created on 16 Apr 2009
 */
package uk.co.ultravisual.LastFM.events
{
	import flash.events.Event;

	public class LastEvent extends Event 
	{
		public static const RADIO_TUNED:String = "radioTuned";		
		public static const PLAYLIST_READY:String = "playListReady";
		public static const PLAYLIST_CREATED:String = "playListCreated";		
		public static const SESSION_GOT:String = "sessionGot";
		public static const AUTHENTICATION_FAILURE:String = "authenticationFailure";
		public static const SESSION_FAILURE:String = "sessionFailure";
		public static const DATA_SENT:String = "dataSent";
		public static const HTML_LOADED:String = "htmlLoaded";
		public static const ARTIST_DATA_GOT:String = "artistDataGot";
		public static const NEXT_TUNE_PLEASE:String = "nextTunePlease";
		public static const STOP_MUSIC_PLEASE:String = "stopMusicPlease";
		public static const VOLUME_CHANGE:String = "volumeChange";

		public function LastEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
		}

		public override function clone():Event
		{
			return new LastEvent(type, bubbles, cancelable);
		}

		public override function toString():String
		{
			return formatToString("LastEvent", "type", "bubbles", "cancelable", "eventPhase");
		}
	}
}
