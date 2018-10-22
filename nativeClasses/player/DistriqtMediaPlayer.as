﻿package nativeClasses.player
{
	//import com.distriqt.extension.mediaplayer.MediaPlayer;
	
	import contents.alert.Alert;
	
	import flash.desktop.NativeApplication;
	import flash.desktop.SystemIdleMode;
	import flash.display.Sprite;
	import flash.display.StageOrientation;
	import flash.events.AccelerometerEvent;
	import flash.events.Event;
	import flash.events.StageOrientationEvent;
	import flash.filesystem.File;
	import flash.geom.Rectangle;
	import flash.sensors.Accelerometer;
	import flash.utils.clearInterval;
	import flash.utils.getDefinitionByName;
	import flash.utils.setInterval;

	
	public class DistriqtMediaPlayer extends Sprite
	{
		private static const FULLSCREEN_ENTER:String = "fullscreen:enter";
		private static const FULLSCREEN_EXIT:String = "fullscreen:exit";
		
		private var isFullScreen:Boolean = false ;
		
		/**com.distriqt.extension.mediaplayer.MediaPlayer*/
		private static var MediaPlayerClass:Class ;
		
		private static var myDistriqtId:String ;
		
		public static var isSupports:Boolean = false ;

		private static var 	scl:Number = 0,
							lastStageW:Number=0,
							deltaX:Number,
							deltaY:Number;
		
		private static var 	appStageWidth:Number,
							appStageHeight:Number;
							
		private var isOpen:Boolean = false ;
		private var debugIntervalId:uint;
		
		private var lastDeviceOriention:String,
					lastPortrateOrientetion:String = StageOrientation.DEFAULT,
					lastLandscapeOrientation:String = StageOrientation.ROTATED_RIGHT;

					private var player:Object;
		
		public function DistriqtMediaPlayer(Width:Number,Height:Number)
		{
			super();
			if(myDistriqtId==null)
			{
				throw "Set the distriqt id first by calling DistriqtMediaPlayer.setId(...)";
			}
			if(!isSupports)
			{
				trace("Distriqt media player is not supporting this device");
			}
			isFullScreen = false ;
			this.graphics.beginFill(0x222222,0);
			this.graphics.drawRect(0,0,Width,Height);
			if(isNaN(appStageWidth))
			{
				this.addEventListener(Event.ADDED_TO_STAGE,saveStageWidthHeighOnce);
			}
			
		}
		
		
		/**Save the stage widh and height once*/
		private function saveStageWidthHeighOnce(e:*):void
		{
			appStageWidth = stage.stageWidth ;
			appStageHeight = stage.stageHeight ;
			
			if(DevicePrefrence.isPortrait())
			{
				debugIntervalId = setInterval(controlOrientationPortrate,1000);
			}
		}
		
		private function controlOrientationPortrate(){
			if(stage.deviceOrientation == StageOrientation.UNKNOWN || lastDeviceOriention == stage.deviceOrientation)
				return ;
			
			if(stage.deviceOrientation == StageOrientation.UPSIDE_DOWN || stage.deviceOrientation == StageOrientation.DEFAULT)
				lastPortrateOrientetion = stage.deviceOrientation ;
			else
				lastLandscapeOrientation = stage.deviceOrientation;
			
			if(player)
			{
				trace("listen to rotation: isFullScreen : "+isFullScreen);
				if(isFullScreen && (stage.deviceOrientation == StageOrientation.DEFAULT || stage.deviceOrientation == StageOrientation.UPSIDE_DOWN))
				{
					trace("Make it exit from full screen : "+player);
					//Make it exit from full screen ;
					player.setFullscreen( false );
				}
				else if(stage.deviceOrientation == StageOrientation.ROTATED_RIGHT || stage.deviceOrientation == StageOrientation.ROTATED_LEFT)
				{
					//Enter full screen
					trace("Make it full screen : "+player);
					player.setFullscreen( true );
				}
			}
				
			
			trace(" stage.orientation : "+stage.orientation+" vs "+stage.deviceOrientation);
			
			lastDeviceOriention = stage.deviceOrientation ;
		}
		
		/**Pass the video native path for local files
		 * <br><br>MediaPlayer.CONTROLS_BASIC : controls:basic
MediaPlayer.CONTROLS_EMBEDDED : controls:embedded
MediaPlayer.CONTROLS_FULLSCREEN : controls:fullscreen
MediaPlayer.CONTROLS_NONE : controls:none*/
		public function playVideo(videoURL:String,autoPlay:Boolean=true,controlls:String="controls:fullscreen"):void
		{
			NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.KEEP_AWAKE ;
			if(this.stage==null)
			{
				throw "Add the player to the stage first";
			}
			
			var rect:Rectangle = createVewPort();
				
			close();
		
			isOpen = true ;
			
			if(videoURL.indexOf('http')!=0)
			{
				videoURL = new File(videoURL).nativePath;
			}
			
			Alert.show("Play the video : "+videoURL);
			
			player = (MediaPlayerClass as Object).service.createPlayer(videoURL,rect.x,rect.y,rect.width,rect.height,autoPlay,controlls,true);
			(MediaPlayerClass as Object).service.addEventListener(FULLSCREEN_ENTER,isFullscreened);
			(MediaPlayerClass as Object).service.addEventListener(FULLSCREEN_EXIT,exitFullscreened);
			//(MediaPlayerClass as Object).service.addEventListener(com.distriqt.extension.mediaplayer.events.MediaPlayerEvent.STOPPED,exitFullscreened);
			this.removeEventListener(Event.ENTER_FRAME,controlPlayerViewPort);
			this.addEventListener(Event.ENTER_FRAME,controlPlayerViewPort);
			this.addEventListener(Event.REMOVED_FROM_STAGE,unLoad);
		}
		
		/**is exited from full screen*/
		protected function exitFullscreened(event:Event):void
		{
			trace("*** Exit full screen !! : "+event);
			if(isFullScreen && !DevicePrefrence.isLandScape())
			{
				stage.setOrientation(lastPortrateOrientetion);
				trace("StageOrientation. >>> "+lastPortrateOrientetion);
			}
			isFullScreen = false ;
		}
		
		/**is full screen now*/
		protected function isFullscreened(event:Event):void
		{
			trace("*** Set full screen !! : "+event);
			if(!isFullScreen && !DevicePrefrence.isLandScape())
			{
				trace("The default oriented is : "+stage.orientation);
				stage.setOrientation(lastLandscapeOrientation);
				trace("StageOrientation. >>> "+lastLandscapeOrientation);
			}
			isFullScreen = true ;
		}
		
		private function createVewPort():Rectangle
		{
			var rect:Rectangle = this.getBounds(stage);
			/*trace("|rect : "+rect);
			
			trace("stage.fullScreenHeight : "+stage.fullScreenHeight);
			trace("stage.fullScreenWidth : "+stage.fullScreenWidth);
			trace("stage.stageHeight : "+stage.stageHeight);
			trace("stage.stageWidth : "+stage.stageWidth);
			trace("appStageWidth : "+appStageWidth);
			trace("appStageHeight : "+appStageHeight);*/
			
			if(scl==0 || lastStageW!=stage.fullScreenWidth)
			{
				lastStageW = stage.fullScreenWidth ;
				
				var sclX:Number = (stage.fullScreenWidth/appStageWidth) ;
				var sclY:Number = (stage.fullScreenHeight/appStageHeight) ;
				
				deltaX = 0 ;
				deltaY = 0 ;
				if(sclX<=sclY)
				{
					scl = sclX ;
					deltaY = stage.fullScreenHeight-(appStageHeight)*scl ;
				}
				else
				{
					scl = sclY ;
					deltaX = stage.fullScreenWidth-(appStageWidth)*scl ;
				}
			}
			
			/*trace("scl : "+scl);
			trace("deltaY : "+deltaY);
			trace("deltaX : "+deltaX);*/
			
			rect.x*=scl;
			rect.y*=scl;
			rect.x += deltaX/2;
			rect.y += deltaY/2;
			rect.width*=scl;
			rect.height*=scl;
			
			rect.x = round(rect.x);
			rect.y = round(rect.y);
			rect.width = round(rect.width);
			rect.height = round(rect.height);
			
			return rect ;
		}
		
		/**Close player*/
		public function close():void
		{
			NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.NORMAL ;
			trace("Hide the player");
			try
			{
				(MediaPlayerClass as Object).service.removeEventListener(FULLSCREEN_ENTER,isFullscreened);
				(MediaPlayerClass as Object).service.removeEventListener(FULLSCREEN_EXIT,exitFullscreened);
				exitFullscreened(null);
				isOpen = false ;
				(MediaPlayerClass as Object).service.removePlayer();
			}catch(e){};
			this.removeEventListener(Event.ENTER_FRAME,controlPlayerViewPort);
		}
		
		protected function unLoad(event:Event):void
		{
			clearInterval(debugIntervalId);
			NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.NORMAL ;
			try
			{
				(MediaPlayerClass as Object).service.removeEventListener(FULLSCREEN_ENTER,isFullscreened);
				(MediaPlayerClass as Object).service.removeEventListener(FULLSCREEN_EXIT,exitFullscreened);
				exitFullscreened(null);
				trace("Remove player");
				//(MediaPlayerClass as Object).service.removeEventListener(com.distriqt.extension.mediaplayer.events.MediaPlayerEvent.STOPPED,exitFullscreened);
				(MediaPlayerClass as Object).service.removePlayer();
			}
			catch(e)
			{
				trace(">>e"+e);
			}
			this.removeEventListener(Event.ENTER_FRAME,controlPlayerViewPort);
		}
		
		/**Controll the player place*/
		protected function controlPlayerViewPort(event:Event=null):void
		{
			if(isFullScreen || !isOpen)
			{
				return ;
			}
			if(Obj.isAccesibleByMouse(this))
			{
				var rect:Rectangle = createVewPort();
				(MediaPlayerClass as Object).service.resize(rect.x,rect.y,rect.width,rect.height);
			}
			else
			{
				(MediaPlayerClass as Object).service.resize(0,0,0,0);
			}
		}
		
		private function round(num:Number):Number
		{
			return Math.round(num);
		}
		
		/**Add the natives below : <ber>
		 * 
   		<extensionID>com.distriqt.Core</extensionID>
   		<extensionID>com.distriqt.MediaPlayer</extensionID>*/
		public static function setId(distriqtId:String):void
		{
			myDistriqtId = distriqtId ;
			trace("++++Distriqt media player starts+++");
			try
			{
				MediaPlayerClass = getDefinitionByName("com.distriqt.extension.mediaplayer.MediaPlayer") as Class ;
				trace("+++Media player starts+++");
			}
			catch(e)
			{
				MediaPlayerClass = null ;
				isSupports = false ;
				trace('*********************** You dont have com.distriqt.extension.mediaplayer.MediaPlayer embeded in your project **************************');
				return ;
			}
			try
			{
				(MediaPlayerClass as Object).init( myDistriqtId );
				if ((MediaPlayerClass as Object).isSupported)
				{
					isSupports = true ;
					trace("+++Media player is supports+++");
				}
				else
				{
					trace("+++media player is not supports+++");
				}
			}
			catch (e:Error)
			{
				trace("+++Distriqt media player isSupports : "+ e );
				isSupports = false ;
			}
		}
	}
}