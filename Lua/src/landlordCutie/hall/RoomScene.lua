local RoomScene = class("RoomScene", require("ui.CCBaseScene"))
require("gameSetting.LevelSetting")
require("hall.WenXinTiShiLayer")
local EffectFactory = require("commonView.DDZEffectFactory")
RoomScene.queryTime = 0
function RoomScene:ctor()

    print("RoomScene:ctor=======", tostring(self))
    --防止frames释放
    EffectFactory:getInstance():cacheFrames()
    
    -- 根节点变更为self.container
    self.super.ctor(self)
    --背景
    local bgSprite = cc.Sprite:create()
    -- bgSprite:setTexture("hall/room/bg.jpg")
    bgSprite:setTexture("ddz_christmas/bg.jpg")
    bgSprite:align(display.CENTER, display.cx, display.cy)
    self.container:addChild(bgSprite)


    EffectFactory:getInstance():getHallBgArmature()
    local armature = EffectFactory:getInstance():getHallBgArmature(1)
    self.container:addChild(armature)
    armature:setPosition(cc.p(display.cx, display.cy))
    
    local texture2d = cc.Director:getInstance():getTextureCache():addImage("effect/ddz_dating/ddz_dt_guangdian.png");
    local light = cc.ParticleSystemQuad:create("effect/ddz_dating/ddz_dt_guangdian_1.plist");
    light:setTexture(texture2d);
    light:setPosition(cc.p(display.cx, display.cy));
    self.container:addChild(light)

    local texture2d = cc.Director:getInstance():getTextureCache():addImage("effect/ddz_dating/ddz_dt_guangdian.png");
    local light = cc.ParticleSystemQuad:create("effect/ddz_dating/ddz_dt_guangdian_2.plist");
    light:setTexture(texture2d);
    light:setPosition(cc.p(display.cx, display.cy));
    self.container:addChild(light)


    --是否显示房间选择界面
    self.showRoom = false
    --排行榜类型 1财富2魅力
    self.rankType = 1
    --当前游戏类型 斗地主-200   美女视频-?
    self.wCurKind = 0
    self.roomNode = {
        [200]={700,701,702,703},--斗地主
        [201]={710,711,712,713},--二人斗地主
        -- [202]={1700,1701,1702,1703},--二人斗地主
        -- [203]={1800,1801,1802,1803}--单挑场
    }
    --滚动消息数组
    self.scrollMessageArr = {}
    self:createUI()

    --按键处理
    self:setKeypadEnabled(true)
    self:addNodeEventListener(cc.KEYPAD_EVENT, function(event)
        if event.key == "back" then
            self:onClickBack()
        end
    end)

    self:registerGameEvent()

end

-- 构建界面
function RoomScene:createUI()
    self:createTopView()
    self:createBottomPageView()
    if self.showRoom == true then
        self.bottomPageView:setPosition(cc.p(-1136,0))
    end

    if autoSelectGame == true then
        self.moveSnow = display.newSprite("ddz_christmas/banner22.png"):addTo(self.container):align(display.LEFT_BOTTOM, 0, 0)
    else
        self.moveSnow = display.newSprite("ddz_christmas/banner2.png"):addTo(self.container):align(display.LEFT_BOTTOM, 0, 0)
    end
end

-- 大厅上层视图
function RoomScene:createTopView()
    -- topView bg,as container
    self.hallTopView = ccui.ImageView:create()
    self.hallTopView:loadTexture("hall/room/hall_top_bg.png")
    self.hallTopView:setAnchorPoint(cc.p(0.5,1.0))
    self.hallTopView:setPosition(cc.p(display.cx,display.top+8))

    -- self.hallTopView:setAnchorPoint(cc.p(0.5,1.0))
    -- self.hallTopView:setPosition(cc.p(display.cx,display.top + 8))
    self.container:addChild(self.hallTopView)

    -- back button
    local backButton = ccui.ImageView:create()
    backButton:setTouchEnabled(true)
    backButton:loadTexture("common/back.png")
    backButton:setPosition(cc.p(90,75))
    self.hallTopView:addChild(backButton)
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

    -- 用户个人信息
    local selfInfoLayer = ccui.ImageView:create()
    selfInfoLayer:loadTexture("hall/room/hall_selfinfo_bg.png")
    selfInfoLayer:setAnchorPoint(cc.p(0.5,1.0))
    selfInfoLayer:setPosition(cc.p(275,110))
    self.hallTopView:addChild(selfInfoLayer)
    
    --头像
    local headView = require("commonView.GameHeadView").new(1);
    headView:setPosition(cc.p(70,56))
    selfInfoLayer:addChild(headView);
    self.headImage = headView;

    -- local headBg = ccui.ImageView:create()
    -- headBg:loadTexture("head/frame.png")
    -- -- headBg:setScale9Enabled(true)
    -- -- headBg:setContentSize(cc.size(70,70))
    -- -- headBg:setCapInsets(cc.rect(10,10,20,20))
    -- headBg:setPosition(cc.p(70,56))
    -- selfInfoLayer:addChild(headBg)
    -- self.headImage = ccui.ImageView:create()
    -- self.headImage:setTouchEnabled(true)
    -- self.headImage:setScale(0.7)
    -- self.headImage:loadTexture("head/default.png")
    -- self.headImage:setPosition(cc.p(headBg:getContentSize().width/2-5,headBg:getContentSize().height/2+5))
    -- headBg:addChild(self.headImage)

    --等级
    self.levelText = ccui.Text:create("LV.1",FONT_ART_TEXT,22)
    self.levelText:setAnchorPoint(cc.p(0,0.5))
    self.levelText:setPosition(cc.p(130,73))
    self.levelText:setTextColor(cc.c4b(250,236,110,255))
    selfInfoLayer:addChild(self.levelText)
    --昵称
    self.nickNameText = ccui.Text:create("欢乐斗地主",FONT_ART_TEXT,22)
    self.nickNameText:setAnchorPoint(cc.p(0,0.5))
    self.nickNameText:setPosition(cc.p(125,40))
    self.nickNameText:setTextColor(cc.c4b(250,236,110,255))
    selfInfoLayer:addChild(self.nickNameText)

    -- selfInfoLayer:addTouchEventListener(function(sender,eventType)
    --     if eventType == ccui.TouchEventType.began then
    --         -- SoundManager:getInstance():playSoundByType(SoundType.BTN_CLICK)
    --         addButton:setScale(1.1)
    --     elseif eventType == ccui.TouchEventType.ended then
    --         addButton:setScale(1.0)
    --         self:onClickPersonalCenter()
    --     elseif eventType == ccui.TouchEventType.canceled then
    --         addButton:setScale(1.0)
    --     end
    -- end)
    local personalCenter = ccui.Button:create("blank.png");
    personalCenter:setScale9Enabled(true)
    personalCenter:setContentSize(240,100)
    personalCenter:setPosition(cc.p(280,38));
    self.hallTopView:addChild(personalCenter);
    personalCenter:setPressedActionEnabled(true);
    personalCenter:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:onClickPersonalCenter();
                onUmengEvent("1054")
            end
        end
    )

    -- --欢乐豆信息
    -- local treasureInfoLayer = ccui.ImageView:create()
    -- treasureInfoLayer:loadTexture("common/txtBg.png")
    -- treasureInfoLayer:setScale9Enabled(true)
    -- treasureInfoLayer:setContentSize(cc.size(230,51))
    -- treasureInfoLayer:setCapInsets(cc.rect(100,25,1,1))
    -- treasureInfoLayer:setPosition(cc.p(560,72))
    -- self.hallTopView:addChild(treasureInfoLayer)
    -- --gold
    -- local goldImage = EffectFactory:getInstance():getBeanAnimation();
    -- -- local goldImage = ccui.ImageView:create()
    -- -- goldImage:loadTexture("common/huanledou.png")
    -- goldImage:setPosition(cc.p(33,treasureInfoLayer:getContentSize().height/2-2))
    -- treasureInfoLayer:addChild(goldImage)
    -- --gold value
    -- self.goldValueText = ccui.Text:create("",FONT_ART_TEXT,30)
    -- self.goldValueText:setColor(cc.c3b(255, 255, 0))
    -- self.goldValueText:setAnchorPoint(cc.p(0,0.5))
    -- self.goldValueText:setPosition(cc.p(65,treasureInfoLayer:getContentSize().height/2-2))
    -- treasureInfoLayer:addChild(self.goldValueText)
    -- --add button
    -- local addButton = ccui.ImageView:create()
    -- addButton:setTouchEnabled(true)
    -- addButton:loadTexture("common/plus.png")
    -- addButton:setPosition(cc.p(218,treasureInfoLayer:getContentSize().height/2-1))
    -- treasureInfoLayer:addChild(addButton)
    -- addButton:addTouchEventListener(function(sender,eventType)
    --     if eventType == ccui.TouchEventType.began then
    --         -- SoundManager:getInstance():playSoundByType(SoundType.BTN_CLICK)
    --         addButton:setScale(1.1)
    --     elseif eventType == ccui.TouchEventType.ended then
    --         addButton:setScale(1.0)
    --         self:onClickBuy(1)
    --     elseif eventType == ccui.TouchEventType.canceled then
    --         addButton:setScale(1.0)
    --     end
    -- end)
    --金币信息
    local goldInfoLayer = ccui.ImageView:create()
    goldInfoLayer:loadTexture("common/txtBg.png")
    goldInfoLayer:setScale9Enabled(true)
    goldInfoLayer:setContentSize(cc.size(230,51))
    goldInfoLayer:setCapInsets(cc.rect(100,25,1,1))
    goldInfoLayer:setPosition(cc.p(560,72))
    self.hallTopView:addChild(goldInfoLayer)
    --gold
    local goldImage2 = EffectFactory:getInstance():getGoldAnimation();
    -- local goldImage2 = ccui.ImageView:create()
    -- goldImage2:loadTexture("common/gold.png")
    goldImage2:setPosition(cc.p(33,goldInfoLayer:getContentSize().height/2-2))
    goldInfoLayer:addChild(goldImage2)
    --gold value
    self.goldValueText2 = ccui.Text:create("",FONT_ART_TEXT,30)
    self.goldValueText2:setColor(cc.c3b(255, 255, 0))
    self.goldValueText2:setAnchorPoint(cc.p(0,0.5))
    self.goldValueText2:setPosition(cc.p(65,goldInfoLayer:getContentSize().height/2-2))
    goldInfoLayer:addChild(self.goldValueText2)
    --add button
    local addButton2 = ccui.ImageView:create()
    addButton2:setTouchEnabled(true)
    addButton2:loadTexture("hall/room/btn_charge.png")
    addButton2:setPosition(cc.p(218,goldInfoLayer:getContentSize().height/2-1))
    goldInfoLayer:addChild(addButton2)
    addButton2:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.began then
            -- SoundManager:getInstance():playSoundByType(SoundType.BTN_CLICK)
            addButton2:setScale(1.1)
        elseif eventType == ccui.TouchEventType.ended then
            addButton2:setScale(1.0)
            self:onClickBuy(2)
        elseif eventType == ccui.TouchEventType.canceled then
            addButton2:setScale(1.0)
        end
    end)

    --礼券信息
    local couponLayer = ccui.ImageView:create("common/txtBg.png")
    couponLayer:setScale9Enabled(true)
    couponLayer:setContentSize(cc.size(230,51))
    couponLayer:setCapInsets(cc.rect(100,25,1,1))
    couponLayer:setPosition(cc.p(860,72))
    self.hallTopView:addChild(couponLayer)

    local couponIcon = ccui.ImageView:create("liquan/lq_icon0.png")
    couponIcon:setPosition(33,couponLayer:getContentSize().height/2-2)
    couponLayer:addChild(couponIcon)

    local couponTxt = ccui.Text:create("0",FONT_ART_TEXT,30)
    couponTxt:setColor(cc.c3b(255,255,0))
    couponTxt:setAnchorPoint(cc.p(0,0.5))
    couponTxt:setPosition(cc.p(65,couponLayer:getContentSize().height/2-2))
    couponLayer:addChild(couponTxt)
    self.couponTxt = couponTxt
    if OnlineConfig_review == nil or OnlineConfig_review == "on" then
        couponLayer:hide()
    end

--斗地主大厅版／斗地主小版本显示兑换按钮
if (autoSelectGame == true and APP_ID == 1005) or AppChannel == "launcher_ddz" then
    --add button
    local exchangeButton = ccui.ImageView:create()
    exchangeButton:setTouchEnabled(true)
    exchangeButton:loadTexture("hall/room/btn_exchange.png")
    exchangeButton:setPosition(cc.p(218,couponLayer:getContentSize().height/2-1))
    couponLayer:addChild(exchangeButton)
    exchangeButton:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.began then
            -- SoundManager:getInstance():playSoundByType(SoundType.BTN_CLICK)
            exchangeButton:setScale(1.1)
        elseif eventType == ccui.TouchEventType.ended then
            exchangeButton:setScale(1.0)
            self:onClickExchangeCoupon()
        elseif eventType == ccui.TouchEventType.canceled then
            exchangeButton:setScale(1.0)
        end
    end)
