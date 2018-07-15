--
-- Author: <zhaxun>
-- Date: 2015-05-29 15:49:58
--

local ViewMessage = class("ViewMessage", function() return display.newNode() end) --require("common.ui.CCModelView"))



local winWidth = 435
local winHeight = 580

local pathFace = {"chat/bq/mmd.png",
                    "chat/bq/baonv.png",
                    "chat/bq/bukaixin.png",
                    "chat/bq/ciya.png",
                    "chat/bq/keshui.png",
                    "chat/bq/liulei.png",
                    "chat/bq/miexiao.png",
                    "chat/bq/nvhuo.png",
                    "chat/bq/qidao.png",
                    "chat/bq/tiaoxin.png",
                    "chat/bq/xinsui.png",
                    "chat/bq/yundao.png"}

local pathQuickMsg = {"大家好，很高兴见到各位",
                        "和你合作真是太愉快了",
                        "快点啊，等得花儿都谢了",
                        "你的牌打的也太好了",
                        "不要吵不要吵，专心玩游戏吧",
                        "怎么又断线，网络怎么这么差啊",
                        "不好意思，我要离开一会儿",
                        "不要走，决战到天亮",
                        "你是MM还是GG",
                        "交个朋友吧，能告诉我联系方式吗",
                        "再见了，我会想念大家的"}

function ViewMessage:switchChairID()
    self.myChairID = DataManager:getMyChairID()
    print("ViewMessage:switchChairID", self.count, self.myChairID)
    if self.count == 3 then
        if self.myChairID == 1 then
            self.nextID = 2
            self.preID = 3
        elseif self.myChairID == 2 then
            self.nextID = 3
            self.preID = 1
        elseif self.myChairID == 3 then
            self.nextID = 1
            self.preID = 2
        else
            print("ViewMessage 座位分配失败！", self.myChairID)
            return
        end

    else
        if self.myChairID == 1 then
            self.nextID = 2
            self.preID = 3
        elseif self.myChairID == 2 then
            self.nextID = 1
            self.preID = 3
        else
            print("ViewMessage 座位分配失败！", self.myChairID)
            return
        end
    end
    
    self.posTable={}
    self.posTable[self.myChairID] = cc.p(-450, -250)
    self.posTable[self.nextID] = cc.p(400,160)
    self.posTable[self.preID] = cc.p(-400,160)
end

function ViewMessage:ctor(params)
    --self.super.ctor(self)

    self:setNodeEventEnabled(true)
    self.count = 3
    if params then
        self.count = params.count
    end
    

    local swallowLayer = ccui.ImageView:create("common/black.png");
    swallowLayer:setScale9Enabled(true);
    local winSize = cc.Director:getInstance():getWinSize()
    swallowLayer:setContentSize(cc.size(winSize.width, winSize.height));
    swallowLayer:setPosition(display.cx, display.cy);
    swallowLayer:addTo(self);
    swallowLayer:addTouchEventListener(function(sender,eventType)
        self:hideChat()
    end)
    swallowLayer:setTouchEnabled(true);
    swallowLayer:setSwallowTouches(true);
    
    self.maskLayer = swallowLayer-- 聊天界面
    self.nodeMsg = nil--选择快捷消息界面
    self.nodeFace = nil--选择表情消息界面

    self:createUI();

    self.msgList = {}

end

function ViewMessage:getFaceByIndex(index)
    return pathFace[index]
end

function ViewMessage:getQuickMsgByIndex(index)
    return pathQuickMsg[index]
end

