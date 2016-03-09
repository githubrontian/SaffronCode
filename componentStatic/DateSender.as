package componentStatic
{
	import diagrams.calender.MyShamsi;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.text.SoftKeyboardType;

	public class DateSender extends ComponentManager
	{
		public static const YYYY:String="yyyy";
		public static const MM:String = "mm";
		public static const DD:String = "dd"
		private var yMc:MovieClip,
					mMc:MovieClip,
					dMc:MovieClip;
		private var _yyStr:String,
					_mmStr:String,
					_ddStr:String;
					
		private var _date:Date,
					_shamsiDate:MyShamsi,
					_shamsi:Boolean;
		public function DateSender(Shamsi_p:Boolean=true)
		{
			super();
			_shamsi = Shamsi_p
			update()
			ComponentManager.evt.addEventListener(ComponentManagerEvent.UPDATE,getUpdate)
		}
		protected function getUpdate(event:Event):void
		{
			// TODO Auto-generated method stub
			update()
		}
		
		public function update():void
		{
			var value:String  = ''
			_date = null
			if(getObj(this.name)!=null)
			{
				value = getObj(this.name)
				_date = new Date(Number(value))	
			}
	
			yMc = Obj.get('y_mc',this)
			mMc = Obj.get('m_mc',this)
			dMc = Obj.get('d_mc',this)
			if(this.name.split('e')[0]!='instanc')
			{
				setObj(this.name,value,ErrorManager.DATE)
			}
			if(yMc!=null)
			{
				_yyStr = getFiledDate(_date,YYYY)
				var _yy:TextBox = new TextBox(yMc,_yyStr,SoftKeyboardType.NUMBER,true)
				_yy.addEventListener(TextBoxEvent.TEXT,yy_fun)	
			}
			if(mMc!=null)
			{
				_mmStr = getFiledDate(_date,MM)
				var _mm:TextBox = new TextBox(mMc,_mmStr,SoftKeyboardType.NUMBER,true)
				_mm.addEventListener(TextBoxEvent.TEXT,mm_fun)
			}
			if(dMc!=null)
			{
				_ddStr = getFiledDate(_date,DD)
				var _dd:TextBox = new TextBox(dMc,_ddStr,SoftKeyboardType.NUMBER,true)
				_dd.addEventListener(TextBoxEvent.TEXT,dd_fun)
			}
			if(_date==null)
			{
				_date = new Date()
			}
			_date.hours = 0
			_date.minutes = 0
			_date.seconds = 0	
			_date.milliseconds = 0
			if(_shamsiDate==null)
			{
				_shamsiDate = new MyShamsi()
			}
			_shamsiDate.hours = 0
			_shamsiDate.minutes = 0
			_shamsiDate.seconds = 0
			_shamsiDate.milliseconds = 0	
		}
		protected function dd_fun(event:TextBoxEvent):void
		{
			// TODO Auto-generated method stub
			_ddStr = event.text
			sentValue()	
		}
		
		protected function mm_fun(event:TextBoxEvent):void
		{
			// TODO Auto-generated method stub
	
				_mmStr = event.text
				sentValue()
		}
		
		protected function yy_fun(event:TextBoxEvent):void
		{
			// TODO Auto-generated method stub
		
				_yyStr = event.text
				sentValue()				
		}
		
		private function getFiledDate(Date_p:Date,Status_p:String):String
		{
			if(Date_p==null)
			{
				return Status_p
			}
			return Add_Zero_Behind.add(2,getDateSplit(Date_p,Status_p))
		}
		public function getDateSplit(Date_p:Date,Status_p:String,Shamsi_p:Boolean=true):Number
		{
		
			var _newDate:*;
			if(Shamsi_p)
			{
				_newDate = MyShamsi.miladiToShamsi(Date_p)
			}
			else
			{
				_newDate = Date_p
			}
			
			switch(Status_p)
			{
				case YYYY:
					return  _newDate.fullYear	
					break;
				case MM:
					return _newDate.month+1
					break;
				case DD:
					return _newDate.date
					break;
			}
			return 0
		}
		public function sentValue():void
		{
			//setObj(this.name,_dateArray.join(splitDate),ErrorManager.DATE)
			if(chekError())
			{
				_date.date = int(_ddStr)
				_shamsiDate.date = int(_ddStr)
					
				_date.month = int(_mmStr)-1					
				_shamsiDate.month = int(_mmStr)-1
					
				_date.fullYear = int(_yyStr)
				_shamsiDate.fullYear = int(_yyStr)
					
				if(_shamsi)
				{
					setObj(this.name,MyShamsi.shamsiToMiladi(_shamsiDate).time.toString(),ErrorManager.DATE)
					trace('shamsiiiiiiiiiiiiiii****************')
				}
				else
				{
					setObj(this.name,_date.time.toString(),ErrorManager.DATE)
					trace('miladiiiiiii***************************** :')
				}
			}
			else
			{
				setObj(this.name,ErrorManager.DATE_ERROR,ErrorManager.DATE)
			}
				

	
		}
		public function chekError():Boolean
		{
			var _yyStatus:Boolean = false
			var _mmStatus:Boolean = false
			var _ddStatus:Boolean = false	
			if(_yyStr !='' && !isNaN(Number(_yyStr)) && _yyStr.length>=4 &&  Number(_yyStr)>0)
			{
				_yyStatus = true
			}
			if(_mmStr!='' && !isNaN(Number(_mmStr)) && Number(_mmStr)>0 && Number(_mmStr)<=12)
			{
				_mmStatus = true
			}
			if(_ddStr!='' && !isNaN(Number(_ddStr)) && Number(_ddStr)>0 && Number(_ddStr) <= chekDateInMonth(Number(_mmStr)-1,Number(_yyStr)))
			{
				_ddStatus = true
			}
			if(_yyStatus && _mmStatus && _ddStatus)
			{
				return true
			}
			return false
		}
		public function chekDateInMonth(CurrentMonth_p:int,CurrentYear_p:int):Number
		{
			// TODO Auto Generated method stub
			if(CurrentMonth_p<=5) return 31
			if(CurrentMonth_p>5 && CurrentMonth_p<11) return 30
			if(CurrentMonth_p==11 && kabise(CurrentYear_p))
			{
				return 30
			}
			else if(CurrentMonth_p==11 && !kabise(CurrentYear_p))
			{
				return 29
			}
			return 0;
		}
		public function kabise(year_p:Number):Boolean
		{
			var kabise:Array = new Array(1,5,9,13,17,22,26,30) 
			for each(var id in kabise)
			{
				if(year_p%33==id)
				{
					return true 
				}
			}
			return false
		}
		
	}
}