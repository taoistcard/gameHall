local ZhajinhuaScene = class("ZhajinhuaScene", require("ui.CCBaseScene_ZJH"))

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
    Z_EFFECT = 9,
    Z_POPMSG = 10,
    Z_RULELAYER = 11,
    Z_BANK = 11,
    Z_KICKUSER = 12,
    Z_COMPETEOVER = 12,
    Z_CHANGECELL = 13,
}
local PLAYERSTATE = {
    S_NORMAL = 0,
    S_FOLLOW = 1,
    S_LOOK = 2,
    S_MAX = 3,
    S_DROP = 4,
    S_ADD = 5,
    S_OFFLINE = 6,
    S_WAITBEGIN = 7,
    S_WIN = 8,
    S_LOSE = 9,
    S_CLEAROFFLINE = 10,
}
local OPERATEBUTTON = {
    B_DROP = 1,
    B_LOOK = 2,
    B_COMPARE = 3,
    B_MAX = 4,
    B_FOLLOW = 5,
}
require("zhajinhua.CMD_ZhajinhuaMsg_New")
require("zhajinhua.CMD_GameServer")
require("protocol.zhajinhua.zhajinhua_c2s_pb")
require("protocol.zhajinhua.zhajinhua_s2c_pb")

require("gameSetting.GameConfig")
require("business.GameLogic")
local EffectFactory = require("commonView.EffectFactory")
local DateModel = require("zhajinhua.DateModel")
function ZhajinhuaScene:ctor()
    -- 根节点变更为self.container
    self.super.ctor(self)
    self.roomkind = RunTimeData:getRoomIndex()
    if BindMobilePhone == false then
        self.roomkind = 1
    end
    print("BindMobilePhone",BindMobilePhone)
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
    bgSprite:setTexture("common/table.jpg")
    bgSprite:align(display.CENTER, DESIGN_WIDTH/2, DESIGN_HEIGHT/2)
    self.container:addChild(bgSprite)

    -- local design = ccui.ImageView:create("zhajinhua/playdesign.jpg")
    -- design:setPosition(display.cx, display.cy)
    -- self.container:addChild(design)
    self:createUI()
end
function ZhajinhuaScene:onEnter()
    self:registerEventListener()
    onUmengEventBegin("youxi")
    DateModel:getInstance():setAllowLookFromServer(0)
    local tableID = DateModel:getInstance():getTableID() or 65535
    local chairID = DateModel:getInstance():getChairID() or 65535
    local lookOn = DateModel:getInstance():getLookOn()
    if BindMobilePhone == false then
        tableID = 65535
        chairID = 65535
        lookOn = 0
    end
    local password = ""
    local allowLookOne = 0
    if DateModel:getInstance():getAllowLookOne() then
        allowLookOne = true
    else
        allowLookOne = false
    end

    
    if lookOn == 0 then
        TableInfo:sendUserSitdownRequest(tableID, chairID, password)
        TableInfo:sendGameOptionRequest(allowLookOne)
        print("onEnter坐下在",tableID,chairID)
        self:updateSeatInfo()
    else
        TableInfo:sendUserLookonRequest(tableID, chairID, password)
        TableInfo:sendUsersLookOnInfoRequest(tableID)
        print("onEnter旁观在",tableID,chairID)
        self:updateSeatInfo()
    end
    SoundManager.stopMusic();
    SoundManager.play3CardBackGround()
    -- local buttonCount = #OPERATEBUTTON
    -- print("buttonCount",buttonCount)
    -- for i=1,buttonCount do
    --     DateModel:getInstance():setOperateButtonStatus(i,0)
    -- end
    self:updateOperateButton()
    self:updateOperatePosition()
end
function ZhajinhuaScene:onExit()
    onUmengEventEnd("youxi")
    -- self:removeGameEvent()
end
-- 构建界面
function ZhajinhuaScene:createUI()

    local back = ccui.Button:create("common/back.png")
    back:setPosition(48,578)
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
    local leftchair = ccui.ImageView:create("zhajinhua/tableUI"..self.roomkind.."/chairRight.png")
    leftchair:setPosition(257,332)--254, 344
    leftchair:setScaleX(-1)
    self.tablelayer:addChild(leftchair)

    local rightchair = ccui.ImageView:create("zhajinhua/tableUI"..self.roomkind.."/chairRight.png")
    rightchair:setPosition(861, 344)
    self.tablelayer:addChild(rightchair)
    if DateModel:getInstance():getIsCompeteRoom() == false then
        local upchair = ccui.ImageView:create("zhajinhua/tableUI"..self.roomkind.."/chairUp.png")
        upchair:setPosition(581,477)--561, 528
        self.tablelayer:addChild(upchair)
    end
    local downchair = ccui.ImageView:create("zhajinhua/tableUI"..self.roomkind.."/chairDown.png")
    downchair:setPosition(505,146)--492, 159
    self.tablelayer:addChild(downchair)

    local table = ccui.ImageView:create("zhajinhua/tableUI"..self.roomkind.."/tableBg.png")
    table:setPosition(557, 337)
    self.tablelayer:addChild(table)
    if DateModel:getInstance():getIsCompeteRoom() == true then
        table:loadTexture("zhajinhua/tableUI0/tableBg.png")
    end

    -- local meinv = ccui.ImageView:create("zhajinhua/tableUI"..self.roomkind.."/meinv.png")
    -- meinv:setPosition(567, 560)
    -- self.tablelayer:addChild(meinv)
    if DateModel:getInstance():getIsCompeteRoom() == false then
        local meinvarmature = EffectFactory:getInstance():getGirlInGameArmature("ani_game_girl_"..self.roomkind)
        meinvarmature:setPosition(562, 479)
        self.tablelayer:addChild(meinvarmature)
    end
    local infoBg = ccui.ImageView:create("zhajinhua/infoBg.png")
    infoBg:setPosition(879, 115)
    self.infoBg = infoBg
    self.tablelayer:addChild(infoBg)

    local maxScoreTitle = ccui.Text:create("加满：","",18)
    maxScoreTitle:setAnchorPoint(cc.p(0,0.5))
    maxScoreTitle:setPosition(24, 49)
    infoBg:addChild(maxScoreTitle)

    local maxScore = ccui.Text:create("0","",18)
    maxScore:setAnchorPoint(cc.p(0,0.5))
    maxScore:setPosition(78, 49)
    infoBg:addChild(maxScore)
    self.maxScore = maxScore

    local cellScoreTitle = ccui.Text:create("单注：","",18)
    cellScoreTitle:setAnchorPoint(cc.p(0,0.5))
    cellScoreTitle:setPosition(24, 16)
    infoBg:addChild(cellScoreTitle)

    local cellScore = ccui.Text:create("0","",18)
    cellScore:setAnchorPoint(cc.p(0,0.5))
    cellScore:setPosition(78, 16)
    infoBg:addChild(cellScore)
    self.cellScore = cellScore
    -----比赛场信息start
        local roundBg = ccui.ImageView:create("zhajinhua/competeRoom/roundBg.png")
        roundBg:setPosition(879, 128)
        self.tablelayer:addChild(roundBg)

        local currentRound = ccui.Text:create("当前第22手","",18)
        currentRound:setAnchorPoint(cc.p(0.5,0.5))
        currentRound:setPosition(71, 23)
        roundBg:addChild(currentRound)
        self.currentRound = currentRound

        local topInfoBg = ccui.ImageView:create("zhajinhua/competeRoom/topInfoBg.png")
        topInfoBg:setPosition(568, 615)
        self.tablelayer:addChild(topInfoBg)

        local competeRank = ccui.Text:create("排名:12/99","",18)
        competeRank:setAnchorPoint(cc.p(0.5,0.5))
        competeRank:setPosition(59,25)
        topInfoBg:addChild(competeRank)
        self.competeRank = competeRank

        local competeCellScore = ccui.Text:create("底注:1299","",18)
        competeCellScore:setAnchorPoint(cc.p(0.5,0.5))
        competeCellScore:setPosition(189, 25)
        topInfoBg:addChild(competeCellScore)
        self.competeCellScore = competeCellScore

        self.timer = 0
        local competeTime = ccui.Text:create("01:59","",18)
        competeTime:setAnchorPoint(cc.p(0.5,0.5))
        competeTime:setPosition(306, 25)
        topInfoBg:addChild(competeTime)
        self.competeTime = competeTime
    -----比赛场信息end
    if DateModel:getInstance():getIsCompeteRoom() then
        infoBg:hide()
        roundBg:show()
        topInfoBg:show()
    else
        infoBg:show()
        roundBg:hide()
        topInfoBg:hide()
    end
    --桌子号
    local tableNum = ccui.Text:create("0","FONT_ART_TEXT",20)
    tableNum:setAnchorPoint(cc.p(0.5,0.5))
    tableNum:setPosition(422, 555)
    tableNum:setTextColor(cc.c4b(255, 255, 255, 240))
    tableNum:enableOutline(cc.c4b(84,53,20,200), 2)
    self.tablelayer:addChild(tableNum)
    self.tableNum = tableNum
    if DateModel:getInstance():getIsCompeteRoom() then
        tableNum:hide()
    end
    --站起按钮
    local standUp = ccui.Button:create("hall/roomselect/standUp.png")
    standUp:setPosition(100,100)
    standUp:hide()
    standUp:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                if DataManager:getMyUserStatus() == Define.US_PLAYING then
                    Hall.showTips("您还在游戏中，不能站起！", 1)
                    return
                end
                local tableID = DateModel:getInstance():getTableID() or 1
                local chairID = DateModel:getInstance():getChairID() or 1
                -- GameCenter:standUp()
                -- GameCenter:lookOn(tableID,chairID)
                -- GameCenter:sendGameConfigInfo(1)
                TableInfo:sendUserStandUpRequest()
                TableInfo:sendUserLookonRequest(tableID, chairID, "")
                print("standUp旁观在",tableID,chairID)
                self:updateSeatInfo()
            end
        end
    )
    self.container:addChild(standUp)
    self:createPlayerView()
    self:createOperateButton()
    self:createOtherUI()
    self:createTableGoldUI()
    self:createChipLayer()
    self:initTable()

    local effectLayer = ccui.Layout:create()
    effectLayer:setContentSize(cc.size(1136,640))
    effectLayer:setPosition(0,0)
    -- effectLayer:setBackGroundColorType(1)
    -- effectLayer:setBackGroundColor(cc.c3b(100,123,100))
    self.effectlayer = effectLayer
    self.container:addChild(effectLayer,LAYER_Z_ORDER.Z_EFFECT)
    print("effectLayer",tostring(effectLayer))

    self.chatWindow = require("commonView.ViewMessage_New").new()--:addTo(self.container, LAYER_Z_ORDER.Z_POPMSG)
    self.chatWindow:setPosition(0,0)
    self.chatWindow:hideChat()
    self.chatWindow:setAllowChat(true)
    self.container:addChild(self.chatWindow,LAYER_Z_ORDER.Z_POPMSG)

    --奖池
    local winSize = cc.Director:getInstance():getWinSize();
    local awardLayer = require("hall.AwardPoolLayer").new(2)
    awardLayer:setPosition(cc.p(0,(640-winSize.height)/2));
    -- awardLayer:setAnchorPoint(cc.p(0.5,0.5))
    -- awardLayer:ignoreAnchorPointForPosition(false)
    -- self:addChild(awardLayer,100)
    self.container:addChild(awardLayer,10)

    -- print("测试位置：",awardLayer:getPositionX(),awardLayer:getPositionY())

end

local playerPos = {cc.p(209,485),cc.p(172,296),cc.p(508,210-11),cc.p(939,284),cc.p(933,490)}

function ZhajinhuaScene:createPlayerView()
    -- body

    local stateIcon = {"zhajinhua/look.png","zhajinhua/follow.png","zhajinhua/drop.png","zhajinhua/showhand.png"}
    local stateIconPos = {cc.p(114,33),cc.p(114,33),cc.p(114,33),cc.p(21,18),cc.p(13,31)}
    local propertyIconPos = {cc.p(10,36),cc.p(13,31),cc.p(12,27),cc.p(121,41),cc.p(125,30)}
    local readyIconPos = {cc.p(68,34),cc.p(67,28),cc.p(69,25+11),cc.p(75,28),cc.p(68,34)}--{cc.p(206,29),cc.p(232,55),cc.p(219,103+11),cc.p(-62,66),cc.p(-88,18)}
    local stateIconData = {1,2,1,3,4}
    self.playerUI = {}
    self.playerInfo = {}
    self.playerInfoTag = {"selectSeat","headbg","nickName","userGold"}
    for i=1,5 do
        self.playerInfo[i] = {}
        local playerbg = ccui.Layout:create()
        playerbg:setAnchorPoint(cc.p(0.5,0.5))
        playerbg:setContentSize(cc.size(144,144))
        playerbg:setPosition(playerPos[i])
        playerbg:setCascadeOpacityEnabled(true)
        -- playerbg:setBackGroundColorType(1)
        -- playerbg:setBackGroundColor(cc.c3b(100,123,100))
        self.container:addChild(playerbg, LAYER_Z_ORDER.Z_PLAYER)

        local selectSeat = ccui.Button:create("zhajinhua/sitDown.png","zhajinhua/sitDown.png")
        selectSeat:setPosition(72, 72)
        selectSeat:setName("selectSeat")
        selectSeat:setTag(i)
        selectSeat:hide()
        selectSeat:addTouchEventListener(
            function (sender,eventType)
                if eventType == ccui.TouchEventType.ended then
                    self:selectSeatHandler(sender)
                end
            end
        )
        self.playerInfo[i]["selectSeat"] = selectSeat
        playerbg:addChild(selectSeat)

        local progressTimer = require("commonView.CustomProgressTimer").new()
        progressTimer:setPosition(72, 72)
        progressTimer:hide()
        playerbg:addChild(progressTimer)
        self.playerInfo[i]["progressTimer"] = progressTimer

        local headbg = ccui.Button:create("common/blank.png")--"hall/selectTable/headbg.png"--zhajinhua/gameOverMask.png
        headbg:setPosition(72, 72)
        headbg:setTag(i)
        headbg:hide()
        -- headbg:setCascadeOpacityEnabled(true)
        headbg:setScale9Enabled(true)
        headbg:setContentSize(cc.size(144,144))
        -- headbg:setTouchEnabled(true)
        self.playerInfo[i]["headbg"] = headbg
        headbg:addTouchEventListener(
            function (sender,eventType)
                if eventType == ccui.TouchEventType.ended then
                    self:clickUserInfoHandler(sender)
                end
            end
        )
        playerbg:addChild(headbg)

        local headview = require("commonView.HeadView").new(1,true)
        self.playerInfo[i]["headview"] = headview
        headview:setPosition(72, 72)
        headbg:addChild(headview)

        local nickNameBg = ccui.ImageView:create("zhajinhua/nameBg.png")
        nickNameBg:setContentSize(cc.size(160,30))
        nickNameBg:setScale9Enabled(true)
        nickNameBg:setPosition(65, -10)
        nickNameBg:setName("nickNameBg")
        -- self.playerInfo[i]["nickNameBg"] = nickNameBg
        headbg:addChild(nickNameBg)

        -- local progressTimer = cc.ProgressTimer:create(cc.Sprite:create("zhajinhua/timeProcess.png"))
        -- progressTimer:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
        -- progressTimer:setMidpoint(cc.p(0.5, 0.5))
        -- progressTimer:setReverseDirection(true)



        local nickName = ccui.Text:create("我是名字","",20)
        nickName:setPosition(77, 14)
        nickName:setColor(cc.c3b(255, 255, 255))
        nickName:setName("nickName")
        self.playerInfo[i]["nickName"] = nickName
        nickNameBg:addChild(nickName)

        local userGoldBg = ccui.ImageView:create("zhajinhua/userGoldBg.png")
        -- userGoldBg:setContentSize(cc.size(160,30))
        -- userGoldBg:setScale9Enabled(true)
        userGoldBg:setPosition(66, -39)
        userGoldBg:setName("userGoldBg")
        -- self.playerInfo[i]["userGoldBg"] = userGoldBg
        headbg:addChild(userGoldBg)

        local userGold = ccui.Text:create("我是金币","",18)
        userGold:setPosition(35, 15)
        userGold:setAnchorPoint(cc.p(0,0.5))
        userGold:setColor(cc.c3b(255, 255, 255))
        userGold:setName("userGold")
        self.playerInfo[i]["userGold"] = userGold
        userGoldBg:addChild(userGold)

        local gameOverMask = ccui.ImageView:create("zhajinhua/gameOverMask.png")--zhajinhua/gameOverMask.png
        gameOverMask:setPosition(72, 72)
        gameOverMask:setVisible(false)
        gameOverMask:hide()
        self.playerInfo[i]["gameOverMask"] = gameOverMask
        playerbg:addChild(gameOverMask)

        local playerState = ccui.ImageView:create(stateIcon[stateIconData[i]])
        playerState:setPosition(stateIconPos[i])
        playerState:setName("playerState")
        playerState:hide()
        self.playerInfo[i]["playerState"] = playerState
        playerbg:addChild(playerState)

        self.playerUI[i] = playerbg

        local playerReady = ccui.ImageView:create("zhajinhua/ok.png")
        playerReady:setPosition(readyIconPos[i])
        playerReady:setName("playerReady")
        self.playerInfo[i]["playerReady"] = playerReady
        playerReady:setVisible(false)
        playerbg:addChild(playerReady)

        local chairID = ccui.Text:create("我是chairID","",25)
        chairID:setPosition(35, 15)
        chairID:setAnchorPoint(cc.p(0,0.5))
        chairID:setColor(cc.c3b(255, 255, 255))
        chairID:setName("chairID")
        chairID:hide()
        self.playerInfo[i]["chairID"] = chairID
        playerbg:addChild(chairID)

        local banker = ccui.ImageView:create("zhajinhua/bankerIcon.png")--ccui.Text:create("庄","",25)
        banker:setPosition(23, 116)
        banker:setAnchorPoint(cc.p(0,0.5))
        -- banker:setColor(cc.c3b(255, 255, 255))
        banker:setName("banker")
        banker:hide()
        self.playerInfo[i]["banker"] = banker
        playerbg:addChild(banker)

        local propertyIcon = ccui.Button:create("zhajinhua/propertyIcon.png")
        propertyIcon:setPosition(propertyIconPos[i])
        propertyIcon:setTag(i)
        propertyIcon:hide()
        propertyIcon:addTouchEventListener(
            function (sender,eventType)
                if eventType == ccui.TouchEventType.ended then
                    self:clickPropertyHandler(sender)
                end
            end
        )
        self.playerInfo[i]["propertyIcon"] = propertyIcon
        playerbg:addChild(propertyIcon)

        local gameoverGold = ccui.Text:create("我是结算","",25)
        gameoverGold:setPosition(40, 80)
        gameoverGold:setAnchorPoint(cc.p(0,0.5))
        gameoverGold:setColor(cc.c3b(255, 255, 255))
        gameoverGold:setName("gameoverGold")
        gameoverGold:hide()
        self.playerInfo[i]["gameoverGold"] = gameoverGold
        playerbg:addChild(gameoverGold)

    end
    -- local bottombg = ccui.ImageView:create("hall/selectTable/bottom.png")
    -- bottombg:setPosition(568, 24)
    -- bottombg:setScale9Enabled(true);
    -- bottombg:setContentSize(cc.size(1136,105));
    -- self.container:addChild(bottombg)


