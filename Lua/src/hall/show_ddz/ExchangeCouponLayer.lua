local ExchangeCouponLayer = class("ExchangeCouponLayer", function() return display.newLayer() end)

function ExchangeCouponLayer:ctor()
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
    self.bindIds[#self.bindIds + 1] = BindTool.bind(PayInfo, "getGiftScore", handler(self, self.eventVoucherExchange))

    self:refreshTab1()

    --查询兑换历史纪录
    -- UserService:sendQueryRecordVoucherExchange(self.curHisPage)

end

function ExchangeCouponLayer:onExit()
    for _, bindid in ipairs(self.bindIds) do
        BindTool.unbind(bindid)
    end
end

function ExchangeCouponLayer:createUI()
	local displaySize = cc.size(display.width, display.height);
    local winSize = cc.Director:getInstance():getWinSize();
    -- 蒙板
    local maskLayer = ccui.ImageView:create("black.png");
    maskLayer:setScale9Enabled(true);
    maskLayer:setContentSize(cc.size(winSize.width, winSize.height));
    maskLayer:setPosition(cc.p(displaySize.width / 2, displaySize.height / 2));
    maskLayer:setTouchEnabled(true);
    maskLayer:addTo(self);
   
    local bgSprite = display.newSprite("hallScene/exchange/bg.png"):pos(winSize.width/2, winSize.height/2-30)
    bgSprite:addTo(maskLayer)

    local bgSize = bgSprite:getContentSize()

    --title
    local titleSprite = cc.Sprite:create("common/hall_title_bg.png");
    titleSprite:setPosition(cc.p(bgSize.width/2, bgSize.height));
    bgSprite:addChild(titleSprite,2);

    local pcWord = ccui.ImageView:create("hallScene/exchange/title.png");
    pcWord:setPosition(214, 55);
    titleSprite:addChild(pcWord);

    --兑换金币    
    local panel = ccui.ImageView:create("hall_frame.png");
    panel:setScale9Enabled(true);
    panel:setContentSize(cc.size(820, 175));
    panel:setPosition(cc.p(bgSize.width / 2, bgSize.height - 120));
    bgSprite:addChild(panel);

    self.container1 = display.newNode():addTo(panel,1)

    --兑换纪录
    local button = ccui.Button:create("hallScene/exchange/btn_his.png","hallScene/exchange/btn_his.png","hallScene/exchange/btn_his.png");
    button:setScale9Enabled(false);
    button:addTo(bgSprite,1)
    button:setPosition(cc.p(bgSize.width-10, bgSize.height * 0.65));
    button:setPressedActionEnabled(true);
    button:addTouchEventListener(
        function ( sender,eventType )
            if eventType == ccui.TouchEventType.ended then
                self:onClickHis()
            end
        end
        )
    button:hide()

    local image = ccui.ImageView:create("hallScene/exchange/image1.png"):addTo(bgSprite,2):align(display.CENTER, bgSize.width/2, 145)
    local light = display.newSprite("hallScene/exchange/image2.png"):addTo(image):align(display.CENTER_TOP, 426, 240)
    light:runAction(cc.RepeatForever:create(cc.Sequence:create(
            cc.FadeIn:create(2),
            cc.DelayTime:create(3.0),
            cc.FadeOut:create(1),
            cc.DelayTime:create(1.0)
        )))
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
        end)


    --banner
    display.newSprite("hallScene/exchange/01.png"):addTo(bgSprite,2):align(display.CENTER, bgSize.width, 50)
    display.newSprite("hallScene/exchange/02.png"):addTo(bgSprite,2):align(display.CENTER, 0, 75)


    --关闭按钮
    local exit = ccui.Button:create("common/hall_close.png");
    exit:setPosition(cc.p(bgSize.width-10, bgSize.height-10));
    exit:addTo(bgSprite,1)
    exit:setPressedActionEnabled(true);
    exit:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:close();
            end
        end
    )
end

