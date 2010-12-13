package uk.co.ultravisual.LastFM.utilities
{
	import air.update.ApplicationUpdaterUI;
	import air.update.events.UpdateEvent;
	
	public class LPlayer_ApplicationUpdater
	{
		private static var up:ApplicationUpdaterUI;

		public static function checkForUpdate():void
		{
			up = new ApplicationUpdaterUI();
			up.updateURL = "http://ultravisual.co.uk/LPlayer/updates/update.xml";
			up.isCheckForUpdateVisible = false;
			up.addEventListener(UpdateEvent.INITIALIZED, updateInitialized);
			up.initialize();
		}

		private static function updateInitialized(e:UpdateEvent):void
		{
			up.removeEventListener(UpdateEvent.INITIALIZED, updateInitialized);
			up.checkNow();
		}
	}
}