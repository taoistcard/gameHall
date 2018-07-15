local VipRoomLayer = class("VipRoomLayer", function() return display.newLayer(); end );

function VipRoomLayer:ctor()
    local winSize = cc.Director:getInstance():getWinSize()
    -- 蒙板
    local maskLayer = ccui.ImageView:create()
    maskLayer:loadTexture("black.png")
    maskLayer:setOpacity(50)
    maskLayer:setContentSize(cc.size(1136, winSize.height));
    maskLayer:setPosition(cc.p(display.cx,display.cy))
    maskLayer:setScale9Enabled(true)
    maskLayer:setTouchEnabled(true)
    self:addChild(maskLayer)

    self:createUI()
    self.curPage = 1
    self.totalPageCount = 0
end

function VipRoomLayer:createUI()
    local titlelight = ccui.ImageView:create("common/effect_light.png");
    titlelight:setScaleY(0.94)
    titlelight:setScaleX(1.71)
    titlelight:setPosition(cc.p(568,535));
    self:addChild(titlelight);

    local zhuangshi4 = ccui.ImageView:create("hall/vipRoom/viproom_star2.png")
    zhuangshi4:setPosition(cc.p(1105,270))
    self:addChild(zhuangshi4)

    local vipRoomBg = ccui.ImageView:create("hall/vipRoom/vipRoomBg.png")
    vipRoomBg:setScale9Enabled(true)
    vipRoomBg:setContentSize(cc.size(1096,544))
    vipRoomBg:setPosition(cc.p(display.cx,270))
    self:addChild(vipRoomBg)

    local zhuangshi1 = ccui.ImageView:create("hall/vipRoom/viproom_star1.png")
    zhuangshi1:setPosition(cc.p(45,160))
    self:addChild(zhuangshi1)

    local zhuangshi2 = ccui.ImageView:create("hall/vipRoom/viproom_star2.png")
    zhuangshi2:setPosition(cc.p(46,37))
    self:addChild(zhuangshi2)

    local zhuangshi3 = ccui.ImageView:create("hall/vipRoom/viproom_star2.png")
    zhuangshi3:setPosition(cc.p(30,310))
    self:addChild(zhuangshi3)

    

    local zhuangshi5 = ccui.ImageView:create("hall/vipRoom/viproom_star3.png")
    zhuangshi5:setPosition(cc.p(1096,353))
    self:addChild(zhuangshi5)

    local zhuangshi6 = ccui.ImageView:create("hall/vipRoom/viproom_star4.png")
    zhuangshi6:setPosition(cc.p(1078,95))
    self:addChild(zhuangshi6)

    local title = ccui.ImageView:create("common/title.png");
    title:setPosition(cc.p(568,555));
    self:addChild(title);

    local titleTxt = ccui.ImageView:create("hall/vipRoom/title_viproom.png");
    titleTxt:setPosition(cc.p(153,70));
    title:addChild(titleTxt);

    --left button
    local leftButton = ccui.Button:create("hall/vipRoom/viproom_arrow.png");
    leftButton:setPosition(cc.p(70,265));
    vipRoomBg:addChild(leftButton);
    leftButton:setPressedActionEnabled(true);
    leftButton:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                -- SoundManager:getInstance():playSoundByType(SoundType.BTN_CLICK)
                local curPage = self.vipRoomPage:getCurPageIndex() 
                self.vipRoomPage:scrollToPage(curPage - 1)
            end
        end
    )
    self.leftButton = leftButton

    --right button
    local rightButton = ccui.Button:create("hall/vipRoom/viproom_arrow.png");
    rightButton:setPosition(cc.p(1026,265));
    rightButton:setFlippedX(true)
    vipRoomBg:addChild(rightButton);
    rightButton:setPressedActionEnabled(true);
    rightButton:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                -- SoundManager:getInstance():playSoundByType(SoundType.BTN_CLICK)
                local curPage = self.vipRoomPage:getCurPageIndex() 
                self.vipRoomPage:scrollToPage(curPage + 1)
            end
        end
    )
    self.rightButton = rightButton

    -- local maskLayer = cc.LayerColor:create(cc.c4b(255, 0, 0, 255))
    -- maskLayer:setContentSize(cc.size(912, 400));
    -- maskLayer:setPosition(cc.p(92, 80));
    -- vipRoomBg:addChild(maskLayer)

    self.vipRoomPage = ccui.PageView:create()
    self.vipRoomPage:setTouchEnabled(true)
    self.vipRoomPage:setContentSize(cc.size(912, 420))
    self.vipRoomPage:setPosition(cc.p(92,70))
    vipRoomBg:addChild(self.vipRoomPage)

    local function pageViewEvent(sender, eventType)
        if eventType == ccui.PageViewEventType.turning then
            local pageView = sender
            local curPage = pageView:getCurPageIndex() + 1
            self:resetButtonStatus(curPage)

            local pageInfo = string.format("page %d " , curPage)
            print("pageInfo:",pageInfo)
        end
    end 
    self.vipRoomPage:addEventListener(pageViewEvent)

    local vipHintText = ccui.Text:create("",FONT_ART_TEXT,20)
    vipHintText:setColor(cc.c3b(224,215,169))
    vipHintText:setString("提示：暂时VIP场没有门槛哦！")
    vipHintText:setAnchorPoint(cc.p(0,0.5))
    vipHintText:setPosition(cc.p(105,67))
    vipRoomBg:addChild(vipHintText)

    --关闭按钮
    local btn_close = ccui.Button:create("common/close.png");
    btn_close:setPosition(cc.p(1060,520));
    vipRoomBg:addChild(btn_close);
    btn_close:setPressedActionEnabled(true);
    btn_close:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                -- SoundManager:getInstance():playSoundByType(SoundType.BTN_CLICK)
                self:onCloseClick()
            end
        end
    )