end
--选择桌位坐下
function ZhajinhuaScene:selectSeatHandler(sender)
    local index = sender:getTag()
    local tableID = DateModel:getInstance():getTableID() or 1
    local chairID = self.chairArry[index]
    print("坐下在",tableID,chairID)
    local allowLookOne = 0
    if DateModel:getInstance():getAllowLookOne() then
        allowLookOne = true
    else
        allowLookOne = false
    end
    TableInfo:sendUserSitdownRequest(tableID, chairID, "")
    TableInfo:sendGameOptionRequest(allowLookOne)
end
--点选玩家个人信息
function ZhajinhuaScene:clickUserInfoHandler(sender)
    
    local index = sender:getTag()
    local userInfo = DataManager:getUserInfoInMyTableByChairIDExceptLookOn(self.chairArry[index])
    require("zhajinhua.PersonInfoLayer").new(userInfo):addTo(self.container, LAYER_Z_ORDER.Z_PLAYERINFOLAYER)

end
--更新桌位信息
function ZhajinhuaScene:updateSeatInfo()
    -- body
    local myChairID = DataManager:getMyChairID()-1
    if myChairID == Define.INVALID_CHAIR then
        myChairID = 0
        print("myChairID==Define.INVALID_CHAIR",Define.INVALID_CHAIR)
    end
    local tempPlayerUI = {}
    local prepreID = (myChairID+3)%5+1
    local preID =(myChairID+4)%5+1
    local nextID = (myChairID+1)%5+1
    local nextnextID = (myChairID+2)%5+1
    myChairID = myChairID+1
    local chairArry = {prepreID,preID,myChairID,nextID,nextnextID}
    -- print("chairArry",prepreID,preID,myChairID,nextID,nextnextID)
    self.chairArry = chairArry
    self.chatWindow:setChairArray(self.chairArry)
    -- for i=1,5 do
    --     tempPlayerUI[chairArry[i]+1] = self.playerUI[i]
    -- end
    -- for i=1,5 do
    --     self.playerUI[i] = tempPlayerUI[i]
    -- end
    
    self.targetUserIDArray = {}
    for i=1,5 do
        userInfo = DataManager:getUserInfoInMyTableByChairIDExceptLookOn(chairArry[i])
        -- print("userInfo",userInfo)
        if userInfo then
            self:updatePlayerInfo(userInfo,i)
            table.insert(self.targetUserIDArray, userInfo.userID)
        else
            self.playerInfo[i]["playerState"]:hide()
            self.playerInfo[i]["headbg"]:hide()
            self.playerInfo[i]["selectSeat"]:show()
            self.tableGoldBgUI[i]:hide()
            self.playerInfo[i]["progressTimer"]:hide()
            self.playerInfo[i]["gameOverMask"]:hide()
            self.playerInfo[i]["propertyIcon"]:hide()
            self:updatePlayerState(chairArry[i],PLAYERSTATE.S_NORMAL)
        end
    end
end
function ZhajinhuaScene:updatePlayerInfo(userInfo,index)

    local chairID = userInfo.chairID
    -- self.playerUI[index]:show()
    -- print("chairID",chairID,DateModel:getInstance():getBankerUser(),"nickName",userInfo.nickName,"chairID",userInfo.chairID ,"userStatus",userInfo.userStatus)
    self.playerInfo[index]["headbg"]:show()
    self.playerInfo[index]["playerState"]:show()
    self.playerInfo[index]["selectSeat"]:hide()
    self.playerInfo[index]["propertyIcon"]:show()
    self.tableGoldBgUI[index]:show()
    -- print("userStatus=",userInfo.userStatus)
    if userInfo.userStatus == Define.US_READY then
        for i,v in ipairs(self.chairArry) do
            if v == chairID then
                self:updatePlayerState(userInfo.chairID, PLAYERSTATE.S_NORMAL)
                self.playerInfo[i]["playerReady"]:show()
                break
            end
        end
        
    elseif userInfo.userStatus == Define.US_OFFLINE then
        -- Hall.showTips("userInfo"..userInfo.nickName, 2)
        self:updatePlayerState(self.chairArry[index],PLAYERSTATE.S_OFFLINE)
    elseif userInfo.userStatus == Define.US_PLAYING then
        if DateModel:getInstance():getGameStart() then
            self:updatePlayerState(self.chairArry[index],PLAYERSTATE.S_CLEAROFFLINE)
            -- print("PLAYERSTATE.S_CLEAROFFLINE")
            for i,v in ipairs(self.dropChairID) do
                if v == self.chairArry[index] then
                    self:updatePlayerState(self.chairArry[index],PLAYERSTATE.S_DROP)
                    break
                end
            end
        end
    elseif userInfo.userStatus == Define.US_SIT then
        if userInfo.userStatus ~= Define.US_PLAYING and DateModel:getInstance():getGameStart() then
            self:updatePlayerState(userInfo.chairID, PLAYERSTATE.S_WAITBEGIN)
        end
    end

    -- if DateModel:getInstance():getLookCardStatus(index) == 1 then
    --     self:updatePlayerState(self.chairArry[index],PLAYERSTATE.S_LOOK)
    -- end
    -- if DateModel:getInstance():getPlayStatus(index) ==0 and userInfo.userStatus == Define.US_PLAYING then
    --     self:updatePlayerState(self.chairArry[index],PLAYERSTATE.S_DROP)
    -- end
    -- if DateModel:getInstance():getTableGoldPlayerValue(index) > DateModel:getInstance():getCellScore() then
    --     self:updatePlayerState(self.chairArry[index],PLAYERSTATE.S_FOLLOW)
    -- end

    local nickName = self.playerInfo[index]["nickName"]--self.playerUI[index]:getChildByName("nickNameBg"):getChildByName("nickName")
    local nameString = userInfo.nickName
    nickName:setString(FormotGameNickName(nameString,7))
    local userGold = self.playerInfo[index]["userGold"]--self.playerUI[index]:getChildByName("userGoldBg"):getChildByName("userGold")
    if DateModel:getInstance():getGameStart() then
        userGold:setString(FormatNumToString(userInfo.scoreInGame))
    else
        userGold:setString(FormatNumToString(userInfo.score))
    end
    
    self.playerInfo[index]["chairID"]:setString(chairID)
    -- print("*****",userInfo.nickName,userInfo.faceID,"tokenID",userInfo.tokenID,"platformFace",userInfo.platformFace,"memberOrder",userInfo.memberOrder)
    self.playerInfo[index]["headview"]:setNewHead(userInfo.faceID,userInfo.platformID,userInfo.platformFace)
    self.playerInfo[index]["headview"]:setVipHead(userInfo.memberOrder)
end
--设置游戏中的金币临时变量
function ZhajinhuaScene:updateMoneyInGame()
    for i=1,5 do
        userInfo = DataManager:getUserInfoInMyTableByChairIDExceptLookOn(self.chairArry[i])
        -- print("userInfo",userInfo)
        if userInfo then
            local index = self:getPlayerIndexByChairID(userInfo.chairID)
            userInfo.scoreInGame=(userInfo.score-DateModel:getInstance():getTableGoldPlayerValue(index))
            local userGold = self.playerInfo[index]["userGold"]
            userGold:setString(FormatNumToString(userInfo.scoreInGame))
        end
    end
end
function ZhajinhuaScene:updateBankerIcon()
    for i=1,5 do
        self.playerInfo[i]["banker"]:hide()
    end
    local index = -1
    for i,chairID in ipairs(self.chairArry) do
        if chairID == DateModel:getInstance():getBankerUser() then
            index = i
            local playerInfo = DataManager:getUserInfoInMyTableByChairIDExceptLookOn(chairID)
            if playerInfo and playerInfo.userStatus == Define.US_PLAYING then
                self.playerInfo[i]["banker"]:show()
            end
        end
    end

end
function ZhajinhuaScene:updatePlayerState(chairID,state,playAction)
    local index = -1
    for i,v in ipairs(self.chairArry) do
        if v== chairID then
            index = i
            -- print("updatePlayerState==","chairID",chairID,"index",index,"state",state)
        end
    end
    if state == PLAYERSTATE.S_NORMAL then
        self.playerInfo[index]["playerState"]:loadTexture("common/blank.png")
        self.playerInfo[index]["playerState"]:hide()
        self.playerInfo[index]["gameOverMask"]:hide()
        self.playerInfo[index]["gameOverMask"]:removeAllChildren()
        self.playerInfo[index]["gameoverGold"]:hide()
        self.playerInfo[index]["banker"]:hide()
        self.playerInfo[index]["playerReady"]:hide()
        if DataManager:getMyUserStatus() == Define.US_LOOKON then
            self.playerInfo[index]["selectSeat"]:show()
        else
            self.playerInfo[index]["selectSeat"]:hide()
        end        
        self.playerUI[index]:setOpacity(255) 
        self.playerInfo[index]["nickName"]:setOpacity(255)
        self.playerInfo[index]["userGold"]:setOpacity(255)     
    elseif state == PLAYERSTATE.S_FOLLOW then
        self.playerInfo[index]["playerState"]:show()
        self.playerInfo[index]["playerState"]:loadTexture("zhajinhua/follow.png")
        local scaleto = cc.ScaleTo:create(0.3, 1.2)
        local scaleto2 = cc.ScaleTo:create(0.1, 1)
        self.playerInfo[index]["playerState"]:runAction(cc.Sequence:create(scaleto,scaleto2))
        self.playerUI[index]:setOpacity(255)
        self.playerInfo[index]["nickName"]:setOpacity(255)
        self.playerInfo[index]["userGold"]:setOpacity(255)
    elseif state == PLAYERSTATE.S_LOOK then
        self.playerInfo[index]["playerState"]:show()
        self.playerInfo[index]["playerState"]:loadTexture("zhajinhua/look.png")
        local scaleto = cc.ScaleTo:create(0.3, 1.2)
        local scaleto2 = cc.ScaleTo:create(0.1, 1)
        self.playerInfo[index]["playerState"]:runAction(cc.Sequence:create(scaleto,scaleto2))
        self.playerUI[index]:setOpacity(255)
        self.playerInfo[index]["nickName"]:setOpacity(255)
        self.playerInfo[index]["userGold"]:setOpacity(255)
    elseif state == PLAYERSTATE.S_MAX then
        self.playerInfo[index]["playerState"]:show()
        self.playerInfo[index]["playerState"]:loadTexture("zhajinhua/showhand.png")
        local scaleto = cc.ScaleTo:create(0.3, 1.2)
        local scaleto2 = cc.ScaleTo:create(0.1, 1)
        self.playerInfo[index]["playerState"]:runAction(cc.Sequence:create(scaleto,scaleto2))
        self.playerUI[index]:setOpacity(255)
        self.playerInfo[index]["nickName"]:setOpacity(255)
        self.playerInfo[index]["userGold"]:setOpacity(255)
    elseif state == PLAYERSTATE.S_DROP then
        self.playerInfo[index]["playerState"]:show()
        self.playerInfo[index]["playerState"]:loadTexture("zhajinhua/drop.png")
        self.playerInfo[index]["gameOverMask"]:show()
        self.playerInfo[index]["gameOverMask"]:removeAllChildren()
        if playAction then
            local scaleto = cc.ScaleTo:create(0.3, 1.2)
            local scaleto2 = cc.ScaleTo:create(0.1, 1)
            self.playerInfo[index]["playerState"]:runAction(cc.Sequence:create(scaleto,scaleto2))
        end
        local opacityValue = 0.5
        self.playerUI[index]:setOpacity(255*opacityValue)
        self.playerInfo[index]["headview"]:setOpacity(255*opacityValue)
        self.playerInfo[index]["nickName"]:setOpacity(255*opacityValue)
        self.playerInfo[index]["userGold"]:setOpacity(255*opacityValue)
    elseif state == PLAYERSTATE.S_ADD then
        self.playerInfo[index]["playerState"]:show()
        self.playerInfo[index]["playerState"]:loadTexture("zhajinhua/add.png")
        local scaleto = cc.ScaleTo:create(0.3, 1.2)
        local scaleto2 = cc.ScaleTo:create(0.1, 1)
        self.playerInfo[index]["playerState"]:runAction(cc.Sequence:create(scaleto,scaleto2))
        self.playerUI[index]:setOpacity(255)
        self.playerInfo[index]["nickName"]:setOpacity(255)
        self.playerInfo[index]["userGold"]:setOpacity(255)
    elseif state == PLAYERSTATE.S_OFFLINE then
        self.playerInfo[index]["gameOverMask"]:show()
        self.playerInfo[index]["gameOverMask"]:removeAllChildren()
        local size = self.playerInfo[index]["gameOverMask"]:getContentSize()
        local offline = ccui.Text:create("玩家掉线","",20)
        offline:setPosition(size.width/2, size.height/2)
        self.playerInfo[index]["gameOverMask"]:addChild(offline)
        self.playerUI[index]:setOpacity(255)
        self.playerInfo[index]["nickName"]:setOpacity(255)
        self.playerInfo[index]["userGold"]:setOpacity(255)
    elseif state == PLAYERSTATE.S_CLEAROFFLINE then
        self.playerInfo[index]["gameOverMask"]:hide()
        self.playerInfo[index]["gameOverMask"]:removeAllChildren()
        self.playerUI[index]:setOpacity(255)
        self.playerInfo[index]["nickName"]:setOpacity(255)
        self.playerInfo[index]["userGold"]:setOpacity(255)
    elseif state == PLAYERSTATE.S_WAITBEGIN then
        self.playerInfo[index]["gameOverMask"]:show()
        self.playerInfo[index]["gameOverMask"]:removeAllChildren()
        local size = self.playerInfo[index]["gameOverMask"]:getContentSize()
        local waitNext = ccui.Text:create("等待下一局","",20)
        waitNext:setPosition(size.width/2, size.height/2)
        self.playerInfo[index]["gameOverMask"]:addChild(waitNext)
        self.playerUI[index]:setOpacity(255)
        self.playerInfo[index]["nickName"]:setOpacity(255)
        self.playerInfo[index]["userGold"]:setOpacity(255)
    elseif state == PLAYERSTATE.S_LOSE then
        self.playerInfo[index]["playerState"]:show()
        self.playerInfo[index]["playerState"]:loadTexture("zhajinhua/iconLose.png")
        self.playerInfo[index]["gameOverMask"]:show()
        self.playerInfo[index]["gameOverMask"]:removeAllChildren()
        self.playerUI[index]:setOpacity(255)
        self.playerInfo[index]["nickName"]:setOpacity(255)
        self.playerInfo[index]["userGold"]:setOpacity(255)
    elseif state == PLAYERSTATE.S_WIN then
        self.playerInfo[index]["playerState"]:show()
        self.playerInfo[index]["playerState"]:loadTexture("zhajinhua/iconWin.png")
        self.playerInfo[index]["gameOverMask"]:show()
        self.playerInfo[index]["gameOverMask"]:removeAllChildren()
        self.playerUI[index]:setOpacity(255)
        self.playerInfo[index]["nickName"]:setOpacity(255)
        self.playerInfo[index]["userGold"]:setOpacity(255)
    end