function ViewMessage:createUI()
    local size = self.maskLayer:getContentSize()
    
    self._bg = ccui.ImageView:create("view/frame3.png");
    self._bg:setScale9Enabled(true);
    self._bg:setContentSize(cc.size(winWidth, winHeight));
    self._bg:align(display.RIGHT_BOTTOM, display.right - 10, display.bottom + 35)
    self._bg:addTo(self.maskLayer)
    self._bg:addTouchEventListener(function(sender,eventType)
        --self:hide()
    end)
    self._bg:setTouchEnabled(true);
    self._bg:setSwallowTouches(true);

    --常用语按钮
    local button = ccui.Button:create("view/btn_msg_1.png","view/btn_msg_1.png","view/btn_msg_0.png");
        button:setZoomScale(0.1);
        button:setContentSize(62,65);
        button:setPressedActionEnabled(true);
        --button:setTitleText("发送")
        --button:setTitleFontSize(26);
        --button:setTitleColor(display.COLOR_WHITE);
        button:addTouchEventListener(function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                SoundManager.playSound("sound/buttonclick.mp3")
                self:showMsgLayer()
                onUmengEvent("1044")
            end
        end)
        button:align(display.CENTER, 216, 78)
        button:addTo(self._bg)
    self.btnMsg = button

    local title = ccui.Text:create("常用语",FONT_ART_BUTTON,28)
    title:setTextColor(cc.c4b(250,236,101,255))
    title:addTo(button):align(display.CENTER, 40, -10)


    --表情按钮
    local button = ccui.Button:create("view/btn_face_1.png","view/btn_face_1.png","view/btn_face_0.png");
        button:setZoomScale(0.1);
        button:setContentSize(62,65);
        button:setPressedActionEnabled(true);
        --button:setTitleText("发送")
        --button:setTitleFontSize(26);
        --button:setTitleColor(display.COLOR_WHITE);
        button:addTouchEventListener(function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                SoundManager.playSound("sound/buttonclick.mp3")
                self:showFaceLayer()
                onUmengEvent("1045")
            end
        end)
        button:align(display.CENTER, 350, 78)
        button:addTo(self._bg)
    self.btnFace = button

    local title = ccui.Text:create("表情",FONT_ART_BUTTON,28)
    title:setTextColor(cc.c4b(250,236,101,255))
    title:addTo(button):align(display.CENTER, 40, -10)

    self:showMsgLayer()
end

function ViewMessage:showFaceLayer()
    if self.nodeFace then
        self.nodeFace:show()
    else
        self:createFace()
    end

    if self.nodeMsg then
        self.nodeMsg:hide()
    end

    self.btnFace:setEnabled(false)
    self.btnFace:setBright(false)

    self.btnMsg:setEnabled(true)
    self.btnMsg:setBright(true)
end

function ViewMessage:showMsgLayer()
    if self.nodeMsg then
        self.nodeMsg:show()
    else
        self:createQuickMsg()
    end

    if self.nodeFace then
        self.nodeFace:hide()
    end

    self.btnFace:setEnabled(true)
    self.btnFace:setBright(true)

    self.btnMsg:setEnabled(false)
    self.btnMsg:setBright(false)
end

function ViewMessage:onEditBoxBegan(editbox)
    printf("editBox1 event began : text = %s", editbox:getText())
end

function ViewMessage:onEditBoxEnded(editbox)
    printf("editBox1 event ended : %s", editbox:getText())
end

function ViewMessage:onEditBoxReturn(editbox)
    printf("editBox1 event return : %s", editbox:getText())
end

function ViewMessage:onEditBoxChanged(editbox)
    printf("editBox1 event changed : %s", editbox:getText())
end

function ViewMessage:createFace()

    local i = 0 
    local j = 0
    local pos = {x = 80, y = 380}
    local dis = 110
    local node = display.newScale9Sprite("view/frame2.png", 0,0, cc.size(380, 430), cc.rect(20, 20, 10, 10))
                :addTo(self._bg)
                :align(display.CENTER_TOP, winWidth/2, winHeight -20)
    self.nodeFace = node
    
    for k,v in ipairs(pathFace) do
        i = math.floor((k-1)%3)--self.count
        j = math.floor((k-1)/3)
        
        local face = ccui.Button:create(v):align(display.CENTER, pos.x + i*dis, pos.y-j*dis):addTo(node)
        face:setZoomScale(0.1);
        face:setPressedActionEnabled(true);
        face:addTouchEventListener(function(sender,eventType)
            if eventType == ccui.TouchEventType.began then
                
            elseif eventType == ccui.TouchEventType.ended then
                self:onClickFace(k)

            elseif eventType == ccui.TouchEventType.canceled then
                
            end
        end)
    end
    self._nodeFace = node

    local line = display.newScale9Sprite("common/sep_line.png", 130, 220, cc.size(400, 2)):addTo(node)
    line:setRotation(90)
    
    line = display.newScale9Sprite("common/sep_line.png", 250, 220, cc.size(400, 2)):addTo(node)
    line:setRotation(90)

    line = display.newScale9Sprite("common/sep_line.png", 200, 105, cc.size(350, 2)):addTo(node)
    display.newScale9Sprite("common/sep_line.png", 200, 215, cc.size(350, 2)):addTo(node)
    display.newScale9Sprite("common/sep_line.png", 200, 325, cc.size(350, 2)):addTo(node)


