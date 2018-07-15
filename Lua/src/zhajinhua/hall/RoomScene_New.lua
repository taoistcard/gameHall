local RoomScene = class("RoomScene", require("ui.CCBaseScene_ZJH"))
require("gameSetting.LevelSetting")

local EffectFactory = require("commonView.EffectFactory")
local DateModel = require("zhajinhua.DateModel")
RoomScene.queryTime = 0
local scheduler = require("framework.scheduler")
local directorWinSize = cc.Director:getInstance():getWinSize();
-- OnlineConfig_review = "on";
function RoomScene:ctor()
    --测试用
    BindMobilePhone = true--现在去掉试玩场，移除之前的非正式号限制条件
    -- OnlineConfig_review = "on"
    --测试用END
    print("+++++++++",BindMobilePhone,"OnlineConfig_review",OnlineConfig_review)
    -- 根节点变更为self.container
    self.super.ctor(self)
    self.room_node_id = {300,301,303,304}
    --背景
    local bgSprite = cc.Sprite:create()
    bgSprite:setTexture("hall/room/bg.jpg")
    print("CONFIG_SCREEN_WIDTH",CONFIG_SCREEN_WIDTH,"CONFIG_SCREEN_HEIGHT",CONFIG_SCREEN_HEIGHT)
    bgSprite:align(display.CENTER, DESIGN_WIDTH/2,DESIGN_HEIGHT/2)
    self.container:addChild(bgSprite)
    
    -- AppRestorePurchaseList = {}
    -- AppRestorePurchaseList[1] = {orderDate = os.date()}
    -- AppRestorePurchaseList[2] = {orderDate = os.date()}

    --排行榜类型 1财富2魅力
    self.rankType = 1
    --当前游戏类型 炸金花 6
    self.wCurKind = 6
    self.lastClickTime = 0
    RunTimeData:setCurGameID(self.wCurKind)

    --滚动消息数组
    self.scrollMessageArr = {}

    --按键处理
    self:setKeypadEnabled(true)
    self:addNodeEventListener(cc.KEYPAD_EVENT, function(event)
        if event.key == "back" then
            self:onClickBack()
        end
    end)

    self:registerGameEvent()

    self:createUI()
    
    --请求累积充值等活动的配置信息
    require("hall.huodong.HuoDongManager"):getInstance():requestFromServerHuoDongConfig(AccountInfo.userId)
    -- require("hall.huodong.HuoDongManager"):getInstance():requestFromServerHuoDongConfig(2152743)

end

-- 构建界面
function RoomScene:createUI()
    self:createTopView()
    self:createBottomPageView()
    -- local cardFriend = require("hall.CardFriend").new()
    -- cardFriend:setPosition(0,0)
    -- self.container:addChild(cardFriend)

    -- local winSize = cc.Director:getInstance():getWinSize();
    -- local awardLayer = require("hall.AwardPoolLayer").new()
    -- -- awardLayer:setPosition(cc.p(winSize.width/2,winSize.height/2));
    -- -- awardLayer:setAnchorPoint(cc.p(0.5,0.5))
    -- -- awardLayer:ignoreAnchorPointForPosition(false)
    -- self:addChild(awardLayer,100)

end

function RoomScene:onExit()
    onUmengEventEnd("dating")
    package.loaded["hall.BankLayer"] = nil;
end

-- scene logic
function RoomScene:onEnter()
    self.competeRoom = false
    DataManager:setAutoHallLogin(true)
    DateModel:getInstance():setIsCompeteRoom(false)
    if OnlineConfig_review == nil or OnlineConfig_review == "on" or cc.UserDefault:getInstance():getBoolForKey("isBindMobile", false) == true or BindMobilePhone == true then
        AccountInfo:sendSetBindingInfo()
    end
    onUmengEventBegin("dating")
    RunTimeData:setPopFrom(0)

    --发送获取排行榜数据请求
    RankingInfo:sendScoreActivityRequest()
    -- 查询魅力排名
    RankingInfo:sendQueryLoveLinesActivityRequest()

    self:setSelfInfo()

    self:refreshGameOnlineCount()

    --弹出首次注册的页面
    self:onFirstRegister()


    -- local userinfo = PlayerInfo:getMyUserInfo()
    -- local tokenID = userinfo:getTokenID()
    -- local url = RunTimeData:getLocalAvatarImageUrlByTokenID(tokenID)
    -- print("========url", url)
    -- local md5 = userinfo:getHeadFile()
    -- local localmd5 = cc.Crypto:MD5File(url)
    -- print(userinfo:userID(),"tokenID",tokenID,"md5===",md5,"localmd5==",localmd5,"url",url)
    -- if localmd5 ~= md5 and userinfo:faceID() == 999 then
    --     PlatformDownloadAvatarImage(userinfo:getTokenID(), md5)
    -- end

    SoundManager.play3CardHallBackGround()

    -- scheduler.performWithDelayGlobal(function()
    --     --查询所有房间 的在线人数,
    --     local ServerIDArray = {}
    --     local serverListDataManager = ServerListDataManager
    --     local gameKindIDArray = serverListDataManager:getAllGameKindID()
    --     local serverArray = {}
    --     for i,v in ipairs(gameKindIDArray) do
    --         local listData = serverListDataManager:achieveServerListDataByGameKindID(v)
    --         for l,server in pairs(listData.serverArray) do
    --             table.insert(serverArray,server)
    --         end
    --     end
    --     for k,v in pairs(serverArray) do
    --         table.insert(ServerIDArray,v:getServerID())
    --     end
    --     -- HallCenter:sendGetOnLineCountByGameKindID(ServerIDArray)

    -- end, 3)
end

--进入选桌子界面
function RoomScene:onEnterTableSelectPage()
    -- body
end
--检测是否显示除了试玩场之外的场（初级场，高级场，富豪场）
function RoomScene:checkShowNormalRoom()
    if OnlineConfig_review == nil or OnlineConfig_review == "on" then
        return true
    end
    -- print("checkShowNormalRoom--AccountType",AccountType,"BindMobilePhone",BindMobilePhone)
    local normalRoom = false
    if AccountType ~= 1 or BindMobilePhone == true then
        normalRoom = true
    end

    return normalRoom
end
--检测是否能进（初级场，高级场，富豪场）
function RoomScene:checkCanGoNormalRoom()
    local can = true
    -- print("checkCanGoNormalRoom--AccountType",AccountType,"BindMobilePhone",BindMobilePhone)
    if AccountType == 1 and BindMobilePhone == false then
        can = false
    end
    return can
end
--检测是否能进试玩场
function RoomScene:checkCanGoTestRoom()
    local can = false
    if (AccountType == 1 and DataManager:getMyUserInfo().score+DataManager:getMyUserInfo().insure<10000) then
        can = true
    else
        Hall.showTips("你已经不能进入试玩场了，请去个人中心绑定手机号后，前往其他场", 1)
    end
    return can 
end
function RoomScene:refreshRoomMask()
    local showMask = self:checkShowNormalRoom()==false
    -- print("refreshRoomMask",show)
    for i,v in ipairs(self.showMaskArray) do
        if showMask then
            v:show()
        else
            v:hide()
        end
    end
end
--@param index  --1 新手场 2 高级场 3 豪华场 4 试玩场
function RoomScene:onEnterRoom(index)
    -- print("onEnterRoom:",index)
    -- self:connectToRoom(self.wCurKind, index, 1)
    if self.lastClickTime > os.time() - 1 then
        Hall.showTips("操作过于频繁", 1)
        return
    end
    self.lastClickTime = os.time()
    self.roomIndex = index

    -- dump(ServerInfo.nodeItemList, "ServerInfo.nodeItemList")
    -- dump(ServerInfo.nodeItemList[1].serverList, "ServerInfo.nodeItemList[1].serverList")
    local nodeList = ServerInfo:getNodeListByKind(6)
    -- print("房间信息",ServerInfo.nodeItemList,nodeList)
    for k,v in pairs(nodeList) do
        -- print(k,v,"nodeID",v.nodeID)
        if self.room_node_id[index] == v.nodeID then
            if #v.serverList > 0 then
                -- print(k.."进入"..v.nodeID..":"..v.name.."...."..self.room_node_id[index],v.onlineCount,v.fullCount)
                local room = v.serverList[1]

                for i=1,#v.serverList do
                    room = v.serverList[i]
                    if room.fullCount*0.6 > room.onlineCount then    
                        -- print("check登录的房间的在线人数",room.onlineCount,room.fullCount)                    
                        room = v.serverList[i]             
                    end
                end
                local delayTime = 0
                if GameConnection.networkSocket and GameConnection.networkSocket:getCurSocketStatus() == SocketStatus.STATUS_CONNECTED then
                    GameConnection:closeConnect()
                    print("大厅中关闭游戏链接，延迟一秒再链接")
                    delayTime = 1
                else
                end
                self:performWithDelay(function ()
                    self.roomAddr = room.serverAddr
                    self.roomPort = room.serverPort
    
                    if string.len(ServerHostBackUp) > 0 then
                        self.roomAddr = ServerHostBackUp
                    end
                    
                    -- print("登录的房间的在线人数",room.onlineCount,room.fullCount)
                    GameConnection:connectServer(self.roomAddr, self.roomPort)--1300--self.roomPort
                    RunTimeData:setCurGameServer(room)
                    RunTimeData:setCurGameNode(self.room_node_id[index])
                    RunTimeData:setRoomIndex(index)
                end, delayTime)
                break;
            end
        end
    end
                -- self.roomAddr = "192.168.0.93"--room.serverAddr
                -- self.roomPort = 1100--1200--room.serverPort
                -- GameConnection:connectServer(self.roomAddr, self.roomPort)
                -- -- RunTimeData:setCurGameServer(room)
                -- RunTimeData:setRoomIndex(index)
    Click();
