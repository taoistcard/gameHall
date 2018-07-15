
local NoticeLayer = class("NoticeLayer", function() return display.newLayer() end)

local EffectFactory = require("commonView.EffectFactory")

function NoticeLayer:ctor(kind)
	-- body
	self:createUI(kind)
end

function NoticeLayer:createUI(kind)
	local displaySize = cc.size(DESIGN_WIDTH,DESIGN_HEIGHT);
    local winSize = cc.Director:getInstance():getWinSize()
    -- 蒙板
    local maskLayer = ccui.ImageView:create("black.png");
    maskLayer:setScale9Enabled(true);
    maskLayer:setContentSize(cc.size(winSize.width, winSize.height));
    maskLayer:setPosition(cc.p(displaySize.width / 2, displaySize.height / 2));
    maskLayer:setTouchEnabled(true);
    maskLayer:addTo(self);

    local bgSprite = ccui.ImageView:create("common/pop_bg.png");
    bgSprite:setPosition(cc.p(displaySize.width / 2, displaySize.height / 2));
    bgSprite:setScale9Enabled(true);
    bgSprite:setContentSize(cc.size(756, 450));
    self:addChild(bgSprite);

    local panel = ccui.ImageView:create("common/panel.png")
    panel:setScale9Enabled(true);
    panel:setContentSize(cc.size(640,340));
    panel:setPosition(380, 225)
    bgSprite:addChild(panel)

    local titleSprite = ccui.ImageView:create("common/pop_title.png");
    titleSprite:setScale9Enabled(true);
    titleSprite:setContentSize(cc.size(250, 50));
    titleSprite:setPosition(cc.p(380, 415));
    bgSprite:addChild(titleSprite,2);

    local xiaoxi = ccui.ImageView:create("hall/notice/xiaoxi.png");
    xiaoxi:setPosition(cc.p(125, 30));
    titleSprite:addChild(xiaoxi);

    -- local xiaoxiword = display.newTTFLabel({text = "消息",
    --                             size = 24,
    --                             color = cc.c3b(255,233,110),
    --                             font = FONT_ART_TEXT,
    --                         })
    --             :addTo(self)
    -- xiaoxiword:setPosition(410, 521)
    -- xiaoxiword:setTextColor(cc.c4b(251,248,142,255))
    -- xiaoxiword:enableOutline(cc.c4b(137,0,167,200), 2)

    local noticeSystem = ccui.Button:create("hall/notice/noticeNotSelect.png","hall/notice/noticeSelected.png");
    noticeSystem:setPosition(cc.p(45, 135))
    noticeSystem:setPressedActionEnabled(true)
    noticeSystem:addTouchEventListener(
                function(sender,eventType)
                    if eventType == ccui.TouchEventType.ended then
                        self:noticeSystemClickHandler(sender);
                    end
                end
            )
    bgSprite:addChild( noticeSystem , 2)
    self.noticeSystem = noticeSystem

    local notice_person = ccui.Text:create("系统消息", "Arial", 24);
    notice_person:setColor(cc.c3b(255,255,255));
    notice_person:setPosition(cc.p(25, 145));
    notice_person:setAnchorPoint(cc.p(0,1))
    notice_person:setTextAreaSize(cc.size(30, 120))
    notice_person:ignoreContentAdaptWithSize(false)
    notice_person:setTextHorizontalAlignment(0)
    notice_person:setTextVerticalAlignment(1)
    noticeSystem:addChild(notice_person);


    local noticeSingle = ccui.Button:create("hall/notice/noticeNotSelect.png","hall/notice/noticeSelected.png");
    noticeSingle:setPosition(cc.p(45,282))
    noticeSingle:setPressedActionEnabled(true)
    noticeSingle:addTouchEventListener(
                function(sender,eventType)
                    if eventType == ccui.TouchEventType.ended then
                        self:noticeSingleHandler(sender);                        
                    end
                end
            )
    bgSprite:addChild(noticeSingle, 1)
    self.noticeSingle = noticeSingle

    local notice_person = ccui.Text:create("个人消息", "Arial", 24);
    notice_person:setColor(cc.c3b(255,255,255));
    notice_person:setPosition(cc.p(25, 145));
    notice_person:setAnchorPoint(cc.p(0,1))
    notice_person:setTextAreaSize(cc.size(30, 120))
    notice_person:ignoreContentAdaptWithSize(false)
    notice_person:setTextHorizontalAlignment(0)
    notice_person:setTextVerticalAlignment(1)
    noticeSingle:addChild(notice_person);

    -- if  kind == 1 then
    --     noticeSystem:loadTextures("hall/notice/noticeSelected.png","hall/notice/noticeSelected.png")
    --     noticeSystem:setLocalZOrder(2)
    --     noticeSingle:setLocalZOrder(1)
    -- else
    --     noticeSingle:loadTextures("hall/notice/noticeSelected.png","hall/notice/noticeSelected.png")
    --     noticeSystem:setLocalZOrder(1)
    --     noticeSingle:setLocalZOrder(2)
    -- end

    local exit = ccui.Button:create("common/close.png");
    exit:setPosition(cc.p(740, 430));
    bgSprite:addChild(exit);
    exit:setPressedActionEnabled(true);
    exit:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then

            	package.loaded["hall.NoticeLayer"] = nil
                self:removeFromParent();

            end
        end
    )

    self.listView = ccui.ListView:create()
    -- set list view ex direction
    self.listView:setDirection(ccui.ScrollViewDir.vertical)
    self.listView:setBounceEnabled(true)
    self.listView:setContentSize(cc.size(555, 290))
    self.listView:setPosition(55, 15)
    panel:addChild(self.listView)
    -- ListView点击事件回调
    local function listViewEvent(sender, eventType)
        -- 事件类型为点击结束
        if eventType == ccui.ListViewEventType.ONSELECTEDITEM_END then
            print("select child index = ",sender:getCurSelectedIndex())
        end
    end
    -- 设置ListView的监听事件
    self.listView:addEventListener(listViewEvent)

    local noNotice = ccui.ImageView:create("hall/notice/noticemask.png")
    noNotice:setScale9Enabled(true)
    noNotice:setContentSize(cc.size(565, 29));
    panel:addChild(noNotice)
    noNotice:setPosition(320, 295)
    noNotice:setFlippedY(true)

    local noNotice = ccui.ImageView:create("hall/notice/noticemask.png")
    noNotice:setScale9Enabled(true)
    noNotice:setContentSize(cc.size(565, 29));
    panel:addChild(noNotice)
    noNotice:setPosition(320, 25)

    --没有消息
    local noNotice = ccui.ImageView:create("common/blank.png")
    panel:addChild(noNotice)
    noNotice:setPosition(0, 0)
    self.noNotice = noNotice

    local qipao = ccui.ImageView:create("hall/notice/qipaowithtext.png")
    qipao:setPosition(370, 210)
    noNotice:addChild(qipao)

    local girl1 = EffectFactory:getInstance():getGirlsArmature("ani_girl_1", 1)
    girl1:align(display.CENTER, 170, 100);
    girl1:setScale(0.80)
    noNotice:addChild(girl1);

    -- local zanwu = ccui.Text:create("",FONT_ART_TEXT,20)
    -- zanwu:setPosition(178, 161)
    -- zanwu:setString("暂无\n消息！")
    -- zanwu:setColor(cc.c3b(134,65,16))
    -- noNotice:addChild(zanwu)

    if  kind == 1 then
        self:noticeSingleHandler()
    else
        self:noticeSystemClickHandler()
    end