end

    --设置
    local settingButton = ccui.ImageView:create()
    settingButton:setTouchEnabled(true)
    settingButton:loadTexture("hall/room/hall_setting.png")
    settingButton:setPosition(cc.p(1035,72))
    self.hallTopView:addChild(settingButton)
    settingButton:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.began then
            -- SoundManager:getInstance():playSoundByType(SoundType.BTN_CLICK)
            settingButton:setScale(1.1)
        elseif eventType == ccui.TouchEventType.ended then
            settingButton:setScale(1.0)
            self:onClickSetting();
        elseif eventType == ccui.TouchEventType.canceled then
            settingButton:setScale(1.0)
        end
    end)

    --滚动消息
    local scrollTextContainer = ccui.Layout:create()
    scrollTextContainer:setContentSize(cc.size(600,30))
    scrollTextContainer:setPosition(cc.p(display.left + 100+513, display.top - 60-107))
    self.container:addChild(scrollTextContainer, 3)
    scrollTextContainer:setVisible(false)
    self.scrollTextContainer = scrollTextContainer
    local scrollBg = ccui.ImageView:create("hall/room/scroll_bg.png")
    scrollBg:setPosition(cc.p(313-120,10))
    scrollTextContainer:addChild(scrollBg)
    local scrollTextPanel = ccui.Layout:create()
    scrollTextPanel:setContentSize(cc.size(626,30))
    scrollTextPanel:setName("scrollTextPanel")
    scrollTextPanel:setPosition(cc.p(0,0))
    scrollTextPanel:setClippingEnabled(true)
    scrollTextContainer:addChild(scrollTextPanel)
    -- local labaImg = ccui.ImageView:create("landlordVideo/scroll_laba.png")
    -- labaImg:setPosition(cc.p(20,15))
    -- scrollTextContainer:addChild(labaImg)

    display.newSprite("ddz_christmas/banner4.png"):addTo(self.hallTopView):align(display.LEFT_TOP, 20, 125)
    display.newSprite("ddz_christmas/banner1.png"):addTo(self.hallTopView,-1):align(display.LEFT_TOP, 10, 38)
end

-- 大厅下层视图
function RoomScene:createBottomPageView()
    self.bottomPageView = ccui.Layout:create()
    self.bottomPageView:setContentSize(cc.size(2272,550))
    self.bottomPageView:setPosition(cc.p(0,0))
    -- self.bottomPageView:setBackGroundColorType(1)
    -- self.bottomPageView:setBackGroundColor(cc.c3b(100,123,100))
    self.container:addChild(self.bottomPageView)
    self:createHallPage()
    self:createRoomPage()
end
function RoomScene:wealthRankHandler()
    -- body
    self.rankType = 1
    self.lovelinessTitle:setHighlighted(false)
    self.bangtitle:setHighlighted(true)
    self:onRequestWealthRankingResult()
end
function RoomScene:lovelinessHandler()
    -- body
    self.rankType = 2
    self.lovelinessTitle:setHighlighted(true)
    self.bangtitle:setHighlighted(false)
    self:onRequestWealthRankingResult()
end
function RoomScene:createHallPage()
    self.hallPage = ccui.Layout:create()
    self.hallPage:setContentSize(cc.size(1136,550))
    self.hallPage:setPosition(cc.p(0,0))
    -- self.hallPage:setBackGroundColorType(1)
    -- self.hallPage:setBackGroundColor(cc.c3b(0,255,0))
    self.bottomPageView:addChild(self.hallPage)

    --财富榜
    local bangLayer = ccui.ImageView:create()
    bangLayer:loadTexture("hall/room/hall_bang_bg.png")
    bangLayer:setScale9Enabled(true)
    bangLayer:setContentSize(cc.size(490,500))
    bangLayer:setCapInsets(cc.rect(200,90,10,10))
    bangLayer:setPosition(cc.p(315,265))
    self.hallPage:addChild(bangLayer)
    self.bangLayer = bangLayer

    display.newSprite("ddz_christmas/banner3.png"):addTo(bangLayer):align(display.RIGHT_TOP, 470, 498)

    ----------- for 正式
    --bang title bg
    local bangtitle = ccui.Button:create()
    bangtitle:loadTextures("hall/room/wealthRank.png","hall/room/wealthRankSelected.png")
    bangtitle:setPosition(cc.p(190,475))
    -- bangtitle:setPressedActionEnabled(true)
    bangtitle:addTouchEventListener(
                function(sender,eventType)
                    if eventType == ccui.TouchEventType.ended then
                        self:wealthRankHandler(sender);                        
                    end
                end
            )
    self.hallPage:addChild(bangtitle,1)
    self.bangtitle = bangtitle
    -- --title
    -- local bangtext = ccui.Text:create("财富榜",FONT_ART_TEXT,24)
    -- bangtext:setPosition(cc.p(68,68))
    -- bangtext:setTextColor(cc.c4b(251,248,142,255))
    -- bangtext:enableOutline(cc.c4b(137,0,167,200), 3)
    -- bangtitle:addChild(bangtext)
    -- --title banner
    -- local banner = ccui.ImageView:create()
    -- banner:loadTexture("hall/room/title_banner.png")
    -- banner:setPosition(cc.p(68,38))
    -- bangtitle:addChild(banner)

    ---魅力榜
    --bang title bg
    local lovelinessTitle = ccui.Button:create()
    lovelinessTitle:loadTextures("hall/room/lovelinessRank.png","hall/room/lovelinessRankSelected.png")
    lovelinessTitle:setPosition(cc.p(190+136,475))
    -- lovelinessTitle:setPressedActionEnabled(true)
    lovelinessTitle:addTouchEventListener(
                function(sender,eventType)
                    if eventType == ccui.TouchEventType.ended then
                        self:lovelinessHandler(sender);
                    end
                end
            )
    self.hallPage:addChild(lovelinessTitle,1)
    self.lovelinessTitle = lovelinessTitle
    --title
    -- local lovelinesstext = ccui.Text:create("魅力榜",FONT_ART_TEXT,24)
    -- lovelinesstext:setPosition(cc.p(68,68))
    -- lovelinesstext:setTextColor(cc.c4b(251,248,142,255))
    -- lovelinesstext:enableOutline(cc.c4b(137,0,167,200), 3)
    -- lovelinessTitle:addChild(lovelinesstext)

    --bang hinttext
    -- local banghinttext = ccui.Text:create("少年，争当首富啦！",FONT_ART_TEXT,28)
    -- banghinttext:setPosition(cc.p(310,470))
    -- banghinttext:setTextColor(cc.c4b(251,248,142,255))
    -- bangLayer:addChild(banghinttext)
    self.lovelinessTitle:setHighlighted(false)
    self.bangtitle:setHighlighted(true)
    -- bang listview
    self.listView = ccui.ListView:create()
    -- set list view ex direction
    self.listView:setDirection(ccui.ScrollViewDir.vertical)
    self.listView:setBounceEnabled(true)
    self.listView:setContentSize(cc.size(390, 310))
    self.listView:setPosition(50,120)
    bangLayer:addChild(self.listView)
    -- ListView点击事件回调
    local function listViewEvent(sender, eventType)
        -- 事件类型为点击结束
        if eventType == ccui.ListViewEventType.ONSELECTEDITEM_END then
            print("select child index = ",sender:getCurSelectedIndex())
            self:showPlayerInfo(sender:getCurSelectedIndex())
        end
        if eventType == ccui.ListViewEventType.ONSELECTEDITEM_START then
            if self.rankType == 1 then
                onUmengEvent("1039")
            elseif self.rankType == 2 then
                onUmengEvent("1040")
            end
        end
    end
    -- 设置ListView的监听事件
    self.listView:addEventListener(listViewEvent)
    ----------- for review
    --review title
    local review_bangtitle = ccui.ImageView:create()
    review_bangtitle:loadTexture("hall/room/gameintro.png")
    review_bangtitle:setPosition(cc.p(215,465))
    bangLayer:addChild(review_bangtitle)
    --review text
    local review_messagetext = ccui.ImageView:create()
    review_messagetext:loadTexture("hall/room/messagetext.png")
    review_messagetext:setPosition(cc.p(245,288))
    bangLayer:addChild(review_messagetext)

    if OnlineConfig_review == "on" then
        bangtitle:setVisible(false)
        self.lovelinessTitle:setVisible(false)
        -- banghinttext:setVisible(false)
        self.listView:setVisible(false)
        review_bangtitle:setVisible(true)
        review_messagetext:setVisible(true)
    else
        bangtitle:setVisible(true)
        self.lovelinessTitle:setVisible(true)
        -- banghinttext:setVisible(true)
        self.listView:setVisible(true)
        review_bangtitle:setVisible(false)
        review_messagetext:setVisible(false)
    end


if autoSelectGame == false and APP_ID == 1005 and OnlineConfig_review == "off" then
    self.bangLayer:loadTexture("hall/room/hall_bang_bg1.png")
    self.listView:setContentSize(cc.size(390, 350))
    self.listView:setPosition(50,80)


    --银行按钮
    local bank = ccui.ImageView:create("hall/room/btn_bank.png")
    bank:setTouchEnabled(true)
    self.hallPage:addChild(bank)
    bank:setPosition(1058, 480)
    bank:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.began then
            bank:setScale(1.1)
        elseif eventType == ccui.TouchEventType.ended then
            bank:setScale(1.0)
            self:onClickBank()
        elseif eventType == ccui.TouchEventType.canceled then
            bank:setScale(1.0)
        end
    end)

    --调整排行榜大小
    -- bangLayer:setContentSize(cc.size(490,540))
    -- bangLayer:setPosition(cc.p(315,225))

    -- self.listView:setContentSize(cc.size(390, 350))
else
    --bang 消息
    local messageButton = ccui.ImageView:create()
    messageButton:setTouchEnabled(true)
    messageButton:loadTexture("hall/room/hall_icon_message.png")
    messageButton:setPosition(cc.p(90,55))
    bangLayer:addChild(messageButton)
    messageButton:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.began then
            -- SoundManager:getInstance():playSoundByType(SoundType.BTN_CLICK)
            messageButton:setScale(1.1)
        elseif eventType == ccui.TouchEventType.ended then
            messageButton:setScale(1.0)
            self:onClickMessage()
        elseif eventType == ccui.TouchEventType.canceled then
            messageButton:setScale(1.0)
        end
    end)
    --add text
    self:addText(messageButton, "消息")


    --bang 银行
    local tuijianButton = ccui.ImageView:create()
    tuijianButton:setTouchEnabled(true)
    tuijianButton:loadTexture("hall/room/hall_icon_bank.png")
    tuijianButton:setPosition(cc.p(182,55))
    bangLayer:addChild(tuijianButton)
    tuijianButton:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.began then
            -- SoundManager:getInstance():playSoundByType(SoundType.BTN_CLICK)
            tuijianButton:setScale(1.1)
        elseif eventType == ccui.TouchEventType.ended then
            tuijianButton:setScale(1.0)
            self:onClickBank()
        elseif eventType == ccui.TouchEventType.canceled then
            tuijianButton:setScale(1.0)
        end
    end)
    --add text
    self:addText(tuijianButton, "银行")

    --bang 活动
    local activityButton = ccui.ImageView:create()
    activityButton:setTouchEnabled(true)
    activityButton:loadTexture("hall/room/hall_icon_activity.png")
    activityButton:setPosition(cc.p(282,55))
    bangLayer:addChild(activityButton)
    activityButton:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.began then
            -- SoundManager:getInstance():playSoundByType(SoundType.BTN_CLICK)
            activityButton:setScale(1.1)
        elseif eventType == ccui.TouchEventType.ended then
            activityButton:setScale(1.0)
            self:onClickActivity()
        elseif eventType == ccui.TouchEventType.canceled then
            activityButton:setScale(1.0)
        end
    end)
    --add text
    self:addText(activityButton, "活动")

    --bang 免费
    local freeButton = ccui.ImageView:create()
    freeButton:setTouchEnabled(true)
    freeButton:loadTexture("hall/room/hall_icon_free.png")
    freeButton:setPosition(cc.p(385,55))
    bangLayer:addChild(freeButton)
    freeButton:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.began then
            -- SoundManager:getInstance():playSoundByType(SoundType.BTN_CLICK)
            freeButton:setScale(1.1)
        elseif eventType == ccui.TouchEventType.ended then
            freeButton:setScale(1.0)
            self:onClickFreeChip()
        elseif eventType == ccui.TouchEventType.canceled then
            freeButton:setScale(1.0)
        end
    end)
    --add text
    self:addText(freeButton, "免费")

    local inReview = false;
    if OnlineConfig_review == nil or OnlineConfig_review == "on" then
        inReview = true;
    end
    if inReview then
        messageButton:setVisible(false);
        tuijianButton:setVisible(false);
        activityButton:setVisible(false);
        freeButton:setVisible(false);
    end
