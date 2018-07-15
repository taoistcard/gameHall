local ExchangeCouponLayer = class("ExchangeCouponLayer", require("show.popView_Hall.baseWindow"))

function ExchangeCouponLayer:ctor()
    self.super.ctor(self, "ExchangeCouponLayer");

    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    self:setNodeEventEnabled(true)
    self.hisList = {}
    self.lastHisCount = 0
    self.curHisPage = 1
    self.isAllHisLoad = false

	self:createUI()

end

function ExchangeCouponLayer:onEnter()
    self.bindIds = {}
    self.bindIds[#self.bindIds + 1] = BindTool.bind(AccountInfo, "present", handler(self, self.refreshCoupon))

    self:refreshTab1()
    
    for i=1,9 do
        -- table.insert(self.hisList, "XXXXX 某年某日 兑换" .. 5000*i .. "金币") 
    end
end

function ExchangeCouponLayer:onExit()
    for _, bindid in ipairs(self.bindIds) do
        BindTool.unbind(bindid)
    end
end

function ExchangeCouponLayer:createUI()

    local bgSize = self.bgSize
    local bgSprite = self.bgSprite

    --title
    local titleSprite = cc.Sprite:create("exchange/title.png");
    titleSprite:setPosition(cc.p(bgSize.width/2, bgSize.height-20));
    bgSprite:addChild(titleSprite,2);

    --兑换金币    
    local panel = ccui.ImageView:create("exchange/bg1.png");    
    panel:setPosition(cc.p(bgSize.width / 2, bgSize.height - 150));
    bgSprite:addChild(panel);

    self.container1 = display.newNode():addTo(panel,1)

    --兑换纪录
    local button = ccui.Button:create("exchange/btn_his.png","exchange/btn_his.png","exchange/btn_his.png");
    button:setScale9Enabled(false);
    -- button:addTo(bgSprite,1)
    button:setPosition(cc.p(bgSize.width, bgSize.height * 0.58));
    button:setPressedActionEnabled(true);
    button:addTouchEventListener(
        function ( sender,eventType )
            if eventType == ccui.TouchEventType.ended then
                self:onClickHis()
            end
        end
    )

    local image = ccui.ImageView:create("exchange/btn_gotoexchange.png"):addTo(bgSprite,2):align(display.CENTER, bgSize.width/2, 145)
    image:setTouchEnabled(true)
    image:addTouchEventListener(function(sender,eventType)
            if eventType == ccui.TouchEventType.began then
                sender:scale(1.01)
            elseif eventType == ccui.TouchEventType.ended then
                sender:scale(1.0)
                self:onClickWebExchange()
                Click();

            elseif eventType == ccui.TouchEventType.canceled then
                sender:scale(1.0)
            end
        end
    )

end

function ExchangeCouponLayer:onClickHis()

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
    maskLayer:addTouchEventListener(function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                maskLayer:removeSelf()
            end
        end
    )

    --bgSprite
    local bgSprite = display.newSprite("exchange/bg.png"):pos(winSize.width/2, winSize.height/2)
    bgSprite:addTo(maskLayer)

    self.tip = ccui.Text:create("暂无兑换记录！",FONT_PTY_TEXT,30)
    self.tip:setPosition(bgSprite:getContentSize().width/2, bgSprite:getContentSize().height/2+20)
    self.tip:setColor(cc.c3b(0xfa, 0xff, 0xff))
    bgSprite:addChild(self.tip)
    -- self.tip:hide()

    self.listView = ccui.ListView:create()
    -- set list view ex direction
    self.listView:setDirection(ccui.ScrollViewDir.vertical)
    self.listView:setBounceEnabled(true)
    self.listView:setContentSize(cc.size(314,183))
    self.listView:setPosition(50, 40)
    -- self.listView:setBackGroundColorType(1)
    -- self.listView:setBackGroundColor(cc.c3b(0,123,0))
    self.listView:addTo(bgSprite,1)
    local function listViewEvent(sender, eventType)
        -- 事件类型为点击结束
        print("eventType=",eventType)
        if eventType == ccui.ListViewEventType.ONSELECTEDITEM_END then
            print("select child index = ",sender:getCurSelectedIndex())
        end
    end

    -- 设置ListView的监听事件
    self.listView:addEventListener(listViewEvent)

    -- 滚动事件方法回调  
    local function scrollViewEvent(sender, eventType)  
        -- 滚动到底部  
        if eventType == ccui.ScrollviewEventType.scrollToBottom then
        
        elseif eventType == ccui.ScrollviewEventType.scrolling then
            local percent = self:getCurPercent()
            -- print("SCROLLVIEW_EVENT_SCROLLING", percent)

        elseif eventType == ccui.ScrollviewEventType.bounceBottom then
            print("请求更新")
            if self.isAllHisLoad == false then
                self.curHisPage = self.curHisPage +1
                --查询兑换历史纪录
                
            end
        end
    end
    self.listView:addScrollViewEventListener(scrollViewEvent)

    --查询兑换历史纪录
    
    self:refreshTab2()
end

function ExchangeCouponLayer:refreshTab1()

    self.container1:removeAllChildren()

    local exchange = ccui.Button:create("exchange/btn_exchange.png","exchange/btn_exchange.png","exchange/btn_exchange1.png");
    exchange:setPosition(cc.p(530, 100));
    exchange:addTo(self.container1,1)
    exchange:setPressedActionEnabled(true);
    exchange:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:onClickExchange()
            end
        end
    )

    local dd = 180
    display.newSprite("exchange/bg2.png"):addTo(self.container1,1):align(display.CENTER, 150, 110)
    display.newSprite("exchange/item2.png"):addTo(self.container1,1):align(display.CENTER, 150, 110)
    display.newSprite("exchange/item12.png"):addTo(self.container1,1):align(display.CENTER, 250, 110)
    display.newSprite("exchange/bg2.png"):addTo(self.container1,1):align(display.CENTER, 350, 110)
    display.newSprite("exchange/item1.png"):addTo(self.container1,1):align(display.CENTER, 350, 110)

    --礼券数量
    local couponNum = AccountInfo.present

    local couponTxt = ccui.Text:create(FormatNumToString(couponNum) .. "金币",FONT_PTY_TEXT,22)
    couponTxt:setFontSize(26)
    couponTxt:setAnchorPoint(cc.p(0,0.5))
    couponTxt:setColor(cc.c4b(0xfe, 0xff, 0x79,255))
    couponTxt:enableOutline(cc.c4b(0x3d,0x1b,0x02,255), 2)
    couponTxt:addTo(self.container1,1):align(display.CENTER, 350, 40)

    --金币数量
    local goldTxt = ccui.Text:create(FormatNumToString(couponNum) .. "张",FONT_PTY_TEXT,22)
    goldTxt:setFontSize(26)
    goldTxt:setAnchorPoint(cc.p(0,0.5))
    goldTxt:setColor(cc.c4b(0xfe, 0xff, 0x79,255))
    goldTxt:enableOutline(cc.c4b(0x3d,0x1b,0x02,255), 2)
    goldTxt:addTo(self.container1,1):align(display.CENTER, 150, 40)


    if couponNum <= 0 then
        exchange:setEnabled(false)
        exchange:setBright(false)
    end
