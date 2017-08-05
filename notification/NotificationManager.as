package notification
{
	import com.milkmangames.nativeextensions.EasyPush;
	import com.milkmangames.nativeextensions.events.PNEvent;
	import com.milkmangames.nativeextensions.events.PNOSEvent;
	import com.mteamapp.StringFunctions;
	
	import contents.Contents;
	
	import flash.display.MovieClip;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	


	/**Notification tocken ready*/
	[Event(name="TOKEN_REGISTER_COMPELETED", type="notification.NotificationEvent")]
	/**Notification receved*/
	[Event(name="NOTIFICATION", type="notification.NotificationEvent")]
	public class NotificationManager extends EventDispatcher
	{
		public static var ONESIGNAL_APP_ID:String;
		public static var GCM_PROJECT_NUMBER:String;
		public static var Notification_Event:NotificationManager
		
		public static var token:String ;
		
		private var _timeOutId:uint	
		private static var autoAlertBox:Boolean;
		public function NotificationManager(ONESIGNAL_APP_ID_p:String='',GCM_PROJECT_NUMBER_p:String='',autoAlerOnNativeBox:Boolean=true)
		{
			super();
			autoAlertBox = autoAlerOnNativeBox ;
			trace("SetUp easy push");
			ONESIGNAL_APP_ID = ONESIGNAL_APP_ID_p ;
			GCM_PROJECT_NUMBER = GCM_PROJECT_NUMBER_p ;
		
			if(ONESIGNAL_APP_ID_p!='' && GCM_PROJECT_NUMBER_p!='')
			{
				EasyPushExample();
			}
		}
		
		/**This will returns an instance on NofificatnionManager to cathc its events<br>
		 * there is no need to call this*/
		public static function setup(ONESIGNAL_APP_ID_p:String='',GCM_PROJECT_NUMBER_p:String='',autoAlerOnNativeBox:Boolean=true):NotificationManager
		{
			autoAlertBox = autoAlerOnNativeBox ;
			trace("SetUp easy push");
			Notification_Event = new NotificationManager()
			ONESIGNAL_APP_ID = ONESIGNAL_APP_ID_p
			GCM_PROJECT_NUMBER = GCM_PROJECT_NUMBER_p
		
			NotificationManager.Notification_Event.EasyPushExample();
			return Notification_Event ;
		}
		
		private function EasyPushExample() 
		{		
			
			//Controll permissions↓
			var requiredPermissionIos:String = "<key>application-identifier</key>\n" +
				"\t<string>??????????."+DevicePrefrence.appID+"</string>\n" +
				"<key>aps-environment</key>\n" +
				"\t<string>development</string><!--\"development\" for adhoc test, \"production\" for Appstore release-->\n" +
				"<key>get-task-allow</key> <true/> <!--Remove this line for Appstore release-->\n" +
				"<key>keychain-access-groups</key>\n" +
				"\t<array>\n" +
				"\t\t<string>??????????."+DevicePrefrence.appID+"</string> <!--Add team id-->\n" +
				"\t</array>";
			var permissions:String = StringFunctions.clearSpacesAndTabs(DevicePrefrence.appDescriptor) ;
			if(permissions.indexOf("<key>application-identifier</key>")==-1)
			{
				throw "You have to add below permission on <iPhone><Entitlements>  <![CDATA[ \n\n\n"+requiredPermissionIos+'\n\n]]>\n\n' ;
			}
			//TODO control android permission
			//Controll permissions↑
			
			
			if (!EasyPush.isSupported())
			{
				log("EasyPush is not supported on this platform (not android or ios!)");
				return;
			}
			if (!EasyPush.areNotificationsAvailable())
			{
				log("Notifications are not available!");
				return;
			}
			
			log("Easy push created")
			
			if (!validateConstants()) return;
		
			setupOneSignal();
			
		}
		private function setupOneSignal():void
		{
			// onesignal mode
			trace('ONESIGNAL_APP_ID :',ONESIGNAL_APP_ID)
			trace('GCM_PROJECT_NUMBER :',GCM_PROJECT_NUMBER)
			log("init OneSignal...");
			try
			{
				EasyPush.initOneSignal(ONESIGNAL_APP_ID, GCM_PROJECT_NUMBER, autoAlertBox);
			}catch(e)
			{
				trace("Esy push >>>> "+e);
			}
			
			log("did init OneSignal.");
			EasyPush.oneSignal.addEventListener(PNOSEvent.ALERT_DISMISSED,onAlertDismissed);
			EasyPush.oneSignal.addEventListener(PNOSEvent.FOREGROUND_NOTIFICATION,onForegroundNotification);
			EasyPush.oneSignal.addEventListener(PNOSEvent.RESUMED_FROM_NOTIFICATION,onNotification);
			EasyPush.oneSignal.addEventListener(PNOSEvent.TOKEN_REGISTERED,onTokenRegistered);
			EasyPush.oneSignal.addEventListener(PNOSEvent.TOKEN_REGISTRATION_FAILED,onRegFailed);
			tryeToConnectNotificationRegister()
		}
		private function validateConstants():Boolean
		{
			
			if (ONESIGNAL_APP_ID=='')
			{
				log("You did not put your onesignal id in EasyPushExample.as.");
				return false;
			}
			if (GCM_PROJECT_NUMBER=='')
			{
				log("WARNING: won't work on android until id set in EasyPushExample.as.");
				return true;
			}
			return true;
		}
		/////////////////////event
		private function onTokenRegistered(e:PNEvent):void
		{
			log("token registered:"+e.token);
			token = e.token;
			this.dispatchEvent(new NotificationEvent (NotificationEvent.TOKEN_REGISTER_COMPELETED,pnEvent(e)))
			clearTimeout(_timeOutId)	
		} 
		
		private function onRegFailed(e:PNEvent):void
		{
			log("reg failed: "+e.errorId+"="+e.errorMsg);
			loop()
		}
		private function loop():void
		{
			clearTimeout(_timeOutId)
			_timeOutId = setTimeout(setupOneSignal,5000)
		}
		private function onAlertDismissed(e:PNEvent):void
		{
			log("dismissed alert "+e.alert);
			loop()
		}
		
		private function onNotification(e:PNEvent):void
		{
			log(e.type+"="+e.rawPayload+","+e.badgeValue+","+e.title+" customPayload : "+e.customPayload+" : "+JSON.stringify(e.customPayload,null,' '));	
			this.dispatchEvent(new NotificationEvent(NotificationEvent.NOTIFICATION,pnEvent(e),false,false,e.customPayload))
		}
		
		private function onForegroundNotification(e:PNEvent):void
		{
			log(e.type+"="+e.rawPayload+","+e.badgeValue+","+e.title+" customPayload : "+e.customPayload+" : "+JSON.stringify(e.customPayload,null,' '));	
			this.dispatchEvent(new NotificationEvent(NotificationEvent.FOREGROUND_NOTIFICATION,pnEvent(e),false,false,e.customPayload))
		}
		
		///////////////////end event
		private function log(msg:String):void
		{
			trace("[Push Notificatoni]"+msg);
		}
		private function pnEvent(e:PNEvent):PNEventManager
		{
			var _pnEvnet:PNEventManager = new PNEventManager()
			_pnEvnet.alert = e.alert
			_pnEvnet.badgeValue = e.badgeValue
			_pnEvnet.errorId = e.errorId
			_pnEvnet.errorMsg = e.errorMsg
			_pnEvnet.rawPayload = e.rawPayload
			_pnEvnet.customPayload = e.customPayload
			_pnEvnet.title = e.title
			_pnEvnet.token = e.token
			_pnEvnet.type = e.type	
			return _pnEvnet	
		}
		private function tryeToConnectNotificationRegister():void
		{
			this.dispatchEvent(new NotificationEvent(NotificationEvent.TOKEN_REGISTER_START))
		}

	}
}
