package ext.wm.feathers
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	
	import feathers.controls.Label;
	import feathers.controls.List;
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.core.FeathersControl;
	
	import starling.display.DisplayObject;
	import starling.display.Quad;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	/**
	 * WmListItemRender基类
	 * <br/>override createChildren()来创建自组件
	 * <br/>override clickHandler(touch:Touch)组件被点击
	 * <br/>override commitData()写数据填充
	 * <br/>override measure()自动计算组件大小
	 * <br/>override refreshSelectedStyle 做选中/非选中样式
	 * <br/>override refreshHoverStyle 做划上样式
	 * <br/>override updateSize()更新子组件大小
	 * <br/>override refreshBackground 置空来禁止默认样式
	 */
	public class WmListItemRender extends FeathersControl implements IListItemRenderer
	{
		protected var _handler:IRenderClickHandler;
		
		protected var _background:DisplayObject;
		
		protected var itemLabel:Label;
		
		public var textFormat:TextFormat;
		
		protected var _index:int = -1;
		
		protected var _owner:List;
		
		protected var _data:Object;
		
		/**
		 * @private
		 */
		protected var currentSkin:DisplayObject;
		
		/**
		 * @private
		 * Stores the values for each state.
		 */
		protected var stateToValue:Dictionary = new Dictionary(true);
		
		/**
		 * @private
		 * Stores the values for each state where isSelected is true.
		 */
		protected var stateToSelectedValue:Dictionary = new Dictionary(true);
		
		public function WmListItemRender(handler:IRenderClickHandler = null)
		{
			_handler = handler;
			stateToValue[STATE_UP] = new Quad(1, 1, 0xE0FFFF);
			stateToValue[STATE_UP].alpha = 0;
			this.addEventListener(TouchEvent.TOUCH, touchHandler);
			this.addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
		}
		
		public function get index():int
		{
			return this._index;
		}
		
		public function set index(value:int):void
		{
			if (this._index == value)
			{
				return;
			}
			this._index = value;
			this.invalidate(INVALIDATION_FLAG_DATA);
		}
		
		public function get owner():List
		{
			return List(this._owner);
		}
		
		public function set owner(value:List):void
		{
			if (this._owner == value)
			{
				return;
			}
			if (this._owner)
			{
				List(this._owner).removeEventListener(Event.SCROLL, owner_scrollHandler);
			}
			this._owner = value;
			if (this._owner)
			{
				const list:List = List(this._owner);
				list.addEventListener(Event.SCROLL, owner_scrollHandler);
			}
			this.invalidate(INVALIDATION_FLAG_DATA);
		}
		
		public function get data():Object
		{
			return this._data;
		}
		
		public function set data(value:Object):void
		{
			if (this._data == value)
			{
				return;
			}
			this._data = value;
			this.invalidate(INVALIDATION_FLAG_DATA);
		}
		
		protected var _isSelected:Boolean;
		
		public function get isSelected():Boolean
		{
			return this._isSelected;
		}
		
		public function set isSelected(value:Boolean):void
		{
			if (this._isSelected == value)
			{
				return;
			}
			this._isSelected = value;
			this.invalidate(INVALIDATION_FLAG_SELECTED);
			this.dispatchEventWith(Event.CHANGE);
		}
		
		public function get isHover():Boolean
		{
			return this.currentState == STATE_HOVER;
		}
		
		/**
		 * @private
		 */
		protected function owner_scrollHandler(event:Event):void
		{
			this._touchPointID = -1;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			createChildren();
			createLabel();
		}
		
		protected function createLabel():void
		{
			if (!this.itemLabel)
			{
				this.itemLabel = new Label();
				this.addChild(this.itemLabel);
				if (textFormat)
				{
					itemLabel.textRendererProperties.textFormat = textFormat;
				}
				itemLabel.visible=false;
			}
		}
		
		protected function createChildren():void
		{
			
		}
		
		protected function clickHandler(touch:Touch):void
		{
			if (_handler != null)
			{
				_handler.clickItem(data);
			}
		}
		
		override protected function draw():void
		{
			const dataInvalid:Boolean = this.isInvalid(INVALIDATION_FLAG_DATA);
			const selectionInvalid:Boolean = this.isInvalid(INVALIDATION_FLAG_SELECTED);
			const styleInvalid:Boolean = this.isInvalid(INVALIDATION_FLAG_STYLES);
			var sizeInvalid:Boolean = this.isInvalid(INVALIDATION_FLAG_SIZE);
			const stateInvalid:Boolean = this.isInvalid(INVALIDATION_FLAG_STATE);
			
			if (dataInvalid)
			{
				this.commitData();
			}
			
			if (styleInvalid)
			{
				this.refreshStyle();
			}
			
			if (selectionInvalid) {
				refreshSkin();
			}
			
			sizeInvalid = this.autoSizeIfNeeded() || sizeInvalid;
			
			if (styleInvalid || stateInvalid || selectionInvalid || sizeInvalid)
			{
				this.scaleSkin();
			}
			
			if (dataInvalid || styleInvalid || stateInvalid || selectionInvalid || sizeInvalid)
			{
				this.layoutContent();
			}
			
			super.draw();
		}
		
		private function autoSizeIfNeeded():Boolean
		{
			const needsWidth:Boolean = isNaN(this.explicitWidth);
			const needsHeight:Boolean = isNaN(this.explicitHeight);
			if (!needsWidth && !needsHeight)
			{
				return false;
			}
			
			var newRect:Rectangle = new Rectangle();
			
			measure(newRect);
			
			var newWidth:Number = this.explicitWidth;
			var newHeight:Number = this.explicitHeight;
			if (needsWidth)
			{
				newWidth = newRect.width;
			}
			if (needsHeight)
			{
				newHeight = newRect.height;
			}
			return this.setSizeInternal(newWidth, newHeight, false);
		}
		
		protected function measure(resultWH:Rectangle):void
		{
			var w:Number = 0;
			var h:Number = 0;
			var i:int = this.numChildren - 1;
			for (; i >= 0; i--)
			{
				var cc:DisplayObject = this.getChildAt(i);
				if (cc is FeathersControl)
					FeathersControl(cc).validate();
				w = Math.max(w, cc.x + cc.width);
				h = Math.max(h, cc.y + cc.height);
			}
			resultWH.width = w;
			resultWH.height = h;
		}
		
		protected function commitData():void
		{
			if (this.itemLabel == null)
				return;
			if (_data && this._data.text)
			{
				this.itemLabel.text = this._data.text.toString();
				itemLabel.visible=true;
			}
			else
			{
				this.itemLabel.text = "";
			}
		}
		
		protected function refreshStyle():void
		{
			refreshSkin();
			refreshSelectedStyle();
			if (currentState == STATE_HOVER)
			{
				refreshHoverStyle();
			}
		}
		
		protected function refreshSkin():void
		{
			const oldSkin:DisplayObject = this.currentSkin;
			this.currentSkin = DisplayObject(stateToSkin());
			if (this.currentSkin != oldSkin)
			{
				if (oldSkin)
				{
					this.removeChild(oldSkin, false);
				}
				if (this.currentSkin)
				{
					if (this.isSelected) {
						// TODO, 背景以上
						this.addChildAt(this.currentSkin, 1);
					} else {
						this.addChildAt(this.currentSkin, 0);
					}
				}
			}
		}
		
		public function set selectedSkin(obj:DisplayObject):void {
			stateToSelectedValue[STATE_UP] = obj;
		}
		
		private function stateToSkin():DisplayObject
		{
			var value:DisplayObject;
			if (isSelected)
			{
				value = this.stateToSelectedValue[currentState];
			}
			else
			{
				value = this.stateToValue[currentState];
			}
			return value;
		}
		
		protected function refreshSelectedStyle():void
		{
			
		}
		
		protected function refreshHoverStyle():void
		{
			
		}
		
		protected function refreshSelectedSkinPosition():void {
			currentSkin.x = (actualWidth - currentSkin.width) / 2;
			currentSkin.y = (actualHeight - currentSkin.height) / 2;
		}
		
		private function scaleSkin():void
		{
			if (this.currentSkin)
			{
				if (this.currentSkin == stateToSelectedValue[STATE_UP]) {
					refreshSelectedSkinPosition();
				} else {
					this.currentSkin.width = this.actualWidth;
					this.currentSkin.height = this.actualHeight;
				}
			}
			
			if (_background) {
				_background.width = this.actualWidth;
				_background.height = this.actualHeight;
			}
			
			updateSize();
		}
		
		protected function updateSize():void
		{
			if (this.itemLabel == null)
				return;
			this.itemLabel.width = this.actualWidth;
			this.itemLabel.height = this.actualHeight;
		}
		
		public function set backgroundSkin(value:DisplayObject):void {
			if (this._background == value) {
				return;
			}
			
			if(this._background) {
				this.removeChild(this._background);
			}
			this._background = value;
			if(this._background && this._background.parent != this)
			{
				if (currentSkin == null) {
					addChildAt(this._background, 0);
				} else {
					addChildAt(this._background, 1);
				}
			}
		}
		
		protected function layoutContent():void
		{
			
		}
		
		//                鼠标事件处理
		//______________________________________________
		
		/**
		 * @private
		 */
		public static const STATE_UP:String = "up";
		
		/**
		 * @private
		 */
		public static const STATE_DOWN:String = "down";
		
		/**
		 * @private
		 */
		public static const STATE_HOVER:String = "hover";
		
		/**
		 * @private
		 */
		public static const STATE_DISABLED:String = "disabled";
		
		/**
		 * @private
		 */
		protected var _stateNames:Vector.<String> = new <String>[STATE_UP, STATE_DOWN, STATE_HOVER, STATE_DISABLED];
		
		/**
		 * A list of all valid state names.
		 */
		protected function get stateNames():Vector.<String>
		{
			return this._stateNames;
		}
		
		/**
		 * @private
		 */
		protected var _currentState:String = STATE_UP;
		
		/**
		 * @private
		 */
		protected function get currentState():String
		{
			return this._currentState;
		}
		
		/**
		 * @private
		 */
		protected function set currentState(value:String):void
		{
			// 我们只关注state_up状态
			value = STATE_UP;
			
			if (this._currentState == value)
			{
				return;
			}
			if (this.stateNames.indexOf(value) < 0)
			{
				throw new ArgumentError("Invalid state: " + value + ".");
			}
			this._currentState = value;
			this.invalidate(INVALIDATION_FLAG_STATE);
		}
		
		/**
		 * @private
		 */
		private static const HELPER_POINT:Point = new Point();
		/**
		 * @private
		 */
		protected var _touchPointID:int = -1;
		/**
		 * @private
		 */
		protected var _isHoverSupported:Boolean = false;
		
		/**
		 * @private
		 */
		protected function touchHandler(event:TouchEvent):void
		{
			if (!this._isEnabled)
			{
				return;
			}
			const touches:Vector.<Touch> = event.getTouches(this);
			if (touches.length == 0)
			{
				//end of hover
				this.currentState = STATE_UP;
				return;
			}
			if (this._touchPointID >= 0)
			{
				var touch:Touch;
				for each (var currentTouch:Touch in touches)
				{
					if (currentTouch.id == this._touchPointID)
					{
						touch = currentTouch;
						break;
					}
				}
				
				if (!touch)
				{
					//end of hover
					this.currentState = STATE_UP;
					return;
				}
				
				touch.getLocation(this, HELPER_POINT);
				var isInBounds:Boolean = this.hitTest(HELPER_POINT, true) != null;
				
				if (touch.phase == TouchPhase.MOVED)
				{
					if (isInBounds)
					{
						this.currentState = STATE_DOWN;
					}
					else
					{
						this.currentState = STATE_UP;
					}
				}
				else if (touch.phase == TouchPhase.ENDED)
				{
					this._touchPointID = -1;
					
					if (isInBounds)
					{
						if (this._isHoverSupported)
						{
							touch.getLocation(this, HELPER_POINT);
							this.localToGlobal(HELPER_POINT, HELPER_POINT);
							
							//we need to do a new hitTest() because a display
							//object may have appeared above this button that
							//will prevent clearing the hover state
							isInBounds = this.contains(this.stage.hitTest(HELPER_POINT, true));
							this.currentState = (isInBounds && this._isHoverSupported) ? STATE_HOVER : STATE_UP;
						}
						else
						{
							this.currentState = STATE_UP;
						}
						this.dispatchEventWith(Event.TRIGGERED);
						clickHandler(touch);
						this.isSelected = !this._isSelected;
					}
					else
					{
						this.currentState = STATE_UP;
					}
				}
			}
			else //if we get here, we don't have a saved touch ID yet
			{
				for each (touch in touches)
				{
					if (touch.phase == TouchPhase.BEGAN)
					{
						this._touchPointID = touch.id;
						break;
					}
					else if (touch.phase == TouchPhase.HOVER)
					{
						this.currentState = STATE_HOVER;
						this._isHoverSupported = true;
						break;
					}
				}
			}
		}
		
		/**
		 * @private
		 */
		protected function removedFromStageHandler(event:Event):void
		{
			this._touchPointID = -1;
			this.currentState = this._isEnabled ? STATE_UP : STATE_DISABLED;
		}
	}
}