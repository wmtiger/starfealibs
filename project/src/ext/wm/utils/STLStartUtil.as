package ext.wm.utils
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.Stage;
	import flash.display.StageOrientation;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	import flash.utils.ByteArray;
	
	import starling.core.Starling;
	import starling.utils.HAlign;
	import starling.utils.RectangleUtil;
	import starling.utils.ScaleMode;
	import starling.utils.VAlign;

	public class STLStartUtil
	{
		private static var _mStarling:Starling;
		
		private static var _launchImage:Loader;
		private static var _savedAutoOrients:Boolean;
		
		private static var _stage:Stage;
		
		public function STLStartUtil()
		{
		}
		
		public static function init(stage:Stage):void
		{
			_stage = stage;
		}
		
		public static function showLaunchImage(root:DisplayObjectContainer):void
		{
			var filePath:String;
			var isPortraitOnly:Boolean = false;
			if(MobileUtil.isIOS())
			{
				if(Capabilities.screenResolutionX == 1536 && Capabilities.screenResolutionY == 2048)
				{
					var isCurrentlyPortrait:Boolean = _stage.orientation == StageOrientation.DEFAULT || _stage.orientation == StageOrientation.UPSIDE_DOWN;
					filePath = isCurrentlyPortrait ? "Default-Portrait@2x.png" : "Default-Landscape@2x.png";
				}
				else if(Capabilities.screenResolutionX == 768 && Capabilities.screenResolutionY == 1024)
				{
					isCurrentlyPortrait = _stage.orientation == StageOrientation.DEFAULT || _stage.orientation == StageOrientation.UPSIDE_DOWN;
					filePath = isCurrentlyPortrait ? "Default-Portrait.png" : "Default-Landscape.png";
				}
				else if(Capabilities.screenResolutionX == 640)
				{
					isPortraitOnly = true;
					if(Capabilities.screenResolutionY == 1136)
					{
						filePath = "Default-568h@2x.png";
					}
					else
					{
						filePath = "Default@2x.png";
					}
				}
				else if(Capabilities.screenResolutionX == 320)
				{
					isPortraitOnly = true;
					filePath = "Default.png";
				}
			}
			
			if(filePath)
			{
				var file:File = File.applicationDirectory.resolvePath(filePath);
				if(file.exists)
				{
					var bytes:ByteArray = new ByteArray();
					var stream:FileStream = new FileStream();
					stream.open(file, FileMode.READ);
					stream.readBytes(bytes, 0, stream.bytesAvailable);
					stream.close();
					_launchImage = new Loader();
					_launchImage.loadBytes(bytes);
					root.addChild(_launchImage);
					_savedAutoOrients = _stage.autoOrients;
					_stage.autoOrients = false;
					if(isPortraitOnly)
					{
						_stage.setOrientation(StageOrientation.DEFAULT);
					}
				}
			}
		}
		
		/**
		 * 根据宽高来创建starling 
		 * @param mainClass
		 * @param width		starling舞台宽
		 * @param height	starling舞台高
		 * @param HDWidth	高清 普通屏幕的分界线
		 * @param debug		是否显示fps状态
		 * @param isPc		是否是再web上运行
		 * @param pullUp	是否拉伸(不拉伸就留黑边)
		 * 
		 */		
		public static function initStarlingWithWH(mainClass:Class, width:int,height:int,HDWidth:int=480,debug:Boolean=false,isPc:Boolean=false,pullUp:Boolean=false):void{
			STLConstant.isDebug = debug;
			STLConstant.nativeStage = _stage;
			STLConstant.StageWidth = width;
			STLConstant.StageHeight = height;
			
			Starling.handleLostContext = !MobileUtil.isIOS();
			Starling.multitouchEnabled = true;
			
			var stageFullScreenWidth:Number = isPc ? _stage.stageWidth : _stage.fullScreenWidth;
			var stageFullScreenHeight:Number = isPc ? _stage.stageHeight : _stage.fullScreenHeight;
			
			var viewPort:Rectangle;
			if(pullUp){
				viewPort = new Rectangle(0,0,stageFullScreenWidth,stageFullScreenHeight);
			}else{
				viewPort = RectangleUtil.fit(
					new Rectangle(0, 0, width, height), 
					new Rectangle(0, 0,stageFullScreenWidth,stageFullScreenHeight), 
					ScaleMode.SHOW_ALL);
			}
			
			STLConstant.scale = viewPort.width > HDWidth ? 2 : 1;//Capabilities.screenDPI > 200 ? 2 : 1;
			
			_mStarling = new Starling(mainClass, _stage, viewPort,null,"auto","baseline");
			_mStarling.antiAliasing = 0;
			_mStarling.stage.stageWidth  = width;
			_mStarling.stage.stageHeight = height;
			_mStarling.enableErrorChecking = Capabilities.isDebugger;
			_mStarling.start();
			if(STLConstant.isDebug){
				_mStarling.showStatsAt(HAlign.LEFT, VAlign.BOTTOM);
			}
			
			if(_launchImage)
			{
				_mStarling.addEventListener("rootCreated", starling_rootCreatedHandler);
			}
			
			_stage.addEventListener(Event.RESIZE, stage_resizeHandler, false, int.MAX_VALUE, true);
			_stage.addEventListener(Event.DEACTIVATE, stage_deactivateHandler, false, 0, true);
			
			trace("handleLostContext:"+Starling.handleLostContext);
			trace("Scale:" + STLConstant.scale);
			trace("StageWidth:"+STLConstant.StageWidth);
			trace("StageHeight:"+STLConstant.StageHeight);
		}
		
		private static function stage_resizeHandler(event:Event):void
		{
			_mStarling.stage.stageWidth = _stage.stageWidth;
			_mStarling.stage.stageHeight = _stage.stageHeight;
			
			const viewPort:Rectangle = _mStarling.viewPort;
			viewPort.width = _stage.stageWidth;
			viewPort.height = _stage.stageHeight;
			try
			{
				_mStarling.viewPort = viewPort;
			}
			catch(error:Error) {}
			if(STLConstant.isDebug){
				_mStarling.showStatsAt(HAlign.LEFT, VAlign.BOTTOM);
			}
		}
		
		private static function starling_rootCreatedHandler(event:Object):void
		{
			if(_launchImage && _launchImage.parent)
			{
				_launchImage.parent.removeChild(_launchImage);
				_launchImage.unloadAndStop(true);
				_launchImage = null;
				_stage.autoOrients = _savedAutoOrients;
			}
		}
		
		private static function stage_deactivateHandler(event:Event):void
		{
			_mStarling.stop();
			_stage.addEventListener(Event.ACTIVATE, stage_activateHandler, false, 0, true);
		}
		
		private static function stage_activateHandler(event:Event):void
		{
			_stage.removeEventListener(Event.ACTIVATE, stage_activateHandler);
			_mStarling.start();
		}
	}
}