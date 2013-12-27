package ext.wm.utils
{
	import flash.system.Capabilities;

	public class MobileUtil
	{
		public function MobileUtil()
		{
		}
		
		public static function isIOS():Boolean
		{
			return Capabilities.manufacturer.indexOf("iOS") >= 0;
		}
	}
}