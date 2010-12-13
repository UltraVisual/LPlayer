
/**
 * @author shanejohnson 
 * {@link http://www.ultravisual.co.uk}
 * created on 14 Apr 2009
 */
 
package
{
	import flash.display.StageScaleMode;
	import flash.events.KeyboardEvent;
	import flash.events.FocusEvent;
	import uk.co.ultravisual.LastFM.displayobjects.ArtistInfoDisplay;
	import uk.co.ultravisual.LastFM.displayobjects.ArtistSearchItemHolder;
	import uk.co.ultravisual.LastFM.events.LastEvent;
	import uk.co.ultravisual.LastFM.utilities.Artist;
	import uk.co.ultravisual.LastFM.utilities.Authenticate;
	import uk.co.ultravisual.LastFM.utilities.GetSession;
	import uk.co.ultravisual.LastFM.utilities.LPlayer_ApplicationUpdater;
	import uk.co.ultravisual.LastFM.utilities.LastVars;
	import uk.co.ultravisual.LastFM.utilities.Radio;
	import uk.co.ultravisual.LastFM.utilities.SystemIconManager;
	import uk.co.ultravisual.LastFM.utilities.Track;
	import uk.co.ultravisual.LastFM.utilities.User;

	import com.greensock.TweenLite;

	import flash.data.EncryptedLocalStore;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.html.HTMLLoader;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.utils.ByteArray;
	import flash.utils.Timer;

	public class LPlayerMain extends MovieClip
	{		
		private var music : Sound;
		private var sc : SoundChannel = new SoundChannel();
		private var tuneIndex : int = 0;
		private var url : URLRequest;		
		private var radio : Radio = new Radio();
		private var loading : Boolean = false;
		private var menu : ContextMenu = new ContextMenu();
		private var auth : Authenticate;
		private var backY : Number = 0;
		private var a : Artist = new Artist();
		private var hl : HTMLLoader;
		private var sysMan : SystemIconManager;
		private var holder : Sprite;
		private var startTime : Number;
		private var endTimeSeconds : Number = 0;
		private var endTime : String;
		private var trackTimer : Timer = new Timer(20, 0);
		private var currentTime : Number = 0;
		private var timerTime : Number = 0;
		private var minutes : Number = 0;
		private var seconds : Number = 0;
		private var vol : Number = 1;
		private var st : SoundTransform = new SoundTransform(vol);

		
		public function LPlayerMain() : void
		{
			LPlayer_ApplicationUpdater.checkForUpdate();
			this.addEventListener(Event.ADDED_TO_STAGE, added);
		}

		private function added(e : Event) : void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, added);
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			sysMan = new SystemIconManager(this.stage.nativeWindow);
			this["backGround"].addEventListener(MouseEvent.MOUSE_DOWN, dragWindow);
			
			menu.customItems.push(new ContextMenuItem("Close"));
			menu.customItems.push(new ContextMenuItem("Minimize"));
			menu.addEventListener(Event.SELECT, menuSelect);
			this["backGround"].contextMenu = menu;
			
			authenticate();
		}

		private function authenticate() : void
		{
			if(!checkForLocalData()) {
				try {
					this["infoText"].aSprite["infoText"].text = "Connecting to Last.fm..........";
					
					auth = new Authenticate();
					auth.addEventListener(LastEvent.HTML_LOADED, addLogIn);
					auth.addEventListener(LastEvent.AUTHENTICATION_FAILURE, authFailure);
					auth.authorise();
					
				
					var getSess : GetSession = new GetSession();
					getSess.addEventListener(LastEvent.SESSION_GOT, session);
					getSess.addEventListener(LastEvent.SESSION_FAILURE, sessionFail);					
				}
				catch(error : Error) {
					this["infoText"].aSprite["infoText"].text = "Error connecting to Last.fm..........";
				}
			} else {				
				addInitialListeners();	
				this["infoText"].aSprite["infoText"].text = "Connected.";		
			}
			this["bottomBar"].barBack.height = 513.5;
			this["bottomBar"].barBack.y = -500;
			backY = 513.5;
			this["volumeControl"].addEventListener(LastEvent.VOLUME_CHANGE, changeVolume);
		}

		private function authFailure(e : LastEvent) : void
		{
			this["infoText"].aSprite["infoText"].text = "Unable to connect.";
		}

		private function checkForLocalData() : Boolean
		{
			var skPresent : Boolean;
			try {
				var a : ByteArray = EncryptedLocalStore.getItem("serialKey");
				LastVars.Skey = a.readUTFBytes(a.length);				
				skPresent = true;
			}
			catch(error : Error) {
				skPresent = false;
			}
			return skPresent;
		}

		private function saveToLocalData() : void
		{
			var b : ByteArray = new ByteArray();
			b.writeUTFBytes(LastVars.Skey);
			EncryptedLocalStore.setItem("serialKey", b);
		}

		private function searchFocus(event : FocusEvent) : void
		{
			trace("focus");
			stage.addEventListener(KeyboardEvent.KEY_UP, keyDownForSearch);
		}

		private function keyDownForSearch(event : KeyboardEvent) : void
		{
			if(event.keyCode == 13){
				stage.removeEventListener(KeyboardEvent.KEY_UP, keyDownForSearch);
				searchForArtist(null);
			}
		}

		private function textNoFocus(event : FocusEvent) : void
		{
			trace("no focus");
			stage.removeEventListener(KeyboardEvent.KEY_UP, keyDownForSearch);
		}

		private function sessionFail(e : LastEvent) : void
		{
			this["infoText"].aSprite["infoText"].text = "Error connecting........trying again.";
			e.currentTarget.removeEventListener(LastEvent.SESSION_FAILURE, sessionFail);
			closeBottom();
			authenticate();
		}

		private function changeVolume(e : LastEvent) : void
		{
			vol = this["volumeControl"].volume;
			st.volume = vol;
			sc.soundTransform = st;
		}

		private function session(e : LastEvent) : void
		{	
			e.currentTarget.removeEventListener(LastEvent.SESSION_GOT, session);
			this["infoText"].aSprite["infoText"].text = "Connected.";
			addInitialListeners();
			closeBottom();
			tweenOut(hl);
			saveToLocalData();
		}

		private function addInitialListeners() : void
		{	
			var user : User = new User();
			user.getInfo();		
			this["searchBtn"].addEventListener(MouseEvent.CLICK, searchForArtist);
			this["logoBtn"].addEventListener(MouseEvent.CLICK, usersLibraryRadio);	
			
			TextField(this["textArea"]).addEventListener(FocusEvent.FOCUS_IN, searchFocus);
			TextField(this["textArea"]).addEventListener(FocusEvent.FOCUS_OUT, textNoFocus);	
		}

		private function searchForArtist(e : MouseEvent) : void
		{
			if(this["textArea"].text != "") {
				LastVars.CURRENT_ARTIST = this["textArea"].text;
				a.search(LastVars.CURRENT_ARTIST);				
				a.addEventListener(LastEvent.ARTIST_DATA_GOT, searchComplete);
			}
		}

		private function removeChildAtTwo() : void
		{
			try {
				if(this["bottomBar"].numChildren > 2) {
					this["bottomBar"].removeChildAt(2);
				}
			}
			catch(error : Error) {
			}
		}

		private function searchComplete(e : LastEvent) : void
		{
			removeChildAtTwo();			
			e.currentTarget.removeEventListener(LastEvent.ARTIST_DATA_GOT, searchComplete);
			var yPos : Number;
			var xPos : Number = 40;
			var backHeight : Number;
			if(a.artistImageSml.length <= 3) {
				backHeight = 163.5;
			} else {
				backHeight = 313.5;
			}
			this["bottomBar"].barBack.height = backHeight;
			this["bottomBar"].barBack.y = -(backHeight - 13.5);
			backY = backHeight;
			yPos = (-backHeight) + 50;
			var imagesLength : int = a.artistImageSml.length;
			if(imagesLength > 6) {
				imagesLength = 6;
			}
			holder = new Sprite();
			this["bottomBar"].addChildAt(holder, 2);
			for(var i : int = 0;i < imagesLength;i++) {
				try {
					var l : Loader = new Loader();
					l.load(new URLRequest(a.artistImageSml[i]));
					var ah : ArtistSearchItemHolder = new ArtistSearchItemHolder();
					ah["artistInfo"].htmlText = a.artistName[i];
					ah.y = yPos;
					ah.x = xPos;
					l.x = 10;
					l.y = 10;					
					ah.addChildAt(l, 1);
					l.mask = ah["imageMask"];
					holder.addChild(ah);					
					xPos += 250;
					
					if(xPos > 541) {
						yPos += 125;
						xPos = 40;
					}
					ah.addEventListener(MouseEvent.CLICK, selectArtist);
					ah.name = i.toString();
				}
				catch(error : Error) {
					trace("error loading image");
				}
				openBottom();
			}
		}		

		private function selectArtist(e : MouseEvent) : void
		{
			closeBottom();
			LastVars.CURRENT_ARTIST = a.artistName[parseInt(e.currentTarget.name)];
			playArtist();			
			tweenOut(holder);
		}

		private function tweenOut(object : DisplayObject) : void
		{
			var params : Array = [];
			params.push(object);
			
			TweenLite.to(object, 1, {alpha: 0, onComplete: removeObject, onCompleteParams: params});
		}

		private function removeObject(object : DisplayObject) : void
		{
			try {
				object.parent.removeChild(object);
			}
			catch(error : Error) {
				//nothing
			}
		}

		private function addLogIn(e : LastEvent) : void
		{
			auth.removeEventListener(LastEvent.HTML_LOADED, addLogIn);
			hl = auth.win;
			hl.y = -475;
			hl.x = 25;
			hl.width = 750;
			hl.height = 450;
			this["bottomBar"].addChildAt(hl, 2);
			
			openBottom();
		}

		private function openBottom() : void
		{
			this["bottomBar"].bar.addEventListener(MouseEvent.CLICK, bottomBack);
			TweenLite.to(this["bottomBar"], 1, {y: backY + 25});
		}

		private function closeBottom() : void
		{
			TweenLite.to(this["bottomBar"], 1, {y: 31});
			this["bottomBar"].bar.removeEventListener(MouseEvent.CLICK, bottomBack);
			this["bottomBar"].bar.addEventListener(MouseEvent.CLICK, bottomClicked);
		}

		private function bottomClicked(e : Event) : void
		{
			TweenLite.to(this["bottomBar"], 1, {y: backY + 25});
			this["bottomBar"].bar.removeEventListener(MouseEvent.CLICK, bottomClicked);
			this["bottomBar"].bar.addEventListener(MouseEvent.CLICK, bottomBack);
		}

		private function bottomBack(e : Event) : void
		{
			TweenLite.to(this["bottomBar"], 1, {y: 31});
			this["bottomBar"].bar.addEventListener(MouseEvent.CLICK, bottomClicked);
			this["bottomBar"].bar.removeEventListener(MouseEvent.CLICK, bottomBack);
		}

		private function menuSelect(e : Event) : void
		{
			switch(e.target.label) {
				case "Close":
					this.stage.nativeWindow.close();
					break;
				case "Minimize":
					sysMan.dock();
					break;
			}
		}

		private function dragWindow(e : MouseEvent) : void
		{
			addEventListener(MouseEvent.MOUSE_MOVE, moveWindow);
			this["backGround"].removeEventListener(MouseEvent.MOUSE_DOWN, dragWindow);
			addEventListener(MouseEvent.MOUSE_UP, dragStop);
		}	

		private function dragStop(e : MouseEvent) : void
		{
			removeEventListener(MouseEvent.MOUSE_MOVE, moveWindow);
			this["backGround"].addEventListener(MouseEvent.MOUSE_DOWN, dragWindow);
			removeEventListener(MouseEvent.MOUSE_UP, dragStop);
		}

		private function moveWindow(e : MouseEvent) : void
		{
			this.stage.nativeWindow.startMove();
		}

		private function playArtist() : void
		{
			LastVars.STATION_STRING = "artist/" + LastVars.CURRENT_ARTIST + "/similarartists";				
			tuneradio();
		}		

		private function getArtistInfo() : void
		{
			a.getInfo(LastVars.CURRENT_ARTIST);
			a.addEventListener(LastEvent.ARTIST_DATA_GOT, infoLoaded);			
		}		

		private function infoLoaded(e : LastEvent) : void
		{
			removeChildAtTwo();
			
			a.removeEventListener(LastEvent.ARTIST_DATA_GOT, infoLoaded);	
			
			var ai : ArtistInfoDisplay = new ArtistInfoDisplay();
			ai.x = 20;
			ai.y = 34;
			holder = new Sprite();
			holder.y = -300;
			backY = 300;
			this["bottomBar"].addChildAt(holder, 2);
			holder.addChild(ai);
			
			var lr : Loader = new Loader();
			lr.load(new URLRequest(a.artistImageLge[0]));
			
			lr.x = 10;
			lr.y = 10;
			
			ai.addChild(lr);
			
			lr.mask = ai["imageMask"];
			
			ai["infoText"].htmlText = a.bio;
			ai["artistName"].htmlText = LastVars.CURRENT_ARTIST;
		}

		private function tuneradio() : void
		{	
			killTheMusic();
			radio.tune();
			radio.addEventListener(LastEvent.RADIO_TUNED, radioLoaded);
		}

		private function radioLoaded(e : LastEvent) : void
		{
			e.currentTarget.removeEventListener(LastEvent.RADIO_TUNED, radioLoaded);
			loadPlayList();
		}

		private function loadPlayList() : void
		{
			radio.getPlayList();
			radio.addEventListener(LastEvent.PLAYLIST_READY, plReady);
		}

		private function plReady(e : LastEvent) : void
		{
			playMusic();
			radio.removeEventListener(LastEvent.PLAYLIST_READY, plReady);
		}

		private function playMusic() : void
		{			
			if(!loading) {				
				url = new URLRequest(radio.TrackURL[tuneIndex]);
				if(url.url == null) {
					loadNextList();
				} else {
					music = new Sound(url);
					music.addEventListener(IOErrorEvent.IO_ERROR, musicError);
					
					var currentStation : String = LastVars.STATION_STRING;
					
					LastVars.CURRENT_TRACK_INFO = radio.Artist[tuneIndex] + " / " + radio.Song[tuneIndex] + " / " + radio.Album[tuneIndex];
					
					this["infoText"].aSprite["infoText"].text = LastVars.CURRENT_TRACK_INFO + " - Station: " + currentStation;
					this["infoText"].bSprite["infoText"].text = LastVars.CURRENT_TRACK_INFO + " - Station: " + currentStation;
					this["infoText"].resetPositions();									
					
					LastVars.CURRENT_ARTIST = radio.Artist[tuneIndex];
					LastVars.CURRENT_TRACK = radio.Song[tuneIndex];
					
					
					endTimeSeconds = Number(radio.trackDuration[tuneIndex]);				
					endTime = secondsToMinutes(endTimeSeconds);
					
					currentTime = 0.00;
					this["progressTime"].text = String(currentTime.toFixed(2));
					this["totalTime"].text = endTime;
					
					trackTimer.addEventListener(TimerEvent.TIMER, upDateTime);
					trackTimer.start();
					
					getArtistInfo();
					
					sc = music.play();
					st.volume = vol;
					sc.soundTransform = st;
					
					sysMan.addEventListener(LastEvent.NEXT_TUNE_PLEASE, sysNext);
					sysMan.addEventListener(LastEvent.STOP_MUSIC_PLEASE, sysStop);
					
					this["playBtn"].gotoAndStop(2);
					this["playBtn"].addEventListener(MouseEvent.CLICK, stopMusic);
					this["playBtn"].removeEventListener(MouseEvent.CLICK, click);
					this["loveBtn"].addEventListener(MouseEvent.CLICK, loveTrack);
					this["banBtn"].addEventListener(MouseEvent.CLICK, banTrack);
															
					if(tuneIndex >= radio.tracks.length() - 1 || radio.tracks.length() == 1) {			
						loadNextList();
						loading = true;
					} else {
						this["nextBtn"].addEventListener(MouseEvent.MOUSE_DOWN, click);
					}
				}
			}
		}

		private function loveTrack(e : MouseEvent) : void
		{
			var lib : Track = new Track();
			lib.love(LastVars.CURRENT_ARTIST, LastVars.CURRENT_TRACK);
			
			this["infoText"].flash("Track given some luv!");
		}

		private function banTrack(e : MouseEvent) : void
		{
			var lib : Track = new Track();
			lib.ban(LastVars.CURRENT_ARTIST, LastVars.CURRENT_TRACK);
			
			this["infoText"].flash("Track has been banned!");
		}

		private function usersLibraryRadio(e : MouseEvent) : void
		{
			this["bottomBar"].bar.addEventListener(MouseEvent.CLICK, bottomClicked);
			LastVars.STATION_STRING = "user/" + LastVars.USER + "/library";
			tuneradio();
		}

		private function secondsToMinutes(secs : Number) : String
		{
			var dur : Number = secs / 60;
			var et : String = String(dur.toFixed(2));

			var mins : String;
			
			var ar : Array = et.split(".");
					
			var em : Number = Number(ar[0]);
			var es : Number = Number(ar[1]);
					
			es = (es / 100) * 60;
			es = Number(es.toFixed());
			var eString : String;
					
			if(es < 10) {
				eString = "0" + es;
			} else {
				eString = String(es);
			}
								
			mins = String(em) + "." + eString;

			return mins;
		}

		private function upDateTime(e : TimerEvent) : void
		{
			timerTime += 1;
			if(timerTime > 24){
				currentTime += 1;	
				this["progressTime"].text = secondsToMinutes(currentTime);
				this["progressBar"].setProgress(currentTime, endTimeSeconds);
				
				if(currentTime > endTimeSeconds) {
					musicEnded();
				}
				timerTime = 0;
			}
			this["infoText"].scrollText();
		}

		private function sysNext(e : LastEvent) : void
		{
			moveOn();
		}

		private function sysStop(e : LastEvent) : void
		{
			killTheMusic();
			stopTheMusic();			
			sysMan.removeEventListener(LastEvent.STOP_MUSIC_PLEASE, sysStop);
		}

		private function click(e : MouseEvent) : void
		{
			sysMan.removeEventListener(LastEvent.NEXT_TUNE_PLEASE, sysNext);
			sysMan.removeEventListener(LastEvent.STOP_MUSIC_PLEASE, sysStop);
			nextTune();
		}		

		private function stopMusic(e : MouseEvent) : void
		{
			stopTheMusic();
		}

		private function stopTheMusic() : void
		{
			killTheMusic();
			this["playBtn"].gotoAndStop(1);
			this["playBtn"].addEventListener(MouseEvent.CLICK, click);
			trackTimer.removeEventListener(TimerEvent.TIMER, upDateTime);
			trackTimer.stop();
		}

		private function moveOn() : void
		{			
			this["playBtn"].removeEventListener(MouseEvent.MOUSE_DOWN, click);
			nextTune();	
		}

		private function musicEnded() : void
		{
			nextTune();
			music.removeEventListener(IOErrorEvent.IO_ERROR, musicError);
		}

		private function resetTimer() : void
		{
			trackTimer.stop();
			trackTimer.removeEventListener(TimerEvent.TIMER, upDateTime);
			
			currentTime = 0;
			startTime = 0;
			seconds = 0;
			minutes = 0;
			timerTime = 0;
			
			this["progressTime"].text = "0.00";
			this["totalTime"].text = "0.00";
			this["progressBar"].resetBar();
		}

		private function killTheMusic() : void
		{
			if(music) {
				music.removeEventListener(IOErrorEvent.IO_ERROR, musicError);
				try {
					music.close();
					sc.stop();
				}
				catch(error : Error) {
					trace("error - no stream open!!");
				}
			}
		}

		private function nextTune() : void
		{
			resetTimer();			
			killTheMusic();
			this["infoText"].removeScroll();
			this["infoText"].resetPositions();
						
			trace("nextTune");
			
			tuneIndex += 1;
			
			this["playBtn"].removeEventListener(MouseEvent.MOUSE_DOWN, click);
			this["loveBtn"].removeEventListener(MouseEvent.CLICK, loveTrack);
			this["banBtn"].removeEventListener(MouseEvent.CLICK, banTrack);
			playMusic();
			
			if(tuneIndex >= radio.tracks.length() - 1 || radio.tracks.length() == 1) {
				trace("last tune");				
				loadNextList();
				loading = true;
			}
		}

		private function loadNextList() : void
		{
			tuneIndex = 0;
			trace("loading next list");
			radio.getPlayList();
			radio.addEventListener(LastEvent.PLAYLIST_READY, nextplReady);	
		}

		private function nextplReady(e : LastEvent) : void
		{
			trace("nextPLReady");
			loading = false;
			radio.removeEventListener(LastEvent.PLAYLIST_READY, nextplReady);
			this["nextBtn"].addEventListener(MouseEvent.MOUSE_DOWN, click);
		}

		private function musicError(e : IOErrorEvent) : void
		{
			trace("STREAM ERROR : " + e.currentTarget);
		}
	}
}
