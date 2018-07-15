local CustomAvatarLayer = class("CustomAvatarLayer", function() return display.newLayer() end)

function CustomAvatarLayer:ctor()
	self:createUI()
end
function CustomAvatarLayer:createUI()
	local displaySize = cc.size(DESIGN_WIDTH, DESIGN_HEIGHT);
    local winSize = cc.Director:getInstance():getWinSize();
    -- 蒙板
    local maskLayer = ccui.ImageView:create("black.png");
    maskLayer:setScale9Enabled(true);
    maskLayer:setContentSize(cc.size(winSize.width, winSize.height));
    maskLayer:setPosition(cc.p(displaySize.width / 2, displaySize.height / 2));
    maskLayer:setTouchEnabled(true);
    maskLayer:addTo(self);

    local bgSprite = ccui.ImageView:create("common/pop_bg.png");
    bgSprite:setScale9Enabled(true);
    bgSprite:setContentSize(cc.size(538, 231));
    bgSprite:setPosition(cc.p(displaySize.width / 2, displaySize.height / 2));
    self:addChild(bgSprite)

	--photo
    local photobutton = ccui.Button:create("hall/personalCenter/photos_icon.png","hall/personalCenter/photos_icon.png");
    photobutton:addTo(bgSprite)
    photobutton:align(display.CENTER, 144, 133)
    photobutton:setScale9Enabled(false)
    -- photobutton:setTitleText("Photo");
    photobutton:setTitleColor(cc.c3b(0,0,0));
    photobutton:setTitleFontSize(30);
    photobutton:setPressedActionEnabled(false);
    photobutton:addTouchEventListener(
        function ( sender,eventType )
            if eventType == ccui.TouchEventType.ended then
                self:onClickPhoto()
            end
        end
        )

	--camera
    local camerabutton = ccui.Button:create("hall/personalCenter/camera_icon.png","hall/personalCenter/camera_icon.png");
    camerabutton:addTo(bgSprite)
    camerabutton:align(display.CENTER, 393, 133)
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

    --文字

    -- local photo = ccui.ImageView:create("customAvatar/photo.png")
    -- bgSprite:addChild(photo)
    -- photo:setPosition(133,46)

    -- local camera = ccui.ImageView:create("customAvatar/camera.png")
    -- bgSprite:addChild(camera)
    -- camera:setPosition(389,46)


    local exit = ccui.Button:create("common/close.png");
    exit:setPosition(cc.p(518,211));
    bgSprite:addChild(exit);
    exit:setPressedActionEnabled(true);
    exit:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:onClickCancel();
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

function CustomAvatarLayer:onClickCancel()
	self:removeFromParent()
end
return CustomAvatarLayer