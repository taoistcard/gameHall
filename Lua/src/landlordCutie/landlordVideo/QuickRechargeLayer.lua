local QuickRechargeLayer = class("QuickRechargeLayer",function() return display.newLayer() end)



function QuickRechargeLayer:ctor()
    self:setNodeEventEnabled(true)
    local winSize = cc.Director:getInstance():getWinSize()
    local contentSize = cc.size(1136,winSize.height)
    self:setContentSize(contentSize)
    -- 蒙板
    local maskLayer = ccui.ImageView:create("blank.png")
    maskLayer:setScale9Enabled(true)
    maskLayer:setContentSize(contentSize)
    maskLayer:setPosition(cc.p(display.cx, display.cy));
    maskLayer:setTouchEnabled(true)
    self:addChild(maskLayer)
    local maskImg = ccui.ImageView:create("landlordVideo/video_mask.png")
    maskImg:setPosition(cc.p(757, winSize.height / 2));
    maskLayer:addChild(maskImg)

    self.payInfoArr = {
        
        {packageID = "380",productID = "huanle_landpoker_006w",price=12,score=60000,member=1},
        {packageID = "381",productID = "huanle_landpoker_25w",price=50,score=250000,member=2},
        {packageID = "382",productID = "huanle_landpoker_050w",price=98,score=500000,member=3},
        {packageID = "383",productID = "huanle_landpoker_0100w",price=198,score=1000000,member=4},
        {packageID = "384",productID = "huanle_landpoker_248w",price=488,score=2480000,member=5},
    }
    self.curIndex = 1
    self:createUI();
    
end

function QuickRechargeLayer:createUI()
    local contentSize = self:getContentSize()

    local popBg = ccui.ImageView:create()
    popBg:loadTexture("common/pop_bg.png")
    popBg:setScale9Enabled(true)
    popBg:setContentSize(cc.size(622,435))
    popBg:setCapInsets(cc.rect(115,215,1,1))
    popBg:setPosition(cc.p(815,display.cy))
    self:addChild(popBg)

    local title_text_bg = ccui.ImageView:create()
    title_text_bg:loadTexture("common/pop_title.png")
    title_text_bg:setAnchorPoint(cc.p(0,0.5))
    title_text_bg:setPosition(cc.p(45,395))
    popBg:addChild(title_text_bg)
    local title_text = ccui.Text:create("快速购买", FONT_ART_TEXT, 24)
    title_text:setColor(cc.c3b(255,233,110));
    title_text:enableOutline(cc.c4b(141,0,166,255*0.7),2);
    title_text:setPosition(cc.p(68,65));
    title_text:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER);
    title_text_bg:addChild(title_text);

    local exit = ccui.Button:create("common/close.png");
    exit:setPosition(cc.p(590,400));
    popBg:addChild(exit);
    exit:setPressedActionEnabled(true);
    exit:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:hide()
            end
        end
    )

    local chargeInfo = ccui.ImageView:create()
    chargeInfo:loadTexture("common/panel.png")
    chargeInfo:setContentSize(cc.size(520,220))
    chargeInfo:setScale9Enabled(true)
    chargeInfo:setCapInsets(cc.rect(39,39,1,1))
    chargeInfo:setPosition(cc.p(310,230))
    popBg:addChild(chargeInfo)

    local showVipLayer = ccui.Layout:create()
    showVipLayer:setContentSize(cc.size(520,220))
    chargeInfo:addChild(showVipLayer)
    self.showVipLayer = showVipLayer
    local vipword = ccui.ImageView:create("hall/shop/vipWord.png");
    vipword:setPosition(cc.p(240,173))
    showVipLayer:addChild(vipword)
    local vipIcon = ccui.ImageView:create("hall/shop/zuan1.png");
    vipIcon:setPosition(cc.p(250,185))
    showVipLayer:addChild(vipIcon)
    self.vipIcon = vipIcon

    local timeLimitText = ccui.Text:create()
    timeLimitText:setString("时限2天")
    timeLimitText:setFontSize(24)
    timeLimitText:setColor(cc.c3b(229, 238, 30))
    timeLimitText:enableOutline(cc.c4b(137,0,167,200), 2)
    timeLimitText:setPosition(330, 175)
    showVipLayer:addChild(timeLimitText)

    local goldCoins = ccui.ImageView:create("hall/bank/goldcoins.png");
    goldCoins:setPosition(cc.p(110, 90));
    chargeInfo:addChild(goldCoins);


    local priceScoreInfo = ccui.Text:create()
    priceScoreInfo:setString("12元＝12万金币")
    priceScoreInfo:setFontSize(24)
    priceScoreInfo:setColor(cc.c3b(229, 238, 30))
    priceScoreInfo:enableOutline(cc.c4b(137,0,167,200), 2)
    priceScoreInfo:setPosition(350, 115)
    chargeInfo:addChild(priceScoreInfo)
    self.priceScoreInfo = priceScoreInfo

    local sepLine = ccui.ImageView:create("common/sep_line.png")
    sepLine:setScale9Enabled(true)
    sepLine:setContentSize(280,3)
    sepLine:setAnchorPoint(cc.p(0,0.5))
    sepLine:setPosition(cc.p(210,90))
    chargeInfo:addChild(sepLine)

    local unitPriceScoreInfo = ccui.Text:create()
    unitPriceScoreInfo:setString("12元＝12万金币")
    unitPriceScoreInfo:setFontSize(24)
    unitPriceScoreInfo:enableOutline(cc.c4b(137,0,167,200), 2)
    unitPriceScoreInfo:setPosition(350, 65)
    chargeInfo:addChild(unitPriceScoreInfo)
    self.unitPriceScoreInfo = unitPriceScoreInfo

    local refreshButton = ccui.Button:create("landlordVideo/refresh_button.png")
    refreshButton:setPosition(cc.p(500,195))
    chargeInfo:addChild(refreshButton)
    refreshButton:setPressedActionEnabled(true)
    refreshButton:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                local totalPayIDCount = table.maxn(self.payInfoArr)
                self.curIndex = self.curIndex + 1
                if self.curIndex > totalPayIDCount then
                    self.curIndex = 1
                end
                self:refreshQuickRechargeLayer()
            end
        end)

    local chargeButton = ccui.Button:create("landlordVideo/video_greenbutton_bg.png");
    chargeButton:setScale9Enabled(true)
    chargeButton:setContentSize(cc.size(200,67))
    chargeButton:setPosition(cc.p(311,75));
    chargeButton:setTitleFontName(FONT_ART_BUTTON);
    chargeButton:getTitleRenderer():enableOutline(COLOR_BTN_GREEN,2);
    chargeButton:setTitleText("确定");
    chargeButton:setTitleColor(cc.c3b(255,255,255));
    chargeButton:setTitleFontSize(28);
    popBg:addChild(chargeButton);
    chargeButton:setPressedActionEnabled(true);
    chargeButton:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                --充值
                local payInfo = self.payInfoArr[self.curIndex]
                local args = {packageID = payInfo.packageID,productId = payInfo.productID,productPrice = payInfo.price}
                PlatformAppPurchases(args)
                self:hide()
            end
        end
    )