end

function ViewMessage:onClickFace(index)
    self:msgFace(index)
    self:hideChat()
    print("click icon = " .. pathFace[index])
end

function ViewMessage:touchListener(event)
    local listView = event.listView
    if "clicked" == event.name then
        print("list clicked item is : ", event.itemPos)
        
    elseif "moved" == event.name then
        print(event.name)

    elseif "ended" == event.name then
        print(event.name)
    else
        print("event name:" .. event.name)
    end
end

function ViewMessage:createQuickMsg()

    local node = display.newScale9Sprite("view/frame2.png", 0, 0, cc.size(380, 430), cc.rect(20, 20, 10, 10))
               :addTo(self._bg)
                :align(display.CENTER_TOP, winWidth/2, winHeight-20)
    self.nodeMsg = node

    --listview
    local list = ccui.ListView:create()
    list:setDirection(ccui.ScrollViewDir.vertical)
    list:setBounceEnabled(true)
    list:setContentSize(cc.size(360, 420))
    list:setPosition(10,10)
    node:addChild(list)

    local size = cc.size(450, 60)
    --子节点
    for k,v in ipairs(pathQuickMsg) do

        local msg = ccui.Button:create();
        msg:setTitleText(v);
        msg:setZoomScale(0.1);
        msg:setPressedActionEnabled(true);
        msg:addTouchEventListener(function(sender,eventType)
            if eventType == ccui.TouchEventType.began then
                --msg:setScale(0.7)

            elseif eventType == ccui.TouchEventType.ended then
                --msg:setScale(0.6)
                self:onClickQuickMsg(k)

            elseif eventType == ccui.TouchEventType.canceled then
                --msg:setScale(0.6)
            end
        end)
        msg:setTitleFontSize(28);
        msg:setTitleColor(cc.c3b(0xFF, 0x8F, 0x00));
        msg:align(display.LEFT_CENTER, 0, 45)
        msg:setContentSize(size);

        display.newScale9Sprite("common/sep_line.png", 150, -10, cc.size(350, 2)):addTo(msg)

        local custom_item = ccui.Layout:create()
            --custom_item:setTouchEnabled(true)
            custom_item:setContentSize(size)
            custom_item:addChild(msg)
            
        list:pushBackCustomItem(custom_item)
    end

    --list:scrollToBottom(0.1, false)
    list:refreshView()

    self._nodeQuickMsg = node
end

function ViewMessage:onClickQuickMsg(index)
    self:msgQuickChat(index)
    self:hideChat()
    print("click icon = " .. pathQuickMsg[index])

end

function ViewMessage:msgFace(index)
    ChatInfo:sendUserExpressionRequest(index)
end

function ViewMessage:msgChat(message)

    ChatInfo:sendUserChatRequest(255, message)

end

function ViewMessage:msgQuickChat(index)
    self:msgChat(tostring(index))
end

function ViewMessage:msgMultiMedia()
--[[{
    required int32                          wDataLength=1;                      //信息长度
    required int32                          dwDataType=2;                           //信息类型
    required int32                          dwTargetUserID=3;                       //目标用户
    required string                         szUrlString=4;          //路径信息
}]]
    GameCenter:sendData(CMD_GameServer.MDM_GF_FRAME,CMD_GameServer.SUB_GF_USER_MULTIMEDIA)

end