end
--游戏操作按钮
function ZhajinhuaScene:createOperateButton()
    local pos = {cc.p(321,42),cc.p(466,42),cc.p(611,42),cc.p(757,42),cc.p(900,42)}
    if DateModel:getInstance():getIsCompeteRoom() == true then--比赛场
        pos = {cc.p(698,42),cc.p(698,42),cc.p(844,42),cc.p(10000,42),cc.p(992,42)}
    end
    local posCompete = {cc.p(157,42),cc.p(323,42),cc.p(489,42)}
    local titlePos = {cc.p(94, 23),cc.p(70, 23),cc.p(70, 23),cc.p(70, 23),cc.p(94, 23)}
    local titleNameArray = {"弃牌","看牌","比牌","加满","跟注"}
    self.operateButtonUIArray = {}
    self.operateCompeteButtonUIArray = {}
    local operateLayer = ccui.Layout:create()
    operateLayer:setContentSize(cc.size(1136,640))
    operateLayer:setPosition(0,0)
    -- operateLayer:setBackGroundColorType(1)
    -- operateLayer:setBackGroundColor(cc.c3b(255,100,0))
    self.container:addChild(operateLayer)
    self.operateLayer = operateLayer
    local bottombg = ccui.ImageView:create("hall/selectTable/bottom.png")
    bottombg:setPosition(568, 24)
    bottombg:setScale9Enabled(true);
    bottombg:setContentSize(cc.size(1136,105));
    self.operateLayer:addChild(bottombg)

    for i=1,5 do
        local operate = ccui.Button:create("zhajinhua/button.png","zhajinhua/buttonSelected.png")
        operate:setPosition(pos[i])
        operate:setZoomScale(0.1)
        operate:setPressedActionEnabled(true)
        operate:setTag(i)
        operate:addTouchEventListener(
            function(sender,eventType)
                if eventType == ccui.TouchEventType.ended then
                    self:operateHandler(sender)
                end
            end
        )
        self.operateLayer:addChild(operate)
        table.insert(self.operateButtonUIArray, operate)
        local titleName = ccui.Text:create(titleNameArray[i],"",24)
        titleName:setPosition(titlePos[i])
        titleName:setName("titleName")
        operate:addChild(titleName)
    end
    local checkDrop = ccui.ImageView:create("zhajinhua/checkBg.png")
    -- checkDrop:setPosition(279, 42)
    -- self.operateLayer:addChild(checkDrop)
    checkDrop:setPosition(26, 24)
    self.operateButtonUIArray[1]:addChild(checkDrop)
    local checkDropYes = ccui.ImageView:create("zhajinhua/check.png")
    checkDropYes:setPosition(26, 24)
    checkDropYes:hide()
    self.operateButtonUIArray[1]:addChild(checkDropYes)
    self.checkDropYes = checkDropYes

    local checkFollow = ccui.ImageView:create("zhajinhua/checkBg.png")
    -- checkFollow:setPosition(858, 42)
    checkFollow:setPosition(26, 24)
    self.operateButtonUIArray[5]:addChild(checkFollow)

    local checkFollowYes = ccui.ImageView:create("zhajinhua/check.png")
    checkFollowYes:setPosition(26, 24)
    checkFollowYes:hide()
    self.operateButtonUIArray[5]:addChild(checkFollowYes)
    self.checkFollowYes = checkFollowYes

    for i=1,3 do
        local operate = ccui.Button:create("zhajinhua/competeRoom/addBtn.png","zhajinhua/competeRoom/addBtn.png")
        operate:setPosition(posCompete[i])
        -- operate:setPressedActionEnabled(true)
        operate:setTag(i)
        operate:addTouchEventListener(
            function(sender,eventType)
                if eventType == ccui.TouchEventType.ended then
                    self:operateCompeteHandler(sender)
                end
            end
        )
        self.operateLayer:addChild(operate)
        table.insert(self.operateCompeteButtonUIArray, operate)
        -- local titleName = ccui.Text:create(titleNameArray[i],"",24)
        -- titleName:setPosition(titlePos[i])
        -- titleName:setName("titleName")
        -- operate:addChild(titleName)
    end
    if DateModel:getInstance():getIsCompeteRoom() == false then--比赛场
        for i,v in ipairs(self.operateCompeteButtonUIArray) do
            v:hide()
        end
    end

    local xuepin = ccui.Button:create("zhajinhua/xuepin.png","zhajinhua/xuepinSelected.png")
    xuepin:setPosition(331,123)
    xuepin:setPressedActionEnabled(true)
    xuepin:hide()
    xuepin:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:xuepinHandler(sender)
            end
        end
    )
    self.container:addChild(xuepin)
    self.xuepin = xuepin

    local showCardButton = ccui.Button:create("zhajinhua/showCard.png","zhajinhua/showCard.png")
    showCardButton:setPosition(331,123)
    showCardButton:setPressedActionEnabled(true)
    showCardButton:hide()
    showCardButton:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:showCardHandler(sender)
            end
        end
    )
    self.container:addChild(showCardButton)
    self.showCardButton = showCardButton

    local start = ccui.Button:create("zhajinhua/start.png","zhajinhua/startSelected.png")
    start:setPosition(563,337)
    start:setPressedActionEnabled(true)
    start:hide()
    start:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:startHandler(sender)
            end
        end
    )
    self.container:addChild(start)
    self.start = start

    -- local standUp = ccui.Button:create("zhajinhua/button.png","zhajinhua/buttonSelected.png")
    -- standUp:setPosition(163,600)
    -- standUp:setPressedActionEnabled(true)
    -- standUp:setTitleText("站起")
    -- standUp:addTouchEventListener(
    --     function(sender,eventType)
    --         if eventType == ccui.TouchEventType.ended then
    --             self:standUpHandler(sender)
    --         end
    --     end
    -- )
    -- self.container:addChild(standUp)

    -- local openCard = ccui.Button:create("zhajinhua/button.png","zhajinhua/buttonSelected.png")
    -- openCard:setPosition(263,600)
    -- openCard:setPressedActionEnabled(true)
    -- openCard:setTitleText("openCard")
    -- openCard:addTouchEventListener(
    --     function(sender,eventType)
    --         if eventType == ccui.TouchEventType.ended then
    --             self:openCard()
    --         end
    --     end
    -- )
    -- self.container:addChild(openCard)

    -- local openCard = ccui.Button:create("zhajinhua/button.png","zhajinhua/buttonSelected.png")
    -- openCard:setPosition(363,600)
    -- openCard:setPressedActionEnabled(true)
    -- openCard:setTitleText("比牌")
    -- openCard:addTouchEventListener(
    --     function(sender,eventType)
    --         if eventType == ccui.TouchEventType.ended then
    --             self:compareCardHandler()
    --         end
    --     end
    -- )
    -- self.container:addChild(openCard)

    -- local openCard = ccui.Button:create("zhajinhua/button.png","zhajinhua/buttonSelected.png")
    -- openCard:setPosition(163,550)
    -- openCard:setPressedActionEnabled(true)
    -- openCard:setTitleText("chipLayer")
    -- openCard:addTouchEventListener(
    --     function(sender,eventType)
    --         if eventType == ccui.TouchEventType.ended then
    --             self:changeChipLayerState(1)
    --         end
    --     end
    -- )
    -- self.container:addChild(openCard)

    -- local openCard = ccui.Button:create("zhajinhua/button.png","zhajinhua/buttonSelected.png")
    -- openCard:setPosition(263,550)
    -- openCard:setPressedActionEnabled(true)
    -- openCard:setTitleText("旁观")
    -- openCard:addTouchEventListener(
    --     function(sender,eventType)
    --         if eventType == ccui.TouchEventType.ended then
    --             self:lookOnHandler()
    --         end
    --     end
    -- )
    -- self.container:addChild(openCard)

end
function ZhajinhuaScene:resetOperateButton()
    -- body
    for i,v in ipairs(self.operateButtonUIArray) do
        v:setHighlighted(false)
        v:setEnabled(false)
        v:getChildByName("titleName"):setOpacity(255/2)
    end
    self.xuepin:hide()
    self.showCardButton:hide()
    self.checkDropYes:hide()
    self.checkFollowYes:hide()
    -- self.operateLayer:setPosition(0,0)
    -- local moveby = cc.MoveBy:create(0.5, cc.p(0,-100))
    -- local fun = cc.CallFunc:create(function ()
    --     self.operateLayer:setPosition(0,-100)
    -- end)
    -- self.operateLayer:runAction(cc.Sequence:create(moveby,fun))
end
--@params state 0 隐藏 1显示
function ZhajinhuaScene:playerOperateAction(state)
    if state == 0 then
        self.operateLayer:setPosition(0,0)
        local moveby = cc.MoveTo:create(0.4, cc.p(0,-200))
        local fun = cc.CallFunc:create(function ()
            self.operateLayer:setPosition(0,-200)
        end)
        self.operateLayer:runAction(cc.Sequence:create(moveby,fun))
    else
        self.operateLayer:setPosition(0,-200)
        local moveby = cc.MoveTo:create(0.4, cc.p(0,0))
        local fun = cc.CallFunc:create(function ()
            self.operateLayer:setPosition(0,0)
        end)
        self.operateLayer:runAction(cc.Sequence:create(moveby,fun))   
    end
end
function ZhajinhuaScene:updateOperatePosition()
    if DataManager:getMyUserStatus()== Define.US_LOOKON  or DataManager:getMyUserStatus() ~= Define.US_PLAYING or DateModel:getInstance():getIsDropped() then
        self.operateLayer:setPosition(0,-200)
        return
    end
    if DateModel:getInstance():getGameStart() then
        self:playerOperateAction(1)
    else
        self:playerOperateAction(0)
    end
end
--游戏操作按钮 状态更新
function ZhajinhuaScene:updateOperateButton()
    -- local count = #OPERATEBUTTON
    -- for i=1,count do
    --     local status = DateModel:getInstance():getOperateButtonStatus(i)
    --     if status == 1 then
    --         self.operateButtonUIArray[i]:setEnabled(true)
    --         self.operateButtonUIArray[i]:setHighlighted(true)
    --     else
    --         self.operateButtonUIArray[i]:setEnabled(false)
    --         self.operateButtonUIArray[i]:setHighlighted(false)
    --     end
    -- end
    if DataManager:getMyUserStatus()== Define.US_LOOKON then
        self:resetOperateButton()
        return
    end
    local updatebutton = {OPERATEBUTTON.B_DROP,OPERATEBUTTON.B_LOOK,OPERATEBUTTON.B_COMPARE,OPERATEBUTTON.B_MAX,OPERATEBUTTON.B_FOLLOW}
    for key,i in ipairs(updatebutton) do
    
        if DateModel:getInstance():getMyTurn() then
            self.operateButtonUIArray[i]:setEnabled(true)
            -- self.operateButtonUIArray[i]:setHighlighted(true)
            self.operateButtonUIArray[i]:loadTextures("zhajinhua/buttonSelected.png","zhajinhua/buttonSelected.png")
            self.operateButtonUIArray[i]:getChildByName("titleName"):setOpacity(255)
        else
            self.operateButtonUIArray[i]:setEnabled(false)
            -- self.operateButtonUIArray[i]:setHighlighted(false)
            self.operateButtonUIArray[i]:loadTextures("zhajinhua/button.png","zhajinhua/button.png")
            self.operateButtonUIArray[i]:getChildByName("titleName"):setOpacity(255/2)
        end
    end
    if 1 or DateModel:getInstance():getAutoFollow() or DateModel:getInstance():getMyTurn() then        
        -- self.operateButtonUIArray[OPERATEBUTTON.B_FOLLOW]:setHighlighted(true)
        self.operateButtonUIArray[OPERATEBUTTON.B_FOLLOW]:loadTextures("zhajinhua/buttonSelected.png","zhajinhua/buttonSelected.png")
        self.operateButtonUIArray[OPERATEBUTTON.B_FOLLOW]:getChildByName("titleName"):setOpacity(255)
    else
        -- self.operateButtonUIArray[OPERATEBUTTON.B_FOLLOW]:setHighlighted(false)
        self.operateButtonUIArray[OPERATEBUTTON.B_FOLLOW]:loadTextures("zhajinhua/button.png","zhajinhua/button.png")
        self.operateButtonUIArray[OPERATEBUTTON.B_FOLLOW]:getChildByName("titleName"):setOpacity(255/2)
    end
    self.operateButtonUIArray[OPERATEBUTTON.B_FOLLOW]:setEnabled(true)
    if 1 or DateModel:getInstance():getAutoDrop() or DateModel:getInstance():getMyTurn() then
        -- self.operateButtonUIArray[OPERATEBUTTON.B_DROP]:setHighlighted(true)
        self.operateButtonUIArray[OPERATEBUTTON.B_DROP]:loadTextures("zhajinhua/buttonSelected.png","zhajinhua/buttonSelected.png")
        self.operateButtonUIArray[OPERATEBUTTON.B_DROP]:getChildByName("titleName"):setOpacity(255)
    else
        -- self.operateButtonUIArray[OPERATEBUTTON.B_DROP]:setHighlighted(false)
        self.operateButtonUIArray[OPERATEBUTTON.B_DROP]:loadTextures("zhajinhua/button.png","zhajinhua/button.png")
        self.operateButtonUIArray[OPERATEBUTTON.B_DROP]:getChildByName("titleName"):setOpacity(255/2)
    end
    self.operateButtonUIArray[OPERATEBUTTON.B_DROP]:setEnabled(true)

    
    if DateModel:getInstance():getLookCard() == 0 and DataManager:getMyUserStatus() == Define.US_PLAYING then
        -- self.operateButtonUIArray[OPERATEBUTTON.B_LOOK]:setHighlighted(true)
        self.operateButtonUIArray[OPERATEBUTTON.B_LOOK]:loadTextures("zhajinhua/buttonSelected.png","zhajinhua/buttonSelected.png")
        self.operateButtonUIArray[OPERATEBUTTON.B_LOOK]:setEnabled(true)
        self.operateButtonUIArray[OPERATEBUTTON.B_LOOK]:getChildByName("titleName"):setOpacity(255)
    else
        -- self.operateButtonUIArray[OPERATEBUTTON.B_LOOK]:setHighlighted(false)
        self.operateButtonUIArray[OPERATEBUTTON.B_LOOK]:loadTextures("zhajinhua/button.png","zhajinhua/button.png")
        self.operateButtonUIArray[OPERATEBUTTON.B_LOOK]:setEnabled(false)
        self.operateButtonUIArray[OPERATEBUTTON.B_LOOK]:getChildByName("titleName"):setOpacity(255/2)
    end
    if DateModel:getInstance():getMyTurn() then
            self.operateButtonUIArray[OPERATEBUTTON.B_COMPARE]:setEnabled(false)
            -- self.operateButtonUIArray[OPERATEBUTTON.B_COMPARE]:setHighlighted(false)
            self.operateButtonUIArray[OPERATEBUTTON.B_COMPARE]:loadTextures("zhajinhua/button.png","zhajinhua/button.png")
            self.operateButtonUIArray[OPERATEBUTTON.B_COMPARE]:getChildByName("titleName"):setOpacity(255/2)
        if DataManager:getMyChairID() == DateModel:getInstance():getBankerUser() then
            self.operateButtonUIArray[OPERATEBUTTON.B_COMPARE]:setEnabled(true)
            -- self.operateButtonUIArray[OPERATEBUTTON.B_COMPARE]:setHighlighted(true)
            self.operateButtonUIArray[OPERATEBUTTON.B_COMPARE]:loadTextures("zhajinhua/buttonSelected.png","zhajinhua/buttonSelected.png")
            self.operateButtonUIArray[OPERATEBUTTON.B_COMPARE]:getChildByName("titleName"):setOpacity(255)
        else
            if DateModel:getInstance():getTableGoldPlayerValue(self:getPlayerIndexByChairID(DataManager:getMyChairID()))==nil or DateModel:getInstance():getCellScore()==nil then
                print("更新操作按钮报错了··CellScore·",DateModel:getInstance():getCellScore(),"getMyChairID",DataManager:getMyChairID(),"getPlayerIndexByChairID",self:getPlayerIndexByChairID(DataManager:getMyChairID()))
                print("TableGoldPlayerValue",DateModel:getInstance():getTableGoldPlayerValue(self:getPlayerIndexByChairID(DataManager:getMyChairID())))
            else
                if DateModel:getInstance():getOriginCellScore()< DateModel:getInstance():getTableGoldPlayerValue(self:getPlayerIndexByChairID(DataManager:getMyChairID())) then
                    self.operateButtonUIArray[OPERATEBUTTON.B_COMPARE]:setEnabled(true)
                    -- self.operateButtonUIArray[OPERATEBUTTON.B_COMPARE]:setHighlighted(true)
                    self.operateButtonUIArray[OPERATEBUTTON.B_COMPARE]:loadTextures("zhajinhua/buttonSelected.png","zhajinhua/buttonSelected.png")
                    self.operateButtonUIArray[OPERATEBUTTON.B_COMPARE]:getChildByName("titleName"):setOpacity(255)
                end
            end
        end
    end
end
--桌面上的筹码数值
function ZhajinhuaScene:createTableGoldUI()
    self.tableGoldUIArray = {}
    self.tableGoldUIArrayValue = {}
    self.tableGoldBgUI = {}
    local tableGoldBgPos = {cc.p(348,471),cc.p(327,310),cc.p(654,216),cc.p(803,308),cc.p(769,467)}
    for i=1,5 do
        local tableGoldBg = ccui.ImageView:create("zhajinhua/tableGoldBg.png")
        tableGoldBg:setPosition(tableGoldBgPos[i])
        self.container:addChild(tableGoldBg,LAYER_Z_ORDER.Z_TABLEGOLD)  
        self.tableGoldBgUI[i] = tableGoldBg

        local tableGold = ccui.Text:create("0","",18)
        tableGold:setPosition(33, 16)
        tableGold:setColor(cc.c3b(255, 255, 255))
        tableGold:setAnchorPoint(cc.p(0,0.5))
        tableGoldBg:addChild(tableGold)
        self.tableGoldUIArray[i] = tableGold
        -- self.tableGoldUIArrayValue[i] = 0
        DateModel:getInstance():setTableGoldPlayerValue(i,0)
    end
    local tableGoldTotalBg = ccui.ImageView:create("zhajinhua/nameBg.png")
    tableGoldTotalBg:setContentSize(cc.size(183,30))
    tableGoldTotalBg:setScale9Enabled(true)
    tableGoldTotalBg:setPosition(561, 415+25)
    self.container:addChild(tableGoldTotalBg,LAYER_Z_ORDER.Z_TABLEGOLD)
    local total = ccui.Text:create("总注：","",20)
    total:setPosition(30, 15)
    total:setColor(cc.c3b(255, 255, 255))
    total:setAnchorPoint(cc.p(0,0.5))
    tableGoldTotalBg:addChild(total)
    local tableGoldTotal = ccui.Text:create("0","",20)
    tableGoldTotal:setPosition(90, 15)
    tableGoldTotal:setColor(cc.c3b(255, 255, 255))
    tableGoldTotal:setAnchorPoint(cc.p(0,0.5))
    tableGoldTotalBg:addChild(tableGoldTotal)
    self.tableGoldTotal = tableGoldTotal
    -- self.tableGoldTotalValue = 0
    DateModel:getInstance():setTableGoldTotalValue(0)
end
--筹码注数选择界面
function ZhajinhuaScene:createChipLayer()
    local chipLayer = ccui.Layout:create()
    -- chipLayer:setAnchorPoint(cc.p(0.5,0.5))
    chipLayer:setContentSize(cc.size(208,520))
    chipLayer:setPosition(30,-chipLayer:getContentSize().height-120)
    -- chipLayer:setBackGroundColorType(1)
    -- chipLayer:setBackGroundColor(cc.c3b(100,123,100))
    self.container:addChild(chipLayer, LAYER_Z_ORDER.Z_CHIPLAYER)
    self.chipLayer = chipLayer

    local chipBg = ccui.ImageView:create("common/pop_bg2.png")
    chipBg:setScale9Enabled(true)
    chipBg:setContentSize(cc.size(208,520))
    chipBg:setAnchorPoint(cc.p(0,0))
    chipLayer:addChild(chipBg)
    self.chipButtonUIArray = {}
    for i=1,10 do
        local vx = math.ceil(i/5)-1
        local vy = (i-1)%5+1-1
        local chipButton = ccui.Button:create("zhajinhua/"..i..".png","zhajinhua/"..i..".png","zhajinhua/gray"..i..".png")
        chipButton:setPosition(104*vx+52, 104*4+52-vy*104)
        chipButton:setTag(i)
        chipLayer:addChild(chipButton)
        chipButton:addTouchEventListener(
            function (sender,eventType  )
                if eventType == ccui.TouchEventType.ended then
                    self:addScoreHandler(sender)
                end
            end
        )
        self.chipButtonUIArray[i] = chipButton
    end
end
--选择筹码注数
function ZhajinhuaScene:addScoreHandler( sender )
    local tag = sender:getTag()
    self:followCard(tag*DateModel:getInstance():getCellScore())
    -- Hall.showTips("加码"..tag, 1)
    self:changeChipLayerState(0)
end
ZhajinhuaScene.state = 0
function ZhajinhuaScene:changeChipLayerState(state)
    -- state = self.state%2
    -- self.state = self.state+1
    if state == 1 then
        local move = cc.MoveTo:create(0.2,cc.p(30,0))
        local funpos = cc.CallFunc:create(function ()
            self.chipLayer:setPosition(30,0)
        end)
        self.chipLayer:runAction(cc.Sequence:create(move,funpos) )
    else
        local move = cc.MoveTo:create(0.2,cc.p(30,-self.chipLayer:getContentSize().height-120))
        local funpos = cc.CallFunc:create(function ()
            self.chipLayer:setPosition(30,-self.chipLayer:getContentSize().height-120)
        end)
        self.chipLayer:runAction(cc.Sequence:create(move,funpos))
    end
