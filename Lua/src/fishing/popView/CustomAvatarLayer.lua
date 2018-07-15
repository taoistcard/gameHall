local CustomAvatarLayer = class("CustomAvatarLayer", function() return display.newLayer() end)

function CustomAvatarLayer:ctor()
	self:createUI()
end

function CustomAvatarLayer:createUI()
	local displaySize = cc.size(display.width, display.height);
    local winSize = cc.Director:getInstance():getWinSize();
    -- 蒙板
    local maskLayer = ccui.ImageView:create("black.png");
    maskLayer:setScale9Enabled(true);
    maskLayer:setContentSize(winSize);
    maskLayer:setPosition(cc.p(winSize.width / 2, winSize.height / 2));
    maskLayer:setTouchEnabled(true);
    maskLayer:addTo(self);
    maskLayer:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                package.loaded["popView.CustomAvatarLayer"] = nil
                self:removeFromParent()
            end
        end
    )

    local bgSprite = ccui.ImageView:create("common/ty-dikuang.png");
    bgSprite:setScale(0.5)
    bgSprite:setPosition(cc.p(winSize.width / 2, winSize.height / 2));
    self:addChild(bgSprite)

	--photo
    local photobutton = ccui.Button:create("userCenter/btn_photo.png","userCenter/btn_photo.png");
    photobutton:addTo(bgSprite)
    photobutton:setScale(2)
    photobutton:align(display.CENTER, 200, 250)
    photobutton:setScale9Enabled(false)
    photobutton:setPressedActionEnabled(false);
    photobutton:addTouchEventListener(
        function ( sender,eventType )
            if eventType == ccui.TouchEventType.ended then
                self:onClickPhoto()
            end
        end
        )

	--camera
    local camerabutton = ccui.Button:create("userCenter/btn_camera.png","userCenter/btn_camera.png");
    camerabutton:addTo(bgSprite)
    camerabutton:setScale(2)
    camerabutton:align(display.CENTER, 510, 255)
    camerabutton:setScale9Enabled(false)
    -- camerabutton:setTitleText("camera");
    camerabutton:setTitleColor(cc.c3b(0,0,0));
    camerabutton:setTitleFontSize(30);
    camerabutton:setPressedActionEnabled(false);
    camerabutton:addTouchEventListener(
        function ( sender,eventType )
            if eventType == ccui.TouchEventType.ended then
                self:onClickCamera()
            end
        end
    )

    self:setLocalZOrder(3)
end
function CustomAvatarLayer:onClickPhoto()
	self:removeFromParent()
    PlatformOpenPhoto(0)
end

function CustomAvatarLayer:onClickCamera()
	self:removeFromParent()
    PlatformOpenPhoto(1)
end

return CustomAvatarLayer