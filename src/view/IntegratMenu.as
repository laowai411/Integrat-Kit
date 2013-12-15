package view
{
	import events.GameDispatcher;
	
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.display.NativeWindow;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	
	/**
	 * 菜单
	 * */
	public class IntegratMenu extends EventDispatcher
	{
		
		/**
		 * 事件接受转发器
		 * */
		private static var _dispatcher:EventDispatcher = new EventDispatcher();
		
		///////////////////////////////////////////////
		//				事件定义
		///////////////////////////////////////////////
		/**
		 * 导出swf图片
		 * */
		public static const TOOL_EXPORT_SWF:String = "tool_export_swf";
		
		/**
		 * 检查无用的fla链接
		 * */
		public static const TOOL_CHECK_FLA:String = "tool_check_fla";
		
		///////////////////////////////////////////////
		//				Menu
		///////////////////////////////////////////////
		/**
		 * Main window
		 * */ 
		private static var _mainWindow:NativeWindow;
		
		/**
		 * The main menu item
		 * */
		private static var _nativeMenu:NativeMenu;
		/**
		 * 工具
		 * */
		private static var _toolMenu:NativeMenuItem;
		
		/**
		 * 初始化
		 * */
		public static function initialize(mainWindow:NativeWindow):void
		{
			_mainWindow = mainWindow;
			_mainWindow.menu = createTopMenu();
		}
		
		/**
		 * 顶级菜单
		 * */
		public static function createTopMenu():NativeMenu
		{
			_nativeMenu = new NativeMenu();
			
			_toolMenu = new NativeMenuItem("工具");
			_toolMenu.data = "tool";
			_toolMenu.submenu = createToolMenu();
			_nativeMenu.addItem(_toolMenu);
			
			return _nativeMenu;
		}
		
		/**
		 * 创建"工具"子菜单
		 * */
		private static function createToolMenu():NativeMenu
		{
			var menu:NativeMenu = new NativeMenu();
			
			var itemMenu:NativeMenuItem = new NativeMenuItem("导出SWF图片");
			itemMenu.data = new Event(TOOL_EXPORT_SWF, true);
			itemMenu.addEventListener(Event.SELECT, onSelectItemHandler);
			menu.addItem(itemMenu);
			
			itemMenu = new NativeMenuItem("检查无用的fla链接");
			itemMenu.data = new Event(TOOL_CHECK_FLA, true);
			itemMenu.addEventListener(Event.SELECT, onSelectItemHandler);
			menu.addItem(itemMenu);
			
			return menu;
		}
		
		/**
		 * 选择菜单项
		 * */
		private static function onSelectItemHandler(e:Event):void
		{
			var item:NativeMenuItem = e.target as NativeMenuItem;
			item.checked = !item.checked;
			if(item.data is Event)
			{
				_dispatcher.dispatchEvent(item.data as Event);
			}
		}
		
		/**
		 * 添加事件
		 * */
		public static function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
		{
			_dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		/**
		 * 移除事件
		 * */
		public static function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
		{
			_dispatcher.removeEventListener(type, listener, useCapture);
		}
	}
}