end

function RoomScene:onClickBack()
    DataManager:setAutoHallLogin(false)
    package.loaded["hall.RoomScene_New"] = nil
    self:removeGameEvent()
    Hall:exitGame()
    Click();
end

function RoomScene:onClickSetting()
    print("onClickSetting")
    local setting = require("hall.SettingLayer").new()
    self.container:addChild(setting)
    Click();
end

-- 大厅上层视图
function RoomScene:createTopView()
    
    -- topView bg,as container
    self.hallTopView = ccui.ImageView:create()
    self.hallTopView:loadTexture("hall/room/hall_top_bg.png")
    self.hallTopView:setAnchorPoint(cc.p(0.5,1.0))
    self.hallTopView:setPosition(cc.p(DESIGN_WIDTH/2, DESIGN_HEIGHT+directorWinSize.height/2-DESIGN_HEIGHT/2))
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
    local selfInfoLayer = cc.Node:create(); --ccui.ImageView:create()
    -- selfInfoLayer:loadTexture("hall/room/hall_selfinfo_bg.png")
    -- selfInfoLayer:setAnchorPoint(cc.p(0.5,1.0))
    selfInfoLayer:setPosition(cc.p(155, 0))
    self.hallTopView:addChild(selfInfoLayer)

    --头像
    local headView = require("commonView.HeadView").new(1);
    headView:setScale(0.90)
    headView:setPosition(cc.p(60,56))
    selfInfoLayer:addChild(headView);
    self.headImage = headView;

    --等级
    self.levelText = ccui.Text:create("LV.1",FONT_ART_TEXT,22)
    self.levelText:setAnchorPoint(cc.p(0,0.5))
    self.levelText:setPosition(cc.p(140,40))
    self.levelText:setTextColor(cc.c4b(255,244,13,255))
    selfInfoLayer:addChild(self.levelText)

    --昵称
    self.nickNameText = ccui.Text:create("这里是昵称",FONT_ART_TEXT,35)
    self.nickNameText:setAnchorPoint(cc.p(0,0.5))
    self.nickNameText:setPosition(cc.p(140,75))
    self.nickNameText:setTextColor(cc.c4b(250,255,255,255))
    selfInfoLayer:addChild(self.nickNameText)

    --个人中心
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
            end
        end
    )
    
    --金币信息
    local goldInfoLayer = ccui.ImageView:create()
    goldInfoLayer:loadTexture("common/txtBg.png")
    -- goldInfoLayer:setScale9Enabled(true)
    -- goldInfoLayer:setContentSize(cc.size(200, 45))
    -- goldInfoLayer:setCapInsets(cc.rect(100,25,1,1))
    goldInfoLayer:setPosition(cc.p(700, 70))
    self.hallTopView:addChild(goldInfoLayer)

    local chouma = ccui.ImageView:create()
    chouma:loadTexture("hall/room/chouma_icon.png")
    chouma:setPosition(cc.p(22, 21))
    goldInfoLayer:addChild(chouma)

    --gold value
    self.goldValueText2 = ccui.Text:create("12.8万", FONT_ART_TEXT, 28)
    self.goldValueText2:setColor(cc.c3b(255, 255, 14))
    self.goldValueText2:setAnchorPoint(cc.p(0, 0.5))
    self.goldValueText2:setPosition(cc.p(65, goldInfoLayer:getContentSize().height/2-2))
    goldInfoLayer:addChild(self.goldValueText2)

    --add button
    local addButton2 = ccui.ImageView:create()
    addButton2:loadTexture("common/plus.png")
    addButton2:setPosition(cc.p(210, goldInfoLayer:getContentSize().height/2 - 3))
    goldInfoLayer:addChild(addButton2)

    local image = ccui.ImageView:create("common/blank.png"); 
    image:setScale9Enabled(true)
    image:setContentSize(cc.size(98,99))
    image:setPosition(cc.p(210, goldInfoLayer:getContentSize().height/2 - 3))
    goldInfoLayer:addChild(image)
    image:setTouchEnabled(true)
    image:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.began then
            addButton2:setScale(1.1)
        elseif eventType == ccui.TouchEventType.ended then
            addButton2:setScale(1.0)
            self:onClickBuy()
        elseif eventType == ccui.TouchEventType.canceled then
            addButton2:setScale(1.0)
        end
    end)

    --礼券信息
    local couponLayer = ccui.ImageView:create("common/txtBg.png")
    couponLayer:setScale9Enabled(true)
    couponLayer:setContentSize(cc.size(200, 45))
    couponLayer:setCapInsets(cc.rect(100,25,1,1))
    couponLayer:setPosition(cc.p(830, 55))
    self.hallTopView:addChild(couponLayer)

    local couponIcon = ccui.ImageView:create("common/ty_lq_icon.png")
    couponIcon:setPosition(20, couponLayer:getContentSize().height/2-2)
    couponLayer:addChild(couponIcon)

    local couponTxt = ccui.Text:create("0",FONT_ART_TEXT,30)
    couponTxt:setColor(cc.c3b(255,255,0))
    couponTxt:setAnchorPoint(cc.p(0,0.5))
    couponTxt:setPosition(cc.p(65,couponLayer:getContentSize().height/2-2))
    couponLayer:addChild(couponTxt)
    self.couponTxt = couponTxt
    -- if OnlineConfig_review == nil or OnlineConfig_review == "on" then
        couponLayer:hide()
    -- end
    --设置
    local settingButton = ccui.ImageView:create()
    settingButton:setTouchEnabled(true)
    settingButton:loadTexture("hall/room/hall_setting.png")
    settingButton:setPosition(cc.p(1045,72))
    self.hallTopView:addChild(settingButton)
    settingButton:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.began then
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
    scrollTextContainer:setPosition(cc.p(display.left + 100+513, DESIGN_HEIGHT+directorWinSize.height/2-DESIGN_HEIGHT/2 - 60-107))
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
end

-- 大厅下层视图
function RoomScene:createBottomPageView()
    self.bottomPageView = ccui.Layout:create()
    self.bottomPageView:setContentSize(cc.size(2272,550))
    -- self.bottomPageView:setPosition(cc.p(0,0))
    self.container:addChild(self.bottomPageView)
    self:createHallPage()
    self:createRoomTypeButtons()

    if OnlineConfig_review == nil or OnlineConfig_review == "on" then
    else
        -- self:createActivityButtons()
    end
    local competeButton = ccui.Button:create("hall/competeSignUp/chip.png")
    competeButton:setPosition(cc.p(1050, 400))
    competeButton:hide()
    competeButton:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then                
                self:competeHandler()
            end
        end
    )
    self.bottomPageView:addChild(competeButton)
    local competeSelectButton = ccui.Button:create("hall/competeSignUp/chip.png")
    competeSelectButton:setPosition(cc.p(1050, 300))
    competeSelectButton:hide()
    competeSelectButton:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then                
                self:competeSelectHandler()
            end
        end
    )
    self.bottomPageView:addChild(competeSelectButton)
end
function RoomScene:competeHandler()
    local signUp = require("hall.CompeteSignUpLayer").new()

    self.container:addChild(signUp)


    -- require("protocol.loginServer.loginServer_testfloat_c2s_pb")
    -- local request = protocol.loginServer.testfloat.c2s_pb.TestFloat()
    -- request.amount = 2.3
    -- local pData = request:SerializeToString()
    -- local response = protocol.loginServer.testfloat.c2s_pb.TestFloat()
    -- response:ParseFromString(pData)
    -- dump(response, "response")


end
function RoomScene:competeSelectHandler()
    local competeSelect = require("hall.CompeteSelectLayer").new()

    self.container:addChild(competeSelect)
