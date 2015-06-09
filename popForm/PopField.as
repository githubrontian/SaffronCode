﻿package popForm
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.text.SoftKeyboardType;
	import flash.text.TextField;
	
	public class PopField extends PopFieldInterface
	{
		private var myTXT:TextField ;
		
		private var tagNameTXT:TextField ;
		
		private var backMC:MovieClip ;
		private var myTitle:String;
		
		/**If this was true, data function will controll the phone correction befor returning the value*/
		public var phoneControl:Boolean = false ;
		
		private var radioButtonArray:Array ;
		
		
		/**this will returns last inputed text to client*/
		public function get text():String
		{
			return myTXT.text ;
		}
		
		override public function get title():String
		{
			return myTitle;
		}
		
		override public function update(data:*):void
		{
			if(data!=null)
			{
				myTXT.text = data as String ;
				myTXT.dispatchEvent(new Event(Event.CHANGE));
			}
		}
		
		override public function get data():*
		{
			if(phoneControl)
			{
				var cash:String = PhoneNumberEditor.clearPhoneNumber(text);
				if(cash == 'false')
				{
					trace("This phone number is incorrect");
					return text ;
				}
				else
				{
					return cash ;
				}
			}
			return text ;
		}
		
		public function changeColor(colorFrame:uint)
		{
			backMC.gotoAndStop(colorFrame);
		}
		
		public function PopField(tagName:String,defaultText:String,KeyBordType:String = SoftKeyboardType.DEFAULT,isPass:Boolean = false,editable:Boolean = true,isAraic:Boolean=true,numLines:uint = 1,color:uint=1,frame:uint=1,maxChar:uint=0,otherOptions:Array=null)
		{
			super();
			radioButtonArray = otherOptions ;
			
			//New lines to manage language style ( like rtl and ltr )
			this.gotoAndStop(frame);
			
			
			myTitle = tagName ;
			backMC = Obj.get("back_mc",this);
			
			//New Line to manage textfield background color 
			changeColor(color);
			
			tagNameTXT = Obj.get("tag_txt",Obj.get("tag_txt",this));
			tagNameTXT.text = "" ;
			
			TextPutter.OnButton(tagNameTXT,tagName,true,false,true);
			myTXT = Obj.get('txt_txt',this);
			
			myTXT.maxChars = maxChar ;
			myTXT.borderColor = 0xD92C5C;
			myTXT.displayAsPassword = isPass ;
			myTXT.mouseEnabled = myTXT.selectable = editable ;
			
			if(numLines>1)
			{
				var Y0:Number = myTXT.height ;
				myTXT.multiline = true ;
				myTXT.wordWrap = true ;
				for(var i = 0 ; i<numLines ; i++)
				{
					myTXT.appendText('a\n') ;
				}
				myTXT.text = myTXT.text.substring(0,myTXT.text.length-1);
				myTXT.height = myTXT.textHeight+10;
				var Y1:Number = myTXT.height ;
				backMC.height += Y1-Y0 ;
				backMC.y+=(Y1-Y0)/2;
				myTXT.text = '' ;
			}
			else
			{
				//Why do i need multiline textfield if I desided to use single line text??
				myTXT.multiline = false ;
				myTXT.wordWrap = false ;
			}
			myTXT.text = (defaultText==null)?'': defaultText ;
			
			//FarsiInputText.steKeyBord(myTXT,false);
			if(editable)
			{
				FarsiInputCorrection.setUp(myTXT,KeyBordType);
			}
			else
			{
				//remove texts back ground
				backMC.visible = false;
				if(isAraic)
				{
					UnicodeStatic.fastUnicodeOnLines(myTXT,defaultText);
				}
				else
				{
					myTXT.text = defaultText ;
				}
			}
		}
		
		/**Returns true if radio butto changed*/
		public function switchRadioButton(e=null):Boolean
		{
			if(radioButtonArray == null || radioButtonArray.length ==0)
			{
				trace("No radio button values receved");
				return false ;
			}
			else
			{
				var I:int = radioButtonArray.indexOf(myTXT.text);
				//trace("radioButtonArray : "+radioButtonArray.indexOf(myTXT));
				if(I==-1)
				{
					trace("Cannot find current value between enterd radio buttons : "+myTXT.text+' vs '+radioButtonArray);
					return false ;
				}
				else
				{
					I = (I+1)%radioButtonArray.length ;
					myTXT.text = radioButtonArray[I];
					myTXT.dispatchEvent(new Event(Event.CHANGE));
					return true ;
				}
			}
		}
		
		/**item is added to stage
		private function imAdded(e:Event)
		{
			FarsiInputCorrection.setUp(myTXT,keyBordType);
		}*/
	}
}