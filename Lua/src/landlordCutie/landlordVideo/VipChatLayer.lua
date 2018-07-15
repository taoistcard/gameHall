local VipChatLayer = class("VipChatLayer", function() return display.newLayer() end) --require("common.ui.CCModelView"))



function VipChatLayer:ctor()

    local winSize = cc.Director:getInstance():getWinSize()
    local contentSize = cc.size(1136,winSize.height)
    -- 蒙板
    local maskLayer = ccui.ImageView:create("blank.png")
    maskLayer:setScale9Enabled(true)
    maskLayer:setContentSize(contentSize)
    maskLayer:setPosition(cc.p(display.cx, display.cy));
    maskLayer:setTouchEnabled(true)
    self:addChild(maskLayer)
    maskLayer:setTouchEnabled(true)
    maskLayer:addTouchEventListener(function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:hide()
            end
        end)
    local maskImg = ccui.ImageView:create("landlordVideo/video_mask.png")
    maskImg:setPosition(cc.p(757, winSize.height / 2));
    maskLayer:addChild(maskImg)

    self:createUI()

    --聊天记录数组
    self.historyChatContent = {}
    --初始化tab
    self.curTab = nil
    self:onClickTab(1)
end

function VipChatLayer:createUI()
    local chatLayer = ccui.ImageView:create("view/frame3.png");
    chatLayer:setScale9Enabled(true)
    chatLayer:setContentSize(cc.size(480,590))
    chatLayer:setPosition(cc.p(808,320))
    self:addChild(chatLayer)
    self.chatLayer = chatLayer

    local chatContainer = ccui.ImageView:create("view/frame2.png");
    chatContainer:setScale9Enabled(true)
    chatContainer:setContentSize(cc.size(434,474))
    chatContainer:setPosition(cc.p(238,320))
    chatLayer:addChild(chatContainer)

    local chatTabPos = {
        {90,45},
        {240,45},
        {390,45}
    }
    for i=1,3 do
        local chatTab = ccui.ImageView:create("landlordVideo/videoChat/chatTab_normal"..i..".png");
        chatTab:setName("chatTab"..i)
        chatTab:setTouchEnabled(true)
        chatTab:setPosition(cc.p(chatTabPos[i][1],chatTabPos[i][2]))
        chatLayer:addChild(chatTab)
        chatTab:addTouchEventListener(function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:onClickTab(i)
            end
        end)
    end

    --快速聊天
    local quickMsgLayer = ccui.ScrollView:create()
    quickMsgLayer:setVisible(false)
    quickMsgLayer:setTouchEnabled(true)
    quickMsgLayer:setContentSize(chatContainer:getContentSize())
    chatContainer:addChild(quickMsgLayer)
    local msgCount = #customQuickMsg
    quickMsgLayer:setInnerContainerSize(cc.size(440, 80*msgCount))
    local index = 1
    for i=msgCount,1,-1 do
        local customMsgItem = ccui.Layout:create()
        customMsgItem:setContentSize(cc.size(412,80))
        customMsgItem:setTouchEnabled(true)
        customMsgItem:addTouchEventListener(function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                print("onclick:",i,customQuickMsg[i])
                self:sendMsgText(customQuickMsg[i])
                self:hide()
            end
        end)
        local posY = 80 * (index-1)
        index = index + 1
        customMsgItem:setPosition(cc.p(0,posY))
        quickMsgLayer:addChild(customMsgItem)

        local sepLine = ccui.ImageView:create("common/sep_line.png")
        sepLine:setScale9Enabled(true)
        sepLine:setContentSize(390,3)
        sepLine:setPosition(cc.p(quickMsgLayer:getContentSize().width/2,0))
        customMsgItem:addChild(sepLine)

        local msgText = ccui.Text:create()
        msgText:setFontSize(22)
        msgText:setColor(cc.c3b(251,237,174))
        msgText:setString(customQuickMsg[i])
        msgText:setAnchorPoint(cc.p(0,0.5))
        msgText:setPosition(cc.p(50,30))
        customMsgItem:addChild(msgText)
    end
    
    self.quickMsgLayer = quickMsgLayer
    -- 表情
    local quickBiaoqingLayer = ccui.Layout:create()
    quickBiaoqingLayer:setVisible(false)
    quickBiaoqingLayer:setContentSize(chatContainer:getContentSize())
    chatContainer:addChild(quickBiaoqingLayer)
    local line = display.newScale9Sprite("common/sep_line.png", 145, 237, cc.size(450, 2)):addTo(quickBiaoqingLayer)
    line:setRotation(90)
    
    line = display.newScale9Sprite("common/sep_line.png", 290, 237, cc.size(450, 2)):addTo(quickBiaoqingLayer)
    line:setRotation(90)

    line = display.newScale9Sprite("common/sep_line.png", 217, 119, cc.size(410, 2)):addTo(quickBiaoqingLayer)
    display.newScale9Sprite("common/sep_line.png", 217, 238, cc.size(410, 2)):addTo(quickBiaoqingLayer)
    display.newScale9Sprite("common/sep_line.png", 217, 357, cc.size(410, 2)):addTo(quickBiaoqingLayer)

    local row = 1
    local col = 1
    for i,v in ipairs(customBqName) do
        local posX = (col - 1) * 145 + 72
        local posY = quickBiaoqingLayer:getContentSize().height - ((row - 1) * 120 + 60)
        col = col + 1;
        if(col>3) then
            row=row+1;
            col=1;
        end

        local biaoqingButton = ccui.Button:create()
        local biaoqingName = "chat/bq/"..v..".png"
        biaoqingButton:loadTextures(biaoqingName,biaoqingName)
        biaoqingButton:setScale(0.6)
        biaoqingButton:setPressedActionEnabled(true)
        biaoqingButton:setPosition(cc.p(posX,posY))
        quickBiaoqingLayer:addChild(biaoqingButton)
        biaoqingButton:addTouchEventListener(function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                print("onclick:",i,v)
                local biaoqingText = "[`"..v.."`]"
                -- self:sendBiaoqing(i)
                -- self:hide()
                self:sendMsgText(biaoqingText)
                self:hide()
            end
        end)
    end
    self.quickBiaoqingLayer = quickBiaoqingLayer
    --历史聊天记录
    local historylistView = ccui.Layout:create()
    historylistView:setVisible(false)
    historylistView:setContentSize(chatContainer:getContentSize())
    chatContainer:addChild(historylistView)
    self.historylistView = historylistView

    -- local maskLayer = cc.LayerColor:create(cc.c4b(255, 0, 0, 255))
    -- maskLayer:setContentSize(cc.size(420, 395));
    -- maskLayer:setPosition(cc.p(8, 70));
    -- historylistView:addChild(maskLayer)

    local chatHistoryView = ccui.ListView:create()
    chatHistoryView:setDirection(ccui.ScrollViewDir.vertical)
    chatHistoryView:setBounceEnabled(true)
    chatHistoryView:setContentSize(cc.size(420, 395))
    chatHistoryView:ignoreAnchorPointForPosition(true)
    chatHistoryView:setPosition(cc.p(8, 70))
    historylistView:addChild(chatHistoryView)
    self.chatHistoryView = chatHistoryView

    local inputContainer = ccui.ImageView:create("landlordVideo/videoChat/video_chat_input_bg.png")
    inputContainer:setScale9Enabled(true)
    inputContainer:setCapInsets(cc.rect(67,36,1,1))
    inputContainer:setContentSize(cc.size(445,74))
    inputContainer:setPosition(cc.p(220,30))
    historylistView:addChild(inputContainer)
    local inputEditBg = ccui.ImageView:create("view/frame2.png")
    inputEditBg:setScale9Enabled(true)
    inputEditBg:setContentSize(cc.size(260,49))
    inputEditBg:setPosition(cc.p(140,42))
    inputContainer:addChild(inputEditBg)

    local chatEditBox = ccui.EditBox:create(cc.size(250,45),"common/blank.png")
    chatEditBox:setPosition(cc.p(20,13))
    chatEditBox:ignoreAnchorPointForPosition(true)
    chatEditBox:setPlaceHolder("请输入聊天内容")
    inputContainer:addChild(chatEditBox)

    local sendButton = ccui.Button:create("landlordVideo/video_greenbutton_bg.png");
    sendButton:setScale9Enabled(true)
    sendButton:setContentSize(cc.size(125, 67))
    sendButton:setPosition(cc.p(360,37));
    sendButton:setTitleFontName(FONT_ART_BUTTON);
    sendButton:getTitleRenderer():enableOutline(COLOR_BTN_GREEN,2);
    sendButton:setTitleText("发送");
    sendButton:setTitleColor(cc.c3b(255,255,255));
    sendButton:setTitleFontSize(28);
    inputContainer:addChild(sendButton)
    sendButton:setPressedActionEnabled(true);
    sendButton:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:sendMsgText(chatEditBox:getText())
                chatEditBox:setText("")
            end
        end
    )
    self.chatEditBox = chatEditBox
    
    --关闭按钮
    local closeButton = ccui.Button:create("common/close.png")
    closeButton:setPressedActionEnabled(true)
    closeButton:setPosition(cc.p(465,565))
    chatLayer:addChild(closeButton)
    closeButton:addTouchEventListener(function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                -- SoundManager.playSound("sound/buttonclick.mp3")
                self:hide()
            end
        end)