end
function RoomScene:createHallPage()
    self.hallPage = ccui.Layout:create()
    self.hallPage:setContentSize(cc.size(1136, 550))
    self.hallPage:setPosition(cc.p(0,0))
    self.bottomPageView:addChild(self.hallPage)

    --财富榜
    local bangLayer = ccui.ImageView:create()
    bangLayer:loadTexture("hall/room/hall_bang_bg.png")
    bangLayer:setScale9Enabled(true)
    bangLayer:setContentSize(cc.size(490,525))
    bangLayer:setCapInsets(cc.rect(200,90,10,10))
    bangLayer:setPosition(cc.p(320, 265))
    self.hallPage:addChild(bangLayer)

    ----------- for 正式
    --bang title bg
    local bangtitle = ccui.Button:create()
    bangtitle:loadTextures("hall/room/wealthRank.png", "hall/room/wealthRankSelected.png")
    bangtitle:setPosition(cc.p(163, 490))
    bangtitle:addTouchEventListener(
                function(sender,eventType)
                    if eventType == ccui.TouchEventType.ended then
                        self.rankType = 1
                        self.lovelinessTitle:setHighlighted(false)
                        self.bangtitle:setHighlighted(true)
                        self:onRequestWealthRankingResult()                     
                    end
                end
            )
    bangLayer:addChild(bangtitle,1)
    self.bangtitle = bangtitle

    ---魅力榜
    --bang title bg
    local lovelinessTitle = ccui.Button:create()
    lovelinessTitle:loadTextures("hall/room/lovelinessRank.png","hall/room/lovelinessRankSelected.png")
    lovelinessTitle:setPosition(cc.p(163+180, 490))
    lovelinessTitle:addTouchEventListener(
                function(sender,eventType)
                    if eventType == ccui.TouchEventType.ended then
                        self.rankType = 2
                        self.lovelinessTitle:setHighlighted(true)
                        self.bangtitle:setHighlighted(false)
                        self:onRequestWealthRankingResult()               
                    end
                end
            )
    bangLayer:addChild(lovelinessTitle,1)
    self.lovelinessTitle = lovelinessTitle

    self.lovelinessTitle:setHighlighted(false)
    self.bangtitle:setHighlighted(true)
    -- bang listview
    self.listView = ccui.ListView:create()
    self.listView:setDirection(ccui.ScrollViewDir.vertical)
    self.listView:setBounceEnabled(true)
    self.listView:setContentSize(cc.size(435, 340))
    self.listView:setPosition(30,120)
    bangLayer:addChild(self.listView)
    self.listView:addEventListener(function(sender, eventType)
        if eventType == ccui.ListViewEventType.ONSELECTEDITEM_END then
            print("select child index = ",sender:getCurSelectedIndex())
            self:showPlayerInfo(sender:getCurSelectedIndex())
        end
    end)

    local rankmask = ccui.ImageView:create()
    rankmask:loadTexture("hall/room/rank_bottom_mask.png")
    rankmask:setAnchorPoint(cc.p(0,0.5))
    bangLayer:addChild(rankmask)
    rankmask:setPosition(25,124)

    ----------- for review
    --review title
    local review_bangtitle = ccui.ImageView:create()
    review_bangtitle:loadTexture("hall/room/gameintro.png")
    review_bangtitle:setPosition(cc.p(235, 480))
    bangLayer:addChild(review_bangtitle)
    --review text
    -- local review_messagetext = ccui.ImageView:create()
    -- review_messagetext:loadTexture("hall/room/messagetext.png")
    -- review_messagetext:setPosition(cc.p(245,288))
    -- bangLayer:addChild(review_messagetext)
    local messagetext = "金三顺是民间非常流行的一种扑克牌玩法，俗称“三张”它具有特定的比牌规则，玩家按照规则以手中的牌来决定输赢。在游戏过程中需要考验玩家的胆略和智慧，且由于玩法简单，易接受。因此金三顺是被公认的最受欢迎的纸牌游戏之一。"
    local review_messagetext = ccui.Text:create(messagetext,"",28)
    review_messagetext:setTextColor(cc.c4b(255,58,255,255))
    review_messagetext:setPosition(cc.p(245,288))
    review_messagetext:setAnchorPoint(cc.p(0.5,0.5))
    bangLayer:addChild(review_messagetext)
    review_messagetext:setName("review_messagetext")
    review_messagetext:setTextAreaSize(cc.size(360,260))
    review_messagetext:ignoreContentAdaptWithSize(false)
    review_messagetext:setTextHorizontalAlignment(0)
    review_messagetext:setTextVerticalAlignment(0)


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

    --bang 消息
    local messageButton = ccui.ImageView:create()
    messageButton:setTouchEnabled(true)
    messageButton:loadTexture("hall/room/functionBtn_bg.png")
    messageButton:setPosition(cc.p(90, 45))
    bangLayer:addChild(messageButton)
    messageButton:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.began then
            messageButton:setScale(1.1)
        elseif eventType == ccui.TouchEventType.ended then
            messageButton:setScale(1.0)
            self:onClickMessage()
        elseif eventType == ccui.TouchEventType.canceled then
            messageButton:setScale(1.0)
        end
    end)
    local func_icon = ccui.ImageView:create()
    func_icon:loadTexture("common/email.png")
    func_icon:setPosition(cc.p(48, 50))
    messageButton:addChild(func_icon)
    --add text
    self:addText(messageButton, "消息")


    --bang 银行
    local tuijianButton = ccui.ImageView:create()
    tuijianButton:setTouchEnabled(true)
    tuijianButton:loadTexture("hall/room/functionBtn_bg.png")
    tuijianButton:setPosition(cc.p(192, 45))
    bangLayer:addChild(tuijianButton)
    tuijianButton:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.began then
            tuijianButton:setScale(1.1)
        elseif eventType == ccui.TouchEventType.ended then
            tuijianButton:setScale(1.0)
            self:onClickBank()
        elseif eventType == ccui.TouchEventType.canceled then
            tuijianButton:setScale(1.0)
        end
    end)
    local func_icon = ccui.ImageView:create()
    func_icon:loadTexture("common/hall_icon_bank.png")
    func_icon:setPosition(cc.p(48, 50))
    tuijianButton:addChild(func_icon)
    --add text
    self:addText(tuijianButton, "银行")

    --bang 活动
    local activityButton = ccui.ImageView:create()
    activityButton:setTouchEnabled(true)
    activityButton:loadTexture("hall/room/functionBtn_bg.png")
    activityButton:setPosition(cc.p(305,45))
    bangLayer:addChild(activityButton)
    activityButton:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.began then
            activityButton:setScale(1.1)
        elseif eventType == ccui.TouchEventType.ended then
            activityButton:setScale(1.0)
            self:onClickActivity()
        elseif eventType == ccui.TouchEventType.canceled then
            activityButton:setScale(1.0)
        end
    end)
    local func_icon = ccui.ImageView:create()
    func_icon:loadTexture("hall/room/hall_icon_activity.png")
    func_icon:setPosition(cc.p(48, 50))
    activityButton:addChild(func_icon)
    --add text
    self:addText(activityButton, "活动")

    --bang 免费
    local freeButton = ccui.ImageView:create()
    freeButton:setTouchEnabled(true)
    freeButton:loadTexture("hall/room/functionBtn_bg.png")
    freeButton:setPosition(cc.p(415,45))
    bangLayer:addChild(freeButton)
    freeButton:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.began then
            freeButton:setScale(1.1)
        elseif eventType == ccui.TouchEventType.ended then
            freeButton:setScale(1.0)
            self:onClickFreeChip()
        elseif eventType == ccui.TouchEventType.canceled then
            freeButton:setScale(1.0)
        end
    end)
    local func_icon = ccui.ImageView:create()
    func_icon:loadTexture("hall/room/hall_icon_free.png")
    func_icon:setPosition(cc.p(48, 50))
    freeButton:addChild(func_icon)
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

function RoomScene:showPlayerInfo(index)

    if self.rankType == 1 then
        rankingArray = RankingInfo.wealthRankList
    elseif self.rankType == 2 then
        rankingArray = RankingInfo.loveLinessList
    end

    self.userInfo = require("hall.ViewPlayerInfo").new({false,index})
    self.userInfo:addTo(self.container)--:align(display.CENTER, display.cx, display.cy)

    local userInfo = rankingArray[index+1]

    if userInfo then
        -- dump(userInfo)
        self.userInfo:refreshByIndex({false,1})
        self.userInfo:show()
        self.userInfo:setName(userInfo.nickName)
        -- self.userInfo:setID(userInfo.tagUserInfo.dwGameID)
        --self.userInfo:setHLD(userInfo:getUserScore())
        self.userInfo:setGold(userInfo.score)
        self.userInfo:setLQ(userInfo.gift,true)
        self.userInfo:setML(userInfo.loveLiness)
        -- self.userInfo:setMaxGold(userInfo:getHighestScore())
        self.userInfo:setLevelInfo(userInfo.medal)
        self.userInfo:setSex(userInfo.gender)
        self.userInfo:setIcon(userInfo.faceID,userInfo.platformID,userInfo.platformFace)
        self.userInfo:setVip(userInfo.vip)
        self.userInfo:setUnderWrite(userInfo.signature)
    end
end

