package ext.wm.feathers
{
	import feathers.controls.PanelScreen;
	import feathers.events.FeathersEventType;
	
	import starling.events.Event;
	
	public class WmPanelScreen extends PanelScreen
	{
		public function WmPanelScreen()
		{
			super();
			this.addEventListener(FeathersEventType.INITIALIZE, initializeHandler);
		}
		
		protected function initializeHandler(event:Event):void
		{
			
		}
	}
}