end

function VipChatLayer:showVipChatLayer()
    self:show()
    self:onClickTab(self.curTab)
end

function VipChatLayer:refreshHistory()
    self.chatHistoryView:removeAllChildren()
    local histroyCount = table.getn(self.historyChatContent)
    for i=histroyCount,1,-1 do
        local msgContent = self.historyChatContent[i]
        local customItem = ccui.Layout:create()
        customItem:setContentSize(cc.size(412,112))

        -- local headBorder = ccui.ImageView:create("landlordVideo/selfhead_border.png")
        -- headBorder:setScale9Enabled(true)
        -- headBorder:setCapInsets(cc.rect(19,20,1,1))
        -- headBorder:setContentSize(cc.size(100,100))
        -- local headImg = ccui.ImageView:create()
        -- if msgContent.faceID >= 1 and msgContent.faceID <= 37 then
        --     headImg:loadTexture("head/head_"..msgContent.faceID..".png")
        -- else
        --     headImg:loadTexture("head/default.png")
        -- end
        -- headImg:setPosition(cc.p(47,53))
        -- headImg:setScale(0.7)
        -- headBorder:addChild(headImg)
        -- customItem:addChild(headBorder)
        local headView = require("commonView.GameHeadView").new();
        -- headView:setPosition(headIcon:getPositionX()+3,headIcon:getPositionY()-3)
        headView:setScale(0.8)
        headView:setNewHead(msgContent.head.faceID,msgContent.head.tokenID,msgContent.head.headFile)
        customItem:addChild(headView)
        headView:setVipHead(msgContent.head.member,1)

        local nicknameText = ccui.Text:create()
        nicknameText:setFontSize(18)
        nicknameText:setString(FormotGameNickName(msgContent.nickName,5))
        customItem:addChild(nicknameText)

        local chatContent = self:formatChatContent(msgContent.content)
        -- local chatContent = nil
        -- if msgContent.type == 2 then
        --     chatContent = ccui.ImageView:create(customFace[msgContent.content])
        --     chatContent:setScale(0.6)
        -- else
        --     chatContent = ccui.Text:create()
        --     chatContent:setString(msgContent.content)
        --     chatContent:ignoreContentAdaptWithSize(false)
        --     chatContent:setContentSize(cc.size(290,100))
        --     chatContent:setFontSize(23)
        --     chatContent:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT);
        --     chatContent:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER);
        -- end
        customItem:addChild(chatContent)
        if msgContent.type == 4 then
            chatContent:setTextColor(cc.c4b(246,0,0,255))
        end

        if msgContent.sendUserId == DataManager:getMyUserID() then
            headView:setPosition(cc.p(355,66))
            nicknameText:setPosition(cc.p(355,16))
            nicknameText:setTextColor(cc.c4b(246,235,127,255))
            chatContent:setAnchorPoint(cc.p(1,0.5))
            chatContent:setPosition(cc.p(305,56))
            -- if msgContent.type ~= 2 then
            --     chatContent:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_RIGHT);
            -- end
        else
            headView:setPosition(cc.p(60,66))
            nicknameText:setPosition(cc.p(60,16))
            nicknameText:setTextColor(cc.c4b(61,225,252,255))
            chatContent:setAnchorPoint(cc.p(0,0.5))
            chatContent:setPosition(cc.p(120,56))
            -- if msgContent.type ~= 2 then
            --     chatContent:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT);
            -- end
        end
        local sepLine = ccui.ImageView:create("common/sep_line.png")
        sepLine:setScale9Enabled(true)
        sepLine:setContentSize(390,3)
        sepLine:setPosition(cc.p(customItem:getContentSize().width/2,0))
        customItem:addChild(sepLine)

        self.chatHistoryView:pushBackCustomItem(customItem)
    end
