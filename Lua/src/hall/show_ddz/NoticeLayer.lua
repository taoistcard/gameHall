
--
local NoticeLayer = class("NoticeLayer", function() return display.newLayer() end)

function NoticeLayer:ctor(kind)
	-- body

	self:createUI(kind)
end
function NoticeLayer:createUI(kind)
	local displaySize = cc.size(display.width, display.height);
    local winSize = cc.Director:getInstance():getWinSize()
    -- 蒙板
    local maskLayer = ccui.ImageView:create("black.png");
    maskLayer:setScale9Enabled(true);
    maskLayer:setContentSize(cc.size(winSize.width, winSize.height));
    maskLayer:setPosition(cc.p(displaySize.width / 2, displaySize.height / 2));
    maskLayer:setTouchEnabled(true);
    maskLayer:addTo(self);

    local bgSprite = ccui.ImageView:create("common/hall_frame_bg.png");
    -- bgSprite:setPosition(cc.p(displaySize.width / 2, displaySize.height / 2));
    bgSprite:setScale9Enabled(true);
    bgSprite:setContentSize(cc.size(750, 420));
    bgSprite:setPosition(cc.p(585,312));
    self:addChild(bgSprite);

    local panel = ccui.ImageView:create("common/hall_frame.png")
    panel:setScale9Enabled(true);
    panel:setContentSize(cc.size(673,344));
    panel:setPosition(585, 307)
    self:addChild(panel)

    local titleSprite = cc.Sprite:create("common/hall_title_bg.png");
    titleSprite:setPosition(cc.p(580, 515));
    self:addChild(titleSprite,2);

    local pcWord = ccui.ImageView:create("hallScene/notice/word.png");
    pcWord:setPosition(214, 55);
    titleSprite:addChild(pcWord);

    -- local pop_title = ccui.ImageView:create("common/pop_title.png");
    -- pop_title:setPosition(cc.p(386,498));
    -- self:addChild(pop_title);

    -- local xiaoxi = ccui.ImageView:create("hallScene/notice/xiaoxi.png");
    -- xiaoxi:setPosition(cc.p(358,526));
    -- self:addChild(xiaoxi);

    -- local xiaoxiword = display.newTTFLabel({text = "消息",
    --                             size = 24,
    --                             color = cc.c3b(255,233,110),
    --                             font = FONT_ART_TEXT,
    --                         })
    --             :addTo(self)
    -- xiaoxiword:setPosition(410, 521)
    -- xiaoxiword:setTextColor(cc.c4b(251,248,142,255))
    -- xiaoxiword:enableOutline(cc.c4b(137,0,167,200), 2)

    local noticeSystem = ccui.Button:create("hallScene/notice/noticeSystem.png","hallScene/notice/noticeSystemSelected.png");
    noticeSystem:setPosition(cc.p(240,394))
    noticeSystem:setPressedActionEnabled(true)
    noticeSystem:addTouchEventListener(
                function(sender,eventType)
                    if eventType == ccui.TouchEventType.ended then
                        self:noticeSystemClickHandler(sender);
                    end
                end
            )
    self:addChild( noticeSystem,1)
    self.noticeSystem = noticeSystem


    local noticeSingle = ccui.Button:create("hallScene/notice/noticeSingle.png","hallScene/notice/noticeSingleSelected.png");
    noticeSingle:setPosition(cc.p(240,260))
    noticeSingle:setPressedActionEnabled(true)
    noticeSingle:addTouchEventListener(
                function(sender,eventType)
                    if eventType == ccui.TouchEventType.ended then
                        self:noticeSingleHandler(sender);                        
                    end
                end
            )
    self:addChild(noticeSingle,1)
    self.noticeSingle = noticeSingle
    if  kind == 1 then
        noticeSystem:loadTextures("hallScene/notice/noticeSystemSelected.png","hallScene/notice/noticeSystemSelected.png")
    else
        noticeSingle:loadTextures("hallScene/notice/noticeSingleSelected.png","hallScene/notice/noticeSingleSelected.png")
    end

    local exit = ccui.Button:create("common/hall_close.png");
    exit:setPosition(cc.p(954,510));
    self:addChild(exit);
    exit:setPressedActionEnabled(true);
    exit:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then

            	-- self:removeGameEvent();
                self:removeFromParent();

            end
        end
    )

    self.listView = ccui.ListView:create()
    -- set list view ex direction
    self.listView:setDirection(ccui.ScrollViewDir.vertical)
    self.listView:setBounceEnabled(true)
    self.listView:setContentSize(cc.size(650,330))--492, 275
    self.listView:setPosition(602-230-110,307-138-25)
    self:addChild(self.listView)
    -- ListView点击事件回调
    local function listViewEvent(sender, eventType)
        -- 事件类型为点击结束
        if eventType == ccui.ListViewEventType.ONSELECTEDITEM_END then
            print("select child index = ",sender:getCurSelectedIndex())
        end
    end
    -- 设置ListView的监听事件
    self.listView:addEventListener(listViewEvent)

    --没有消息
    local noNotice = ccui.ImageView:create("hallScene/notice/dizhu.png")
    self:addChild(noNotice)
    noNotice:setPosition(591, 291)
    self.noNotice = noNotice

    local qipao = ccui.ImageView:create("hallScene/notice/qipao.png")
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
    self.noticeSystem:loadTextures("hallScene/notice/noticeSystemSelected.png","hallScene/notice/noticeSystemSelected.png")
    self.noticeSingle:loadTextures("hallScene/notice/noticeSingle.png","hallScene/notice/noticeSingleSelected.png")
