local ExchangeCouponLayer = class("ExchangeCouponLayer", function() return display.newLayer() end )

function ExchangeCouponLayer:ctor()

    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    self:setNodeEventEnabled(true)
	self:createUI()

end

function ExchangeCouponLayer:onEnter()
    self.bindIds = {}
    self.bindIds[#self.bindIds + 1] = BindTool.bind(AccountInfo, "present", handler(self, self.refreshCoupon))
end

function ExchangeCouponLayer:onExit()
    for _, bindid in ipairs(self.bindIds) do
        BindTool.unbind(bindid)
    end
end

function ExchangeCouponLayer:createUI()

    local winSize = cc.Director:getInstance():getWinSize();

    self:setContentSize(cc.size(winSize.width, winSize.height));

    -- 蒙板
    local maskLayer = ccui.ImageView:create("black.png");
    maskLayer:setScale9Enabled(true);
    maskLayer:setContentSize(cc.size(winSize.width, winSize.height));
    maskLayer:setPosition(cc.p(winSize.width/2, winSize.height/2));
    maskLayer:setAnchorPoint(cc.p(0.5,0.5));
    maskLayer:ignoreAnchorPointForPosition(false);
    maskLayer:setTouchEnabled(true);
    maskLayer:addTo(self);

    local kuangBg = ccui.ImageView:create("common/kuangBg.png")
    kuangBg:setPosition(winSize.width/2, winSize.height/2)
    kuangBg:setScale9Enabled(true)
    kuangBg:setContentSize(cc.size(664, 434));
    self:addChild(kuangBg)

    local ex_bg = ccui.ImageView:create("exchange/exchange_bg.png");    
    ex_bg:setPosition(cc.p(winSize.width/2, winSize.height/2));
    self:addChild(ex_bg);

    --titleBg
    local titleBg = cc.Sprite:create("common/ty_title_bg.png");
    titleBg:setPosition(cc.p(winSize.width/2, winSize.height/2+234));
    self:addChild(titleBg);

    --title
    local titleSprite = cc.Sprite:create("exchange/title.png");
    titleSprite:setPosition(cc.p(winSize.width/2, winSize.height/2+240));
    self:addChild(titleSprite);

    local image = ccui.ImageView:create("exchange/btn_gotoexchange.png"):addTo(self,2):align(display.CENTER, winSize.width/2, winSize.height/2-90)
    image:setTouchEnabled(true)
    image:addTouchEventListener(function(sender,eventType)
            if eventType == ccui.TouchEventType.began then
                sender:scale(1.01)
            elseif eventType == ccui.TouchEventType.ended then
                sender:scale(1.0)
                self:onClickWebExchange()
            elseif eventType == ccui.TouchEventType.canceled then
                sender:scale(1.0)
            end
        end
    )

    self.container1 = display.newNode()
    self.container1:setPosition(cc.p(230, winSize.height/2))
    self:addChild(self.container1,10)

    local titleSprite = cc.Sprite:create("exchange/left_light.png");
    titleSprite:setPosition(cc.p(winSize.width/2-200, winSize.height/2+50));
    self:addChild(titleSprite);

    local titleSprite = cc.Sprite:create("exchange/right_light.png");
    titleSprite:setPosition(cc.p(winSize.width/2+150, winSize.height/2-10));
    self:addChild(titleSprite);

    local exit = ccui.Button:create("common/close2.png", "common/close2.png");
    self:addChild(exit);
    exit:setPosition(winSize.width/2+320, winSize.height/2+200);
    exit:onClick(function() self:removeFromParent(); end);

    local exchange = ccui.Button:create("exchange/btn_exchange.png","exchange/btn_exchange.png");
    exchange:setPosition(cc.p(winSize.width/2+190, winSize.height/2+110));
    exchange:addTo(self)
    exchange:onClick(
        function(sender,eventType)  
            self:onClickExchange()
        end
    )
    self.exchange = exchange

    --刷新内容
    display.newSprite("exchange/bg2.png"):addTo(self.container1,1):align(display.CENTER, 150, 110)
    display.newSprite("exchange/item2.png"):addTo(self.container1,1):align(display.CENTER, 150, 110)
    display.newSprite("exchange/item12.png"):addTo(self.container1,1):align(display.CENTER, 250, 110)
    display.newSprite("exchange/bg2.png"):addTo(self.container1,1):align(display.CENTER, 350, 110)
    display.newSprite("exchange/item1.png"):addTo(self.container1,1):align(display.CENTER, 350, 110)

    --礼券数量
    local couponNum = AccountInfo.present

    local couponTxt = ccui.Text:create(FormatNumToString(couponNum) .. "金币","",22)
    couponTxt:setFontSize(26)
    couponTxt:setAnchorPoint(cc.p(0,0.5))
    couponTxt:setColor(cc.c4b(255,255,255,255))
    couponTxt:enableOutline(cc.c4b(0x3d,0x1b,0x02,255), 2)
    couponTxt:addTo(self.container1,1):align(display.CENTER, 350, 40)
    self.couponTxt = couponTxt

    --金币数量
    local goldTxt = ccui.Text:create(FormatNumToString(couponNum) .. "张","",22)
    goldTxt:setFontSize(26)
    goldTxt:setAnchorPoint(cc.p(0,0.5))
    goldTxt:setColor(cc.c4b(255,255,255,255))
    goldTxt:enableOutline(cc.c4b(0x3d,0x1b,0x02,255), 2)
    goldTxt:addTo(self.container1,1):align(display.CENTER, 150, 40)
    self.goldTxt = goldTxt

    self:refreshView()

    local exchangeBtn = ccui.Button:create("common/ty_btn.png","common/ty_btn.png");
    exchangeBtn:setPosition(cc.p(winSize.width/2, winSize.height/2-206));
    exchangeBtn:addTo(self,10)
    exchangeBtn:onClick(
        function(sender,eventType)  
            self:onClickWebExchange()
        end
    )

    local btnTxt = ccui.Text:create("兑换实物","",22)
    btnTxt:setFontSize(30)
    btnTxt:setAnchorPoint(cc.p(0,0.5))
    btnTxt:setColor(cc.c4b(255,255,255,255))
    btnTxt:enableOutline(cc.c4b(0x3d,0x1b,0x02,255), 2)
    btnTxt:addTo(exchangeBtn):align(display.CENTER, exchangeBtn:getContentSize().width/2, exchangeBtn:getContentSize().height/2+4)

end

function ExchangeCouponLayer:refreshView()

    self.couponTxt:setString(FormatNumToString(AccountInfo.present).."金币")
    self.goldTxt:setString(FormatNumToString(AccountInfo.present).."张")

    if AccountInfo.present <= 0 then
        -- self.exchange:setEnabled(false)
        self.exchange:setColor(cc.c3b(150,150,150))
        -- self.exchange:setBright(false)
    end
end

function ExchangeCouponLayer:close()
    self:removeSelf();
end

function ExchangeCouponLayer:onClickExchange()
    --礼券数量
    local couponNum = AccountInfo.present
    if couponNum <=0 then
        Hall.showTips("没有礼券，不可兑换！")
    else
        local canExchange = 500000
        if couponNum < 500000 then
            canExchange = couponNum
        end
        PayInfo:sendGetGiftScoreRequest(canExchange)
    end
end

function ExchangeCouponLayer:refreshCoupon()
    self:refreshView()
end

function ExchangeCouponLayer:onClickWebExchange()
    local url = "http://mlive.19baba.com/interface/gamemarket/?token="..AccountInfo.sessionId.."&cate=98game&game_id=1032&channel_id=1"
    openPortraitWebView(url)
    -- openWebView(url)
end

return ExchangeCouponLayer