function ExchangeCouponLayer:onClickHis()

    local displaySize = cc.size(display.width, display.height);
    local winSize = cc.Director:getInstance():getWinSize();
    -- 蒙板
    local maskLayer = ccui.ImageView:create("black.png");
    maskLayer:setScale9Enabled(true);
    maskLayer:setContentSize(cc.size(winSize.width, winSize.height));
    maskLayer:setPosition(cc.p(displaySize.width / 2, displaySize.height / 2));
    maskLayer:setTouchEnabled(true);
    maskLayer:addTo(self);

    --bgSprite
    local bgSprite = display.newSprite("hallScene/personalCenter/underWriteBg.png"):pos(winSize.width/2, winSize.height/2-30)
    bgSprite:addTo(maskLayer)


    self.listView = ccui.ListView:create()
    -- set list view ex direction
    self.listView:setDirection(ccui.ScrollViewDir.vertical)
    self.listView:setBounceEnabled(true)
    self.listView:setContentSize(cc.size(400,215))
    self.listView:setPosition(100, 25)
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
            print("SCROLLVIEW_EVENT_SCROLLING", percent)

            self.exchangeprogress:setValue(percent*100)

        elseif eventType == ccui.ScrollviewEventType.bounceBottom then
            print("请求更新")
            if self.isAllHisLoad == false then
                self.curHisPage = self.curHisPage +1
                --查询兑换历史纪录
                -- UserService:sendQueryRecordVoucherExchange(self.curHisPage)
            end
        end
    end
    self.listView:addScrollViewEventListener(scrollViewEvent)

    --slider
    local exchangeprogress = cc.ControlSlider:create("hall/hallScene/exchange/sliderBg.png","hall/hallScene/exchange/sliderBg.png","hall/hallScene/exchange/slider.png")
    bgSprite:addChild(exchangeprogress)
    exchangeprogress:rotation(90)
    exchangeprogress:setPosition(520, 135)
    exchangeprogress:setMinimumValue(0);
    exchangeprogress:setMaximumValue(100);
    exchangeprogress:registerControlEventHandler(
        function ( sender )
            -- self:exchangeprogressHandler(exchangeprogress);
        end,
        cc.CONTROL_EVENTTYPE_VALUE_CHANGED
        )
    exchangeprogress:setEnabled(false)
    self.exchangeprogress = exchangeprogress;


    --关闭按钮
    local exit = ccui.Button:create("common/hall_close.png");
    exit:setPosition(cc.p(560, 250));
    exit:addTo(bgSprite,1)
    exit:setPressedActionEnabled(true);
    exit:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                maskLayer:removeSelf()
            end
        end
    )

    --查询兑换历史纪录
    -- UserService:sendQueryRecordVoucherExchange(self.curHisPage)
end

function ExchangeCouponLayer:refreshTab1()

    self.container1:removeAllChildren()

    local exchange = ccui.Button:create("hallScene/exchange/btn_exchange.png","hallScene/exchange/btn_exchange.png","hallScene/exchange/btn_exchange1.png");
    exchange:setPosition(cc.p(650, 80));
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
    display.newSprite("hallScene/exchange/item11.png"):addTo(self.container1,1):align(display.CENTER, 160, 90)
    display.newSprite("hallScene/exchange/item12.png"):addTo(self.container1,1):align(display.CENTER, 297, 90)
    display.newSprite("hallScene/exchange/item13.png"):addTo(self.container1,1):align(display.CENTER, 440, 90)

    --礼券数量
    local couponNum = DataManager:getMyUserInfo().present

    local couponTxt = ccui.Text:create(FormatNumToString(couponNum) .. "张","fonts/HKBDTW12.TTF",24)
    couponTxt:setFontSize(26)
    couponTxt:setAnchorPoint(cc.p(0,0.5))
    couponTxt:setColor(cc.c4b(0xfe, 0xff, 0x79,255))
    couponTxt:enableOutline(cc.c4b(0x3d,0x1b,0x02,255), 2)
    couponTxt:addTo(self.container1,1):align(display.CENTER, 160, 40)

    --金币数量
    local goldTxt = ccui.Text:create(FormatNumToString(couponNum) .. "金币","fonts/HKBDTW12.TTF",24)
    goldTxt:setFontSize(26)
    goldTxt:setAnchorPoint(cc.p(0,0.5))
    goldTxt:setColor(cc.c4b(0xfe, 0xff, 0x79,255))
    goldTxt:enableOutline(cc.c4b(0x3d,0x1b,0x02,255), 2)
    goldTxt:addTo(self.container1,1):align(display.CENTER, 440, 40)


    if couponNum <= 0 then
        exchange:setEnabled(false)
        exchange:setBright(false)
    end