end

function QuickRechargeLayer:showQuickRechargeLayer()
    self:show()
    UserService:sendQueryHasBuyGoldByKind("193");
    UserService:sendQueryHasBuyGoldByKind("194");
end

function QuickRechargeLayer:refreshQuickRechargeLayer()
    local payInfo = self.payInfoArr[self.curIndex]
    if payInfo.member > 0 and payInfo.member <= 5 then
        self.showVipLayer:setVisible(true)
        self.vipIcon:loadTexture("hall/shop/zuan"..payInfo.member..".png")
    else
        self.showVipLayer:setVisible(false)
    end
    local priceStr = payInfo.price.."元＝"..FormatDigitToString(payInfo.score, 1).."金币"
    self.priceScoreInfo:setString(priceStr)
    local unitPrice = math.modf(payInfo.score/payInfo.price)
    local unitPriceStr = "1元＝"..FormatDigitToString(unitPrice, 2).."金币"
    self.unitPriceScoreInfo:setString(unitPriceStr)
end

function QuickRechargeLayer:getTodayWasNotPaySuccess(event)
    local info = protocol.hall.treasureInfo_pb.CMD_GP_QueryTodayWasnotPayResult_Pro();
    info:ParseFromString(event.data)
    local dwWasTodayPayed = info.dwWasTodayPayed
    local szPayId = info.szPayId
    print("getTodayWasNotPaySuccess:",dwWasTodayPayed,szPayId)
    if dwWasTodayPayed == 1 then
        for i,v in ipairs(self.payInfoArr) do
            if v.packageID == szPayId then
                table.remove(self.payInfoArr,i)
                break
            end
        end
    end
    self:refreshQuickRechargeLayer()
end

function QuickRechargeLayer:getTodayWasNotPayFailure(event)
    local info = protocol.hall.treasureInfo_pb.CMD_GP_UserInsureFailure_Pro();
    info:ParseFromString(event.data)
    Hall.showTips(info.szDescribeString)
end

function QuickRechargeLayer:onEnter()
    print("QuickRechargeLayer:onEnter!")
    self.handler1 = UserService:addEventListener(HallCenterEvent.EVENT_QUERY_TODAYWASNOTPAY_SUCCESS, handler(self, self.getTodayWasNotPaySuccess))
    self.handler2 = UserService:addEventListener(HallCenterEvent.EVENT_QUERY_TODAYWASNOTPAY_FAILURE, handler(self, self.getTodayWasNotPayFailure))
end

function QuickRechargeLayer:onExit()
    print("QuickRechargeLayer:onExit!")
    UserService:removeEventListener(self.handler1)
    UserService:removeEventListener(self.handler2)
end

return QuickRechargeLayer