end
function NoticeLayer:noticeSingleHandler()
	-- self:removeAllChildren();
	self:refreshList(1)
	-- self:getExchangeValue(2);
    self.noticeSystem:loadTextures("hallScene/notice/noticeSystem.png","hallScene/notice/noticeSystemSelected.png")
    self.noticeSingle:loadTextures("hallScene/notice/noticeSingleSelected.png","hallScene/notice/noticeSingleSelected.png")
end
--@param kind  1个人消息2系统消息
 
function NoticeLayer:refreshList(kind)

    local noticeArray = {}--MessageInfo.systemLogonMsg--LogonMessageManager:obtainMessages(kind)
    if kind == 1 then
        noticeArray = MessageInfo.userLogonMsg
    elseif kind == 2 then
        local listArr = MessageInfo.systemLogonMsg
        local filterType = HallSetting.getAllKindID(curGameName)

        for i,v in ipairs(listArr) do
            for _, vv in ipairs(filterType) do
                if v.kindID == vv then
                    table.insert(noticeArray, v)
                end                
            end
        end
    end

    -- if kind == 1 then
    --     noticeArray = MessageInfo.userLogonMsg
    -- end

	self.listView:removeAllItems()
	local count = 0
    if noticeArray ~= nil and #noticeArray>0 then
        self.noNotice:hide()
        count = #noticeArray
    else
        self.noNotice:show()
    end
	-- local testmessage = "最新版欢乐斗地主上线，现在更好玩，画面更精美，叫上你的小伙伴快来玩吧!"
    for i = 1, count do
        local bangItemLayer = ccui.ImageView:create()
        bangItemLayer:loadTexture("hallScene/notice/list_item.png")
        bangItemLayer:setScale9Enabled(true)
        bangItemLayer:setContentSize(cc.size(645,120))--485,84
        bangItemLayer:setCapInsets(cc.rect(50,40,10,10))
        bangItemLayer:ignoreAnchorPointForPosition(true)
        bangItemLayer:setName("ListItem")
        bangItemLayer:setTag(i)


        -- 排名图片
        local emailImage = ccui.ImageView:create()
        emailImage:loadTexture("hallScene/notice/email.png")
        emailImage:setPosition(cc.p(40,60))
        bangItemLayer:addChild(emailImage)
        emailImage:setName("emailImage")

        local LogonMessage = noticeArray[i]
        -- print("LogonMessage",LogonMessage:getRead(),LogonMessage:getMessage(),LogonMessage.message.wSecond,LogonMessage.message.wMilliseconds)
        local message = LogonMessage.msg--"afasdf发生的弗兰克发的&&&456456发生的发顺丰"--
        local contentlist = string.split(message,"&&&")
        local title = contentlist[1] or ""
        local content = contentlist[2] or ""
        local titleLabel = ccui.Text:create(title,"",20)
        titleLabel:setTextColor(cc.c4b(140,58,0,255))
        titleLabel:enableOutline(cc.c4b(140,58,0,255), 1)
        titleLabel:setPosition(cc.p(80,115))
        titleLabel:setAnchorPoint(cc.p(0,1))
        bangItemLayer:addChild(titleLabel)
        titleLabel:setName("titleLabel")
        titleLabel:setTextAreaSize(cc.size(420,100))
        titleLabel:ignoreContentAdaptWithSize(false)
        titleLabel:setTextHorizontalAlignment(0)
        titleLabel:setTextVerticalAlignment(0)
        local noticeLabel = ccui.Text:create(content,"",20)
        noticeLabel:setTextColor(cc.c4b(140,58,0,255))
        noticeLabel:setPosition(cc.p(80,90))
        noticeLabel:setAnchorPoint(cc.p(0,1))
        bangItemLayer:addChild(noticeLabel)
        noticeLabel:setName("noticeLabel")
	    noticeLabel:setTextAreaSize(cc.size(530,100))
	    noticeLabel:ignoreContentAdaptWithSize(false)
	    noticeLabel:setTextHorizontalAlignment(0)
	    noticeLabel:setTextVerticalAlignment(0)

        local timeIcon = ccui.ImageView:create("hallScene/notice/timeIconLastest.png")
        timeIcon:setPosition(525, 105)
        bangItemLayer:addChild(timeIcon)
        local timeLabel = ccui.Text:create("最新消息","",18)
        timeLabel:setTextColor(cc.c4b(222,54,38,255))
        timeLabel:setPosition(540, 115)
        timeLabel:setAnchorPoint(cc.p(0,1))
        bangItemLayer:addChild(timeLabel)
        local currentTime = os.time()
        -- print("currentTime=",currentTime ,"时间差值",currentTime - LogonMessage.message.wMilliseconds)
        if (currentTime - LogonMessage.startTime) > 3600 then
            timeIcon:loadTexture("hallScene/notice/timeIconPassed.png")
            timeLabel:setTextColor(cc.c4b(255,0,0,255))
            timeLabel:setString("1小时前")
        end

        local custom_item = ccui.Layout:create()
        custom_item:setTouchEnabled(true)
        custom_item:setContentSize(bangItemLayer:getContentSize())
        custom_item:addChild(bangItemLayer)
        
        self.listView:pushBackCustomItem(custom_item)
    end
end
return NoticeLayer