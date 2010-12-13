package uk.co.ultravisual.LastFM.utilities
{
	import uk.co.ultravisual.LastFM.events.LastEvent;

	import flash.desktop.NativeApplication;
	import flash.desktop.SystemTrayIcon;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowDisplayState;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.events.NativeWindowDisplayStateEvent;

	public class SystemIconManager extends EventDispatcher
	{

		[Embed(source="../assets/systemTray_LPlayer.png")]
		private var DockImage:Class;
		private var dockImage:Bitmap;
		private var window:NativeWindow;

		public function SystemIconManager(app:NativeWindow):void
		{
			window = app;
			
			window.addEventListener(Event.CLOSING, closeApp);
			
			prepareForSystray();
		}

		private function closeApp(evt:Event):void 
		{
			window.close();
		}

		public function dock():void 
		{
			window.visible = false;
      		
			/*for(var i:int = NativeApplication.nativeApplication.openedWindows.length - 1; i > 0; --i){
			var minWin:NativeWindow = NativeApplication.nativeApplication.openedWindows[i] as NativeWindow;
      			
			minWin.visible = false;
			}*/
			var bmd:BitmapData = new BitmapData(dockImage.width, dockImage.height);
			bmd.draw(dockImage);
			NativeApplication.nativeApplication.icon.bitmaps = [bmd];
		}

		public function prepareForSystray():void 
		{
			dockImage = new DockImage();

			if (NativeApplication.supportsSystemTrayIcon) {
				setSystemTrayProperties();        
				SystemTrayIcon(NativeApplication.nativeApplication.icon).menu = createSystrayRootMenu();
			}
     		else if(NativeApplication.supportsDockIcon) {
     			//you have a mac?
			}
		}

		private function createSystrayRootMenu():NativeMenu
		{
			var menu:NativeMenu = new NativeMenu();
			var openNativeMenuItem:NativeMenuItem = new NativeMenuItem("Open");
			var exitNativeMenuItem:NativeMenuItem = new NativeMenuItem("Exit");
			var stopNativeMenuItem:NativeMenuItem = new NativeMenuItem("Stop");
			var nextNativeMenuItem:NativeMenuItem = new NativeMenuItem("Next");
      		
			openNativeMenuItem.addEventListener(Event.SELECT, undock);
			exitNativeMenuItem.addEventListener(Event.SELECT, closeApp);
			stopNativeMenuItem.addEventListener(Event.SELECT, stopMusic);
			nextNativeMenuItem.addEventListener(Event.SELECT, nextSong);
     		
			menu.addItem(openNativeMenuItem);
			menu.addItem(new NativeMenuItem("", true));
			//separator 
			menu.addItem(exitNativeMenuItem);
			menu.addItem(new NativeMenuItem("", true));
			menu.addItem(stopNativeMenuItem);
			menu.addItem(new NativeMenuItem("", true));
			menu.addItem(nextNativeMenuItem);
      		
			return menu;
		}

		private function stopMusic(e:Event):void
		{
			dispatchEvent(new LastEvent(LastEvent.STOP_MUSIC_PLEASE));
		}

		private function nextSong(e:Event):void
		{
			dispatchEvent(new LastEvent(LastEvent.NEXT_TUNE_PLEASE));
		}

		private function setSystemTrayProperties():void
		{
			SystemTrayIcon(NativeApplication.nativeApplication .icon).tooltip = "lPlayer";
      		
			SystemTrayIcon(NativeApplication.nativeApplication .icon).addEventListener(MouseEvent.CLICK, undock);
      		
			window.addEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGING, nwMinimized);
		}

		private function nwMinimized(displayStateEvent:NativeWindowDisplayStateEvent):void 
		{
			if(displayStateEvent.afterDisplayState == NativeWindowDisplayState.MINIMIZED) { 
				displayStateEvent.preventDefault();
				dock();
			}
		}

		public function undock(evt:Event):void 
		{
			window.visible = true;
			window.orderToFront();

			NativeApplication.nativeApplication .icon.bitmaps = [];
		}
	}
}
