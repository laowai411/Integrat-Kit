package load
{
	import events.ParamEvent;
	
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	/**
	 * 缓存加载控制器
	 * */
	public class SourceCache extends EventDispatcher
	{
		
		private static var _instance:SourceCache;
		
		public static function getInstance():SourceCache
		{
			if(_instance == null)
			{
				_instance = new SourceCache();
			}
			return _instance;
		}
		
		public function SourceCache()
		{
			_loadedDic = new Dictionary();
			_disLoadingDic = new Dictionary();
			_byteLoaddingDic = new Dictionary();
			_waitLoadList = [];
			_isLoadding = false;
			
			timer = new Timer(1000);
			timer.addEventListener(TimerEvent.TIMER, onTimerHandler);
		}
		
		/**
		 * 计时器， 每秒检查等待加载的列表
		 * */
		private var timer:Timer;
		
		/**
		 * 已经加载完成
		 * */
		private var _loadedDic:Dictionary;
		
		/**
		 * swf或者png加载中的文件
		 * */
		private var _disLoadingDic:Dictionary;
		
		/**
		 * 二进制加载器正在加载中的文件
		 * */
		private var _byteLoaddingDic:Dictionary;
		
		/**
		 * 加载器是否在加载
		 * */
		private var _isLoadding:Boolean;
		
		/**
		 * 等待加载的列表
		 * */
		private var _waitLoadList:Array;
		
		/**
		 * 加载一个文件
		 * */
		public function load(url:String):void
		{
			if(url && url != "")
			{
				if(_loadedDic[url] != undefined)
				{
					this.dispatchEvent(new ParamEvent(Event.COMPLETE, {data:_loadedDic[url], url:url}));
				}
				else if(_disLoadingDic[url] == true || _byteLoaddingDic[url] == true)
				{
					
				}
				else
				{
					if(_waitLoadList.indexOf(url) < 0)
					{
						_waitLoadList.push(url);
						timer.start();
					}
				}
			}
		}
		
		/**
		 * 计时器心跳，检查不再加载中才去加载一个文件
		 * */
		private function onTimerHandler(e:TimerEvent):void
		{
			var url:String = _waitLoadList.pop();
			if(url && url != "")
			{
				if(url.substr(-2) == "wf" && _disLoadingDic[url] != true)
				{
					loadDisFile(url);
				}
				else if(_byteLoaddingDic[url] != true)
				{
					
				}
			}
			else
			{
				timer.stop();
			}
		}
		
		/**
		 * 加载swf或者png文件
		 * */
		private function loadDisFile(url:String):void
		{
			_disLoadingDic[url] = true;
			var loader:DisplayLoader = new DisplayLoader();
			loader.addEventListener(Event.COMPLETE, onLoadDisCompleteHandler);
			loader.load(url);
		}
		
		/**
		 * swf，png加载完成
		 * */
		private function onLoadDisCompleteHandler(e:ParamEvent):void
		{
			if(_waitLoadList.length<1)
			{
				timer.stop();
			}
			_loadedDic[e.param.url] = e.param.data;
			this.dispatchEvent(new ParamEvent(Event.COMPLETE, e.param));
			delete _disLoadingDic[e.param.url];
		}
	}
}