--1 新手场 2 高级场 3 豪华场 4 试玩场
function RoomScene:createRoomTypeButtons()
    self.showMaskArray = {}
    local bangLayer = ccui.Layout:create()
    bangLayer:setPosition(115, -65)
    self.bottomPageView:addChild(bangLayer)
    local showMask = self:checkShowNormalRoom()==false
    print("createRoomTypeButtons---showMask",showMask)
    local inReview = false
    local chujiPos = cc.p(850, 470)
    if OnlineConfig_review == nil or OnlineConfig_review == "on" then
        inReview = true
        chujiPos = cc.p(585, 470)
    end
    local deleteFreeRoom = true--删除试玩场
    if deleteFreeRoom == true then
        chujiPos = cc.p(585, 470)
    end
    -- if inReview == false then
    --     --room 试玩场
    --     local noviceFreeButton = ccui.ImageView:create()
    --     noviceFreeButton:setTouchEnabled(true)
    --     noviceFreeButton:setPosition(cc.p(585, 470))
    --     bangLayer:addChild(noviceFreeButton)

    --     noviceFreeButton:loadTexture("blank.png")
    --     noviceFreeButton:setScale9Enabled(true);
    --     noviceFreeButton:setContentSize(cc.size(240,250));
    --     local iconUp = ccui.ImageView:create("hall/room/roombutton4.png")
    --     iconUp:addTo(noviceFreeButton):align(display.CENTER, 120, 125)
    --     -- iconUp:setScale(0.8)

    --     --TODO
    --     noviceFreeButton:addTouchEventListener(function(sender,eventType)
    --         if eventType == ccui.TouchEventType.began then
    --             noviceFreeButton:setScale(1.1)
    --         elseif eventType == ccui.TouchEventType.ended then
    --             noviceFreeButton:setScale(1.0)
    --             if self:checkCanGoTestRoom() then
    --                 self:onEnterRoom(4)
    --             else
    --                 --todo
    --             end
                
    --         elseif eventType == ccui.TouchEventType.canceled then
    --             noviceFreeButton:setScale(1.0)
    --         end
    --     end)

    --     local particle = cc.ParticleSystemQuad:create("particle/lizi_chang_hong.plist")
    --     -- particle:setScale(1.5)
    --     -- particle:setEmissionRate(2)
    --     particle:addTo(iconUp):align(display.CENTER, 120, 129)

    --     local bgSprite = EffectFactory:getInstance():getGirlsArmature("ani_girl_4")
    --     bgSprite:align(display.CENTER, 120, 120);
    --     -- bgSprite:setScale(0.80)
    --     -- bgSprite:setScaleX(-0.8)
    --     iconUp:addChild(bgSprite);

    --     display.newSprite("hall/room/word_shiwan.png", 120, 35):addTo(iconUp)

    --     display.newSprite("hall/room/green_dot.png", 80, 0):addTo(iconUp)

    --     self.personInFreeHouse = ccui.Text:create()
    --     self.personInFreeHouse:setString("130人")
    --     self.personInFreeHouse:setFontSize(26)
    --     self.personInFreeHouse:setColor(cc.c3b(242,245,50))
    --     self.personInFreeHouse:setPosition(cc.p(120, 0))
    --     iconUp:addChild(self.personInFreeHouse)
    -- end
    --room 新手场
    local noviceHouseButton = ccui.ImageView:create()
    noviceHouseButton:setTouchEnabled(true)
    noviceHouseButton:setPosition(chujiPos)
    bangLayer:addChild(noviceHouseButton)

    noviceHouseButton:loadTexture("blank.png")
    noviceHouseButton:setScale9Enabled(true);
    noviceHouseButton:setContentSize(cc.size(240,250));
    local iconUp = ccui.ImageView:create("hall/room/roombutton1.png")
    iconUp:addTo(noviceHouseButton):align(display.CENTER, 120, 125)
    -- iconUp:setScale(0.8)

    --TODO
    noviceHouseButton:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.began then
            noviceHouseButton:setScale(1.1)
        elseif eventType == ccui.TouchEventType.ended then
            noviceHouseButton:setScale(1.0)
            self:onEnterRoom(1)
        elseif eventType == ccui.TouchEventType.canceled then
            noviceHouseButton:setScale(1.0)
        end
    end)

    local particle = cc.ParticleSystemQuad:create("particle/lizi_chang_lv.plist")
    -- particle:setScale(1.5)
    -- particle:setEmissionRate(2)
    particle:addTo(iconUp):align(display.CENTER, 120, 129)

    local bgSprite = EffectFactory:getInstance():getGirlsArmature("ani_girl_1", 1)
    bgSprite:align(display.CENTER, 120, 50);
    bgSprite:setScale(0.80)
    bgSprite:setScaleX(-0.8)
    iconUp:addChild(bgSprite);

    display.newSprite("hall/room/word_xinshou.png", 120, 35):addTo(iconUp)

    display.newSprite("hall/room/green_dot.png", 80, 0):addTo(iconUp)

    self.personInNoviceHouse = ccui.Text:create()
    self.personInNoviceHouse:setString("130人")
    self.personInNoviceHouse:setFontSize(26)
    self.personInNoviceHouse:setColor(cc.c3b(242,245,50))
    self.personInNoviceHouse:setPosition(cc.p(120, 0))
    iconUp:addChild(self.personInNoviceHouse)

    if showMask then
        local btnMask = ccui.Button:create("hall/room/roomMask.png","hall/room/roomMask.png");
        btnMask:setPosition(cc.p(120, 120));
        btnMask:addTouchEventListener(
            function(sender,eventType)
                if eventType == ccui.TouchEventType.ended then
                    self:onClickMask()
                end
            end
        )
        iconUp:addChild(btnMask);
        local roomLock = ccui.ImageView:create("hall/room/roomLock.png")
        roomLock:setPosition(60,120)
        iconUp:addChild(roomLock);
        table.insert(self.showMaskArray,btnMask)
        table.insert(self.showMaskArray,roomLock)
    end

    --room 高级场
    local seniorHouseButton = ccui.ImageView:create()
    seniorHouseButton:setTouchEnabled(true)
    seniorHouseButton:setPosition(cc.p(585,200))
    bangLayer:addChild(seniorHouseButton)

    seniorHouseButton:loadTexture("blank.png")
    seniorHouseButton:setScale9Enabled(true);
    seniorHouseButton:setContentSize(cc.size(240, 250));
    local iconUp = ccui.ImageView:create("hall/room/roombutton2.png")
    iconUp:addTo(seniorHouseButton):align(display.CENTER,120, 125)
    -- iconUp:setScale(0.8)

    local particle = cc.ParticleSystemQuad:create("particle/lizi_chang_lan.plist")
    -- particle:setScale(1.5)
    -- particle:setEmissionRate(2)
    particle:addTo(iconUp):align(display.CENTER, 120, 129)

    local bgSprite = EffectFactory:getInstance():getGirlsArmature("ani_girl_2", 1)
    bgSprite:align(display.CENTER, 120, 45);
    bgSprite:setScale(0.9)
    iconUp:addChild(bgSprite);

    display.newSprite("hall/room/word_gaoji.png", 120, 35):addTo(iconUp)

    display.newSprite("hall/room/green_dot.png", 80, 0):addTo(iconUp)

    seniorHouseButton:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.began then
            seniorHouseButton:setScale(1.1)
        elseif eventType == ccui.TouchEventType.ended then
            seniorHouseButton:setScale(1.0)
            self:onEnterRoom(2)
        elseif eventType == ccui.TouchEventType.canceled then
            seniorHouseButton:setScale(1.0)
        end
    end)
    self.personInSeniorHouse = ccui.Text:create()
    self.personInSeniorHouse:setString("1230人")
    self.personInSeniorHouse:setFontSize(26)
    self.personInSeniorHouse:setColor(cc.c3b(242,245,50))
    self.personInSeniorHouse:setPosition(cc.p(120, 0))
    iconUp:addChild(self.personInSeniorHouse)

    if showMask then
        local btnMask = ccui.Button:create("hall/room/roomMask.png","hall/room/roomMask.png");
        btnMask:setPosition(cc.p(120, 120));
        btnMask:addTouchEventListener(
            function(sender,eventType)
                if eventType == ccui.TouchEventType.ended then
                    self:onClickMask()
                end
            end
        )
        iconUp:addChild(btnMask);
        local roomLock = ccui.ImageView:create("hall/room/roomLock.png")
        roomLock:setPosition(60,120)
        iconUp:addChild(roomLock);
        table.insert(self.showMaskArray,btnMask)
        table.insert(self.showMaskArray,roomLock)
    end
    --room 豪华场
    local luxuryHouseButton = ccui.ImageView:create()
    luxuryHouseButton:setTouchEnabled(true)
    luxuryHouseButton:loadTexture("blank.png")
    luxuryHouseButton:setScale9Enabled(true);
    luxuryHouseButton:setContentSize(cc.size(240,250));
    luxuryHouseButton:setPosition(cc.p(850, 200))
    bangLayer:addChild(luxuryHouseButton)

    local iconUp = ccui.ImageView:create("hall/room/roombutton3.png")
    iconUp:addTo(luxuryHouseButton):align(display.CENTER,120, 125)
    -- iconUp:setScale(0.8)

    luxuryHouseButton:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.began then
            luxuryHouseButton:setScale(1.1)
        elseif eventType == ccui.TouchEventType.ended then
            luxuryHouseButton:setScale(1.0)
            self:onEnterRoom(3)
        elseif eventType == ccui.TouchEventType.canceled then
            luxuryHouseButton:setScale(1.0)
        end
    end)

    local particle = cc.ParticleSystemQuad:create("particle/lizi_chang_zi.plist")
    -- particle:setScale(1.5)
    -- particle:setEmissionRate(2)
    particle:addTo(iconUp):align(display.CENTER, 120, 129)

    local bgSprite = EffectFactory:getInstance():getGirlsArmature("ani_girl_3", 1)
    bgSprite:align(display.CENTER, 120, 60);
    bgSprite:setScale(0.8)
    iconUp:addChild(bgSprite);

    display.newSprite("hall/room/word_haohua.png", 120, 35):addTo(iconUp)

    display.newSprite("hall/room/green_dot.png", 80, 0):addTo(iconUp)

    self.personInLuxuryHouse = ccui.Text:create()
    self.personInLuxuryHouse:setString("1230人")
    self.personInLuxuryHouse:setFontSize(26)
    self.personInLuxuryHouse:setColor(cc.c3b(242,245,50))
    self.personInLuxuryHouse:setPosition(cc.p(120, 0))
    iconUp:addChild(self.personInLuxuryHouse)
    if showMask then
        local btnMask = ccui.Button:create("hall/room/roomMask.png","hall/room/roomMask.png");
        btnMask:setPosition(cc.p(120, 120));
        btnMask:addTouchEventListener(
            function(sender,eventType)
                if eventType == ccui.TouchEventType.ended then
                    self:onClickMask()
                end
            end
        )
        iconUp:addChild(btnMask);
        local roomLock = ccui.ImageView:create("hall/room/roomLock.png")
        roomLock:setPosition(60,120)
        iconUp:addChild(roomLock);
        table.insert(self.showMaskArray,btnMask)
        table.insert(self.showMaskArray,roomLock)
    end
