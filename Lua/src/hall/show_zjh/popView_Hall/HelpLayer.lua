
local HelpLayer = class("HelpLayer",function() return display.newLayer() end)

local m_itemsArray = {"游戏简介","基本规则","桌面功能介绍","牌型比较","常见问题","游戏说明","意见反馈"}
local bgSize = cc.size(674, 433)

function HelpLayer:ctor(inGame)
    self.inGame = inGame or false
    self.score = 0
    self.insure = 0
    self.selectScore = 0
    self.selectInsure = 0

    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    self:setNodeEventEnabled(true)

    local winSize = cc.Director:getInstance():getWinSize()
    local contentSize
    if inGame then
        contentSize = cc.size(656,winSize.height)
    else
        contentSize = cc.size(winSize.width,winSize.height)
    end
    self:setContentSize(contentSize)
    -- 蒙板
    local maskLayer = ccui.ImageView:create()
    maskLayer:loadTexture("common/black.png")
    maskLayer:setContentSize(contentSize);
    maskLayer:setScale9Enabled(true)
    maskLayer:setCapInsets(cc.rect(4,4,1,1))
    maskLayer:setPosition(cc.p(DESIGN_WIDTH/2, DESIGN_HEIGHT/2));
    maskLayer:setTouchEnabled(true)
    self:addChild(maskLayer)

    self:createUI();
    
end

function HelpLayer:onExit()
    package.loaded["show_zjh.popView_Hall.HelpLayer"] = nil
end

function HelpLayer:createUI()
    local contentSize = self:getContentSize()
    

    local bgSprite = ccui.ImageView:create("common/ty_bank_bg.png");
    bgSprite:setScale9Enabled(true);
    bgSprite:setContentSize(bgSize);
    bgSprite:setPosition(cc.p(555, 338));
    self:addChild(bgSprite);
    self.container = bgSprite

    local exit = ccui.Button:create("common/close.png");
    exit:setPosition(cc.p(bgSize.width - 10, bgSize.height - 10));
    bgSprite:addChild(exit);
    exit:setPressedActionEnabled(true);
    exit:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                package.loaded["show_zjh.popView_Hall.HelpLayer"] = nil
                self:removeFromParent();
            end
        end
    )

    local titleSprite = ccui.ImageView:create("common/pop_title.png");
    titleSprite:setScale9Enabled(true);
    titleSprite:setContentSize(cc.size(226, 48));
    titleSprite:setPosition(cc.p(bgSize.width / 2, bgSize.height - 24));
    bgSprite:addChild(titleSprite,2);

    local title = ccui.Text:create("帮助中心", FONT_ART_TEXT, 24)
    title:setPosition(cc.p(113, 27))
    title:setTextColor(cc.c4b(251,248,142,255))
    title:enableOutline(cc.c4b(137,0,167,200), 3)
    title:addTo(titleSprite)

    --back button
    local backButton = ccui.ImageView:create()
    backButton:setTouchEnabled(true)
    backButton:loadTexture("common/back.png")
    backButton:setPosition(cc.p(90, bgSize.height - 34))
    bgSprite:addChild(backButton)
    backButton:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.began then
            -- SoundManager:getInstance():playSoundByType(SoundType.BTN_CLICK)
            backButton:setScale(1.1)
        elseif eventType == ccui.TouchEventType.ended then
            backButton:setScale(1.0)
            self:onClickBack();
        elseif eventType == ccui.TouchEventType.canceled then
            backButton:setScale(1.0)
        end
    end)
    self.backButton = backButton
    self.backButton:setVisible(false)


    -- panel
    local panel = ccui.ImageView:create("common/blank.png")
    panel:setScale9Enabled(true);
    panel:setContentSize(cc.size(bgSize.width - 40, bgSize.height - 70));
    panel:setAnchorPoint(cc.p(0,0))
    panel:setPosition(cc.p(20, 10));
    bgSprite:addChild(panel);


    self.listView = ccui.ListView:create()
    self.listView:setDirection(ccui.ScrollViewDir.vertical)
    self.listView:setBounceEnabled(true)
    self.listView:setContentSize(cc.size(bgSize.width - 50, bgSize.height - 80))
    self.listView:setPosition(5,5)
    panel:addChild(self.listView)
    -- ListView点击事件回调
    local function listViewEvent(sender, eventType)
        -- 事件类型为点击结束
        if eventType == ccui.ListViewEventType.ONSELECTEDITEM_END then
            print("HelpLayer select child index = ",sender:getCurSelectedIndex())
            self:showHelpContent(sender:getCurSelectedIndex())
        end
    end
    -- 设置ListView的监听事件
    self.listView:addEventListener(listViewEvent)

    for i = 1, #m_itemsArray do
    	local itemLayer = ccui.ImageView:create("common/panel2.png")
        itemLayer:setScale9Enabled(true);
        itemLayer:setContentSize(cc.size(bgSize.width - 50, 70));
        itemLayer:ignoreAnchorPointForPosition(true)
        itemLayer:setName("ListItem")
        itemLayer:setTag(i)

        local itemLabel = ccui.Text:create(m_itemsArray[i], FONT_ART_TEXT, 24)
        itemLabel:setTextColor(cc.c4b(255,255,255,255))
        itemLabel:setAnchorPoint(cc.p(0, 0.5))
        itemLabel:setPosition(cc.p(25, 35))
        itemLabel:enableOutline(cc.c4b(140,58,0,200), 1)
        itemLayer:addChild(itemLabel)
        itemLabel:setName("itemLabel")

        local custom_item = ccui.Layout:create()
        custom_item:setTouchEnabled(true)
        custom_item:setContentSize(cc.size(bgSize.width - 40, 78))
        custom_item:addChild(itemLayer)
        
        self.listView:pushBackCustomItem(custom_item)
    end