end
    --room 二人斗地主
    local room2LandlordButton = ccui.ImageView:create()
    room2LandlordButton:setTouchEnabled(true)

    --room2LandlordButton:loadTexture("hall/room/game_icon_2landlord.png")
    room2LandlordButton:loadTexture("blank.png")
    room2LandlordButton:setScale9Enabled(true);
    room2LandlordButton:setContentSize(cc.size(177,256));
    local iconUp = ccui.ImageView:create("hall/room/game_icon_2landlord_up.png")
    iconUp:addTo(room2LandlordButton):align(display.CENTER,88, 135)
    local EffectFactory = require("commonView.DDZEffectFactory");
    local iconAnimation = EffectFactory:getInstance():getGameIconAnimation(1);
    iconAnimation:setPosition(cc.p(88,128));
    room2LandlordButton:addChild(iconAnimation);
    --commodityLightAnimation:getAnimation():setSpeedScale(math.random(1,5) / 5);
    --iconAnimation:getAnimation():setSpeedScale(0.3);
    local iconDwon = ccui.ImageView:create("hall/room/game_icon_2landlord_down.png")
    iconDwon:addTo(room2LandlordButton):align(display.CENTER,88, 60)

    -- room2LandlordButton:setPosition(cc.p(580,230))
    room2LandlordButton:setPosition(cc.p(560,150))
    bangLayer:addChild(room2LandlordButton)
    --add pop text
    local popText = ccui.ImageView:create("hall/room/pop_erren.png")
    popText:addTo(room2LandlordButton):align(display.CENTER,140, 255)

    --TODO
    -- room2LandlordButton:setVisible(false)
    room2LandlordButton:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.began then
            -- SoundManager:getInstance():playSoundByType(SoundType.BTN_CLICK)
            room2LandlordButton:setScale(1.1)
        elseif eventType == ccui.TouchEventType.ended then
            room2LandlordButton:setScale(1.0)
            self:onEnterRoomSelectPage(201)
        elseif eventType == ccui.TouchEventType.canceled then
            room2LandlordButton:setScale(1.0)
        end
    end)
    self.roomOnline2Landlord = ccui.Text:create()
    self.roomOnline2Landlord:setString("1230人在线")
    self.roomOnline2Landlord:setFontSize(20)
    self.roomOnline2Landlord:setColor(cc.c3b(255,255,255))
    -- self.roomOnline2Landlord:enableOutline(cc.c3b(0, 0, 0), 1)
    self.roomOnline2Landlord:setPosition(cc.p(88,66))
    room2LandlordButton:addChild(self.roomOnline2Landlord)
    --add
    local text = ccui.Text:create("在线","",20)
    text:addTo(room2LandlordButton):align(display.CENTER, 88, 46)

    --room 抢地主
    local roomLandlordButton = ccui.ImageView:create()
    roomLandlordButton:setTouchEnabled(true)

    --roomLandlordButton:loadTexture("hall/room/game_icon_landlord.png")
    roomLandlordButton:loadTexture("blank.png")
    roomLandlordButton:setScale9Enabled(true);
    roomLandlordButton:setContentSize(cc.size(177,256));
    local iconUp = ccui.ImageView:create("hall/room/game_icon_landlord_up.png")
    iconUp:addTo(roomLandlordButton):align(display.CENTER,88, 135)
    local EffectFactory = require("commonView.DDZEffectFactory");
    local iconAnimation = EffectFactory:getInstance():getGameIconAnimation(2);
    iconAnimation:setPosition(cc.p(88,128));
    roomLandlordButton:addChild(iconAnimation);
    --commodityLightAnimation:getAnimation():setSpeedScale(math.random(1,5) / 5);
    --iconAnimation:getAnimation():setSpeedScale(0.3);
    local iconDwon = ccui.ImageView:create("hall/room/game_icon_landlord_down.png")
    iconDwon:addTo(roomLandlordButton):align(display.CENTER,88, 60)

    roomLandlordButton:setPosition(cc.p(730,150))
    --add pop text
    local popText = ccui.ImageView:create("hall/room/pop_jingdian.png")
    popText:addTo(roomLandlordButton):align(display.CENTER,140, 255)

    -- roomLandlordButton:setPosition(cc.p(870,230))
    bangLayer:addChild(roomLandlordButton)
    roomLandlordButton:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.began then
            -- SoundManager:getInstance():playSoundByType(SoundType.BTN_CLICK)
            roomLandlordButton:setScale(1.1)
        elseif eventType == ccui.TouchEventType.ended then
            roomLandlordButton:setScale(1.0)
            self:onEnterRoomSelectPage(200)
        elseif eventType == ccui.TouchEventType.canceled then
            roomLandlordButton:setScale(1.0)
        end
    end)
    self.roomOnlineLandlord = ccui.Text:create()
    self.roomOnlineLandlord:setString("1230人")
    self.roomOnlineLandlord:setFontSize(20)
    self.roomOnlineLandlord:setColor(cc.c3b(255,255,255))
    self.roomOnlineLandlord:setPosition(cc.p(90,66))
    roomLandlordButton:addChild(self.roomOnlineLandlord)
    --add
    local text = ccui.Text:create("在线","",20)
    text:addTo(roomLandlordButton):align(display.CENTER, 90, 46)

    
    --room 美女互动
    local roomVideoButton = ccui.ImageView:create()
    roomVideoButton:setTouchEnabled(true)
    -- if OnlineConfig_review == "on" then
    --     roomVideoButton:loadTexture("hall/room/game_icon_video.png")
    -- else
    --     roomVideoButton:loadTexture("hall/room/game_icon_video.png")
    -- end
    roomVideoButton:loadTexture("blank.png")
    roomVideoButton:setScale9Enabled(true);
    roomVideoButton:setContentSize(cc.size(177,256));
    local iconUp = ccui.ImageView:create("hall/room/game_icon_video_up.png")
    iconUp:addTo(roomVideoButton):align(display.CENTER,88, 135)
    local EffectFactory = require("commonView.DDZEffectFactory");
    local iconAnimation = EffectFactory:getInstance():getGameIconAnimation(3);
    iconAnimation:setPosition(cc.p(88,128));
    roomVideoButton:addChild(iconAnimation);
    --commodityLightAnimation:getAnimation():setSpeedScale(math.random(1,5) / 5);
    --iconAnimation:getAnimation():setSpeedScale(0.3);
    local iconDwon = ccui.ImageView:create("hall/room/game_icon_video_down.png")
    iconDwon:addTo(roomVideoButton):align(display.CENTER,88, 60)

    roomVideoButton:setPosition(cc.p(925,150))
    --add pop text
    local popText = ccui.ImageView:create("hall/room/pop_bairen.png")
    popText:addTo(roomVideoButton):align(display.CENTER,140, 255)

    bangLayer:addChild(roomVideoButton)
    roomVideoButton:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.began then
            -- SoundManager:getInstance():playSoundByType(SoundType.BTN_CLICK)
            roomVideoButton:setScale(1.1)
        elseif eventType == ccui.TouchEventType.ended then
            roomVideoButton:setScale(1.0)
            Hall.showTips("视频场暂停维护，敬请期待！")
            -- self:onEnterRoomSelectPage(210)
        elseif eventType == ccui.TouchEventType.canceled then
            roomVideoButton:setScale(1.0)
        end
    end)
    self.roomOnlineVideo = ccui.Text:create()
    self.roomOnlineVideo:setString("1230人")
    self.roomOnlineVideo:setFontSize(20)
    self.roomOnlineVideo:setColor(cc.c3b(255,255,255))
    -- self.roomOnlineVideo:enableOutline(cc.c3b(0, 0, 0), 1)
    self.roomOnlineVideo:setPosition(cc.p(82,66))
    roomVideoButton:addChild(self.roomOnlineVideo)
    --add
    local text = ccui.Text:create("在线","",20)
    text:addTo(roomVideoButton):align(display.CENTER, 82, 46)



    if AppChannel == "launcher_ddz" then--小版本斗地主

     ---礼包start
        local xinshoulibao = cc.UserDefault:getInstance():getBoolForKey("xinshoulibao", false)
        -- if xinshoulibao then--新手礼包充值过一次不再显示

        -- else
        --     local chongzhi1 = RunTimeData:getChongZhiStatus(1)
        --     if chongzhi1 == 0 then
                local lb1 = ccui.ImageView:create("hall/room/hall_room_lb1.png")
                lb1:setTouchEnabled(true)
                self.hallPage:addChild(lb1)
                lb1:setPosition(1058, 480)
                lb1:addTouchEventListener(function(sender,eventType)
                    if eventType == ccui.TouchEventType.began then
                        lb1:setScale(1.1)
                    elseif eventType == ccui.TouchEventType.ended then
                        lb1:setScale(1.0)
                        self:popLiBao(1)
                    elseif eventType == ccui.TouchEventType.canceled then
                        lb1:setScale(1.0)
                    end
                end)
                local lb1animation = EffectFactory:getInstance():getXinShouLiBaoAnimation()
                local size = lb1:getContentSize()
                lb1animation:setPosition(size.width/2, size.height/2)
                lb1:addChild(lb1animation)
                self.lb1 = lb1
        --     end
        -- end


        local chongzhi6 = RunTimeData:getChongZhiStatus(6)

        -- if chongzhi6 == 0 then
            local lb2 = ccui.ImageView:create("hall/room/hall_room_lb2.png")
            lb2:setTouchEnabled(true)
            lb2:setPosition(1058, 380)
            self.hallPage:addChild(lb2)
            lb2:addTouchEventListener(function(sender,eventType)
                if eventType == ccui.TouchEventType.began then
                    lb2:setScale(1.1)
                elseif eventType == ccui.TouchEventType.ended then
                    lb2:setScale(1.0)
                    self:popLiBao(2)
                elseif eventType == ccui.TouchEventType.canceled then
                    lb2:setScale(1.0)
                end
            end)
            local lb2animation = EffectFactory:getInstance():getShouChongLiBaoAnimation()
            local size = lb2:getContentSize()
            lb2animation:setPosition(size.width/2, size.height/2)
            lb2:addChild(lb2animation)
            self.lb2 = lb2
        -- end

        if OnlineConfig_review == "on" then
            if self.lb1 then
                self.lb1:hide();
            end
            if self.lb2 then
                self.lb2:hide();
            end
        end

     ---礼包end
    end
 
    --Marry start
    local goMarry = ccui.Button:create("hall/marry/goMarry.png","hall/marry/goMarry.png")
    goMarry:setPosition(640, 460)
    goMarry:hide()
    self.hallPage:addChild(goMarry)
    goMarry:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then

                self:goMarryHandler();

            end
        end
    )
    self.goMarry = goMarry

    local EffectFactory = require("commonView.DDZEffectFactory");
    local marryButtonAnimation = EffectFactory:getInstance():getMarryButtonAnimation();
    marryButtonAnimation:setPosition(cc.p(116,40));
    goMarry:addChild(marryButtonAnimation);

    local married = ccui.Button:create("hall/marry/love.png","hall/marry/love.png")
    married:setPosition(600, 460)
    married:hide()
    self.hallPage:addChild(married)
    married:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then

                self:goMarryHandler();

            end
        end
    )
    self.married = married
 --Marry end
end
function RoomScene:goMarryHandler( )
    local marry = require("hall.marry.MarryLayer").new()

    self.container:addChild(marry, 2)
end

function RoomScene:refreshLiBao()
    print("refreshLiBao")
    local chongzhi1 = RunTimeData:getChongZhiStatus(1)
    if chongzhi1 == 1 then
        if self.lb1 then
            self.lb1:hide()
        end
    else
        if self.lb1 then
            self.lb1:show()
        end
    end

    local chongzhi6 = RunTimeData:getChongZhiStatus(6)
    if chongzhi6 == 1 then
        if self.lb2 then
            self.lb2:hide()
        end
    else
        if self.lb2 then
            self.lb2:show()
        end
    end

    if self.LiBaoLayer and self.LiBaoLayer:getParent() then
        self.LiBaoLayer:close()
        self.LiBaoLayer = nil
    end
    if inReview then

        room2LandlordButton:setPosition(cc.p(630,150));
        roomLandlordButton:setPosition(cc.p(900,150));
        roomVideoButton:setVisible(false);

    end

end
function RoomScene:popLiBao(kind)
    local libao = require("hall.LiBaoLayer").new(kind)
    self.container:addChild(libao)
    self.LiBaoLayer = libao
end

function RoomScene:createRoomPage()
    self.roomPage = ccui.Layout:create()
    self.roomPage:setContentSize(cc.size(1136,550))
    self.roomPage:setPosition(cc.p(1136,0))
    -- self.roomPage:setBackGroundColorType(1)
    -- self.roomPage:setBackGroundColor(cc.c3b(255,0,0))
    self.bottomPageView:addChild(self.roomPage,1,1)

    --房间选择界面
    self.roomSelectLayer = ccui.ImageView:create()
    self.roomSelectLayer:loadTexture("common/window.png")
    self.roomSelectLayer:setScale9Enabled(true)
    self.roomSelectLayer:setContentSize(cc.size(892,503))
    self.roomSelectLayer:setCapInsets(cc.rect(70,70,1,1))
    self.roomSelectLayer:setPosition(cc.p(display.cx,display.cy - 60))
    self.roomPage:addChild(self.roomSelectLayer)

    self.roomSelectLayerBox = ccui.Layout:create()
    self.roomSelectLayerBox:setContentSize(cc.size(892,503))
    self.roomSelectLayerBox:setName("box")
    self.roomSelectLayer:addChild(self.roomSelectLayerBox)

    self.roomSelectLayerBox203 = ccui.Layout:create()
    self.roomSelectLayerBox203:setContentSize(cc.size(892,503))
    self.roomSelectLayerBox203:setName("box203")
    self.roomSelectLayer:addChild(self.roomSelectLayerBox203)

