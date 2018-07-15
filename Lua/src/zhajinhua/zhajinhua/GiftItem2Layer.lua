local GiftItem2Layer = class("GiftItem2Layer", function() return display.newLayer(); end );

function GiftItem2Layer:ctor(params)
    self:setContentSize(cc.size(130,175))
    self:createUI()
    self.sceneID = params.sceneID
    self.sendGiftFunc = params.sendGiftFunc
    self.giftCountIndex = 1
    self.parentContainer = params.parentContainer
    self.giftInfo = nil
end

function GiftItem2Layer:createUI()

    -- local focusImage = display.newSprite("giftLayer/focus.png"):addTo(self):align(display.CENTER, 80, 82):hide()

	local sendButton = ccui.ImageView:create("giftLayer/propertyItembg.png");
    sendButton:setPosition(cc.p(58,121));
    sendButton:setTouchEnabled(true)
    sendButton:setSwallowTouches(false)
    self:addChild(sendButton)
    sendButton:addTouchEventListener(
        function(sender,eventType)
			if eventType == ccui.TouchEventType.began then
                -- sender:scale(1.1)
                -- focusImage:show()
			elseif eventType == ccui.TouchEventType.moved then

            elseif eventType == ccui.TouchEventType.ended then
                -- sender:scale(1.0)
                -- focusImage:hide()
                self:onSendGift()

            elseif eventType == ccui.TouchEventType.canceled then
                -- sender:scale(1.0)
                -- focusImage:hide()
            end
        end
    )


    local itemIcon = ccui.ImageView:create("giftLayer/gift_500.png")
    itemIcon:setPosition(cc.p(52,51))
    -- itemIcon:scale(0.66)
    sendButton:addChild(itemIcon)
    self.giftIcon = itemIcon

    local itemName = ccui.Text:create()
    itemName:setFontSize(20)
    -- itemName:setColor(cc.c3b(0x9b,0x31,0x16))
    -- itemName:setAnchorPoint(cc.p(1,0.5))
    itemName:setPosition(cc.p(62,44))
    itemName:setString("玫瑰")
    self:addChild(itemName)
    self.giftNameLabel = itemName

    local itemPrice = ccui.Text:create()
    itemPrice:setFontSize(20)
    -- itemPrice:setColor(cc.c3b(0xfb,0xff,0))
    -- itemPrice:enableOutline(cc.c3b(0xe5,0x5b,0x0b), 2)
    -- itemPrice:setAnchorPoint(cc.p(0,0.5))
    itemPrice:setPosition(cc.p(62,17))
    itemPrice:setString("9999.9万")
    self:addChild(itemPrice)
    self.giftPriceLabel = itemPrice
end

function GiftItem2Layer:onSendGift()
    -- self.sendGiftFunc(self.giftIndex,self.giftPrice,self.giftCountArr[self.giftCountIndex])
    if self.detail == nil then
        local detail = require("zhajinhua.GiftItemDetailLayer").new({
            sendGiftFunc=function(giftIndex,giftPrice,giftCount,isall) 
                        self:sendGiftFuncCallBack(giftIndex,giftPrice,giftCount,isall) 
                    end})
        detail:updateGiftItemInfo(self.giftInfo)
        self.parentContainer:addChild(detail)
    --     self.detail = detail
    -- else
    --     self.detail:updateGiftItemInfo(self.giftInfo)
    --     self.detail:show()
    end
end
function GiftItem2Layer:sendGiftFuncCallBack( giftIndex,giftPrice,giftCount,isall )
    print("sendGiftFuncCallBack",tostring(self))
    self.sendGiftFunc(giftIndex,giftPrice,giftCount,isall)
end
function GiftItem2Layer:updateGiftItemInfo(gift)
    if gift == nil then
        print("gift is nil")
        return
    end
    self.giftInfo = gift
    self.giftIndex = gift:getIndex()
    self.giftPrice = gift:getPropertyGold()
    self.giftName = customGift[gift:getIndex()].giftName
    self.giftImg = customGift[gift:getIndex()].giftImg
    self.giftCountArr = customGift[gift:getIndex()].giftCount


    self.giftPriceLabel:setString(FormatDigitToString(self.giftPrice, 1))
    self.giftNameLabel:setString(self.giftName)
    self.giftIcon:loadTexture(self.giftImg)
    -- self.itemEffectLabel:setString("获得魅力值："..gift:getRecvLoveLiness())

end

return GiftItem2Layer