end
function RoomScene:onClickMask()
    -- body
end
function RoomScene:createActivityButtons()
    local bangLayer = ccui.Layout:create()
    bangLayer:setPosition(0, 0)
    self.bottomPageView:addChild(bangLayer)

    local jishaochengduoButton = ccui.ImageView:create()
    jishaochengduoButton:setTouchEnabled(true)
    jishaochengduoButton:loadTexture("hall/room/icon_jishaochengduo.png")
    -- jishaochengduoButton:setScale9Enabled(true);
    -- jishaochengduoButton:setContentSize(cc.size(240,250));
    jishaochengduoButton:setPosition(cc.p(1050, 500))
    bangLayer:addChild(jishaochengduoButton)

    jishaochengduoButton:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.began then
            jishaochengduoButton:setScale(1.1)
        elseif eventType == ccui.TouchEventType.ended then
            jishaochengduoButton:setScale(1.0)
            self:onClickJIShaoChengDuo()
        elseif eventType == ccui.TouchEventType.canceled then
            jishaochengduoButton:setScale(1.0)
        end
    end)

    local posx = {{1000, 540, 0.6}, {1050, 450,0.9}, {1030, 470, 0.7}, {1060, 500, 0.6}, {1020, 510, 0.7}, {1070, 530, 1.1}, {1080, 470, 0.8}, {1090, 540, 1}}
    local randomarr = {}
    local tem = {1,1.0,1}
    randomarr[1] = tem
    local tem = {1.2,1.2,1.1}
    randomarr[2] = tem
    local tem = {1.3,1.1,1.3}
    randomarr[3] = tem
    local tem = {1.4,1.3,1.2}
    randomarr[4] = tem
    local tem = {1.5,1.4,1.4}
    randomarr[5] = tem
    local tem = {0.9,1.5,1.5}
    randomarr[6] = tem
    local tem = {0.8,1.3,1.3}
    randomarr[7] = tem
    local tem = {0.7,1.2,1.2}
    randomarr[8] = tem

    for i, pos in ipairs(posx) do
        math.randomseed(tostring(os.time()):reverse():sub(1, 9))
        local star = EffectFactory:createOneBreathStar(pos[1], pos[2], pos[3], randomarr[i])
        bangLayer:addChild(star)
    end
end

function RoomScene:addText(target, text)
    local bangtext = ccui.Text:create(text, FONT_ART_TEXT,24)
    bangtext:setPosition(cc.p(46, -5))
    bangtext:setTextColor(cc.c4b(251,233,16,255))
    bangtext:enableOutline(cc.c4b(93,44,12,200), 3)
    target:addChild(bangtext)
end

