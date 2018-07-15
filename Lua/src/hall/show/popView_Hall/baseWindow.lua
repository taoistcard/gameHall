local BaseWindow = class( "BaseWindow", function() return display.newLayer(); end )

function BaseWindow:createBaseWindow(mode)

    local winSize = cc.Director:getInstance():getWinSize();
    local container = display.newLayer();
    self:addChild(container);

    local center = cc.p(winSize.width/2,winSize.height/2);
    local cx = center.x;
    local cy = center.y;

    local bgSprite = display.newSprite("common/ty-dikuang.png", cx, cy);
    container:addChild(bgSprite);

    self.bgSize = bgSprite:getContentSize()
    local bgRect = bgSprite:getBoundingBox()
    self.bgSprite = display.newNode():addTo(container,1):pos(bgRect.x, bgRect.y)

    local frameX = cx
    local frameY = cy
    local extra = 0--适配帐号登陆框的大小

    if mode == nil then
        mode = 1
    end

    local file_index = mode

    if mode == 1 then
        frameY = cy
    elseif mode ==2 then
        frameX = cx +74
    elseif mode == 3 then
        frameY = cy + 50
    elseif mode == 4 then--适配帐号登陆框的大小
        frameY = cy + 50
        extra = 40
    elseif mode == 5 or mode == 6 then
        extra = 50
        file_index = 1
    end

    --内框
    if mode ~= "ExchangeCouponLayer" then
        self.frame = display.newSprite("common/ty-nk"..file_index..".png", frameX, frameY)
        container:addChild(self.frame);
    end

    local leftIcon = display.newSprite("common/ty_icon_left.png", cx-120, cy+245-extra)
    container:addChild(leftIcon);
    local rightIcon = display.newSprite("common/ty_icon_right.png", cx+120, cy+260-extra)
    container:addChild(rightIcon);
    local bottomIcon = display.newSprite("common/ty_icon_bottom.png", cx+332-extra, cy-135+extra)
    container:addChild(bottomIcon);
    local haimaIcon = display.newSprite("common/ty_hai_ma.png", cx-350+extra, cy-160+extra)
    container:addChild(haimaIcon);
    local paopaoIcon = display.newSprite("common/ty_pao_pao_1.png", cx-360+extra, cy+200-extra)
    container:addChild(paopaoIcon);

    local exit = ccui.Button:create("common/ty_close.png");
    container:addChild(exit);
    exit:setPosition(cc.p(cx+330-extra,cy+230-extra));
    exit:onClick(function()self:removeFromParent();end);

    self.contentNode = display.newLayer()
    container:addChild(self.contentNode)
    if mode == 1 or mode == 3 or mode == 2 then
        self.contentNode:setContentSize(cc.size(724, 514))
        self.contentNode:ignoreAnchorPointForPosition(false)
        self.contentNode:setAnchorPoint(cc.p(0.5,0.5))
        self.contentNode:setPosition(cx, cy)
    end
    --适配帐号登陆框的大小
    if mode == 4 or mode == 5 or mode == 6 then
        bgSprite:setScaleX(0.84)
        bgSprite:setScaleY(0.8)
        self.frame:setScaleX(0.84)
        self.frame:setScaleY(0.6)
    end
    --vip说明界面
    if mode == 5 then
        self.frame:setPositionY(self.frame:getPositionY()+10)
        bottomIcon:hide()
        haimaIcon:hide()
        paopaoIcon:hide()
    end
    --捕鱼游戏界面中获得金币
    if mode == 6 then
        self.frame:setScaleY(0.54)
        self.frame:setPositionY(self.frame:getPositionY()+16)
        bottomIcon:hide()
        haimaIcon:hide()
        paopaoIcon:hide()
    end
end

function BaseWindow:initMaskLayer(mode)

    local winSize = cc.Director:getInstance():getWinSize()
    -- 蒙板
    local maskLayer = ccui.ImageView:create()
    maskLayer:loadTexture("black.png")
    maskLayer:setOpacity(153)
    maskLayer:setScale9Enabled(true)
    maskLayer:setCapInsets(cc.rect(4,4,1,1))
    maskLayer:setContentSize(cc.size(winSize.width, winSize.height));
    maskLayer:setPosition(cc.p(winSize.width/2, winSize.height/2));
    maskLayer:setTouchEnabled(true);
    self:addChild(maskLayer)

    self.maskLayer = maskLayer

    self:setContentSize(winSize);
end

function BaseWindow:ctor(mode)

    self:initMaskLayer();
    self:createBaseWindow(mode);

end

function BaseWindow:setBlankMask()
    self.maskLayer:loadTexture("blank.png")
end

function BaseWindow:getContentNode()
    return self.contentNode
end

return BaseWindow;