--  listview
    self.listViewRoomPage = ccui.ListView:create()
    -- set list view ex direction
    self.listViewRoomPage:setDirection(ccui.ScrollViewDir.horizontal)
    self.listViewRoomPage:setBounceEnabled(true)
    self.listViewRoomPage:setContentSize(cc.size(700,360))
    self.listViewRoomPage:setAnchorPoint(cc.p(0.5,0.5))
    self.listViewRoomPage:setPosition(443,264)
    self.roomSelectLayerBox203:addChild(self.listViewRoomPage)
    --快速开始
    local button = ccui.Button:create("hall/room/fast_start.png");
    button:align(display.CENTER, 546-100, 40)
    button:addTo(self.roomSelectLayer)
    button:setPressedActionEnabled(true);
    button:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:onClickFastStart();
            end
        end
    )
    --房间选择
    -- local room_select = ccui.Button:create("hall/room/room_select.png");
    -- room_select:align(display.CENTER, 346, 40)
    -- room_select:addTo(self.roomSelectLayer)
    -- room_select:setPressedActionEnabled(true);
    -- room_select:addTouchEventListener(
    --     function(sender,eventType)
    --         if eventType == ccui.TouchEventType.ended then
    --             self:onClickRoomSelect();
    --         end
    --     end
    -- )
    self.commonOrnament = {}
    --poker装饰
    local banner = ccui.ImageView:create("hall/room/roompage_banner.png")
    banner:addTo(self.roomSelectLayer):align(display.CENTER, 40, 120)
    self.commonOrnament[1] = banner

    local banner1 = ccui.ImageView:create("hall/room/roompage_banner.png")
    banner1:scale(0.8)
    banner1:setRotation(35)
    banner1:addTo(self.roomSelectLayer):align(display.CENTER, 60, 120)
    self.commonOrnament[2] = banner1

    local banner2 = ccui.ImageView:create("hall/room/roompage_banner.png")
    banner2:setRotation(80)
    banner2:addTo(self.roomPage,-1):align(display.CENTER, 910, 490)
    self.commonOrnament[3] = banner2

    local banner3 = ccui.ImageView:create("hall/room/roompage_banner.png")
    banner3:scale(0.8)
    banner3:setRotation(90)
    banner3:addTo(self.roomPage,-1):align(display.CENTER, 1000, 200)
    self.commonOrnament[4] = banner3

    self.excitingOrnament = {}
    --单挑场装饰
    local banner4 = ccui.ImageView:create("hall/room/roompage_zhuangshi1.png")
    banner4:setRotation(180)
    banner4:addTo(self.roomSelectLayer):align(display.CENTER, 30, 120)
    self.excitingOrnament[1] = banner4

    local banner5 = ccui.ImageView:create("hall/room/roompage_zhuangshi2.png")
    banner5:addTo(self.roomSelectLayer):align(display.CENTER, 860, 230)
    self.excitingOrnament[2] = banner5

    local banner6 = ccui.ImageView:create("hall/room/roompage_zhuangshi3.png")
    banner6:addTo(self.roomSelectLayer):align(display.CENTER, 830, 90)
    self.excitingOrnament[3] = banner6

    local banner7 = ccui.ImageView:create("hall/room/roompage_zhuangshi1.png")
    banner7:setRotation(0)
    banner7:addTo(self.roomPage,-1):align(display.CENTER, 510, 520)
    self.excitingOrnament[4] = banner7

    local banner8 = ccui.ImageView:create("hall/room/roompage_zhuangshi1.png")
    banner8:scale(0.8)
    banner8:setRotation(0)
    banner8:addTo(self.roomPage,-1):align(display.CENTER, 1010, 200)
    self.excitingOrnament[5] = banner8

    --房间选择界面标题
    self.roomPageIcon = {}
    --抢地主
    self.roomPageIcon[200] = ccui.ImageView:create("hall/room/game_icon_landlord.png")
    self.roomPageIcon[200]:setPosition(cc.p(15,370))
    self.roomPageIcon[200]:addTo(self.roomSelectLayer)
    --add pop text
    local popText = ccui.ImageView:create("hall/room/pop_jingdian.png")
    popText:addTo(self.roomPageIcon[200]):align(display.CENTER,140, 255)
    -- roomLandlordButton:setPosition(cc.p(870,230))
    self.onlineLandlord = ccui.Text:create()
    self.onlineLandlord:setString("1230人")
    self.onlineLandlord:setFontSize(20)
    self.onlineLandlord:setColor(cc.c3b(255,255,255))
    self.onlineLandlord:setPosition(cc.p(90,66))
    self.roomPageIcon[200]:addChild(self.onlineLandlord)
    --add
    local text = ccui.Text:create("在线","",20)
    text:addTo(self.roomPageIcon[200]):align(display.CENTER, 90, 46)

    --二人场
    self.roomPageIcon[201] = ccui.ImageView:create("hall/room/game_icon_2landlord.png")
    self.roomPageIcon[201]:setPosition(cc.p(15,370))
    self.roomPageIcon[201]:addTo(self.roomSelectLayer)
    --add pop text
    local popText = ccui.ImageView:create("hall/room/pop_erren.png")
    popText:addTo(self.roomPageIcon[201]):align(display.CENTER,140, 255)
    -- --普通玩法-二人世界
    -- local tabNormal = ccui.Button:create("hall/room/tabNormal.png","hall/room/tabNormalSelected.png");
    -- tabNormal:setPosition(cc.p(605+1136,475))
    -- tabNormal:setPressedActionEnabled(true)
    -- tabNormal:addTouchEventListener(
    --             function(sender,eventType)
    --                 if eventType == ccui.TouchEventType.ended then
    --                     self:refreshRoomSelectPage(202)
    --                     -- tabNormal:loadTextures("hall/room/tabNormalSelected.png","hall/room/tabNormal.png")
    --                     tabNormal:setHighlighted(true)
    --                     self.wCurKind = 202
    --                     RunTimeData:setCurGameID(202)
    --                 end
    --             end
    --         )
    -- self.bottomPageView:addChild(tabNormal,2)
    -- self.tabNormal = tabNormal
 

    --房间
    local roomPos = {
        [1]={265,350},
        [2]={630,350},
        [3]={265,160},
        [4]={630,160}
    }
    local roomLimit = {
        [1]="2万",
        [2]="10万",
        [3]="50万",
        [4]="100万",
    }
    for i=1,4 do
        local roomBg = ccui.ImageView:create()
        roomBg:setTag(i)
        roomBg:setTouchEnabled(true)
        roomBg:loadTexture("hall/room/hall_room_bg.png")
        roomBg:setScale9Enabled(true)
        roomBg:setContentSize(cc.size(315,160))
        roomBg:setCapInsets(cc.rect(50,40,1,1))
        roomBg:setPosition(cc.p(roomPos[i][1],roomPos[i][2]))
        self.roomSelectLayerBox:addChild(roomBg)



        --框 
        if i>1 then
            local titlekuang = ccui.ImageView:create()
            titlekuang:loadTexture("hall/room/title_roomkuang_"..i..".png")
            titlekuang:setPosition(cc.p(315/2-2,160/2+2))
            roomBg:addChild(titlekuang)
            --礼券
            if OnlineConfig_review == nil or OnlineConfig_review == "on" then
                --todo
            else
                local liquan = ccui.ImageView:create("common/liquan.png")
                liquan:setName("liquan")
                liquan:setPosition(280, 132)
                roomBg:addChild(liquan)
            end

        end
        --xx场
        local titleRoom = ccui.ImageView:create()
        titleRoom:loadTexture("hall/room/title_room_"..(i)..".png")
        titleRoom:setPosition(cc.p(80,130))
        roomBg:addChild(titleRoom)
        --绿点
        local greenPoint= ccui.ImageView:create("hall/room/greenPoint.png")
        greenPoint:setPosition(150, 135)
        roomBg:addChild(greenPoint)

        --在线人数
        local onLineCount = ccui.Text:create("123", "", 24)
        onLineCount:setName("onLineCount")
        onLineCount:setColor(cc.c3b(126,65,25))
        onLineCount:setAnchorPoint(cc.p(0,0.5))
        onLineCount:setPosition(cc.p(160,135))
        roomBg:addChild(onLineCount)

        --金币限制
        local minEnterRoom = ccui.Text:create(limitText, FONT_ART_TEXT, 28)
        minEnterRoom:setName("minEnterRoom")
        minEnterRoom:setTextColor(cc.c4b(126,65,25,255))
        minEnterRoom:setAnchorPoint(cc.p(0.5,0.5))
        minEnterRoom:setPosition(cc.p(90,60))

        roomBg:addChild(minEnterRoom)

        --gold
        local goldTypeImage = ccui.ImageView:create()
        goldTypeImage:loadTexture("common/huanledou.png")
        goldTypeImage:setName("goldTypeImage")
        goldTypeImage:setPosition(cc.p(180,60))
        roomBg:addChild(goldTypeImage)

        --准入
        local roomLabel = ccui.Text:create("准入", FONT_ART_TEXT, 28)
        roomLabel:setPosition(cc.p(210,60))
        roomLabel:setTextColor(cc.c4b(126,65,25,255))
        roomLabel:setAnchorPoint(cc.p(0,0.5))
        roomBg:addChild(roomLabel)
        roomBg:addTouchEventListener(function(sender,eventType)
            if eventType == ccui.TouchEventType.began then
                -- SoundManager:getInstance():playSoundByType(SoundType.BTN_CLICK)
                roomBg:setScale(1.05)
            elseif eventType == ccui.TouchEventType.ended then
                roomBg:setScale(1.0)
                self:onEnterRoom(roomBg:getTag());
            elseif eventType == ccui.TouchEventType.canceled then
                roomBg:setScale(1.0)
            end
        end)

        --牌型花色
        -- local pokerkind1 = ccui.ImageView:create()
        -- pokerkind1:loadTexture("hall/room/pokerkind"..i..".png")
        -- pokerkind1:setName("pokerkind1")
        -- pokerkind1:setPosition(cc.p(20,20))
        -- roomBg:addChild(pokerkind1)

        -- local pokerkind2 = ccui.ImageView:create()
        -- pokerkind2:loadTexture("hall/room/pokerkind"..i..".png")
        -- pokerkind2:setName("pokerkind2")
        -- pokerkind2:setPosition(cc.p(289,20))
        -- roomBg:addChild(pokerkind2)

        -- local pokerkind3 = ccui.ImageView:create()
        -- pokerkind3:loadTexture("hall/room/pokerkind"..i..".png")
        -- pokerkind3:setName("pokerkind3")
        -- pokerkind3:setPosition(cc.p(289,140))
        -- roomBg:addChild(pokerkind3)
    end
    --203单挑
    for i=1,4 do
        local roomBg = ccui.ImageView:create()
        roomBg:setTag(i)
        roomBg:setTouchEnabled(true)
        roomBg:loadTexture("hall/dantiao/dantiaoItemBg.png")
        roomBg:setScale9Enabled(true)
        roomBg:setContentSize(cc.size(218,302))
        roomBg:ignoreAnchorPointForPosition(true)
        roomBg:setName("ListItem")
        -- roomBg:setCapInsets(cc.rect(50,40,1,1))
        -- roomBg:setPosition(cc.p(roomPos[i][1],roomPos[i][2]))
        

        --xx场
        local titleRoom = ccui.ImageView:create()
        titleRoom:loadTexture("hall/room/title_room_"..(i+1)..".png")
        titleRoom:setPosition(cc.p(75,265))
        roomBg:addChild(titleRoom)

        --icon
        local roomIconImage = ccui.ImageView:create()
        roomIconImage:loadTexture("hall/dantiao/roomIcon"..i..".png")
        roomIconImage:setName("roomIcon")
        roomIconImage:setPosition(cc.p(106,164))
        roomBg:addChild(roomIconImage)

        --在线人数
        local onLineCount = ccui.Text:create("100人", "", 24)
        onLineCount:setName("onLineCount")
        onLineCount:setColor(cc.c3b(126,65,25))
        -- onLineCount:setAnchorPoint(cc.p(0,0.5))
        onLineCount:setPosition(cc.p(104,39))
        roomBg:addChild(onLineCount)

        --金币限制
        local minEnterRoom = ccui.Text:create("10万", FONT_ART_TEXT, 28)
        minEnterRoom:setName("minEnterRoom")
        minEnterRoom:setTextColor(cc.c4b(126,65,25,255))
        minEnterRoom:setAnchorPoint(cc.p(1,0.5))
        minEnterRoom:setPosition(cc.p(75,77))

        roomBg:addChild(minEnterRoom)

        --gold
        local goldTypeImage = ccui.ImageView:create()
        goldTypeImage:loadTexture("common/gold.png")
        goldTypeImage:setName("goldTypeImage")
        goldTypeImage:setPosition(cc.p(106,75))
        roomBg:addChild(goldTypeImage)

        --准入
        local roomLabel = ccui.Text:create("准入", FONT_ART_TEXT, 28)
        roomLabel:setPosition(cc.p(156,73))
        roomLabel:setTextColor(cc.c4b(126,65,25,255))
        roomLabel:setAnchorPoint(cc.p(0.5,0.5))
        roomBg:addChild(roomLabel)
        roomBg:addTouchEventListener(function(sender,eventType)
            if eventType == ccui.TouchEventType.began then
                -- SoundManager:getInstance():playSoundByType(SoundType.BTN_CLICK)
                roomBg:setScale(1.05)
            elseif eventType == ccui.TouchEventType.ended then
                roomBg:setScale(1.0)
                self:onEnterRoom(roomBg:getTag());
            elseif eventType == ccui.TouchEventType.canceled then
                roomBg:setScale(1.0)
            end
        end)

        --牌型花色
        local pokerkind1 = ccui.ImageView:create()
        pokerkind1:loadTexture("hall/room/pokerkind"..i..".png")
        pokerkind1:setName("pokerkind1")
        pokerkind1:setPosition(cc.p(189,276))
        roomBg:addChild(pokerkind1)

        local pokerkind2 = ccui.ImageView:create()
        pokerkind2:loadTexture("hall/room/pokerkind"..i..".png")
        pokerkind2:setName("pokerkind2")
        pokerkind2:setPosition(cc.p(23,26))
        roomBg:addChild(pokerkind2)

        local pokerkind3 = ccui.ImageView:create()
        pokerkind3:loadTexture("hall/room/pokerkind"..i..".png")
        pokerkind3:setName("pokerkind3")
        pokerkind3:setPosition(cc.p(187,25))
        roomBg:addChild(pokerkind3)

        local custom_item = ccui.Layout:create()
        custom_item:setTouchEnabled(true)
        custom_item:setContentSize(roomBg:getContentSize())
        custom_item:addChild(roomBg)
        custom_item:setTag(i)

        self.listViewRoomPage:pushBackCustomItem(custom_item)
    end
