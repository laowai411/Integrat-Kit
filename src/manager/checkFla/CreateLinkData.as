package manager.checkFla
{
	import events.EventName;
	import events.GameDispatcher;
	import events.ParamEvent;
	
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	/**
	 * 生成link数据
	 * */
	public class CreateLinkData extends EventDispatcher
	{
		
		private static const FLA_URL_REG:String = "FLA_URL";
		private static const LINK_URL_REG:String = "LINK_URL";
		
		private static var _instance:CreateLinkData;
		
		public static function getInstance():CreateLinkData
		{
			if(!_instance)
			{
				_instance = new CreateLinkData();
			}
			return _instance;
		}
		
		/**
		 * Flash.exe进程
		 * */
		private var flashProcess:NativeProcess;
		
		/**
		 * flash.exe文件
		 * */
		private var flashExe:File;
		
		/**
		 * fla文件列表
		 * */
		private var flaList:Array;
		
		/**
		 * 每个delay开始的时间
		 * */
		private var startTime:uint;
		
		/**
		 * 搜索link的模版jsfl文件内容
		 * */
		private var templateJSFL:String;
		
		private var timer:Timer;
		
		/**
		 * fla文件总数
		 * */
		private var flaCount:uint;
		
		/**
		 * 打开flash进程
		 * */
		public function startFlash():void
		{
			flaList = [];
			getAllFla(CheckFlaConfig.flaURL);
			flaCount = flaList.length;
			
			getTemplateJSFL();
			
			timer = new Timer(CheckFlaConfig.searchFlaDelay);
			timer.addEventListener(TimerEvent.TIMER, onTimerHandler);
			
			flashExe = new File(CheckFlaConfig.flashURL);
			
			timer.start();
		}
		
		/**
		 * 遍历目录取到所有的fla
		 * */
		private function getAllFla(url:String):void
		{
			var list:Array = new File(url).getDirectoryListing();
			for each(var flaFile:File in list)
			{
				if(flaFile.isDirectory)
				{
					getAllFla(flaFile.nativePath);
				}
				else
				{
					if(flaFile.type == ".fla")
					{
						flaList.push(flaFile);
					}
				}
			}
		}
		
		/**
		 * 读取模版jsfl脚本
		 * */
		private function getTemplateJSFL():void
		{
			var jsflFile:File = new File(File.applicationDirectory.resolvePath("./etc/link.jsfl").nativePath);
			var rs:FileStream = new FileStream();
			rs.open(jsflFile, FileMode.READ);
			templateJSFL = rs.readUTFBytes(rs.bytesAvailable);
			rs.close();
			GameDispatcher.getInstance().dispatchEvent(new ParamEvent(EventName.PRINT, "载入jsfl模版完成"));
		}
		
		/**
		 * 每个delay执行
		 * */
		private function onTimerHandler(e:TimerEvent):void
		{
			startTime = getTimer();
			while(true)
			{
				if(getTimer() - startTime > CheckFlaConfig.searchFlaMaxTime)
				{
					return;
				}
				GameDispatcher.getInstance().dispatchEvent(new ParamEvent(EventName.PRINT, CheckFlaConfig.searchFlaDelay+" 检测"));
				var file:File;
				if(checkComplete())
				{
					GameDispatcher.getInstance().dispatchEvent(new ParamEvent(EventName.PRINT, "上一个jsfl执行完成"));
					file = new File(CheckFlaConfig.linkURL+"\\complete.txt");
					if(file && file.exists)
					{
						file.deleteFile();
					}
					file = new File(CheckFlaConfig.linkURL+"\\running.txt");
					if(file && file.exists)
					{
						file.deleteFile();
					}
					file.cancel();
				}
				else
				{
					if(checkJSFLRunning())
					{
						return;
					}
				}
				GameDispatcher.getInstance().dispatchEvent(new ParamEvent(EventName.CHANGE_STATE, {typeName:"jsfl脚本", total:flaCount, odd:flaList.length}));
				var flaFile:File = flaList.pop();
				if(!flaFile)
				{
					(e.target as Timer).removeEventListener(TimerEvent.TIMER, onTimerHandler);
					(e.target as Timer).stop();
					this.dispatchEvent(new Event(Event.COMPLETE));
					return;
				}
				if(flaFile.type != ".fla")
				{
					continue;
				}
				
				file = new File(CheckFlaConfig.linkURL+"\\running.txt");
				var rs:FileStream = new FileStream();
				rs.open(file, FileMode.WRITE);
				rs.writeUTFBytes("running");
				rs.close();
				file.cancel();
				
				createLinkXml(flaFile);
			}
		}
		
		/**
		 * 执行jsfl
		 * */
		private function createLinkXml(fla:File):void
		{
			createJsfl(fla);
			var jsflURL:String = CheckFlaConfig.jsflURL+"\\"+fla.name.substr(0, fla.name.indexOf(".fla"))+".jsfl";
			GameDispatcher.getInstance().dispatchEvent(new ParamEvent(EventName.PRINT, jsflURL+"生成成功"));
			var processInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			processInfo.executable = flashExe;
			var prarams:Vector.<String> = new Vector.<String>;
			prarams.push(jsflURL);
			processInfo.arguments = prarams;
			this.flashProcess = new NativeProcess();
			flashProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onHasReadDataHandler);
			flashProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, onStandErrorHandler);
			flashProcess.addEventListener(NativeProcessExitEvent.EXIT, onFlashExitHandler);
			flashProcess.addEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, onStandardOutputIoErrorHandler);
			flashProcess.addEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, onStandardErrorIoErrorHandler);
			this.flashProcess.start(processInfo);
			
			GameDispatcher.getInstance().dispatchEvent(new ParamEvent(EventName.PRINT, jsflURL+"开始执行"));
		}

		private function onStandardErrorIoErrorHandler(event:IOErrorEvent):void
		{
			GameDispatcher.getInstance().dispatchEvent(new ParamEvent(EventName.PRINT, event.text));
		}

		private function onStandardOutputIoErrorHandler(event:IOErrorEvent):void
		{
			GameDispatcher.getInstance().dispatchEvent(new ParamEvent(EventName.PRINT, event.text));
		}
		
		/**
		 * 生成对应与fla的jsfl脚本
		 * */
		private function createJsfl(flaFile:File):void
		{
			var jsfl:File = new File(CheckFlaConfig.jsflURL+"\\"+flaFile.name.substr(0, flaFile.name.indexOf(".fla"))+".jsfl");
//			if(jsfl && jsfl.exists)
//			{
//				jsfl.deleteFile();
//			}
			var ws:FileStream = new FileStream();
			ws.open(jsfl, FileMode.WRITE);
			var tempStr:String = templateJSFL.replace(FLA_URL_REG, changeFLAURLFormatForJSFL(flaFile.url));
			tempStr = tempStr.replace(LINK_URL_REG, changeLINKURLFormatForJSFL(CheckFlaConfig.linkURL+"\\"+flaFile.name.substr(0, flaFile.name.indexOf(".fla"))+".xml"));
			ws.writeUTFBytes(tempStr);
			ws.close();
			
			jsfl.cancel();
		}
		
		/**
		 * fla路径转换成jsfl需要的路径格式
		 * */
		private function changeFLAURLFormatForJSFL(url:String):String
		{
			var tempurl:String = url.substr(0, url.indexOf(":", 5));
			url = url.substr(9);
			tempurl += "|"+url.substr(url.indexOf(":")+1);
			return tempurl;
		}
		
		/**
		 * jsfl脚本路径转换成jsfl需要的路径格式
		 * */
		private function changeLINKURLFormatForJSFL(url:String):String
		{
			 url = "file:///"+url;
			 var tempurl:String = url.substr(0, url.indexOf(":", 5));
			 url = url.substr(9);
			 tempurl += "|"+url.substr(url.indexOf(":")+1);
			 tempurl = tempurl.replace(/\\/g, "/");
			 
			 return tempurl;
		}
		
		/**
		 * 输出流上存在本机进程可以读取的数据。
		 * */
		private function onHasReadDataHandler(e:ProgressEvent):void
		{
//			trace("out", flashProcess.standardOutput.readUTFBytes(flashProcess.standardOutput.bytesAvailable)); 
		}
		
		/**
		 * Flash.exe退出
		 * */
		private function onFlashExitHandler(e:NativeProcessExitEvent):void
		{
			var process:NativeProcess = e.target as NativeProcess;
			GameDispatcher.getInstance().dispatchEvent(new ParamEvent(EventName.PRINT, "flash.exe退出 "+e.exitCode));
			GameDispatcher.getInstance().dispatchEvent(new ParamEvent(EventName.PRINT, e.toString()));
		}
		
		/**
		 * 启动error
		 * */
		private function onStandErrorHandler(e:ProgressEvent):void
		{
			GameDispatcher.getInstance().dispatchEvent(new ParamEvent(e.toString()));
		}
		
		/**
		 * 是否有jsfl正在执行
		 * */
		private function checkJSFLRunning():Boolean
		{
			var tempDir:File = new File(CheckFlaConfig.linkURL+"\\running.txt");
			if(tempDir && tempDir.exists)
			{
				return true;
			}
			return false;
		}
		
		/**
		 * 脚本执行完成
		 * */
		private function checkComplete():Boolean
		{
			trace(CheckFlaConfig.linkURL+"\\complete.txt");
			var tempDir:File = new File(CheckFlaConfig.linkURL+"\\complete.txt");
			if(tempDir && tempDir.exists)
			{
				return true;
			}
			return false;
		}
	}
}