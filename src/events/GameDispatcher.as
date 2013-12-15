package events
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;

    /**
    * 此框架结构中的mvc中的事件发送中心.
    * **/
    public class GameDispatcher
    {
    	
    	/**
    	 * 发送实例,所有的事件侦听和发送都集中于此对象，来实现消息共享.
    	 * **/
        private var eventDispatcher:IEventDispatcher;
        
        /**
        * 跨服战的时候，被禁发的消息.
        * **/
        public const MULTI_DISABLE_EVENTNAMES:Array = [];
        
        /**
        * 单例模式.
        * **/
        private static var instance:GameDispatcher;

        /**
        * 构造函数.
        * **/
        public function GameDispatcher(_eventDispatcher:IEventDispatcher = null)
        {
            eventDispatcher = new EventDispatcher(_eventDispatcher);
        }

        /**
        * 发送事件.
        * **/
        public function dispatchEvent(event:Event) : Boolean
        {
            return eventDispatcher.dispatchEvent(event);
        }

        /**
        * 是否已经对某个事件进行了注册.
        * **/
        public function hasEventListener(evtType:String) : Boolean
        {
            return eventDispatcher.hasEventListener(evtType);
        }

        /**
        * 制定是否此事件发送中心有被注册回调,注意是对整个事件流进行检测.
        * **/ 
        public function willTrigger(evtType:String) : Boolean
        {
            return eventDispatcher.willTrigger(evtType);
        }

        /**
        * 移除事件侦听.
        * **/
        public function removeEventListener(evtType:String, listener:Function, useCapture:Boolean = false) : void
        {
            eventDispatcher.removeEventListener(evtType, listener, useCapture);
        }

        /**
        * 添加事件侦听.
        * **/
        public function addEventListener(evtType:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false) : void
        {
            eventDispatcher.addEventListener(evtType, listener, useCapture, priority, useWeakReference);
        }

        /**
        * 事件发送中心.
        * **/
        public static function getInstance() : GameDispatcher
        {
            if (instance == null)
            {
                instance = new GameDispatcher();
            }
            return instance;
        }
    }
}
