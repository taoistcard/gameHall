local KickUserAlertLayer = class("KickUserAlertLayer", function() return display.newLayer(); end )
function KickUserAlertLayer:ctor(tip,fun)
	self:createUI(tip,fun)
end
function KickUserAlertLayer:createUI(tip,fun)
    local displaySize = cc.size(display.width, display.height);
    local winSize = cc.Director:getInstance():getWinSize();

    -- 蒙板
    local maskLayer = ccui.ImageView:create("black.png");
    maskLayer:setScale9Enabled(true);
    maskLayer:setContentSize(cc.size(winSize.width, winSize.height));
    -- maskLayer:setAnchorPoint(cc.p(0,0))
    maskLayer:setPosition(cc.p(DESIGN_WIDTH/2, DESIGN_HEIGHT/2));
    maskLayer:setTouchEnabled(true);
    maskLayer:addTo(self);


    local containerLayer = ccui.Layout:create()
    -- containerLayer:setAnchorPoint(cc.p(0.5,0.5))
    containerLayer:setContentSize(cc.size(1136,640))
    -- containerLayer:setPosition(-1136/2+724/2, -640/2+514/2)
    -- containerLayer:setBackGroundColorType(1)
    -- containerLayer:setBackGroundColor(cc.c3b(100,123,100))
    self.containerLayer = containerLayer
    self:addChild(containerLayer)

    local shopBg = ccui.ImageView:create("shopBg.png")
    shopBg:setPosition(611,306)
    shopBg:setScale9Enabled(true)
    shopBg:setContentSize(cc.size(610, 407));
    containerLayer:addChild(shopBg)

    local kuangBg = ccui.ImageView:create("kuangBg.png")
    kuangBg:setPosition(304,204)
    kuangBg:setScale9Enabled(true)
    kuangBg:setContentSize(cc.size(618, 412));
    shopBg:addChild(kuangBg)


   
    local info = ccui.Text:create("",FONT_PTY_TEXT,24)
    info:setTextColor(cc.c4b(201,179,236,255))
    info:enableOutline(cc.c4b(42,18,60,255), 2)
    info:setPosition(cc.p(310,192))
    info:setAnchorPoint(cc.p(0.5,0.5))
    info:setString(tip)
    info:setTextAreaSize(cc.size(400,250))
    info:ignoreContentAdaptWithSize(false)
    info:setTextHorizontalAlignment(0)
    info:setTextVerticalAlignment(0)
    shopBg:addChild(info)
    -- self.info = info
    -- self.info:setString("1.修改优惠充值字体\n2.埋入 切换内网功能\n3.开启看牌的命名\n4.埋入test渠道热更")



    local sure = ccui.Button:create("common/common_button3.png");
    sure:setScale9Enabled(true)
    sure:setContentSize(cc.size(163*1.12, 72))
    sure:setPosition(cc.p(311,52));
    sure:setTitleFontName(FONT_ART_TEXT);
    sure:setTitleText("确认");
    sure:setTitleColor(cc.c3b(255,255,255));
    sure:setTitleFontSize(28);
    sure:getTitleRenderer():enableOutline(COLOR_BTN_BLUE,2)
    shopBg:addChild(sure);
    sure:setPressedActionEnabled(true);
    sure:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:removeFromParent();
                fun()
            end
        end
    )

end
return KickUserAlertLayer