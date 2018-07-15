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
    maskLayer:setContentSize(cc.size(winSize.width, winSize.height));
    maskLayer:setPosition(cc.p(displaySize.width / 2, displaySize.height / 2));
    maskLayer:setTouchEnabled(true);
    maskLayer:addTo(self);

    local bgSprite = ccui.ImageView:create("hallScene/personalCenter/underWriteBg.png");
    bgSprite:setScale9Enabled(true);
    bgSprite:setContentSize(cc.size(538, 231));
    bgSprite:setPosition(cc.p(displaySize.width / 2, displaySize.height / 2));
    self:addChild(bgSprite)

	--photo
    local shadow = ccui.ImageView:create("hallScene/personalCenter/shadow.png")
    shadow:setPosition(149, 91)
    bgSprite:addChild(shadow)
    local photobutton = ccui.Button:create("hallScene/personalCenter/photoNormal.png","hallScene/personalCenter/photoNormal.png");
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
    local shadow = ccui.ImageView:create("hallScene/personalCenter/shadow.png")
    shadow:setPosition(389, 91)
    bgSprite:addChild(shadow)
    local camerabutton = ccui.Button:create("hallScene/personalCenter/cameraNormal.png","hallScene/personalCenter/cameraNormal.png");
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

    -- local photo = ccui.ImageView:create("hallScene/personalCenter/photo.png")
    -- bgSprite:addChild(photo)
    -- photo:setPosition(133,46)
    local photo = ccui.Text:create("手机相册", "fonts/HKBDTW12.TTF", 26);
    photo:setColor(cc.c3b(109,58,24));
    photo:setPosition(cc.p(133,46));
    bgSprite:addChild(photo)

    -- local camera = ccui.ImageView:create("hallScene/personalCenter/camera.png")
    -- bgSprite:addChild(camera)
    -- camera:setPosition(389,46)
    local photo = ccui.Text:create("拍照", "fonts/HKBDTW12.TTF", 26);
    photo:setColor(cc.c3b(109,58,24));
    photo:setPosition(cc.p(389,46));
    bgSprite:addChild(photo)

    local exit = ccui.Button:create("hall_close.png");
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