end

function HelpLayer:showHelpContent(index)
    if index == 0 then
        self:showYouXiJianJie()
    elseif index == 1 then
        self:showJiBenGuiZe()
    elseif index == 2 then
        self:showZhuoMianGongNeng()
    elseif index == 3 then
        self:showPaiXingBiJiao()
    elseif index == 4 then
        self:showChangJianWenTi()
    elseif index == 5 then
        self:showYouXiShuoMing()
    elseif index == 6 then
        self:showYiJianFanKui()
    end
end

function HelpLayer:onClickBack()
    self.backButton:setVisible(false)
    self.curMaskLayer:removeFromParent()
    self.curMaskLayer = nil
end

--游戏简介
function HelpLayer:showYouXiJianJie()
    local panel = ccui.ImageView:create("common/panel_bg.png")
    panel:setScale9Enabled(true);
    panel:setContentSize(cc.size(bgSize.width - 40, bgSize.height - 70));
    panel:setAnchorPoint(cc.p(0,0))
    panel:setPosition(cc.p(20, 10));
    self.container:addChild(panel,10);

    self.curMaskLayer = panel
    self.backButton:setVisible(true)

    local listView = ccui.ListView:create()
    listView:setDirection(ccui.ScrollViewDir.vertical)
    listView:setBounceEnabled(true)
    listView:setContentSize(cc.size(bgSize.width - 60, bgSize.height - 90))
    listView:setPosition(10, 10)
    panel:addChild(listView)

    local underWriteLabel = ccui.Text:create("金三顺是民间非常流行的一种扑克牌玩法，俗称“三张”它具有特定的比牌规则，玩家按照规则以手中的牌来决定输赢。在游戏过程中需要考验玩家的胆略和智慧，且由于玩法简单，易接受。因此金三顺是被公认的最受欢迎的纸牌游戏之一。", "Arial", 24);
    underWriteLabel:setColor(cc.c3b(255,230,100));
    underWriteLabel:setPosition(5, bgSize.height - 90);
    underWriteLabel:setAnchorPoint(cc.p(0,1))
    underWriteLabel:setTextAreaSize(cc.size(bgSize.width - 60, bgSize.height - 90))
    underWriteLabel:ignoreContentAdaptWithSize(false)
    underWriteLabel:setTextHorizontalAlignment(0)
    underWriteLabel:setTextVerticalAlignment(0)

    local custom_item = ccui.Layout:create()
    custom_item:setTouchEnabled(true)
    custom_item:setContentSize(underWriteLabel:getContentSize())
    custom_item:addChild(underWriteLabel)
    
    listView:pushBackCustomItem(custom_item)
