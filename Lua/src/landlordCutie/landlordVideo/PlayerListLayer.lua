local PlayerListLayer = class("PlayerListLayer", function() return display.newLayer(); end );

function PlayerListLayer:ctor()
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

    self:createUI()
    self.playerList = {}
end

function PlayerListLayer:createUI()
    local playerList = ccui.ImageView:create()
    playerList:loadTexture("common/pop_bg.png")
    playerList:setScale9Enabled(true)
    playerList:setContentSize(cc.size(622,622))
    playerList:setCapInsets(cc.rect(115,215,1,1))
    playerList:setPosition(cc.p(815,315))
    self:addChild(playerList)
    local title_text_bg = ccui.ImageView:create()
    title_text_bg:loadTexture("common/pop_title.png")
    title_text_bg:setAnchorPoint(cc.p(0,0.5))
    title_text_bg:setPosition(cc.p(45,580))
    playerList:addChild(title_text_bg)
    local title_text = ccui.Text:create("无座玩家", FONT_ART_TEXT, 24)
    title_text:setColor(cc.c3b(255,233,110));
    title_text:enableOutline(cc.c4b(141,0,166,255*0.7),2);
    title_text:setPosition(cc.p(68,65));
    title_text:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER);
    title_text_bg:addChild(title_text);

    -- local maskLayer = cc.LayerColor:create(cc.c4b(255, 0, 0, 255))
    -- maskLayer:setContentSize(cc.size(520, 482));
    -- maskLayer:setPosition(cc.p(60, 56));
    -- self:addChild(maskLayer)
    self.listView = ccui.ListView:create()
    self.listView:setDirection(ccui.ScrollViewDir.vertical)
    self.listView:setBounceEnabled(true)
    self.listView:setContentSize(cc.size(520, 482))
    self.listView:setPosition(60,56)
    playerList:addChild(self.listView)
    -- ListView点击事件回调
    local function listViewEvent(sender, eventType)
        -- 事件类型为点击结束
        if eventType == ccui.ListViewEventType.ONSELECTEDITEM_END then
            print("select child index = ",sender:getCurSelectedIndex())
            self:dispatchEvent({name=GameCenterEvent.EVENT_SHOW_PLAYER_DETAIL,playerInfo = self.playerList[sender:getCurSelectedIndex() + 1]})
            self:hide()
        end
    end
    -- 设置ListView的监听事件
    self.listView:addEventListener(listViewEvent)

    --关闭按钮
    local closeButton = ccui.Button:create()
    closeButton:setTouchEnabled(true)
    closeButton:setPressedActionEnabled(true)
    closeButton:loadTextures("common/close.png","common/close.png")
    closeButton:setPosition(cc.p(590,585))
    playerList:addChild(closeButton)
    closeButton:addTouchEventListener(function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                SoundManager.playSound("sound/buttonclick.mp3")
                self:onCloseClick()
            end
        end)
end

function PlayerListLayer:onCloseClick()
    self:hide()
end

function PlayerListLayer:showPlayerList(otherPlayerList)
    self:show()
    self.listView:removeAllItems()
    local playerCount = table.maxn(otherPlayerList)
    if playerCount == 0 then
        return
    end
    self.playerList = otherPlayerList

    for i = 1,playerCount do
        local custom_item = ccui.Layout:create()
        custom_item:setTouchEnabled(true)
        custom_item:setContentSize(cc.size(520,130))
        self.listView:pushBackCustomItem(custom_item)

        local otherPlayerInfo = otherPlayerList[i]

        local playerInfoItemBg = ccui.ImageView:create("common/panel.png")
        playerInfoItemBg:setScale9Enabled(true)
        playerInfoItemBg:setContentSize(cc.size(520,120))
        playerInfoItemBg:setPosition(cc.p(260,65))
        custom_item:addChild(playerInfoItemBg)
        
        --什么鬼小花装饰
        local banner = ccui.Text:create("*", "", 70)
        banner:addTo(playerInfoItemBg)
        banner:setColor(cc.c3b(255,255,0))
        banner:setPosition(cc.p(40, 50))

        --头像
        local headItem = ccui.ImageView:create()
        headItem:loadTexture("landlordVideo/selfhead_border.png")
        headItem:setScale9Enabled(true)
        headItem:setContentSize(cc.size(96,96))
        headItem:setCapInsets(cc.rect(19,20,1,1))
        headItem:setPosition(cc.p(120,55))
        playerInfoItemBg:addChild(headItem)
        --头像👦
        local headView = require("commonView.GameHeadView").new(1);
        headView:addTo(headItem)
        headView:setPosition(cc.p(44,52))
        headView:setNewHead(otherPlayerInfo.faceID, otherDataManager.platformID,otherDataManager.platformFace)
        --VIP
        headView:setVipHead(otherPlayerInfo.memberOrder, 1)
        -- local headImage = ccui.ImageView:create()
        -- headImage:setTouchEnabled(true)
        -- headImage:setScale(0.66)
        -- if otherPlayerInfo.faceID > 0 then
        --     headImage:loadTexture("head/head_"..otherPlayerInfo.faceID..".png")
        -- else
        --     headImage:loadTexture("head/default.png")
        -- end
        -- headImage:setPosition(cc.p(44,52))
        -- headItem:addChild(headImage)
        -- local vipImage = ccui.ImageView:create()
        -- vipImage:setPosition(cc.p(90,100))
        -- headItem:addChild(vipImage)
        -- if OnlineConfig_review == "on" then
        --     vipImage:setVisible(false)
        -- else
        --     if otherPlayerInfo.memberOrder >= 1 and otherPlayerInfo.memberOrder <= 5 then
        --         vipImage:setVisible(true)
        --         vipImage:loadTexture("hall/shop/zuan"..otherPlayerInfo.memberOrder..".png")
        --     else
        --         vipImage:setVisible(false)
        --     end
        -- end
        --昵称
        local nickName = ccui.Text:create()
        nickName:setFontSize(24)
        nickName:setString(FormotGameNickName(otherDataManager.nickName, 10))
        -- nickName:setString(otherDataManager.nickName)
        nickName:setAnchorPoint(cc.p(0,0.5))
        nickName:setPosition(cc.p(190,95))
        playerInfoItemBg:addChild(nickName)
        --金币
        local goldImage = ccui.ImageView:create()
        goldImage:loadTexture("common/gold.png")
        goldImage:setPosition(cc.p(190,60))
        goldImage:setScale(0.6)
        goldImage:setAnchorPoint(cc.p(0,0.5))
        playerInfoItemBg:addChild(goldImage)
        local goldLabel = ccui.Text:create()
        goldLabel:setString(FormatDigitToString(otherPlayerInfo.score, 1))
        goldLabel:setFontSize(24)
        goldLabel:setColor(cc.c3b(253,127,42))
        goldLabel:setAnchorPoint(cc.p(0,0.5))
        goldLabel:setPosition(cc.p(230,60))
        playerInfoItemBg:addChild(goldLabel)
        --魅力
        local loveliness = ccui.Text:create()
        loveliness:setColor(cc.c3b(255,255,0))
        loveliness:setFontSize(24)
        loveliness:setString("魅力值："..otherPlayerInfo:loveliness())
        loveliness:setAnchorPoint(cc.p(0,0.5))
        loveliness:setPosition(cc.p(190,25))
        playerInfoItemBg:addChild(loveliness)      
    end
end

return PlayerListLayer