end

function ExchangeCouponLayer:refreshTab2()
    print("ExchangeCouponLayer:refreshTab2")

    if #self.hisList > 0 then
        self.tip:hide()
    else
        self.tip:show()
    end

    for i=self.lastHisCount+1, #self.hisList do
        local height = 0
        local custom_itemY = 35
        local custom_itemX = 225
        local custom_item = ccui.Layout:create()
        custom_item:setTouchEnabled(true)
        custom_item:setContentSize(cc.size(custom_itemX,custom_itemY))
        custom_item:setAnchorPoint(cc.p(0,1))

        local item = ccui.Text:create(self.hisList[i],"",22)
        item:setColor(cc.c4b(0xff, 0xff, 0xff, 255))
        item:enableOutline(cc.c4b(0xff, 0xff, 0xff, 255), 2)
        item:setAnchorPoint(cc.p(0,0))
        custom_item:addChild(item)
    
        self.listView:pushBackCustomItem(custom_item)    
    end

    self.listView:doLayout()

end

function ExchangeCouponLayer:getCurPercent()
    local size = self.listView:getContentSize()
    local sizeContainer = self.listView:getInnerContainerSize()

    local distance = sizeContainer.height - size.height
    if distance <= 0 then
        return 1
    end

    local posY = self.listView:getInnerContainer():getPositionY()
    
    return 1 - (0- posY)/distance

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
    self:refreshTab1()
end

function ExchangeCouponLayer:onClickWebExchange()
    local url = "http://mlive.19baba.com/interface/gamemarket/?token="..AccountInfo.sessionId.."&cate=98game&game_id=1038&channel_id=1"
    openPortraitWebView(url)
    -- openWebView(url)
end

return ExchangeCouponLayer