package load
{
	import events.ParamEvent;
	
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;

	/**
	 * 显示对象加载器
	 * */
	public class DisplayLoader extends EventDispatcher
	{
		
		public var url:String;
		
		/**
		 * 加载器
		 * */
		private var loader:Loader;
		
		public function DisplayLoader()
		{
			
		}
		
		/**
		 * 加载
		 * */
		public function load(cusURL:String):void
		{
			if(cusURL && cusURL != "")
			{
				loader = new Loader();
				url = cusURL;
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadCompleteHandler);
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIoErrorHandler);
				loader.load(new URLRequest(cusURL), new LoaderContext(false, ApplicationDomain.currentDomain));
			}
		}
		
		/**
		 * 加载完成
		 * */
		private function onLoadCompleteHandler(e:Event):void
		{
			var data:LoaderInfo = e.target as LoaderInfo;
			this.dispatchEvent(new ParamEvent(Event.COMPLETE, {data:data.content, url:url}));
		}
		
		/**
		 * ioerror
		 * */
		private function onIoErrorHandler(e:IOErrorEvent):void
		{
			trace(e.text);
		}
	}
}