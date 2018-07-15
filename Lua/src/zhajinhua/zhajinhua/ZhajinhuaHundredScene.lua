local ZhajinhuaHundredScene = class("ZhajinhuaHundredScene", require("ui.CCBaseScene_ZJH"))

local cardInfo = {
[0x01] = "方块A", [0x02] = "方块2", [0x03] = "方块3", [0x04] = "方块4", [0x05] = "方块5", [0x06] = "方块6", [0x07] = "方块7", [0x08] = "方块8", [0x09] = "方块9", [0x0A] = "方块10", [0x0B] = "方块J", [0x0C] = "方块Q", [0x0D]= "方块K",  
[0x11] = "梅花A", [0x12] = "梅花2", [0x13] = "梅花3", [0x14] = "梅花4", [0x15] = "梅花5", [0x16] = "梅花6", [0x17] = "梅花7", [0x18] = "梅花8", [0x19] = "梅花9", [0x1A] = "梅花10", [0x1B] = "梅花J", [0x1C] = "梅花Q", [0x1D]= "梅花K",
[0x21] = "红桃A", [0x22] = "红桃2", [0x23] = "红桃3", [0x24] = "红桃4", [0x25] = "红桃5", [0x26] = "红桃6", [0x27] = "红桃7", [0x28] = "红桃8", [0x29] = "红桃9", [0x2A] = "红桃10", [0x2B] = "红桃J", [0x2C] = "红桃Q", [0x2D]= "红桃K",
[0x31] = "黑桃A", [0x32] = "黑桃2", [0x33] = "黑桃3", [0x34] = "黑桃4", [0x35] = "黑桃5", [0x36] = "黑桃6", [0x37] = "黑桃7", [0x38] = "黑桃8", [0x39] = "黑桃9", [0x3A] = "黑桃10", [0x3B] = "黑桃J", [0x3C] = "黑桃Q", [0x3D]= "黑桃K", 
[0x4E] = "小王",  [0x4F] = "大王",
}

local LAYER_Z_ORDER = {
    Z_BG = 0,
    Z_TABLE = 1,
    Z_CARD = 2,
    Z_PLAYER = 3,--玩家头像
    
    Z_TABLEGOLD = 7,--4
    Z_CHIPLAYER = 5,
    Z_PLAYERINFOLAYER = 7,--玩家信息
    Z_PLAYER_LIST = 8,
    Z_CHAT = 8,
    Z_CHARTS = 8,
    Z_EFFECT = 9,
    Z_POPMSG = 10,
    Z_plusLAYER = 11,
    Z_BANK = 11,
    Z_KICKUSER = 12,
    Z_COMPETEOVER = 12,
    Z_CHANGECELL = 13,
}
require("zhajinhua.CMD_ZhajinhuaMsg_New")
require("zhajinhua.CMD_GameServer")
require("protocol.zhajinhua.zhajinhua_c2s_pb")
require("protocol.zhajinhua.zhajinhua_s2c_pb")

require("gameSetting.GameConfig")
require("business.GameLogic")
local EffectFactory = require("commonView.EffectFactory")
local DateModel = require("zhajinhua.DateModel")
function ZhajinhuaHundredScene:ctor()
    -- 根节点变更为self.container
    self.super.ctor(self)

    self.chairArry = {}
    self.playerState = {0,0,0,0,0}
    self.dropChairID = {}--已经放弃和比牌输掉的人
    self.showCardChairID = {}--结算时显示牌的人
    self.playerLeftToOpenCardChairID = {}--留下来开牌的人
    self.colorArray = {cc.c3b(253, 234, 109),cc.c3b(188,255,0),cc.c3b(79,214,254),cc.c3b(255,255,255)}
    self.targetUserIDArray = {}
    self.sendGiftUserIdArray = {} --送道具的目标人id
    --滚动消息数组
    self.scrollMessageArr = {}

    self.scrollMessageKindArr = {}

    self.allIn = false
    --背景
    local bgSprite = cc.Sprite:create()
    bgSprite:setTexture("hundredRoom/hundredPlayScene/bg.png")
    bgSprite:align(display.CENTER, DESIGN_WIDTH/2, DESIGN_HEIGHT/2)
    self.container:addChild(bgSprite)

    self:createUI()
