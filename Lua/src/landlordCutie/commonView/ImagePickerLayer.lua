--
-- Author: <zhaxun>
-- Date: 2015-07-28 20:20:49
--
local ImagePickerLayer = class("ImagePickerLayer", require("ui.CCModelView"))

function ImagePickerLayer:ctor()
	self.super.ctor(self)
    
    self:createUI()

end

function ImagePickerLayer:createUI()
	--bg
	local bg = display.newScale9Sprite("ImagePicker/bk.png", 130, 220, cc.size(640, 313))
					:addTo(self)
					:align(display.CENTER_TOP, display.cx, -100)

	bg:runAction(transition.sequence({
		cc.DelayTime:create(0.2),
		cc.MoveBy:create(0.2, cc.p(0,413))
		}))

	--photo
    local button = ccui.Button:create("ImagePicker/ButtonPhoto.png","ImagePicker/ButtonPhoto1.png");
    button:addTo(bg)
    button:align(display.CENTER, 320, 250)
    button:setScale9Enabled(false);
    --button:setContentSize(cc.size(261,67));
    --button:setCapInsets(cc.rect(130, 33, 1, 1));
    --button:setPosition(cc.p(840,56));
    --button:setTitleFontName(FONT_ART_BUTTON);
    button:setTitleText("Photo");
    button:setTitleColor(cc.c3b(0,0,0));
    button:setTitleFontSize(30);
    button:setPressedActionEnabled(false);
    --button:getTitleRenderer():enableOutline(COLOR_BTN_YELLOW,2);
    -- button:getTitleRenderer():enableShadow();
    button:addTouchEventListener(
        function ( sender,eventType )
            if eventType == ccui.TouchEventType.ended then
                self:onClickPhoto()
            end
        end
        )

	--camera
	button = ccui.Button:create("ImagePicker/ButtonCamera.png","ImagePicker/ButtonCamera1.png");
    button:addTo(bg)
    button:align(display.CENTER, 320, 170)
    button:setScale9Enabled(false);
    --button:setContentSize(cc.size(261,67));
    --button:setCapInsets(cc.rect(130, 33, 1, 1));
    --button:setPosition(cc.p(840,56));
    --button:setTitleFontName(FONT_ART_BUTTON);
    button:setTitleText("Camera");
    button:setTitleColor(cc.c3b(0,0,0));
    button:setTitleFontSize(30);
    button:setPressedActionEnabled(false);
    --button:getTitleRenderer():enableOutline(COLOR_BTN_YELLOW,2);
    -- button:getTitleRenderer():enableShadow();
    button:addTouchEventListener(
        function ( sender,eventType )
            if eventType == ccui.TouchEventType.ended then
                self:onClickCamera()
            end
        end
        )

	--cancel
  	button = ccui.Button:create("ImagePicker/ButtonCancel.png","ImagePicker/ButtonCancel1.png");
    button:addTo(bg)
    button:align(display.CENTER, 320, 70)
    button:setScale9Enabled(false);
    --button:setContentSize(cc.size(261,67));
    --button:setCapInsets(cc.rect(130, 33, 1, 1));
    --button:setPosition(cc.p(840,56));
    --button:setTitleFontName(FONT_ART_BUTTON);
    button:setTitleText("Cancel");
    button:setTitleColor(cc.c3b(0,0,0));
    button:setTitleFontSize(30);
    button:setPressedActionEnabled(false);
    --button:getTitleRenderer():enableOutline(COLOR_BTN_YELLOW,2);
    -- button:getTitleRenderer():enableShadow();
    button:addTouchEventListener(
        function ( sender,eventType )
            if eventType == ccui.TouchEventType.ended then
                self:onClickCancel()
            end
        end
        )
    
end

function ImagePickerLayer:onClickPhoto()
	self:removeFromParent()
    PlatformOpenPhoto(0)
end

function ImagePickerLayer:onClickCamera()
	self:removeFromParent()
    PlatformOpenPhoto(1)
end

function ImagePickerLayer:onClickCancel()
	self:removeFromParent()
end


return ImagePickerLayer