end

function NoticeLayer:noticeSystemClickHandler()
	-- self:removeAllChildren();
	self:refreshList(2)
	-- self:getExchangeValue(1);
    self.noticeSystem:loadTextures("hall/notice/noticeSelected.png","hall/notice/noticeSelected.png")
    self.noticeSingle:loadTextures("hall/notice/noticeNotSelect.png","hall/notice/noticeSelected.png")

    self.noticeSystem:setLocalZOrder(2)
    self.noticeSingle:setLocalZOrder(1)
end

function NoticeLayer:noticeSingleHandler()
	-- self:removeAllChildren();
	self:refreshList(1)
	-- self:getExchangeValue(2);
    self.noticeSystem:loadTextures("hall/notice/noticeNotSelect.png","hall/notice/noticeSelected.png")
    self.noticeSingle:loadTextures("hall/notice/noticeSelected.png","hall/notice/noticeSelected.png")
    self.noticeSystem:setLocalZOrder(1)
    self.noticeSingle:setLocalZOrder(2)
end

--@param kind  1个人消息2系统消息
function NoticeLayer:refreshList(kind)

    local noticeArray = {}--MessageInfo.systemLogonMsg--LogonMessageManager:obtainMessages(kind)

    if kind == 1 then
        noticeArray = MessageInfo.userLogonMsg
    elseif kind == 2 then
        local listArr = MessageInfo.systemLogonMsg
        local filterType = 6
        if APP_ID == 1038 then
            filterType = 2010
        elseif APP_ID == 1032 then
            filterType = 6
        end
        for i,v in ipairs(listArr) do
            -- print(v.id,"v.kindID",v.kindID,v.msg)
            if v.kindID == filterType then
                table.insert(noticeArray, v)
            end
        end
    end
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
        bangItemLayer:loadTexture("hall/notice/list_item.png")
        bangItemLayer:setScale9Enabled(true)
        bangItemLayer:setCapInsets(cc.rect(50,40,10,10))
        bangItemLayer:ignoreAnchorPointForPosition(true)
        bangItemLayer:setName("ListItem")
        bangItemLayer:setTag(i)

        local emailImage = ccui.ImageView:create()
        emailImage:loadTexture("common/email.png")
        
        bangItemLayer:addChild(emailImage)
        emailImage:setName("emailImage")

        local LogonMessage = noticeArray[i]
        local message = LogonMessage.msg--"afasdf发生的弗兰克发的&&&456456发生的发顺丰"--
        local contentlist = string.split(message,"&&&")
        local title = contentlist[1] or ""
        local content = contentlist[2] or ""

        local titleLabel = ccui.Text:create(title,"",26)
        titleLabel:setTextColor(cc.c4b(80,52,18,255))
        -- titleLabel:enableOutline(cc.c4b(140,58,0,255), 2)
        titleLabel:setAnchorPoint(cc.p(0, 0.5))
        bangItemLayer:addChild(titleLabel)
        titleLabel:setName("titleLabel")
        
        local noticeLabel = ccui.Text:create(content,"",24)
        noticeLabel:setTextColor(cc.c4b(131,100,57,255))
        noticeLabel:setAnchorPoint(cc.p(0, 0.5))
        bangItemLayer:addChild(noticeLabel)
        noticeLabel:setName("noticeLabel")
	    

        local titconsize = titleLabel:getContentSize()
        local titheight = 35 * math.ceil(titconsize.width / 320)
        if titheight < 35 then titheight = 35 end

        local consize = noticeLabel:getContentSize()
        local conheight = 30 * math.ceil(consize.width / 415)
        if conheight < 30 then conheight = 30 end

        local itemHeight = 10 + titheight + 7 + conheight + 10

        bangItemLayer:setContentSize(cc.size(535, itemHeight))

        emailImage:setPosition(cc.p(50, itemHeight - 35))

        titleLabel:setPosition(cc.p(84, itemHeight - 10 - titheight * 0.5))
        titleLabel:setTextAreaSize(cc.size(320, titheight))
        titleLabel:ignoreContentAdaptWithSize(false)
        titleLabel:setTextHorizontalAlignment(0)
        titleLabel:setTextVerticalAlignment(0)

        noticeLabel:setPosition(cc.p(84, itemHeight - 10 - titheight - 7 - conheight * 0.5))
        noticeLabel:setTextAreaSize(cc.size(430, conheight))
        noticeLabel:ignoreContentAdaptWithSize(false)
        noticeLabel:setTextHorizontalAlignment(0)
        noticeLabel:setTextVerticalAlignment(0)


        local timeIcon = ccui.ImageView:create("hall/notice/timeIconLastest.png")
        timeIcon:setPosition(430, itemHeight - 25)
        bangItemLayer:addChild(timeIcon)
        local timeLabel = ccui.Text:create("最新消息","",20)
        timeLabel:setTextColor(cc.c4b(222,54,38,255))
        timeLabel:setPosition(445, itemHeight - 25)
        timeLabel:setAnchorPoint(cc.p(0,0.5))
        bangItemLayer:addChild(timeLabel)
        local currentTime = os.time()
        -- print("currentTime=",currentTime ,"时间差值",currentTime - LogonMessage.message.wMilliseconds)
        if (currentTime - LogonMessage.startTime) > 3600 then
            timeIcon:loadTexture("hall/notice/timeIconPassed.png")
            timeLabel:setTextColor(cc.c4b(140,58,0,255))
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