end

-- click event
--@param kindID  201 202
function RoomScene:onEnterRoomSelectPage(kindID)
    print("onEnterRoomSelectPage:",kindID)
    self.wCurKind = kindID
    RunTimeData:setCurGameID(kindID)
    if kindID == 210 then --视频场直接进游戏界面
        print("connect to video room!!!")
        -- self:onEnterRoom(1)
        if self.vipRoomLayer == nil then
            self.vipRoomLayer = require("hall.VipRoomLayer").new()
            self.container:addChild(self.vipRoomLayer);
        end
        self.vipRoomLayer:showVipRoomLayer()
        return
    end
    if(not self.showRoom) and self:refreshRoomSelectPage(kindID) then
        local act1 = cc.EaseOut:create(cc.MoveBy:create(0.6, cc.p(-display.width, 0)), 0.2)
        self.bottomPageView:runAction(cc.Repeat:create(act1, 1))
        self.showRoom = true
        self:showSnow(false)
    end



    Click();
end
--@param index  1无限场2初级场3中级场4高级场
function RoomScene:onEnterRoom(index)
    print("onEnterRoom:",index)
    RunTimeData:setRoomIndex(index)

    -- if index == 1 then
    if index == 1 or index == 2 then
        self:autoSelectGame(index)

    else

        local wCurKind = RunTimeData:getCurGameID()
        local nodeItem = ServerInfo:getNodeItemByIndex(wCurKind,index)
        dump(nodeItem, "nodeItem")
        if nodeItem then
            local roomCount = #nodeItem.serverList

            if roomCount>1 then
                local room_select = require("hall.RoomSelectLayer").new(index);
                self.container:addChild(room_select)
            else
                if self:checkTips(index) then
                    self:connectToRoom(self.wCurKind,index,1)
                end
            end
        else
            print("没有房间！")
        end
    end

    Click();
end

function RoomScene:autoSelectGame(index)
    local wCurKind = RunTimeData:getCurGameID()
    local nodeItem = ServerInfo:getNodeItemByIndex(wCurKind,index)


    local roomCount = #nodeItem.serverList
    local minServer = nil
    local roomIndex = 1
    for i=1,roomCount do
        local gameServer = nodeItem.serverList[i]
        if minServer == nil then
            minServer = gameServer
            roomIndex = i
        end

        local max = gameServer.fullCount
        local online = gameServer.onlineCount

        local max1 = minServer.fullCount
        local online1 = minServer.onlineCount

        local rat = online/max
        local rat1 = online1/max1

        if rat < 0.7 then
            minServer = gameServer
            roomIndex = i
            break

        elseif rat > rat1 then
            minServer = gameServer
            roomIndex = i
        end
    end

    self:connectToRoom(self.wCurKind, index, roomIndex)

end

--检测是否弹提示
function RoomScene:checkTips(index)

    -- if 1 then
    --     return true
    -- end
    local wCurKind = RunTimeData:getCurGameID()
    local nodeItem = ServerInfo:getNodeItemByIndex(wCurKind, index)
    local userInfo = DataManager:getMyUserInfo()
    local roomIndex = 0
    local popTips = true

    local gameServer = nodeItem.serverList[1]
    if gameServer then
        local min = gameServer.minEnterScore
        local max = gameServer.maxEnterScore
                    
        if bit.band(gameServer.serverType,Define.GAME_GENRE_EDUCATE) == Define.GAME_GENRE_EDUCATE then
            if (userInfo.score+userInfo.insure>=2000) then
                Hall.showTips("你的金币超过2000，请前往金币场！", 1)
                return false
            end
        else
            if (userInfo.score <= max or max == 0) then
                popTips = false
                return true
            end
        end
    else
        return true
    end


    local myInfo = DataManager:getMyUserInfo()
    local kind = 0
    local tipStr = ""
    if index == 2 and popTips then
        kind = 1
        tipStr = "客官，看你骨骼惊奇，是块斗地主的好料，初级场不适合你，还是去中场去看看吧。"
        --检测下一个场是否超出准入限制
        local isnext = true
        local nodeItem = ServerInfo:getNodeItemByIndex(wCurKind, index+1)
        local gameServer =  nil 
        if nodeItem then
            gameServer = nodeItem.serverList[1]
        end
        if gameServer then
            local min = gameServer.minEnterScore
            local max = gameServer.maxEnterScore
                        
            if bit.band(gameServer.serverType,Define.GAME_GENRE_EDUCATE) == Define.GAME_GENRE_EDUCATE then

                if (userInfo.beans <= max or max == 0) then
                    isnext = false
                    
                end

            else
                if (userInfo.score <= max or max == 0) then
                    isnext = false
                    
                end
            end
        end

        if isnext then
            kind = 2
            tipStr = "客官，我果然没看错你，高手场才是您真正应该战斗的地方"
            index = index+1
        end
    end
    if index == 3 and popTips then
        kind = 2
        tipStr = "客官，我果然没看错你，高手场才是您真正应该战斗的地方"
    end

    if kind >0 then
        local tips = require("hall.WenXinTiShiLayer").new(SystemNoticeType.ClientNoticeType_goNextRoom,tipStr,index)

        self.container:addChild(tips)
        return false
    end

    return true
end

-- 连接房间
function RoomScene:connectToRoom(kindID,section,roomIndex)
    local gameServer = ServerInfo:getServerItemByNodeIndex(kindID, section, roomIndex)
    
    if gameServer == nil then
        print("没有房间!!")
        return
    end
    -- local info = PlayerInfo
    -- if (info ~= nil) then
    --     info:clearAllUserInfo()
    -- end
    RunTimeData:setCurGameServer(gameServer)
    RunTimeData:setRoomIndex(section)
    print("gameServer.serverAddr,gameServer.serverPort==",gameServer.serverAddr,gameServer.serverPort)
    GameConnection:connectServer(gameServer.serverAddr,gameServer.serverPort)
    Hall.showWaiting(3)
    self.roomInfo = {kindID,section,roomIndex}

    --保存登陆信息
    cc.UserDefault:getInstance():setIntegerForKey("lastGameID", kindID);
    cc.UserDefault:getInstance():setIntegerForKey("lastGameSection", section);
    cc.UserDefault:getInstance():setIntegerForKey("lastRoomIndex", roomIndex);
    cc.UserDefault:getInstance():setIntegerForKey("lastGameTime", os.time());

end

function RoomScene:onClickFastStart()
    local userInfo = DataManager:getMyUserInfo()
    
    for i=4,1,-1 do
        local nodeItem = ServerInfo:getNodeItemByIndex(self.wCurKind,i)

        local gameServer = nodeItem.serverList[1]
        if gameServer then
            local min = gameServer.minEnterScore
            local max = gameServer.maxEnterScore
            if bit.band(gameServer.serverType,Define.GAME_GENRE_EDUCATE) == Define.GAME_GENRE_EDUCATE then
                print(userInfo.score, min, max)
                if userInfo.score >= min and (userInfo.score <= max or max == 0) then
                    self:autoSelectGame(i)
                    -- self:connectToRoom(self.wCurKind,i,1)
                    return       
                end

            else
                if userInfo.score >= min and (userInfo.score <= max or max == 0) then
                    self:autoSelectGame(i)
                    -- self:connectToRoom(self.wCurKind,i,1)
                    return
                end
            end
        end
    end
    --[[
    local nodeItem = ServerInfo:getNodeItemByIndex(self.wCurKind,1)
    local gameServer = nodeItem.serverList[1]
    local min = gameServer.minEnterScore
    if bit.band(gameServer.serverType,Define.GAME_GENRE_EDUCATE) == Define.GAME_GENRE_EDUCATE then

        if userInfo.score > min then
            self:connectToRoom(self.wCurKind,1,1)
        else
            Hall.showTips("您的欢乐豆不足，请先去商城兑换！")
        end

    else
        if userInfo.score > min then
            self:connectToRoom(self.wCurKind,1,1)
        else
            Hall.showTips("您的金币不足，请先去商城充值！")
        end
    end
]]
    Click();
end
function RoomScene:onClickRoomSelect()
    print("onClickRoomSelect")
    local room_select = require("hall.RoomSelectLayer").new();
    self.container:addChild(room_select)
    Click();
end
function RoomScene:onClickBank()
    --TODO buy something
    print("onClickBank")
    local bank = require("hall.BankLayer").new();
    self.container:addChild(bank);

    Click();
end

function RoomScene:onClickMessage()
    --TODO buy something
    print("onClickMessage")
    -- Hall.showTips("此功能暂未开放!", 1.0)
    local noticelayer = require("hall.NoticeLayer").new(1)
    self.container:addChild(noticelayer)
    Click();
end

function RoomScene:onClickActivity()
    --print("onClickActivity")
    --Hall.showTips("此功能暂未开放!!!!", 1.0)
    FreeChip("http://112.124.38.85:8083/hall/present.php")
    Click();
end

function RoomScene:onClickFreeChip()
    --print("onClickFreeChip")
    -- Hall.showTips("此功能暂未开放!", 1.0)
    FreeChip("http://112.124.38.85:8083/hall/freeChip.php")
    Click();
end

function RoomScene:onClickBack()
    if(self.showRoom) then
        -- 主UI动画偏移一个屏幕的宽度
        local act1 = cc.EaseOut:create(cc.MoveBy:create(0.6, cc.p(1136, 0)), 0.2)
        self.bottomPageView:runAction(cc.Repeat:create(act1, 1))
        self.showRoom = false

        self:showSnow(true)
    else
        self:removeGameEvent()
        -- package.loaded["hall.RoomScene"] = nil
        Hall:exitGame()

    end

    Click();
end

function RoomScene:onClickPersonalCenter()

    local personalCenter = require("hall.PersonalCenterLayer").new();
    self.container:addChild(personalCenter);

    Click();
end


function RoomScene:onClickBuy(kind)
    if true then
        if device.platform == "ios" or device.platform == "mac" then
            local shopLayer = require("show_ddz.AppStoreLayer").new();
            self.container:addChild(shopLayer);
        else
            local chargeLayer = require("show_ddz.ChargeLayer").new()
            self.container:addChild(chargeLayer)
        end

        return
    end


    local buy = require("hall.ShopLayer").new(kind)
    -- buy:addEventListener(HallCenterEvent.EVENT_SHOW_RESTORELAYER, handler(self, self.showAppRestorePurchaseLayer))

    self.container:addChild(buy)

    -- Hall.showTips("请退到大厅充值！", 0.8)
    
    Click();
end

function RoomScene:showAppRestorePurchaseLayer()
    local appRestorePurchaseLayer = require("hall.AppRestorePurchaseLayer").new()
    self.container:addChild(appRestorePurchaseLayer)
end

function RoomScene:onClickSetting()
    print("onClickSetting")
    local setting = require("hall.SettingLayer").new()
    self.container:addChild(setting)
    Click();
end

-- 业务逻辑
-- 数据请求
function RoomScene:requestWealthRanking()
    -- 发送获取排行榜数据请求
    QueryService:queryWealthRanking()
end
function RoomScene:requestLovelinessRanking()
    -- 查询魅力排名
    QueryService:queryLovelinessRanking()
end
--数据更新
function RoomScene:setSelfInfo()
    -- 顶部设置自己的属性
    local nickName = FormotGameNickName(AccountInfo.nickName,5)
    self.nickNameText:setString(nickName)
    -- self.goldValueText:setString(FormatNumToString(myInfo.beans))
    self.goldValueText2:setString(FormatNumToString(AccountInfo.score))
    self.couponTxt:setString(FormatNumToString(AccountInfo.present))
    self.headImage:setNewHead(AccountInfo.faceId,AccountInfo.cy_userId, AccountInfo.headFileMD5)
    self.headImage:setVipHead(AccountInfo.memberOrder)

    local levelStr = "LV."..getLevelByExp(AccountInfo.medal)
    self.levelText:setString(levelStr)

end

function RoomScene:refreshGameOnlineCount()
    --斗地主在线
    local onlineCount1 = ServerInfo:getOnlineCountByGameKind(200)
    self.roomOnlineLandlord:setString(onlineCount1.."人")
    self.onlineLandlord:setString(onlineCount1.."人")
    --2人斗地主在线
    local onlineCount2 = ServerInfo:getOnlineCountByGameKind(201)
    self.roomOnline2Landlord:setString(onlineCount2.."人")
    --视频场在线
    local onlineCount3 = ServerInfo:getOnlineCountByGameKind(202)
    self.roomOnlineVideo:setString(onlineCount3.."人")
end

function RoomScene:refreshRoomSelectPage(kindID)
    local nodeList = ServerInfo:getNodeListByKind(kindID)
    dump(nodeList, "nodeList---refreshRoomSelectPage")
    if #nodeList ==0 then
        Hall.showTips("房间未开放！", 1.0)
        return false
    end

    if kindID == 200 then
        self.roomPageIcon[200]:show()
        self.roomPageIcon[201]:hide()
    elseif kindID == 201 then
        self.roomPageIcon[201]:show()
        self.roomPageIcon[200]:hide()
    end
    -- if kindID == 203 or kindID == 202 then
    --     self.tabNormal:show()
    -- else
    --     self.tabNormal:hide()
    -- end
    local inReview = false;
    if OnlineConfig_review == nil or OnlineConfig_review == "on" then
        inReview = true;
    end
    -- if inReview then
    --     -- self.tabNormal:hide()
    -- else

