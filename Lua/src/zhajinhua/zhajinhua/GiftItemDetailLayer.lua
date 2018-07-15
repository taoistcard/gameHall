local GiftItemDetailLayer = class("GiftItemDetailLayer",function ()
	return display.newLayer()
end)
function GiftItemDetailLayer:ctor(params)
	self.giftCount = 1
	self.sendGiftFunc = params.sendGiftFunc
	self:createUI()
end
function GiftItemDetailLayer:createUI()
    local winSize = cc.Director:getInstance():getWinSize()
    local contentSize = cc.size(winSize.width,winSize.height)
    -- 蒙板
    local maskLayer = ccui.ImageView:create()
    maskLayer:loadTexture("common/black.png")
    maskLayer:setContentSize(contentSize);
    maskLayer:setScale9Enabled(true)
    maskLayer:setCapInsets(cc.rect(4,4,1,1))
    maskLayer:setPosition(cc.p(DESIGN_WIDTH/2,DESIGN_HEIGHT/2));
    maskLayer:setTouchEnabled(true)
    self:addChild(maskLayer)

    local popBg = ccui.ImageView:create()
    popBg:loadTexture("view/frame3.png")
    popBg:setScale9Enabled(true)
    popBg:setContentSize(cc.size(370,298))
    popBg:setPosition(539,265)
    self:addChild(popBg)

    local item = ccui.ImageView:create("giftLayer/gift_500.png")
    item:setPosition(69, 250)
    popBg:addChild(item)
    self.item = item

    local itemName = ccui.Text:create()
    itemName:setFontSize(24)
    -- itemName:setColor(cc.c3b(0x9b,0x31,0x16))
    -- itemName:setAnchorPoint(cc.p(1,0.5))
    itemName:setPosition(cc.p(154,250))
    itemName:setString("玫瑰")
    popBg:addChild(itemName)
    self.giftNameLabel = itemName

    local itemName = ccui.Text:create()
    itemName:setFontSize(24)
    -- itemName:setColor(cc.c3b(0x9b,0x31,0x16))
    -- itemName:setAnchorPoint(cc.p(1,0.5))
    itemName:setPosition(cc.p(220,250))
    itemName:setString("魅力")
    popBg:addChild(itemName)

    local loveliness = ccui.Text:create()
    loveliness:setFontSize(24)
    -- loveliness:setColor(cc.c3b(0x9b,0x31,0x16))
    loveliness:setAnchorPoint(cc.p(0,0.5))
    loveliness:setPosition(cc.p(250,250))
    loveliness:setString("100")
    popBg:addChild(loveliness)
    self.lovelinessLabel = loveliness

    local chip = ccui.ImageView:create("hall/room/chouma_icon.png")
    chip:setPosition(134, 175)
    chip:setScale(0.7)
    popBg:addChild(chip)

    local price = ccui.Text:create()
    price:setFontSize(24)
    -- price:setColor(cc.c3b(0x9b,0x31,0x16))
    price:setAnchorPoint(cc.p(0,0.5))
    price:setPosition(cc.p(165,175))
    price:setString("100")
    popBg:addChild(price)
    self.priceLabel = price

    self.minusTime = 0
    self.plusTime = 0
    local intervalTime = 0.016

    local minus = ccui.Button:create("giftLayer/minus.png")
    minus:setPosition(125, 130)
    minus:addTouchEventListener(function (sender,eventType )
    	if eventType == ccui.TouchEventType.ended then
    		self:minusHandler()
            self:stopAutoMinusAndPlus()
        elseif eventType == ccui.TouchEventType.began then
            self.minusTime = os.time()
            self:schedule(function ()
                self:checkAutoMinusAndPlus(-1)
            end,intervalTime)
        elseif eventType == ccui.TouchEventType.canceled then
            self:stopAutoMinusAndPlus()
    	end
    end)
    popBg:addChild(minus)

    local countBg = ccui.ImageView:create("giftLayer/countBg.png")
    countBg:setPosition(189, 128)
    popBg:addChild(countBg)

    local count = ccui.Text:create()
    count:setFontSize(22)
    -- price:setColor(cc.c3b(0x9b,0x31,0x16))
    -- count:setAnchorPoint(cc.p(0,0.5))
    count:setPosition(cc.p(189, 128))
    count:setString("1")
    popBg:addChild(count)
    self.countLabel = count

    local plus = ccui.Button:create("giftLayer/plus.png")
    plus:setPosition(252, 130)
    plus:addTouchEventListener(function (sender,eventType )
    	if eventType == ccui.TouchEventType.ended then
    		self:plusHandler()
            self:stopAutoMinusAndPlus()
        elseif eventType == ccui.TouchEventType.began then
            self.plusTime = os.time()
            self:schedule(function ()
                self:checkAutoMinusAndPlus(1)
            end,intervalTime)
        elseif eventType == ccui.TouchEventType.canceled then
            self:stopAutoMinusAndPlus()
    	end
    end)
    popBg:addChild(plus)

    local present = ccui.Button:create("common/common_button2.png")
    present:setPosition(95, 48)
    present:setTitleText("赠送")
    present:setTitleFontSize(24)
    present:setTitleColor(cc.c3b(255, 255, 255))
    present:addTouchEventListener(function (sender,eventType )
    	if eventType == ccui.TouchEventType.ended then
    		self:presentHandler()
    	end
    end)
    popBg:addChild(present)

    local presentAll = ccui.Button:create("common/common_button3.png")
    presentAll:setPosition(265, 48)
    presentAll:setTitleText("给所有人买")
    presentAll:setTitleFontSize(24)
    presentAll:setTitleColor(cc.c3b(255, 255, 255))
    presentAll:addTouchEventListener(function (sender,eventType )
    	if eventType == ccui.TouchEventType.ended then
    		self:presentAllHandler()
    	end
    end)
    popBg:addChild(presentAll)

    --关闭按钮
    local closeButton = ccui.Button:create("common/close2.png")
    closeButton:setPressedActionEnabled(true)
    closeButton:setPosition(cc.p(361,286))
    popBg:addChild(closeButton)
    closeButton:addTouchEventListener(function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                
                self:close()
            end
        end)