function ViewMessage:createListItem(msg)
    local content = nil
    local rect = nil
    local pop = nil
    local node = ccui.ImageView:create()--"Default/Button_Normal.png")
            node:setContentSize(cc.size(660,84))
            node:setScale9Enabled(true)
            node:setCapInsets(cc.rect(10,10,11,11))
            node:ignoreAnchorPointForPosition(true)

    local height = 84
    local _from = msg.dwSendUserID
    local _type = nil
    if not msg.wChatLength then
        _type = 1
    elseif msg.wChatLength == 0 then
        _type = 2
    elseif msg.wChatLength > 0 then
        _type = 3
    end

    
    print("from", _from, "chat_type", _type, "index", _index)
    
    local pos = nil
    local userInfo = DataManager:getUserInfoByUserID(_from)

    if userInfo then

        if _type == 1 then
            local _index = msg.wItemIndex
            content = display.newSprite(pathFace[_index]):scale(0.6)
            rect = content:getBoundingBox()
            rect = cc.rect(0,0,rect.width*1.2, rect.height*1.5)
            pop = display.newScale9Sprite("chat/pop.png", 300, 50, cc.size(rect.width,rect.height), cc.rect(10,10,20,20)):addTo(node)

            height = rect.height
        elseif  _type == 2  then
            local _index = tonumber(msg.szChatString)
            content = display.newTTFLabel({
                    text = pathQuickMsg[_index],
                    font = "",
                    size = 24,
                    color = cc.c3b(0x5F, 0x1F, 0x00),
                    align = cc.ui.TEXT_ALIGN_LEFT,
                    valign = cc.ui.TEXT_VALIGN_CENTER,
                    --dimensions = cc.size(350, 50)
                })
            
            --content:enableOutline(cc.c3b(0,0,0), 1);
            rect = content:getBoundingBox()
            rect = cc.rect(0,0,rect.width*1.2, rect.height*2.0)
            pop = display.newScale9Sprite("chat/pop.png", 300, 20, cc.size(rect.width,rect.height), cc.rect(10,10,20,20)):addTo(node)
            height = rect.height*2

        elseif _type == 3 then
            print("接收到的消息内容：", msg.szChatString)
            content = display.newTTFLabel({
                    text = msg.szChatString,
                    font = "",
                    size = 24,
                    color = cc.c3b(0x5F, 0x1F, 0x00),
                    align = cc.ui.TEXT_ALIGN_LEFT,
                    valign = cc.ui.TEXT_VALIGN_CENTER,
                    --dimensions = cc.size(350, 50)
                })
            
            --content:enableOutline(cc.c3b(0,0,0), 1);
            rect = content:getBoundingBox()
            rect = cc.rect(0,0,rect.width*1.2, rect.height*2.0)
            pop = display.newScale9Sprite("chat/pop.png", 300, 20, cc.size(rect.width,rect.height), cc.rect(10,10,20,20)):addTo(node)
            height = rect.height*2
        end


        --调整坐标
        node:setContentSize(cc.size(660, height))

        local isSelf = false
        if _from == DataManager:getMyUserInfo().userID then
            isSelf = true
        end

        if isSelf then
            pop:setScaleX(-1)
            pop:align(display.RIGHT_CENTER, 100, 80)
            content:addTo(node):align(display.LEFT_CENTER, 100, 80)
            

            --icon
            if userInfo.faceID >= 1 and userInfo.faceID <= 37 then
                display.newSprite("head/head_"..userInfo.faceID..".png"):addTo(node):align(display.CENTER, 50, 75):scale(0.6)

            else
                display.newSprite("head/default.png"):addTo(node):align(display.CENTER, 50, 75):scale(0.6)

            end

            --name
            display.newTTFLabel({
                        text = userInfo.nickName,
                        font = "",
                        size = 20,
                        color = cc.c3b(0xff, 0xff, 0x60),
                        align = cc.ui.TEXT_VALIGN_LEFT,
                        valign = cc.ui.TEXT_VALIGN_CENTER,
                        --dimensions = cc.size(350, 50)
                    })
            :addTo(node)
            :align(display.LEFT_CENTER, 20, 20)

        else
            node:setContentSize(cc.size(660, height))
            pop:align(display.RIGHT_CENTER, 500, 80)
            content:addTo(node):align(display.RIGHT_CENTER, 500, 80)

            --icon
            if userInfo.faceID >= 1 and userInfo.faceID <= 37 then
                display.newSprite("head/head_"..userInfo.faceID..".png"):addTo(node):align(display.CENTER, 550, 75):scale(0.6)

            else
                display.newSprite("head/default.png"):addTo(node):align(display.CENTER, 550, 75):scale(0.6)

            end

        
            --name
            display.newTTFLabel({
                        text = userInfo.nickName,
                        font = "",
                        size = 20,
                        color = cc.c3b(0xff, 0xff, 0x60),
                        align = cc.ui.TEXT_VALIGN_RIGHT,
                        valign = cc.ui.TEXT_VALIGN_CENTER,
                        --dimensions = cc.size(350, 50)
                    })
            :addTo(node)
            :align(display.RIGHT_CENTER, 580, 20)
        end

    end

    return node
end

function ViewMessage:onUserMessage()

    local msg = ChatInfo.chatMsgData--event.data

    if msg then
        self:switchChairID()
        self:popMsg(msg)
    end
end

   --[[{
        required int32                          wChatLength=1;                      //信息长度
        required int32                          dwChatColor=2;                      //信息颜色
        required int32                          dwTargetUserID=3;                   //目标用户
        required string                         szChatString=4;                     //聊天信息
    }]]

    --[[{
        required int32                          wItemIndex=1;                           //表情索引
        required int32                          dwTargetUserID=2;                       //目标用户
    }]]

