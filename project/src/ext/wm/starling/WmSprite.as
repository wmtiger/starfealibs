package ext.wm.starling
{
	import starling.display.Sprite;
	import starling.events.Event;
	
	public class WmSprite extends Sprite
	{
		public function WmSprite()
		{
			super();
			this.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}
		
		protected function addedToStageHandler(event:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			
			init();
			
		}
		
		protected function init():void
		{
			
		}
	}
}