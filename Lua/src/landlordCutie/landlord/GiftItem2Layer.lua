--
-- Author: <zhaxun>
-- Date: 2015-10-15 10:09:23
--
local GiftItem2Layer = class("GiftItem2Layer", function() return display.newLayer(); end );

function GiftItem2Layer:ctor(params)
    self:setContentSize(cc.size(163,161))
    self:createUI()
    self.sceneID = params.sceneID
    self.sendGiftFunc = params.sendGiftFunc
    self.giftCountIndex = 1
end

function GiftItem2Layer:createUI()

    local focusImage = display.newSprite("landlordVideo/giftLayer/focus.png"):addTo(self):align(display.CENTER, 80, 82):hide()

	local sendButton = ccui.ImageView:create("landlordVideo/giftLayer/giftItemBg2.png");
    sendButton:setPosition(cc.p(82,80));
    sendButton:setTouchEnabled(true)
    sendButton:setSwallowTouches(false)
    self:addChild(sendButton)
    sendButton:addTouchEventListener(
        function(sender,eventType)
			if eventType == ccui.TouchEventType.began then
                -- sender:scale(1.1)
                focusImage:show()
			elseif eventType == ccui.TouchEventType.moved then

            elseif eventType == ccui.TouchEventType.ended then
                -- sender:scale(1.0)
                focusImage:hide()
                self:onSendGift()

            elseif eventType == ccui.TouchEventType.canceled then
                -- sender:scale(1.0)
                focusImage:hide()
            end
        end
    )


    local itemIcon = ccui.ImageView:create("landlordVideo/giftLayer/gift_500.png")
    itemIcon:setPosition(cc.p(77,77))
    itemIcon:scale(0.66)
    sendButton:addChild(itemIcon)
    self.giftIcon = itemIcon

    local itemEffectLabel = ccui.Text:create()
    itemEffectLabel:setFontSize(18)
    itemEffectLabel:setColor(cc.c3b(0xfb,0xff,0))
    itemEffectLabel:enableOutline(cc.c4b(0x7f,0x2a,0,0xff), 2)
    itemEffectLabel:setPosition(cc.p(77,24))
    itemEffectLabel:setString("增加魅力值：100")
    sendButton:addChild(itemEffectLabel)
    self.itemEffectLabel = itemEffectLabel

    local goldIcon = ccui.ImageView:create("common/gold.png")
    goldIcon:setPosition(cc.p(26,128))
    goldIcon:setScale(0.4)
    sendButton:addChild(goldIcon)

    local itemPrice = ccui.Text:create()
    itemPrice:setFontSize(16)
    itemPrice:setColor(cc.c3b(0xfb,0xff,0))
    itemPrice:enableOutline(cc.c4b(0xe5,0x5b,0x0b,0xff), 2)
    itemPrice:setAnchorPoint(cc.p(0,0.5))
    itemPrice:setPosition(cc.p(38,130))
    itemPrice:setString("9999.9万")
    sendButton:addChild(itemPrice)
    self.giftPriceLabel = itemPrice

    local itemName = ccui.Text:create()
    itemName:setFontSize(18)
    itemName:setColor(cc.c3b(0x9b,0x31,0x16))
    itemName:setAnchorPoint(cc.p(1,0.5))
    itemName:setPosition(cc.p(135,130))
    itemName:setString("玫瑰")
    sendButton:addChild(itemName)
    self.giftNameLabel = itemName

end

function GiftItem2Layer:onSendGift()
    self.sendGiftFunc(self.giftIndex,self.giftPrice,self.giftCountArr[self.giftCountIndex])
end

function GiftItem2Layer:updateGiftItemInfo(gift)
    if gift == nil then
        print("gift is nil")
        return
    end
    self.giftIndex = gift:getIndex()
    self.giftPrice = gift:getPropertyGold()
    self.giftName = customGift[gift:getIndex()].giftName
    self.giftImg = customGift[gift:getIndex()].giftImg
    self.giftCountArr = customGift[gift:getIndex()].giftCount


    self.giftPriceLabel:setString(FormatDigitToString(self.giftPrice, 1))
    self.giftNameLabel:setString(self.giftName)
    self.giftIcon:loadTexture(self.giftImg)
    self.itemEffectLabel:setString("获得魅力值："..gift:getRecvLoveLiness())
end

return GiftItem2Layer