--    end
    if kindID == 203 then--单挑场
        -- self.tabNormal:setHighlighted(false)
        for k,v in pairs(self.commonOrnament) do
            v:hide()
        end
        for k,v in pairs(self.excitingOrnament) do
            v:show()
        end
        
    else
        -- self.tabNormal:setHighlighted(true)
        for k,v in pairs(self.commonOrnament) do
            v:show()
        end
        for k,v in pairs(self.excitingOrnament) do
            v:hide()
        end
    end
    if kindID == 203 then
        self.roomSelectLayerBox:hide()
        self.roomSelectLayerBox203:show()
        for i=1,4 do


            local item = self.listViewRoomPage:getItem( i - 1 )
            local itemLayer = item:getChildByName("ListItem")

            local roomBg = itemLayer
            roomBg:loadTexture("hall/dantiao/dantiaoItemBg.png")
            --更新准入
            local minEnterRoom = roomBg:getChildByName("minEnterRoom")
            local goldTypeImage = roomBg:getChildByName("goldTypeImage")
            local liquan = roomBg:getChildByName("liquan")
            local nodeItem = nodeList[i]
            local gameServer = nil
            if nodeItem then
                gameServer = nodeItem.serverList[1]
            end
            if gameServer == nil then
                minEnterRoom:setString(0)
                goldTypeImage:loadTexture("common/gold.png")
                local roomCountLabel = roomBg:getChildByName("onLineCount")
                roomCountLabel:setString("0人")

            else
                local min = gameServer.minEnterScore
                local max = gameServer.maxEnterScore
                if max == 0 then
                    minEnterRoom:setString(FormatDigitToString(min,0))
                else
                    minEnterRoom:setString(FormatDigitToString(min,0) .. "-" .. FormatDigitToString(max,0))
                end
                
                -- minEnterRoom:setString(FormatDigitToString(90000000,0))
                if bit.band(gameServer.serverType,Define.GAME_GENRE_EDUCATE) == Define.GAME_GENRE_EDUCATE then
                    goldTypeImage:loadTexture("common/huanledou.png")
                    if liquan then
                        liquan:hide()
                    end                    
                else
                    goldTypeImage:loadTexture("common/gold.png")
                    if liquan then
                        liquan:show()
                    end                    
                end

                --更新在线
                local roomCountLabel = roomBg:getChildByName("onLineCount")
                local totalOnlineCount = nodeItem.onLineCount or 0
                roomCountLabel:setString(totalOnlineCount.."人")
            end
        end
    else
        print("=============选择房间==================")
        self.roomSelectLayerBox203:hide()
        self.roomSelectLayerBox:show()
        local rsl = self.roomSelectLayer:getChildByName("box")
        for i=1,4 do
            local roomBg = rsl:getChildByTag(i)
            roomBg:loadTexture("hall/room/hall_room_bg.png")

            --更新准入
            local minEnterRoom = roomBg:getChildByName("minEnterRoom")
            local goldTypeImage = roomBg:getChildByName("goldTypeImage")
            local nodeItem = nodeList[i]
            local gameServer = nil
            if nodeItem then
                gameServer = nodeItem.serverList[1]
            end
            dump(gameServer, "gameServer")

            if gameServer == nil then
                minEnterRoom:setString(0)
                goldTypeImage:loadTexture("common/gold.png")
                local roomCountLabel = roomBg:getChildByName("onLineCount")
                roomCountLabel:setString("0人")

            else
                local min = gameServer.minEnterScore
                local max = gameServer.maxEnterScore
                print("==========min,max == ", min, max)
                if max == 0 then
                    minEnterRoom:setString(FormatDigitToString(min,0))
                else
                    minEnterRoom:setString(FormatDigitToString(min,0) .. "-" .. FormatDigitToString(max,0))
                end
                
                -- minEnterRoom:setString(FormatDigitToString(90000000,0))
                if bit.band(gameServer.serverType,Define.GAME_GENRE_EDUCATE) == Define.GAME_GENRE_EDUCATE then
                    goldTypeImage:loadTexture("common/huanledou.png")
                    minEnterRoom:setString("免费")
                else
                    goldTypeImage:loadTexture("common/gold.png")
                end
                --更新在线
                local roomCountLabel = roomBg:getChildByName("onLineCount")
                local totalOnlineCount = nodeItem.onlineCount or 0
                roomCountLabel:setString(totalOnlineCount.."人")
            end
            --牌型花色
            -- local pokerkind1 =  roomBg:getChildByName("pokerkind1")
            -- local pokerkind2 =  roomBg:getChildByName("pokerkind2")
            -- local pokerkind3 =  roomBg:getChildByName("pokerkind3")
            -- if kindID == 203 then
            --     pokerkind1:show();
            --     pokerkind2:show();
            --     pokerkind3:show();
            -- else
            --     pokerkind1:hide();
            --     pokerkind2:hide()
            --     pokerkind3:hide()
            -- end

        end
    end
    
    return true
end