end

function ExchangeCouponLayer:refreshTab2()
    print("ExchangeCouponLayer:refreshTab2")

    for i=self.lastHisCount+1, #self.hisList do
        local height = 0
        local custom_itemY = 35
        local custom_itemX = 225
        local custom_item = ccui.Layout:create()
        custom_item:setTouchEnabled(true)
        custom_item:setContentSize(cc.size(custom_itemX,custom_itemY))
        custom_item:setAnchorPoint(cc.p(0,1))

        local item = ccui.Text:create(self.hisList[i],"",24)
        item:setColor(cc.c4b(0x81, 0x42, 0x12, 255))
        item:enableOutline(cc.c4b(0x81, 0x42, 0x12, 255), 2)
        item:setAnchorPoint(cc.p(0,0))
        custom_item:addChild(item)
    
        self.listView:pushBackCustomItem(custom_item)    
    end

    self.listView:doLayout()

    self.exchangeprogress:setValue(0)
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
    --礼券数量
    local couponNum = AccountInfo.present
    if couponNum <=0 then
        Hall.showTips("没有礼券，不可兑换！")
    else
        if couponNum < 500000 then
            self.canExchange = couponNum
        else
            self.canExchange = 500000
        end
        PayInfo:sendGetGiftScoreRequest(self.canExchange)
    end
end

function ExchangeCouponLayer:refreshCoupon()
    self:refreshTab1()
end

function ExchangeCouponLayer:eventQueryRecorderExchange(event)
    print("ExchangeCouponLayer:eventQueryRecorderExchange")
    --[[ 
    //玩家礼券兑换记录查询结果数组结构
    message DBO_GR_VoucherExchangeRecord
    {
        required int64 dwExchangeValue      = 1;        //兑换到的金币
        required string dtExchangeDate      = 2;        //兑换时间
    }
    // 玩家礼券兑换记录查询结果
    message DBO_GR_QueryRecordVoucherExchange_Pro
    {
        required int32 dwUserID                 = 1;        //用户ID 
        required int32 nResultCode              = 2;
        repeated DBO_GR_VoucherExchangeRecord RecordList    = 3;

    }
    ]]
    local pData = protocol.hall.business_pb.DBO_GR_QueryRecordVoucherExchange_Pro()
    pData:ParseFromString(event.data)

    self.lastHisCount = #self.hisList
    for _,v in ipairs(pData.RecordList) do
        table.insert(self.hisList, v.dtExchangeDate .. "兑换" .. v.dwExchangeValue .. "金币") 
    end
    if self.lastHisCount == #self.hisList then
        self.isAllHisLoad = true
    end

    self:refreshTab2()
end

function ExchangeCouponLayer:eventVoucherExchange(event)
    --[[
    // 玩家礼券兑换金币 结果
    message DBO_GR_VoucherExchange_Pro
    {
        required int32 dwUserID         = 1;        //用户ID 
        required int32 nResultCode      = 2;
        required int64 dwExchangeValue      = 3;        //兑换到的金币
        required string szDescribe      = 4;        //文字描述
    }
    ]]
    local pData = event.value
    print("eventVoucherExchange",pData.code, pData.score, pData.gift )

    Hall.showTips("兑换" .. self.canExchange .. "金币成功")    
    self:refreshTab1()


end

function ExchangeCouponLayer:onClickWebExchange()
    print("ExchangeCouponLayer:onClickWebExchange!!")
    -- FreeChip("http://112.124.38.85:8083/hall/present.php")
    local url = "http://mlive.19baba.com/interface/gamemarket/?token="..AccountInfo.sessionId.."&cate=98game&game_id=1005&channel_id=1"
    openPortraitWebView(url)
end

return ExchangeCouponLayer