end
function ZhajinhuaScene:updateChipButton()
    -- body
    for i,v in ipairs(self.chipButtonUIArray) do
        if i>= DateModel:getInstance():getCurrentTimes() then
            v:setBright(true)
            v:setEnabled(true)
        else
            v:setBright(false)
            v:setEnabled(false)
        end
    end
    
end
--更新比赛场筹码按钮状态
function ZhajinhuaScene:updateOperateCompeteButton()
    if self:checkIsCompeteRoom() == false then
        return
    end
    local lookcard = 1
    if DateModel:getInstance():getLookCard()==1 then
        lookcard = 2
    end
    for i,v in ipairs(self.operateCompeteButtonUIArray) do
        if i>= DateModel:getInstance():getCurrentTimes() then
            v:show()
            v:setTitleFontName(FONT_ART_TEXT);
            v:setTitleText(math.pow(2,i-1)*DateModel:getInstance():getCellScore()*lookcard);
            v:setPressedActionEnabled(true)
            v:setTitleColor(cc.c3b(255,255,255));
            v:setTitleFontSize(28);
            v:getTitleRenderer():enableOutline(COLOR_BTN_BLUE,2)
        else
            v:hide()

        end
    end
    if self:checkAllIn() then
        self.operateCompeteButtonUIArray[3]:loadTextures("zhajinhua/competeRoom/allinBtn.png","zhajinhua/competeRoom/allinBtn.png")
        self.operateCompeteButtonUIArray[3]:setTitleText("All In")
    else
        self.operateCompeteButtonUIArray[3]:loadTextures("zhajinhua/competeRoom/addBtn.png","zhajinhua/competeRoom/addBtn.png")
    end
end
function ZhajinhuaScene:resetData()
    -- self.tableGoldUIArrayValue = {0,0,0,0,0}
    -- self.tableGoldTotalValue = 0
    for i=1,5 do
        DateModel:getInstance():setTableGoldPlayerValue(i,0)
    end
    DateModel:getInstance():setTableGoldTotalValue(0)
end
function ZhajinhuaScene:standUpHandler()
    TableInfo:sendUserStandUpRequest()
end
function ZhajinhuaScene:lookOnHandler()
    local tableID = DateModel:getInstance():getTableID() or 1
    local chairID = DateModel:getInstance():getChairID() or 1
    print("旁观在",tableID,chairID)

    TableInfo:sendUserStandUpRequest()
    TableInfo:sendUserLookonRequest(tableID, chairID, "")
end
function ZhajinhuaScene:compareCardHandler()
    -- body
end
function ZhajinhuaScene:startHandler( sender )

    self.start:hide()
    if self:checkSelfLookOn() == false then
        self:msgReady()
    end
    self.playerInfo[3]["progressTimer"]:hide()
    self.playerInfo[3]["progressTimer"]:stop()

    self:stopActionByTag(100)
    -- Hall.showTips("msgReady发协议号"..CMD_GameServer.MDM_GF_FRAME.."---"..CMD_GameServer.SUB_GF_GAME_OPTION, 2)
end
function ZhajinhuaScene:operateCompeteHandler(sender)
    local tag = sender:getTag()
    local currentTime = 1
    if tag == 1 then
        currentTime = 1
    elseif tag == 2 then
        currentTime = 2
    elseif tag == 3 then
        currentTime = 4
        self.allIn = self:checkAllIn()
    end
    if self.allIn == true then
        self:compareAll()
    else
        
        if DateModel:getInstance():getMyTurn() then
            self:followCard(DateModel:getInstance():getCellScore()*currentTime)
        else
            self.checkDropYes:hide()
            DateModel:getInstance():setAutoDrop(false)
            if DateModel:getInstance():getAutoFollow() then
                self.checkFollowYes:hide()
                DateModel:getInstance():setAutoFollow(false)
            else
                self.checkFollowYes:show()
                DateModel:getInstance():setAutoFollow(true)
                -- self.operateButtonUIArray[OPERATEBUTTON.B_FOLLOW]:setHighlighted(true)
                self.operateButtonUIArray[OPERATEBUTTON.B_FOLLOW]:loadTextures("zhajinhua/buttonSelected.png","zhajinhua/buttonSelected.png")
                self.operateButtonUIArray[OPERATEBUTTON.B_FOLLOW]:getChildByName("titleName"):setOpacity(255)

            end
        end
    end
end
function ZhajinhuaScene:operateHandler( sender )
    -- body
    local tag = sender:getTag()
    if tag == 1 then--"弃牌"
        if DateModel:getInstance():getMyTurn() then
            self:dropCard()
        else
            self.checkFollowYes:hide()
            DateModel:getInstance():setAutoFollow(false)
            if DateModel:getInstance():getAutoDrop() then
                self.checkDropYes:hide()
                DateModel:getInstance():setAutoDrop(false)
                -- self.operateButtonUIArray[OPERATEBUTTON.B_DROP]:setHighlighted(false)
                -- self.operateButtonUIArray[OPERATEBUTTON.B_DROP]:loadTextures("zhajinhua/button.png","zhajinhua/button.png")
                -- self.operateButtonUIArray[OPERATEBUTTON.B_DROP]:getChildByName("titleName"):setOpacity(255/2)
            else
                self.checkDropYes:show()
                DateModel:getInstance():setAutoDrop(true)
                -- self.operateButtonUIArray[OPERATEBUTTON.B_DROP]:setHighlighted(true)
                self.operateButtonUIArray[OPERATEBUTTON.B_DROP]:loadTextures("zhajinhua/buttonSelected.png","zhajinhua/buttonSelected.png")
                self.operateButtonUIArray[OPERATEBUTTON.B_DROP]:getChildByName("titleName"):setOpacity(255)
                -- self.operateButtonUIArray[OPERATEBUTTON.B_FOLLOW]:setHighlighted(false)
                -- self.operateButtonUIArray[OPERATEBUTTON.B_FOLLOW]:getChildByName("titleName"):setOpacity(255/2)
            end
        end        
    elseif tag == 2 then--,"看牌"

        local main = CMD_GameServer.MDM_GF_GAME
        local sub = CMD_ZJH.SUB_C_LOOK_CARD
        
        GameConnection:sendCommand(sub,0,nil,0)
    elseif tag == 3 then--,"比牌"
        if DateModel:getInstance():getMyTurn() then
            local otherPlayer = {}
            for id=1,5 do
                userInfo = DataManager:getUserInfoInMyTableByChairIDExceptLookOn(id)
                if userInfo and userInfo.userStatus == Define.US_PLAYING and userInfo.chairID ~= DataManager:getMyChairID() then
                    -- print("userInfo.chairID",userInfo.chairID)
                    -- self:compareCard(userInfo.chairID)
                    local same = 0
                    for i,v in ipairs(self.dropChairID) do
                        if userInfo.chairID == v then
                            same = same+1
                        end
                    end
                    if same == 0 then
                        table.insert(otherPlayer, userInfo)
                    end
                end
            end
            if #otherPlayer>1 then
                if not self.cardView then
                    self.cardView = require("zhajinhua.ViewCardLayer_New").new({dataModel=DateModel:getInstance(),effectLayer=self.effectlayer})
                    self.container:addChild(self.cardView, LAYER_Z_ORDER.Z_CARD)
                    self.cardView:showCompareHand(otherPlayer,self.chairArry,function(compareUserChairID) self:compareCard(compareUserChairID) end)
                else
                    self.cardView:showCompareHand(otherPlayer,self.chairArry,function(compareUserChairID) self:compareCard(compareUserChairID) end)
                end
            else
                self:compareCard(otherPlayer[1].chairID)
            end
        end
    elseif tag == 4 then--"加满",

        if DateModel:getInstance():getMyTurn() then
            self:followCard(DateModel:getInstance():getMaxScore())
        end

    elseif tag == 5 then--,"跟注"

        if DateModel:getInstance():getMyTurn() then
            self:followCard(DateModel:getInstance():getCellScore()*DateModel:getInstance():getCurrentTimes())
        else
            self.checkDropYes:hide()
            DateModel:getInstance():setAutoDrop(false)
            if DateModel:getInstance():getAutoFollow() then
                self.checkFollowYes:hide()
                DateModel:getInstance():setAutoFollow(false)
                -- self.operateButtonUIArray[OPERATEBUTTON.B_FOLLOW]:setHighlighted(false)
                -- self.operateButtonUIArray[OPERATEBUTTON.B_FOLLOW]:loadTextures("zhajinhua/button.png","zhajinhua/button.png")
                -- self.operateButtonUIArray[OPERATEBUTTON.B_FOLLOW]:getChildByName("titleName"):setOpacity(255/2)
            else
                self.checkFollowYes:show()
                DateModel:getInstance():setAutoFollow(true)
                -- self.operateButtonUIArray[OPERATEBUTTON.B_FOLLOW]:setHighlighted(true)
                self.operateButtonUIArray[OPERATEBUTTON.B_FOLLOW]:loadTextures("zhajinhua/buttonSelected.png","zhajinhua/buttonSelected.png")
                self.operateButtonUIArray[OPERATEBUTTON.B_FOLLOW]:getChildByName("titleName"):setOpacity(255)
                -- self.operateButtonUIArray[OPERATEBUTTON.B_DROP]:setHighlighted(false)
                -- self.operateButtonUIArray[OPERATEBUTTON.B_DROP]:getChildByName("titleName"):setOpacity(255/2)

            end
        end
    end
end
function ZhajinhuaScene:xuepinHandler( sender )
    if DateModel:getInstance():getXuePin() then
        DateModel:getInstance():setXuePin(false)
        self.xuepin:setHighlighted(false)
    else
        DateModel:getInstance():setXuePin(true)
        self.xuepin:setHighlighted(true)
        if DateModel:getInstance():getMyTurn() then
            self:followCard(DateModel:getInstance():getCellScore()*DateModel:getInstance():getCurrentTimes())
        else
            print("不是自己回合")
        end
    end
end

function ZhajinhuaScene:showCardHandler(sender)
    self:showCard()
    self.showCardButton:hide()
end

function ZhajinhuaScene:initTable()
    --滚动消息
    local scrollTextContainer = ccui.Layout:create()
    scrollTextContainer:setContentSize(cc.size(600,30))
    scrollTextContainer:setPosition(cc.p(display.left + 100, display.top - 60))
    self.container:addChild(scrollTextContainer, 100)--LAYER_Z_ORDER.Z_POPMSG
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

--送道具
function ZhajinhuaScene:clickPropertyHandler(sender)
    local targetUserID = DataManager:getUserInfoInMyTableByChairIDExceptLookOn(self.chairArry[sender:getTag()]).userID
    local event = {targetUserID=targetUserID,sceneID=2,sendGiftFunc=function(self,event) self:sendGift(self,event) end,sendGiftCallBackTarget = self}

    if targetUserID then
        if self.giftInfoLayer == nil then
            self.giftInfoLayer = require("zhajinhua.GiftInfo2Layer").new(event)
            -- self.giftInfoLayer:addEventListener(GameCenterEvent.EVENT_BUY_PROPERTY, handler(self, self.sendGift))
            self.giftInfoLayer:addTo(self.container, LAYER_Z_ORDER.Z_EFFECT)
        end
        print("onSendProperty:",targetUserID,tostring(self))
        self.giftInfoLayer:showGiftInfo2Layer(targetUserID,self.targetUserIDArray)
    end
end
function ZhajinhuaScene:onClickCup(event)
    print("onClickCup")
    dump(event,"event")
    local targetUserID = event.targetUserID--DataManager:getUserInfoInMyTableByChairIDExceptLookOn(self.chairArry[sender:getTag()]).userID
    local event = {targetUserID=targetUserID,sceneID=2,sendGiftFunc=function(self,event) self:sendGift(self,event) end,sendGiftCallBackTarget = self}

    if targetUserID then
        if self.giftInfoLayer == nil then
            self.giftInfoLayer = require("zhajinhua.GiftInfo2Layer").new(event)
            -- self.giftInfoLayer:addEventListener(GameCenterEvent.EVENT_BUY_PROPERTY, handler(self, self.sendGift))
            self.giftInfoLayer:addTo(self.container, LAYER_Z_ORDER.Z_EFFECT)
        end
        print("onSendProperty:",targetUserID,tostring(self))
        self.giftInfoLayer:showGiftInfo2Layer(targetUserID,self.targetUserIDArray)
    end
end
function ZhajinhuaScene:sendGift(self,event)
    -- if DateModel:getInstance():getGameStart() == false then
    --     Hall.showTips("游戏开始后才可以赠送噢！")
    --     return
    -- end
    dump(event, "event")
    dump(self, "self")
    print("ZhajinhuaScene-sendGift",tostring(self))
    self.giftInfoLayer:hide()
    local giftIndex = event.giftIndex
    local giftPrice = event.giftPrice
    local giftCount = event.giftCount
    local targetUserID = event.targetUserID

    if (giftPrice * giftCount) > DataManager:getMyUserInfo().score then
        Hall.showTips("您的金币不足！", 1.0)
        --return
    end

    self.sendGiftUserIdArray[#self.sendGiftUserIdArray + 1] = targetUserID

    PropertyInfo:sendBuyPropertyRequest(giftIndex, giftCount)
end

function ZhajinhuaScene:onBuyPropertySuccess(event)
    print(self.sendGiftUserIdArray[1],"PropertyInfo.buyPropertyResult.propertyID",PropertyInfo.buyPropertyResult.propertyID, "PropertyInfo.buyPropertyResult.propertyCount",PropertyInfo.buyPropertyResult.propertyCount)
    if PropertyInfo.buyPropertyResult.code == 1 then
        --开始使用道具
        PropertyInfo:sendUsePropertyRequest(PropertyInfo.buyPropertyResult.propertyID, PropertyInfo.buyPropertyResult.propertyCount,self.sendGiftUserIdArray[1])
    elseif PropertyInfo.buyPropertyResult.code == 2 then
        print("----非法道具号---")
    elseif PropertyInfo.buyPropertyResult.code == 3 then
        print("----道具数量错误---")
    elseif PropertyInfo.buyPropertyResult.code == 4 then
        print("----金币不够---")
    elseif PropertyInfo.buyPropertyResult.code == 5 then
        print("----RC_SERVER_TYPE_CANNOT_BUY---")
    end

    table.remove(self.sendGiftUserIdArray, 1)
end

--周边功能 入口按钮
function ZhajinhuaScene:createOtherUI()
    local rule = ccui.Button:create("zhajinhua/rule.png","zhajinhua/rule.png")
    rule:setPosition(23, 311)
    rule:setPressedActionEnabled(true)
    rule:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:ruleHandler()
            end
        end
    )
    self.container:addChild(rule)

    local bank = ccui.Button:create("zhajinhua/bank.png","zhajinhua/bank.png")
    bank:setPosition(1095, 460)--1004
    bank:setPressedActionEnabled(true)
    bank:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:bankHandler()
            end
        end
    )
    self.container:addChild(bank)

    -- local boxClose = ccui.Button:create("zhajinhua/boxClose.png","zhajinhua/boxClose.png")
    -- boxClose:setPosition(1095, 593)
    -- boxClose:setPressedActionEnabled(true)
    -- boxClose:addTouchEventListener(
    --     function(sender,eventType)
    --         if eventType == ccui.TouchEventType.ended then
    --             self:boxCloseHandler()
    --         end
    --     end
    -- )
    -- self.container:addChild(boxClose)
    local chat = ccui.Button:create("zhajinhua/chat.png","zhajinhua/chat.png")
    chat:setPosition(1093, 200)
    chat:setPressedActionEnabled(true)
    chat:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:chatHandler()
            end
        end
    )
    self.container:addChild(chat)

    local playerList = ccui.Button:create("zhajinhua/playerList.png","zhajinhua/playerList.png")
    playerList:setPosition(1093, 118)
    playerList:setPressedActionEnabled(true)
    playerList:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:playerListHandler()
            end
        end
    )
    self.container:addChild(playerList)
end
--玩家列表
function ZhajinhuaScene:playerListHandler()
    -- require("hall.ChatPersonListLayer").new(self):addTo(self.container, LAYER_Z_ORDER.Z_PLAYER_LIST)
    local chatPersonListLayer = require("hall.ChatPersonListLayer").new(self);
    chatPersonListLayer:setPosition(0,0)
    self.container:addChild(chatPersonListLayer,LAYER_Z_ORDER.Z_PLAYER_LIST);
end
--聊天框
function ZhajinhuaScene:chatHandler()

    self.chatWindow:showChat()
end
--宝箱
function ZhajinhuaScene:boxCloseHandler()
    -- body
end
--银行
function ZhajinhuaScene:bankHandler()
    local bank = require("hall.BankLayer").new(true);
    bank:setPosition(0,0)
    self.container:addChild(bank,LAYER_Z_ORDER.Z_BANK);

    Click();
end
--游戏规则，比牌大小
function ZhajinhuaScene:ruleHandler()
    if self.RuleLayer then
        self.RuleLayer:show()
        self.RuleLayer:slideOut()
    else
        self.RuleLayer = require("zhajinhua.RuleLayer").new()
        self.container:addChild(self.RuleLayer, LAYER_Z_ORDER.Z_RULELAYER)
        self.RuleLayer:slideOut()
    end
end
function ZhajinhuaScene:gotoRoomScene()
    if DataManager:getMyUserStatus() == Define.US_PLAYING then
        
        local canQuick = false
        for i,v in ipairs(self.dropChairID) do
            if v == DataManager:getMyChairID() then
                TableInfo:sendUserStandUpRequest(true)
                canQuick = true
                break
            end
        end
        if canQuick == false then
            Hall.showTips("游戏还在进行中，不能退出游戏!", 1)
            return
        end
    else
        TableInfo:sendUserStandUpRequest(false)
    end
    self:removeGameEvent()
    if self:checkIsCompeteRoom() then--非正式账号BindMobilePhone == false and AccountType == 1
        GameConnection:closeRoomSocketDelay(0)
        local roomScene = require("hall.RoomScene_New")
        cc.Director:getInstance():replaceScene(cc.TransitionSlideInT:create(0.5, roomScene.new()))
    else
        if RunTimeData:getRoomIndex() == 1 then
            GameConnection:closeRoomSocketDelay(0)
            print("退到大厅****")
            local roomScene = require("hall.RoomScene_New")
            cc.Director:getInstance():replaceScene(cc.TransitionSlideInT:create(0.5, roomScene.new()))
        else
            local roomScene = require("hall.SelectTableScene_New")
            cc.Director:getInstance():replaceScene(cc.TransitionSlideInT:create(0.5, roomScene.new()))
        end
    end

