
local NoticeLayer = class("NoticeLayer", function() return display.newLayer() end)

function NoticeLayer:ctor(kind)
	-- body
	self:createUI(kind)
end

function NoticeLayer:createUI(kind)
	local displaySize = cc.size(display.width, display.height);
    local winSize = cc.Director:getInstance():getWinSize()
    -- -- 蒙板
    local basewindow = require("show.popView_Hall.baseWindow").new(2)
    self:addChild(basewindow)
    -- basewindow:setPosition(-10,-70)

    local containerLayer = ccui.Layout:create()
    -- containerLayer:setAnchorPoint(cc.p(0.5,0.5))
    containerLayer:setContentSize(cc.size(1136,640))
    containerLayer:setPosition(-1136/2+724/2, -640/2+514/2)
    -- containerLayer:setBackGroundColorType(1)
    -- containerLayer:setBackGroundColor(cc.c3b(100,123,100))
    self.containerLayer = containerLayer
    basewindow:getContentNode():addChild(containerLayer)


    local pop_title = ccui.ImageView:create("hall/notice/title.png");
    pop_title:setPosition(cc.p(571,559));
    containerLayer:addChild(pop_title);

    -- local xiaoxi = ccui.ImageView:create("hall/notice/xiaoxi.png");
    -- xiaoxi:setPosition(cc.p(358,526));
    -- containerLayer:addChild(xiaoxi);

    -- local xiaoxiword = display.newTTFLabel({text = "消息",
    --                             size = 24,
    --                             color = cc.c3b(255,233,110),
    --                             font = FONT_ART_TEXT,
    --                         })
    --             :addTo(self)
    -- xiaoxiword:setPosition(410, 521)
    -- xiaoxiword:setTextColor(cc.c4b(251,248,142,255))
    -- xiaoxiword:enableOutline(cc.c4b(137,0,167,200), 2)
    self.listView = ccui.ListView:create()
    -- set list view ex direction
    self.listView:setDirection(ccui.ScrollViewDir.vertical)
    self.listView:setBounceEnabled(true)
    self.listView:setContentSize(cc.size(450, 400))
    self.listView:setPosition(422,116)
    containerLayer:addChild(self.listView)
    -- ListView点击事件回调
    local function listViewEvent(sender, eventType)
        -- 事件类型为点击结束
        if eventType == ccui.ListViewEventType.ONSELECTEDITEM_END then
            print("select child index = ",sender:getCurSelectedIndex())
        end
    end
    -- 设置ListView的监听事件
    self.listView:addEventListener(listViewEvent)

    local noticeSystem = ccui.Button:create("hall/notice/noticeSystem.png","hall/notice/noticeSystemSelected.png");
    noticeSystem:setPosition(cc.p(332,439))
    noticeSystem:setPressedActionEnabled(true)
    noticeSystem:addTouchEventListener(
                function(sender,eventType)
                    if eventType == ccui.TouchEventType.ended then
                        self:noticeSystemClickHandler(sender);
                    end
                end
            )
    containerLayer:addChild( noticeSystem)
    self.noticeSystem = noticeSystem


    local noticeSingle = ccui.Button:create("hall/notice/noticeSingle.png","hall/notice/noticeSingleSelected.png");
    noticeSingle:setPosition(cc.p(332,368))
    noticeSingle:setPressedActionEnabled(true)
    noticeSingle:addTouchEventListener(
                function(sender,eventType)
                    if eventType == ccui.TouchEventType.ended then
                        self:noticeSingleHandler(sender);                        
                    end
                end
            )
    containerLayer:addChild(noticeSingle)
    self.noticeSingle = noticeSingle
    if  kind == 1 then
        noticeSystem:loadTextures("hall/notice/noticeSystemSelected.png","hall/notice/noticeSystemSelected.png")
    else
        noticeSingle:loadTextures("hall/notice/noticeSingleSelected.png","hall/notice/noticeSingleSelected.png")
    end

    -- local exit = ccui.Button:create("common/close.png");
    -- exit:setPosition(cc.p(889,510));
    -- containerLayer:addChild(exit);
    -- exit:setPressedActionEnabled(true);
    -- exit:addTouchEventListener(
    --     function(sender,eventType)
    --         if eventType == ccui.TouchEventType.ended then

    --         	-- self:removeGameEvent();
    --             self:removeFromParent();

    --         end
    --     end
    -- )



    --没有消息
    local noNotice = ccui.ImageView:create("")
    containerLayer:addChild(noNotice)
    noNotice:setPosition(591, 291)
    self.noNotice = noNotice

    local qipao = ccui.ImageView:create("hall/notice/qipao.png")
    qipao:setPosition(148, 158)
    noNotice:addChild(qipao)

    local zanwu = ccui.Text:create("",FONT_ART_TEXT,20)
    zanwu:setPosition(153, 161)
    zanwu:setString("暂无\n消息！")
    zanwu:setColor(cc.c3b(134,65,16))
    noNotice:addChild(zanwu)

    self:noticeSystemClickHandler()
end

function NoticeLayer:noticeSystemClickHandler()
	-- self:removeAllChildren();
	self:refreshList(2)
	-- self:getExchangeValue(1);
    self.noticeSystem:loadTextures("hall/notice/noticeSystemSelected.png","hall/notice/noticeSystemSelected.png")
    self.noticeSingle:loadTextures("hall/notice/noticeSingle.png","hall/notice/noticeSingleSelected.png")
