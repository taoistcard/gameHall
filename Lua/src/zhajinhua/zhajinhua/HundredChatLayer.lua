local HundredChatLayer = class("HundredChatLayer", function() return display.newNode() end) --require("common.ui.CCModelView"))

local facemode = 2 -- 1：静态图片 2:动态图片

local winWidth = 670
local winHeight = 450

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

local pathQuickMsg = {"闷5一圈,怎么样!",
                        "闷10一圈,怎么样!",
                        "本桌头5,不玩让下!!!",
                        "本桌头10,不玩让下!!!",
                        "我豹子,敢血拼么!!!",
                        "血拼到底一把!!!",
                        "大家好,很高兴见到各位!",
                        "你的人品也太好了吧!",
                        "哎!又输了!今天运气太差了吧!",
                        "各位不好意思,离开一会儿!",
                        "今天赢够了,明天再来,各位后会有期!",
                        "又断线了,网络怎么这么差!",
                        "你的牌真是忒好了呀",
                        "我的天啊,我一把也没赢,不会吧!"}


local pathFaceGif = {
"chat/gifnew/expression-Magic1.gif",
"chat/gifnew/expression-Magic2.gif",
"chat/gifnew/expression-Magic3.gif",
"chat/gifnew/expression-Magic4.gif",
"chat/gifnew/expression-Magic5.gif",
"chat/gifnew/expression-Magic6.gif",
"chat/gifnew/expression-Magic7.gif",
"chat/gifnew/expression-Magic8.gif",
"chat/gifnew/expression-Magic9.gif",
"chat/gifnew/expression-Magic10.gif",
"chat/gifnew/expression-Magic11.gif"
}

local posTable = {cc.p(209,485),cc.p(172,296),cc.p(508,210),cc.p(939,284),cc.p(933,490)}
local DateModel = require("zhajinhua.DateModel")
function HundredChatLayer:ctor(params)
    --self.super.ctor(self)

    if device.platform ~= "android" and device.platform ~= "ios" then
        facemode = 1
        CacheGif = ccui.ImageView
    else
        facemode = 1
        CacheGif = ccui.ImageView
    end

    self.msgList = {}

    self:setNodeEventEnabled(true)
    if params then
        self.chairArray = params.chairArry
    end
    self.allowChat = false

    local swallowLayer = ccui.ImageView:create("common/black.png");
    swallowLayer:setScale9Enabled(true);
    swallowLayer:setOpacity(255)
    local winSize = cc.Director:getInstance():getWinSize()

    swallowLayer:setContentSize(cc.size(winSize.width, winSize.height));

    -- swallowLayer:setContentSize(cc.size(DESIGN_WIDTH, DESIGN_HEIGHT));

    --swallowLayer:setPosition(display.cx, DESIGN_HEIGHT/2);
    swallowLayer:align(display.CENTER, 3000, DESIGN_HEIGHT/2)
    swallowLayer:addTo(self);
    swallowLayer:addTouchEventListener(function(sender,eventType)
        self:hideChat()
    end)
    swallowLayer:setTouchEnabled(true);
    swallowLayer:setSwallowTouches(true);
    
    self.maskLayer = swallowLayer-- 聊天界面
    self.nodeChat = nil -- 聊天界面
    self.nodeMsg = nil--选择快捷消息界面
    self.nodeFace = nil--选择表情消息界面
    self.playerMsgNode = display.newNode():addTo(self)

    self.myChairID = DataManager:getMyChairID()

    self:createUI();

end

function HundredChatLayer:setChairArray(chairArr)
    self.chairArray = chairArr
end

function HundredChatLayer:setAllowChat(bflag)
    self.allowChat = bflag
end

function HundredChatLayer:getFaceByIndex(index)
    return pathFace[index]
end

function HundredChatLayer:getQuickMsgByIndex(index)
    return pathQuickMsg[index]
end

