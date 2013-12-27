package ext.wm.utils
{
	import flash.display.Stage;
	
	import starling.display.Sprite;

	public class STLConstant
	{
		public static var nativeStage:Stage;
		
		public static var currnetAppRoot:Sprite;//当前的根容器
		
		public static var StageWidth:int = 480;//舞台宽
		public static var StageHeight:int = 320;//舞台高
		
		public static var scale:int = 1;//比例
		public static var useMipMaps:Boolean = false;
		
		public static var isDebug:Boolean = false;// 是否调试要显示state
		
		public function STLConstant()
		{
		}
	}
}