end

--基本规则
function HelpLayer:showJiBenGuiZe()
    local panel = ccui.ImageView:create("common/panel_bg.png")
    panel:setScale9Enabled(true);
    panel:setContentSize(cc.size(bgSize.width - 40, bgSize.height - 70));
    panel:setAnchorPoint(cc.p(0,0))
    panel:setPosition(cc.p(20, 10));
    self.container:addChild(panel,10);

    self.curMaskLayer = panel
    self.backButton:setVisible(true)

    local listView = ccui.ListView:create()
    listView:setDirection(ccui.ScrollViewDir.vertical)
    listView:setBounceEnabled(true)
    listView:setContentSize(cc.size(bgSize.width - 60, bgSize.height - 90))
    listView:setPosition(10, 10)
    panel:addChild(listView)

    local theight = 400
    local strlist = {}
    strlist[1] = {str="(1)游戏人数可为2~5人，一副扑克牌共28张(去掉大小王和2~7)", size=cc.size(bgSize.width - 60, 40), pos=cc.p(5, theight-5)}
    strlist[2] = {str="(2)游戏开始后投入底注：发牌之前大家先付出的筹码。", size=cc.size(bgSize.width - 60, 40), pos=cc.p(5, theight-35)}
    strlist[3] = {str="(3)发牌:从庄家开始依次发牌，第一次开局则随机选择一个用户先发牌。牌面向下，为暗牌。", size=cc.size(bgSize.width - 60, 80), pos=cc.p(5, theight-65)}
    strlist[4] = {str="(4)庄家的顺时针的下一家先开始下注，其他玩家依次顺时针操作。轮到玩家操作时，玩家根据条件和判断形势可以进行加注、跟注、看牌、放弃、开牌等操作。", size=cc.size(bgSize.width - 60, 120), pos=cc.p(5, theight-125)}
    strlist[5] = {str="(5)开牌：当玩家所持筹码数少于该局加满数的6倍时，则玩家需选择开牌。", size=cc.size(bgSize.width - 60, 80), pos=cc.p(5, theight-215)}
    strlist[6] = {str="(6)判断胜负：根据牌型比较规则来判断胜负。如果可以投入筹码的玩家只剩下一个，则判此玩家为胜利玩家。", size=cc.size(bgSize.width - 60, 80), pos=cc.p(5, theight-275)}
    
    local custom_item = ccui.Layout:create()
    custom_item:setTouchEnabled(true)
    custom_item:setContentSize(cc.size(bgSize.width - 60, theight))


    for i, v in ipairs(strlist) do

        local underWriteLabel = ccui.Text:create(v.str, "", 22);
        underWriteLabel:setColor(cc.c3b(255,230,100));
        underWriteLabel:setAnchorPoint(cc.p(0,1))
        underWriteLabel:setTextAreaSize(v.size)
        underWriteLabel:ignoreContentAdaptWithSize(false)
        underWriteLabel:setTextHorizontalAlignment(0)
        underWriteLabel:setTextVerticalAlignment(0)
        underWriteLabel:setPosition(v.pos)

        custom_item:addChild(underWriteLabel)

    end


    listView:pushBackCustomItem(custom_item)

end