end
--检测自己是否处于旁观状态
function ZhajinhuaScene:checkSelfLookOn()
    return DataManager:getMyUserStatus() == Define.US_LOOKON
end
function ZhajinhuaScene:getPlayerIndexByChairID(chairID)
    local index = -1
    for j,w in ipairs(self.chairArry) do
        if chairID == w then
            index = j
            break
        end
    end
    return index
end
--开启 开始游戏倒计时
function ZhajinhuaScene:startSelfAutoTimer()
    local myChairID = DataManager:getMyChairID()
    local myIndex = self:getPlayerIndexByChairID(myChairID)
    print(#self.chairArry,"startSelfAutoTimer--myIndex",myIndex,"myChairID",myChairID)
    self.playerInfo[myIndex]["progressTimer"]:show()
    self.playerInfo[myIndex]["progressTimer"]:showByLeftTime(10, 10)
    local callback =  function ()
        self.playerInfo[myIndex]["progressTimer"]:hide()
        self.playerInfo[myIndex]["progressTimer"]:stop()
        self:startHandler()
        
    end
    local delay = cc.DelayTime:create(10)
    local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callback))
    sequence:setTag(100)
    self:runAction(sequence)
end
function ZhajinhuaScene:registerEventListener()
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

    self.bindIds[#self.bindIds + 1] = BindTool.bind(SystemMessageInfo, "msgRresh", handler(self, self.refreshSysMsgRresh))
end

function ZhajinhuaScene:refreshSysMsgRresh(event)

    if event.value == 21 then--奖励消息
        self:showScrollMessage(SystemMessageInfo.curMessage)
    end

end


function ZhajinhuaScene:removeGameEvent()
    for _, bindid in ipairs(self.bindIds) do
        BindTool.unbind(bindid)
    end
    GameConnection:removeEventListener(self.connected_handler)
end
function ZhajinhuaScene:msgReady()
    if DateModel:getInstance():getIsCompeteRoom() == false then
        TableInfo:sendUserReadyRequest()
    end
    
    -- Hall.showTips("msgReady发协议号"..CMD_GameServer.MDM_GF_FRAME.."---"..CMD_GameServer.SUB_GF_USER_READY, 2)
end
--检测是否是比赛场
function ZhajinhuaScene:checkIsCompeteRoom()
    return DateModel:getInstance():getIsCompeteRoom() == true
end
--判断是否开牌，开牌返回TRUE ,不开牌false
--1.钱不够下一次跟注就开牌
--2.下注的钱超过最大下注就开牌
function ZhajinhuaScene:checkOpenCard()
    local result = false
    local myGold = DataManager:getMyUserInfo().score
    local lookcard = 1
    if DateModel:getInstance():getLookCard()==1 then
        lookcard = 2
    end
    local chipGold = DateModel:getInstance():getCellScore()*2*lookcard*DateModel:getInstance():getCurrentTimes()
    print("myGold",myGold,"chipGold",chipGold)
    if myGold<2*chipGold then
        result = true
    end

    local myIndex = -1
    for i,v in ipairs(self.chairArry) do
        if v == DataManager:getMyChairID() then
            myIndex = i
        end
    end
    print("getUserMaxScore",DateModel:getInstance():getUserMaxScore(),DateModel:getInstance():getTableGoldPlayerValue(myIndex),chipGold)
    if DateModel:getInstance():getUserMaxScore() - DateModel:getInstance():getTableGoldPlayerValue(myIndex) < chipGold then
        result = true
    end
    return result
end
--判断是否孤注一掷

function ZhajinhuaScene:checkAllIn()
    local result = false
    local myGold = DataManager:getMyUserInfo().score
    local myGoldInGame = DataManager:getMyUserInfo().scoreInGame
    local lookcard = 1
    if DateModel:getInstance():getLookCard()==1 then
        lookcard = 2
    end
    local chipGold = DateModel:getInstance():getCellScore()*1*lookcard*DateModel:getInstance():getCurrentTimes()
    print("checkAllIn孤注一掷myGold",myGold,"chipGold",chipGold,"myGoldInGame",myGoldInGame)
    if myGoldInGame<=chipGold then
        result = true
    end
    return result
end
--用户亮牌
function ZhajinhuaScene:showCard()
    local main = CMD_GameServer.MDM_GF_GAME
    local sub = CMD_ZJH.SUB_C_SHOW_CARD
    
    GameConnection:sendCommand(sub,0,nil,0)
end
--用户开牌
function ZhajinhuaScene:openCard()
    self:compareFollowCard(DateModel:getInstance():getCellScore())
    local main = CMD_GameServer.MDM_GF_GAME
    local sub = CMD_ZJH.SUB_C_OPEN_CARD
    
    GameConnection:sendCommand(sub,0,nil,0)
end
function ZhajinhuaScene:dropCard()
    local main = CMD_GameServer.MDM_GF_GAME
    local sub = CMD_ZJH.SUB_C_GIVE_UP
    
    GameConnection:sendCommand(sub,0,nil,0)
end
--用户跟注
function ZhajinhuaScene:followCard(gold)
    if DateModel:getInstance():getIsCompeteRoom() == true then
        if self:checkAllIn() then
            print("用户跟注-我是孤注一掷")
            self:compareAll()
            return
        end
    else
        if self:checkOpenCard() then
            print("用户跟注-我是开牌")
            self:openCard()
            return
        end
    end

    local addScore = protocol.zhajinhua.zhajinhua.c2s_pb.CMD_C_AddScore_Pro()
    local beishu = 1
    if DateModel:getInstance():getLookCard() == 1 then
        beishu = 2
    end
    addScore.lScore = gold*beishu
    addScore.wState = 0
    print("followCard-followCard-addScore.lScore",addScore.lScore,"addScore.wState",addScore.wState)
    local pData = addScore:SerializeToString()
    local pDataLen = string.len(pData)

    local main = CMD_GameServer.MDM_GF_GAME
    local sub = CMD_ZJH.SUB_C_ADD_SCORE
    
    GameConnection:sendCommand(sub,0,pData,pDataLen)
end
--用户比牌跟注
function ZhajinhuaScene:compareFollowCard(gold)
    local addScore = protocol.zhajinhua.zhajinhua.c2s_pb.CMD_C_AddScore_Pro()
    local beishu = 1
    if DateModel:getInstance():getLookCard() == 1 then
        beishu = 2
    end
    addScore.lScore = gold*beishu*2*DateModel:getInstance():getCurrentTimes()
    addScore.wState = 1
    print("compareFollowCard-addScore.lScore",addScore.lScore,"addScore.wState",addScore.wState)
    local pData = addScore:SerializeToString()
    local pDataLen = string.len(pData)

    local main = CMD_GameServer.MDM_GF_GAME
    local sub = CMD_ZJH.SUB_C_ADD_SCORE
    
    GameConnection:sendCommand(sub,0,pData,pDataLen)
end
--用户比牌
function ZhajinhuaScene:compareCard(compareUserChairID)
    print("用户比牌compareUserChairID",compareUserChairID,"当前单元积分",DateModel:getInstance():getCellScore())
    self:compareFollowCard(DateModel:getInstance():getCellScore())
    local compareCard = protocol.zhajinhua.zhajinhua.c2s_pb.CMD_C_CompareCard_Pro()
    compareCard.wCompareUser = compareUserChairID
    local pData = compareCard:SerializeToString()
    local pDataLen = string.len(pData)

    local main = CMD_GameServer.MDM_GF_GAME
    local sub = CMD_ZJH.SUB_C_COMPARE_CARD
    
    GameConnection:sendCommand(sub,0,pData,pDataLen)
end
--全场比牌ALL IN
function ZhajinhuaScene:compareAll()
    print("全场比牌ALL IN")
    local addScore = protocol.zhajinhua.zhajinhua.c2s_pb.CMD_C_AddScore_Pro()
    local beishu = 1
    if DateModel:getInstance():getLookCard() == 1 then
        beishu = 2
    end
    local normalAddScore = DateModel:getInstance():getCellScore()*beishu*2*DateModel:getInstance():getCurrentTimes()
    local realAddScore = normalAddScore
    if DataManager:getMyUserInfo().scoreInGame < normalAddScore then
        normalAddScore = DataManager:getMyUserInfo().scoreInGame
    end
    addScore.lScore = normalAddScore--gold*beishu*2*DateModel:getInstance():getCurrentTimes()
    addScore.wState = 1
    print("compareAll-addScore.lScore",addScore.lScore,"addScore.wState",addScore.wState)
    local pData = addScore:SerializeToString()
    local pDataLen = string.len(pData)

    local main = CMD_GameServer.MDM_GF_GAME
    local sub = CMD_ZJH.SUB_C_COMPARE_ALL
    
    GameConnection:sendCommand(sub,0,pData,pDataLen)
end
function ZhajinhuaScene:onTimer()

    self.timer = self.timer -1
    if self.timer >= 0 then
        self:performWithDelay(function() self:onTimer() end, 1.0)

        self.competeTime:setString(self:FormatTimeToString(self.timer))
    elseif self.timer <= -999 then
        --todo
    else
        -- self:onClickJX()
    end

end
function ZhajinhuaScene:FormatTimeToString(time)
    local str = ""
    local sec = time%60
    local min = (time-sec)/60
    if min<10 then
        str = str.."0"..min..":"
    else
        str = str..min..":"
    end
    if sec<10 then
        str = str.."0"..sec
    else
        str = str..sec
    end
    return str
end
    ----------协议回调------------
function ZhajinhuaScene:onUsersLookonInfo()
    local response = TableInfo.usersLookonInfo.isAllowLookon
end
function ZhajinhuaScene:onSitDownResult()
    local response = TableInfo.userSitDownResult
    if response.code == nil then
        
    else
        Hall.showTips(response.msg, 2)
    end
end
--登陆返回结果，不一定成功
function ZhajinhuaScene:loginRoomResult(event)
    if RoomInfo.loginResult == false then
        print("------登陆房间失败，code:", RoomInfo.loginResultCode)
    end
end
function ZhajinhuaScene:roomConfigResult()
    print("ZhajinhuaScene:roomConfigResult!!")
    local tableID = DateModel:getInstance():getTableID() or 65535
    local chairID = DateModel:getInstance():getChairID() or 65535
    local lookOn = DateModel:getInstance():getLookOn()
    if BindMobilePhone == false then
        tableID = 65535
        chairID = 65535
        lookOn = 0
    end
    local password = ""
    local allowLookOne = 0
    if DateModel:getInstance():getAllowLookOne() then
        allowLookOne = true
    else
        allowLookOne = false
    end

    
    if lookOn == 0 then
        TableInfo:sendUserSitdownRequest(tableID, chairID, password)
        TableInfo:sendGameOptionRequest(allowLookOne)
        print("onEnter坐下在",tableID,chairID)
    else
        TableInfo:sendUserLookonRequest(tableID, chairID, password)
        print("onEnter旁观在",tableID,chairID)
        self:updateSeatInfo()
    end
end
function ZhajinhuaScene:onSocketStatus(event)
    print(".... ZhajinhuaScene:enterRoomRequest back ...............")
    if event.name == NetworkManagerEvent.SOCKET_CONNECTED then
        RoomInfo:sendLoginRequest(0, 60)
    elseif event.name == NetworkManagerEvent.SOCKET_CLOSED then
        
    elseif event.name == NetworkManagerEvent.SOCKET_CONNECTE_FAILURE then
        
    end
end
function ZhajinhuaScene:onRequestUserMatchInfo()

    DateModel:getInstance():setTableID(MatchInfo.userMatchInfo.tableID)
    DateModel:getInstance():setChairID(MatchInfo.userMatchInfo.chairID)
    DateModel:getInstance():setCurrentMatchServerID(MatchInfo.userMatchInfo.serverID)

    DateModel:getInstance():setIsCompeteRoom(true)
    GameConnection:closeConnect()
    self:performWithDelay(function ()
        local ZhajinhuaScene = require("zhajinhua.ZhajinhuaScene_New")
        cc.Director:getInstance():replaceScene(cc.TransitionSlideInT:create(0.5, ZhajinhuaScene.new()))
    end, 1)
end
function ZhajinhuaScene:onMatchInfo()
    local matchInfo = MatchInfo.matchInfo
    if matchInfo then
        print(matchInfo.myRanking,matchInfo.userCount,matchInfo.gameTime)
        if matchInfo.gameTime>=120 then
            self.timer = 30-(matchInfo.gameTime-120)%30
        else
            self.timer = 120-matchInfo.gameTime
        end
        self.competeTime:setString(self:FormatTimeToString(self.timer))

        self:performWithDelay(function() self:onTimer() end, 1.0)
        if DateModel:getInstance():getIsCompeteRoom() == true then
            local rank = matchInfo.myRanking
            local total = matchInfo.userCount
            self.competeRank:setString("排名:"..rank.."/"..total)
        end
    end
end
function ZhajinhuaScene:onUserRanking()
    -- if DateModel:getInstance():getIsCompeteRoom() == true then
        local userRank = MatchInfo.userRanking
        -- Hall.showTips("恭喜你在XX比赛场中获得第"..userRank.ranking.."名", 2)
        local competeOver = require("hall.CompeteOverLayer").new(userRank)
        self.container:addChild(competeOver, LAYER_Z_ORDER.Z_COMPETEOVER)
    -- end
end
function ZhajinhuaScene:onCompeteRank()
    if DateModel:getInstance():getIsCompeteRoom() == true then
        local rank = 26
        local total = 99
        self.competeRank:setString("排名:"..rank.."/"..total)
    end

end
function ZhajinhuaScene:onCurrentRound()
    if DateModel:getInstance():getIsCompeteRoom() == true then
        local round = DateModel:getInstance():getCurrentRound()
        self.currentRound:setString("当前第"..round.."手")
    end
end
function ZhajinhuaScene:onUserScore()
    for j=1,5 do
        local playerInfo = DataManager:getUserInfoInMyTableByChairIDExceptLookOn(j)
        if playerInfo and playerInfo.userID == GameUserInfo.userScore.userID then

            -- playerInfo.score=GameUserInfo.userScore
            playerInfo.scoreInGame=GameUserInfo.userScore.score
            local playerIndex = 0
            for i,v in ipairs(self.chairArry) do
                if v== j then
                    playerIndex = i
                end
            end
            local userGold = self.playerInfo[playerIndex]["userGold"]
            userGold:setString(FormatNumToString(playerInfo.scoreInGame))
        end 
    end
    -- if GameUserInfo.userScore.userID == DataManager:getMyUserInfo().userID then
    --     local userScore = GameUserInfo.userScore
    --     if userScore.score>=10000 and  AccountType == 1  and BindMobilePhone == false then
    --         Hall.showTips("你已经不能再试玩场继续游戏，将在5秒后自动退出房间！请前往个人中心绑定手机，之后可以在其他场继续游戏", 5)
    --     end
    --     self:performWithDelay(function()
    --         self:gotoRoomScene()
    --     end, 5)
    --     print("userID",userScore.userID,"score",userScore.score)
    -- end
end
function ZhajinhuaScene:onPaymentNotify()
    local paymentNotify = GameUserInfo.paymentNotify
    print("orderID",paymentNotify.orderID,"score",paymentNotify.score,"payID",paymentNotify.payID)
end
function ZhajinhuaScene:systemNoticeHandler(event)
    local wType = event.wType
    local tipStr = event.szString;
    print(tipStr)
    Hall.showTips("您的筹码不足，将在3秒后自动退出房间！", 3)
    self:performWithDelay(function ()
        self:gotoRoomScene()
    end, 3)
end
function ZhajinhuaScene:onQueryUserInsure(event)
    print("onQueryUserInsure--event",event.score,event.insure)
    -- self:updateSeatInfo()
    if DateModel:getInstance():getGameStart() then
        --todo
    end
end
function ZhajinhuaScene:bankSucceseHandler(event)
    print("bankSucceseHandler--event",event.score,event.insure)
    if DateModel:getInstance():getGameStart() then
        local gamescore = DataManager:getMyUserInfo().scoreInGame + DateModel:getInstance():getQuQianNUm()
        DataManager:getMyUserInfo().scoreInGame(gamescore)
        self:updatePlayerInfo(DataManager:getMyUserInfo(), 3)
        DateModel:getInstance():setQuQianNum(0)
    end
end
function ZhajinhuaScene:onKickUserBack(event)
    local response = TableInfo.kickUserResult
    print("被踢者",response.userID,response.msg)
    
    if response.userID == DataManager:getMyUserID() then
        if response.code == 0 then
            -- self:gotoRoomScene()
            self:alertBox(response.msg)
        end
    else
        if response.code ~= 0 then
            -- local tipArray = {"椅子无效","试玩场桌子,试玩场不允许踢人","魅力值不足","玩家正在游戏中，不能踢出","筹码比被踢者少","等级比被踢者少","踢人失败"}
            local tip =""
            -- if tipArray[response.code] then
            --     tip = tipArray[response.code]
            -- end
            tip =response.msg
            Hall.showTips(tip, 2)
        end
    end
end
function ZhajinhuaScene:alertBox(tip)
    local KickUserAlertLayer = require("zhajinhua.KickUserAlertLayer").new(tip,function ()
        self:gotoRoomScene()
    end)
    self.container:addChild(KickUserAlertLayer,LAYER_Z_ORDER.Z_KICKUSER);
end
function ZhajinhuaScene:onServerGameStatus(event)
    local gameStatus = TableInfo.gameStatus
    -- print("onServerGameStatus--cbAllowLookon",gameStatus.cbAllowLookon)
    -- DateModel:getInstance():setAllowLookFromServer(gameStatus.cbAllowLookon)
end
function ZhajinhuaScene:onServerGameScene(event)

    local gameStatus = TableInfo.gameStatus
    print("gameStatus",gameStatus)
    if self:checkSelfLookOn() == false then

        if gameStatus == Define.GAME_STATUS_FREE then
            --self:msgReady()
            print("场景恢复  空闲状态", gameStatus)

            local msg = protocol.zhajinhua.zhajinhua.s2c_pb.CMD_S_StatusFree_Pro()
            msg:ParseFromString(ZhajinhuaInfo.recoverGameScene)
            self.playConfig = msg
            self:recoverFree(msg)
        elseif gameStatus == 1 then--Define.GAME_STATUS_PLAY
            print("场景恢复 游戏状态",gameStatus)
            local msg = protocol.zhajinhua.zhajinhua.s2c_pb.CMD_S_StatusPlay_Pro()
            msg:ParseFromString(ZhajinhuaInfo.recoverGameScene)
            self.playConfig = msg
            self:recoverGame(msg)
        else
            print("场景恢复  未知状态", gameStatus)
            
        end
    else        
        local msg = protocol.zhajinhua.zhajinhua.s2c_pb.CMD_S_StatusPlay_Pro()
        msg:ParseFromString(ZhajinhuaInfo.recoverGameScene)
        self.playConfig = msg
        self:recoverGame(msg)
    end
end
function ZhajinhuaScene:recoverFree(msg)
    self.playConfig = msg
    if self:checkSelfLookOn() == false and DateModel:getInstance():getIsCompeteRoom() == false then
        self.start:show()
        DateModel:getInstance():setStartButtonClicked(false)
    else
    end
    if self:checkIsCompeteRoom() == false then
        self:startSelfAutoTimer()
    end    
end
function ZhajinhuaScene:recoverGame(msg)
    --[[
    //加注信息
    required int64                          lMaxCellScore       = 1;                        //单元上限
    required int64                          lCellScore      = 2;                            //单元下注
    required int64                          lCurrentTimes       = 3;                        //当前倍数
    required int64                          lUserMaxScore       = 4;                        //用户分数上限

    //状态信息
    required int32                          wBankerUser         = 5;                        //庄家用户
    required int32                          wCurrentUser        = 6;                        //当前玩家
    repeated int32                          cbPlayStatus        = 7;            //游戏状态 1表示还在游戏中0表示放弃或比牌输掉或不在游戏中
    repeated int32                          bMingZhu        = 8;                //看牌状态
    repeated int64                          lTableScore         = 9;            //下注数目

    //扑克信息
    repeated int32                          cbHandCardData      = 10;                   //扑克数据

    //状态信息
    required int32                          bCompareState       = 11;                       //比牌状态  
    ]]
    DateModel:getInstance():setMaxScore(msg.lMaxCellScore)
    DateModel:getInstance():setCellScore(msg.lCellScore)
    DateModel:getInstance():setCurrentTimes(msg.lCurrentTimes)
    DateModel:getInstance():setBankerUser(msg.wBankerUser)
    DateModel:getInstance():setUserMaxScore(msg.lUserMaxScore)
    self:setLookCardAlready(0)
    DateModel:getInstance():setGameStart(true)
    DataManager:getMyUserInfo().scoreInGame = DataManager:getMyUserInfo().score
    self.maxScore:setString(msg.lMaxCellScore)
    self.cellScore:setString(msg.lCellScore)
    self.dropChairID = {}
    self.showCardChairID = {}
    self.playerLeftToOpenCardChairID = {}
    self:updateSeatInfo()
    --打印发的牌
    local shoupai = ""
    local total = #msg.cbHandCardData
    for i=1,total do

        -- shoupai = shoupai..string.format("0x%02x",msg.cbCardData[i])..","--cardInfo[
        shoupai = shoupai..cardInfo[msg.cbHandCardData[i]]
    end
    -- print("扑克数据--",total,"shoupai",shoupai)
    for i,v in ipairs(msg.bMingZhu) do
        -- print("看牌状态",i,v)
        if v == 1 and DataManager:getMyChairID() == i then
            self:setLookCardAlready(1)
        end
        DateModel:getInstance():setLookCardStatus(self:getPlayerIndexByChairID(i), v)
    end
    for i,v in ipairs(msg.cbPlayStatus) do
        -- print("游戏状态",i,v)
        if v==0 then
            table.insert(self.dropChairID,i)
            if i == DataManager:getMyChairID() then
                DateModel:getInstance():setMyTurn(false)
                DateModel:getInstance():setIsDropped(true)
                self:updatePlayerState(i, PLAYERSTATE.S_WAITBEGIN)
            end
        else
            table.insert(self.playerLeftToOpenCardChairID,i)
        end
        DateModel:getInstance():setPlayStatus(self:getPlayerIndexByChairID(i), v)
        self:updatePlayerState(i,PLAYERSTATE.S_NORMAL)
    end
    if DateModel:getInstance():getIsDropped() then
        self.playerLeftToOpenCardChairID = {}
    end

    -- print("当前玩家",msg.wCurrentUser)
    if msg.wCurrentUser~=65535 then
        local index = -1
        for i,v in ipairs(self.chairArry) do
            if v == msg.wCurrentUser then
                index = i
            end
        end
        self.playerInfo[index]["progressTimer"]:show()
        self.playerInfo[index]["progressTimer"]:showByLeftTime(20, 20)
    end
    local totalTableScore = 0
    for i,score in ipairs(msg.lTableScore) do
        -- print(i,score)
        local index = -1
        for j,v in ipairs(self.chairArry) do
            if v == i then
                index = j
            end
        end
        DateModel:getInstance():setTableGoldPlayerValue(index, score)
        totalTableScore = totalTableScore+score
    end
    DateModel:getInstance():setTableGoldTotalValue(totalTableScore)
    for i=1,5 do
        self.tableGoldUIArray[i]:setString(DateModel:getInstance():getTableGoldPlayerValue(i))        
    end
    self.tableGoldTotal:setString(DateModel:getInstance():getTableGoldTotalValue())
    self:updateMoneyInGame()
    ---更新游戏下标状态start
    for i=1,5 do
        userInfo = DataManager:getUserInfoInMyTableByChairIDExceptLookOn(self.chairArry[i])
        -- print("i",i,DateModel:getInstance():getLookCardStatus(i),"myIndex",self:getPlayerIndexByChairID(DataManager:getMyChairID()))
        if userInfo then
            if DateModel:getInstance():getTableGoldPlayerValue(i)>DateModel:getInstance():getCellScore() then
                self:updatePlayerState(userInfo.chairID, PLAYERSTATE.S_FOLLOW)
            end
            if DateModel:getInstance():getLookCardStatus(i) == 1 then
                self:updatePlayerState(userInfo.chairID, PLAYERSTATE.S_LOOK)
            end
            if userInfo.userStatus == Define.US_PLAYING and DateModel:getInstance():getPlayStatus(i) == 0 then
                self:updatePlayerState(userInfo.chairID, PLAYERSTATE.S_DROP)
                local msg = {wGiveUpUser=userInfo.chairID}
                if not self.cardView then
                    self.cardView = require("zhajinhua.ViewCardLayer_New").new({dataModel=DateModel:getInstance(),effectLayer=self.effectlayer})
                    self.container:addChild(self.cardView, LAYER_Z_ORDER.Z_CARD)
                    self.cardView:dropCard(msg)
                else
                    self.cardView:dropCard(msg)
                end
            end
            if  userInfo.userStatus ~= Define.US_PLAYING and DateModel:getInstance():getPlayStatus(i) == 0 then
                if userInfo.userStatus == Define.US_OFFLINE then
                    
                else
                    self:updatePlayerState(userInfo.chairID, PLAYERSTATE.S_WAITBEGIN)
                end                
            end
            if userInfo.userStatus == Define.US_OFFLINE then
                self:updatePlayerState(userInfo.chairID, PLAYERSTATE.S_OFFLINE)
            end
        end
    end
    ---更新游戏下标状态end
    -- self:updateSeatInfo()--因为self.chairArray需要重置，所以调用两次助攻方法
    if not self.cardView then
        self.cardView = require("zhajinhua.ViewCardLayer_New").new({dataModel=DateModel:getInstance(),effectLayer=self.effectlayer})
        self.container:addChild(self.cardView, LAYER_Z_ORDER.Z_CARD)
        self.cardView:recoverGame(msg)
    else
        self.cardView:recoverGame(msg)
    end

    self.chatWindow:setChairArray(self.chairArry)
    self.chatWindow:setAllowChat(true)
    self:updateOperateButton()
    self:updateBankerIcon()
    self:updateOperatePosition()
    self:updateOperateCompeteButton()
    self.start:hide()
end
function ZhajinhuaScene:onUserEnter(pData)
    local userinfo = DataManager:getUserInfoByUserID(RoomInfo.userInfo.userID)
    -- print("userinfo-chairID",userinfo.chairID,"tableID",userinfo.tableID)
    -- print("faceID=",RoomInfo.userInfo.faceID,"----------ZhajinhuaScene:onUserEnter-------------------------用户ID ： ",RoomInfo.userInfo.userID,"自己的getMyUserID=",DataManager:getMyUserID())
    self:updateSeatInfo()
    if self:checkSelfLookOn() == false  and DataManager:getMyUserID() == RoomInfo.userInfo.userID and DateModel:getInstance():getIsCompeteRoom() == false then
        self.start:show()
        DateModel:getInstance():setStartButtonClicked(false)
    end
end
function ZhajinhuaScene:onUserStatusChange(pData)
    local userinfo = DataManager:getUserInfoByUserID(TableInfo.userStatus.userID)
    -- if userinfo then
    -- end
    if TableInfo.userStatus.userStatus == Define.US_FREE then
        -- self:updateSeatInfo()
    end
    if DataManager:getMyUserID() == TableInfo.userStatus.userID then
        self.tableNum:setString(DataManager:getMyUserInfo().tableID.."桌")
    end
    -- if DataManager:getMyTableID() == TableInfo.userStatus.tableID then
        self:updateSeatInfo()
        if userinfo then
        -- print("----------ZhajinhuaScene:onUserStatusChange-------------------------用户ID ： ",userinfo.nickName,TableInfo.userStatus.userID, TableInfo.userStatus.tableID,", 用户状态：",TableInfo.userStatus.userStatus)
        end
    -- end
    
end
function ZhajinhuaScene:onServerMsgCallBack(event)
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

    elseif event.subId == CMD_ZJH.SUB_S_GIVE_UP then--102--放弃跟注
        self:onDropCard(event.data)
    elseif event.subId == CMD_ZJH.SUB_S_COMPARE_CARD then--比牌数据包105
        self:onCompareCard(event.data)
    elseif event.subId == CMD_ZJH.SUB_S_COMPARE_ALL then--全场比牌
        self:onCompareAll(event.data)
    elseif event.subId == CMD_ZJH.SUB_S_LOOK_CARD then--106--看牌跟注
        self:onLookCard(event.data)
    elseif event.subId == CMD_ZJH.SUB_S_OPEN_CARD then--108 开牌消息 
        self:onOpenCard(event.data)
    elseif event.subId == CMD_ZJH.SUB_S_WAIT_COMPARE then--109等待比牌
        --[[
        required int32                          wCompareUser        = 1;                        //比牌用户
        ]]
        local msg = protocol.zhajinhua.zhajinhua.s2c_pb.CMD_S_WaitCompare_Pro()
        msg:ParseFromString(event.data)
        print("wCompareUser",msg.wCompareUser)
        -- self:compareCard(1030)
    elseif event.subId == CMD_ZJH.SUB_S_SHOW_CARD then--111--用户亮牌

        self:onShowCard(event.data)
    
    elseif event.subId == CMD_ZJH.SUB_S_GAME_END then--104--游戏结束

        self:onGameEnd(event.data)
    elseif event.subId == CMD_ZJH.SUB_S_CLOCK then--110--用户时钟

        self:onClock(event.data)
    elseif event.subId == CMD_ZJH.SUB_S_GAMECELLINFO then
        self:onUpdateGameCellInfo(event.data)
    end
    
end
function ZhajinhuaScene:onUpdateGameCellInfo(data)
--     message CMD_S_GameCellInfo              //0x050011
-- {
--     required int64 lMaxCellScore = 1;//单元上限
--     required int64 lCellScore = 2;//单元下注
--     required int64 lCurrentTimes = 3;//当前倍数
-- }
    local msg = protocol.zhajinhua.zhajinhua.s2c_pb.CMD_S_GameCellInfo()
    msg:ParseFromString(data)
    if msg.lCellScore > DateModel:getInstance():getCellScore() then
        DateModel:getInstance():setMaxScore(msg.lMaxCellScore)
        DateModel:getInstance():setCellScore(msg.lCellScore)
        DateModel:getInstance():setCurrentTimes(msg.lCurrentTimes)
        self.maxScore:setString(msg.lMaxCellScore)
        self.cellScore:setString(msg.lCellScore)
        print("变更底注啦",msg.lMaxCellScore,msg.lCellScore,msg.lCurrentTimes)
        self:playChangeCellEffect()
    end
end
function ZhajinhuaScene:playChangeCellEffect()
    self.infoBg:hide()
    local displaySize = cc.size(DESIGN_WIDTH, DESIGN_HEIGHT);
    local winSize = cc.Director:getInstance():getWinSize();
    -- 蒙板
    local maskLayer = ccui.ImageView:create()
    maskLayer:loadTexture("common/black.png")
    maskLayer:setContentSize(cc.size(winSize.width, winSize.height));
    maskLayer:setScale9Enabled(true)
    maskLayer:setCapInsets(cc.rect(4,4,1,1))
    maskLayer:setPosition(cc.p(DESIGN_WIDTH/2, DESIGN_HEIGHT/2));
    maskLayer:setTouchEnabled(true)
    self.container:addChild(maskLayer,LAYER_Z_ORDER.Z_CHANGECELL)

    local bgSprite = ccui.ImageView:create("zhajinhua/changeCell/changeCellBg.png");
    -- bgSprite:setScale9Enabled(true);
    -- bgSprite:setContentSize(cc.size(642, 452));
    bgSprite:setPosition(cc.p(576,299));
    bgSprite:setScale(0.1)
    self.container:addChild(bgSprite,LAYER_Z_ORDER.Z_CHANGECELL)

    local armature = EffectFactory:getInstance():getChangeCell1()
    armature:setPosition(191, 128)
    bgSprite:addChild(armature)

    local bgkuang = ccui.ImageView:create("zhajinhua/changeCell/splitLine.png");
    bgkuang:setScale9Enabled(true);
    bgkuang:setContentSize(cc.size(300, 2));
    bgkuang:setPosition(cc.p(190,135));
    bgSprite:addChild(bgkuang)

    local maxScore = ccui.Text:create("满注："..DateModel:getInstance():getMaxScore(), "", 30);
    maxScore:setColor(cc.c3b(255,255,255));
    maxScore:enableOutline(cc.c4b(9,51,90,255), 2)
    maxScore:setAnchorPoint(cc.p(0.0,0.5))
    maxScore:setPosition(102,168)
    bgSprite:addChild(maxScore);

    local cellScore = ccui.Text:create("底注："..DateModel:getInstance():getCellScore(), "", 30);
    cellScore:setColor(cc.c3b(255,255,255));
    cellScore:enableOutline(cc.c4b(9,51,90,255), 2)
    cellScore:setAnchorPoint(cc.p(0.0,0.5))
    cellScore:setPosition(102,97)
    bgSprite:addChild(cellScore);

    local t1 = 0.2
    local scale = cc.ScaleTo:create(t1, 1)
    local ease1 = cc.EaseOut:create(scale,0.2)
    local t2 = 0.5
    local moveto = cc.MoveTo:create(t2,cc.p(890, 100))
    local ease2 = cc.EaseOut:create(moveto,0.3)
    local scaleSmall = cc.ScaleTo:create(t2,0.3)
    local ease3 = cc.EaseOut:create(scaleSmall,0.3)
    local removeself = cc.CallFunc:create(function() 
        bgSprite:removeSelf()
        maskLayer:removeSelf()
        end)

    local showdizhu = cc.CallFunc:create(function() 
        self:infoBgEffect()
        self.infoBg:show()
        end)
    local seq = cc.Sequence:create(ease1,cc.DelayTime:create(1.0),cc.Spawn:create(ease3,ease2),removeself,showdizhu)

    bgSprite:runAction(seq)

end
function ZhajinhuaScene:infoBgEffect()
    local armature2 = EffectFactory:getInstance():getChangeCell2()
    armature2:setPosition(85, 35)
    self.infoBg:addChild(armature2)
end
function ZhajinhuaScene:onShowCard(data)
    --[[
        required int32                          wShowUser       = 1;                      //亮牌用户
    ]]
    local msg = protocol.zhajinhua.zhajinhua.s2c_pb.CMD_S_ShowCared_Pro()
    msg:ParseFromString(data)
    print("用户亮牌: ",msg.wShowUser)
    if not self.cardView then
        self.cardView = require("zhajinhua.ViewCardLayer_New").new({dataModel=DateModel:getInstance(),effectLayer=self.effectlayer})
        self.container:addChild(self.cardView, LAYER_Z_ORDER.Z_CARD)
        self.cardView:showCard(msg)
    else
        self.cardView:showCard(msg)
    end
end
function ZhajinhuaScene:onOpenCard(data)
    --[[
    required int32                          wWinner         = 1;                            //胜利用户
    ]]
    local msg = protocol.zhajinhua.zhajinhua.s2c_pb.CMD_S_OpenCard_Pro()
    msg:ParseFromString(data)
    print("开牌消息--赢的人=", msg.wWinner)
    local myChairID = DataManager:getMyChairID()
    local meInOpenCard = true--自己是否在开牌用户中
    local playerChairIDLeft = {}
    local playerChairIDLeftWithMe = {}
    for i,v in ipairs(self.dropChairID) do
        if myChairID==v then
            meInOpenCard = false
        end
    end    
    -- if meInOpenCard then
        for i=1,5 do
            local playerInfo = DataManager:getUserInfoInMyTableByChairIDExceptLookOn(i)
            if playerInfo and playerInfo.userStatus == Define.US_PLAYING then
                local isleft = true
                for j,v in ipairs(self.dropChairID) do
                    if v == playerInfo.chairID then
                        isleft = false
                    end
                end
                if isleft then
                    if playerInfo.chairID~=DataManager:getMyChairID()  then
                        table.insert(playerChairIDLeft,playerInfo.chairID)
                    end
                    table.insert(playerChairIDLeftWithMe,playerInfo.chairID)

                end
            end
        end
        print("playerChairIDLeft",playerChairIDLeft[1],playerChairIDLeft[2],playerChairIDLeft[3],playerChairIDLeft[4])
    -- end
    self.playerLeftToOpenCardChairID = playerChairIDLeft
    if not self.cardView then
        self.cardView = require("zhajinhua.ViewCardLayer_New").new({dataModel=DateModel:getInstance(),effectLayer=self.effectlayer})
        self.container:addChild(self.cardView, LAYER_Z_ORDER.Z_CARD)
        self.cardView:openCard(msg.wWinner,playerChairIDLeftWithMe)
    else
        self.cardView:openCard(msg.wWinner,playerChairIDLeftWithMe)
    end
end
function ZhajinhuaScene:onDropCard(data)
    --[[
    required int32                          wGiveUpUser         = 1;                        //放弃用户
    ]]
    local msg = protocol.zhajinhua.zhajinhua.s2c_pb.CMD_S_GiveUp_Pro()
    msg:ParseFromString(data)
    print("放弃用户",msg.wGiveUpUser)
    table.insert(self.dropChairID,msg.wGiveUpUser)
    if not self.cardView then
        self.cardView = require("zhajinhua.ViewCardLayer_New").new({dataModel=DateModel:getInstance(),effectLayer=self.effectlayer})
        self.container:addChild(self.cardView, LAYER_Z_ORDER.Z_CARD)
        self.cardView:dropCard(msg)
    else
        self.cardView:dropCard(msg)
    end
    self:updatePlayerState(msg.wGiveUpUser, PLAYERSTATE.S_DROP,true)
    SoundManager.playGiveUP()
    local  index = self:getPlayerIndexByChairID(msg.wGiveUpUser)
    print("index",index)
    self.playerInfo[index]["progressTimer"]:hide()
    self.playerInfo[index]["progressTimer"]:stop()
    if msg.wGiveUpUser == DataManager:getMyChairID() then
        self.xuepin:hide()
        self.showCardButton:hide()
        self:resetOperateButton()
    end

    if msg.wGiveUpUser == DataManager:getMyChairID() and self:checkSelfLookOn() == false then
        DateModel:getInstance():setIsDropped(true)
        self:updateOperatePosition()
    end
    
end
function ZhajinhuaScene:onCompareCard(data)
        --[[
        required int32                          wCurrentUser        = 1;                        //当前用户
        repeated int32                          wCompareUser        = 2;                    //比牌用户
        required int32                          wLostUser       = 3;                            //输牌用户
        ]]
        local msg = protocol.zhajinhua.zhajinhua.s2c_pb.CMD_S_CompareCard_Pro()
        msg:ParseFromString(data)
        self:changeChipLayerState(0)
        table.insert(self.dropChairID,msg.wLostUser)
        print("比牌数据包105==输牌用户",msg.wLostUser,"当前用户",msg.wCurrentUser,"比牌用户",msg.wCompareUser)
    if not self.cardView then
        self.cardView = require("zhajinhua.ViewCardLayer_New").new({dataModel=DateModel:getInstance(),effectLayer=self.effectlayer})
        self.container:addChild(self.cardView, LAYER_Z_ORDER.Z_CARD)
        self.cardView:compareCard(msg)
    else
        self.cardView:compareCard(msg)
    end
    if msg.wLostUser == DataManager:getMyChairID() and self:checkSelfLookOn() == false then
        self:performWithDelay(function ()
            self.xuepin:hide()
            self.showCardButton:hide()
            self:resetOperateButton()
            DateModel:getInstance():setIsDropped(true)
            self:updateOperatePosition()
        end, DateModel:getInstance():getComparteDelayTime())

    end
    SoundManager.playCompareCard()
end
function ZhajinhuaScene:onCompareAll(data)
    -- required int32 wLostUser = 1;//输牌用户
    local msg = protocol.zhajinhua.zhajinhua.s2c_pb.CMD_S_MatchCompare_Pro()
    msg:ParseFromString(data)
    Hall.showTips("全场比牌输了"..msg.wLostUser, 2)
end
function ZhajinhuaScene:onClock(data)
    --[[
    required int32                          wTimerID        = 1;                            //时钟ID
    required int32                          wTimeOut        = 2;                            //超时时间 单位:秒
    required int32                          wTimeLeft       = 3;                            //剩余时间 单位:秒
    required int32                          wCurrentUser        = 4;                        //当前用户
    ]]
   
    local msg = protocol.zhajinhua.zhajinhua.s2c_pb.CMD_S_Clock_Pro()
    msg:ParseFromString(data)
    -- print("时钟状态" .. msg.wTimerID .. "超时时间" .. msg.wTimeOut .. "剩余时间" .. msg.wTimeLeft .."当前用户" .. msg.wCurrentUser)
    local playerInfo = DataManager:getUserInfoInMyTableByChairIDExceptLookOn(msg.wCurrentUser)
    if playerInfo then print("当前操作用户",playerInfo.nickName) end
    if msg.wTimerID == 0 then--无效

    elseif msg.wTimerID == 1 then--计算剩余时间

    elseif msg.wTimerID == 2 then--结束定时器

    elseif msg.wTimerID == 3 then--结束定时器
       for index=1,5 do
            self.playerInfo[index]["progressTimer"]:hide()
            self.playerInfo[index]["progressTimer"]:stop()
       end

    elseif msg.wTimerID == 4 then--
        
    elseif msg.wTimerID == 10 then--操作定时器

    elseif msg.wTimerID == 11 then--下注定时器
        -- print("-----------用户时钟，开始下注时间", os.date("%H:%M:%S", os.time()))
        if DataManager:getMyChairID() == msg.wCurrentUser then
            DateModel:getInstance():setMyTurn(true)
            -- DateModel:getInstance():setOperateButtonStatus(OPERATEBUTTON.B_COMPARE,1)
            -- DateModel:getInstance():setOperateButtonStatus(OPERATEBUTTON.B_MAX,1)
        else
            DateModel:getInstance():setMyTurn(false)
            -- DateModel:getInstance():setOperateButtonStatus(OPERATEBUTTON.B_COMPARE,0)
            -- DateModel:getInstance():setOperateButtonStatus(OPERATEBUTTON.B_MAX,0)
        end
        self:updateOperateButton()
        if msg.wCurrentUser == DataManager:getMyChairID() and self:checkSelfLookOn() == false and DateModel:getInstance():getCurrentTimes()<10 then
            if DateModel:getInstance():getAutoFollow() == false and self:checkIsCompeteRoom() == false then
                self:changeChipLayerState(1)
                self:updateChipButton()
            end
            if self:checkIsCompeteRoom() == true then
                self:updateOperateCompeteButton()
            end
            
        end
        local index = -1
        -- print("wCurrentUser",msg.wCurrentUser)
        -- print("chairArry",self.chairArry[1],self.chairArry[2],self.chairArry[3],self.chairArry[4],self.chairArry[5])
        for i,v in ipairs(self.chairArry) do
            if v == msg.wCurrentUser then
                index = i
            end
        end
        -- print("onClock-index",index,msg.wTimeLeft, msg.wTimeOut)
        self.playerInfo[index]["progressTimer"]:show()
        self.playerInfo[index]["progressTimer"]:showByLeftTime(msg.wTimeLeft, msg.wTimeOut)
        local scalebig = cc.ScaleTo:create(0.2, 1.1)
        local scalesmall = cc.ScaleTo:create(0.2, 1)
        self.playerInfo[index]["headbg"]:runAction(cc.Sequence:create(scalebig,scalesmall))
        if msg.wCurrentUser == DataManager:getMyChairID() then
            self:performWithDelay(function ()
                SoundManager.playOnMyTurn()
            end, 0.2)
            
        end
        -- self.playerInfo[index]["progressTimer"]:runAction(cc.ProgressFromTo:create(msg.wTimeLeft,100*msg.wTimeLeft/msg.wTimeOut,0))
        if DateModel:getInstance():getIsCompeteRoom() == true then
            if msg.wCurrentUser == DataManager:getMyChairID() and self:checkAllIn() then
                print("我是孤注一掷")
                self:compareAll()
            end
        end
        -- print("onClock当前倍数")
        -- dump(DateModel:getInstance():getCurrentTimes(), "getCurrentTimes")
        print(DateModel:getInstance():getCurrentTimes(),self:checkIsCompeteRoom())
        if msg.wCurrentUser == DataManager:getMyChairID() and DateModel:getInstance():getXuePin() and DateModel:getInstance():getCurrentTimes()==10 and self:checkIsCompeteRoom()==false then
            if self:checkOpenCard() then
                self:openCard()
            else
                self:performWithDelay(function ()
                    self:followCard(DateModel:getInstance():getCellScore()*DateModel:getInstance():getCurrentTimes())
                    DateModel:getInstance():setCompareDelayTime(0)
                end, DateModel:getInstance():getComparteDelayTime())
                
            end
            return
        end
        if msg.wCurrentUser == DataManager:getMyChairID() and DateModel:getInstance():getAutoDrop() then
            self:dropCard()            
            DateModel:getInstance():setAutoDrop(false)
            self.checkFollowYes:hide()
            self.checkDropYes:hide()
        end
        if msg.wCurrentUser == DataManager:getMyChairID() and DateModel:getInstance():getAutoFollow() then
            self:performWithDelay(function ()
                self:followCard(DateModel:getInstance():getCellScore()*DateModel:getInstance():getCurrentTimes())
                DateModel:getInstance():setAutoFollow(false)
                self.checkFollowYes:hide()
                self.checkDropYes:hide()
                DateModel:getInstance():setCompareDelayTime(0)
            end, DateModel:getInstance():getComparteDelayTime())

        end


    elseif msg.wTimerID == 12 then--看牌定时器
        local index = -1
        for i,v in ipairs(self.chairArry) do
            if v == msg.wCurrentUser then
                index = i
            end
        end
        print("onClock-index",index)
        self.playerInfo[index]["progressTimer"]:show()
        self.playerInfo[index]["progressTimer"]:showByLeftTime(msg.wTimeLeft, msg.wTimeOut)
    elseif msg.wTimerID == 13 then--比牌定时器
        local index = -1
        for i,v in ipairs(self.chairArry) do
            if v == msg.wCurrentUser then
                index = i
            end
        end
        print("比牌定时器",msg.wCurrentUser,"onClock-index",index)
        self.playerInfo[index]["progressTimer"]:hide()
        self.playerInfo[index]["progressTimer"]:stop()
    
    end
end
function ZhajinhuaScene:onGameEnd(data)
        --[[
        required int64                          lGameTax        = 1;                            //游戏税收
        repeated int64                          lGameScore      = 2;            //游戏得分
        repeated CardData_Pro                       cbCardData      = 3;            //用户扑克
        repeated CardData_Pro                       wCompareUser        = 4;        //比牌用户
        required int32                          wEndState       = 5;                            //结束状态
        
        ]]
    local msg = protocol.zhajinhua.zhajinhua.s2c_pb.CMD_S_GameEnd_Pro()
    msg:ParseFromString(data)
    -- print("***************************游戏税收",msg.lGameTax,"结束状态",msg.wEndState)
    -- print("msg.lGameScore",#msg.lGameScore)
    msg = copyProtoTable(msg)
    -- dump(msg, "msg")
    -- local gameScore = copyProtoTable(msg.lGameScore)
    -- local cbCardData = copyProtoTable(msg.cbCardData)
    -- local wCompareUser = copyProtoTable(msg.wCompareUser)
    local winner = 1
    -- dump(gameScore, "gameScore")
    -- dump(cbCardData, "cbCardData")
    -- dump(wCompareUser, "wCompareUser")
    for i,v in ipairs(msg.lGameScore) do
        -- print("游戏得分",i,v)
        local playerInfo = DataManager:getUserInfoInMyTableByChairIDExceptLookOn(i)
        if playerInfo and playerInfo.userStatus == Define.US_PLAYING then
            if v > 0 then
                self:updatePlayerState(i,PLAYERSTATE.S_WIN)
                winner = i
                if winner==DataManager:getMyChairID() then
                    SoundManager.playGameWin()
                end
            elseif v<0 then
                self:updatePlayerState(i,PLAYERSTATE.S_LOSE)
                if i == DataManager:getMyChairID() then
                    SoundManager.playGameLost()
                end
            end
            local index = -1
            for j,w in ipairs(self.chairArry) do
                if i == w then
                    index = j
                end
            end
            local gameoverGoldStr = FormatNumToString(v)
            if v>0 then
                gameoverGoldStr = "+"..gameoverGoldStr
            end
            self.playerInfo[index]["gameoverGold"]:setString(gameoverGoldStr)
            self.playerInfo[index]["gameoverGold"]:show()
        end
    end

    if not self.cardView then
        self.cardView = require("zhajinhua.ViewCardLayer_New").new({dataModel=DateModel:getInstance(),effectLayer=self.effectlayer})
        self.container:addChild(self.cardView, LAYER_Z_ORDER.Z_CARD)
        self.cardView:gameEnd(msg,winner,self.playerLeftToOpenCardChairID)
    else
        self.cardView:gameEnd(msg,winner,self.playerLeftToOpenCardChairID)
    end
    self:changeChipLayerState(0)
    DateModel:getInstance():setGameStart(false)
    self:resetData()
    if self:checkSelfLookOn() == false and DateModel:getInstance():getIsCompeteRoom() == false then
        self.start:show()
        DateModel:getInstance():setStartButtonClicked(false)
    end
    SoundManager.playGameEnd()

    -- local buttonCount = #OPERATEBUTTON
    -- print("buttonCount",buttonCount)
    -- for i=1,buttonCount do
    --     DateModel:getInstance():setOperateButtonStatus(i,0)
    -- end
    DateModel:getInstance():setMyTurn(false)
    self:updateOperateButton()
    self:startSelfAutoTimer()
    self.xuepin:hide()
    if winner == DataManager:getMyChairID() and DataManager:getMyUserStatus() ~= Define.US_LOOKON then
        if DateModel:getInstance():getIsCompeteRoom() == false then
            self.showCardButton:show()
        end
        
    end
    self:updateOperatePosition()
end
--设置是否已经看过牌
function ZhajinhuaScene:setLookCardAlready(isLookCard)
    DateModel:getInstance():setLookCard(isLookCard)
    if self:checkIsCompeteRoom() then
        if isLookCard == 1 then
            self.operateButtonUIArray[OPERATEBUTTON.B_DROP]:show()
            self.operateButtonUIArray[OPERATEBUTTON.B_LOOK]:hide()
        else
            self.operateButtonUIArray[OPERATEBUTTON.B_DROP]:hide()
            self.operateButtonUIArray[OPERATEBUTTON.B_LOOK]:show()
        end
    end
end
--看牌
function ZhajinhuaScene:onLookCard(data)
        --[[       
        required int32                          wLookCardUser       = 1;                        //看牌用户
        repeated int32                          cbCardData      = 2;                //用户扑克
        ]] 
        
    local msg = protocol.zhajinhua.zhajinhua.s2c_pb.CMD_S_LookCard_Pro()
    msg:ParseFromString(data)
    local playerInfo = DataManager:getUserInfoInMyTableByChairIDExceptLookOn(msg.wLookCardUser)
    local myChairID = DataManager:getMyChairID()
    print("看牌数据包----看牌用户", msg.wLookCardUser,playerInfo.nickName)
    if myChairID == msg.wLookCardUser then
        self:setLookCardAlready(1)
        if self:checkIsCompeteRoom() then
            self:updateOperateCompeteButton()
        end
    end
    self:updatePlayerState(msg.wLookCardUser, PLAYERSTATE.S_LOOK)
    -- --打印发的牌
    -- local shoupai = ""
    -- local total = #msg.cbCardData
    -- for i=1,total do

    --     -- shoupai = shoupai..string.format("0x%02x",msg.cbCardData[i])..","--cardInfo[
    --     shoupai = shoupai..cardInfo[msg.cbCardData[i]]
    -- end        
    -- print("发牌total",total,"shoupai",shoupai)
    if not self.cardView then
        self.cardView = require("zhajinhua.ViewCardLayer_New").new({dataModel=DateModel:getInstance(),effectLayer=self.effectlayer})
        self.container:addChild(self.cardView, LAYER_Z_ORDER.Z_CARD)
        self.cardView:lookCard(msg)
    else
        self.cardView:lookCard(msg)
    end
    self:updateOperateButton()
end
--游戏开始
function ZhajinhuaScene:onGameStart(data)
    local msg = protocol.zhajinhua.zhajinhua.s2c_pb.CMD_S_GameStart_Pro()
    msg:ParseFromString(data)
    -- print("当前倍数",msg.lCurrentTimes,"下注底分:" .. msg.lCellScore,"最大下注",msg.lMaxScore,"庄家用户",msg.wBankerUser,"当前玩家",msg.wCurrentUser,"分数上限",msg.lUserMaxScore)
    DateModel:getInstance():setMaxScore(msg.lMaxScore)
    DateModel:getInstance():setCellScore(msg.lCellScore)
    DateModel:getInstance():setOriginCellScore(msg.lCellScore)
    DateModel:getInstance():setCurrentTimes(msg.lCurrentTimes)
    DateModel:getInstance():setBankerUser(msg.wBankerUser)
    DateModel:getInstance():setUserMaxScore(msg.lUserMaxScore)
    self:setLookCardAlready(0)
    DateModel:getInstance():setXuePin(false)
    DateModel:getInstance():setAutoDrop(false)
    DateModel:getInstance():setAutoFollow(false)
    DateModel:getInstance():setIsDropped(false)
    DateModel:getInstance():setCompareDelayTime(0)
    DateModel:getInstance():setCurrentRound(1)
    self:onCurrentRound()
    self:resetOperateButton()
    -- Hall.showTips("游戏开始"..tostring(self), 3)
    -- DateModel:getInstance():setOperateButtonStatus(OPERATEBUTTON.B_DROP,1)
    -- DateModel:getInstance():setOperateButtonStatus(OPERATEBUTTON.B_LOOK,1)
    -- DateModel:getInstance():setOperateButtonStatus(OPERATEBUTTON.B_FOLLOW,1)

    -- DataManager:getMyUserInfo():setScoreInGame(DataManager:getMyUserInfo().score)
    
    self.maxScore:setString(msg.lMaxScore)
    self.cellScore:setString(msg.lCellScore)
    self.competeCellScore:setString("底注:"..msg.lCellScore)
    self.dropChairID = {}
    self.showCardChairID ={}
    self.playerLeftToOpenCardChairID = {}
    self.allIn = false
    self.xuepin:hide()
    self.showCardButton:hide()
    local chairID = msg.wBankerUser--math.random(0,4)
    local myChairID = DataManager:getMyChairID()
    if myChairID == msg.wCurrentUser then
        DateModel:getInstance():setMyTurn(true)
    else
        DateModel:getInstance():setMyTurn(false)
    end
    -- self:updateSeatInfo()
    if not self.cardView then
        self.cardView = require("zhajinhua.ViewCardLayer_New").new({dataModel=DateModel:getInstance(),effectLayer=self.effectlayer})
        self.container:addChild(self.cardView, LAYER_Z_ORDER.Z_CARD)
        self.cardView:sendCard(chairID,myChairID)
    else
        self.cardView:sendCard(chairID,myChairID)
    end
    local totalValue = 0
    for i=1,5 do
        local playerInfo = DataManager:getUserInfoInMyTableByChairIDExceptLookOn(i)
        DateModel:getInstance():setLookCardStatus(i, 0)
        DateModel:getInstance():setPlayStatus(i, 0)
        if playerInfo then
            totalValue = totalValue+msg.lCellScore
            local index = -1
            for j,v in ipairs(self.chairArry) do
                if v == i then
                    index = j
                end
            end
            -- self.tableGoldUIArrayValue[index] = msg.lCellScore
            DateModel:getInstance():setTableGoldPlayerValue(index,msg.lCellScore)
            -- playerInfo:setScore(playerInfo.score-msg.lCellScore)
            -- self:updatePlayerInfo(playerInfo,index)
            DateModel:getInstance():setPlayStatus(i, 1)
        end
        self:updatePlayerState(i,PLAYERSTATE.S_NORMAL)
        self.tableGoldUIArray[i]:setString(msg.lCellScore)


    end
    self:updateMoneyInGame()
    self:updateBankerIcon()
    for i,v in ipairs(self.tableGoldUIArrayValue) do
        -- print("玩家初始投注",i,v)
    end
    self.tableGoldTotal:setString(totalValue)
    -- self.tableGoldTotalValue = totalValue
    DateModel:getInstance():setTableGoldTotalValue(totalValue)
    DateModel:getInstance():setGameStart(true)
    SoundManager.playGameStart()


    --游戏开始之后才可以聊天，这里去构造聊天层

    self.chatWindow:clearPlayerMsg()
    self.chatWindow:setChairArray(self.chairArry)
    self.chatWindow:setAllowChat(true)
    self:updateOperateButton()
    self:updateOperatePosition()
    self:updateOperateCompeteButton()
end

--游戏加注
function ZhajinhuaScene:onGameAddScore(data)
        --[[
            required int32                          wCurrentUser        = 1;                        //当前用户
            required int32                          wAddScoreUser       = 2;                        //加注用户
            required int32                          wCompareState       = 3;                        //比牌状态
            required int64                          lAddScoreCount      = 4;                        //加注数目
            required int64                          lCurrentTimes       = 5;                        //当前倍数
        ]]
    local msg = protocol.zhajinhua.zhajinhua.s2c_pb.CMD_S_AddScore_Pro()
    msg:ParseFromString(data)
    --print("服务端加注:",msg.wAddScoreUser,msg.lAddScoreCount,msg.lCurrentTimes)
    local playerInfo = DataManager:getUserInfoInMyTableByChairIDExceptLookOn(msg.wAddScoreUser)
    playerInfo.score=(playerInfo.score-msg.lAddScoreCount)
    if playerInfo.scoreInGame == nil then
        print("我的积分不对 playerInfo...nickName",playerInfo.nickName)
    else
        playerInfo.scoreInGame=(playerInfo.scoreInGame-msg.lAddScoreCount)
    end    
    
    local playerIndex = 0
    for i,v in ipairs(self.chairArry) do
        if v== msg.wAddScoreUser then
            playerIndex = i
        end
    end
    self:updatePlayerInfo(playerInfo,playerIndex)
    local add = false
    if msg.lCurrentTimes > DateModel:getInstance():getCurrentTimes() then
        add = true
        print("我是加注！！")
    end
    if msg.lAddScoreCount>0 then
        self:updatePlayerState(msg.wAddScoreUser, PLAYERSTATE.S_FOLLOW)
    end
    if add then
        self:updatePlayerState(msg.wAddScoreUser, PLAYERSTATE.S_ADD)
    end
    if msg.lCurrentTimes == 10 then
        local isupdate = true
        for i,v in ipairs(self.dropChairID) do
            if v == msg.wAddScoreUser then
                isupdate = false
                break
            end
        end
        if isupdate then
            self:updatePlayerState(msg.wAddScoreUser, PLAYERSTATE.S_MAX)
        end        
    end
    local index = -1
    for i,v in ipairs(self.chairArry) do
        if v == msg.wAddScoreUser then
            index = i
        end
    end
    self.playerInfo[index]["progressTimer"]:hide()
    self.playerInfo[index]["progressTimer"]:stop()
    -- print(index,"self.tableGoldUIArrayValue[index]",self.tableGoldUIArrayValue[index])
    -- print(index,"getTableGoldPlayerValue",DateModel:getInstance():getTableGoldPlayerValue(index))
    local meNotInDrop = true
    for i,v in ipairs(self.dropChairID) do
        if v==DataManager:getMyChairID() then
            meNotInDrop = false
            break
        end
    end
    if msg.lCurrentTimes == 10 and DataManager:getMyUserStatus() ~= Define.US_LOOKON and DataManager:getMyUserStatus() == Define.US_PLAYING and meNotInDrop then
        self.xuepin:show()
        if DateModel:getInstance():getXuePin() == false then
            self.xuepin:setHighlighted(false)
        end
    else
        self.xuepin:hide()
    end
    if msg.wAddScoreUser == DataManager:getMyChairID() then
        self:changeChipLayerState(0)
    end
    if msg.wAddScoreUser == DateModel:getInstance():getBankerUser() then
        DateModel:getInstance():setCurrentRound(DateModel:getInstance():getCurrentRound()+1)
        self:onCurrentRound()
    end
    self:updateChipButton()
    local value = DateModel:getInstance():getTableGoldPlayerValue(index)+msg.lAddScoreCount--self.tableGoldUIArrayValue[index]+msg.lAddScoreCount
    -- self.tableGoldUIArrayValue[index] = value
    DateModel:getInstance():setTableGoldPlayerValue(index,value)
    self.tableGoldUIArray[index]:setString(value)
    local totalValue = DateModel:getInstance():getTableGoldTotalValue()+msg.lAddScoreCount --self.tableGoldTotalValue + msg.lAddScoreCount
    -- self.tableGoldTotalValue = totalValue
    DateModel:getInstance():setTableGoldTotalValue(totalValue)
    self.tableGoldTotal:setString(totalValue)
    DateModel:getInstance():setCurrentTimes(msg.lCurrentTimes)
    -- print(msg,"加注数目",msg.lAddScoreCount,"当前倍数",msg.lCurrentTimes,"当前用户",msg.wCurrentUser,"加注用户",msg.wAddScoreUser,"比牌状态",msg.wCompareState)
    if msg.lAddScoreCount==0 then
        return
    end
    local chairID = msg.wAddScoreUser
    if not self.cardView then
        self.cardView = require("zhajinhua.ViewCardLayer_New").new({dataModel=DateModel:getInstance(),effectLayer=self.effectlayer})
        self.container:addChild(self.cardView, LAYER_Z_ORDER.Z_CARD)
        self.cardView:followCard(msg)
    else
        self.cardView:followCard(msg)
    end
    SoundManager.playAddScore()
end
function ZhajinhuaScene:roomConfigResult(event)
    Hall.showTips("roomConfigResult", 2)
    print("ZhajinhuaScene---roomConfigResult!!")
    self:removeGameEvent()
    local ZhajinhuaScene = require("zhajinhua.ZhajinhuaScene_New")
    cc.Director:getInstance():replaceScene(ZhajinhuaScene.new())
end
function ZhajinhuaScene:requestInsure()
    BankInfo:sendQueryRequest()
end
function ZhajinhuaScene:getFlyStartIndex(sourceUserID)
    
    local userInfo = DataManager:getUserInfoByUserID(sourceUserID)
    local chairID = 1
    if userInfo then
        chairID = userInfo.chairID
    else
        print("找不到送道具的用户信息")
    end
    return chairID
end
function ZhajinhuaScene:onUsePropertyResult(event)
    local result = false
    local propertySuccess = PropertyInfo.usePropertyResult--event.data
    if propertySuccess.code == 1 then
        result = true
    elseif propertySuccess.code == 2 then
        Hall.showTips("道具不存在",2)
    elseif propertySuccess.code == 3 then
        Hall.showTips("道具数量错误",2)
    elseif propertySuccess.code == 4 then
        Hall.showTips("魅力为负数不能使用伤害性道具，快给自己买道具提升魅力值吧!",2)
    elseif propertySuccess.code == 5 then
        Hall.showTips("比赛房间不可以使用此功能！",2)
    elseif propertySuccess.code == 6 then
        Hall.showTips("练习房间不可以使用此功能！",2)
    elseif propertySuccess.code == 7 then
        Hall.showTips("被赠送道具的人未找到",2)
    elseif propertySuccess.code == 8 then
        Hall.showTips("道具不足",2)
    end

    if result == false then
        print("-------使用道具失败-------code--",propertySuccess.code)
        
        return 
    end
end

function ZhajinhuaScene:onPropertySuccess(event)

    local propertySuccess = PropertyInfo.usePropertyBroadcast--event.data

    print("--播放道具动画")

    print("propertySuccess:",
            propertySuccess.propertyCount,
            propertySuccess.propertyID,
            propertySuccess.sourceUserID,
            propertySuccess.targetUserID)


    -- self:requestInsure()
    --播放道具动画
    local startIndex = self:getFlyStartIndex(propertySuccess.sourceUserID)
    local endIndex = self:getFlyStartIndex(propertySuccess.targetUserID)
    
    self:flyGift(startIndex,endIndex,propertySuccess.propertyID,propertySuccess.propertyCount)
    
    --添加聊天记录
    local senderStr = ""
    local sourceUser = DataManager:getUserInfoByUserID(propertySuccess.sourceUserID)    
    if sourceUser then
        senderStr = sourceUser.nickName
    end

    local targetStr = ""
    local targetUser = DataManager:getUserInfoByUserID(propertySuccess.targetUserID)
    if targetUser then
        targetStr = targetUser.nickName
    end

    local gift = PropertyConfigInfo:obtainPropertyobjectByIndex(propertySuccess.propertyID)
    local msgString = senderStr.."赠送"..targetStr..propertySuccess.propertyCount..customGift[gift:getIndex()].giftName
    
    --添加滚动消息
    self:showScrollMessage(msgString)
    ---更新玩家的钱(非旁观玩家)
    if sourceUser.userStatus ~= Define.US_LOOKON then
        sourceUser.scoreInGame=(sourceUser.scoreInGame-gift:getPropertyGold()*propertySuccess.propertyCount)

        print(propertySuccess.sourceUserID,"sourceUserID",sourceUser.score,gift:getPropertyGold()*propertySuccess.propertyCount)
    end
    self:updateSeatInfo()
end

--赠送礼物动画
function ZhajinhuaScene:flyGift(startIndex,endIndex,giftIndex,giftCount)
    print("flyGiftToAnchor:",startIndex,endIndex,giftIndex,giftCount)
    
    ----动画索引
    local effectIndex = 0
    if giftIndex >= 500 and giftIndex <= 507 then
        for i,v in ipairs(customGift[giftIndex].giftCount) do
            if v == giftCount then
                effectIndex = i - 1
                break
            end
        end
    end
    ----动画起始位置
    local indexS = -1
    local indexE = -1
    for i,v in ipairs(self.chairArry) do
        if startIndex == v then
            indexS = i
        end
        if endIndex == v then
            indexE = i
        end
    end
    local originNode = self.playerInfo[indexS]["headbg"]--self.playerIcon[startIndex]
    -- local originWorldPosition = originNode:getParent():convertToWorldSpace(cc.p(originNode:getPositionX(),originNode:getPositionY()))
    local originPosition = playerPos[indexS]--self.container:convertToNodeSpace(cc.p(originWorldPosition.x,originWorldPosition.y))
    ----动画node
    local giftTarget = ccui.ImageView:create(customGift[giftIndex].giftImg)
    giftTarget:setScale(0.6)
    giftTarget:setPosition(cc.p(originPosition.x,originPosition.y))
    self.container:addChild(giftTarget, LAYER_Z_ORDER.Z_EFFECT)
    ----动画可能的中间位置
    local midPos = cc.p(770,380)--大动画位置
    local middleWorldPosition = self.container:convertToWorldSpace(midPos)
    local middlePosition = self.container:convertToNodeSpace(cc.p(middleWorldPosition.x,middleWorldPosition.y))
    ----动画最终目标位置
    -- local targetNode = self.playerIcon[endIndex]
    -- local targetWorldPosition = targetNode:getParent():convertToWorldSpace(cc.p(targetNode:getPositionX(),targetNode:getPositionY()))
    local targetPosition = playerPos[indexE]--self.container:convertToNodeSpace(cc.p(targetWorldPosition.x,targetWorldPosition.y))

    ----开始播放动画
    ----动画1:送出玩家动画
    if startIndex then
        --起始位置动画
        local action1 = cc.MoveBy:create(0.1,cc.p(0,20))
        local action2 = action1:reverse()
        local acitionHead = cc.Sequence:create(action1,action2)
        originNode:runAction(acitionHead)

    end
    ----动画2-1:道具平移、目标位置动画
    ----动画2-2:道具平移、动画展示、移动向目标位置
    if effectIndex == 0 then
        ----动画2-1:道具平移、目标位置动画
        local giftEffect = cc.CallFunc:create(
            function()
                --移除道具
                giftTarget:removeFromParent()
                -- 如果是主播，播放招财猫动画
                -- if endIndex == 9 then
                --     anchorPet:stopAllActions()
                --     local animation = nil
                --     if giftIndex >= 508 and giftIndex <= 515 then
                --         animation = EffectFactory:getInstance():getEffectByName("zcm-zgj-", 0.1, 1, 6)
                --     else
                --         animation = EffectFactory:getInstance():getEffectByName("zcm-kx-", 0.1, 1, 5)
                --     end
                --     local petDJ = cc.CallFunc:create(
                --         function()
                --             anchorPet:stopAllActions()
                --             local animation = EffectFactory:getInstance():getEffectByName("zcm-dj-", 0.2, 1, 3)
                --             local action = cc.RepeatForever:create(cc.Animate:create(animation))
                --             anchorPet:runAction(action)
                --         end
                --     );
                --     local action = cc.Sequence:create(cc.Animate:create(animation),petDJ)
                --     anchorPet:runAction(action)
                -- end
                -- 播放道具动画
                local armature = EffectFactory:getInstance():getGiftArmature(giftIndex)
                if armature then
                    armature:setPosition(cc.p(targetPosition.x,targetPosition.y))
                    self.container:addChild(armature, LAYER_Z_ORDER.Z_EFFECT)
                    armature:getAnimation():setFrameEventCallFunc(function(bone,evt,originFrameIndex,currentFrameIndex)
                            if evt == "end" then
                                armature:removeFromParent()
                            end
                        end)
                    armature:getAnimation():playWithIndex(effectIndex)
                end
            end
        );
        local actionGift1 = cc.MoveTo:create(0.5,cc.p(targetPosition.x,targetPosition.y))
        -- local actionGift2 = cc.Sequence:create(cc.FadeIn:create(0.35),cc.FadeOut:create(0.15))
        local actionGift2 = cc.FadeIn:create(0.5)
        local actionGiftFly = cc.Sequence:create(cc.Spawn:create(actionGift1,actionGift2),giftEffect)
        giftTarget:runAction(actionGiftFly)
    else
        ----动画2-2:道具平移、动画展示、移动向目标位置
        local giftEffect = cc.CallFunc:create(
            function()
                -- 播放道具动画
                local armature = EffectFactory:getInstance():getGiftArmature(giftIndex)
                if armature then
                    armature:setPosition(cc.p(middlePosition.x,middlePosition.y))
                    self.container:addChild(armature, LAYER_Z_ORDER.Z_EFFECT)
                    armature:getAnimation():setFrameEventCallFunc(function(bone,evt,originFrameIndex,currentFrameIndex)
                            if evt == "end" then
                                armature:removeFromParent()
                                --移动到目标位置并消失
                                local remove = cc.CallFunc:create(
                                    function()
                                        --移除道具
                                        giftTarget:removeFromParent()
                                        -- 如果是主播，播放招财猫动画
                                        if endIndex == 9 then
                                            anchorPet:stopAllActions()
                                            local animation = nil
                                            if giftIndex >= 508 and giftIndex <= 515 then
                                                animation = EffectFactory:getInstance():getEffectByName("zcm-zgj-", 0.1, 1, 6)
                                            else
                                                animation = EffectFactory:getInstance():getEffectByName("zcm-kx-", 0.1, 1, 5)
                                            end
                                            local petDJ = cc.CallFunc:create(
                                                function()
                                                    anchorPet:stopAllActions()
                                                    local animation = EffectFactory:getInstance():getEffectByName("zcm-dj-", 0.2, 1, 3)
                                                    local action = cc.RepeatForever:create(cc.Animate:create(animation))
                                                    anchorPet:runAction(action)
                                                end
                                            );
                                            local action = cc.Sequence:create(cc.Animate:create(animation),petDJ)
                                            anchorPet:runAction(action)
                                        end
                                    end
                                );
                                local actionMove1 = cc.MoveTo:create(0.5,cc.p(targetPosition.x,targetPosition.y))
                                local actionMove2 = cc.ScaleTo:create(0.5, 0.1)
                                local actionMove3 = cc.Sequence:create(cc.Spawn:create(actionMove1,actionMove2),remove)
                                giftTarget:runAction(actionMove3)
                            end
                        end)
                    armature:getAnimation():playWithIndex(effectIndex)
                end
            end
        );
        local actionGift1 = cc.MoveTo:create(0.5,cc.p(middlePosition.x,middlePosition.y))
        -- local actionGift2 = cc.Sequence:create(cc.FadeIn:create(0.35),cc.FadeOut:create(0.15))
        local actionGift2 = cc.FadeIn:create(0.5)
        local actionGiftFly = cc.Sequence:create(cc.Spawn:create(actionGift1,actionGift2),giftEffect)
        giftTarget:runAction(actionGiftFly)
    end
    self:performWithDelay(function ()
        SoundManager.playSendProperty(giftIndex)
    end, 0.5)
end

function ZhajinhuaScene:showScrollMessage(messageContent,color,labaKind)
    table.insert(self.scrollMessageArr, messageContent)
    table.insert(self.scrollMessageKindArr,labaKind)
    if self.scrollTextContainer:isVisible() == false then
        self.scrollTextContainer:setVisible(true)
        self:startScrollMessage(color)
    end
end

function ZhajinhuaScene:startScrollMessage(color)
    local messageCount = table.maxn(self.scrollMessageArr)
    if messageCount > 0 then
        local kind = self.scrollMessageKindArr[1] or 4
        local labaImg = self.scrollTextContainer:getChildByName("labaImg")
        labaImg:loadTexture("common/scroll_laba"..kind..".png")
        local scrollTextPanel = self.scrollTextContainer:getChildByName("scrollTextPanel")
        local messageContent = self.scrollMessageArr[1]
        local scrollText = ccui.Text:create()
        scrollText:setFontSize(22)
        scrollText:setAnchorPoint(cc.p(0,0.5))

        scrollText:setColor(self.colorArray[kind])
        scrollText:setString(messageContent)
        scrollText:setPosition(cc.p(scrollTextPanel:getContentSize().width,scrollTextPanel:getContentSize().height/2))
        scrollTextPanel:addChild(scrollText)

        local moveDistance = scrollText:getContentSize().width + scrollTextPanel:getContentSize().width
        local moveDuration = moveDistance / 100

        local scrollAction = cc.Sequence:create(
                        cc.MoveBy:create(moveDuration, cc.p(-moveDistance,0)),
                        cc.CallFunc:create(function() 
                            scrollText:removeFromParent()
                            self:startScrollMessage(color)
                        end)
                    )
        scrollText:runAction(scrollAction)

        table.remove(self.scrollMessageArr,1)
        table.remove(self.scrollMessageKindArr,1)
    else
        self.scrollTextContainer:setVisible(false)
    end
end

return ZhajinhuaScene