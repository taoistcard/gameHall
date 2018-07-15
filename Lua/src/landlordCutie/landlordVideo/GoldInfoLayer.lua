local GoldInfoLayer = class("GoldInfoLayer", function() return display.newLayer(); end );

function GoldInfoLayer:ctor()
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

    self.goldArr = {
        10000,
        50000,
        100000,
        500000,
        1000000,
        5000000,
        10000000,
        100000000,
    }

    self:createUI()
end

function GoldInfoLayer:createUI()
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
    local title_text = ccui.Text:create("打赏金币",FONT_ART_TEXT,22)
    title_text:setTextColor(cc.c4b(251,248,142,255))
    title_text:enableOutline(cc.c4b(137,0,167,200), 2)
    title_text:setPosition(cc.p(68,70))
    title_text_bg:addChild(title_text)

    local curGoldTxt = ccui.Text:create()
    curGoldTxt:setString("现有金币：")
    curGoldTxt:setFontSize(20)
    curGoldTxt:setColor(cc.c3b(255,255,255))
    curGoldTxt:enableOutline(cc.c4b(0x3f,0x0f,0x02,255), 2)
    curGoldTxt:setAnchorPoint(cc.p(0,0.5))
    curGoldTxt:setPosition(cc.p(160,550))
    popBg:addChild(curGoldTxt)

    local curGoldLabel = ccui.Text:create()
    curGoldLabel:setFontSize(20)
    curGoldLabel:setColor(cc.c3b(0,251,0))
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
    local goldInfoScrollView = ccui.ScrollView:create()
    goldInfoScrollView:setTouchEnabled(true)
    goldInfoScrollView:setContentSize(cc.size(540, 480))
    goldInfoScrollView:setPosition(cc.p(40,55))
    popBg:addChild(goldInfoScrollView)

    local goldItemCount = #self.goldArr
    print("goldItemCount:",goldItemCount)
    local row = 1
    local col = 1
    if (goldItemCount % 2) == 0 then
        row = goldItemCount / 2
    else
        row = math.modf(goldItemCount / 2) + 1
    end
    goldInfoScrollView:setInnerContainerSize(cc.size(540, 270*row))
    for i=1,goldItemCount do
        local posX = (col - 1) * 270
        local posY = (row - 1) * 270

        local goldInfoItem = ccui.Layout:create()
        goldInfoItem:setContentSize(cc.size(270,270))
        goldInfoItem:setPosition(cc.p(posX,posY))
        goldInfoScrollView:addChild(goldInfoItem)
        local goldItemBg = ccui.ImageView:create("landlordVideo/goldInfo/goldInfoItemBg.png")
        goldItemBg:setScale9Enabled(true)
        goldItemBg:setContentSize(cc.size(254,193))
        goldItemBg:setPosition(cc.p(135,160))
        goldInfoItem:addChild(goldItemBg)
        local goldLightBg = ccui.ImageView:create("landlordVideo/goldInfo/goldLightBg.png")
        goldLightBg:setPosition(cc.p(135,160))
        goldInfoItem:addChild(goldLightBg)
        local goldBigIcon = ccui.ImageView:create("landlordVideo/goldInfo/golfInfoIcon.png")
        goldBigIcon:setPosition(cc.p(135,160))
        goldInfoItem:addChild(goldBigIcon)
        local goldItemValue = ccui.ImageView:create("landlordVideo/goldInfo/gold_"..self.goldArr[i]..".png")
        goldItemValue:setPosition(cc.p(135,160))
        goldInfoItem:addChild(goldItemValue)

        local sendButton = ccui.Button:create("landlordVideo/video_greenbutton_bg.png");
        sendButton:setScale9Enabled(true)
        sendButton:setContentSize(cc.size(125, 67))
        sendButton:setPosition(cc.p(135,30));
        sendButton:setTitleFontName(FONT_ART_BUTTON);
        sendButton:getTitleRenderer():enableOutline(COLOR_BTN_GREEN,2);
        sendButton:setTitleText("打赏");
        sendButton:setTitleColor(cc.c3b(255,255,255));
        sendButton:setTitleFontSize(28);
        goldInfoItem:addChild(sendButton)
        sendButton:setPressedActionEnabled(true);
        sendButton:addTouchEventListener(
            function(sender,eventType)
                if eventType == ccui.TouchEventType.ended then
                    self:onSendGold(i)
                end
            end
        )

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

function GoldInfoLayer:showGoldInfoLayer()
    self:show()
    self.curGoldLabel:setString(FormatDigitToString(DataManager:getMyUserInfo().score, 1))
end

function GoldInfoLayer:onSendGold(index)
    print("onSendGold:",index,self.goldArr[index])
    self:dispatchEvent({name=GameCenterEvent.EVENT_SEND_GOLD,gold=self.goldArr[index]})
end

function GoldInfoLayer:onCloseClick()
    self:hide()
end

return GoldInfoLayer