--桌面功能介绍
function HelpLayer:showZhuoMianGongNeng()
    local panel = ccui.ImageView:create("common/panel_bg.png")
    panel:setScale9Enabled(true);
    panel:setContentSize(cc.size(bgSize.width - 40, bgSize.height - 70));
    panel:setAnchorPoint(cc.p(0,0))
    panel:setPosition(cc.p(20, 10));
    self.container:addChild(panel,10);

    self.curMaskLayer = panel
    self.backButton:setVisible(true)

    -- local listView = ccui.ListView:create()
    -- listView:setDirection(ccui.ScrollViewDir.horizontal)
    -- listView:setBounceEnabled(true)
    -- listView:setContentSize(cc.size(bgSize.width - 60, bgSize.height - 90))
    -- listView:setPosition(10, 10)
    -- panel:addChild(listView)

    local pageView = ccui.PageView:create()
    pageView:setTouchEnabled(true)
    pageView:setContentSize(cc.size(bgSize.width - 50, bgSize.height - 80))
    pageView:setPosition(cc.p(4,5))
    panel:addChild(pageView)


    local strlist = {}
    strlist[1] = {file="help/gongneng1.jpg", size=cc.size(bgSize.width - 60, bgSize.height - 90)}
    strlist[2] = {file="help/gongneng2.jpg", size=cc.size(bgSize.width - 60, bgSize.height - 90)}
    strlist[3] = {file="help/gongneng3.jpg", size=cc.size(bgSize.width - 60, bgSize.height - 90)}

    for i, v in ipairs(strlist) do
        local img = ccui.ImageView:create(v.file)
        -- img:setScale9Enabled(true);
        -- img:setContentSize(v.size);
        img:setScale(0.55)
        img:setPosition(0, 0)
        img:setAnchorPoint(cc.p(0,0))

        local custom_item = ccui.Layout:create()
        custom_item:setTouchEnabled(true)
        custom_item:setContentSize(v.size)
        custom_item:addChild(img)

        -- listView:pushBackCustomItem(custom_item)
        pageView:addPage(custom_item)
    end
end

--牌型比较
function HelpLayer:showPaiXingBiJiao()
    local panel = ccui.ImageView:create("common/panel_bg.png")
    panel:setScale9Enabled(true);
    panel:setContentSize(cc.size(bgSize.width - 40, bgSize.height - 70));
    panel:setAnchorPoint(cc.p(0,0))
    panel:setPosition(cc.p(20, 10));
    self.container:addChild(panel,10);

    self.curMaskLayer = panel
    self.backButton:setVisible(true)

    local listView = ccui.ListView:create()
    listView:setDirection(ccui.ScrollViewDir.vertical)
    listView:setBounceEnabled(true)
    listView:setContentSize(cc.size(bgSize.width - 60, bgSize.height - 90))
    listView:setPosition(10, 10)
    panel:addChild(listView)


    local theight = 500
    local strlist = {}
    strlist[1] = {str="(1)豹子:三张点数相同的牌,如AAA,KKK。", size=cc.size(bgSize.width - 60, 40), pos=cc.p(5, theight-5)}
    strlist[2] = {str="(2)同花顺:花色一样的顺子,如 ♠JQK, ♣QKA。", size=cc.size(bgSize.width - 60, 40), pos=cc.p(5, theight-35)}
    strlist[3] = {str="(3)同花:花色一样,但不是顺子,如 ♥9JQ, ♠8KA。", size=cc.size(bgSize.width - 60, 40), pos=cc.p(5, theight-65)}
    strlist[4] = {str="(4)顺子:花色不一样的顺子,如 ♦7♠8♥9。", size=cc.size(bgSize.width - 60, 40), pos=cc.p(5, theight-95)}
    strlist[5] = {str="(5)对子:含有两张点数一样的牌,如778,JJK。", size=cc.size(bgSize.width - 60, 40), pos=cc.p(5, theight-125)}
    strlist[6] = {str="(6)特殊:花色不同的 235。", size=cc.size(bgSize.width - 60, 40), pos=cc.p(5, theight-155)}
    strlist[7] = {str="(7)单张:无法组成以上的任何牌型", size=cc.size(bgSize.width - 60, 40), pos=cc.p(5, theight-185)}
    strlist[8] = {str="(8)豹子 > 同花顺 > 同花 > 顺子 > 对子 > 单张 ", size=cc.size(bgSize.width - 60, 40), pos=cc.p(5, theight-215)}
    strlist[9] = {str="(9)如果牌型一样，则比较点数。大小若相同，开牌者输。", size=cc.size(bgSize.width - 60, 40), pos=cc.p(5, theight-245)}
    strlist[10] = {str="(10)牌的点数大小为：去掉大小王和2~7后，A最大，8最小。A>K>Q>J>10>9>8", size=cc.size(bgSize.width - 60, 80), pos=cc.p(5, theight-275)}
    strlist[11] = {str="(11)豹子、同花、对子、单张的比较，按照顺序比点的规则比较大小。", size=cc.size(bgSize.width - 60, 80), pos=cc.p(5, theight-335)}
    strlist[12] = {str="(12)同花顺、顺子按照顺序比点。例：AKQ > KQJ > QJ10 > A89（注：因为去掉了2~7，所以A89为顺子)", size=cc.size(bgSize.width - 60, 80), pos=cc.p(5, theight-395)}

    local custom_item = ccui.Layout:create()
    custom_item:setTouchEnabled(true)
    custom_item:setContentSize(cc.size(bgSize.width - 60, theight))


    for i, v in ipairs(strlist) do

        local underWriteLabel = ccui.Text:create(v.str, "", 22);
        underWriteLabel:setColor(cc.c3b(255,230,100));
        underWriteLabel:setAnchorPoint(cc.p(0,1))
        underWriteLabel:setTextAreaSize(v.size)
        underWriteLabel:ignoreContentAdaptWithSize(false)
        underWriteLabel:setTextHorizontalAlignment(0)
        underWriteLabel:setTextVerticalAlignment(0)
        underWriteLabel:setPosition(v.pos)

        custom_item:addChild(underWriteLabel)

    end


    listView:pushBackCustomItem(custom_item)
