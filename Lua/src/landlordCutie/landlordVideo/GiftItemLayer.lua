local GiftItemLayer = class("GiftItemLayer", function() return display.newLayer(); end );

function GiftItemLayer:ctor(params)
    self:setContentSize(cc.size(270,330))
    self:createUI()
    self.sceneID = params.sceneID
    self.sendGiftFunc = params.sendGiftFunc
    self.giftCountIndex = 1
end

function GiftItemLayer:createUI()

    local giftItemBg = ccui.ImageView:create("landlordVideo/giftLayer/giftItemBg.png")
    giftItemBg:setPosition(cc.p(135,200))
    self:addChild(giftItemBg)

    local itemIcon = ccui.ImageView:create("landlordVideo/giftLayer/gift_500.png")
    itemIcon:setPosition(cc.p(130,140))
    giftItemBg:addChild(itemIcon)
    self.giftIcon = itemIcon
    local itemEffectLabel = ccui.Text:create()
    itemEffectLabel:setFontSize(20)
    itemEffectLabel:setColor(cc.c3b(255,255,0))
    itemEffectLabel:enableOutline(cc.c4b(114,40,2,255), 2)
    itemEffectLabel:setPosition(cc.p(135,75))
    itemEffectLabel:setString("获得魅力值：100")
    giftItemBg:addChild(itemEffectLabel)
    self.itemEffectLabel = itemEffectLabel

    local goldIcon = ccui.ImageView:create("common/gold.png")
    goldIcon:setPosition(cc.p(45,205))
    goldIcon:setScale(0.7)
    giftItemBg:addChild(goldIcon)
    local itemPrice = ccui.Text:create()
    itemPrice:setFontSize(25)
    itemPrice:setColor(cc.c3b(255,255,0))
    itemPrice:enableOutline(cc.c4b(228,83,1,255), 2)
    itemPrice:setAnchorPoint(cc.p(0,0.5))
    itemPrice:setPosition(cc.p(65,208))
    itemPrice:setString("9999.9万")
    giftItemBg:addChild(itemPrice)
    self.giftPriceLabel = itemPrice
    local itemName = ccui.Text:create()
    itemName:setFontSize(20)
    itemName:setColor(cc.c3b(146,50,20))
    itemName:setAnchorPoint(cc.p(1,0.5))
    itemName:setPosition(cc.p(220,208))
    itemName:setString("玫瑰")
    giftItemBg:addChild(itemName)
    self.giftNameLabel = itemName

    

    local itemCountBg = ccui.ImageView:create("landlordVideo/video_info_bg.png")
    itemCountBg:setScale9Enabled(true)
    itemCountBg:setContentSize(cc.size(110,40))
    itemCountBg:setCapInsets(cc.rect(12,13,1,1))
    itemCountBg:setPosition(cc.p(135,35))
    giftItemBg:addChild(itemCountBg)
    local giftCountLabel = ccui.Text:create()
    giftCountLabel:setFontSize(20)
    giftCountLabel:setPosition(cc.p(55,20))
    giftCountLabel:setString("999")
    itemCountBg:addChild(giftCountLabel)
    self.giftCountLabel = giftCountLabel

    local leftButton = ccui.Button:create("hall/vipRoom/viproom_arrow.png")
    leftButton:setPressedActionEnabled(true)
    leftButton:setScale(0.7)
    leftButton:setPosition(cc.p(55,35))
    giftItemBg:addChild(leftButton)
    leftButton:addTouchEventListener(function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self.giftCountIndex = self.giftCountIndex - 1
                if self.giftCountIndex < 1 then
                    self.giftCountIndex = 1
                end
                self.giftCountLabel:setString(self.giftCountArr[self.giftCountIndex])
                self.giftPriceLabel:setString(FormatDigitToString(self.giftPrice * self.giftCountArr[self.giftCountIndex], 1))
            end
        end)
    self.leftButton = leftButton
    local rightButton = ccui.Button:create("hall/vipRoom/viproom_arrow.png")
    rightButton:setFlippedX(true)
    rightButton:setScale(0.7)
    rightButton:setPressedActionEnabled(true)
    rightButton:setPosition(cc.p(215,35))
    giftItemBg:addChild(rightButton)
    rightButton:addTouchEventListener(function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                -- SoundManager.playSound("sound/buttonclick.mp3")
                self.giftCountIndex = self.giftCountIndex + 1
                if self.giftCountIndex > #self.giftCountArr then
                    self.giftCountIndex = #self.giftCountArr
                end
                self.giftCountLabel:setString(self.giftCountArr[self.giftCountIndex])
                self.giftPriceLabel:setString(FormatDigitToString(self.giftPrice * self.giftCountArr[self.giftCountIndex], 1))
            end
        end)
    self.rightButton = rightButton
    local sendButton = ccui.Button:create("landlordVideo/video_greenbutton_bg.png");
    sendButton:setScale9Enabled(true)
    sendButton:setContentSize(cc.size(125, 67))
    sendButton:setPosition(cc.p(135,45));
    sendButton:setTitleFontName(FONT_ART_BUTTON);
    sendButton:getTitleRenderer():enableOutline(COLOR_BTN_GREEN,2);
    sendButton:setTitleText("赠送");
    sendButton:setTitleColor(cc.c3b(255,255,255));
    sendButton:setTitleFontSize(28);
    self:addChild(sendButton)
    sendButton:setPressedActionEnabled(true);
    sendButton:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:onSendGift()
            end
        end
    )
end

function GiftItemLayer:onSendGift()
    self.sendGiftFunc(self.giftIndex,self.giftPrice,self.giftCountArr[self.giftCountIndex])
end

function GiftItemLayer:updateGiftItemInfo(gift)
    if gift == nil then
        print("gift is nil")
        return
    end
    self.giftIndex = gift:getIndex()
    self.giftPrice = gift:getPropertyGold()
    self.giftName = customGift[gift:getIndex()].giftName
    self.giftImg = customGift[gift:getIndex()].giftImg
    self.giftCountArr = customGift[gift:getIndex()].giftCount
    if self.sceneID == 1 or self.sceneID == 2 then
        self.giftCountArr = {1}
        self.leftButton:setVisible(false)
        self.rightButton:setVisible(false)
    end

    self.giftPriceLabel:setString(FormatDigitToString(self.giftPrice, 1))
    self.giftNameLabel:setString(self.giftName)
    self.giftIcon:loadTexture(self.giftImg)
    self.giftCountLabel:setString(self.giftCountArr[self.giftCountIndex])
    self.itemEffectLabel:setString("获得魅力值："..gift:getRecvLoveLiness())
end

return GiftItemLayer