end

function VipChatLayer:formatChatContent(contentStr)
    local chatContent = nil

    local contentLen = string.len(contentStr)
    local index = 1
    local startIndex = string.find(contentStr,"[`",index,true)
    if startIndex ~= nil then
        local endIndex = string.find(contentStr,"`]",startIndex + 1,true)
        local imgName = string.sub(contentStr,startIndex+2,endIndex-1)
        chatContent = cc.Sprite:create("chat/bq/"..imgName..".png")
        -- chatContent:setScale(0.5)
        -- local endIndex = string.find(contentStr,"`]",startIndex + 1,true)
        -- local richTag = 1
        -- chatContent = ccui.RichText:create()
        -- chatContent:ignoreContentAdaptWithSize(false)
        -- -- chatContent:setAnchorPoint(cc.p(0,0))
        -- chatContent:setPosition(cc.p(145,50))
        -- chatContent:setContentSize(cc.size(290,100))
        -- repeat
        --     local text1 = string.sub(contentStr,index,startIndex-1)
        --     if text1 ~= nil and text1 ~= "" then
        --         local re1 = ccui.RichElementText:create(richTag, cc.c3b(255,255,128), 255, text1, "Helvetica", 23)
        --         chatContent:pushBackElement(re1)
        --         richTag = richTag + 1
        --     end

            -- local imgName = string.sub(contentStr,startIndex+2,endIndex-1)
        --     local re2 = ccui.RichElementImage:create(richTag, cc.c3b(255, 255, 255), 255, "chat/bq/"..imgName..".png")
        --     re2:setScale(0.3)
        --     chatContent:pushBackElement(re2)
        --     richTag = richTag + 1

        --     print("text1,imgName",text1,imgName)
        --     index = endIndex + 2
        --     startIndex = string.find(contentStr,"[`",index,true)
        --     if startIndex == nil then
        --         local text2 = string.sub(contentStr,index,contentLen)
        --         if text2 ~= nil and text2 ~= "" then
        --             local re3 = ccui.RichElementText:create(richTag, cc.c3b(255,255,128), 255, text2, "Helvetica", 23)
        --             chatContent:pushBackElement(re3)
        --             print("text2",text2)
        --         end
        --         break
        --     end
        --     endIndex = string.find(contentStr,"`]",startIndex + 1,true)
        --     if endIndex == nil then
        --         break
        --     end
        -- until false
    else
        chatContent = ccui.Text:create()
        chatContent:setString(contentStr)
        chatContent:ignoreContentAdaptWithSize(false)
        chatContent:setContentSize(cc.size(290,100))
        chatContent:setFontSize(23)
        chatContent:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT);
        chatContent:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER);
    end
    return chatContent