function HundredChatLayer:createUI()
    local size = self.maskLayer:getContentSize()
    
    self._bg = ccui.ImageView:create("hundredRoom/commonBg.png");
    -- self._bg:setScale9Enabled(true);
    -- self._bg:setContentSize(cc.size(winWidth, winHeight));
    self._bg:align(display.BOTTOM_CENTER, size.width / 2, 100)
    self._bg:addTo(self.maskLayer)
    self._bg:addTouchEventListener(function(sender,eventType)
        --self:hide()
    end)
    self._bg:setTouchEnabled(true);
    self._bg:setSwallowTouches(true);



    local botBg = ccui.ImageView:create("hundredRoom/hundredBanker/kuang.png");
    botBg:setScale9Enabled(true)
    botBg:setContentSize(cc.size(570, 360));
    botBg:align(display.CENTER, 320,212)
    self._bg:addChild(botBg)

    local inputbg = ccui.ImageView:create()
    inputbg:loadTexture("hundredRoom/hundredChat/input_bg.png")
    -- inputbg:setScale9Enabled(true)
    -- inputbg:setContentSize(cc.size(420, 57))
    --inputbg:setCapInsets(cc.rect(90,30,1,1))
    inputbg:setPosition(cc.p(169, 71))
    self._bg:addChild(inputbg)


    local chatEditBox = ccui.EditBox:create(cc.size(253, 48), "blank.png");
    chatEditBox:setFontSize(20);
    chatEditBox:setPlaceHolder("请输入聊天内容");
    chatEditBox:setPlaceholderFontColor(cc.c3b(255,255,100));
    chatEditBox:setPlaceholderFontSize(20);
    chatEditBox:setInputMode(InputMode_ANY);
    chatEditBox:setMaxLength(30);

    chatEditBox:setAnchorPoint(cc.p(0,0.0));
    chatEditBox:setPosition(0, 0)
    inputbg:addChild(chatEditBox)
    chatEditBox:registerScriptEditBoxHandler(function(event, editbox)
        print("---chatEditBox---", event)
        if event == "began" then 
        -- 开始输入,显示聊天历史
        self:showChatListLayer()
        elseif event == "changed" then
            -- 输入框内容发生变化
        elseif event == "ended" then
            -- 输入结束
        elseif event == "return" then
            -- 从输入框返回
        end
    end)
    self.inputBox = chatEditBox;



    --常用语
    local button = ccui.Button:create("hundredRoom/hundredChat/word.png","hundredRoom/hundredChat/wordSelected.png","hundredRoom/hundredChat/wordSelected.png");
    -- button:setScale9Enabled(true);
    -- button:setContentSize(60, 60);
    button:setPressedActionEnabled(true);
    button:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            SoundManager.playSound("sound/buttonclick.mp3")
            self:showMsgLayer()
            self.btnFace:setHighlighted(false)
            self.btnMsg:setHighlighted(true)
        end
    end)
    button:align(display.CENTER, 334, 72)
    button:addTo(self._bg)
    self.btnMsg = button

    local btnicon = ccui.ImageView:create("hundredRoom/hundredChat/wordIcon.png");
    btnicon:align(display.CENTER, 30, 30)
    btnicon:addTo(button)


    --表情按钮
    local button = ccui.Button:create("hundredRoom/hundredChat/word.png","hundredRoom/hundredChat/wordSelected.png","hundredRoom/hundredChat/wordSelected.png");
    -- button:setScale9Enabled(true);
    -- button:setContentSize(60, 60);
    button:setPressedActionEnabled(true);
    button:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            SoundManager.playSound("sound/buttonclick.mp3")
            self:showFaceLayer()
            self.btnFace:setHighlighted(true)
            self.btnMsg:setHighlighted(false)
        end
    end)
    button:align(display.CENTER, 393, 72)
    button:addTo(self._bg)
    self.btnFace = button

    local btnicon = ccui.ImageView:create("hundredRoom/hundredChat/faceIcon.png");
    btnicon:align(display.CENTER, 30, 30)
    btnicon:addTo(button)

    --发送按钮
    local button = ccui.Button:create("hundredRoom/hundredChat/send.png","hundredRoom/hundredChat/sendSelected.png","hundredRoom/hundredChat/sendSelected.png");
    button:setPressedActionEnabled(true);
    button:setTitleText("发送")
    button:setTitleFontSize(26);
    button:setTitleColor(display.COLOR_WHITE);
    button:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            SoundManager.playSound("sound/buttonclick.mp3")

            local txt = self.inputBox:getText()
            if stringContainsEmoji(txt) == true then
                Hall.showTips("字符中不能含有表情符号", 2.5)
            else
                self:msgChat(txt)
                self.inputBox:setText("")
                self:hideChat()
            end
        end
    end)
    button:align(display.CENTER, 467, 72)
    button:addTo(self._bg)
    --self.btnMsg = button

    --弹幕按钮
    local danmuBtn = ccui.Button:create("hundredRoom/hundredChat/danmuBtn.png","hundredRoom/hundredChat/danmuBtn.png","hundredRoom/hundredChat/danmuBtn.png");
    danmuBtn:setPressedActionEnabled(true);
    danmuBtn:setTitleText("弹幕")
    danmuBtn:setTitleFontSize(26);
    danmuBtn:setTitleColor(display.COLOR_WHITE);
    danmuBtn:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            SoundManager.playSound("sound/buttonclick.mp3")

        end
    end)
    danmuBtn:align(display.CENTER, 555, 72)
    danmuBtn:addTo(self._bg)

    local danmuicon = ccui.ImageView:create("hundredRoom/hundredChat/forbiddenIcon.png");
    danmuicon:align(display.CENTER, 73, 54)
    danmuicon:addTo(danmuBtn)
    self.danmuicon = danmuicon

    local close = ccui.Button:create()
    close:loadTextures("common/close1.png", "common/close1.png")
    close:setPosition(cc.p(621, 418))
    close:addTouchEventListener(
                function(sender,eventType)
                    if eventType == ccui.TouchEventType.ended then
                		self:hideChat()
                    end
                end
            )
    self._bg:addChild(close)

    self:showChatListLayer()

    self.lastChatCount = 0

    self.handler = scheduler.scheduleGlobal(function()
        if self.msgList then
            if(self.lastChatCount < #self.msgList) then
                self.lastChatCount = #self.msgList
                self:refreshNodeChat()
            end
        end
    end , 1)
end

function HundredChatLayer:showChatListLayer()

    if self.nodeChat then
        self.nodeChat:show()
    else
        self:refreshNodeChat()
    end

    if self.nodeMsg then
        self.nodeMsg:hide()
    end

    if self.nodeFace then
        self.nodeFace:hide()
    end

    -- self.btnFace:setHighlighted(false)
    -- self.btnMsg:setHighlighted(false)
    -- self.btnFace:setBright(false)
    -- self.btnMsg:setBright(false)
    self.btnMsg:setEnabled(true)
    self.btnFace:setEnabled(true)

end

function HundredChatLayer:showFaceLayer()
    if self.nodeFace then
        self.nodeFace:show()
    else
        self:createFace()
    end

    if self.nodeMsg then
        self.nodeMsg:hide()
    end

    if self.nodeChat then
        self.nodeChat:hide()
    end

    self.btnFace:setEnabled(false)
    self.btnFace:setBright(false)

    self.btnMsg:setEnabled(true)
    self.btnMsg:setBright(true)
end

function HundredChatLayer:showMsgLayer()
    if self.nodeMsg then
        self.nodeMsg:show()
    else
        self:createQuickMsg()
    end

    if self.nodeFace then
        self.nodeFace:hide()
    end

    if self.nodeChat then
        self.nodeChat:hide()
    end

    self.btnFace:setEnabled(true)
    self.btnFace:setBright(true)

    self.btnMsg:setEnabled(false)
    self.btnMsg:setBright(false)
end

function HundredChatLayer:createFace()

    local i = 0 
    local j = 0
    local pos = {x = 54, y = 200}
    local dis = 108

    self.nodeFace = ccui.Layout:create()
    self.nodeFace:setContentSize(cc.size(645, 360))
    self.nodeFace:align(display.BOTTOM_LEFT, 12, 85)
    self._bg:addChild(self.nodeFace)

    --listview
    local list = ccui.ListView:create()
    list:setDirection(ccui.ScrollViewDir.vertical)
    list:setBounceEnabled(true)
    list:setContentSize(cc.size(648, 340))
    list:setPosition(-10, 5)
    self.nodeFace:addChild(list)
    
    local custom_item;

    if facemode == 1 then
        for k,v in ipairs(pathFace) do
            i = math.floor((k-1)%6)
            j = math.floor((k-1)/6)
            
            if i == 0 then
                custom_item = ccui.Layout:create()
                custom_item:setContentSize(cc.size(648, 130))
                list:pushBackCustomItem(custom_item)
            end

            local face = ccui.Button:create(v):align(display.CENTER, pos.x + i*dis, 65):addTo(custom_item)
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
    elseif facemode == 2 then
        pos = {x = 77, y = 200}
        dis = 164
        for k,v in ipairs(pathFaceGif) do
            i = math.floor((k-1)%4)
            j = math.floor((k-1)/4)

            if i == 0 then
                custom_item = ccui.Layout:create()
                custom_item:setContentSize(cc.size(648, 190))
                list:pushBackCustomItem(custom_item)
            end

            local gif = CacheGif:create(v);
            gif:setAnchorPoint(cc.p(0.5,0.5));
            custom_item:addChild(gif);
            gif:setPosition(pos.x + i*dis, 95);
            -- gif:setTag(1000);
            -- gif:setScale(3)

            
            local face = ccui.ImageView:create("common/blank.png"):align(display.CENTER, pos.x + i*dis, 95):addTo(custom_item)
            face:setScale9Enabled(true)
            face:setContentSize(cc.size(165 , 165))
            face:addTouchEventListener(function(sender,eventType)
                if eventType == ccui.TouchEventType.began then
                    
                elseif eventType == ccui.TouchEventType.ended then
                    self:onClickFace(k)

                elseif eventType == ccui.TouchEventType.canceled then
                    
                end
            end)
            face:setTouchEnabled(true);
            
        end
    end
end

function HundredChatLayer:onClickFace(index)
    self:msgFace(index)
    self:hideChat()
    print("click icon = ")
end

function HundredChatLayer:touchListener(event)
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

function HundredChatLayer:refreshNodeChat()
    
    if self.nodeChat == nil then
        local node = ccui.Layout:create()
        node:setContentSize(cc.size(500, 270))
        node:align(display.BOTTOM_LEFT, 72, 107)
        self._bg:addChild(node)
        self.nodeChat = node
    end

    self.nodeChat:removeAllChildren()

    --listview
    local list = ccui.ListView:create()
    list:setDirection(ccui.ScrollViewDir.vertical)
    list:setBounceEnabled(true)
    list:setContentSize(cc.size(500, 270))
    -- list:setPosition(10, 5)
    -- list:setBackGroundColorType(1)
    -- list:setBackGroundColor(cc.c3b(100,123,100))
    self.nodeChat:addChild(list)

    local custom_item
    for k,v in ipairs(self.msgList) do
        custom_item = ccui.Layout:create()

        local name = ccui.Text:create(FormotGameNickName(v.nickName, 8), FONT_ART_TEXT, 24)
        name:setTextColor(cc.c4b(255,226,112,255))
        name:setAnchorPoint(cc.p(0, 1))

        custom_item:addChild(name)

        if v.chatType == 1 then
            local content = CacheGif:create(v.msg);
            content:setScale(0.6)
            custom_item:setContentSize(cc.size(640, 110))
            custom_item:addChild(content)

            name:setPosition(cc.p(10, 100))
            content:setPosition(270, 60)
        else
            name:setAnchorPoint(cc.p(0,1))

            local content = ccui.Text:create(v.msg, FONT_ART_TEXT, 24)
            content:setTextColor(cc.c4b(255,255,255,255))
            content:setAnchorPoint(cc.p(0,1))
            custom_item:addChild(content)

            local consize = content:getContentSize()
            local titheight = 34 * math.ceil(consize.width / 420)
            if titheight < 34 then titheight = 34 end
            local conheight = 10 + titheight + 10

            custom_item:setContentSize(cc.size(640, conheight))
            
            name:setTextAreaSize(cc.size(200, conheight))
            name:ignoreContentAdaptWithSize(false)
            name:setTextHorizontalAlignment(0)
            name:setTextVerticalAlignment(0)

            content:setTextAreaSize(cc.size(415, conheight))
            content:ignoreContentAdaptWithSize(false)
            content:setTextHorizontalAlignment(0)
            content:setTextVerticalAlignment(0)

            name:setPosition(cc.p(10, conheight - 10))
            content:setPosition(220, conheight - 10)
        end

        -- local sprline = ccui.ImageView:create("common/sep_line.png")
        -- sprline:setScale9Enabled(true);
        -- sprline:setContentSize(cc.size(635, 2));
        -- sprline:setPosition(323, 5)
        -- custom_item:addChild(sprline)


        list:pushBackCustomItem(custom_item)
        
    end

    if #self.msgList == 0 then
        custom_item = ccui.Layout:create()
        custom_item:setContentSize(cc.size(640, 54))
        local content = ccui.Text:create("还没有聊天记录,说点什么吧", FONT_ART_TEXT, 24)
        content:setTextColor(cc.c4b(255,255,255,255))
        content:setAnchorPoint(cc.p(0,0.5))
        content:setPosition(15, 27)
        custom_item:addChild(content)
        list:pushBackCustomItem(custom_item)
    end
end

function HundredChatLayer:createQuickMsg()

    -- local node = display.newScale9Sprite("view/frame2.png", 0, 0, cc.size(380, 430), cc.rect(20, 20, 10, 10))
    --            :addTo(self._bg)
    --             :align(display.CENTER_TOP, winWidth/2, winHeight-20)
    local node = ccui.Layout:create()
    node:setContentSize(cc.size(500, 270))
    node:align(display.BOTTOM_LEFT, 72, 107)
    self._bg:addChild(node)
    self.nodeMsg = node

    --listview
    local list = ccui.ListView:create()
    list:setDirection(ccui.ScrollViewDir.vertical)
    list:setBounceEnabled(true)
    list:setContentSize(cc.size(500, 270))
    -- list:setPosition(10, 5)
    node:addChild(list)

    local size = cc.size(645, 70)
    --子节点
    for k,v in ipairs(pathQuickMsg) do

        local blayer = ccui.ImageView:create("common/blank.png");
        blayer:setScale9Enabled(true)
        blayer:setContentSize(size)
        blayer:setAnchorPoint(cc.p(0,0))
        blayer:setPosition(cc.p(0, 0))
        blayer:setTouchEnabled(true)
        blayer:addTouchEventListener(function(sender,eventType)
            if eventType == ccui.TouchEventType.began then
                --msg:setScale(0.7)

            elseif eventType == ccui.TouchEventType.ended then
                --msg:setScale(0.6)
                self:onClickQuickMsg(k)

            elseif eventType == ccui.TouchEventType.canceled then
                --msg:setScale(0.6)
            end
        end)

        local itemUnderWrite = ccui.Text:create(v, FONT_ART_TEXT, 28)
        itemUnderWrite:setTextColor(cc.c4b(255,255,255,255))
        itemUnderWrite:setAnchorPoint(cc.p(0,0.5))
        itemUnderWrite:setPosition(cc.p(10, 35))
        blayer:addChild(itemUnderWrite)



        -- local msg = ccui.Button:create();
        -- msg:setTitleText(v);
        -- msg:setZoomScale(0.1);
        -- msg:setPressedActionEnabled(true);
        
        -- msg:setTitleFontSize(28);
        -- msg:setTitleColor(cc.c3b(0xFF, 0x8F, 0x00));
        -- msg:align(display.CENTER, 322, 45)
        -- msg:setContentSize(size);

        -- display.newScale9Sprite("common/sep_line.png", 322, 0, cc.size(630, 2)):addTo(blayer)

        local custom_item = ccui.Layout:create()
        --custom_item:setTouchEnabled(true)
        custom_item:setContentSize(size)
        custom_item:addChild(blayer)
            
        list:pushBackCustomItem(custom_item)
    end

    --list:scrollToBottom(0.1, false)
    list:refreshView()

    self._nodeQuickMsg = node
end

function HundredChatLayer:onClickQuickMsg(index)
    local curStr = self.inputBox:getText()
    local addStr = self:getQuickMsgByIndex(index)
    self.inputBox:setText(addStr)
end

function HundredChatLayer:msgFace(index)
    if DateModel:getInstance():getListenChat() == false then
        return
    end
    ChatInfo:sendUserExpressionRequest(index)
end

function HundredChatLayer:msgChat(message)
    if DateModel:getInstance():getListenChat() == false then
        return
    end
    ChatInfo:sendUserChatRequest(255, message)
end

function HundredChatLayer:createListItem(msg)
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
        if _from == DataManager:getMyUserID() then
            isSelf = true
        end

        if isSelf then
            pop:setScaleX(-1)
            pop:align(display.RIGHT_CENTER, 100, 80)
            content:addTo(node):align(display.LEFT_CENTER, 100, 80)
            

            --icon
            if userInfo:faceID() >= 1 and userInfo:faceID() <= 37 then
                display.newSprite("head/head_"..userInfo:faceID()..".png"):addTo(node):align(display.CENTER, 50, 75):scale(0.6)

            else
                display.newSprite("head/default.png"):addTo(node):align(display.CENTER, 50, 75):scale(0.6)

            end

            --name
            display.newTTFLabel({
                        text = userInfo:getNickName(),
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
            if userInfo:faceID() >= 1 and userInfo:faceID() <= 37 then
                display.newSprite("head/head_"..userInfo:faceID()..".png"):addTo(node):align(display.CENTER, 550, 75):scale(0.6)

            else
                display.newSprite("head/default.png"):addTo(node):align(display.CENTER, 550, 75):scale(0.6)

            end

        
            --name
            display.newTTFLabel({
                        text = userInfo:getNickName(),
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

function HundredChatLayer:onUserMessage(event)
    if DateModel:getInstance():getListenChat() == false then
        return
    end    

    local response = ChatInfo.chatMsgData--event.data
    --弹框显示
    local _from = response.sendUserID

    local _type = nil
    if response.chatType == 1 then
        _type = 2
    elseif response.chatType == 2 then
        _type = 1
    end

    print("from", _from, "chat_type", _type, "index", _index)

    if self.chairArray ==nil then
        print("Error:HundredChatLayer:popMsg self.chairArray is nil")
        return
    end
    
    local userInfo = DataManager:getUserInfoByUserID(_from)
    print("-----userInfo----nickname----", userInfo.nickName)
    if userInfo then
        local tem = {}
        tem.nickName = userInfo.nickName
        tem.chatType = _type
        tem.userid = userInfo.userID

        local pos = posTable[self:getPostionIndex(userInfo.chairID)]
        local x = pos.x
        local y = pos.y
        local node = display.newNode():addTo(self.playerMsgNode)
        local content = nil
        local rect = nil
        local pop = nil
        
        if _type == 1 then--表情
            local _index = response.expressID
            if facemode == 1 then
                content = display.newSprite(pathFace[_index])--:scale(0.6)
                rect = content:getBoundingBox()
                rect = cc.rect(0,0,rect.width*1.5, rect.height*1.5)
                -- pop = display.newScale9Sprite("chat/pop.png", 0, 0, cc.size(rect.width,rect.height), cc.rect(20,12,1,1)):addTo(node)
                pop = display.newSprite():addTo(node)
                content:addTo(node)

                tem.msg = pathFace[_index]
            elseif facemode == 2 then
                if pathFaceGif[_index] then
                    content = CacheGif:create(pathFaceGif[_index]);
                    content:setScale(1)
                    rect = cc.rect(0, 0, 80*1.5, 80*1.5)
                    pop = display.newSprite():addTo(node)
                    node:addChild(content)

                    tem.msg = pathFaceGif[_index]
                end
            end

        elseif _type == 2 then--用户自定义消息

            print("接收到的消息内容：", response.content, "消息长度：", string.utf8len(response.content))
            content = display.newTTFLabel({
                    text = response.content,
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
            content:addTo(node)

            tem.msg = response.content
        end

        --旁观发言
        if userInfo.userStatus == Define.US_LOOKON then
            x = 1093 - 50
            y = 118 - rect.height/2 + 20
        end
        
        if x < DESIGN_WIDTH/2 then 
            x = x+rect.width/2

        else
            pop:setScaleX(-1)
            x = x-rect.width/2+50
        end
        
        if y > DESIGN_HEIGHT/2 then 
            y = y-rect.height /2+50
            
        else
            y = y + rect.height/2
        end

        
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

        -- self.msgList[#self.msgList+1] = tem
        table.insert(self.msgList,1,tem)
    end
end

function HundredChatLayer:getPostionIndex(chairId)
    for ind , chair in ipairs(self.chairArray) do
        if chair == chairId then
            return ind
        end
    end
    return 1
end

function HundredChatLayer:clearPlayerMsg()
    self.playerMsgNode:removeAllChildren()
end

function HundredChatLayer:showChat()
    if self.allowChat then
        self.maskLayer:show()
        self.maskLayer:setPosition(DESIGN_WIDTH/2, DESIGN_HEIGHT/2)
        self:showChatListLayer()
    end
end

function HundredChatLayer:hideChat()
    self.maskLayer:hide()
    self.maskLayer:setPosition(3000, DESIGN_HEIGHT/2)
end

function HundredChatLayer:onEnter()
    -- GameCenter:addEventListener(GameMessageType.EVENT_USER_MESSAGE, handler(self, self.onUserMessage))
    self.bindIds = {}

    self.bindIds[#self.bindIds + 1] = BindTool.bind(ChatInfo, "chatMsgData", handler(self, self.onUserMessage));
end

function HundredChatLayer:onExit()
    -- GameCenter:removeEventListenersByEvent(GameMessageType.EVENT_USER_MESSAGE)
    for _, bindid in ipairs(self.bindIds) do
        BindTool.unbind(bindid)
    end
    if self.handler then
        scheduler.unscheduleGlobal(self.handler)
        self.handler = nil
    end
end

return HundredChatLayer