function RoomScene:registerGameEvent()

    self.bindIds = {}   
    self.bindIds[#self.bindIds + 1] = BindTool.bind(AccountInfo, "userId", handler(self, self.setSelfInfo))
    self.bindIds[#self.bindIds + 1] = BindTool.bind(AccountInfo, "userInfoChange", handler(self, self.onUserInfoChanged))   
    self.bindIds[#self.bindIds + 1] = BindTool.bind(AccountInfo, "bindingInfo", handler(self, self.refreshRoomMask)) 
    self.bindIds[#self.bindIds + 1] = BindTool.bind(AccountInfo, "scoreInfoAccount", handler(self, self.refreshMyGold))--推送用户分数时，刷新
    self.bindIds[#self.bindIds + 1] = BindTool.bind(RoomInfo, "loginResult", handler(self, self.loginRoomResult))

    self.bindIds[#self.bindIds + 1] = BindTool.bind(RoomInfo, "ServerConfig", handler(self, self.roomConfigResult))
    self.bindIds[#self.bindIds + 1] = BindTool.bind(RoomInfo, "userInfoList", handler(self, self.onUserInfoList))
    self.bindIds[#self.bindIds + 1] = BindTool.bind(DataManager, "tabelStatuChange", handler(self, self.onTableStatusChange))
    self.bindIds[#self.bindIds + 1] = BindTool.bind(FishInfo, "gameConfig", handler(self, self.onReceiveFishGameConfig))

    self.bindIds[#self.bindIds + 1] = BindTool.bind(RankingInfo, "wealthRankList", handler(self, self.onRequestWealthRankingResult));
    self.bindIds[#self.bindIds + 1] = BindTool.bind(MatchInfo, "userMatchInfo", handler(self, self.onRequestUserMatchInfo));
    -- self.bindIds[#self.bindIds + 1] = BindTool.bind(RankingInfo, "loveLinessList", handler(self, self.onRequestWealthRankingResult));


    self.connected_handler = GameConnection:addEventListener(NetworkManagerEvent.SOCKET_CONNECTED, handler(self, self.onSocketStatus))
end
function RoomScene:onRequestUserMatchInfo()

    DateModel:getInstance():setTableID(MatchInfo.userMatchInfo.tableID)
    DateModel:getInstance():setChairID(MatchInfo.userMatchInfo.chairID)
    DateModel:getInstance():setCurrentMatchServerID(MatchInfo.userMatchInfo.serverID)
    self.competeRoom =  true
    DateModel:getInstance():setIsCompeteRoom(true)
    local serverItem = ServerInfo:getServerItemByServerID(MatchInfo.userMatchInfo.serverID)
    print("开始连接比赛场",MatchInfo.userMatchInfo.serverID,MatchInfo.userMatchInfo.tableID,MatchInfo.userMatchInfo.chairID)

    self.roomAddr = serverItem.serverAddr
    if string.len(ServerHostBackUp) > 0 then
        self.roomAddr = ServerHostBackUp
    end
    self.roomPort = serverItem.serverPort
    GameConnection:connectServer(self.roomAddr, self.roomPort)--1300--self.roomPort
    RunTimeData:setCurGameServer(serverItem)
    -- RunTimeData:setCurGameNode(self.room_node_id[index])
    RunTimeData:setRoomIndex(1)
    -- dump(serverItem, "serverItem")

    -- local ZhajinhuaScene = require("zhajinhua.ZhajinhuaScene_New")
    -- cc.Director:getInstance():replaceScene(cc.TransitionSlideInT:create(0.5, ZhajinhuaScene.new()))
end
function RoomScene:removeGameEvent()
    
    for _, bindid in ipairs(self.bindIds) do
        BindTool.unbind(bindid)
    end
    GameConnection:removeEventListener(self.connected_handler)
end

function RoomScene:onClickBank()

    -- local firstRegisterLayer = require("hall.FirstRegisterLayer").new()
    --     self.container:addChild(firstRegisterLayer)

    local bank = require("hall.BankLayer").new(false);
    bank:setPosition(0,0)
    self.container:addChild(bank);

    Click();
end

function RoomScene:onClickJIShaoChengDuo()
    local bank = require("hall.huodong.JiShaoChengDuo").new(self);
    self.container:addChild(bank);
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
    --保存commonjs
    local activityManager = require("data.ActivityManager"):getInstance()
    activityManager:saveCommonJs()
    activityManager:callActivityWebView()
end

function RoomScene:onClickFreeChip()
    local model = "iphone"
    if device.platform == "android" then model = "android" end
    -- local url = "http://42.121.109.138/hall/freeChip.php?uid="..DataManager:getMyUserID().."&os="..device.platform.."&model="..model..",1&source="..APP_CHANNEL.."&ver="..getAppVersion().."&kid=6&uuid="..GetDeviceID()
    local url = "http://activity.game100.cn/hall/index/index?sessionid="..AccountInfo.sessionId--"http://activity.game100.cn/hall/index/index"
    print(url)
    openPortraitWebView(url)
    -- FreeChip(url)
    Click();
end

function RoomScene:onClickPersonalCenter()

    local personalCenter = require("hall.PersonalCenterLayer_New").new();
    self.container:addChild(personalCenter);

    Click();
end

function RoomScene:onClickBuy()
    --TODO buy something
    print("onClickBuy")
    if true == PlatformGetChannel() then
        if AppChannel == "CMCC" then
            kind = 3
        elseif AppChannel == "CTCC" then
            kind = 5
        end
    end
    
    local buy = require("hall.ShopLayer_New").new(2)
    buy:setPurchaseCallBack(self,function()
        self:showAppRestorePurchaseLayer()
    end)
    -- buy:addEventListener(HallCenterEvent.EVENT_SHOW_RESTORELAYER, handler(self, self.showAppRestorePurchaseLayer))

    self.container:addChild(buy)

    Click();
end

function RoomScene:showAppRestorePurchaseLayer()
    print("showAppRestorePurchaseLayer",tostring(self))
    local appRestorePurchaseLayer = require("hall.AppRestorePurchaseLayer").new()
    self.container:addChild(appRestorePurchaseLayer)
end

function RoomScene:onRequestWealthRankingResult()
    -- if true then
    --     return
    -- end
    -- 获取排行榜数据
    local rankingArray
    if self.rankType == 1 then
        rankingArray = RankingInfo.wealthRankList
    elseif self.rankType == 2 then
        rankingArray = RankingInfo.loveLinessList
    end
    -- 如果排行榜没有数据，那么发送获取排行榜数据请求
    if(rankingArray == nil or #rankingArray == 0) then
        if rankingArray then
            print("#rankingArray",#rankingArray)
        end
    else
        self.listView:removeAllItems()
        local count = #rankingArray
        -- 添加自定义item
        for i = 1, count do
            local bangItemLayer = ccui.ImageView:create()
            bangItemLayer:loadTexture("hall/rank/list_item_bg.png")
            bangItemLayer:ignoreAnchorPointForPosition(true)
            bangItemLayer:setName("ListItem")
            bangItemLayer:setTag(i)

            -- local itemRankLabel = ccui.Text:create("",FONT_ART_TEXT,38)
            -- itemRankLabel:setTextColor(cc.c4b(140,58,0,255))
            -- itemRankLabel:setPosition(cc.p(40,40))
            -- --itemRankLabel:enableOutline(cc.c4b(140,58,0,200), 3)
            -- bangItemLayer:addChild(itemRankLabel)
            -- itemRankLabel:setName("itemRankLabel")

            -- 人物头像图片
            local itemHead = require("commonView.HeadView").new(1);
            itemHead:setName("ItemHead")
            bangItemLayer:addChild(itemHead)
            itemHead:setPosition(cc.p(54,47))
            itemHead:setScale(0.85)

            if i < 4 then
                local hvip = "hall/rank/rank"..i.."_icon.png"
                local vspr = display.newSprite(hvip)
                vspr:setPosition(cc.p(80, 80))
                bangItemLayer:addChild(vspr)

                -- 排名图片
                local itemRankImage = ccui.ImageView:create()
                itemRankImage:loadTexture("hall/rank/hall_bang_"..i..".png")
                itemRankImage:setAnchorPoint(cc.p(1,0.5))
                itemRankImage:setPosition(cc.p(400,83))
                bangItemLayer:addChild(itemRankImage)
                itemRankImage:setName("itemRankImage")
            

                local rakn = "hall/rank/ranknum"..i..".png"
                local raknumbg = display.newSprite(rakn)
                raknumbg:setPosition(cc.p(80, 20))
                -- raknumbg:setScale(6)
                -- raknumbg:setOpacity(150)
                bangItemLayer:addChild(raknumbg)

                -- local rannum = ccui.Text:create(i, FONT_ART_TEXT, 30)
                -- rannum:setTextColor(cc.c4b(255, 255, 255,255))
                -- rannum:setAnchorPoint(cc.p(0.5,0.5))
                -- rannum:setPosition(cc.p(80, 20))
                -- rannum:enableOutline(cc.c4b(0,44,12,250), 1)
                -- bangItemLayer:addChild(rannum)
            end

            -- 名字
            local itemName = ccui.Text:create("名字名字",FONT_ART_TEXT, 24)
            itemName:setTextColor(cc.c4b(255, 255, 255, 255))
            itemName:setAnchorPoint(cc.p(0,0.5))
            itemName:setPosition(cc.p(110,76))
            itemName:enableOutline(cc.c4b(58,20,5,255), 2)
            bangItemLayer:addChild(itemName)
            itemName:setName("ItemName")
            -- 筹码
            local itemScore = ccui.Text:create("",FONT_ART_TEXT,24)
            itemScore:setTextColor(cc.c4b(255,249,14,255))
            itemScore:setAnchorPoint(cc.p(0,0.5))
            itemScore:setPosition(cc.p(145,45))
            itemScore:enableOutline(cc.c4b(65,39,11,255), 2)
            bangItemLayer:addChild(itemScore)
            itemScore:setName("ItemScore")
            if self.rankType == 1 then
                local icon = display.newSprite("common/chouma_icon.png");
                icon:setPosition(cc.p(125, 45))
                icon:setScale(0.55);
                bangItemLayer:addChild(icon)
            elseif self.rankType == 2 then
                local icon = display.newSprite("common/loveliness.png");
                icon:setPosition(cc.p(125, 45))
                icon:setScale(0.55);
                bangItemLayer:addChild(icon)
            end
            --签名
            local itemUnderWrite = ccui.Text:create("没有签名",FONT_ART_TEXT,20)
            itemUnderWrite:setTextColor(cc.c4b(255,255,255,255))
            itemUnderWrite:setAnchorPoint(cc.p(0,0.5))
            itemUnderWrite:setPosition(cc.p(110,17))
            itemUnderWrite:enableOutline(cc.c4b(84,53,20,255), 1)
            bangItemLayer:addChild(itemUnderWrite)
            itemUnderWrite:setName("itemUnderWrite")     

            local custom_item = ccui.Layout:create()
            custom_item:setTouchEnabled(true)
            custom_item:setContentSize(cc.size(427, 120))
            bangItemLayer:setPosition(5, 10)
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
            -- local itemRankLabel = itemLayer:getChildByName("itemRankLabel")
            -- 人物头像图片
            local itemHead = itemLayer:getChildByName("ItemHead")
            -- 名字
            local itemName = itemLayer:getChildByName("ItemName")
            -- 筹码
            local itemScore = itemLayer:getChildByName("ItemScore")
            --签名
            local itemUnderWrite = itemLayer:getChildByName("itemUnderWrite")

            -- itemRankLabel:setString(i)
            -- 排名前三的显示奖杯
            local jaingbeiImage = {"hall/rank/hall_bang_1.png","hall/rank/hall_bang_2.png",
                "hall/rank/hall_bang_3.png"}
            if self.rankType == 2 then
                jaingbeiImage = {"hall/rank/hall_loveliness_1.png","hall/rank/hall_loveliness_2.png",
                "hall/rank/hall_loveliness_3.png"}
            end

            if i <= 3 and itemRankImage then
                itemRankImage:loadTexture(jaingbeiImage[i])

                local seq = transition.sequence(
                        {
                            cc.FadeTo:create(4, 200),
                            cc.FadeTo:create(3, 255)
                        }
                    )
                itemRankImage:runAction(cc.RepeatForever:create(seq))
            end

            local nickName = FormotGameNickName(itemInfo.nickName,6)
            itemName:setString(nickName)
            
            
            
            if self.rankType == 1 then
                itemScore:setString(FormatNumToString(itemInfo.score))

            elseif self.rankType == 2 then
                itemScore:setString(FormatNumToString(itemInfo.loveLiness))
            end
            itemUnderWrite:setString(FormotGameNickName(itemInfo.signature,12))
        --print("faceID==",itemInfo:faceID()," getTokenID",itemInfo:getTokenID()," nickname",itemInfo:getNickName()," userID",itemInfo:getUserID())

            itemHead:setNewHead(itemInfo.faceID, itemInfo.platformID, itemInfo.platformFace)
            -- if itemInfo:faceID() >= 1 and itemInfo:faceID() <= 37 then
            --     itemHead:loadTexture("head/head_"..itemInfo:faceID()..".png")

            -- elseif itemInfo:faceID() == 999 and itemInfo:getTokenID() then
            --     local imageName = RunTimeData:getLocalAvatarImageUrlByTokenID(itemInfo:getTokenID())
            --     local localmd5 = cc.Crypto:MD5File(imageName)
            --     print("排行榜=====","localmd5", localmd5,"headFile", itemInfo:getHeadFile(), "is_file_exists(imageName)", is_file_exists(imageName))
            --     if is_file_exists(imageName) and localmd5 == itemInfo:getHeadFile() then
            --         head = itemHead:loadTexture(imageName)

            --     else
            --         head = itemHead:loadTexture("head/default.png")

            --         PlatformDownloadAvatarImage(itemInfo:getTokenID(),itemInfo:getHeadFile())
            --     end
            -- else

            --     itemHead:loadTexture("head/default.png")

            -- end

        end
    end
end

-- 业务逻辑
--kindid : 6  
--nodeid  初级场300,中级场301,高级场302，富豪场303, 转正场304
function RoomScene:refreshGameOnlineCount()

    --新手场
    local onlineCount1 = ServerInfo:getOnlineCountByGameNodeID(self.wCurKind, 300)
    if self.personInNoviceHouse then
        self.personInNoviceHouse:setString(onlineCount1.."人")
    end
    --高级场
    local onlineCount2 = ServerInfo:getOnlineCountByGameNodeID(self.wCurKind, 301)
    if self.personInSeniorHouse then
        self.personInSeniorHouse:setString(onlineCount2.."人")
    end
    --豪华场
    local onlineCount3 = ServerInfo:getOnlineCountByGameNodeID(self.wCurKind, 303)
    if self.personInLuxuryHouse then
        self.personInLuxuryHouse:setString(onlineCount3.."人")
    end

    local onlineCount4 = ServerInfo:getOnlineCountByGameNodeID(self.wCurKind, 304)
    if self.personInFreeHouse then
        self.personInFreeHouse:setString(onlineCount4.."人")
    end
end
function RoomScene:refreshMyGold()
    print("领取救济金")
    self:performWithDelay(function (  )

        local myInfo = DataManager:getMyUserInfo()
        -- if(myInfo ~= nil) then

            self.goldValueText2:setString(FormatNumToString(AccountInfo.score))

        -- end
    end, 2)
end
--数据更新
function RoomScene:setSelfInfo()
    -- 顶部设置自己的属性
    local myInfo = DataManager:getMyUserInfo()
    -- if(myInfo ~= nil) then
        local nickName = FormotGameNickName(AccountInfo.nickName,8)
        self.nickNameText:setString(nickName)
        -- self.goldValueText:setString(FormatNumToString(myInfo:beans()))
        self.goldValueText2:setString(FormatNumToString(AccountInfo.score))
        -- self.couponTxt:setString(FormatNumToString(AccountInfo:getCoupon()))
        -- self.headImage:setNewHead(AccountInfo.faceId, AccountInfo.cy_userId, AccountInfo.headFileMD5)
        self.headImage:setNewHead(myInfo.faceID, myInfo.platformID, myInfo.platformFace)
        self.headImage:setVipHead(AccountInfo.memberOrder)

        local levelStr = "LV."..getLevelByExp(AccountInfo.medal)
        self.levelText:setString(levelStr)

    -- end
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

function RoomScene:bankSucceseHandler(event)
   print("bankSucceseHandler")
    local info = event--protocol.hall.treasureInfo_pb.CMD_GP_UserInsureSuccess_Pro();
   -- info:ParseFromString(event.data)
    -- self.qu1:setString(FormatNumToString(info.lUserInsure))
    -- self.cun1:setString(FormatNumToString(info.lUserScore));
    -- self.bankmoney:setString(FormatNumToString(info.insure))
   -- Hall.showTips(info.lUserInsure)
end

function RoomScene:onFirstRegister()
    if firstModifyNickname == 1 then
        local firstRegisterLayer = require("hall.FirstRegisterLayer").new()
        self.container:addChild(firstRegisterLayer)
        firstModifyNickname = 0
    end
end
-- 连接房间
function RoomScene:connectToRoom(kindID,section,roomIndex)
    print("-----connectToRoom--------", kindID,section,roomIndex)
    local listData = ServerListDataManager:achieveServerListDataByGameKindID(kindID)
    local gameServer = listData:getGameServer(section,roomIndex)
    if gameServer == nil then
        print("没有房间!!")
        return
    end
    local info = PlayerInfo
    if (info ~= nil) then
        info:clearAllUserInfo()
    end
    RunTimeData:setCurGameServer(gameServer)
    RunTimeData:setRoomIndex(section)
    print("gameServer:getServerAddr(),gameServer:getServerPort()==",gameServer:getServerAddr(),gameServer:getServerPort())
    GameCenter:connectRoomServer(gameServer:getServerAddr(),gameServer:getServerPort())
    Hall.showWaiting(15)
    self.roomInfo = {["kindid"] = kindID, ["section"] = section, ["roomindex"]=roomIndex}
end
--判断房间进入限制
function RoomScene:checkRoomRestrict(gameServer)
    local result = false
    --print("checkRoom",gameServer:getMaxEnterScore(),gameServer:getMinEnterScore(),gameServer:getMinTableScore())
    if PlayerInfo:getMyUserInfo():score() >= gameServer:getMinEnterScore()then
        result = true
    end
    return result
end
 ----------------接受数据后的处理---------
function RoomScene:onSocketStatus(event)
    print(".... RoomScene:enterRoomRequest back ...............")
    if event.name == NetworkManagerEvent.SOCKET_CONNECTED then
        RoomInfo:sendLoginRequest(0, 60)
    elseif event.name == NetworkManagerEvent.SOCKET_CLOSED then
        
    elseif event.name == NetworkManagerEvent.SOCKET_CONNECTE_FAILURE then
        
    end
end
--登陆返回结果，不一定成功
function RoomScene:loginRoomResult(event)
    if RoomInfo.loginResult == false then
        print("------登陆房间失败，code:", RoomInfo.loginResultCode)
        -- RoomInfo:sendLogoutRequest()
        self:performWithDelay(function() GameConnection:closeConnect() end, 0.1)
    end
end

function RoomScene:onTableStatusChange(event)
    print("------RoomScene:onTableStatusChange:", DataManager.myUserInfo.userStatus)
    -- if DataManager.myUserInfo.userStatus == US_PLAYING then
    --     TableInfo:sendGameOptionRequest(true)
    -- else
    --     --1表示默认进入某个场(免费、激情、VIP)的第一个房间的第一个桌子
    --     local room = require("layer.roomLayer").new(self.roomIndex,1,1);
    --     display.replaceScene(room:scene());
    -- end
end

function RoomScene:onReceiveFishGameConfig(event)
    -- local gameLayer = require("layer.gameLayer").new();
    -- display.replaceScene(gameLayer:scene());
end
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
function RoomScene:roomConfigResult()
    print("RoomScene:roomConfigResult!!")
end
--登录房间后收到房间里的用户信息
function RoomScene:onUserInfoList()
    print("RoomScene:onUserInfoList!!")
    self:enterGame(event)
end
function RoomScene:enterGame(event)
    print("enterGame!!","competeRoom",self.competeRoom,"BindMobilePhone",BindMobilePhone,"getAutoSitDown",DateModel:getInstance():getAutoSitDown())
    if DateModel:getInstance():getAutoSitDown() or self.competeRoom then
        -- local result = false
        -- local gameServer = RunTimeData:getCurGameServer()
        -- if gameServer then
        --     if PlayerInfo:getMyUserInfo():score()>=gameServer:getMinEnterScore() then
        --         result = true
        --     end
        -- end
        -- if result == false then
        --     Hall.showTips("很遗憾，您的筹码不足，至少需要"..gameServer:getMinEnterScore().."才能加入游戏!", 1)
        --     return
        -- end
        if self.competeRoom == false then
            DateModel:getInstance():setTableID(65535)
            DateModel:getInstance():setChairID(65535)
        end
        local ZhajinhuaScene = require("zhajinhua.ZhajinhuaScene_New")
        cc.Director:getInstance():replaceScene(cc.TransitionSlideInT:create(0.5, ZhajinhuaScene.new()))
    else
        if BindMobilePhone == false then
            local ZhajinhuaScene = require("zhajinhua.ZhajinhuaScene_New")
            cc.Director:getInstance():replaceScene(cc.TransitionSlideInT:create(0.5, ZhajinhuaScene.new()))
        else
            if RunTimeData:getRoomIndex() == 1 then
                DateModel:getInstance():setTableID(65535)
                DateModel:getInstance():setChairID(65535)
                local ZhajinhuaScene = require("zhajinhua.ZhajinhuaScene_New")
                cc.Director:getInstance():replaceScene(cc.TransitionSlideInT:create(0.5, ZhajinhuaScene.new()))
            else
                local myUserStatus = DataManager:getMyUserStatus()
                -- print("我的用户状态",myUserStatus,Define.US_PLAYING,DataManager:getMyTableID(),DataManager:getMyChairID())
                if myUserStatus == Define.US_PLAYING then
                    DateModel:getInstance():setTableID(DataManager:getMyTableID())
                    DateModel:getInstance():setChairID(DataManager:getMyChairID())
                    local ZhajinhuaScene = require("zhajinhua.ZhajinhuaScene_New")
                    cc.Director:getInstance():replaceScene(cc.TransitionSlideInT:create(0.5, ZhajinhuaScene.new()))
                else
                    local selectTableScene = require("hall.SelectTableScene_New")
                    cc.Director:getInstance():replaceScene(cc.TransitionSlideInT:create(0.5, selectTableScene.new(RunTimeData:getRoomIndex())))
                end
            end
        end

    end

    RunTimeData:setPopFrom(1)
    self:removeGameEvent()
end

function RoomScene:getTodayWasNotPaySuccess(event)
    if self.checkTime == nil then
        return
    end
    print("getTodayWasNotPaySuccess")
    local info = protocol.hall.treasureInfo_pb.CMD_GP_QueryTodayWasnotPayResult_Pro();
    info:ParseFromString(event.data)
    self.checkTime = self.checkTime + 1
    local key = {194,188,189}
    self.checkValue[info.szPayId] = info.dwWasTodayPayed--//今天充值过吗 0:没有 1:已经充值过
    if self.checkTime >= 3 then
        local firstPayKind = 3
        if self.checkValue["189"]==0 then
            firstPayKind = 3
        end
        if self.checkValue["188"]==0 then
            firstPayKind = 2
        end
        if self.checkValue["194"]==0 then
            firstPayKind = 1
        end
        local tips = require("hall.FirstPayGiftLayer").new(firstPayKind,1,self.tipStr)
        self.container:addChild(tips)
        self.checkTime = nil
        print("self.checkTime >= 3")
    end
end

function RoomScene:onConnectRoomErrHandler(event)

    self.viewPlayExit = require("commonView.ViewConfirmLayer").new(
        {ok=function() self:connectToRoom(self.roomInfo.kindid, self.roomInfo.section, self.roomInfo.roomindex) end, cancel = function() self.viewPlayExit:removeSelf() end, desc=event.errDesc})

    self.viewPlayExit:addTo(self.container, 999)

end

function RoomScene:onReceiveSystemMessage(event)
    if event.type==GameMessageType.CLOSE_GAME and event.msg then
        print("RoomScene:onReceiveSystemMessage!")
        
        Hall.printKind = 1
        Hall.hideWaiting()
        Hall.showTips(event.msg.szString, 3.0)
        GameCenter:closeRoomSocketDelay(1.0)
    end
end

function RoomScene:onExchangeCallBack(event)

    if event.subId == CMD_LogonServer.SUB_GP_EXCHANGE_BEANS_SUCCESS then--
        print("SUB_GP_EXCHANGE_BEANS_SUCCESS---------OK")
        local exchangeSuccess = protocol.hall.treasureInfo_pb.CMD_GP_ExchangeBeansSuccess_Pro()
        exchangeSuccess:ParseFromString(event.data)
        
        
        local myInfo = PlayerInfo:getMyUserInfo()
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

    -- if event.subId == CMD_LogonServer.SUB_GP_OPERATE_SUCCESS then--操作成功
    --     self:setSelfInfo()
        
    --     -- UserService:sendQueryInsureInfo()
    -- elseif event.subId == CMD_LogonServer.SUB_GP_USER_FACE_INFO then --头像修改成功
    --     self:setSelfInfo()
    -- end
    self:setSelfInfo()
    if 1 then
        return
    end
    --检查排行榜中有没有自己，有了刷新一下排行榜
    --查询所有房间 的在线人数
    local rankingArray1 = RankingInfo.wealthRankList
    local rankingArray2 = RankingInfo.loveLinessList

    local refreshRank = false
    local myInfo = DataManager:getMyUserInfo()
    for _, ruserinfo in pairs(rankingArray1) do
        if ruserinfo:getUserID() == myInfo:userID() then print("--财富榜找到了玩家自己---")
            ruserinfo:setNickName(myInfo:getNickName())
            ruserinfo:setUnderWrite(myInfo:getUnderWrite())
            ruserinfo:setHeadFile(myInfo:getHeadFile())
            ruserinfo:setFaceID(myInfo:faceID())
            refreshRank = true
            break;
        end
    end

    for _, ruserinfo in pairs(rankingArray2) do
        if ruserinfo:getUserID() == myInfo:userID() then print("--魅力榜找到了玩家自己---")
            ruserinfo:setNickName(myInfo:getNickName())
            ruserinfo:setUnderWrite(myInfo:getUnderWrite())
            ruserinfo:setHeadFile(myInfo:getHeadFile())
            ruserinfo:setFaceID(myInfo:faceID())
            refreshRank = true
            break;
        end
    end

    if refreshRank == true then
        print("--玩家信息在排行榜中，玩家信息改变，刷新排行榜----")
        self:onRequestWealthRankingResult()
    end


end

function RoomScene:marriageInfoHandler(event)
    
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

function RoomScene:systemNoticeHandler(event)
    print("==========RoomScene:systemNoticeHandler", event.szString)
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
    self.checkTime = 0
    self.checkValue = {["194"]=0,["188"]=0,["189"]=0}

    
    UserService:sendQueryHasBuyGoldByKind("194");
    UserService:sendQueryHasBuyGoldByKind("188");
    UserService:sendQueryHasBuyGoldByKind("189");
    print("checkHasBuyGold")
end

function RoomScene:receiveGoldBackHandler( event )
    print("!!!!!!!!!!!!!receiveGoldBackHandler!!!!!!!!!!")
    local result = event.data.dwResultCode--结果 0成功 其他=失败
    if result == 0 then
        local gold =  event.data.dwReceiveVaule
        if event.data.dwReceiveType == 1 then
            local myInfo = PlayerInfo:getMyUserInfo()
            myInfo:setbeans(myInfo:beans()+gold)
            -- self.goldValueText:setString(FormatNumToString(myInfo:beans()))
            Hall.showTips("成功领取"..gold.."欢乐豆",1)
        end
        if event.data.dwReceiveType == 2 then
            
            UserService:sendQueryInsureInfo()
            Hall.showTips("成功领取"..gold.."筹码",1)
        end

    else
        Hall.showTips("领取失败",1)
    end
    
end

function RoomScene:gameMessageHandler(event)
    local pSystemMessage = protocol.room.game_pb.CMD_CM_SystemMessage_Pro()
    pSystemMessage:ParseFromString(event.data)
    
    local msgString = pSystemMessage.szString
    print("---大厅滚动消息--", msgString)
    --大厅滚动消息
    --self:showScrollMessage(msgString)
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

--下载头像回调
function RoomScene:customFaceUrlBackHandler(event)
    -- body
    print("customFaceUrlBackHandler下载头像回调event.url",event.url,"tokenID=",event.tokenID)

    -- local tokenID = PlayerInfo:getMyUserInfo():getTokenID()

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

function RoomScene:refreshRank(event)
    local tokenID = event.tokenID
    -- 获取排行榜数据
    local rankingArray
    if self.rankType == 1 then
        rankingArray = RankingInfo.wealthRankList
    elseif self.rankType == 2 then
        rankingArray = RankingInfo.loveLinessList
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
            itemHead:setNewHead(itemInfo.faceID, itemInfo.platformID, itemInfo.platformFace)
            
            -- local itemTokenID = itemInfo:getTokenID()

            -- if tokenID == itemTokenID then
            --     local imageName = RunTimeData:getLocalAvatarImageUrlByTokenID(itemInfo:getTokenID())
            --     -- print("下载头像排行榜=====","getTokenID",itemInfo:getTokenID(),"localmd5",localmd5,"headFile",itemInfo:getHeadFile(),"is_file_exists(imageName)",is_file_exists(imageName))
            --     local localmd5 = cc.Crypto:MD5File(imageName)
            --     if is_file_exists(imageName) and localmd5 == itemInfo:getHeadFile() then
                    
            --         self:performWithDelay(function (  )
            --             -- print("延迟加载头像",imageName)
            --            head = itemHead:loadTexture(imageName)
            --         end, 0)
            --     else
            --         head = itemHead:loadTexture("head/default.png")
                    
            --     end
            -- end

        end
    end
end

return RoomScene