function ViewMessage:popMsg(msg)

    if self.myChairID == Define.INVALID_CHAIR then
        return
    end

    --弹框显示
    local _from = msg.sendUserID
    local _type = msg.chatType
    local userInfo = DataManager:getUserInfoByUserID(_from)

    if userInfo then
        --print(self.myChairID, self.nextID, self.preID, self.count)
        --dump(self.posTable, "posTable")

        local x = display.cx+self.posTable[userInfo.chairID].x
        local y = display.cy+self.posTable[userInfo.chairID].y
        local node = display.newNode():addTo(self)
        local content = nil
        local rect = nil
        local pop = nil
        
        if  _type == 1  then--快捷消息
            local _index = tonumber(msg.content)
            content = display.newTTFLabel({
                    text = pathQuickMsg[_index],
                    font = "",
                    size = 24,
                    color = cc.c3b(0x5F, 0x1F, 0x00),
                    align = cc.ui.TEXT_ALIGN_LEFT,
                    valign = cc.ui.TEXT_VALIGN_CENTER,
                    --dimensions = cc.size(350, 50)
                })

            --content:enableOutline(cc.c3b(0,0,0), 1);
            rect = content:getBoundingBox()
            rect = cc.rect(0,0,rect.width*1.2, rect.height*2.0)
            pop = display.newScale9Sprite("chat/pop.png", 0, 0, cc.size(rect.width,rect.height), cc.rect(20,12,1,1)):addTo(node)
        
        elseif _type == 2 then--表情

            local _index = msg.expressID
            content = display.newSprite(pathFace[_index])--:scale(0.6)
            rect = content:getBoundingBox()
            rect = cc.rect(0,0,rect.width*1.5, rect.height*1.5)
            -- pop = display.newScale9Sprite("chat/pop.png", 0, 0, cc.size(rect.width,rect.height), cc.rect(20,12,1,1)):addTo(node)
            pop = display.newSprite():addTo(node)

        elseif _type == 3 then--用户自定义消息

            print("接收到的消息内容：", msg.szChatString," len =", msg.wChatLength, "消息长度：", string.utf8len(msg.szChatString))

            content = display.newTTFLabel({
                    text = msg.szChatString,
                    font = "",
                    size = 24,
                    color = cc.c3b(0x5F, 0x1F, 0x00),
                    align = cc.ui.TEXT_ALIGN_LEFT,
                    valign = cc.ui.TEXT_VALIGN_CENTER,
                    --dimensions = cc.size(350, 50)
                })
            rect = content:getBoundingBox()
            rect = cc.rect(0,0,rect.width*1.2, rect.height*2.0)
            if rect.width < 67 then
                rect.width = 67
            end
            if rect.height < 53 then
                rect.height = 53
            end
            pop = display.newScale9Sprite("chat/pop.png", 0, 0, cc.size(rect.width,rect.height), cc.rect(20,12,1,1)):addTo(node)

        end
        
        if x < display.cx then 
            x = x+rect.width/2

        else
            pop:setScaleX(-1)
            x = x-rect.width/2+50
        end
        
        if y > display.cy then 
            y = y-rect.height /2+50
            
        else
            y = y + rect.height/2
        end

        content:addTo(node)
        node:align(display.CENTER, x, y)

        
        node:setScale(0.1)
        local callfunc = cc.CallFunc:create(
            function()
                node:removeSelf()
            end
        );
        local action = transition.sequence(
            {
                cc.Spawn:create(cc.FadeIn:create(0.2), cc.ScaleTo:create(0.2, 1.0)),
                cc.DelayTime:create(3.0),
                cc.FadeOut:create(0.1),
                callfunc
            })

        node:runAction(action)
    end
    
end

function ViewMessage:showChat()
    self.maskLayer:show()
    
end

function ViewMessage:hideChat()
    self.maskLayer:hide()
    
end

function ViewMessage:onEnter()
    self.bindIds = {}
    self.bindIds[#self.bindIds + 1] = BindTool.bind(ChatInfo, "chatMsgData", handler(self, self.onUserMessage));
    
    self:switchChairID()

end

function ViewMessage:onExit()
    for _, bindid in ipairs(self.bindIds) do
        BindTool.unbind(bindid)
    end
end

return ViewMessage