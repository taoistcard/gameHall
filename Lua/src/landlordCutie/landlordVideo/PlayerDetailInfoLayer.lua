local PlayerDetailInfoLayer = class("PlayerDetailInfoLayer",function() return display.newLayer() end)



function PlayerDetailInfoLayer:ctor()
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    -- self:setNodeEventEnabled(true)
    -- self:registerGameEvent();
    
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
    
    self:createUI()
    self.userID = nil
end

function PlayerDetailInfoLayer:createUI()
    local contentSize = self:getContentSize()

    local detailInfoContainer = ccui.ImageView:create("view/frame3.png")
    detailInfoContainer:setScale9Enabled(true)
    detailInfoContainer:setContentSize(cc.size(510,390))
    detailInfoContainer:setPosition(cc.p(815,display.cy + 10))
    self:addChild(detailInfoContainer)

    local frame1 = ccui.ImageView:create("view/frame1.png")
    frame1:setScale9Enabled(true)
    frame1:setContentSize(cc.size(420,170))
    frame1:setPosition(cc.p(255,270))
    detailInfoContainer:addChild(frame1)
    --头像
    local headBorder = ccui.ImageView:create("landlordVideo/selfhead_border.png")
    headBorder:setScale9Enabled(true)
    headBorder:setContentSize(cc.size(125,125))
    headBorder:setCapInsets(cc.rect(19,20,1,1))
    headBorder:setPosition(cc.p(100,80))
    frame1:addChild(headBorder)
    local headImage = ccui.ImageView:create()
    headImage:setName("HeadImage")
    headImage:setScale(0.9)
    headImage:loadTexture("head/default.png")
    headImage:setPosition(cc.p(60,67))
    headBorder:addChild(headImage)
    self.headImage = headImage
    local vipImage = ccui.ImageView:create("hall/shop/zuan1.png")
    vipImage:setName("VipImage")
    vipImage:setPosition(cc.p(110,120))
    headBorder:addChild(vipImage)
    self.vipImage = vipImage
    --昵称
    self.nickNameLabel = ccui.Text:create("百人斗地主",FONT_ART_TEXT,20)
    self.nickNameLabel:setColor(cc.c3b(253,253,253))
    self.nickNameLabel:enableOutline(cc.c3b(7,1,3), 2)
    self.nickNameLabel:setAnchorPoint(cc.p(0,0.5))
    self.nickNameLabel:setPosition(cc.p(175,120))
    frame1:addChild(self.nickNameLabel)
    --等级
    self.levelLabel = ccui.Text:create("Lv.33",FONT_ART_TEXT,20)
    self.levelLabel:setColor(cc.c3b(253,253,253))
    self.levelLabel:enableOutline(cc.c3b(7,1,3), 2)
    self.levelLabel:setAnchorPoint(cc.p(0,0.5))
    self.levelLabel:setPosition(cc.p(175,90))
    frame1:addChild(self.levelLabel)
    --金币
    local goldImage = ccui.ImageView:create()
    goldImage:loadTexture("common/gold.png")
    goldImage:setPosition(cc.p(175,60))
    goldImage:setScale(0.6)
    goldImage:setAnchorPoint(cc.p(0,0.5))
    frame1:addChild(goldImage)
    self.goldLabel = ccui.Text:create("9999.9万",FONT_ART_TEXT,22)
    self.goldLabel:setColor(cc.c3b(255,237,86))
    self.goldLabel:enableOutline(cc.c3b(0,4,8), 2)
    self.goldLabel:setAnchorPoint(cc.p(0,0.5))
    self.goldLabel:setPosition(cc.p(210,60))
    frame1:addChild(self.goldLabel)
    --ID
    self.gameIDLabel = ccui.Text:create("ID:5521325",FONT_ART_TEXT,20)
    self.gameIDLabel:setColor(cc.c3b(253,253,253))
    self.gameIDLabel:enableOutline(cc.c3b(7,1,3), 2)
    self.gameIDLabel:setAnchorPoint(cc.p(0,0.5))
    self.gameIDLabel:setPosition(cc.p(175,30))
    frame1:addChild(self.gameIDLabel)

    local archiveInfoBg = ccui.ImageView:create("landlordVideo/roomSumInfoBg.png")
    archiveInfoBg:setScale9Enabled(true)
    archiveInfoBg:setContentSize(cc.size(400,46))
    archiveInfoBg:setPosition(cc.p(255,145))
    detailInfoContainer:addChild(archiveInfoBg)
    self.archiveLabel = ccui.Text:create("历史最高金额：暂无数据",FONT_ART_TEXT,20)
    self.archiveLabel:setColor(cc.c3b(253,253,253))
    self.archiveLabel:enableOutline(cc.c3b(7,1,3), 2)
    self.archiveLabel:setPosition(cc.p(200,23))
    archiveInfoBg:addChild(self.archiveLabel)

    local sendGiftButton = ccui.Button:create("landlordVideo/video_greenbutton_bg.png");
    sendGiftButton:setScale9Enabled(true)
    sendGiftButton:setContentSize(cc.size(205,67))
    sendGiftButton:setPosition(cc.p(255,70));
    sendGiftButton:setTitleFontName(FONT_ART_BUTTON);
    sendGiftButton:getTitleRenderer():enableOutline(COLOR_BTN_GREEN,2);
    sendGiftButton:setTitleText("赠送礼物");
    sendGiftButton:setTitleColor(cc.c3b(255,255,255));
    sendGiftButton:setTitleFontSize(28);
    detailInfoContainer:addChild(sendGiftButton);
    sendGiftButton:setPressedActionEnabled(true);
    sendGiftButton:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:dispatchEvent({name=GameCenterEvent.EVENT_SEND_GIFT,targetUserID = self.userID})
                self:hide()
            end
        end
    )

    local exit = ccui.Button:create("common/close.png");
    exit:setPosition(cc.p(490,370));
    detailInfoContainer:addChild(exit);
    exit:setPressedActionEnabled(true);
    exit:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:hide()
            end
        end
    )
end

function PlayerDetailInfoLayer:showPlayerDetailInfo(playerInfo)
    self:show()
    self.userID = playerInfo.userID
    if playerInfo.faceID >= 1 and playerInfo.faceID <= 37 then
        self.headImage:loadTexture("head/head_"..playerInfo.faceID..".png")
    elseif playerInfo.faceID == 999 then
        local tokenID = DataManager.platformID;    
        self.headImage:loadTexture(RunTimeData:getLocalAvatarImageUrlByTokenID(tokenID))
    else
        self.headImage:loadTexture("head/default.png")
    end
    --vip
    if OnlineConfig_review == "on" then
        self.vipImage:setVisible(false)
    else
        if playerInfo.memberOrder >= 1 and playerInfo.memberOrder <= 5 then
            self.vipImage:setVisible(true)
            self.vipImage:loadTexture("hall/shop/zuan"..playerInfo.memberOrder..".png")
        else
            self.vipImage:setVisible(false)
        end
    end
    -- 昵称
    self.nickNameLabel:setString(FormotGameNickName(DataManager.nickName, 6) )
    --等级
    self.levelLabel:setString("Lv."..getLevelByExp(playerInfo.medal))
    -- 筹码
    self.goldLabel:setString(FormatDigitToString(playerInfo.score,1))
    -- ID
    self.gameIDLabel:setString("ID:"..playerInfo.tagUserInfo.dwGameID)
    --成就
    self.archiveLabel:setString("历史最高金额："..FormatDigitToString(playerInfo.tagUserInfo.lHighestScore, 1))
end

return PlayerDetailInfoLayer