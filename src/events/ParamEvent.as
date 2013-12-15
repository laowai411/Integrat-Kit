package events
{
    import flash.events.Event;
    
    /**
    * 可以携带参数的事件类型.
    * **/  
    public class ParamEvent extends Event
    {
    	/**
    	 * 携带参数.
    	 * **/
        public var param:Object;

        public function ParamEvent(evtType:String, data:Object = null, bubbles:Boolean = false, cancelable:Boolean = false) : void
        {
            super(evtType, bubbles, cancelable);
            this.param = data;
        }
    }
}
