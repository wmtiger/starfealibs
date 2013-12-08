package ext.wm.feathers
{
	import feathers.controls.Alert;
	import feathers.controls.TextInput;
	import feathers.core.IFeathersControl;
	import feathers.layout.AnchorLayoutData;
	
	import starling.display.DisplayObject;
	
	public class AlertInput extends Alert
	{
		protected static const INVALIDATION_FLAG_TEXT_INPUT_FACTORY:String = "textInputFactory";
		
		private var _input:TextInput;
		
		public function AlertInput()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			this.invalidate(INVALIDATION_FLAG_TEXT_INPUT_FACTORY);
		}
		
		protected function createTextInputFactory():void
		{
			if(_input)
			{
				this.removeChild(DisplayObject(this._input), true);
				this._input = null;
			}
			_input = new TextInput();
			_input.prompt = "Type Something";
			_input.isEditable = true;
			const inputLayoutData:AnchorLayoutData = new AnchorLayoutData();
			inputLayoutData.horizontalCenter = 0;
			inputLayoutData.verticalCenter = 0;
			_input.layoutData = inputLayoutData;
			addChild(_input);
		}
		
		override protected function draw():void
		{
			super.draw();
			
			const textInputFactoryInvalid:Boolean = this.isInvalid(INVALIDATION_FLAG_TEXT_INPUT_FACTORY);
			
			if(textInputFactoryInvalid)
			{
				this.createTextInputFactory();
			}
			
			if(this._input)
			{
				if(this._input is IFeathersControl)
				{
					IFeathersControl(this._input).validate();
				}
				this._input.x = (this._viewPort.width - this._input.width) / 2;
				this._input.y = this.messageTextRenderer.y + this.messageTextRenderer.height;
			}
		}
	}
}