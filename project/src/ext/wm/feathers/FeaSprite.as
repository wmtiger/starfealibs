package ext.wm.feathers
{
	import flash.geom.Rectangle;
	
	import feathers.core.FeathersControl;
	import feathers.dragDrop.IDropTarget;
	
	import starling.display.DisplayObject;
	
	public class FeaSprite extends FeathersControl implements IDropTarget
	{
		public function FeaSprite()
		{
			super();
		}
		
		override protected function initialize():void
		{
			
		}
		
		/**
		 * @private
		 */
		protected var currentBackgroundSkin:DisplayObject;
		
		/**
		 * @private
		 */
		protected var _backgroundSkin:DisplayObject;
		
		/**
		 * A display object displayed behind the item renderers.
		 */
		public function get backgroundSkin():DisplayObject
		{
			return this._backgroundSkin;
		}
		
		/**
		 * @private
		 */
		public function set backgroundSkin(value:DisplayObject):void
		{
			if(this._backgroundSkin == value)
			{
				return;
			}
			
			if(this._backgroundSkin && this._backgroundSkin != this._backgroundDisabledSkin)
			{
				this.removeChild(this._backgroundSkin);
			}
			this._backgroundSkin = value;
			if(this._backgroundSkin && this._backgroundSkin.parent != this)
			{
				this._backgroundSkin.visible = false;
				super.addChildAt(this._backgroundSkin, 0);
			}
			this.invalidate(INVALIDATION_FLAG_STYLES);
		}
		
		/**
		 * @private
		 */
		protected var _backgroundDisabledSkin:DisplayObject;
		
		/**
		 * A background to display when the list is disabled.
		 */
		public function get backgroundDisabledSkin():DisplayObject
		{
			return this._backgroundDisabledSkin;
		}
		
		/**
		 * @private
		 */
		public function set backgroundDisabledSkin(value:DisplayObject):void
		{
			if(this._backgroundDisabledSkin == value)
			{
				return;
			}
			
			if(this._backgroundDisabledSkin && this._backgroundDisabledSkin != this._backgroundSkin)
			{
				this.removeChild(this._backgroundDisabledSkin);
			}
			this._backgroundDisabledSkin = value;
			if(this._backgroundDisabledSkin && this._backgroundDisabledSkin.parent != this)
			{
				this._backgroundDisabledSkin.visible = false;
				super.addChildAt(this._backgroundDisabledSkin, 0);
			}
			this.invalidate(INVALIDATION_FLAG_STYLES);
		}
		
		override protected function draw():void
		{
			const stylesInvalid:Boolean = this.isInvalid(INVALIDATION_FLAG_STYLES);
			var sizeInvalid:Boolean = this.isInvalid(INVALIDATION_FLAG_SIZE);
			var layoutInvalid:Boolean = this.isInvalid(INVALIDATION_FLAG_LAYOUT);
			
			if(sizeInvalid || stylesInvalid || layoutInvalid)
			{
				this.refreshBackgroundSkin();
				updateLayout();
			}
			
			sizeInvalid = this.autoSizeIfNeeded() || sizeInvalid;
			
			if(sizeInvalid || stylesInvalid)
			{
				scaleSkin();
			}
			
			if(this._autoFlatten)
			{
				this.unflatten();
				this.flatten();
			}
		}		
		
		protected function autoSizeIfNeeded():Boolean
		{
			const needsWidth:Boolean = isNaN(this.explicitWidth);
			const needsHeight:Boolean = isNaN(this.explicitHeight);
			if(!needsWidth && !needsHeight)
			{
				return false;
			}
			
			var newRect:Rectangle = new Rectangle();
			
			measure(newRect);
			
			var newWidth:Number = this.explicitWidth;
			var newHeight:Number = this.explicitHeight;			
			if(needsWidth)
			{
				newWidth = newRect.width;
			}
			if(needsHeight)
			{
				newHeight = newRect.height;
			}
			return this.setSizeInternal(newWidth, newHeight, false);
		}		
		
		protected function measure(resultWH:Rectangle):void{
			var w:Number = 0;
			var h:Number = 0;
			var i:int = this.numChildren-1;
			for(;i>=0;i--){
				var cc:DisplayObject = this.getChildAt(i);
				if(cc is FeathersControl) FeathersControl(cc).validate();
				w = Math.max(w,cc.x+cc.width);
				h = Math.max(h,cc.y+cc.height);
			}
			resultWH.width = w;
			resultWH.height = h;
		}
		
		protected var _autoFlatten:Boolean = false;
		
		public function get autoFlatten():Boolean
		{
			return this._autoFlatten;
		}
		
		public function set autoFlatten(value:Boolean):void
		{
			if(this._autoFlatten == value)
			{
				return;
			}
			this._autoFlatten = value;
			this.unflatten();
			if(this._autoFlatten)
			{
				this.flatten();
			}
		}
		
		protected function refreshBackgroundSkin():void
		{
			this.currentBackgroundSkin = this._backgroundSkin;
			if(!this._isEnabled && this._backgroundDisabledSkin)
			{
				if(this._backgroundSkin)
				{
					this._backgroundSkin.visible = false;
				}
				this.currentBackgroundSkin = this._backgroundDisabledSkin;
			}
			else if(this._backgroundDisabledSkin)
			{
				this._backgroundDisabledSkin.visible = false;
			}
			
			if(this.currentBackgroundSkin)
			{
				this.currentBackgroundSkin.visible = true;
			}
		}
		
		protected function scaleSkin():void
		{
			if(this.currentBackgroundSkin)
			{
				this.currentBackgroundSkin.width = this.actualWidth - _paddingLeft - _paddingRight;
				this.currentBackgroundSkin.height = this.actualHeight - _paddingBottom - _paddingTop;
				this.currentBackgroundSkin.x = _paddingLeft;
				this.currentBackgroundSkin.y = _paddingTop;
			}
		}
		
		private var _paddingLeft:int;
		public function set paddingLeft(value:int):void {
			_paddingLeft = value;
			this.invalidate(INVALIDATION_FLAG_STYLES);
		}
		public function get paddingLeft():int {
			return _paddingLeft;
		}
		
		private var _paddingRight:int;
		public function set paddingRight(value:int):void {
			_paddingRight = value;
			this.invalidate(INVALIDATION_FLAG_STYLES);
		}
		public function get paddingRight():int {
			return _paddingRight;
		}
		
		private var _paddingTop:int;
		public function set paddingTop(value:int):void {
			_paddingTop = value;
			this.invalidate(INVALIDATION_FLAG_STYLES);
		}
		public function get paddingTop():int {
			return _paddingTop;
		}
		
		private var _paddingBottom:int;
		public function set paddingBottom(value:int):void {
			_paddingBottom = value;
			this.invalidate(INVALIDATION_FLAG_STYLES);
		}
		public function get paddingBottom():int {
			return _paddingBottom;
		}
		
		protected function updateLayout():void
		{
			
		}
		
		public override function dispose():void {
			this.backgroundSkin = null;
			this.backgroundDisabledSkin = null;
			this.currentBackgroundSkin = null;
			super.dispose();
		}
	}
}