end
function ZhajinhuaHundredScene:onEnter()
    self:registerEventListener()

end
function ZhajinhuaHundredScene:onExit()

end
function ZhajinhuaHundredScene:registerEventListener()
    self.bindIds = {}

    self.bindIds[#self.bindIds + 1] = BindTool.bind(RoomInfo, "userInfo", handler(self, self.onUserEnter));
    self.bindIds[#self.bindIds + 1] = BindTool.bind(TableInfo, "userStatus", handler(self, self.onUserStatusChange));
    self.bindIds[#self.bindIds + 1] = BindTool.bind(ZhajinhuaInfo, "mainID", handler(self, self.onServerMsgCallBack));
    self.bindIds[#self.bindIds + 1] = BindTool.bind(ZhajinhuaInfo, "data", handler(self, self.onServerMsgCallBack));
    self.bindIds[#self.bindIds + 1] = BindTool.bind(ZhajinhuaInfo, "recoverGameScene", handler(self, self.onServerGameScene));
    self.bindIds[#self.bindIds + 1] = BindTool.bind(PropertyInfo, "buyPropertyResult", handler(self, self.onBuyPropertySuccess));
    self.bindIds[#self.bindIds + 1] = BindTool.bind(PropertyInfo, "usePropertyResult", handler(self, self.onUsePropertyResult));
    self.bindIds[#self.bindIds + 1] = BindTool.bind(PropertyInfo, "usePropertyBroadcast", handler(self, self.onPropertySuccess));
    self.bindIds[#self.bindIds + 1] = BindTool.bind(TableInfo, "kickUserResult", handler(self, self.onKickUserBack));
    self.bindIds[#self.bindIds + 1] = BindTool.bind(TableInfo, "gameStatus", handler(self, self.onServerGameStatus));

    self.bindIds[#self.bindIds + 1] = BindTool.bind(GameUserInfo, "userScore", handler(self, self.onUserScore));
    self.bindIds[#self.bindIds + 1] = BindTool.bind(GameUserInfo, "paymentNotify", handler(self, self.onPaymentNotify));

    self.bindIds[#self.bindIds + 1] = BindTool.bind(MatchInfo, "userRanking", handler(self, self.onUserRanking));
    self.bindIds[#self.bindIds + 1] = BindTool.bind(MatchInfo, "matchInfo", handler(self, self.onMatchInfo));
    self.bindIds[#self.bindIds + 1] = BindTool.bind(MatchInfo, "userMatchInfo", handler(self, self.onRequestUserMatchInfo));
    
    self.bindIds[#self.bindIds + 1] = BindTool.bind(RoomInfo, "loginResult", handler(self, self.loginRoomResult))

    self.bindIds[#self.bindIds + 1] = BindTool.bind(RoomInfo, "ServerConfig", handler(self, self.roomConfigResult))
    self.bindIds[#self.bindIds + 1] = BindTool.bind(TableInfo, "userSitDownResult", handler(self, self.onSitDownResult))
    self.bindIds[#self.bindIds + 1] = BindTool.bind(TableInfo, "usersLookonInfo", handler(self, self.onUsersLookonInfo))
    self.connected_handler = GameConnection:addEventListener(NetworkManagerEvent.SOCKET_CONNECTED, handler(self, self.onSocketStatus))
end
function ZhajinhuaHundredScene:removeGameEvent()
    for _, bindid in ipairs(self.bindIds) do
        BindTool.unbind(bindid)
    end
    GameConnection:removeEventListener(self.connected_handler)
end
-- 构建界面
function ZhajinhuaHundredScene:createUI()

    local back = ccui.Button:create("common/back.png")
    back:setPosition(48,603)
    back:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:gotoRoomScene()
            end
        end
    )
    self.container:addChild(back)

    local tablelayer = ccui.Layout:create()
    tablelayer:setContentSize(cc.size(1136,640))
    tablelayer:setPosition(0,0)
    self.tablelayer = tablelayer
    self.container:addChild(tablelayer)
    local leftchair = ccui.ImageView:create("hundredRoom/hundredPlayScene/chair.png")
    leftchair:setPosition(203,279)
    self.tablelayer:addChild(leftchair)

    local rightchair = ccui.ImageView:create("hundredRoom/hundredPlayScene/chair.png")
    rightchair:setPosition(947, 279)
    rightchair:setScaleX(-1)
    self.tablelayer:addChild(rightchair)


    local table = ccui.ImageView:create("hundredRoom/hundredPlayScene/table.png")
    table:setPosition(574, 326)
    self.tablelayer:addChild(table)

    local bankerBg = ccui.ImageView:create("hundredRoom/hundredPlayScene/bankerBg.png")
    bankerBg:setPosition(586, 588)
    self.bankerBg = bankerBg
    self.tablelayer:addChild(bankerBg)

    local bankerBtn = ccui.Button:create("hundredRoom/hundredPlayScene/bankerBtn.png")
    bankerBtn:setPosition(249,55)
    bankerBg:addChild(bankerBtn)
    bankerBtn:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
            	self:bankerBtnHandler()
            end
        end
    )

    local headview = require("commonView.HeadView").new(1,true)
    self.banker = headview
    headview:setPosition(5, 55)
    headview:setScale(0.9)
    bankerBg:addChild(headview)
    self.bankerCardArrayUI = {}
    for i=1,3 do
    	local bankerCard = ccui.ImageView:create("zhajinhua/cardRed.png")
    	bankerCard:setPosition(102+(i-1)*24,54)
    	bankerCard:setScale(0.8)
    	bankerBg:addChild(bankerCard)
    	self.bankerCardArrayUI[i] = bankerCard
    end
    ---中部UI
    self.playerCardArrayUI = {}
    self.totalChipArrayUI = {}
    self.selfChipArrayUI = {}
    for i=1,4 do
    	local playerCardBg = ccui.ImageView:create("hundredRoom/hundredPlayScene/cardItem.png")
    	playerCardBg:setPosition(329+(i-1)*165,430)
    	self.tablelayer:addChild(playerCardBg)
    	self.playerCardArrayUI[i] = {}
    	for j=1,3 do
	    	local playerCard = ccui.ImageView:create("zhajinhua/cardRed.png")
	    	playerCard:setPosition(50+(j-1)*28,64)
	    	playerCardBg:addChild(playerCard)
	    	self.playerCardArrayUI[i][j] = playerCard
    	end

    	local betItem = ccui.ImageView:create("hundredRoom/hundredPlayScene/betItem.png")
    	betItem:setPosition(329+(i-1)*165,252)
    	self.tablelayer:addChild(betItem)

        local betRegion = ccui.Button:create("common/blank.png")
        betRegion:setScale9Enabled(true);
        betRegion:setContentSize(153, 191);
        betRegion:setPosition(329+(i-1)*165,252)
        betRegion:setTag(i)
        betRegion:addTouchEventListener(
            function(sender,eventType)
                if eventType == ccui.TouchEventType.ended then
                    self:betHandler(sender)
                end
            end
        )
        self.tablelayer:addChild(betRegion)

    	local cardSuit = ccui.ImageView:create("hundredRoom/hundredPlayScene/cardSuit"..i..".png")
    	cardSuit:setPosition(77,92)
    	betItem:addChild(cardSuit)
	    local totalChip = ccui.Text:create("9999","",18)
	    totalChip:setAnchorPoint(cc.p(0.5,0.5))
	    totalChip:setPosition(79, 172)
	    betItem:addChild(totalChip)
	    self.totalChipArrayUI[i] = totalChip
	    local selfChip = ccui.Text:create("1111","",18)
	    selfChip:setAnchorPoint(cc.p(0.5,0.5))
	    selfChip:setPosition(78, 12)
	    betItem:addChild(selfChip)
	    self.selfChipArrayUI[i] = selfChip

    end
    local Countdown = ccui.Text:create("结束时间：","",18)
    Countdown:setAnchorPoint(cc.p(0.5,0.5))
    Countdown:setPosition(578, 131)
    self.tablelayer:addChild(Countdown)
    self.Countdown = Countdown
    ----底部UI
    local buttomBg = ccui.ImageView:create("hundredRoom/hundredPlayScene/betKuang.png")
    buttomBg:setPosition(568,22)
    self.tablelayer:addChild(buttomBg)
    local infoBg = ccui.ImageView:create("hundredRoom/hundredPlayScene/infoBg.png")
    infoBg:setPosition(236, 48)
    self.infoBg = infoBg
    buttomBg:addChild(infoBg)

    local myHead = require("commonView.HeadView").new(1,true)
    self.myHead = myHead
    myHead:setPosition(34, 52)
    myHead:setScale(0.75)
    infoBg:addChild(myHead)

    local nickName = ccui.Text:create("我是昵称","",18)
    nickName:setAnchorPoint(cc.p(0,0.5))
    nickName:setPosition(85, 49)
    infoBg:addChild(nickName)
    self.nickName = nickName

    local chips = ccui.Text:create("999999","",18)
    chips:setAnchorPoint(cc.p(0,0.5))
    chips:setPosition(82, 24)
    infoBg:addChild(chips)
    self.chips = chips

    local plus = ccui.Button:create("hundredRoom/hundredPlayScene/plus.png","hundredRoom/hundredPlayScene/plus.png")
    plus:setPosition(206, 35)
    plus:setPressedActionEnabled(true)
    infoBg:addChild(plus)
    plus:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:plusHandler()
            end
        end
    )

    local btnX = 409
    local btnY = 54
    local betName = {"100","1000","1万","10万","100万"}
    self.betArrayUI = {}
    for i=1,5 do
	    local bet = ccui.Button:create("hundredRoom/hundredPlayScene/bet.png","hundredRoom/hundredPlayScene/betSelected.png")
	    bet:setPosition(btnX+(i-1)*79, btnY)
	    bet:setPressedActionEnabled(true)
	    bet:setTag(i)
        bet:setTitleFontName(FONT_ART_BUTTON);
        bet:setTitleText(betName[i]);
        bet:setTitleColor(cc.c3b(255,255,255));
        bet:setTitleFontSize(20);
        bet:getTitleRenderer():enableOutline(COLOR_BTN_GREEN,2)
	    buttomBg:addChild(bet)
	    bet:addTouchEventListener(
	        function(sender,eventType)
	            if eventType == ccui.TouchEventType.ended then
	                self:betSelectHandler(sender)
	            end
	        end
	    )
        self.betArrayUI[i] = bet
        if i==1 then
            bet:setHighlighted(true)
        end
    end
    self:createOtherUI()
    self:initTable()



    local effectLayer = ccui.Layout:create()
    effectLayer:setContentSize(cc.size(1136,640))
    effectLayer:setPosition(0,0)
    -- effectLayer:setBackGroundColorType(1)
    -- effectLayer:setBackGroundColor(cc.c3b(100,123,100))
    self.effectlayer = effectLayer
    self.container:addChild(effectLayer,LAYER_Z_ORDER.Z_EFFECT)
    print("effectLayer",tostring(effectLayer))

    self.chatWindow = require("zhajinhua.HundredChatLayer").new()--:addTo(self.container, LAYER_Z_ORDER.Z_POPMSG)
    self.chatWindow:setPosition(0,0)
    self.chatWindow:hideChat()
    self.chatWindow:setAllowChat(true)
    self.container:addChild(self.chatWindow,LAYER_Z_ORDER.Z_POPMSG)



end
--周边功能 入口按钮
function ZhajinhuaHundredScene:createOtherUI()
    local ruleBtn = ccui.Button:create("hundredRoom/hundredPlayScene/ruleBtn.png","hundredRoom/hundredPlayScene/ruleBtn.png")
    ruleBtn:setPosition(1093, 172)
    ruleBtn:setPressedActionEnabled(true)
    ruleBtn:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:ruleHandler()
            end
        end
    )
    self.container:addChild(ruleBtn)

    local chartsBtn = ccui.Button:create("hundredRoom/hundredPlayScene/chartsBtn.png","hundredRoom/hundredPlayScene/chartsBtn.png")
    chartsBtn:setPosition(1093, 109)
    chartsBtn:setPressedActionEnabled(true)
    chartsBtn:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:chartsHandler()
            end
        end
    )
    self.container:addChild(chartsBtn)

    local chat = ccui.Button:create("hundredRoom/hundredPlayScene/chatBtn.png","hundredRoom/hundredPlayScene/chatBtn.png")
    chat:setPosition(1093, 45)
    chat:setPressedActionEnabled(true)
    chat:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:chatHandler()
            end
        end
    )
    self.container:addChild(chat)
end
function ZhajinhuaHundredScene:bankerBtnHandler()
	local HundredBankerLayer = require("zhajinhua.HundredBankerLayer").new()
	self.container:addChild(HundredBankerLayer,LAYER_Z_ORDER.Z_CHARTS)
end
--往投注区投注
function ZhajinhuaHundredScene:betHandler(sender)
    local tag = sender:getTag()
    print("betHandler",tag)
    self:addScore(tag)
end
--选择筹码
function ZhajinhuaHundredScene:betSelectHandler(sender)
	local tag = sender:getTag()
    DateModel:getInstance():setSelectedChip(tag*500)
	print("betSelectHandler",tag)
    for i=1,5 do
        if i==tag then
            self.betArrayUI[i]:setHighlighted(true)
        else
            self.betArrayUI[i]:setHighlighted(false)
        end
        
    end
end
function ZhajinhuaHundredScene:plusHandler()
	self:onGameStart()
end
function ZhajinhuaHundredScene:ruleHandler()
	local HundredRuleLayer = require("zhajinhua.HundredRuleLayer").new()
	self.container:addChild(HundredRuleLayer,LAYER_Z_ORDER.Z_CHARTS)
end
function ZhajinhuaHundredScene:chartsHandler()
	local HundredChartsLayer = require("zhajinhua.HundredChartsLayer").new()
	self.container:addChild(HundredChartsLayer,LAYER_Z_ORDER.Z_CHARTS)
end
function ZhajinhuaHundredScene:chatHandler()
	-- self.chatWindow:showChat()
    self:onGameEnd()
end
function ZhajinhuaHundredScene:gotoRoomScene()
	-- body
end
function ZhajinhuaHundredScene:initTable()
    --滚动消息
    local scrollTextContainer = ccui.Layout:create()
    scrollTextContainer:setContentSize(cc.size(600,30))
    scrollTextContainer:setPosition(cc.p(display.left + 100, display.top - 60))
    self.container:addChild(scrollTextContainer, LAYER_Z_ORDER.Z_POPMSG)
    scrollTextContainer:setVisible(false)
    self.scrollTextContainer = scrollTextContainer
    local scrollBg = ccui.ImageView:create("common/scroll_bg.png")
    scrollBg:setPosition(cc.p(313,15))
    scrollTextContainer:addChild(scrollBg)
    local scrollTextPanel = ccui.Layout:create()
    scrollTextPanel:setContentSize(cc.size(626,30))
    scrollTextPanel:setName("scrollTextPanel")
    scrollTextPanel:setPosition(cc.p(0,0))
    scrollTextPanel:setClippingEnabled(true)
    scrollTextContainer:addChild(scrollTextPanel)
    local labaImg = ccui.ImageView:create("common/scroll_laba1.png")
    labaImg:setPosition(cc.p(20,15))
    labaImg:setName("labaImg")
    scrollTextContainer:addChild(labaImg)
end
------------发送协议------------
function ZhajinhuaHundredScene:addScore(region)
    local chip = DateModel:getInstance():getSelectedChip()
    -- local addScore = protocol.zhajinhua.zhajinhua.c2s_pb.addScore()
    -- addScore.wCompareUser = compareUserChairID
    -- local pData = addScore:SerializeToString()
    -- local pDataLen = string.len(pData)

    -- local main = CMD_GameServer.MDM_GF_GAME
    -- local sub = CMD_ZJH.SUB_C_COMPARE_CARD
    
    -- GameConnection:sendCommand(sub,0,pData,pDataLen)
end
    ----------协议回调------------
function ZhajinhuaHundredScene:onServerMsgCallBack(event)
    -- print("event.subId",event.subId)
    local event = {}
    event["subId"] = ZhajinhuaInfo.mainID
    event["data"] = ZhajinhuaInfo.data
    if event.subId == CMD_ZJH.SUB_S_GAME_START then--100--游戏开始--押注
        --[[
    //下注信息
    required int64                          lMaxScore       = 1;                            //最大下注
    required int64                          lCellScore      = 2;                            //单元下注
    required int64                          lCurrentTimes       = 3;                        //当前倍数
    required int64                          lUserMaxScore       = 4;                        //分数上限

    //用户信息
    required int32                          wBankerUser         = 5;                        //庄家用户
    required int32                          wCurrentUser        = 6;                        //当前玩家
        ]]
        print(tostring(self),"游戏开始时间", os.date("%H:%M:%S", os.time()),os.time())

        self:onGameStart(event.data)
    elseif event.subId == CMD_ZJH.SUB_S_ADD_SCORE then--101--用户加注结果
        self:onGameAddScore(event.data)
    elseif event.subId == CMD_ZJH.SUB_S_GAME_END then--104--游戏结束
        self:onGameEnd(event.data)
    elseif event.subId == CMD_ZJH.SUB_S_CLOCK then--110--用户时钟

        self:onClock(event.data)
    end
    
end
function ZhajinhuaHundredScene:onGameStart(data)
    -- local msg = protocol.zhajinhua.zhajinhua.s2c_pb.CMD_S_GameStart_Pro()
    -- msg:ParseFromString(data)
    if not self.hundredCardLayer then
        print("111111")
        self.hundredCardLayer = require("zhajinhua.HundredCardLayer").new({dataModel=DateModel:getInstance(),effectLayer=self.effectlayer})
        self.container:addChild(self.hundredCardLayer, LAYER_Z_ORDER.Z_CARD)
        self.hundredCardLayer:sendCard(1,1)
    else
        self.hundredCardLayer:sendCard(1,1)
        print("22222")
    end
end
function ZhajinhuaHundredScene:onGameAddScore(data)
    -- local msg = protocol.zhajinhua.zhajinhua.s2c_pb.CMD_S_AddScore_Pro()
    -- msg:ParseFromString(data)
    if not self.hundredCardLayer then
        self.hundredCardLayer = require("zhajinhua.HundredCardLayer").new({dataModel=DateModel:getInstance(),effectLayer=self.effectlayer})
        self.container:addChild(self.hundredCardLayer, LAYER_Z_ORDER.Z_CARD)
        self.hundredCardLayer:addScore(msg)
    else
        self.hundredCardLayer:addScore(msg)
    end
end
function ZhajinhuaHundredScene:onGameEnd(data)
    -- local msg = protocol.zhajinhua.zhajinhua.s2c_pb.CMD_S_AddScore_Pro()
    -- msg:ParseFromString(data)
    if not self.hundredCardLayer then
        self.hundredCardLayer = require("zhajinhua.HundredCardLayer").new({dataModel=DateModel:getInstance(),effectLayer=self.effectlayer})
        self.container:addChild(self.hundredCardLayer, LAYER_Z_ORDER.Z_CARD)
        self.hundredCardLayer:compareCard(msg)
    else
        self.hundredCardLayer:compareCard(msg)
    end
end
function ZhajinhuaHundredScene:onClock(data)
end
return ZhajinhuaHundredScene