end

--常见问题
function HelpLayer:showChangJianWenTi()
    local panel = ccui.ImageView:create("common/panel_bg.png")
    panel:setScale9Enabled(true);
    panel:setContentSize(cc.size(bgSize.width - 40, bgSize.height - 70));
    panel:setAnchorPoint(cc.p(0,0))
    panel:setPosition(cc.p(20, 10));
    self.container:addChild(panel,10);

    self.curMaskLayer = panel
    self.backButton:setVisible(true)

    local listView = ccui.ListView:create()
    listView:setDirection(ccui.ScrollViewDir.vertical)
    listView:setBounceEnabled(true)
    listView:setContentSize(cc.size(bgSize.width - 60, bgSize.height - 90))
    listView:setPosition(10, 10)
    panel:addChild(listView)

    local theight = 1500
    local strlist = {}
    strlist[1] = {title="(1)什么是游客账号？",str="为了方便玩家能够快捷的开始游戏，98·金三顺为玩家设置了游客身份的注册，无需注册就能登陆进行游戏；该账号存在设定限制，建议只在98·金三顺进行游戏。", size=cc.size(bgSize.width - 60, 180), pos=cc.p(5, theight-5)}
    strlist[2] = {title="(2)注册账号 ",str="玩家可在游戏界面中的“新注册”中，自行注册一个新账号，新账号注册后，系统加送5000筹码。每个手机只有五个账号的注册机会才有免费筹码，过多的话则后面注册的账号就无法领取免费筹码。", size=cc.size(bgSize.width - 60, 180), pos=cc.p(5, theight-180)}
    strlist[3] = {title="(3)密保手机号码",str="玩家在进行注册账号的同时建议同时绑定密保手机号码。绑定后，如忘记密码可以通过密码手机号码找回。", size=cc.size(bgSize.width - 60, 180), pos=cc.p(5, theight-390)}
    strlist[4] = {title="(4)关于充值的问题 ",str="玩家在商城中购买了元宝，在通过兑换将元宝兑换成筹码自动存入账户。", size=cc.size(bgSize.width - 60, 180), pos=cc.p(5, theight-520)}
    strlist[5] = {title="(5)保险柜存取问题 ",str="玩家可将身上的金币存入保险柜中，存入金币需收取少许的手续费，取出金币免费。", size=cc.size(bgSize.width - 60, 180), pos=cc.p(5, theight-660)}
    strlist[6] = {title="(6)无法登陆游戏、突然掉线、画面停滞、无法下注等问题 ",str="如果网络情况不佳或者无网络的情况下，可能会导致上述问题，建议您先检查设备的网络连接情况，如果依然存在，可以关闭应用重启或者稍后再试。", size=cc.size(bgSize.width - 60, 180), pos=cc.p(5, theight-820)}
    strlist[7] = {title="(7)有时游戏自动退出或者无法进入的问题 ",str="如果您安装了流氓软件、越狱、终端记忆不足或者网络情况不佳等，会导致上述问题，建议您先检查网络情况，关闭后台运行的其他程序，再重新登录；如果问题依然存在，请在意见反馈栏 中及时反馈，我们会尽快给您答复。", size=cc.size(bgSize.width - 60, 180), pos=cc.p(5, theight-1000)}
    strlist[8] = {title="(8)联系我们 ",str="玩家在游戏中碰到任何问题，均可以在登陆界面“帮助”中的意见反馈栏中进行询问，我们会在第一时间给予答复。客服QQ：2216314986 ", size=cc.size(bgSize.width - 60, 180), pos=cc.p(5, theight-1200)}
    
    local custom_item = ccui.Layout:create()
    custom_item:setTouchEnabled(true)
    custom_item:setContentSize(cc.size(bgSize.width - 60, theight))

    for _, v in ipairs(strlist) do
        local title = ccui.Text:create(v.title, FONT_ART_TEXT,26)
        title:setAnchorPoint(cc.p(0,1))
        title:setPosition(v.pos)
        title:setColor(cc.c3b(255,228,0))
        custom_item:addChild(title)
        
        local underWriteLabel = ccui.Text:create(v.str, "", 22);
        underWriteLabel:setColor(cc.c3b(255,230,100));
        underWriteLabel:setAnchorPoint(cc.p(0,1))
        underWriteLabel:setTextAreaSize(v.size)
        underWriteLabel:ignoreContentAdaptWithSize(false)
        underWriteLabel:setTextHorizontalAlignment(0)
        underWriteLabel:setTextVerticalAlignment(0)
        underWriteLabel:setPosition(v.pos.x, v.pos.y-30)

        custom_item:addChild(underWriteLabel)

    end

    listView:pushBackCustomItem(custom_item)
   