end

function NoticeLayer:noticeSingleHandler()
	-- self:removeAllChildren();
	self:refreshList(1)
	-- self:getExchangeValue(2);
    self.noticeSystem:loadTextures("hall/notice/noticeSystem.png","hall/notice/noticeSystemSelected.png")
    self.noticeSingle:loadTextures("hall/notice/noticeSingleSelected.png","hall/notice/noticeSingleSelected.png")
end

--@param kind  1个人消息2系统消息
function NoticeLayer:refreshList(kind)

    local noticeArray = {}

    if kind == 1 then
        noticeArray = MessageInfo.userLogonMsg
    elseif kind == 2 then
        local listArr = MessageInfo.systemLogonMsg
        local filterType = 2010
        if APP_ID == 1038 then
            filterType = 2010
        elseif APP_ID == 1032 then
            --todo
        end
        for i,v in ipairs(listArr) do
            if v.kindID == filterType then
                table.insert(noticeArray, v)
            end
        end
    end

    -- dump(noticeArray, "noticeArray")

	self.listView:removeAllItems()

	local count = 0--#noticeArray
    if noticeArray ~= nil and #noticeArray>0 then
        self.noNotice:hide()
        count = #noticeArray
    else
        self.noNotice:show()
    end

	-- local testmessage = "最新版欢乐斗地主上线，现在更好玩，画面更精美，叫上你的小伙伴快来玩吧!"
    for i = 1, count do
        local bangItemLayer = ccui.ImageView:create()
        bangItemLayer:loadTexture("hall/notice/itembg.png")
        bangItemLayer:setScale9Enabled(true)
        bangItemLayer:setContentSize(cc.size(440,110))
        bangItemLayer:setCapInsets(cc.rect(50,40,10,10))
        bangItemLayer:ignoreAnchorPointForPosition(true)
        bangItemLayer:setName("ListItem")
        bangItemLayer:setTag(i)

        -- 排名图片
        local emailImage = ccui.ImageView:create()
        emailImage:loadTexture("hall/notice/email.png")
        emailImage:setPosition(cc.p(50,0+50))
        bangItemLayer:addChild(emailImage)
        emailImage:setName("emailImage")

        local LogonMessage = noticeArray[i]
        -- print("LogonMessage",LogonMessage:getRead(),LogonMessage:getMessage(),LogonMessage.message.wSecond,LogonMessage.message.wMilliseconds)
        local message = LogonMessage.msg--"afasdf发生的弗兰克发的&&&456456发生的发顺丰"--
        local contentlist = string.split(message,"&&&")
        local title = contentlist[1] or ""
        local content = contentlist[2] or ""

        local titleLabel = ccui.Text:create(title,"",20)--FONT_PTY_TEXT
        titleLabel:setTextColor(cc.c4b(225,255,0,255))
        titleLabel:enableOutline(cc.c4b(140,58,0,255), 2)
        titleLabel:setPosition(cc.p(84,100))
        titleLabel:setAnchorPoint(cc.p(0,1))
        bangItemLayer:addChild(titleLabel)
        titleLabel:setName("titleLabel")
        titleLabel:setTextAreaSize(cc.size(340,300))
        titleLabel:ignoreContentAdaptWithSize(false)
        titleLabel:setTextHorizontalAlignment(0)
        titleLabel:setTextVerticalAlignment(0)

        local noticeLabel = ccui.Text:create(content,FONT_PTY_TEXT,22)
        noticeLabel:setTextColor(cc.c4b(140,58,0,255))
        noticeLabel:setPosition(cc.p(84,56))
        noticeLabel:setAnchorPoint(cc.p(0,1))
        bangItemLayer:addChild(noticeLabel)
        noticeLabel:setName("noticeLabel")
	    noticeLabel:setTextAreaSize(cc.size(253,76))
	    noticeLabel:ignoreContentAdaptWithSize(false)
	    noticeLabel:setTextHorizontalAlignment(0)
	    noticeLabel:setTextVerticalAlignment(0)

        -- local timeIcon = ccui.ImageView:create("hall/notice/timeIconLastest.png")
        -- timeIcon:setPosition(380, 69)
        -- bangItemLayer:addChild(timeIcon)
        -- local timeLabel = ccui.Text:create("最新消息","",20)
        -- timeLabel:setTextColor(cc.c4b(222,54,38,255))
        -- timeLabel:setPosition(395, 79)
        -- timeLabel:setAnchorPoint(cc.p(0,1))
        -- bangItemLayer:addChild(timeLabel)
        -- local currentTime = os.time()
        -- -- print("currentTime=",currentTime ,"时间差值",currentTime - LogonMessage.message.wMilliseconds)
        -- if (currentTime - LogonMessage.message.wMilliseconds) > 3600 then
        --     timeIcon:loadTexture("hall/notice/timeIconPassed.png")
        --     timeLabel:setTextColor(cc.c4b(140,58,0,255))
        --     timeLabel:setString("1小时前")
        -- end

        local custom_item = ccui.Layout:create()
        custom_item:setTouchEnabled(true)
        custom_item:setContentSize(cc.size(450,120))
        custom_item:addChild(bangItemLayer)
        
        self.listView:pushBackCustomItem(custom_item)
    end
end

return NoticeLayer