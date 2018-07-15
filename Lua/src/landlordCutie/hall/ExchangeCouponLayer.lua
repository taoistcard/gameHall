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
    self.handlerVOUCHEREXCHANGE = UserService:addEventListener(HallCenterEvent.EVENT_VOUCHEREXCHANGE,handler(self, self.eventVoucherExchange))
    self.handlerQUERYRECORDVOUCHEREXCHANGE = UserService:addEventListener(HallCenterEvent.EVENT_QUERYRECORDVOUCHEREXCHANGE,handler(self, self.eventQueryRecorderExchange))

    self:refreshTab2()
    self:onClickTab(1)
    
    --查询兑换历史纪录
    UserService:sendQueryRecordVoucherExchange(self.curHisPage)

end

function ExchangeCouponLayer:onExit()
    UserService:removeEventListener(self.handlerVOUCHEREXCHANGE)
    UserService:removeEventListener(self.handlerQUERYRECORDVOUCHEREXCHANGE)
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
   

    local page1 = display.newScale9Sprite("hall/exchange/bg.png", winSize.width/2-240, winSize.height/2, cc.size(210, 326), cc.rect(60,50,10,10))
    page1:addTo(maskLayer)
    
    local page2 = display.newScale9Sprite("hall/exchange/bg.png", winSize.width/2+110, winSize.height/2, cc.size(494, 326), cc.rect(60,50,10,10))
    page2:addTo(maskLayer)
    
    -- --title
    -- local scaleValue = 0.7
    -- display.newSprite("hall/exchange/top1.png"):addTo(bgSprite,1):align(display.CENTER, 297, -20):scale(scaleValue)
    
    -- --frame
    self.frame = display.newScale9Sprite("hall/exchange/frame.png", 244, 200, cc.size(437,215)):addTo(page2):align(display.CENTER_TOP, 244, 303)

    --兑换金币    
    local button = ccui.Button:create("hall/exchange/btn_exchange.png","hall/exchange/btn_exchange.png","hall/exchange/btn_exchange1.png");
    button:addTo(page1,1)
    button:setPosition(cc.p(100,205));
    button:setPressedActionEnabled(true);
    button:addTouchEventListener(
        function ( sender,eventType )
            if eventType == ccui.TouchEventType.ended then
                self:onClickTab(1)
            end
        end
        )
    self.tab1 = button

    self.container1 = display.newNode():addTo(page2,1)
    -- --frame
    -- display.newScale9Sprite("hall/exchange/frame.png", 0, 0, cc.size(437,215)):addTo(self.container1,1)

    --兑换纪录
    local button = ccui.Button:create("hall/exchange/btn_exchange_his.png","hall/exchange/btn_exchange_his.png","hall/exchange/btn_exchange_his1.png");
    button:setScale9Enabled(false);
    button:addTo(page1,1)
    button:setPosition(cc.p(100,105));
    button:setPressedActionEnabled(true);
    button:addTouchEventListener(
        function ( sender,eventType )
            if eventType == ccui.TouchEventType.ended then
                self:onClickTab(2)
            end
        end
        )
    self.tab2 = button

    self.container2 = display.newNode():addTo(page2,1)
    local bgTitle = display.newSprite("hall/exchange/title2.png"):addTo(self.container2,2):align(display.CENTER, 247, 320)

    self.listView = ccui.ListView:create()
    -- set list view ex direction
    self.listView:setDirection(ccui.ScrollViewDir.vertical)
    self.listView:setBounceEnabled(true)
    self.listView:setContentSize(cc.size(400,225))
    self.listView:setPosition(50, 62)
    -- self.listView:setBackGroundColorType(1)
    -- self.listView:setBackGroundColor(cc.c3b(0,123,0))
    self.listView:addTo(self.container2,1)
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
            
        elseif eventType == ccui.ScrollviewEventType.bounceBottom then
            print("请求更新")
            if self.isAllHisLoad == false then
                self.curHisPage = self.curHisPage +1
                --查询兑换历史纪录
                UserService:sendQueryRecordVoucherExchange(self.curHisPage)
            end
        end
    end
    self.listView:addScrollViewEventListener(scrollViewEvent)
    
    --banner
    display.newSprite("common/ty_dizhu.png"):addTo(page1,2):align(display.CENTER, 30, 345)
    display.newSprite("hall/exchange/banner3.png"):addTo(page1,2):align(display.CENTER, 130, 375)
    display.newSprite("hall/exchange/banner2.png"):addTo(page1,2):align(display.CENTER, 50, 50)
    display.newSprite("hall/exchange/banner2.png"):addTo(page1,2):align(display.CENTER, 175, 280):flipX(true):scale(0.6)
    display.newSprite("hall/exchange/banner1.png"):addTo(page1,2):align(display.CENTER, 170, 305)
    display.newSprite("hall/shop/zsgold2.png"):addTo(page2,2):align(display.CENTER, -10, 45)
    display.newSprite("hall/shop/zsgold5.png"):addTo(page2,2):align(display.CENTER, 510, 90)

    --关闭按钮
    local exit = ccui.Button:create("common/close.png");
    exit:setPosition(cc.p(468,312));
    exit:addTo(page2,1)
    exit:setPressedActionEnabled(true);
    exit:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:close();
            end
        end
    )