end
function GiftItemDetailLayer:stopAutoMinusAndPlus()
    self:stopAllActions()
end
function GiftItemDetailLayer:checkAutoMinusAndPlus(autotype)
    local currentTime = os.time()
    -- print("checkAutoMinusAndPlus","self.minusTime",self.minusTime,"self.plusTime",self.plusTime,"currentTime",currentTime)
    if autotype == 1 then
        if currentTime - self.plusTime >0.5 then
            self:plusHandler()
        end
    else
        if currentTime - self.minusTime > 0.5 then
            self:minusHandler()
        end
    end
end
function GiftItemDetailLayer:close()
    self:removeFromParent()
    -- self:hide()
end
function GiftItemDetailLayer:updateGiftItemInfo(gift)
    if gift == nil then
        print("gift is nil")
        return
    end
    self.giftIndex = gift:getIndex()
    self.giftPrice = gift:getPropertyGold()
    self.giftName = customGift[gift:getIndex()].giftName
    self.giftImg = customGift[gift:getIndex()].giftImg
    


    self.priceLabel:setString(FormatDigitToString(self.giftPrice, 1))
    self.giftNameLabel:setString(self.giftName)
    self.item:loadTexture(self.giftImg)
    self.lovelinessLabel:setString(gift:getRecvLoveLiness())
end
function GiftItemDetailLayer:minusHandler( )
	-- body
	if self.giftCount<=1 then
		return
	end
	self.giftCount = self.giftCount-1
	self.countLabel:setString(self.giftCount)
end
function GiftItemDetailLayer:plusHandler()
	if self.giftCount>=99 then
		return
	end
	self.giftCount = self.giftCount+1
	self.countLabel:setString(self.giftCount)
end
function GiftItemDetailLayer:presentHandler()
	self.sendGiftFunc(self.giftIndex,self.giftPrice,self.giftCount)
    self:close()
end
function GiftItemDetailLayer:presentAllHandler()
	self.sendGiftFunc(self.giftIndex,self.giftPrice,self.giftCount,true)
    self:close()
end
return GiftItemDetailLayer