end

function VipChatLayer:sendBiaoqing(index)
    --[[{
        required int32                          wItemIndex=1;                           //表情索引
        required int32                          dwTargetUserID=2;                       //目标用户
    }]]
    local data = protocol.game.gameServer_pb.CMD_GF_C_UserExpression_Pro()

    data.wItemIndex = index
    data.dwTargetUserID = 0

    local pData = data:SerializeToString()
    local pDataLen = string.len(pData)


    GameCenter:sendData(CMD_GameServer.MDM_GF_FRAME,CMD_GameServer.SUB_GF_USER_EXPRESSION, pData, pDataLen)

end

function VipChatLayer:sendMsgText(msgText)
    --[[{
        required int32                          wChatLength=1;                      //信息长度
        required int32                          dwChatColor=2;                      //信息颜色
        required int32                          dwTargetUserID=3;                   //目标用户
        required string                         szChatString=4;                     //聊天信息
    }]]
    -- local data = protocol.game.gameServer_pb.CMD_GF_C_UserChat_Pro()

    -- data.wChatLength = string.len(msgText)
    -- data.dwChatColor = 255
    -- data.dwTargetUserID = 0
    -- data.szChatString = msgText

    -- local pData = data:SerializeToString()
    -- local pDataLen = string.len(pData)

    -- GameCenter:sendData(CMD_GameServer.MDM_GF_FRAME,CMD_GameServer.SUB_GF_USER_CHAT, pData, pDataLen)
    local gameServer = RunTimeData:getCurGameServer()
    local platFormUserID = DataManager:getMyUserInfo().tokenID
    local roomID = VideoAnchorManager:getAnchorRoomID(gameServer:getServerID())
    local nickName = DataManager:getMyUserInfo().nickName
    local userID = DataManager:getMyUserID()

    sendTextMsg(msgText,platFormUserID,roomID,nickName,userID)
end

function VipChatLayer:onReceiveChatMsg(msgContent)
    local histroyCount = table.getn(self.historyChatContent)
    if histroyCount >= 20 then
        table.remove(self.historyChatContent,1)
    end
    table.insert(self.historyChatContent, msgContent)

    if self:isVisible() and self.curTab == 1 then
        self:refreshHistory()
    end
end

function VipChatLayer:onClickTab(index)
    for i=1,3 do
        local chatTab = self.chatLayer:getChildByName("chatTab"..i)
        if i == index then
            chatTab:loadTexture("landlordVideo/videoChat/chatTab_select"..i..".png");
        else
            chatTab:loadTexture("landlordVideo/videoChat/chatTab_normal"..i..".png");
        end
    end
    self.curTab = index

    self.quickMsgLayer:setVisible(false)
    self.quickBiaoqingLayer:setVisible(false)
    self.historylistView:setVisible(false)
    if index == 1 then
        self.historylistView:setVisible(true)
        self:refreshHistory()
    elseif index == 2 then
        self.quickBiaoqingLayer:setVisible(true)
    elseif index == 3 then
        self.quickMsgLayer:setVisible(true)
    end
end

return VipChatLayer