end

function ExchangeCouponLayer:onClickTab(index)
    if index == 1 then
        self.tab1:setEnabled(false)
        self.tab2:setEnabled(true)
        self.tab1:setBright(false)
        self.tab2:setBright(true)

        self.container1:show()
        self.container2:hide()

        self:refreshTab1()
        self.frame:setContentSize(cc.size(437,215))

    else
        self.tab2:setEnabled(false)
        self.tab1:setEnabled(true)
        self.tab2:setBright(false)
        self.tab1:setBright(true)

        self.container2:show()
        self.container1:hide()
    
        self.frame:setContentSize(cc.size(437,255))

    end

end

function ExchangeCouponLayer:refreshTab1()
    

    self.container1:removeAllChildren()

    --banner
    display.newSprite("hallScene/exchange/02.png"):addTo(self.container1,2):align(display.CENTER, 120, 0)


    local exchange = ccui.Button:create("common/common_button3.png","common/common_button3.png","common/common_button0.png");
    exchange:setPosition(cc.p(247,56));
    exchange:setScale9Enabled(true);
    exchange:setContentSize(cc.size(150, 70));
    exchange:setTitleFontName(FONT_ART_BUTTON);
    exchange:setTitleText("兑换");
    exchange:setTitleColor(cc.c3b(255,255,255));
    exchange:setTitleFontSize(30);
    exchange:setPressedActionEnabled(true);
    exchange:getTitleRenderer():enableOutline(COLOR_BTN_GREEN,2);
    exchange:addTo(self.container1,1)
    exchange:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:onClickExchange()
            end
        end
    )

    local bgTitle = display.newSprite("hall/exchange/title1.png"):addTo(self.container1,1):align(display.CENTER, 247, 320)
    

    display.newSprite("hallScene/exchange/item11.png"):addTo(self.container1,1):align(display.CENTER, 120, 210)
    display.newSprite("hallScene/exchange/item12.png"):addTo(self.container1,1):align(display.CENTER, 237, 210)
    display.newSprite("hallScene/exchange/item13.png"):addTo(self.container1,1):align(display.CENTER, 370, 210)

    --礼券数量
    local couponNum = DataManager:getMyUserInfo():getCoupon()

    local couponTxt = ccui.Text:create(FormatNumToString(couponNum) .. "张","fonts/HKBDTW12.TTF",24)
    couponTxt:setFontSize(26)
    couponTxt:setAnchorPoint(cc.p(0,0.5))
    couponTxt:setColor(cc.c4b(0xfe, 0xff, 0x79,255))
    couponTxt:enableOutline(cc.c4b(0x3d,0x1b,0x02,255), 2)
    couponTxt:addTo(self.container1,1):align(display.CENTER, 120, 150)

    --金币数量
    local goldTxt = ccui.Text:create(FormatNumToString(couponNum) .. "金币","fonts/HKBDTW12.TTF",24)
    goldTxt:setFontSize(26)
    goldTxt:setAnchorPoint(cc.p(0,0.5))
    goldTxt:setColor(cc.c4b(0xfe, 0xff, 0x79,255))
    goldTxt:enableOutline(cc.c4b(0x3d,0x1b,0x02,255), 2)
    goldTxt:addTo(self.container1,1):align(display.CENTER, 370, 150)


    if couponNum <= 0 then
        exchange:setEnabled(false)
        exchange:setBright(false)
    end
end

function ExchangeCouponLayer:refreshTab2()

    for i=self.lastHisCount+1, #self.hisList do
        local height = 0
        local custom_itemY = 35
        local custom_itemX = 225
        local custom_item = ccui.Layout:create()
        custom_item:setTouchEnabled(true)
        custom_item:setContentSize(cc.size(custom_itemX,custom_itemY))
        custom_item:setAnchorPoint(cc.p(0,1))

        local item = ccui.Text:create(self.hisList[i],"",24)
        item:setColor(cc.c4b(0xfe, 0xff, 0x79, 255))
        item:enableOutline(cc.c4b(0x3d,0x1b,0x02,255), 2)
        item:setAnchorPoint(cc.p(0,0))
        custom_item:addChild(item)
    
        self.listView:pushBackCustomItem(custom_item)    
    end

    self.listView:doLayout()
end

function ExchangeCouponLayer:close()
    self:removeSelf();
end

function ExchangeCouponLayer:onClickExchange()
    --礼券数量
    local couponNum = DataManager:getMyUserInfo():getCoupon()
    if couponNum <=0 then
        Hall.showTips("没有礼券，不可兑换！")
    else
        UserService:sendVoucherExchange()
    end
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

    dump(pData.RecordList, "pData.RecordList")

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
    local pData = protocol.hall.business_pb.DBO_GR_VoucherExchange_Pro()
    pData:ParseFromString(event.data)
    dump(pData, "eventVoucherExchange")
    if pData.nResultCode == 0 then
        Hall.showTips("兑换" .. pData.dwExchangeValue .. "金币成功")
        -- local userInfo = DataManager:getMyUserInfo()
        -- userInfo.present(0)
        AccountInfo:setPresent(0)
        UserService:sendQueryInsureInfo()
        self:refreshTab1()
    else
        Hall.showTips(pData.szDescribe)
    end
end

return ExchangeCouponLayer