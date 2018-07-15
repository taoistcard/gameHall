local GiftInfoLayer = class("GiftInfoLayer", function() return display.newLayer(); end );

function GiftInfoLayer:ctor(params)
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    local winSize = cc.Director:getInstance():getWinSize()
    local contentSize = cc.size(1136,winSize.height)
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

    self:createUI(params.sceneID)
    self.targetUserID = nil
end

function GiftInfoLayer:createUI(sceneID)
    local popBg = ccui.ImageView:create()
    popBg:loadTexture("common/pop_bg.png")
    popBg:setScale9Enabled(true)
    popBg:setContentSize(cc.size(622,622))
    popBg:setCapInsets(cc.rect(115,215,1,1))
    popBg:setPosition(cc.p(815,315))
    self:addChild(popBg)
    local title_text_bg = ccui.ImageView:create()
    title_text_bg:loadTexture("common/pop_title.png")
    title_text_bg:setAnchorPoint(cc.p(0,0.5))
    title_text_bg:setPosition(cc.p(45,580))
    popBg:addChild(title_text_bg)
    local title_text = ccui.Text:create("赠送礼物",FONT_ART_TEXT,22)
    title_text:setTextColor(cc.c4b(251,248,142,255))
    title_text:enableOutline(cc.c4b(137,0,167,200), 2)
    title_text:setPosition(cc.p(68,70))
    title_text_bg:addChild(title_text)

    local curGoldTxt = ccui.Text:create()
    curGoldTxt:setString("现有金币：")
    curGoldTxt:setFontSize(20)
    curGoldTxt:setColor(cc.c3b(249,213,57))
    curGoldTxt:enableOutline(cc.c4b(83,8,2,255), 2)
    curGoldTxt:setAnchorPoint(cc.p(0,0.5))
    curGoldTxt:setPosition(cc.p(160,550))
    popBg:addChild(curGoldTxt)

    local curGoldLabel = ccui.Text:create()
    curGoldLabel:setFontSize(20)
    curGoldLabel:setColor(cc.c3b(250,251,4))
    curGoldLabel:enableOutline(cc.c4b(62,4,0,255), 2)
    curGoldLabel:setAnchorPoint(cc.p(0,0.5))
    curGoldLabel:setPosition(cc.p(250,550))
    popBg:addChild(curGoldLabel)
    curGoldLabel:setString(FormatDigitToString(DataManager:getMyUserInfo().score, 1))
    self.curGoldLabel = curGoldLabel

    -- local maskLayer = cc.LayerColor:create(cc.c4b(255, 0, 0, 255))
    -- maskLayer:setContentSize(cc.size(540, 480));
    -- maskLayer:setPosition(cc.p(40,55));
    -- popBg:addChild(maskLayer)
    local giftInfoScrollView = ccui.ScrollView:create()
    giftInfoScrollView:setTouchEnabled(true)
    giftInfoScrollView:setContentSize(cc.size(540, 480))
    giftInfoScrollView:setPosition(cc.p(40,55))
    popBg:addChild(giftInfoScrollView)

    local giftIndexArr = nil
    if sceneID == 1 then--三人场
        giftIndexArr = {500,501,502,503,508,511}

    elseif sceneID == 2 then--二人场
        giftIndexArr = {500,501,502,503,508,511}
    
    else--视频场
        giftIndexArr = {500,501,502,503,504,505,506,507,508,509,510,511,512,513,514,515}
    end

    local propertyCount = #giftIndexArr--PropertyConfigInfo:propertyCount()
    local row = 1
    local col = 1
    if (propertyCount % 2) == 0 then
        row = propertyCount / 2
    else
        row = math.modf(propertyCount / 2) + 1
    end
    giftInfoScrollView:setInnerContainerSize(cc.size(540, 330 * row))
    
    for i=1,propertyCount do
        local gift = PropertyConfigInfo:obtainPropertyobjectByIndex(giftIndexArr[i])

        local posX = (col - 1) * 270
        local posY = (row - 1) * 330
        local customItem = ccui.Layout:create()
        customItem:setContentSize(cc.size(270,330))
        customItem:setPosition(cc.p(posX,posY))
        giftInfoScrollView:addChild(customItem)

        local giftItem = require("landlordVideo.GiftItemLayer").new({sceneID=sceneID,
                                                                    sendGiftFunc=
                                                                        function(giftIndex,giftPrice,giftCount) 
                                                                            self:sendGift(giftIndex,giftPrice,giftCount) 
                                                                        end
                                                                        })
        customItem:addChild(giftItem)
        giftItem:updateGiftItemInfo(gift)


        col = col + 1
        if col > 2 then
            row = row -1
            col = 1
        end
    end

    --关闭按钮
    local closeButton = ccui.Button:create("common/close.png")
    closeButton:setPressedActionEnabled(true)
    closeButton:setPosition(cc.p(590,585))
    popBg:addChild(closeButton)
    closeButton:addTouchEventListener(function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                -- SoundManager.playSound("sound/buttonclick.mp3")
                self:onCloseClick()
            end
        end)
end

function GiftInfoLayer:showGiftInfoLayer(targetUserID)
    self.targetUserID = targetUserID
    self:show()
    self.curGoldLabel:setString(FormatDigitToString(DataManager:getMyUserInfo().score, 1))
end

function GiftInfoLayer:sendGift(giftIndex,giftPrice,giftCount)
    print("sendGift:",giftIndex,giftPrice,giftCount)
    self:dispatchEvent({name=GameCenterEvent.EVENT_BUY_PROPERTY,giftIndex=giftIndex,giftPrice=giftPrice,giftCount=giftCount,targetUserID=self.targetUserID})
end

function GiftInfoLayer:onCloseClick()
    self:hide()
end

return GiftInfoLayer