end

function VipRoomLayer:resetButtonStatus(curPage)
    if curPage == 1 then
        self.leftButton:setVisible(false)
    else
        self.leftButton:setVisible(true)
    end

    if curPage == self.totalPageCount then
        self.rightButton:setVisible(false)
    else
        self.rightButton:setVisible(true)
    end
end

function VipRoomLayer:showVipRoomLayer()
    self:show()
    self.vipRoomPage:removeAllPages()

    local nodeItem = ServerInfo:getNodeItemByIndex(201, 1)
    if nodeItem == nil then
        print("nodeItem is nil")
        return
    end
    local serverArrCount = #nodeItem.serverList
    local pageCount = 1
    if (serverArrCount % 6) == 0 then
        pageCount = serverArrCount / 6
    else
        pageCount = math.modf(serverArrCount / 6) + 1
    end

    --初始化
    self.totalPageCount = pageCount
    self:resetButtonStatus(1)
    
    for i = 1 , pageCount do
        local layout = ccui.Layout:create()
        layout:setContentSize(cc.size(912, 420))

        local row = 1
        local col = 1
        for j=1,6 do
            local serverIndex = j + (i - 1)* 6
            if serverIndex > serverArrCount then
                break
            end
            local posX = (row - 1) * 304
            local posY = 420 - col * 210
            local vipRoomItemLayout = ccui.Layout:create()
            vipRoomItemLayout:setContentSize(cc.size(304, 208))
            vipRoomItemLayout:setPosition(cc.p(posX,posY))
            vipRoomItemLayout:setTouchEnabled(true)
            vipRoomItemLayout:addTouchEventListener(function(sender,eventType)
                if eventType == ccui.TouchEventType.ended then
                    -- SoundManager:getInstance():playSoundByType(SoundType.BTN_CLICK)
                    self:onConnectToRoom(serverIndex)
                end
            end)

            local vipRoomItemBg = ccui.ImageView:create("hall/vipRoom/viproom_itembg.png")
            vipRoomItemBg:setScale9Enabled(true)
            vipRoomItemBg:setContentSize(cc.size(282,210))
            vipRoomItemBg:setPosition(cc.p(152,105))
            vipRoomItemLayout:addChild(vipRoomItemBg)

            local anchorHeadImg = ccui.ImageView:create("hall/vipRoom/viproom_default.png")
            anchorHeadImg:setPosition(cc.p(151,121))
            vipRoomItemLayout:addChild(anchorHeadImg)

            local anchorStatusTxt = ccui.ImageView:create("hall/vipRoom/viproom_mmrest.png")
            anchorStatusTxt:setPosition(cc.p(151,58))
            vipRoomItemLayout:addChild(anchorStatusTxt)

            local anchorTextBg = ccui.ImageView:create("hall/vipRoom/viproom_textbg.png")
            anchorTextBg:setPosition(cc.p(151,28))
            vipRoomItemLayout:addChild(anchorTextBg)

            local anchorName = ccui.Text:create("",FONT_ART_TEXT,18)
            anchorName:setAnchorPoint(cc.p(0,0.5))
            anchorName:setPosition(cc.p(30,28))
            vipRoomItemLayout:addChild(anchorName)

            local anchorLoveliness = ccui.Text:create("",FONT_ART_TEXT,18)
            anchorLoveliness:setAnchorPoint(cc.p(1,0.5))
            anchorLoveliness:setPosition(cc.p(270,28))
            anchorLoveliness:setColor(cc.c3b(255,241,58))
            vipRoomItemLayout:addChild(anchorLoveliness)

            --更新数据
            local gameServer = nodeItem.serverList[serverIndex]
            if gameServer then
                --是否在线
                local isOnline = VideoAnchorManager:isOnline(gameServer.serverID)
                if isOnline == 99 then --主播不存在
                    --头像
                    anchorHeadImg:setScale(0.67)
                    --昵称
                    local nickName = gameServer.serverName
                    anchorName:setString(FormotGameNickName(nickName, 5))
                    --是否在线
                    anchorStatusTxt:setVisible(false)
                    --魅力
                    anchorLoveliness:setString("魅力：无限")
                else
                    --头像
                    local userID = VideoAnchorManager:getAnchorUserID(gameServer.serverID)
                    local writablePath = cc.FileUtils:getInstance():getWritablePath()
                    local ANCHOR_FOLDER = writablePath.."videoAnchor/"
                    local filePath = ANCHOR_FOLDER.."anchor_"..userID..".png"
                    if cc.FileUtils:getInstance():isFileExist(filePath) then
                        anchorHeadImg:loadTexture(filePath)
                    else
                        anchorHeadImg:loadTexture("hall/vipRoom/vip_1078.png")

                    end
                    anchorHeadImg:setScale(0.57)
                    --昵称
                    local nickName = VideoAnchorManager:getAnchorName(gameServer.serverID)
                    anchorName:setString(FormotGameNickName(nickName, 5))
                    --是否在线
                    local isOnline = VideoAnchorManager:isOnline(gameServer.serverID)
                    if isOnline == 1 then
                        anchorStatusTxt:setVisible(false)
                    else
                        anchorStatusTxt:setVisible(true)
                    end
                    --魅力
                    local loveliness = VideoAnchorManager:getVipAnchorLoveliness(gameServer.serverID)
                    anchorLoveliness:setString("魅力："..loveliness)
                end
            end

            layout:addChild(vipRoomItemLayout)

            row = row + 1
            if row > 3  then
                row = 1
                col = col + 1
            end
        end

        self.vipRoomPage:addPage(layout)

    end
end

function VipRoomLayer:onConnectToRoom(index)
    local nodeItem = ServerInfo:getNodeItemByIndex(201, 1)
    if nodeItem == nil then
        print("nodeItem is nil")
        return
    end
    local gameServer = nodeItem.serverList[index]
    if gameServer == nil then
        print("gameServer is nil")
        return
    end
    RunTimeData:setCurGameServer(gameServer)
    RunTimeData:setRoomIndex(index)
    local info = PlayerInfo
    if (info ~= nil) then
        info:clearAllUserInfo()
    end
    print("VipRoomLayer gameServer.serverAddr,gameServer.serverPort==",gameServer.serverAddr,gameServer.serverPort)
    GameConnection:connectRoomServer(gameServer.serverAddr,gameServer.serverPort)
    Hall.showWaiting(15)

end

function VipRoomLayer:onCloseClick()
    self:hide()
end

return VipRoomLayer