end

--游戏说明
function HelpLayer:showYouXiShuoMing()
    local panel = ccui.ImageView:create("common/panel_bg.png")
    panel:setScale9Enabled(true);
    panel:setContentSize(cc.size(bgSize.width - 40, bgSize.height - 70));
    panel:setAnchorPoint(cc.p(0,0))
    panel:setPosition(cc.p(20, 10));
    self.container:addChild(panel,10);

    self.curMaskLayer = panel
    self.backButton:setVisible(true)

    local listView = ccui.ListView:create()
    listView:setDirection(ccui.ScrollViewDir.vertical)
    listView:setBounceEnabled(true)
    listView:setContentSize(cc.size(bgSize.width - 60, bgSize.height - 90))
    listView:setPosition(10, 10)
    panel:addChild(listView)

    local theight = 1400
    local strlist = {}
    strlist[1] = {size=cc.size(bgSize.width - 60, 300), pos=cc.p(5, theight-5), title="(1)道具说明：", str="鸡蛋：花费5000筹码购买一个鸡蛋扔给对方，对方会减少魅力1\r\n刀具：花费5万筹码购买一把刀具扔给对方，对方会减少魅力10\r\n炸弹：花费50万筹码购买一个炸弹扔给对方，对方会减少魅力100\r\n小花：花费5000筹码购买一多小花扔给对方，对方会增加魅力1\r\n金表：花费5万筹码购买一块金表扔给对方，对方会增加魅力10\r\n汽车：花费50万筹码购买一块金表扔给对方，对方会增加魅力100"}
    strlist[2] = {size=cc.size(bgSize.width - 60, 180), pos=cc.p(5, theight-300), title="(2)禁言说明", str="当玩家魅力值为负数时，不能发文字和语音。"}
    strlist[3] = {size=cc.size(bgSize.width - 60, 180), pos=cc.p(5, theight-420), title="(3)修改昵称说明", str="修改昵称需要支付50万筹码，游客有一次免费修改昵称的机会。"}

    local tem = {}
    tem[1] = "在游戏中vip玩家可以将非vip的玩家踢出房间"
    tem[2] = "官职大的可以将官职小的玩家踢出房间"
    tem[3] = "如果vip等级或官职大小相等，则账户金币多的玩家踢走金币少的玩家（不含保险柜内的金币）。"
    strlist[4] = {size=cc.size(bgSize.width - 60, 30), pos=cc.p(5, theight-550), title="(4)踢人说明：", str=tem}
    
    local strguanzhi = {}
    strguanzhi[1] = "官职大小根据账户的游戏积分的不等来判断"
    strguanzhi[2] = "等级-0,官职-无名,所需积分-0分"
    strguanzhi[3] = "等级-1,官职-村民,所需积分:1积分"
    strguanzhi[4] = "等级-2,官职-办事员,所需积分:2积分"
    strguanzhi[5] = "等级-3,官职-组长,所需积分:10积分"
    strguanzhi[6] = "等级-4,官职-副主任,所需积分:50积分"
    strguanzhi[7] = "等级-5,官职-主任,所需积分:200积分"
    strguanzhi[8] = "等级-6,官职-副村长,所需积分:500积分"
    strguanzhi[9] = "等级-7,官职-村长,所需积分:2000积分"
    strguanzhi[10] = "等级-8,官职-副镇长,所需积分:5000积分"
    strguanzhi[11] = "等级-9,官职-镇长,所需积分:1万积分"
    strguanzhi[12] = "等级-10,官职-副县长,所需积分:2万积分"
    strguanzhi[13] = "等级-11,官职-县长,所需积分:5万积分"
    strguanzhi[14] = "等级-12,官职-副市长,所需积分:10万积分"
    strguanzhi[15] = "等级-13,官职-市长,所需积分:20万积分"
    strguanzhi[16] = "等级-14,官职-副省长,所需积分:50万积分"
    strguanzhi[17] = "等级-15,官职-省长,所需积分:100万积分"
    strguanzhi[18] = "等级-16,官职-副总统,所需积分:200万积分"
    strguanzhi[19] = "等级-17,官职-总统,所需积分:500万积分"
    strguanzhi[20] = "等级-18,官职-超人,所需积分:2000万积分"
    strlist[5] = {size=cc.size(bgSize.width - 60, 30), pos=cc.p(5, theight-750), title="(5)官职说明：", str=strguanzhi}
        
    local custom_item = ccui.Layout:create()
    custom_item:setTouchEnabled(true)
    custom_item:setContentSize(cc.size(bgSize.width - 60, theight))

    for _, v in ipairs(strlist) do

        local title = ccui.Text:create(v.title, FONT_ART_TEXT,26)
        title:setAnchorPoint(cc.p(0,1))
        title:setPosition(v.pos)
        title:setColor(cc.c3b(255,228,0))
        custom_item:addChild(title)
        
        if type(v.str) == "string" then
            local underWriteLabel = ccui.Text:create(v.str, "", 22);
            underWriteLabel:setColor(cc.c3b(255,230,100));
            underWriteLabel:setAnchorPoint(cc.p(0,1))
            underWriteLabel:setTextAreaSize(v.size)
            underWriteLabel:ignoreContentAdaptWithSize(false)
            underWriteLabel:setTextHorizontalAlignment(0)
            underWriteLabel:setTextVerticalAlignment(0)
            underWriteLabel:setPosition(v.pos.x, v.pos.y-30)
            custom_item:addChild(underWriteLabel)

        elseif type(v.str) == "table" then
            for i, stri in ipairs(v.str) do
                local underWriteLabel = ccui.Text:create(stri, "", 22);
                underWriteLabel:setColor(cc.c3b(255,230,100));
                underWriteLabel:setAnchorPoint(cc.p(0,1))
                underWriteLabel:setTextAreaSize(v.size)
                underWriteLabel:ignoreContentAdaptWithSize(false)
                underWriteLabel:setTextHorizontalAlignment(0)
                underWriteLabel:setTextVerticalAlignment(0)
                underWriteLabel:setPosition(v.pos.x, v.pos.y - 30 * i)
                custom_item:addChild(underWriteLabel)

            end
        end
        
    end

    listView:pushBackCustomItem(custom_item)
end

--意见反馈
function HelpLayer:showYiJianFanKui()
    PlatformFeedback()
end

return HelpLayer