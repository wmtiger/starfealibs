package ext.wm.feathers
{
	import feathers.controls.PanelScreen;
	import feathers.events.FeathersEventType;
	
	import starling.display.DisplayObject;
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
		
		override protected function createHeader():void
		{
			super.createHeader();
			removeHeader();
		}
		
		protected function removeHeader():void
		{
			var displayHeader:DisplayObject = DisplayObject(this.header);
			this.focusExtrasBefore.splice(this.focusExtrasBefore.indexOf(displayHeader), 1);
			this.removeRawChild(displayHeader, true);
		}
		
	}
}