function RoomScene:onRequestWealthRankingResult()
    -- 获取排行榜数据
    local rankingArray
    if self.rankType == 1 then
        rankingArray = RankingInfo.wealthRankList
    elseif self.rankType == 2 then
        rankingArray = RankingInfo.loveLinessList
    end
    -- 如果排行榜没有数据，那么发送获取排行榜数据请求
    if(rankingArray == nil or #rankingArray == 0) then
        -- queryService:queryWealthRanking()
        print("rankingArray",rankingArray)
        if rankingArray then
            print("#rankingArray",#rankingArray)
        end
    else
        self.listView:removeAllItems()
        local count = #rankingArray
        print("排行榜的个数= === ",count)
        -- 添加自定义item
        for i = 1, count do
            local bangItemLayer = ccui.ImageView:create()
            bangItemLayer:loadTexture("common/list_item.png")
            bangItemLayer:setScale9Enabled(true)
            bangItemLayer:setContentSize(cc.size(395,84))
            bangItemLayer:setCapInsets(cc.rect(50,40,10,10))
            bangItemLayer:ignoreAnchorPointForPosition(true)
            bangItemLayer:setName("ListItem")
            bangItemLayer:setTag(i)
            --树叶装饰
            display.newSprite("hall/room/list_banner.png", 335, 35):addTo(bangItemLayer)

            -- 排名图片
            local itemRankImage = ccui.ImageView:create()
            itemRankImage:loadTexture("hall/room/hall_bang_1.png")
            itemRankImage:setPosition(cc.p(40,42+10))
            bangItemLayer:addChild(itemRankImage)
            itemRankImage:setName("itemRankImage")
            -- 排名名字
            local itemRankLblBG = ccui.ImageView:create()
            itemRankLblBG:loadTexture("hall/room/hall_bang_0.png")
            itemRankLblBG:setPosition(cc.p(40,42))
            bangItemLayer:addChild(itemRankLblBG)
            itemRankLblBG:setName("itemRankLblBG")

            local itemRankLabel = ccui.Text:create("",FONT_ART_TEXT,38)
            itemRankLabel:setTextColor(cc.c4b(140,58,0,255))
            itemRankLabel:setPosition(cc.p(40,40))
            --itemRankLabel:enableOutline(cc.c4b(140,58,0,200), 3)
            bangItemLayer:addChild(itemRankLabel)
            itemRankLabel:setName("itemRankLabel")

            -- 人物头像图片
            local itemHead = require("commonView.GameHeadView").new(1);
            itemHead:setName("ItemHead")
            bangItemLayer:addChild(itemHead)
            itemHead:setPosition(cc.p(123,40))
            itemHead:setScale(0.85)

            -- 名字
            local itemName = ccui.Text:create("",FONT_ART_TEXT,24)
            itemName:setTextColor(cc.c4b(140,58,0,255))
            itemName:setAnchorPoint(cc.p(0,0.5))
            itemName:setPosition(cc.p(170+3,70))
            bangItemLayer:addChild(itemName)
            itemName:setName("ItemName")
            -- 筹码
            local itemScore = ccui.Text:create("",FONT_ART_TEXT,24)
            itemScore:setTextColor(cc.c4b(140,58,0,255))
            itemScore:setAnchorPoint(cc.p(0,0.5))
            itemScore:setPosition(cc.p(190,44))
            bangItemLayer:addChild(itemScore)
            itemScore:setName("ItemScore")
            if self.rankType == 1 then
                local icon = display.newSprite("common/gold.png");
                icon:setPosition(cc.p(176,44))
                icon:setScale(0.5);
                bangItemLayer:addChild(icon)
            elseif self.rankType == 2 then
                local icon = display.newSprite("common/loveliness.png");
                icon:setPosition(cc.p(176,44))
                icon:setScale(0.5);
                bangItemLayer:addChild(icon)
            end
            --签名
            local itemUnderWrite = ccui.Text:create("",FONT_ART_TEXT,24)
            itemUnderWrite:setTextColor(cc.c4b(140,58,0,255))
            itemUnderWrite:setAnchorPoint(cc.p(0,0.5))
            itemUnderWrite:setPosition(cc.p(170+3,19))
            bangItemLayer:addChild(itemUnderWrite)
            itemUnderWrite:setName("itemUnderWrite")            

            local custom_item = ccui.Layout:create()
            custom_item:setTouchEnabled(true)
            custom_item:setContentSize(bangItemLayer:getContentSize())
            custom_item:addChild(bangItemLayer)
            
            self.listView:pushBackCustomItem(custom_item)
        end

        -- 设置item data
        local items_count = table.getn(self.listView:getItems())
        for i = 1, items_count do
            -- 获取当前的名次的排行榜上人的属性
            local itemInfo = rankingArray[i]
            if(itemInfo == nil) then
                break
            end
            -- 返回一个索引和参数相同的项.
            local item = self.listView:getItem( i - 1 )
            local itemLayer = item:getChildByName("ListItem")
            local index = self.listView:getIndex(item)

            -- 排名图片
            local itemRankImage = itemLayer:getChildByName("itemRankImage")
            -- 排名名字
            local itemRankLabelBG = itemLayer:getChildByName("itemRankLblBG")
            local itemRankLabel = itemLayer:getChildByName("itemRankLabel")
            -- 人物头像图片
            local itemHead = itemLayer:getChildByName("ItemHead")
            -- 名字
            local itemName = itemLayer:getChildByName("ItemName")
            -- 筹码
            local itemScore = itemLayer:getChildByName("ItemScore")
            --签名
            local itemUnderWrite = itemLayer:getChildByName("itemUnderWrite")

            itemRankLabel:setString(i)
            -- 排名前三的显示奖杯
            local jaingbeiImage = {"hall/room/hall_bang_1.png","hall/room/hall_bang_2.png",
                "hall/room/hall_bang_3.png"}
            if self.rankType == 2 then
                jaingbeiImage = {"hall/room/hall_loveliness_1.png","hall/room/hall_loveliness_2.png",
                "hall/room/hall_loveliness_3.png"}
            end
            itemRankImage:loadTexture("hall/room/hall_bang_light.png")
            if(i <= 3 ) then
                -- itemRankImageOn = :loadTexture(jaingbeiImage[i])
                local itemRankImageOn = ccui.ImageView:create(jaingbeiImage[i])
                itemRankImageOn:setPosition(40,42)
                itemLayer:addChild(itemRankImageOn)
                local itemStar = ccui.ImageView:create("hall/room/hall_bang_star.png")
                itemLayer:addChild(itemStar)
                itemStar:setPosition(30,32)
                itemStar:setScale(1.5)
                local seq = transition.sequence(
                        {
                            cc.FadeOut:create(0.5),
                            cc.FadeIn:create(0.5)
                        }
                    )
                itemStar:runAction(cc.RepeatForever:create(seq))
                local rotateBy = cc.RotateBy:create(3,360)
                itemRankImage:runAction(cc.RepeatForever:create(rotateBy))
                itemRankImage:setVisible(true)
                itemRankLabel:setVisible(false)
                itemRankLabelBG:setVisible(false)
            else
                itemRankImage:setVisible(false)
                itemRankLabel:setVisible(true)
                itemRankLabelBG:setVisible(true)
            end
            local nickName = FormotGameNickName(itemInfo.nickName,8)
            itemName:setString(nickName)
            
            
            
            if self.rankType == 1 then
                itemScore:setString(FormatNumToString(itemInfo.score))

            elseif self.rankType == 2 then
                itemScore:setString(FormatNumToString(itemInfo.loveLiness))
            end
            itemUnderWrite:setString(FormotGameNickName(itemInfo.signature,8))
            print("faceID==",itemInfo.faceID,"tokenID",itemInfo.platformID,"platformFace",itemInfo.platformFace)
            itemHead:setNewHead(itemInfo.faceID, itemInfo.platformID, itemInfo.platformFace)

        end
    end
end
function RoomScene:refreshRank(event)
    local tokenID = event.tokenID
    -- 获取排行榜数据
    local rankingArray
    if self.rankType == 1 then
        rankingArray = QueryService:getRankingList()
    elseif self.rankType == 2 then
        rankingArray = QueryService:getLoveLinessList()
    end
    -- 如果排行榜没有数据，那么发送获取排行榜数据请求
    if(rankingArray == nil or #rankingArray == 0) then

    else
 -- 设置item data
        local items_count = table.getn(self.listView:getItems())
        -- print("下载头像回调event-------------------items_count",items_count,"tokenID",tokenID)
        for i = 1, items_count do
            -- 获取当前的名次的排行榜上人的属性
            local itemInfo = rankingArray[i]
            if(itemInfo == nil) then
                break
            end
            -- 返回一个索引和参数相同的项.
            local item = self.listView:getItem( i - 1 )
            local itemLayer = item:getChildByName("ListItem")
            local index = self.listView:getIndex(item)

             -- 人物头像图片
            local itemHead = itemLayer:getChildByName("ItemHead")
            local itemTokenID = itemInfo.platformID

            if tokenID == itemTokenID then
                local imageName = RunTimeData:getLocalAvatarImageUrlByTokenID(itemInfo.platformID)
                local localmd5 = cc.Crypto:MD5File(imageName)
                if is_file_exists(imageName) and localmd5 == itemInfo.platformFace then
                    
                    self:performWithDelay(function (  )
                        -- print("延迟加载头像",imageName)
                       head = itemHead:loadTexture(imageName)
                    end, 0)
                else
                    head = itemHead:loadTexture("head/default.png")
                    
                end
            end

        end
    end
end
-- eventtype callback
function RoomScene:roomLogonResult(event)
    if event.resultCode == 0 then
        print("登录失败")
    elseif event.resultCode == 1 then
        print("登录成功")
    elseif event.resultCode == 2 then
        print("登录结束")
    end
    Hall.hideWaiting();
end

function RoomScene:roomConfigResult(event)

    print("RoomScene:roomConfigResult!!")
    
    if IS_AUTOMATCH then
        --匹配模式直接进入房间
        self:enterGame()
    
    else
        TableInfo:sendUserSitdownRequest(65535, 65535)
        self:enterGame()
    end

    
end

function RoomScene:onQueryUserInsure(event)
    print("RoomScene:onQueryUserInsure!!",self.goldValueText2,"score=",event.score)
    if self.goldValueText2 then
        self.goldValueText2:setString(FormatNumToString(event.score))
    end   

    --个人中心信息更新
    if self._setMyInfoLayer and self._setMyInfoLayer:isVisible() then
        self._setMyInfoLayer:showMyInfo()
    end 
end
function RoomScene:onExchangeCallBack(event)

    if event.subId == CMD_LogonServer.SUB_GP_EXCHANGE_BEANS_SUCCESS then--
        print("SUB_GP_EXCHANGE_BEANS_SUCCESS---------OK")
        local exchangeSuccess = protocol.hall.treasureInfo_pb.CMD_GP_ExchangeBeansSuccess_Pro()
        exchangeSuccess:ParseFromString(event.data)
        
        
        local myInfo = DataManager:getMyUserInfo()
        myInfo.tagUserInfo.lScore = exchangeSuccess.lUserScore  
        myInfo.tagUserInfo.lUserBeans = exchangeSuccess.lUserBeans

        self.goldValueText2:setString(FormatNumToString(exchangeSuccess.lUserScore))
        -- self.goldValueText:setString(FormatNumToString(exchangeSuccess.lUserBeans))
        Hall.showTips("购买欢乐豆成功！",1)
    elseif event.subId == CMD_LogonServer.SUB_GP_EXCHANGE_BEANS_FAILURE then--

        print("SUB_GP_EXCHANGE_BEANS_FAILURE------OK")
        local exchangeFailure = protocol.hall.treasureInfo_pb.CMD_GP_ExchangeBeansFailure_Pro()
        exchangeFailure:ParseFromString(event.data)
        local msg = exchangeFailure.szDescribeString;
        print("msg=",msg)
        Hall.showTips(msg, 1.0)
        
    end
    print("onExchangeCallBack")
end

function RoomScene:onUserInfoChanged(event)

    if event.subId == CMD_LogonServer.SUB_GP_OPERATE_SUCCESS then--操作成功
        self:setSelfInfo()
        
        UserService:sendQueryInsureInfo()
    elseif event.subId == CMD_LogonServer.SUB_GP_USER_FACE_INFO then --头像修改成功
        self:setSelfInfo()
    end
end
function RoomScene:systemNoticeHandler(event)
    print("==========RoomScene:systemNoticeHandler")
    local wType = event.wType
    local tipStr = event.szString
    
    if wType == 5 then
        self:checkHasBuyGold()
        self.tipStr = tipStr
    else

        local tips = require("hall.WenXinTiShiLayer").new(wType,tipStr)

        self.container:addChild(tips)
    end
end
function RoomScene:checkHasBuyGold()
    
    if RunTimeData:getNewGuestChargeStatus() then
        self.checkTime = 1
    else
        self.checkTime = 2
    end
    UserService:queryTodayWasPay()

    -- UserService:sendQueryHasBuyGoldByKind("194");
    -- UserService:sendQueryHasBuyGoldByKind("188");
    -- UserService:sendQueryHasBuyGoldByKind("189");
    print("checkHasBuyGold")
end
function RoomScene:getTodayWasNotPaySuccess(event)
    if self.checkTime == nil or OnlineConfig_review == "on" then
        return
    end
    self.checkTime = self.checkTime - 1
    if self.checkTime <= 0 then

        if RunTimeData:getDailyChargeStatus() then
            local tips = require("hall.FirstPayGiftLayer").new(2,1,self.tipStr)
            self.container:addChild(tips)
        else
            local tips = require("hall.FirstPayGiftLayer").new(1,1,self.tipStr)
            self.container:addChild(tips)
        end

    end

    -- print("getTodayWasNotPaySuccess")
    -- local info = protocol.hall.treasureInfo_pb.CMD_GP_QueryTodayWasnotPayResult_Pro();
    -- info:ParseFromString(event.data)
    -- self.checkTime = self.checkTime + 1
    -- local key = {194,188,189}
    -- self.checkValue[info.szPayId] = info.dwWasTodayPayed--//今天充值过吗 0:没有 1:已经充值过
    -- if self.checkTime >= 3 then
    --     local firstPayKind = 3
    --     if self.checkValue["189"]==0 then
    --         firstPayKind = 3
    --     end
    --     if self.checkValue["188"]==0 then
    --         firstPayKind = 2
    --     end
    --     if self.checkValue["194"]==0 then
    --         firstPayKind = 1
    --     end
    --     local tips = require("hall.FirstPayGiftLayer").new(firstPayKind,1,self.tipStr)
    --     self.container:addChild(tips)
    --     self.checkTime = nil
    --     print("self.checkTime >= 3")
    -- end
end
--下载头像回调
function RoomScene:customFaceUrlBackHandler(event)
    -- body
    print("customFaceUrlBackHandler下载头像回调event.url",event.url,"tokenID=",event.tokenID)

    -- local tokenID = DataManager:getMyUserInfo().platformID

    -- if tokenID == event.tokenID then
    --     print("下载自己的头像成功")
    --     self:performWithDelay(function ( )
    --         if self.headImage then
    --             print("延迟一秒")
    --            self.headImage:setNewHead(999,tokenID)
    --         end
    --     end, 1)
    -- end
    self:refreshRank(event)
end
--上传头像成功回调 
function RoomScene:customFaceUploadBackHandler(event)
    -- body
    local md5 = event.md5
    local tokenID = event.tokenID

    print("RoomScene:customFaceUploadBackHandler",tokenID,md5)
    self:performWithDelay(function ( )
        if self.headImage then
            print("延迟一秒")
           self.headImage:setNewHead(999,tokenID,md5)
        end
    end, 1)
 
end
function RoomScene:enterGame(event)
    print("RoomScene:enterGame", TableInfo.userID,TableInfo.tableID,TableInfo.chairID,TableInfo.userStatus)

    -- if TableInfo.userStatus.userStatus ~= Define.US_SIT then
    --     print("用户坐下失败", TableInfo.userStatus.userStatus)
    --     return
    -- end

    local curGameID = RunTimeData:getCurGameID()
    local curRoomIndex = RunTimeData:getRoomIndex()
    print("enterGame!!", curGameID)

    if curGameID ~= 202 then
        cc.UserDefault:getInstance():setBoolForKey("isReconnect", true)
    end

    RunTimeData:setPopFrom(1)
    self:removeGameEvent()

    if(curGameID == 200) then
        --统计进入抢地主场
        if curRoomIndex == 1 then
            onUmengEvent("1070")
            onUmengEventBegin("1079")
        elseif curRoomIndex == 2 then
            onUmengEvent("1071")
            onUmengEventBegin("1080")
        elseif curRoomIndex == 3 then
            onUmengEvent("1072")
            onUmengEventBegin("1081")
        elseif curRoomIndex == 4 then
            onUmengEvent("1073")
            onUmengEventBegin("1082")
        end
        print("======================enterGame")
        local nextScene = require("landlord.PlayScene")
        cc.Director:getInstance():replaceScene(cc.TransitionSlideInT:create(0.5, nextScene.new()))
    elseif(curGameID == 202) then
        local LandlordVideoScene = require("landlordVideo.LandlordVideoScene")
        cc.Director:getInstance():replaceScene(cc.TransitionSlideInT:create(0.5, LandlordVideoScene.new()))
        --进入视频场事件统计
        onUmengEvent("1074")
        onUmengEventBegin("1083")
    elseif(curGameID == 201) then
        --统计进入二人场
        if curRoomIndex == 1 then
            onUmengEvent("1066")
            onUmengEventBegin("1075")
        elseif curRoomIndex == 2 then
            onUmengEvent("1067")
            onUmengEventBegin("1076")
        elseif curRoomIndex == 3 then
            onUmengEvent("1068")
            onUmengEventBegin("1077")
        elseif curRoomIndex == 4 then
            onUmengEvent("1069")
            onUmengEventBegin("1078")
        end
print("RunTimeData:getCurGameServerType",        RunTimeData:getCurGameServerType())
        local LandlordOneVSOneScene = require("landlord1vs1.LandlordOneVSOneScene")
        cc.Director:getInstance():replaceScene(cc.TransitionSlideInT:create(0.5, LandlordOneVSOneScene.new()))
    elseif curGameID == 203 then
        print("RunTimeData:getCurGameServerType",        RunTimeData:getCurGameServerType())
        local LandlordOneVSOneScene = require("landlord1vs1.LandlordOneVSOneScene")
        cc.Director:getInstance():replaceScene(cc.TransitionSlideInT:create(0.5, LandlordOneVSOneScene.new()))
    end
end

function RoomScene:checkReconnect()
    --断线重连，一分钟内断线后重新登录进行连接
    local isReconnect =  cc.UserDefault:getInstance():getBoolForKey("isReconnect", false)
    if isReconnect then
        local lastTime = cc.UserDefault:getInstance():getIntegerForKey("lastGameTime", os.time())
        --一分钟之内的重连
        local time = os.time() - lastTime
        if time < 60 then

            self.viewPlayExit = require("commonView.ViewConfirmLayer").new(
                {ok=handler(self,self.reconnectRoomServer), cancel = function() self.viewPlayExit:removeSelf() end})

            self.viewPlayExit:addTo(self.container, 999)
        end
    end
end

function RoomScene:onConnectRoomErrHandler(event)
    local serverID = event.errCode-100000
    self.viewPlayExit = require("commonView.ViewConfirmLayer").new(
        {ok=function() self:reconnectRoomByServerID(serverID) end, cancel = function() self.viewPlayExit:removeSelf() end, desc=event.errDesc})

    self.viewPlayExit:addTo(self.container, 999)

end

function RoomScene:reconnectRoomByServerID(serverID)
    local ServerIDArray = {}
    local serverListDataManager = ServerListDataManager
    local gameKindIDArray = serverListDataManager:getAllGameKindID()
    local serverArray = {}
    for i,v in ipairs(gameKindIDArray) do
        local listData = serverListDataManager:achieveServerListDataByGameKindID(v)
        for l,server in pairs(listData.serverArray) do
            if server:getServerID() == serverID then
                RunTimeData:setCurGameID(v)
                GameConnection:connectServer(server:getServerAddr(),server:getServerPort())
                break;
            end
        end
    end

end

--保存上次游戏房间信息
function RoomScene:reconnectRoomServer()

    local gameID = cc.UserDefault:getInstance():getIntegerForKey("lastGameID", 0)
    local section = cc.UserDefault:getInstance():getIntegerForKey("lastGameSection", 1)
    local roomIndex = cc.UserDefault:getInstance():getIntegerForKey("lastRoomIndex", 1)
    if gameID ~= 0 then
        self.wCurKind = gameID
        RunTimeData:setCurGameID(gameID)
        RunTimeData:setRoomIndex(section)
        self:connectToRoom(gameID, section, roomIndex)
    end

end

-- scene logic
function RoomScene:onEnter()
    print("landlordCutie----RoomScene:createUI")
    RunTimeData:setPopFrom(0)

    -- self:registerGameEvent()
    --发送获取排行榜数据请求
    RankingInfo:sendScoreActivityRequest()
    -- 查询魅力排名
    RankingInfo:sendQueryLoveLinesActivityRequest()
    
    -- UserService:queryMarriagesInfo()
    if  RoomScene.queryTime < 1 then
        -- UserService:queryTodayWasPay()
        RoomScene.queryTime = RoomScene.queryTime + 1
    end
    
    self:setSelfInfo()
    self:refreshGameOnlineCount()

    --弹出首次注册的页面
    self:onFirstRegister()

    -- local userinfo = DataManager:getMyUserInfo()
    -- local tokenID = userInfo.platformID
    -- local url = RunTimeData:getLocalAvatarImageUrlByTokenID(tokenID)
    -- print("========url", url)
    -- local md5 = userInfo.platformFace
    -- local localmd5 = cc.Crypto:MD5File(url)
    -- print(userinfo.userID,"tokenID",tokenID,"md5===",md5,"localmd5==",localmd5,"url",url)
    -- if localmd5 ~= md5 and userinfo:faceID() == 999 then
    --     PlatformDownloadAvatarImage(userInfo.platformID, md5)
    -- end

    SoundManager.playMusic("sound/hallbgm.mp3", true)

    self:performWithDelay(handler(self, self.checkReconnect), 2.0)


    self:checkShowVideo()
    self:playSnowEffect()
end

function RoomScene:onFirstRegister()
    if firstModifyNickname == 1 then
        local firstRegisterLayer = require("hall.FirstRegisterLayer").new()
        self.container:addChild(firstRegisterLayer)
        firstModifyNickname = 0
    end
end

function RoomScene:onExit()
    -- self:removeGameEvent()
end
function RoomScene:bankSucceseHandler(event)
   print("bankSucceseHandler")
    local info = event--protocol.hall.treasureInfo_pb.CMD_GP_UserInsureSuccess_Pro();
   -- info:ParseFromString(event.data)
    -- self.qu1:setString(FormatNumToString(info.lUserInsure))
    -- self.cun1:setString(FormatNumToString(info.lUserScore));
    -- self.bankmoney:setString(FormatNumToString(info.insure))
   -- Hall.showTips(info.lUserInsure)
end
function RoomScene:receiveGoldBackHandler( event )
    print("!!!!!!!!!!!!!receiveGoldBackHandler!!!!!!!!!!")
    local result = event.data.dwResultCode--结果 0成功 其他=失败
    if result == 0 then
        local gold =  event.data.dwReceiveVaule
        if event.data.dwReceiveType == 1 then
            local myInfo = DataManager:getMyUserInfo()
            myInfo:setbeans(myInfo.beans+gold)
            -- self.goldValueText:setString(FormatNumToString(myInfo.beans))
            Hall.showTips("成功领取"..gold.."欢乐豆",1)
        end
        if event.data.dwReceiveType == 2 then
            
            UserService:sendQueryInsureInfo()
            Hall.showTips("成功领取"..gold.."金币",1)
        end

    else
        Hall.showTips("领取失败",1)
    end
    
end
function RoomScene:gameMessageHandler(event)
    local pSystemMessage = protocol.room.game_pb.CMD_CM_SystemMessage_Pro()
    pSystemMessage:ParseFromString(event.data)
    
    local msgString = pSystemMessage.szString
    self:showScrollMessage(msgString)
end
function RoomScene:marriageInfoHandler(event)
    if OnlineConfig_review == "on" then
        return
    end

    if self.goMarry then
        local userID = event.data.dwTargetUserID or 0
        if 0 < userID then
            self.goMarry:hide()
            self.married:show()
        else--未婚
            self.goMarry:show()
            self.married:hide()
        end
    end
end
function RoomScene:registerGameEvent()

    self.bindIds = {}
    self.bindIds[#self.bindIds + 1] = BindTool.bind(AccountInfo, "userId", handler(self, self.setSelfInfo))
    self.bindIds[#self.bindIds + 1] = BindTool.bind(AccountInfo, "score", handler(self, self.setSelfInfo));
    self.bindIds[#self.bindIds + 1] = BindTool.bind(AccountInfo, "insure", handler(self, self.setSelfInfo));
    self.bindIds[#self.bindIds + 1] = BindTool.bind(RoomInfo, "loginResult", handler(self, self.loginRoomResult))

    self.bindIds[#self.bindIds + 1] = BindTool.bind(RoomInfo, "ServerConfig", handler(self, self.roomConfigResult))
    -- self.bindIds[#self.bindIds + 1] = BindTool.bind(DataManager, "tabelStatuChange", handler(self, self.onTableStatusChange))
    self.bindIds[#self.bindIds + 1] = BindTool.bind(RankingInfo, "wealthRankList", handler(self, self.onRequestWealthRankingResult));
    -- self.bindIds[#self.bindIds + 1] = BindTool.bind(TableInfo, "userStatus", handler(self, self.enterGame));


    self.connected_handler = GameConnection:addEventListener(NetworkManagerEvent.SOCKET_CONNECTED, handler(self, self.onSocketStatus))
 
end

function RoomScene:removeGameEvent()
    for _, bindid in ipairs(self.bindIds) do
        BindTool.unbind(bindid)
    end
    GameConnection:removeEventListener(self.connected_handler)
end

--登陆返回结果，不一定成功
function RoomScene:loginRoomResult(event)
    if RoomInfo.loginResult == false then
        print("------登陆房间失败，code:", RoomInfo.loginResultCode, RoomInfo.loginResultMsg)

        local serverItem = ServerInfo:getServerItemByServerID(tonumber(RoomInfo.loginResultMsg))
        if serverItem then
            Hall.showTips("您正在"..serverItem.serverName.."中进行游戏!")
        end
        -- RoomInfo:sendLogoutRequest()
        self:performWithDelay(function() GameConnection:closeConnect() end, 0.1)
    end
end
 ----------------接受数据后的处理---------
function RoomScene:onSocketStatus(event)
    -- print(".... RoomScene:enterRoomRequest back ...............", tostring(self))
    if event.name == NetworkManagerEvent.SOCKET_CONNECTED then

        RoomInfo:sendLoginRequest(0, 60)
    elseif event.name == NetworkManagerEvent.SOCKET_CLOSED then
        
    elseif event.name == NetworkManagerEvent.SOCKET_CONNECTE_FAILURE then
        
    end
end

function RoomScene:onReceiveSystemMessage(event)
    if event.type==GameMessageType.CLOSE_GAME and event.msg then
        print("RoomScene:onReceiveSystemMessage!")
        
        Hall.printKind = 1
        Hall.hideWaiting()
        Hall.showTips(event.msg.szString, 3.0)
        GameConnection:closeRoomSocketDelay(1.0)
    end
end

function RoomScene:addText(target, text)
    local bangtext = ccui.Text:create(text, FONT_ART_TEXT,26)
    bangtext:setPosition(cc.p(42,15))
    bangtext:setTextColor(cc.c4b(251,233,16,255))
    bangtext:enableOutline(cc.c4b(93,44,12,200), 3)
    target:addChild(bangtext)
end
function RoomScene:showScrollMessage(messageContent)
    table.insert(self.scrollMessageArr, messageContent)
    if self.scrollTextContainer:isVisible() == false then
        self.scrollTextContainer:setVisible(true)
        self:startScrollMessage()
    end
end

function RoomScene:startScrollMessage()
    local messageCount = table.maxn(self.scrollMessageArr)
    if messageCount > 0 then
        local scrollTextPanel = self.scrollTextContainer:getChildByName("scrollTextPanel")
        local messageContent = self.scrollMessageArr[1]
        local scrollText = ccui.Text:create()
        scrollText:setFontSize(22)
        scrollText:setAnchorPoint(cc.p(0,0.5))
        scrollText:setString(messageContent)
        scrollText:setPosition(cc.p(scrollTextPanel:getContentSize().width,scrollTextPanel:getContentSize().height/2))
        scrollTextPanel:addChild(scrollText)

        local moveDistance = scrollText:getContentSize().width + scrollTextPanel:getContentSize().width
        local moveDuration = moveDistance / 100

        local scrollAction = cc.Sequence:create(
                        cc.MoveBy:create(moveDuration, cc.p(-moveDistance,0)),
                        cc.CallFunc:create(function() 
                            scrollText:removeFromParent()
                            self:startScrollMessage()
                        end)
                    )
        scrollText:runAction(scrollAction)

        table.remove(self.scrollMessageArr,1)
    else
        self.scrollTextContainer:setVisible(false)
    end
end

function RoomScene:showPlayerInfo(index)

    if self.rankType == 1 then
        rankingArray = RankingInfo.wealthRankList
    elseif self.rankType == 2 then
        rankingArray = RankingInfo.loveLinessList
    end

    self.userInfo = require("landlord.ViewPlayerInfo").new({false,index})
    self.userInfo:addTo(self.container)--:align(display.CENTER, display.cx, display.cy)

    local userInfo = rankingArray[index+1]

    if userInfo then
        self.userInfo:refreshByIndex({false,1})
        self.userInfo:show()
        self.userInfo:setName(userInfo.nickName)
        -- self.userInfo:setID(userInfo.gameID)
        --self.userInfo:setHLD(userInfo:getUserScore())
        self.userInfo:setGold(userInfo.score)
        self.userInfo:setLQ(userInfo.present,true)
        self.userInfo:setML(userInfo.loveLiness)
        -- self.userInfo:setMaxGold(userInfo.highestScore)
        self.userInfo:setLevelInfo(userInfo.medal)
        self.userInfo:setSex(userInfo.gender)
        self.userInfo:setIcon(userInfo.faceID,userInfo.platformID, userInfo.platformFace)
        self.userInfo:setVip(userInfo.vip)
        self.userInfo:setUnderWrite(userInfo.signature)
    end
end

function RoomScene:onClickExchangeCoupon()
    local newLayer = require("hall.ExchangeCouponLayer").new()
    self.container:addChild(newLayer)
    self.exchangeLayer = newLayer 

end

function RoomScene:checkShowVideo()
    
    local nodeList = ServerInfo:getNodeListByKind(202)
    local serverArrCount = #nodeList
    
    -- for i=1,serverArrCount do
    --     local gameServer = nodeList[i]
    --     if gameServer and VideoAnchorManager:isOnline(gameServer:getServerID()) == 1 then
    --         --是否在线
    --         print("打开视频提示！！！", i)
    --         local isShow = cc.UserDefault:getInstance():getBoolForKey("isNeedShowVideo", true)
    --         if isShow then
    --             cc.UserDefault:getInstance():setBoolForKey("isNeedShowVideo", false)

    --             self:showVideoView(i)
    --         end
    --         break
    --     end
    -- end
end

function RoomScene:showVideoView(serverIndex)

    local winSize = cc.Director:getInstance():getWinSize();
    --蒙板
    local maskLayer = ccui.ImageView:create("black.png");
    maskLayer:setScale9Enabled(true);
    maskLayer:setContentSize(cc.size(winSize.width, winSize.height));
    maskLayer:setPosition(cc.p(display.width/2, display.height/2));
    maskLayer:setTouchEnabled(true)
    self.container:addChild(maskLayer)

    maskLayer:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                -- maskLayer:removeFromParent()
            end
        end
    )

    local bg = ccui.ImageView:create("common/ty_dialog_small_bg.png");
    bg:setPosition(maskLayer:getContentSize().width/2, maskLayer:getContentSize().height/2)
    maskLayer:addChild(bg)

    --banner
    display.newSprite("common/ax.png"):addTo(bg):pos(45,195):rotation(-80):scale(0.9)
    display.newSprite("common/ax.png"):addTo(bg):pos(350,120):rotation(-60):scale(0.9)
    display.newSprite("common/ax.png"):addTo(bg):pos(375,125):scale(1.2)

    local zhuBoMM = EffectFactory:getInstance():getZhuBoMMAnimation()
    zhuBoMM:ignoreAnchorPointForPosition(false)
    zhuBoMM:setAnchorPoint(cc.p(0,0))
    zhuBoMM:setPosition(cc.p(-126,-18))
    bg:addChild(zhuBoMM)
    zhuBoMM:getAnimation():playWithIndex(0)
    zhuBoMM:setRotation(-12)

    local xiaoJi = ccui.ImageView:create("common/ty_xiao_ji.png");
    xiaoJi:setPosition(bg:getContentSize().width+10, 0)
    bg:addChild(xiaoJi)

    local content = ccui.Text:create("绚丽的视频场上线啦！快和我一\n起去围观萌妹子的表演吧！","",23)
    content:setPosition(bg:getContentSize().width/2 + 10, 160);
    content:setColor(cc.c3b(0x83, 0x43, 0x11))
    bg:addChild(content)

    local GameItemFactory = require("commonView.GameItemFactory")

    local btn = GameItemFactory:getInstance():getBtnBlue1ByText(
                function(sender,eventType)
                    maskLayer:removeFromParent()
                end,
                "不去了")
    bg:addChild(btn)
    btn:setPosition(cc.p(120,70))

    btn = GameItemFactory:getInstance():getBtnGreen1ByText(
                function(sender,eventType)
                    print("goto video scene!")
                    self:onEnterRoomSelectPage(202)
                    self:onConnectToRoom(serverIndex)
                    maskLayer:removeFromParent()
                end,
                "马上去")
    bg:addChild(btn)
    btn:setPosition(cc.p(bg:getContentSize().width-110,70))


end

function RoomScene:onConnectToRoom(index)
    print("VipRoomLayer:onConnectToRoom:",index)
    local nodeItem = ServerInfo:getNodeItemByIndex(202, 1)
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
    GameConnection:connectServer(gameServer.serverAddr,gameServer.serverPort)
    Hall.showWaiting(3)
end

function RoomScene:showSnow(isShow)
    if isShow then
        self.moveSnow:runAction(cc.MoveBy:create(0.2, cc.p(0,50)))
    else
        self.moveSnow:runAction(cc.MoveBy:create(0.2, cc.p(0,-50)))
    end
end
function RoomScene:playSnowEffect()
    local texture2d = cc.Director:getInstance():getTextureCache():addImage("effect/lizi_xuehua.png");
    local light = cc.ParticleSystemQuad:create("effect/lizi_xuehua.plist");
    light:setTexture(texture2d);
    light:setPosition(cc.p(display.cx, display.top));
    self.container:addChild(light,99)
end

function RoomScene:onReceiveGameConfig()
    print("RoomScene:onReceiveGameConfig!")
    
end
return RoomScene