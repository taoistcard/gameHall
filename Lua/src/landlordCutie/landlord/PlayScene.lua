-- 普通游戏场景
-- Author: <zhaxun>
-- Date: 2015-05-12 13:49:55
--
local cardInfo = {
[0x01] = "方块A", [0x02] = "方块2", [0x03] = "方块3", [0x04] = "方块4", [0x05] = "方块5", [0x06] = "方块6", [0x07] = "方块7", [0x08] = "方块8", [0x09] = "方块9", [0x0A] = "方块10", [0x0B] = "方块J", [0x0C] = "方块Q", [0x0D]= "方块K",  
[0x11] = "梅花A", [0x12] = "梅花2", [0x13] = "梅花3", [0x14] = "梅花4", [0x15] = "梅花5", [0x16] = "梅花6", [0x17] = "梅花7", [0x18] = "梅花8", [0x19] = "梅花9", [0x1A] = "梅花10", [0x1B] = "梅花J", [0x1C] = "梅花Q", [0x1D]= "梅花K",
[0x21] = "红桃A", [0x22] = "红桃2", [0x23] = "红桃3", [0x24] = "红桃4", [0x25] = "红桃5", [0x26] = "红桃6", [0x27] = "红桃7", [0x28] = "红桃8", [0x29] = "红桃9", [0x2A] = "红桃10", [0x2B] = "红桃J", [0x2C] = "红桃Q", [0x2D]= "红桃K",
[0x31] = "黑桃A", [0x32] = "黑桃2", [0x33] = "黑桃3", [0x34] = "黑桃4", [0x35] = "黑桃5", [0x36] = "黑桃6", [0x37] = "黑桃7", [0x38] = "黑桃8", [0x39] = "黑桃9", [0x3A] = "黑桃10", [0x3B] = "黑桃J", [0x3C] = "黑桃Q", [0x3D]= "黑桃K", 
[0x4E] = "小王",  [0x4F] = "大王",
}

local LEAVE_TABLE = 1
local CHANGE_TABLE = 2
local CHANGE_ROOM = 3

local LAYER_Z_ORDER = {
    Z_BG = 0,
    Z_TABLE = 1,
    Z_PLAYER = 2,
    Z_CARD = 3,
    Z_BUTTONS = 4,
    Z_TUOGUAN = 5,
    Z_RESULT = 6,
    Z_EFFECT = 6,
    Z_CHATWINDOW = 7,
    Z_POPMSG = 8,
    Z_GIFT = 1000,
    Z_CONFIRM = 9,
    Z_SYTEMNOTICE = 10,
    Z_ROOMSELECT = 11,
    Z_CUP = 5,
    Z_COUPON = 2,
}

require("gameSetting.GameConfig")
require("landlord.CMD_LandlordMsg")
require("protocol.doudizhu.doudizhu_s2c_pb")


local viewCardLayer = require("landlord.ViewCardLayer")
local scheduler = require("framework.scheduler")



local EffectFactory = require("commonView.DDZEffectFactory")
local GameItemFactory = require("commonView.GameItemFactory"):getInstance()

--[[
local PlayConfig = {
    
    --游戏属性
    lCellScore      =1,         --基础积分

    --时间信息
    cbTimeOutCard       =2,         --出牌时间
    cbTimeCallScore     =3,         --叫分时间
    cbTimeStartGame     =4,         --开始时间
    cbTimeHeadOutCard   =5,         --首出时间

    --历史积分
    lTurnScore          =6,         --积分信息
    lCollectScore       =7,         --积分信息
}
]]

local PlayScene = class("PlayScene", require("ui.CCBaseScene"))

function PlayScene:ctor()
    print("PlayScene:ctor=======")
    -- 根节点变更为self.container
    self.super.ctor(self)

    --防止frames释放
    EffectFactory:getInstance():cacheFrames()
        
    self.sendGiftUserIdArray = {} --送道具的目标人id
    self.leaveType = 0
    self.needRestart = false--客户端主动站起时值为true
    self._step = 0
    self.isRecover = false

    self.downloadCount = 5

    --背景
    local bgSprite = cc.Sprite:create()
    bgSprite:setTexture("common/table.jpg")
    bgSprite:align(display.CENTER, display.cx, display.cy)
    self.container:addChild(bgSprite, LAYER_Z_ORDER.Z_BG)
--[[
    if RunTimeData:getCurGameServerType() == Define.GAME_GENRE_EDUCATE then
        pUserInfo.tagUserInfo.lUserBeans = pUserScore.UserScore.lScore
    else
        pUserInfo.tagUserInfo.lScore = pUserScore.UserScore.lScore
    end
]]
    --房间名称
    local curGameServer = RunTimeData:getCurGameServer()
    if curGameServer then
        local roomNameLabel = display.newTTFLabel({text = curGameServer.serverName,
                                size = 22,
                                font = FONT_ART_TEXT,
                                color = cc.c3b(153,37,83),
                                align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                            })
                :align(display.CENTER, 568, 390)
                :addTo(self.container)
    end

    self.isHappyBeans = (bit.band(RunTimeData:getCurGameServerType(),Define.GAME_GENRE_EDUCATE) == Define.GAME_GENRE_EDUCATE)
    if self.isHappyBeans then
        self.fileMoney = "common/huanledou.png"
    else
        self.fileMoney = "common/gold.png"
    end
    -- self.fileMoney = "common/gold.png"    
    self.colorArray = {cc.c3b(253, 234, 109),cc.c3b(188,255,0),cc.c3b(79,214,254),cc.c3b(255,255,255)}--fdea6d  bcff00 4fd6fe ffffff  
    -- 初始化界面
    self:createUI();

    -- 初始化特效
    self:initEffect();

    -- 初始化音效
    self:initAudio();

    -- ceshi
    --self:performWithDelay(function() self:testPlay(); end, 1.0)
    self._dataModel = require("landlord.DateModel").new()

    self.changeTableTime = 3.0

    --滚动消息数组
    self.scrollMessageArr = {}

    self.scrollMessageKindArr = {}

    --按键处理
    self:setKeypadEnabled(true)
    self:addNodeEventListener(cc.KEYPAD_EVENT, function(event)
        if event.key == "back" then
            self:onBackRoom()
        end
    end)

    --每局牌的牌型统计
    self.has_out_king_boom = false
    self.has_out_boom_nums = 0
    self.has_out_three_plane = false
end

function PlayScene:userMoney(player)
    return player.score 

    -- if self.isHappyBeans then
    --     return player.beans 
    -- else
    --     return player.score
    -- end
    
end

function PlayScene:initAudio()
    
end

function PlayScene:createUI()
	-- body
    
    self:initTopView();
    self:initPlayerView();
    self:initOther();
    local inReview = false
    if OnlineConfig_review == nil or OnlineConfig_review == "on" then
        inReview = true;
    end

    if inReview == false then
        self:initTable();
        -- self:gift()
    end
    --self:performWithDelay(function() self:initSeatInfo() end, 1.0)

end

function PlayScene:initTable()
    --滚动消息
    local scrollTextContainer = ccui.Layout:create()
    scrollTextContainer:setContentSize(cc.size(600,30))
    scrollTextContainer:setPosition(cc.p(display.left + 100, display.top - 60))
    self.container:addChild(scrollTextContainer, LAYER_Z_ORDER.Z_EFFECT)
    scrollTextContainer:setVisible(false)
    self.scrollTextContainer = scrollTextContainer
    local scrollBg = ccui.ImageView:create("landlordVideo/scroll_bg.png")
    scrollBg:setPosition(cc.p(313,15))
    scrollTextContainer:addChild(scrollBg)
    local scrollTextPanel = ccui.Layout:create()
    scrollTextPanel:setContentSize(cc.size(626,30))
    scrollTextPanel:setName("scrollTextPanel")
    scrollTextPanel:setPosition(cc.p(0,0))
    scrollTextPanel:setClippingEnabled(true)
    scrollTextContainer:addChild(scrollTextPanel)
    local labaImg = ccui.ImageView:create("landlordVideo/scroll_laba.png")
    labaImg:setPosition(cc.p(20,15))
    labaImg:setName("labaImg")
    scrollTextContainer:addChild(labaImg)

    print("self.isHappyBeans", self.isHappyBeans)
    --暂不开启
    if self.isHappyBeans then
        --[[
        local couponLayer = require("landlord.ViewCoupon2Layer").new()
        couponLayer:addTo(self.container, LAYER_Z_ORDER.Z_COUPON)
        couponLayer:align(display.CENTER, display.cx, display.cy)
        ]]
    else
        --[[
        local couponLayer = require("landlord.ViewCouponLayer").new()
        couponLayer:addTo(self.container, LAYER_Z_ORDER.Z_COUPON)
        couponLayer:align(display.CENTER, display.cx, display.cy)
        couponLayer:setBetEnable(false)
        self.couponLayer = couponLayer
        ]]
        --自己酒杯
        local bgSprite = display.newSprite("view/cup_bg.png"):addTo(self.container, LAYER_Z_ORDER.Z_CUP):align(display.CENTER,display.left + 70, display.bottom + 130)
        bgSprite:runAction(cc.RepeatForever:create(cc.RotateBy:create(3.0, 180)))
        local button = ccui.Button:create("view/cup.png");
        button:setPressedActionEnabled(false)
        button:addTouchEventListener(
            function ( sender,eventType )
                if eventType == ccui.TouchEventType.ended then
                    SoundManager.playSound("sound/buttonclick.mp3")
                    local userInfo = DataManager:getMyUserInfo()
                    self:onClickCup({targetUserID=userInfo.userID,sceneID=2})
                end
            end
            )
        button:align(display.CENTER, display.left + 70, display.bottom + 130)
        button:addTo(self.container, LAYER_Z_ORDER.Z_CUP)
        
        self.myCupBg = bgSprite
        self.myCup = button
        --下家酒杯
        local bgSprite = display.newSprite("view/cup_bg.png"):addTo(self.container, LAYER_Z_ORDER.Z_CUP):align(display.CENTER, display.right - 180, display.cy + 160)
        bgSprite:runAction(cc.RepeatForever:create(cc.RotateBy:create(3.0, 180)))
        local button = ccui.Button:create("view/cup.png");
        button:setPressedActionEnabled(false)
        button:addTouchEventListener(
            function ( sender,eventType )
                if eventType == ccui.TouchEventType.ended then
                    SoundManager.playSound("sound/buttonclick.mp3")
                    local userInfo = DataManager:getUserInfoInMyTableByChairID(self.nextID)
                    self:onClickCup({targetUserID=userInfo.userID,sceneID=1})
                end
            end
            )
        button:align(display.CENTER, display.right - 180, display.cy + 160)
        button:addTo(self.container, LAYER_Z_ORDER.Z_CUP)
        
        self.nextCupBg = bgSprite
        self.nextCup = button

        --上家酒杯
        local bgSprite = display.newSprite("view/cup_bg.png"):addTo(self.container, LAYER_Z_ORDER.Z_CUP):align(display.CENTER, display.left + 180, display.cy + 160)
        bgSprite:runAction(cc.RepeatForever:create(cc.RotateBy:create(3.0, 180)))
        local button = ccui.Button:create("view/cup.png");
        button:setPressedActionEnabled(false)
        button:addTouchEventListener(
            function ( sender,eventType )
                if eventType == ccui.TouchEventType.ended then
                    SoundManager.playSound("sound/buttonclick.mp3")
                    local userInfo = DataManager:getUserInfoInMyTableByChairID(self.preID)
                    self:onClickCup({targetUserID=userInfo.userID,sceneID=1})
                end
            end
            )
        button:align(display.CENTER, display.left + 180, display.cy + 160)
        button:addTo(self.container, LAYER_Z_ORDER.Z_CUP)
        
        self.preCupBg = bgSprite
        self.preCup = button

    end
end

function PlayScene:onClickCup(event)
    onUmengEvent("1046")
    local targetUserID = event.targetUserID
    -- local params = {targetUserID=targetUserID,sceneID=2,sendGiftFunc=function(self,event) self:sendGift(self,event) end,sendGiftCallBackTarget = self}
    event.target = self
    if targetUserID then
        if self.giftInfoLayer == nil then
            self.giftInfoLayer = require("landlord.GiftInfo2Layer").new(event)
            -- self.giftInfoLayer:addEventListener(GameCenterEvent.EVENT_BUY_PROPERTY, handler(self, self.sendGift))
            self.giftInfoLayer:addTo(self.container, LAYER_Z_ORDER.Z_EFFECT)
        end
        print("PlayScene...onSendProperty:",targetUserID)
        self.giftInfoLayer:showGiftInfo2Layer(targetUserID)
    end
end

function PlayScene:sendGift(event)
    if self._step < 1 then
        Hall.showTips("游戏开始后才可以赠送噢！")
        return
    end
    dump(event, "PlayScene:sendGift---event")
    self.giftInfoLayer:hide()

    local giftIndex = event.giftIndex
    local giftPrice = event.giftPrice
    local giftCount = event.giftCount
    local targetUserID = event.targetUserID

    if (giftPrice * giftCount) > DataManager:getMyUserInfo().score then
        Hall.showTips("您的金币不足！", 1.0)
        return
    end

    self.sendGiftUserIdArray[#self.sendGiftUserIdArray + 1] = targetUserID

    PropertyInfo:sendBuyPropertyRequest(giftIndex, giftCount)

end

function PlayScene:onBuyPropertySuccess(event)
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

function PlayScene:gift()
    local giftbg = ccui.ImageView:create("hall/pochan/giftbg.png")
    self.container:addChild(giftbg)
    giftbg:setPosition(835, 590)
    local giftbtn = ccui.Button:create("hall/pochan/gift.png");
    giftbtn:setPosition(cc.p(833,583));
    self.container:addChild(giftbtn);
    giftbtn:setPressedActionEnabled(true);
    giftbtn:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then


                self:giftClick();

            end
        end
    )
    local giftbottom = ccui.Button:create("hall/pochan/giftBlank.png")
    self.container:addChild(giftbottom)
    giftbottom:setPosition(830, 541)
    giftbottom:setTitleText("")
    giftbottom:setTitleColor(cc.c3b(249,228,126))
    giftbottom:setTitleFontSize(18)
    giftbottom:setPressedActionEnabled(true);
    giftbottom:setEnabled(false)
    giftbottom:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then


                self:giftClick();

            end
        end
    )
    self.giftbottom = giftbottom
    self.giftkind = 3

    Click();
end
function PlayScene:giftClick()
    if OnlineConfig_review == "on" then
        return
    end
    
    -- local kind = self.giftkind%6 +1
    -- local kind = 5--self.giftkind
    -- local kindArray = {{1,0},{2,0},{3,0},{1,1},{2,1},{3,1}};
    -- local popGift = require("hall.FirstPayGiftLayer").new(1)
    
    if RunTimeData:getDailyChargeStatus() then
        local tips = require("hall.FirstPayGiftLayer").new(2,1)
        self.container:addChild(tips,LAYER_Z_ORDER.Z_GIFT)
    else
        local tips = require("hall.FirstPayGiftLayer").new(1,1)
        self.container:addChild(tips,LAYER_Z_ORDER.Z_GIFT)
    end

    -- self.container:addChild(popGift,LAYER_Z_ORDER.Z_GIFT)
    -- self.giftkind = self.giftkind +1
end
function PlayScene:GameBank()
    local gamebank = require("landlord1vs1.GameBankLayer").new()
    self.container:addChild(gamebank,LAYER_Z_ORDER.Z_GIFT)
end
function PlayScene:checkHasBuyGold()
    self.checkTime = 0
    self.checkValue = {["194"]=0,["188"]=0,["189"]=0}

    
    UserService:sendQueryHasBuyGoldByKind("194");
    UserService:sendQueryHasBuyGoldByKind("188");
    UserService:sendQueryHasBuyGoldByKind("189");
    -- print("checkHasBuyGold")
end
function PlayScene:getTodayWasNotPaySuccess(event)
    -- print("dispatch --getTodayWasNotPaySuccess")
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
        self.giftkind = firstPayKind
        
        local titleName = {"首充","12元","50元"}
        if self.giftbottom then
            self.giftbottom:setEnabled(true)
            self.giftbottom:setTitleText(titleName[firstPayKind])
        end
        -- if self.checkKind == 1 then
        --     local tips = require("hall.FirstPayGiftLayer").new(firstPayKind,1,self.tipStr)
        --     self.container:addChild(tips,LAYER_Z_ORDER.Z_SYTEMNOTICE)
        -- end


        self.checkTime = nil
        print("self.checkTime >= 3")
    end
end
function PlayScene:initTopView()
    local top = display.newNode()
                :addTo(self.container, LAYER_Z_ORDER.Z_BUTTONS)

    --退出房间
    local button = ccui.Button:create("common/back.png");
    button:addTouchEventListener(
        function ( sender,eventType )
            if eventType == ccui.TouchEventType.ended then
                SoundManager.playSound("sound/buttonclick.mp3")
                self:onBackRoom()
            end
        end
        )
    button:align(display.CENTER, display.left + 50, display.top - 50)
    button:addTo(top)

    --换桌
    -- button = ccui.Button:create("common/change.png");
    -- button:addTouchEventListener(
    --     function ( sender,eventType )
    --         if eventType == ccui.TouchEventType.ended then
    --             SoundManager.playSound("sound/buttonclick.mp3")
    --             --self:onChangeTable();
    --             self:onChangeRoom();
    --         end
    --     end
    --     )
    -- button:align(display.CENTER, display.right - 140, display.top - 50)
    -- button:addTo(top)
    -- self.btnChangeTable = button
    -- local pos1 = {display.right - 354,display.top - 46}
    local pos1 = {display.right - 240,display.top - 46-4}
    --补充金币（6，12礼包 等）换成保险柜
    local buchongjinbi = ccui.Button:create("common/bankIcon.png");
    buchongjinbi:align(display.CENTER, pos1[1], pos1[2])
    buchongjinbi:addTo(top)
    buchongjinbi:setPressedActionEnabled(true);
    buchongjinbi:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:GameBank();
            end
        end
    )
    self.buchongjinbi = buchongjinbi
    if self.isHappyBeans then
        buchongjinbi:hide()
    end
    -- local pos2 = {display.right - 240,display.top - 50}
    local pos2 = {display.right - 140,display.top - 50}
    --换桌,房间选择
    local room_select = ccui.Button:create("common/changeTable.png");
    room_select:align(display.CENTER, pos2[1], pos2[2])
    room_select:addTo(top)
    room_select:setPressedActionEnabled(true);
    room_select:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                -- self:onClickRoomSelect();
                self:onChangeTable()
            end
        end
    )
    self.room_select = room_select
    --托管
    local button = ccui.Button:create("common/tuoguan.png")
    button:addTouchEventListener(
        function ( sender,eventType )
            if eventType == ccui.TouchEventType.ended then
                SoundManager.playSound("sound/buttonclick.mp3")
                self:onTuoGuan();
            end
        end
        )

    button:align(display.CENTER, pos2[1], pos2[2])
    button:addTo(top)
    button:hide()
    self.btnTuoGuan = button
    -- local pos3 = {display.right - 140,display.top - 50}
    local pos3 = {display.right - 140,display.top - 50}
    --换牌
    local changePoker = ccui.Button:create("common/changePoker.png")
    changePoker:addTouchEventListener(
        function ( sender,eventType )
            if eventType == ccui.TouchEventType.ended then
                SoundManager.playSound("sound/buttonclick.mp3")
                self:changePokerHandler();
            end
        end
        )

    changePoker:align(display.CENTER, display.right - 140, display.top - 50)
    changePoker:addTo(top)
    changePoker:hide()
    self.changePoker = changePoker

    --时钟
    self.clock = display.newTTFLabel({text = "12:30",
                                size = 28,
                                color = cc.c3b(128,16,48),
                                font = FONT_ART_TEXT,
                                align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                            })
                :align(display.CENTER_TOP, display.right - 50, display.top - 35)
                :addTo(top)

end

function PlayScene:initPlayerView()
    display.newScale9Sprite("play3/bottom.png", 0, 0, cc.size(display.width - 50, 60))
                        :addTo(self.container, LAYER_Z_ORDER.Z_BUTTONS)
                        :align(display.CENTER, display.cx, display.bottom + 30)

    self.playerIcon = {};
    self.vipImage = {};
    self.nickName = {};
    self.gold = {};
    self.userStateMark = {}

    -- 玩家信息
    self.userStateMark[1] = display.newSprite("play3/ok.png")
        :addTo(self.container, LAYER_Z_ORDER.Z_PLAYER)
        :align(display.CENTER, display.cx, display.cy + 60)
        :hide()

    local sprite = display.newScale9Sprite("common/txtBg.png", 0, 0, cc.size(160, 51))
                        :addTo(self.container, LAYER_Z_ORDER.Z_BUTTONS)
                        :align(display.LEFT_CENTER, display.left+75, display.bottom + 30)
    self.nickName[1] = display.newTTFLabel({text = "",
                                size = 22,
                                font = FONT_ART_TEXT,
                                color = cc.c3b(255,255,100),
                                align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                            })
                :align(display.LEFT_CENTER, 20, 35)
                :addTo(sprite)
    self.level = display.newTTFLabel({text = "lv.1",
                                size = 24,
                                font = FONT_ART_TEXT,
                                color = cc.c3b(255,255,100),
                                align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                            })
                :align(display.LEFT_CENTER, 20, 13)
                :addTo(sprite)

    local icon = display.newSprite():scale(0.7);
    local button = ccui.Button:create("head/frame.png");
    button:setPressedActionEnabled(false)
    button:addTouchEventListener(
        function ( sender,eventType )
            if eventType == ccui.TouchEventType.ended then
                SoundManager.playSound("sound/buttonclick.mp3")
                self:onClickUserInfo(1)
            end
        end
        )
    button:align(display.CENTER, display.left + 55, display.bottom + 40)
    button:addTo(self.container, LAYER_Z_ORDER.Z_BUTTONS)
    icon:addTo(button):align(display.CENTER, 45, 54)
    icon:setTexture("play3/icon_nm.png")
    button:scale(0.8)
    self.playerIcon[1] = icon

    self.vipImage[1] = display.newSprite():addTo(button):align(display.LEFT_BOTTOM, 60,60)

    -----------------------------------------------
    self.userStateMark[2] = display.newSprite("play3/ok.png")
        :addTo(self.container, LAYER_Z_ORDER.Z_PLAYER)
        :align(display.CENTER, display.right - 200, display.cy + 120)
        :hide()

    icon = display.newSprite():scale(0.7);
    button = ccui.Button:create("head/frame.png");
    button:setPressedActionEnabled(false)
    button:addTouchEventListener(
        function ( sender,eventType )
            if eventType == ccui.TouchEventType.ended then
                SoundManager.playSound("sound/buttonclick.mp3")
                self:onClickUserInfo(2)
            end
        end
        )
    button:align(display.CENTER, display.right - 80, display.cy + 115)
    button:addTo(self.container, LAYER_Z_ORDER.Z_BUTTONS)
    icon:addTo(button):align(display.CENTER, 45, 54)
    icon:setTexture("play3/icon_nm.png")
    self.playerIcon[2] = icon
    
    self.vipImage[2] = display.newSprite():addTo(button):align(display.LEFT_BOTTOM, 60,60)

    sprite = display.newScale9Sprite("play3/info_bg.png", 0, 0, cc.size(133, 54))
                        :addTo(button)
                        :align(display.CENTER, 50, -20)
                        --:align(display.CENTER, 0, -80)
    self.nickName[2] = display.newTTFLabel({text = "",
                                size = 24,
                                --font = FONT_ART_BUTTON,
                                color = cc.c3b(255,255,255),
                                align = cc.ui.FONT_ART_TEXT
                            })
                :align(display.CENTER, 66, 40)
                :addTo(sprite)
    local gold = display.newSprite(self.fileMoney)
                    :addTo(sprite)
                    :align(display.CENTER, 20, 13)
    gold:scale(0.6)
    self.gold[2] = display.newTTFLabel({text = "",
                                size = 24,
                                color = cc.c3b(255,255,105),
                                align = cc.ui.FONT_ART_TEXT
                            })
                :align(display.CENTER, 75, 15)
                :addTo(sprite)

    ------------------------------------------
    self.userStateMark[3] = display.newSprite("play3/ok.png")
        :addTo(self.container, LAYER_Z_ORDER.Z_PLAYER)
        :align(display.CENTER, display.left + 200, display.cy + 120)
        :hide()

    icon = display.newSprite():scale(0.7);
    button = ccui.Button:create("head/frame.png");
    button:setPressedActionEnabled(false)
    button:addTouchEventListener(
        function ( sender,eventType )
            if eventType == ccui.TouchEventType.ended then
                SoundManager.playSound("sound/buttonclick.mp3")
                self:onClickUserInfo(3)
            end
        end
        )
    button:align(display.CENTER, display.left + 80, display.cy + 115)
    button:addTo(self.container, LAYER_Z_ORDER.Z_BUTTONS)
    icon:addTo(button):align(display.CENTER, 45, 54)
    icon:setTexture("play3/icon_dz.png")
    self.playerIcon[3] = icon
    
    self.vipImage[3] = display.newSprite():addTo(button):align(display.LEFT_BOTTOM, 60,60)

    sprite = display.newScale9Sprite("play3/info_bg.png", 0, 0, cc.size(133, 54))
                        :addTo(button)
                        :align(display.CENTER, 50, -20)
                        
    self.nickName[3] = display.newTTFLabel({text = "",
                                size = 24,
                                --font = FONT_ART_BUTTON,
                                color = cc.c3b(255,255,255),
                                align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                            })
                :align(display.CENTER, 66, 40)
                :addTo(sprite)
    gold = display.newSprite(self.fileMoney)
                    :addTo(sprite)
                    :align(display.CENTER, 20, 13)
                    :scale(0.6)
    self.gold[3] = display.newTTFLabel({text = "",
                                size = 24,
                                color = cc.c3b(255,255,105),
                                align = cc.ui.TEXT_ALIGN_CENTER
                            })
                :align(display.CENTER, 75, 15)
                :addTo(sprite)
    


    -- 自己的金币信息
    local plus = display.newSprite("common/plus.png");
    local gold = display.newSprite(self.fileMoney)
    local button = ccui.Button:create("common/txtBg.png")
    button:setScale9Enabled(true);
    button:setContentSize(cc.size(220, 51));
    button:setTitleFontName(FONT_ART_TEXT);
    button:setTitleText("");
    button:setTitleColor(cc.c3b(255,255,100));
    button:setTitleFontSize(30);
    button:setPressedActionEnabled(true);
    button:setEnabled(false)
    --button:getTitleRenderer():enableOutline(COLOR_BTN_BLUE,2);
    button:addTouchEventListener(
        function ( sender,eventType )
            if eventType == ccui.TouchEventType.began then
                plus:scale(1.1)
            elseif eventType == ccui.TouchEventType.ended then
                plus:scale(1.0)
                --SoundManager.playSound("sound/buttonclick.mp3")
                --self:onClickAddGold()
            elseif eventType == ccui.TouchEventType.canceled then
                plus:setScale(1.0)                
            end
        end
        )
    button:align(display.CENTER, display.cx-215, display.bottom + 30)
    button:addTo(self.container, LAYER_Z_ORDER.Z_BUTTONS)

    plus:addTo(button):align(display.CENTER, 190, 25):hide()
    gold:addTo(button):align(display.CENTER, 20, 26)
    self.gold[1] = button
    self.mygold = gold
end

function PlayScene:switchChairID()
    if self.myChairID == 1 then
        self.nextID = 2
        self.preID = 3
    elseif self.myChairID == 2 then
        self.nextID = 3
        self.preID = 1
    elseif self.myChairID == 3 then
        self.nextID = 1
        self.preID = 2
    end
end

function PlayScene:refreshUI()

    local myID = self.myChairID or 1
    local nextID = self.nextID or 2
    local preID = self.preID or 3

    self.myChairID = DataManager:getMyChairID()
    if self.myChairID == Define.INVALID_CHAIR then
        self.myChairID = 1
    end
    self:switchChairID()

    local icons={}
    local vip={}
    local names={}
    local golds={}
    local ready={}


    icons[self.myChairID] = self.playerIcon[myID]
    icons[self.nextID] = self.playerIcon[nextID]
    icons[self.preID] = self.playerIcon[preID]

    vip[self.myChairID] = self.vipImage[myID]
    vip[self.nextID] = self.vipImage[nextID]
    vip[self.preID] = self.vipImage[preID]

    names[self.myChairID] = self.nickName[myID]
    names[self.nextID] = self.nickName[nextID]
    names[self.preID] = self.nickName[preID]

    golds[self.myChairID] = self.gold[myID]
    golds[self.nextID] = self.gold[nextID]
    golds[self.preID] = self.gold[preID]

    ready[self.myChairID] = self.userStateMark[myID]
    ready[self.nextID] = self.userStateMark[nextID]
    ready[self.preID] = self.userStateMark[preID]

    self.playerIcon = icons
    self.vipImage = vip
    self.nickName = names
    self.gold = golds
    self.userStateMark = ready
end

function PlayScene:initOther()

    -- 开始游戏按钮
    local button = ccui.Button:create("common/btn_start.png")
    button:addTouchEventListener(
        function ( sender,eventType )
            if eventType == ccui.TouchEventType.ended then
                SoundManager.playSound("sound/buttonclick.mp3")
                self:onGameStart(0);
                sender:hide()
            end
        end
        )
    button:align(display.CENTER, display.cx, display.cy-160)
    button:addTo(self.container, LAYER_Z_ORDER.Z_BUTTONS)
    button:getTitleRenderer():enableOutline(COLOR_BTN_BLUE,1);
    button:hide()
    self.btnStartGame = button

    --聊天按钮
    local button = ccui.Button:create("play3/btn_chat.png")
    button:addTouchEventListener(
        function(sender, event)
            if event == ccui.TouchEventType.ended then
                SoundManager.playSound("sound/buttonclick.mp3")
                self:popMsgWindow(0,0);
                onUmengEvent("1043")
            end
        end)
    button:align(display.CENTER, display.cx + 470, display.bottom + 30)
    button:addTo(self.container, LAYER_Z_ORDER.Z_BUTTONS)

    -- 礼券信息
    local liquan = display.newSprite("liquan/lq_icon0.png")
    local button = display.newScale9Sprite("common/txtBg.png", 0, 0, cc.size(200, 51))
                    :align(display.CENTER, display.cx, display.bottom + 30)
                    :addTo(self.container, LAYER_Z_ORDER.Z_BUTTONS)
                    
    liquan:addTo(button):align(display.CENTER, 35, 20)
    self.liquanNum = display.newTTFLabel({text = "0张",
                                size = 28,
                                font = FONT_ART_TEXT,
                                color = cc.c3b(255,255,100),
                                align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                            })
                :align(display.CENTER, 115, 25)
                :addTo(button,0,0)

    if OnlineConfig_review == nil or OnlineConfig_review == "on" then
        button:hide()
    end
    --任务
    local taskNode = display.newNode():addTo(self.container,LAYER_Z_ORDER.Z_BUTTONS):align(display.CNETER, display.right-80, 267)
    local taskBG = display.newSprite("hall/task/renwu_bg.png"):addTo(taskNode)
    self.taskBG = taskBG
    local task = ccui.Button:create("hall/task/renwu.png")
    -- task:setPosition(display.right-74-5, 267)
    taskNode:addChild(task)
    self.taskNode = taskNode
    task:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:onClickTask();
            end
        end
    )
    self.task = task
    if self.isHappyBeans then
        taskNode:show()
        local armature = EffectFactory:getInstance():getAnimationTask()
        armature:setPosition(cc.p(37, 38))
        armature:setPosition(37, 38)
        task:addChild(armature)
        self.taskEffect = armature
    else 
        taskNode:hide()
    end

    -- 底分信息
    local gold = display.newSprite("common/fen.png")
    local button = display.newScale9Sprite("common/txtBg.png", 0, 0, cc.size(126, 51))
                    :align(display.CENTER, display.cx+190, display.bottom + 30)
                    :addTo(self.container, LAYER_Z_ORDER.Z_BUTTONS)
    gold:addTo(button):align(display.CENTER, 15, 25)
    self.difenNum = display.newTTFLabel({text = "0",
                                size = 28,
                                font = FONT_ART_TEXT,
                                color = cc.c3b(255,255,100),
                                align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                            })
                :align(display.CENTER, 70, 25)
                :addTo(button,0,0)


    -- 倍数信息
    --local plus = display.newSprite("common/plus.png");
    local gold = display.newSprite("common/times.png")
    local button = display.newScale9Sprite("common/txtBg.png", 0, 0, cc.size(126, 51))
                    :align(display.CENTER, display.cx + 335, display.bottom + 30)
                    :addTo(self.container, LAYER_Z_ORDER.Z_BUTTONS)

    --plus:addTo(button):align(display.CENTER, 67, 0)
    gold:addTo(button):align(display.CENTER, 15, 25)
    self.plusNum = display.newTTFLabel({text = "0",
                                size = 28,
                                font = FONT_ART_TEXT,
                                color = cc.c3b(255,255,100),
                                align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                            })
                :align(display.CENTER, 70, 25)
                :addTo(button,0,0)
    
end
function PlayScene:changePokerHandler()
    -- body
end
function PlayScene:addGoldAnimation(gold)
    gold = gold or 5000
    local addgoldffect = EffectFactory:getInstance():getAnimationAddGold()
    local ac = cc.Animate:create(addgoldffect)
    local addgoldffectsprite = cc.Sprite:create()
    local repeatAc = cc.Repeat:create(ac, 3)
    addgoldffectsprite:runAction(cc.Sequence:create(repeatAc, cc.CallFunc:create(function() addgoldffectsprite:removeSelf() end) ))
    addgoldffectsprite:setPosition(29, 29)
    self.mygold:addChild(addgoldffectsprite)

    local txtPos = cc.p(display.left+300, display.bottom + 40)
    local moneytxt = ccui.Text:create("", FONT_ART_TEXT, 30)
    moneytxt:setPosition(txtPos)
    moneytxt:setFontSize(30)
    moneytxt:setString("+"..gold)
    moneytxt:setColor(cc.c4b(253,229,12,255))
    moneytxt:enableOutline(cc.c4b(94,40,5,255),2)
    self.container:addChild(moneytxt,100)
    local moveby = cc.MoveBy:create(1, cc.p(0, 100))
    moneytxt:runAction(cc.Sequence:create(moveby, cc.CallFunc:create(function() moneytxt:removeSelf() end) ))
end
function PlayScene:onClickTask()
    self.taskBG:hide()
    self.taskEffect:hide()

    if not self.taskLayer then
        self.taskLayer = require("hall.TaskLayer").new()
        self.container:addChild(self.taskLayer, LAYER_Z_ORDER.Z_ROOMSELECT)
        self.taskLayer:refreshTaskList()
    else
        self.taskLayer:show()
    end
    --[[
    local TaskLayer = require("hall.TaskLayer")
    local task = TaskLayer:getInstance();
    task:retain()
    if task and task:getParent() ==nil then
        task:refreshTaskList()
        self.container:addChild(task, LAYER_Z_ORDER.Z_ROOMSELECT)
    end   
    ]]
    Click()
end
function PlayScene:gameMessageHandler(event)
    local msgString = SystemMessageInfo.curMessage
    local wType = event.value
    local colorkind = 1
    if ((bit.band(wType,Define.SMT_SYSTEM_MSG)) == Define.SMT_SYSTEM_MSG) then--系统消息
        colorkind = 1
    end
    if ((bit.band(wType,Define.SMT_PLYER_MSG)) == Define.SMT_PLYER_MSG) then--玩家喊话消息
        colorkind = 2
    end
    if ((bit.band(wType,Define.SMT_AWARD_MSG)) == Define.SMT_AWARD_MSG) then--奖励消息
        colorkind = 3
    end
    if ((bit.band(wType,Define.SMT_ACTIVITY_MSG)) == Define.SMT_ACTIVITY_MSG) then--活动消息
        colorkind = 4
    end

    self:showScrollMessage(msgString,self.colorArray[colorkind],colorkind)
end
function PlayScene:onClickRoomSelect()
    print("onClickRoomSelect")
    local room_select = require("hall.RoomSelectLayer").new(1);
    self.container:addChild(room_select,LAYER_Z_ORDER.Z_ROOMSELECT)
    Click();
end
function PlayScene:registerEventListener()
    self.bindIds = {}

    self.bindIds[#self.bindIds + 1] = BindTool.bind(RoomInfo, "userInfo", handler(self, self.onUserEnter));
    self.bindIds[#self.bindIds + 1] = BindTool.bind(TableInfo, "userStatus", handler(self, self.onUserStatusChange));
    self.bindIds[#self.bindIds + 1] = BindTool.bind(TableInfo, "signUp", handler(self, self.onUserSignUp));
    self.bindIds[#self.bindIds + 1] = BindTool.bind(DoudizhuInfo, "DDZ_PROTOCOL", handler(self, self.onServerMsgCallBack));
    self.bindIds[#self.bindIds + 1] = BindTool.bind(AccountInfo, "score", handler(self, self.setSelfInfo))

    --系统消息处理
    self.bindIds[#self.bindIds + 1] = BindTool.bind(SystemMessageInfo, "msgRresh", handler(self, self.gameMessageHandler))

    self.bindIds[#self.bindIds + 1] = BindTool.bind(PropertyInfo, "buyPropertyResult", handler(self, self.onBuyPropertySuccess));
    self.bindIds[#self.bindIds + 1] = BindTool.bind(PropertyInfo, "usePropertyResult", handler(self, self.onUsePropertyResult));
    self.bindIds[#self.bindIds + 1] = BindTool.bind(PropertyInfo, "usePropertyBroadcast", handler(self, self.onPropertySuccess));
    --礼券开奖
    self.bindIds[#self.bindIds + 1] = BindTool.bind(MissionInfo, "missionInfo", handler(self, self.onMissionMessage))

    self.eventHandler = HallEvent:addEventListener(HallEvent.AVATAR_DOWNLOAD_URL_SUCCESS, handler(self, self.onDownloadCustomFaceUrlBackHandler))

--[[
	-- 注册GameCenter监听事件
    GameCenter:addEventListener(GameCenterEvent.EVENT_USER_SIGNUP, handler(self, self.onUserSignUp))
    GameCenter:addEventListener(GameCenterEvent.EVENT_USER_SIGNUP_NOUSER, handler(self, self.showMatching))
    GameCenter:addEventListener(GameCenterEvent.EVENT_USER_ENTER, handler(self, self.onUserEnter))
    GameCenter:addEventListener(GameCenterEvent.EVENT_STATUS_CHANGED, handler(self, self.onUserStatusChange))
    
    GameCenter:addEventListener(GameCenterEvent.EVENT_GAME_MESSAGE, handler(self, self.onServerMsgCallBack))
    GameCenter:addEventListener(GameCenterEvent.EVENT_GAME_SCENE, handler(self, self.onServerGameScene))

    GameCenter:addEventListener(GameCenterEvent.EVENT_TIMEBOXAWARD_RESULT, handler(self, self.onTimeBoxAwardResult))
    self.SMT_TABLE_ROLL = GameCenter:addEventListener(GameMessageType.SMT_TABLE_ROLL, handler(self, self.gameMessageHandler))
    
    self.handler4 = GameCenter:addEventListener(GameCenterEvent.EVENT_ROOM_CONFIG_RESULT, handler(self, self.roomConfigResult))
    self.handler1 = GameCenter:addEventListener(GameCenterEvent.EVENT_SYSTEM_NOTICE, handler(self, self.systemNoticeHandler))
    self.handler6 = HallCenter:addEventListener(HallCenterEvent.EVENT_RECEIVEGOLD_RESULT, handler(self, self.receiveGoldBackHandler))
    --游戏链接取救济金
    self.handler_RECEIVEGOLD = GameCenter:addEventListener(GameCenterEvent.EVENT_RECEIVEGOLD_RESULT, handler(self, self.receiveGoldBackHandler))

    self.handler3 = UserService:addEventListener(GameCenterEvent.EVENT_APPPURCHASE_SUCCESS, handler(self, self.appPurchasesSuccessBack))
    self.handler2 = UserService:addEventListener(HallCenterEvent.EVENT_QUERY_TODAYWASNOTPAY_SUCCESS, handler(self, self.getTodayWasNotPaySuccess))
    self.handler_getExchangeValueSuccess = UserService:addEventListener(HallCenterEvent.EVENT_QUERY_LEFTEXCHANGEBEAN_SUCCESS, handler(self, self.getExchangeValueSuccess))
    self.handler_getExchangeValueFailure = UserService:addEventListener(HallCenterEvent.EVENT_QUERY_LEFTEXCHANGEBEAN_FAILURE, handler(self, self.getExchangeValueFailure))
    self.handler_room_exchage_beans = GameCenter:addEventListener(GameCenterEvent.EVENT_ROOM_EXCHAGE_BEANS, handler(self,self.onExchangeCallBack))
    self.handler_AVATARDOWNLOADURL = UserService:addEventListener(HallCenterEvent.EVENT_AVATARDOWNLOADURL, handler(self, self.customFaceUrlBackHandler))
    --道具购买成功
    self.handler_PROPERTY_SUCCESS = GameCenter:addEventListener(GameCenterEvent.EVENT_PROPERTY_SUCCESS, handler(self, self.onPropertySuccess))
    --银行更新
    self.handler_QUERY_INSURE_FOR_GAME = GameCenter:addEventListener(GameCenterEvent.EVENT_QUERY_INSURE_FOR_GAME, handler(self, self.onQueryUserInsure))
    --礼券开奖
    self.handler_COUPON = GameCenter:addEventListener(GameCenterEvent.EVNET_COUPON, handler(self, self.onServerMessage))
    --结算清场
    GameCenter:addEventListener(GameCenterEvent.EVENT_SYSTEM_MESSAGE, handler(self, self.onReceiveSystemMessage))
]]
    -- 注册 update 事件
    self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function(dt)
        self:onEnterFrame(dt);
    end)
    self:scheduleUpdate();
end

function PlayScene:setSelfInfo()
    -- 顶部设置自己的属性
    print("===刷新自己的金币数量！")
    local myInfo = DataManager:getMyUserInfo()
    if(myInfo ~= nil) then
        self:setPlayerInfo(myInfo.chairID, "gold", self:userMoney(myInfo))
    end
end

function PlayScene:getExchangeValueSuccess(event)
    local info = protocol.hall.treasureInfo_pb.CMD_GP_QuerySurplusExchageResult_Pro();
    info:ParseFromString(event.data)
    self.leftExchangeValue = info.lSurplusExchageCount;
    self:onChangeRoom()
    self:initSeatInfo()
end
function PlayScene:getExchangeValueFailure(event)
    -- local info = protocol.hall.treasureInfo_pb.CMD_GP_UserInsureFailure_Pro();
    -- info:ParseFromString(event.data)

end

function PlayScene:onReceiveSystemMessage(event)
    if self.isHappyBeans and event.type==GameMessageType.CLOSE_GAME and event.msg then
        Hall.showTips(event.msg.szString, 3.0)
        self:onBackRoom()
    end
end

function PlayScene:systemNoticeHandler(event)
    local wType = event.wType
    local tipStr = event.szString;
    if wType == 5 then

        local zhunru = self:getMinEnterScore()
        local totalGold = DataManager:getMyUserInfo().score+DataManager:getMyUserInfo().tagUserInfo.lInsure
        if totalGold >= zhunru then
            self:GameBank()
        else
            self:giftClick()
        end
    elseif wType == 9 then-- 斗地主欢乐豆场 最大金币限制
        Hall.showTips(tipStr, 1)
        GameConnection:closeRoomSocketDelay(2.0)

        self:performWithDelay(
            function ()
                self:onServerExitScene(nil);
            end,
            1.0
        )
    else
        if self.isHappyBeans then
            self:performWithDelay(function()
                GameCenter:receiveGold(1)
            end, 2)
        else
            self:performWithDelay(function()
                GameCenter:receiveGold(2)
            end, 2)  
        end
    end

    -- GameCenter:closeRoomSocket()
end
function PlayScene:getMinEnterScore()
    local minEnterScore = 10000000
    local gameServer = RunTimeData:getCurGameServer()
    if gameServer then
        local min = gameServer.minEnterScore
        local max = gameServer.maxEnterScore
        minEnterScore = min
        print("minEnterScore",minEnterScore,"gameServerName==",gameServer.serverName)
    end
    return minEnterScore
end
function PlayScene:onQueryUserInsure(event)
    self:initSeatInfo()
end

function PlayScene:receiveGoldBackHandler(event)
    local result = event.data.dwResultCode--结果 0成功 其他=失败
    if result == 0 then
        local gold =  event.data.dwReceiveVaule
        if event.data.dwReceiveType == 1 then
            local myInfo = DataManager:getMyUserInfo()
            myInfo:setbeans(myInfo.beans+gold)
            -- self.goldValueText:setString(FormatNumToString(myInfo.beans))
            Hall.showTips("成功领取"..gold.."欢乐豆",1)
            self:addGoldAnimation(gold)
        end
        if event.data.dwReceiveType == 2 then
            local myInfo = DataManager:getMyUserInfo()
            myInfo:setScore(myInfo.score+gold)
            
            -- UserService:sendQueryInsureInfo()
            BankInfoInGame:sendQueryRequest()
            Hall.showTips("破产了，系统君送上"..gold.."金币，继续游戏吧！",3)
            self:addGoldAnimation(gold)
        end
        self:initSeatInfo()
        
    else
        Hall.showTips("领取失败",2)
    end
    
end

function PlayScene:appPurchasesSuccessBack( event )

    Hall.showWaiting(2)
    ---延迟一秒，为了让内存中用户的金币先更新
    local function onInterval(dt)
        self:onChangeRoom()
    end
    local scheduler = require("framework.scheduler")
    scheduler.performWithDelayGlobal(onInterval, 1)
    
end

function PlayScene:onExchangeCallBack(event)
    if event.subId == CMD_LogonServer.SUB_GP_EXCHANGE_BEANS_SUCCESS then--
        -- self:initSeatInfo()
        Hall.showTips("购买欢乐豆成功！", 1.0)

    elseif event.subId == CMD_LogonServer.SUB_GP_EXCHANGE_BEANS_FAILURE then--
        local exchangeFailure = protocol.hall.treasureInfo_pb.CMD_GP_ExchangeBeansFailure_Pro()
        exchangeFailure:ParseFromString(event.data)
        local msg = exchangeFailure.szDescribeString;
        Hall.showTips(msg, 1.0)
        
    end

    self:onChangeRoom()
end

function PlayScene:customFaceUrlBackHandler(event)
    print("PlayScene:customFaceUrlBackHandler","url=",event.url,"tokenID--",event.tokenID)
    -- display.removeSpriteFrameByImageName(RunTimeData:getLocalAvatarImageUrlByTokenID(event.tokenID))
    self:refreshUI()
    self:initSeatInfo();

    if self.couponLayer then
        self.couponLayer:refreshHisInfo()
    end
end

function PlayScene:initEffect()

end

function PlayScene:onEnterFrame(dt)
    if self.changeTableTime < 3.0 then
        self.changeTableTime = self.changeTableTime + dt
    end

    self.clock:setString(os.date("%H:%M", os.time()))
end

function PlayScene:onTimeBoxAwardResult(event)
    local pTimeBoxAwardResult = event.data
    if pTimeBoxAwardResult.dwResultCode == 0 then
        local timeBoxRecord = RunTimeData:loadTimeBoxRecord()
        if timeBoxRecord.boxType == pTimeBoxAwardResult.dwBoxType then
            timeBoxRecord.boxType = timeBoxRecord.boxType + 1
            timeBoxRecord.recordDate = os.date("%Y%m%d")
            if timeBoxRecord.boxType <= #TimeBoxConfig then
                timeBoxRecord.leftSecond = TimeBoxConfig[timeBoxRecord.boxType]
                timeBoxRecord.hasBox = true
            else
                timeBoxRecord.leftSecond = 0
                timeBoxRecord.hasBox = false
            end
            RunTimeData:saveTimeBoxRecord(timeBoxRecord)
            -- 修改用户显示的钱
            self:onMyScoreAdd(pTimeBoxAwardResult.dwAwardScore)
            self._treasureBox:onOpenTimeBox(timeBoxRecord.boxType,timeBoxRecord.leftSecond,pTimeBoxAwardResult.dwAwardScore)
            print("领取宝箱成功!")
            print("data:",pTimeBoxAwardResult.dwBoxType,pTimeBoxAwardResult.dwAwardScore)
        else
            print("领取宝箱成功! 但本地异常")
        end
        
    else
        Hall.showTips(pTimeBoxAwardResult.szDescribe,1.0)
        print("领取宝箱失败!")
        print("data:",pTimeBoxAwardResult.dwResultCode,pTimeBoxAwardResult.szDescribe)
    end
end

function PlayScene:test()
    --start create data model
    local dataModel = require("app.OX.DateModel").new()
    dataModel:createTestData()
    self._dataModel = dataModel

    self._resultLayer = viewResultLayer.new({data=self._dataModel, lisenter = function() print("开始下一回合") end}):align(display.CENTER, display.cx, display.cy)
    self.root:addChild(self._resultLayer);
    self._resultLayer:test()

end

function PlayScene:reset()
    if self.cardLayer then self.cardLayer:removeSelf(); self.cardLayer = nil; end
    if self.nodeQdz then self.nodeQdz:removeSelf(); self.nodeQdz = nil; end
    if self.nodeChuPai then self.nodeChuPai:removeSelf(); self.nodeChuPai = nil; end
    if self.resultLayer then self.resultLayer:removeSelf(); self.resultLayer = nil; end
    if self.tuoguan then self.tuoguan:removeSelf(); self.tuoguan = nil; end

    self._dataModel:reset();
    self:updatePlusNum(0)
    self.downloadCount = 5

    --UI信息重置
    for id = 1, 3 do
        print("hide  reset:"..id)
        self.playerIcon[id]:hide();
        self.nickName[id]:hide();
        self.gold[id]:hide();
        self.userStateMark[id]:hide()
        self.vipImage[id]:hide()
    end

    self:refreshUI()
    self:initSeatInfo()
    --if handle then scheduler.unscheduleGlobal(handle) end
end

function PlayScene:onServerExitScene(param)--退出房间处理

    local curRoomIndex = RunTimeData:getRoomIndex()
    if curRoomIndex == 1 then
        onUmengEventEnd("1079")
    elseif curRoomIndex == 2 then
        onUmengEventEnd("1080")
    elseif curRoomIndex == 3 then
        onUmengEventEnd("1081")
    elseif curRoomIndex == 4 then
        onUmengEventEnd("1082")
    end

    --清理场景handle
    if self._djs then self._djs:stop() end--开始倒计时
    if self._selDealer then self._selDealer:stop() end--选庄
    if self._resultLayer  then self._resultLayer:stop() end
    if self._treasureBox then self._treasureBox:onGameExit() end
    
    --切换界面
    local roomScene=require("hall.RoomScene").new()
    cc.Director:getInstance():replaceScene(cc.TransitionSlideInT:create(0.5, roomScene))
    
    --游戏重连
    cc.UserDefault:getInstance():setBoolForKey("isReconnect", false)

end

--虚假数据实现用户坐下和离开
function PlayScene:onUserSignUp(pData)
    print("=================onUserSignUp", TableInfo.signUp.code, TableInfo.signUp.msg)
    local resultCode = TableInfo.signUp.code
    if resultCode ~= 0 then
        Hall.showTips(TableInfo.signUp.msg)

    else

        local userList = TableInfo.signUp.userInfoList
        print("====count userList=", #userList)
        for k,v in ipairs(userList) do
            local userInfo = v
            print("updateUserInfo===", userInfo.chairID, userInfo.faceID, userInfo.nickName, userInfo.present)
            
            local id = userInfo.chairID
            self.playerIcon[id]:show()
            self.nickName[id]:show()
            self.gold[id]:show()
            self:updatePlayerInfo(userInfo)
        end
    end
--[[
    local pUserInfoHead = protocol.room.struct_pb.tagUserInfoHead_Pro()
    pUserInfoHead:ParseFromString(pData.data)
    pUserInfoHead.wChairID = math.random(1,2)
    local userInfo = DataManager:createUserInfo(pUserInfoHead)
    
    local id = userInfo.chairID
    self.playerIcon[id]:show()
    self.nickName[id]:show()
    self.gold[id]:show()
    self:updatePlayerInfo(userInfo)
    print("=================onUserSignUp")
]]
end

function PlayScene:onUserEnter(pData)

    if pData.value.tableID ~= DataManager:getMyTableID() then
        print("不是本桌玩家进入！")
        return
    end

    local userInfo = DataManager:getUserInfoByUserID(RoomInfo.userInfo.userID)
    local tokenID = userInfo.platformID or ""
    local url = RunTimeData:getLocalAvatarImageUrlByTokenID(tokenID)

    local md5 = userInfo.platformFace
    local localmd5 = cc.Crypto:MD5File(url)
    print("自己的桌子和椅子：",DataManager:getMyUserInfo().tableID,DataManager:getMyUserInfo().chairID)
    -- print(userInfo.tableID,userInfo.chairID,pData.userID,"tokenID",tokenID,"md5===",md5,"localmd5==",localmd5,"url",url)
    if localmd5 ~= md5 and pData.faceID == 999 then
        PlatformDownloadAvatarImage(userInfo.platformID, md5)
    end

    self:refreshUI()
    self:initSeatInfo()
end

function PlayScene:onUserStatusChange(event)
    local pData = event.value
    if pData.userID == DataManager:getMyUserID() then
        print("--1111111------PlayScene:onUserStatusChange----", pData.userID, ", 用户状态：", pData.userStatus, "chairID:", pData.chairID)
    end
    if pData.tableID ~= DataManager:getMyTableID() then
        -- print("不是本桌玩家状态变化！")
        return
    end

    self:refreshUI()
    self:initSeatInfo()

    --有玩家站起，自己也站起，重新发起匹配
    --其他玩家先站起来，我不想继续游戏的时候无法处理，此处站起无法处理自己的站起逻辑
    if pData.userID == DataManager:getMyUserID() and not self.needRestart then
        print("======self.leaveType", self.leaveType)
        --其他玩家站起，自己需要重新准备
        local myUserStatus = DataManager:getMyUserStatus()
        if myUserStatus == Define.US_FREE then
            if self.leaveType == CHANGE_TABLE then--换桌
                print("====重新坐下！")
                if IS_AUTOMATCH then
                    TableInfo:sendAutoMatch()
                else
                    TableInfo:sendUserSitdownRequest(65535, 65535)
                end
            else

            end
        
        elseif myUserStatus == Define.US_SIT then
            if self.leaveType == CHANGE_TABLE then--换桌
                print("====重新准备！")
                TableInfo:sendGameOptionRequest()
            else

            end

        elseif myUserStatus == Define.US_READY then
            
        end

    elseif pData.userID == DataManager:getMyUserID() and self.needRestart then
        
        local myUserStatus = DataManager:getMyUserStatus()
        if myUserStatus == Define.US_FREE then
            print("====重新坐下！onGameStart 已发送sitdown！")        
            if IS_AUTOMATCH then
                TableInfo:sendAutoMatch()
            end

        elseif myUserStatus == Define.US_SIT then
            print("====重新准备！---- needRestart")
            TableInfo:sendGameOptionRequest()

        elseif myUserStatus == Define.US_READY then
            self.needRestart = false
            
        end
    end
end

function PlayScene:onMissionMessage(event)

    local event = {}
    event.subId = MissionInfo.mainID
    event.data = MissionInfo.missionInfo

    if event.subId == CMD_GAME.SUB_S_VOUCHER_BET then--礼券投注
        print("礼券投注返回")


    elseif event.subId == CMD_GAME.SUB_S_VOUCHER_DRAWING then----礼券开奖
        print("礼券开奖返回")
        local msg = protocol.gameServer.gameServer.mission.s2c_pb.VoucherDrawing()
        msg:ParseFromString(event.data)
        self:processOpenVoucherCallBack(msg)

    elseif event.subId == CMD_GAME.SUB_S_VOUCHER_COUNT then----礼券查询总量
        print("礼券查询返回")

    elseif event.subId == CMD_GAME.SUB_S_NEARLYDRAWED_USERLIST then
        print("历史奖励查询返回")

    elseif event.subId == CMD_GAME.SUB_S_WINTASK then
        local WinTaskCalc = protocol.gameServer.gameServer.mission.s2c_pb.userWinTaskCalc()
        WinTaskCalc:ParseFromString(event.data)
        self:winTaskCallBack(WinTaskCalc)
    end
end

function PlayScene:onServerMsgCallBack(data)
    print("PlayScene:onServerMsgCallBack! ", string.format("%x",DoudizhuInfo.mainID))

    local event = {}
    event.subId = DoudizhuInfo.mainID
    event.data = DoudizhuInfo.DDZ_PROTOCOL

if self.isRecover == true then

    if event.subId == CMD_DDZ.SUB_S_GAME_START then
        print("游戏开始---------OK")
        local curRoomIndex = RunTimeData:getRoomIndex()
        if tonumber(curRoomIndex) > 1 then
            onUmengEvent("1049")
        else
            onUmengEvent("1048")
        end
        --每局牌的牌型统计初始化
        self.has_out_king_boom = false
        self.has_out_boom_nums = 0
        self.has_out_three_plane = false

        self.room_select:hide()
        local msg = protocol.doudizhu.doudizhu.s2c_pb.CMD_S_GameStart_Pro()
        msg:ParseFromString(event.data)        
        self._dataModel:setSpring(false)
        self:step2_SendCard(msg)
        if self.couponLayer then
            self.couponLayer:setBetEnable(false)
        end

    elseif event.subId == CMD_DDZ.SUB_S_CALL_SCORE then--101--用户叫分

        print("用户叫分------OK")
        local msg = protocol.doudizhu.doudizhu.s2c_pb.CMD_S_CallScore_Pro()
        msg:ParseFromString(event.data)
        self:step3_JiaoDiZhu(msg)
  
    elseif event.subId == CMD_DDZ.SUB_S_BANKINFO then--102--庄家信息

        local msg = protocol.doudizhu.doudizhu.s2c_pb.CMD_S_BankerInfo_Pro()
        msg:ParseFromString(event.data)
        print("庄家信息" , msg.wBankerUser)
        self:step4_SetBanker(msg)
    
    elseif event.subId == CMD_DDZ.SUB_S_CARD_OUT then--103--用户出牌

        print("用户出牌-------OK")
        local msg = protocol.doudizhu.doudizhu.s2c_pb.CMD_S_OutCard_Pro()
        msg:ParseFromString(event.data)
        self:step5_OutCards(msg)
    
    elseif event.subId == CMD_DDZ.SUB_S_CARD_PASS then--104--用户放弃
        print("用户放弃")
        local msg = protocol.doudizhu.doudizhu.s2c_pb.CMD_S_PassCard_Pro()
        msg:ParseFromString(event.data)
        self:step6_Pass(msg)

    elseif event.subId == CMD_DDZ.SUB_S_GAME_CONCLUDE then--105--游戏结束
        print("游戏结束")
        self.room_select:show()
        local msg = protocol.doudizhu.doudizhu.s2c_pb.CMD_S_GameConclude_Pro()
        msg:ParseFromString(event.data)
        self:step7_GameOver(msg)

    elseif event.subId == CMD_DDZ.SUB_S_SCORE_BASE then--106--设置基数
        print("设置基数" )
        local msg = protocol.doudizhu.doudizhu.s2c_pb.CMD_S_BaseScore_Pro()
        msg:ParseFromString(event.data)
        self._dataModel:setDiFen(msg.lCellScore)
        self.difenNum:setString(FormatDigitToString(msg.lCellScore,0))

    elseif event.subId == CMD_DDZ.SUB_S_TUO_GUAN then--107--游戏托管   
        print("游戏托管" )
        local msg = protocol.doudizhu.doudizhu.s2c_pb.CMD_S_TuoGuan_Pro()
        msg:ParseFromString(event.data)
        self:gameTuoGuan(msg.bTuoGuan)

    elseif event.subId == CMD_DDZ.SUB_S_GAME_CLOCK then--108--当前操作剩余时间
        print("当前操作剩余时间" )
        local msg = protocol.doudizhu.doudizhu.s2c_pb.CMD_S_GameClock_Pro()
        msg:ParseFromString(event.data)

        local gameStatus = TableInfo.gameStatus
        if gameStatus == GAME_SCENE_CALL then --叫分
            print("--游戏叫分",msg.lTimeLeft)
            if self.nodeQdz then
                self.nodeQdz:setTime(msg.lTimeLeft)
            end
        elseif gameStatus == GAME_SCENE_PLAY then--游戏进行
            print("--游戏出牌",msg.lTimeLeft)
            if self.nodeChuPai then
                self.nodeChuPai:setTime(msg.lTimeLeft)
            end
        end
    end
end

    if event.subId == CMD_DDZ.SUB_S_GAME_CONFIG then
        print("110游戏配置")
        local msg = protocol.doudizhu.doudizhu.s2c_pb.CMD_S_StatusFree_Pro()
        msg:ParseFromString(event.data)
        self:recoverFree(msg)

    elseif event.subId == CMD_DDZ.SUB_S_BET_START or event.subId == CMD_DDZ.SUB_S_COMMON then
        print("开始投注！")
        if self.couponLayer then
            self.couponLayer:setBetEnable(true)
        end
        --隐藏换桌按钮
        self.btnTuoGuan:show()
        if self.btnChangeTable then
            self.btnChangeTable:hide()
        end


    elseif event.subId == CMD_DDZ.SUB_S_STATUS_FREE then
        print("场景恢复  空闲状态")
        if IS_AUTOMATCH then
            print("自动匹配")
            
        else
            self:msgReady()
        end

        local msg = protocol.doudizhu.doudizhu.s2c_pb.CMD_S_StatusFree_Pro()
        msg:ParseFromString(event.data)
        self:recoverFree(msg)
        
    elseif event.subId == CMD_DDZ.SUB_S_STATUS_CALL then --叫分
        print("场景恢复  叫分状态")
        local msg = protocol.doudizhu.doudizhu.s2c_pb.CMD_S_StatusCall_Pro()
        msg:ParseFromString(event.data)
        self:recoverGameJDZ(msg)

    elseif event.subId == CMD_DDZ.SUB_S_STATUS_PLAY then--游戏进行
        print("场景恢复  游戏状态")
        local msg = protocol.doudizhu.doudizhu.s2c_pb.CMD_S_StatusPlay_Pro()
        msg:ParseFromString(event.data)
        self:recoverGamePlay(msg)

    end
    
end

function PlayScene:initSeatInfo()
    local userInfo = DataManager:getMyUserInfo()
    --在没有分配桌子前，默认座位号为1
    if userInfo and userInfo.chairID == Define.INVALID_CHAIR then
        for id = 1, 3 do
            if id ~= 1 then
                userInfo = DataManager:getUserInfoInMyTableByChairID(id)
            end

            if userInfo then
                self.playerIcon[id]:show();
                self.nickName[id]:show();
                self.gold[id]:show();
                self:updatePlayerInfo(userInfo)
                self.level:show()
                userInfo = nil

                if self.nextID == id and self.nextCupBg and self.nextCup then
                    self.nextCupBg:show()
                    self.nextCup:show()

                elseif self.preID == id and self.preCupBg and self.preCup then
                    self.preCupBg:show()
                    self.preCup:show()
                end
            else
                print("hide  initSeatInfo:"..id)
                self.playerIcon[id]:hide();
                self.vipImage[id]:hide()
                self.nickName[id]:hide();
                self.gold[id]:hide();
                self.userStateMark[id]:hide()

                if self.nextID == id and self.nextCupBg and self.nextCup then
                    self.nextCupBg:hide()
                    self.nextCup:hide()

                elseif self.preID == id and self.preCupBg and self.preCup then
                    self.preCupBg:hide()
                    self.preCup:hide()
                end
            end
        end

    elseif userInfo and userInfo.chairID ~= Define.INVALID_CHAIR then
        for id = 1, 3 do
        	userInfo = DataManager:getUserInfoInMyTableByChairID(id)
        	if userInfo then
                self.playerIcon[id]:show();
                self.nickName[id]:show();
                self.gold[id]:show();
                self:updatePlayerInfo(userInfo)
                --self.level:show()
                
                if self.nextID == id and self.nextCupBg and self.nextCup then
                    self.nextCupBg:show()
                    self.nextCup:show()

                elseif self.preID == id and self.preCupBg and self.preCup then
                    self.preCupBg:show()
                    self.preCup:show()
                end
        	else
                print("hide  initSeatInfo111:"..id)
                self.playerIcon[id]:hide();
                self.vipImage[id]:hide()
                self.nickName[id]:hide();
                self.gold[id]:hide();
                self.userStateMark[id]:hide()
                
                if self.nextID == id and self.nextCupBg and self.nextCup then
                    self.nextCupBg:hide()
                    self.nextCup:hide()

                elseif self.preID == id and self.preCupBg and self.preCup then
                    self.preCupBg:hide()
                    self.preCup:hide()
                end
        	end
        end
    end
end

function PlayScene:onMyScoreAdd(addScore)
    local player = DataManager:getMyUserInfo()
    local index = player.tagUserInfo.wChairID
    assert(index >= 1 and index <= 3)

    local curPlayer = self._player[index]
    local gold = curPlayer:getChildByName("txt_gold")
    if gold then gold:setString(FormatNumToString(self:userMoney(player)+addScore)) end--金币数
end

function PlayScene:updatePlayerInfo(userInfo)
    if userInfo then
       
        local index = userInfo.chairID
        if index == Define.INVALID_CHAIR then
            index = 1
        end

        if userInfo.userStatus == Define.US_READY then
            self.userStateMark[index]:show()
            self.userStateMark[index]:setTexture("play3/ok.png")

        elseif userInfo.userStatus == Define.US_OFFLINE then
            self.userStateMark[index]:show()
            self.userStateMark[index]:setTexture("play3/offline.png")
            
        elseif self._step == 7 then
            self.userStateMark[index]:hide()
            
        else
            self.userStateMark[index]:hide()
        end

        --icon
        local file
        if self._step == 4 and self._step <= 7 then
            if self._step == 4 then
                self:showEffectBianShen(self.playerIcon[index]:getParent())
            end
            if index == self._dataModel.banker then
                file = "play3/icon_dz.png"
               
            else
                file = "play3/icon_nm.png"
               
                -- self:showEffectBianShen(self.playerIcon[index]:getParent())
            end
        else
            if userInfo.faceID >= 1 and userInfo.faceID <= 37 then
                file = "head/head_" .. userInfo.faceID .. ".png"
            elseif userInfo.faceID == 999 then
                -- local tokenID = userInfo.platformID;                
                -- file = RunTimeData:getLocalAvatarImageUrlByTokenID(tokenID)
                file = self:checkCustionIcon(userInfo)

            else
                file = "head/default.png"
            end
        end
        print("updatePlayerInfo = ", file)

        self:setPlayerInfo(index, "icon", file)
       
        --name
        self:setPlayerInfo(index, "name", userInfo.nickName)
        
        --金币
        self:setPlayerInfo(index, "gold", self:userMoney(userInfo))
        
        --会员
        self:setPlayerInfo(index, "vip", userInfo.memberOrder)

        --等级
        if userInfo.chairID == DataManager:getMyChairID() then
            self.level:setString("lv." .. getLevelByExp(userInfo.medal))
            self.liquanNum:setString(userInfo.present.."张")
        end
    end
end

function PlayScene:checkCustionIcon(userInfo)
    local file = RunTimeData:getLocalAvatarImageUrlByTokenID(userInfo.platformID)
    
    if is_file_exists(file) then
        -- print("***文件存在")
        head = cc.Sprite:create(file);
        local md5 = userInfo.platformFace
        local localmd5 = cc.Crypto:MD5File(file)
        -- print("HeadView--tokenID",tokenID,"md5===",md5,"localmd5==",localmd5,"url",imageName)
        if localmd5 ~= md5 and self.downloadCount > 0 then
            PlatformDownloadAvatarImage(userInfo.platformID, userInfo.platformFace)
            self.downloadCount = self.downloadCount - 1
        
            file = "head/default.png"
        end
    
    elseif self.downloadCount > 0 then
        PlatformDownloadAvatarImage(userInfo.platformID, userInfo.platformFace)
        self.downloadCount = self.downloadCount - 1
    end

    return file
end

function PlayScene:onDownloadCustomFaceUrlBackHandler(event)
    
    if tonumber(event.userId) == tonumber(self.tokenID) then 
        self:performWithDelay(function ()
            self:updatePlayerInfo(DataManager:getUserInfoByUserID(event.userId))
            -- self:setNewHead(self.headIndex, event.userId, event.md5Value)
        end, 1)
    end

end

function PlayScene:refreshPlayerInfo(player)
    if player then
       
        local index = player.chairID

        local icon = self.playerIcon[index]
        local name = self.nickName[index]
        local gold = self.gold[index]
        local vip = self.vipImage[index]
        
        --icon

        if self._step == 4 then
            if index == self._dataModel.banker then
                self:setPlayerInfo(i, "icon", "play3/icon_dz.png")
                self:showEffectBianShen(self.playerIcon[index]:getParent())

            else
                self:setPlayerInfo(i, "icon", "play3/icon_nm.png")
                self:showEffectBianShen(self.playerIcon[index]:getParent())
            end
        else
            if player.faceID >= 1 and player.faceID <= 37 then
                icon:setTexture("head/head_" .. player.faceID .. ".png")
            else
                icon:setTexture("head/default.png")
            end
        end
       
        --name
        name:setString(player.nickName)
        
        if index == DataManager:getMyChairID() then
            print("用户钱币数量：", self:userMoney(player))
            --金币
            gold:setTitleText(self:userMoney(player))
            
        else
            print("用户钱币数量：", self:userMoney(player))
            gold:setString(self:userMoney(player))
        end

        --vip
        vip:setTexture("hall/shop/zuan"..player.memberOrder .. ".png")
    end
end

function PlayScene:startNextRound()
     
    self._step = 0
    --self.btnStartGame:show();
    self:initSeatInfo();

    self:performWithDelay(function() self:onGameStart(0) end, 1.0)
end

function PlayScene:testPlay()
    
    self:step1();
    --[[
    local dataModel = require("landlord.DateModel").new()
    dataModel:createTestData()
    self._dataModel = dataModel

    if not self._cardLayer then
        self._cardLayer = viewCardLayer.new(self._dataModel):align(display.CENTER, display.cx, display.cy)
        self.container:addChild(self._cardLayer, LAYER_Z_ORDER.Z_CARD);
        self._cardLayer:start({posTable = self._posTable})
    else
        self._cardLayer:removeFromParent() 
        self._cardLayer = viewCardLayer.new(self._dataModel):align(display.CENTER, display.cx, display.cy)
        self.container:addChild(self._cardLayer, LAYER_Z_ORDER.Z_CARD);
        self._cardLayer:start({posTable = self._posTable})
    end
    ]]

end

-- 玩家坐下后进入
function PlayScene:step1(msg)
    self._step =1
    print("PlayScene-step1－等待其他玩家加入")
    --等待其他玩家加入
    self.btnStartGame:show();

    self:performWithDelay(function() self:step2_SendCard(); end, 2.0)

end

-- 所有玩家准备后，开始发牌
function PlayScene:step2_SendCard(msg)
    self.btnTuoGuan:show()
    if self.btnChangeTable then
        self.btnChangeTable:hide()
    end
    
    --换桌时，服务端可能不会返回ready状态，这里将离开状态reset，防止上一局换桌而没有reset离开状态的问题
    self.leaveType = 0

    self._step =2
    print("PlayScene-step2_SendCard－发牌")
    --self.btnMingPai:hide();
    self.btnStartGame:hide();

    --开始发牌
    if self.cardLayer then
        self.cardLayer:removeSelf();
        print("self.cardLayer!!!=====nil")
    end
    
    self._dataModel:setBanker(msg.wStartUser)
    self._dataModel:refreshCards(msg.cbCardData)
    self._dataModel:cachePlayerInfo()
    --dataModel:createTestData()

    self.cardLayer = viewCardLayer.new(self._dataModel)
                :addTo(self.container, LAYER_Z_ORDER.Z_CARD)
                :align(display.CENTER, display.cx, display.cy)
    self.cardLayer:start(function() self:sendCardFinished(msg) end);        

    print("sendCard------msg.wStartUser=",  msg.wStartUser, "msg.wCurrentUser=", msg.wCurrentUser)

    -- required int32                          wStartUser      = 1;            //开始玩家
    -- required int32                          wCurrentUser        = 2;            //当前玩家
    --self:performWithDelay(function() self:step3_JiaoDiZhu(); end, 5.0)
end

function PlayScene:sendCardFinished(msg)
    if not self.nodeQdz then
        self.nodeQdz = require("landlord.ViewJDZLayer").new({config=self.playConfig})
                    :addTo(self.container, LAYER_Z_ORDER.Z_BUTTONS)
    end

    self.nodeQdz:showJDZ(msg)
end

-- 发牌结束，进入抢地主
function PlayScene:step3_JiaoDiZhu(msg)
    self._step =3
    print("PlayScene-step3_JiaoDiZhu——抢地主")
    print("msg.wCurrentUser", msg.wCurrentUser, "msg.wCallScoreUser", msg.wCallScoreUser,"cbCurrentScore",msg.cbCurrentScore)
    self._dataModel:setRobPlus(msg.cbCurrentScore)
    --显示抢地主按钮和相关信息
    -- 叫分
    if not self.nodeQdz then
        self.nodeQdz = require("landlord.ViewJDZLayer").new({config=self.playConfig})
                    :addTo(self.container, LAYER_Z_ORDER.Z_BUTTONS)
                    --:align(display.CENTER, display.cx, display.cy)
    end

    self.nodeQdz:showQDZ(msg)    
    self:updatePlusNum(msg.cbUserCallScore*3)

end

function PlayScene:qiangDiZhuFinished(dizhu)
    if not self.nodeChuPai then
        self.nodeChuPai = require("landlord.ViewChuPaiLayer").new({cardLayer=self.cardLayer, config=self.playConfig})
                    :addTo(self.container, LAYER_Z_ORDER.Z_BUTTONS)
    end
    self.nodeChuPai:start(dizhu)

end

-- 地主抄底
function PlayScene:step4_SetBanker(msg)
    self._step =4
    print("PlayScene-step4_SetBanker—-地主抄底")
    --[[
    required int32                          wBankerUser         = 1;            //庄家玩家
    required int32                          wCurrentUser        = 2;            //当前玩家
    required int32                          cbBankerScore       = 3;            //庄家叫分
    repeated int32                          cbBankerCard        = 4;            //庄家扑克
    ]]
    self._dataModel:setBanker(msg.wBankerUser)
    self._dataModel:refreshDiPai(msg.cbBankerCard)
    if self.cardLayer then
        self.cardLayer:showDiPai(msg)
    end

    if not self.nodeChuPai then
        self.nodeChuPai = require("landlord.ViewChuPaiLayer").new({cardLayer=self.cardLayer, config=self.playConfig})
                    :addTo(self.container, LAYER_Z_ORDER.Z_BUTTONS)
    end
    self.nodeChuPai:start(msg.wBankerUser)

    self:updatePlusNum(msg.cbBankerScore)

    --更新头像
    self:updateIcons()
end

-- 出牌阶段
function PlayScene:step5_OutCards(msg)
    self._step =5
    print("PlayScene-step5_OutCards——玩家出牌")
    --显示玩家出的牌
    --计时闹钟
    --更新明牌信息
    if not self.nodeChuPai then
        self.nodeChuPai = require("landlord.ViewChuPaiLayer").new({cardLayer=self.cardLayer, config=self.playConfig})
                    :addTo(self.container, LAYER_Z_ORDER.Z_BUTTONS)
                    --:align(display.CENTER, display.cx, display.cy)
    end
--[[
    required int32                          cbCardCount         = 1;            //出牌数目
    required int32                          wCurrentUser        = 2;            //当前玩家
    required int32                          wOutCardUser        = 3;            //出牌玩家
    repeated int32                          cbCardData      = 4;            //扑克列表
]]
    print("出牌数目", msg.cbCardCount, "当前玩家", msg.wCurrentUser, "出牌玩家", msg.wOutCardUser)
    self.cardLayer:showChuPai(msg)
    local checkresult = -1
    if msg.wCurrentUser == DataManager:getMyChairID() then
        checkresult = self.cardLayer:checkResult()
    end
    self.nodeChuPai:showChuPai(msg)
    if msg.wCurrentUser == DataManager:getMyChairID() then
        self.nodeChuPai:changeButtonState(checkresult)      
    end

    local _type = GameLogic.analysebCardData(msg.cbCardData)
    print("出牌类型：", _type)

    --友盟统计：当前玩家出的牌型中符合中奖的牌局
    if msg.wOutCardUser == 0 then--表示是玩家自己出的牌
        print("进入Umeng统计............................................................................")
        if _type == CARDS_TYPE.CT_5 then--王炸
            self.has_out_king_boom = true
            self.has_out_boom_nums = self.has_out_boom_nums + 1
        end
        if _type == CARDS_TYPE.CT_4 then--四炸
            self.has_out_boom_nums = self.has_out_boom_nums + 1
        end
        if _type == CARDS_TYPE.CT_3S3 and msg.cbCardCount then--三连飞机
            self.has_out_three_plane = true
        end
    end


    if _type == CARDS_TYPE.CT_4 then
        self:doublePlusNum()
    elseif _type == CARDS_TYPE.CT_5 then
        self:doublePlusNum()
    end
    
    self.cardLayer:playEffectPX(_type, msg.wOutCardUser)

end

-- 用户放弃
function PlayScene:step6_Pass(msg)
    self._step =6
    print("PlayScene-step6_Pass——用户放弃")
    if not self.nodeChuPai then
        self.nodeChuPai = require("landlord.ViewChuPaiLayer").new({cardLayer=self.cardLayer, config=self.playConfig}):addTo(self.container, LAYER_Z_ORDER.Z_BUTTONS)
    end

    self.nodeChuPai:showBuChuPai(msg)
    self.cardLayer:showBuChuPai(msg)
end

--结算
function PlayScene:step7_GameOver(msg)

    --牌局统计Umeng结算
    local curRoomIndex = RunTimeData:getRoomIndex()
    if tonumber(curRoomIndex) > 1 then
        self.has_out_king_boom = false
        self.has_out_boom_nums = 0
        self.has_out_three_plane = false
        if self.has_out_three_plane == true then
            onUmengEvent("1050")
        elseif self.has_out_boom_nums == 3 and self.has_out_king_boom == true then
            onUmengEvent("1051")
        elseif self.has_out_boom_nums == 3 then
            onUmengEvent("1052")
        elseif self.has_out_boom_nums == 4 then
            onUmengEvent("1053")
        end
    end

    --是否出过火箭
    local totalBombCount = 0
    for i,v in ipairs(msg.cbEachBombCount) do
        totalBombCount = totalBombCount + v
    end
    print("cbBombCount",msg.cbBombCount,"totalBombCount",totalBombCount)
    print("有火箭有火箭有火箭有火箭有火箭有火箭",msg.cbHasMissile)
    if msg.cbHasMissile == 1 then--有火箭
        self._dataModel:setRocket(true)
        self._dataModel:setBombCount(msg.cbBombCount-1)
    else
        self._dataModel:setRocket(false)
        self._dataModel:setBombCount(msg.cbBombCount)
    end
    -- if totalBombCount ~= msg.cbBombCount then--有火箭
    --     self._dataModel:setRocket(true)
    --     self._dataModel:setBombCount((msg.cbBombCount-2))
    -- else
    --     self._dataModel:setRocket(false)
    --     self._dataModel:setBombCount(msg.cbBombCount)
    -- end

    self.btnTuoGuan:hide()
    if self.btnChangeTable then
        self.btnChangeTable:show()
    end
    

    self._step = 7
    print("PlayScene-step7_GameOver-结算")
    if not self._resultLayer then
        local function resultCall(type)
            if type == 1 then
                self:step8()
                
            elseif type == 0 then
                
                self.needRestart = true
                self:reset();

                if self:userMoney(DataManager:getMyUserInfo()) < 0 then--金币不足，只能旁观
                    local winSize = cc.Director:getInstance():getWinSize()
                    self._viewTipLayer = viewTipLayer.new({tip="金币不足时，仅能观战哦亲～", lisenter = function() self:onClickBuy() end}):addTo(self):align(display.CENTER,winSize.width/2,winSize.height/2)
                    return
                end
                
                self.btnStartGame:show()
            
            elseif type == 2 then
                self:onChangeTable()
                
            end
        end
        self.resultLayer = require("landlord.ViewResultLayer").new({data=self._dataModel, lisenter = resultCall}):align(display.CENTER, display.cx, display.cy)
        self.resultLayer:addTo(self.container, LAYER_Z_ORDER.Z_RESULT)
    end

    if self.cardLayer then
        --self.cardLayer:gameOver(msg)
        self.cardLayer:showAllCardsDelay(msg,1)
    end

    self.resultLayer:start(msg)
    
    if (msg.bChunTian and msg.bChunTian == 1) or (msg.bFanChunTian and msg.bFanChunTian == 1) then
        self:doublePlusNum()
        self.cardLayer:playEffectCT()
        self._dataModel:setSpring(true)
    end

    --隐藏托管
    if self.tuoguan then
        self.tuoguan:hide()
        self.cardLayer:tuoGuan()
    end
    self:playGameOverEffect(msg)
end
---结算特效
function PlayScene:playGameOverEffect(msg)
    local num = #msg.lGameScore
    local myChairID = DataManager:getMyChairID()
    local myposX,myposY = self.playerIcon[myChairID]:getParent():getPosition()
    local mypos = cc.p(myposX,myposY+0)
    local nextposX,nextposY = self.playerIcon[self.nextID]:getParent():getPosition()
    local nextpos = cc.p(nextposX,nextposY+0)

    local preposX,preposY = self.playerIcon[self.preID]:getParent():getPosition()
    local prepos = cc.p(preposX,preposY+0)

    print("mypos",mypos.x,mypos.y,"nextpos",nextpos.x,nextpos.y,"prepos",prepos.x,prepos.y)
    local txtPos = cc.p(display.left+380, display.bottom + 30)
    local txtPosNext = cc.p(display.right - 80, display.cy + 115-82)
    local txtPosPre = cc.p(display.left + 80, display.cy + 115-82)

    if msg.lGameScore[self.myChairID] > 0 then--自己赢
        --下家
        if msg.lGameScore[self.nextID] <0 then
            self:AnimationBezierTo(nextpos,mypos,self.fileMoney)
            self:performWithDelay(function ()

                local moneytxt = ccui.Text:create("", FONT_NORMAL, 30)
                moneytxt:setPosition(txtPosNext)
                moneytxt:setString(msg.lGameScore[self.myChairID])
                moneytxt:setColor(cc.c4b(255,0,0,255))
                moneytxt:enableOutline(cc.c4b(255,255,255,255),3)
                self.container:addChild(moneytxt,100)
                local moveby = cc.MoveBy:create(1, cc.p(0,70))
                moneytxt:runAction(cc.Sequence:create(moveby, cc.CallFunc:create(function() moneytxt:removeSelf() end) ))
            end, 1)
        else
            self:AnimationBezierTo(prepos,nextpos,self.fileMoney)
            self:performWithDelay(function ()
                local armature = EffectFactory:getInstance():getJieSuanAnimation(0)
                self.container:addChild(armature,LAYER_Z_ORDER.Z_BUTTONS)
                armature:setPosition(nextpos)
                local moneytxt = ccui.Text:create("", FONT_NORMAL, 30)
                moneytxt:setPosition(txtPosNext)
                moneytxt:setString("+"..msg.lGameScore[self.myChairID])
                moneytxt:setColor(cc.c4b(255,255,0,255))
                moneytxt:enableOutline(cc.c4b(255,255,255,255),3)
                self.container:addChild(moneytxt,100)
                local moveby = cc.MoveBy:create(1, cc.p(0,70))
                moneytxt:runAction(cc.Sequence:create(moveby, cc.CallFunc:create(function() moneytxt:removeSelf() end) ))
            end, 1)
        end
        --上家
        if msg.lGameScore[self.preID]<0 then
            self:AnimationBezierTo(prepos,mypos,self.fileMoney)
            self:performWithDelay(function ()

                local moneytxt = ccui.Text:create("", FONT_NORMAL, 30)
                moneytxt:setPosition(txtPosPre)
                moneytxt:setString(msg.lGameScore[self.preID])
                moneytxt:setColor(cc.c4b(255,0,0,255))
                moneytxt:enableOutline(cc.c4b(255,255,255,255),3)
                self.container:addChild(moneytxt,100)
                local moveby = cc.MoveBy:create(1, cc.p(0,70))
                moneytxt:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),moveby, cc.CallFunc:create(function() moneytxt:removeSelf() end) ))
            end, 1)
        else
            self:AnimationBezierTo(nextpos,prepos,self.fileMoney)
            self:performWithDelay(function ()
                local armature = EffectFactory:getInstance():getJieSuanAnimation(0)
                self.container:addChild(armature,LAYER_Z_ORDER.Z_BUTTONS)
                armature:setPosition(prepos)
                local moneytxt = ccui.Text:create("", FONT_NORMAL, 30)
                moneytxt:setPosition(txtPosPre)
                moneytxt:setString("+"..msg.lGameScore[self.preID])
                moneytxt:setColor(cc.c4b(255,255,0,255))
                moneytxt:enableOutline(cc.c4b(255,255,255,255),3)
                self.container:addChild(moneytxt,100)
                local moveby = cc.MoveBy:create(1, cc.p(0,70))
                moneytxt:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),moveby, cc.CallFunc:create(function() moneytxt:removeSelf() end) ))
            end, 1)
        end
        --ziji
        self:performWithDelay(function ()
            local armature = EffectFactory:getInstance():getJieSuanAnimation(1)
            self.container:addChild(armature,LAYER_Z_ORDER.Z_BUTTONS)
            armature:setPosition(mypos)
                local moneytxt = ccui.Text:create("", FONT_NORMAL, 30)
                moneytxt:setPosition(txtPos)
                moneytxt:setString("+"..msg.lGameScore[self.myChairID])
                moneytxt:setColor(cc.c4b(255,255,0,255))
                moneytxt:enableOutline(cc.c4b(255,255,255,255),3)
                self.container:addChild(moneytxt,100)
                local moveby = cc.MoveBy:create(1, cc.p(0,70))
                moneytxt:runAction(cc.Sequence:create(moveby, cc.CallFunc:create(function() moneytxt:removeSelf() end) ))
          
        end,1)
    else
        --下家
        if msg.lGameScore[self.nextID] >0 then
            self:AnimationBezierTo(mypos,nextpos,self.fileMoney)
            self:performWithDelay(function ()
                local armature = EffectFactory:getInstance():getJieSuanAnimation(0)
                self.container:addChild(armature,LAYER_Z_ORDER.Z_BUTTONS)
                armature:setPosition(nextpos)
                local moneytxt = ccui.Text:create("", FONT_NORMAL, 30)
                moneytxt:setPosition(txtPosNext)
                moneytxt:setString("+"..msg.lGameScore[self.nextID])
                moneytxt:setColor(cc.c4b(255,255,0,255))
                moneytxt:enableOutline(cc.c4b(255,255,255,255),3)
                self.container:addChild(moneytxt,100)
                local moveby = cc.MoveBy:create(1, cc.p(0, 70))
                moneytxt:runAction(cc.Sequence:create(moveby, cc.CallFunc:create(function() moneytxt:removeSelf() end) ))
            end, 1)
        else
            self:AnimationBezierTo(nextpos,prepos,self.fileMoney)
            self:performWithDelay(function ()
                -- local armature = EffectFactory:getInstance():getJieSuanAnimation(0)
                -- self.container:addChild(armature,LAYER_Z_ORDER.Z_BUTTONS)
                -- armature:setPosition(nextpos)
                local moneytxt = ccui.Text:create("", FONT_NORMAL, 30)
                moneytxt:setPosition(txtPosNext)
                moneytxt:setString("-"..msg.lGameScore[self.nextID])
                moneytxt:setColor(cc.c4b(255,0,0,255))
                moneytxt:enableOutline(cc.c4b(255,255,255,255),3)
                self.container:addChild(moneytxt,100)
                local moveby = cc.MoveBy:create(1, cc.p(0, 70))
                moneytxt:runAction(cc.Sequence:create(moveby, cc.CallFunc:create(function() moneytxt:removeSelf() end) ))
            end, 1)
        end
        --上家
        if msg.lGameScore[self.preID]>0 then
            self:AnimationBezierTo(mypos,prepos,self.fileMoney)
            self:performWithDelay(function ()
                local armature = EffectFactory:getInstance():getJieSuanAnimation(0)
                self.container:addChild(armature,LAYER_Z_ORDER.Z_BUTTONS)
                armature:setPosition(prepos)
                local moneytxt = ccui.Text:create("", FONT_NORMAL, 30)
                moneytxt:setPosition(txtPosPre)
                moneytxt:setString("+"..msg.lGameScore[self.preID])
                moneytxt:setColor(cc.c4b(255,255,0,255))
                moneytxt:enableOutline(cc.c4b(255,255,255,255),3)
                self.container:addChild(moneytxt,100)
                local moveby = cc.MoveBy:create(1, cc.p(0, 70))
                moneytxt:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),moveby, cc.CallFunc:create(function() moneytxt:removeSelf() end) ))
            end, 1)
        else
            self:AnimationBezierTo(prepos,nextpos,self.fileMoney)
            self:performWithDelay(function ()
                -- local armature = EffectFactory:getInstance():getJieSuanAnimation(0)
                -- self.container:addChild(armature,LAYER_Z_ORDER.Z_BUTTONS)
                -- armature:setPosition(prepos)
                local moneytxt = ccui.Text:create("", FONT_NORMAL, 30)
                moneytxt:setPosition(txtPosPre)
                moneytxt:setString("-"..msg.lGameScore[self.preID])
                moneytxt:setColor(cc.c4b(255,0,0,255))
                moneytxt:enableOutline(cc.c4b(255,255,255,255),3)
                self.container:addChild(moneytxt,100)
                local moveby = cc.MoveBy:create(1, cc.p(0, 70))
                moneytxt:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),moveby, cc.CallFunc:create(function() moneytxt:removeSelf() end) ))
            end, 1)
        end
        --ziji
        self:performWithDelay(function ()
                local moneytxt = ccui.Text:create("", FONT_NORMAL, 30)
                moneytxt:setPosition(txtPos)
                moneytxt:setString(msg.lGameScore[self.myChairID])
                moneytxt:setColor(cc.c4b(255,0,0,255))
                moneytxt:enableOutline(cc.c4b(255,255,255,255),3)
                self.container:addChild(moneytxt,100)
                local moveby = cc.MoveBy:create(1, cc.p(0,70))
                moneytxt:runAction(cc.Sequence:create(moveby, cc.CallFunc:create(function() moneytxt:removeSelf() end) ))
                       
        end,1)
    end
end
--@param pStart
--@param pEnd
--pStart.x不能等于pEnd.x
function PlayScene:AnimationBezierTo(pStart,pEnd,imageName)
    -- local pStart = cc.p(99,100)
    -- local pEnd = cc.p(700,200)
    if pStart.x==pEnd.x then
        pStart.x = pEnd.x-10
    end
    local pi = 3.1415926535
    local center = cc.p((pEnd.x-pStart.x)/2,(pEnd.y-pStart.y)/2)
    local radianA = math.atan((pEnd.y-pStart.y)/(pEnd.x-pStart.x))--弧度
    local rs = self:rotateCoordinateSystem(pStart,pi*2-radianA,center)
    local re = self:rotateCoordinateSystem(pEnd,pi*2-radianA,center)
    local length = re.x -rs.x
    local radianB = 45*0.01745329252 --弧度

    local height = math.tan(radianB)*(length/4)

    local rcontrol1 = cc.p(rs.x+length/4,rs.y+height)
    local rcontrol2 = cc.p(re.x-length/4,re.y-height)

    local control1 = self:rotateCoordinateSystem(rcontrol1,(radianA),center)

    local control2 = self:rotateCoordinateSystem(rcontrol2,(radianA),center)
    imageName = imageName or "common/gold.png"
    for i=1,10 do
        local sp = display.newSprite(imageName)
        sp:setPosition(pStart)
        self.container:addChild(sp,LAYER_Z_ORDER.Z_BUTTONS)
        local vy = 150
        local vx = 50

        local bezier = {
            control1,
            control2,
            pEnd
        }
        -- 以持续时间和贝塞尔曲线的配置结构体为参数创建动作  
        local bezierForward = cc.BezierTo:create(1, bezier)  
        local delay = cc.DelayTime:create(0.1*i)
        local fun =  cc.CallFunc:create(function() sp:removeSelf() end) 

        sp:setOpacity(0)
        sp:runAction(cc.Sequence:create(
                    delay, 
                    cc.Spawn:create(bezierForward, cc.FadeIn:create(0.1)),
                    fun))
    end
end
function PlayScene:rotateCoordinateSystem(point,radian,center)
    local rx0 = center.x or 0
    local ry0 = center.y or 0
    local x0 = (point.x - rx0)*math.cos(radian) - (point.y - ry0)*math.sin(radian) + rx0 ;

    local y0 = (point.x - rx0)*math.sin(radian) + (point.y - ry0)*math.cos(radian) + ry0 ;
    return cc.p(x0,y0)
end
function PlayScene:step8()
    self._step = 0
    self:performWithDelay(handler(self, self.preNextRound), 0.1)

--    --游戏结束，恢复个人头像
--    self:initSeatInfo()
end
--连胜 开奖
function PlayScene:winTaskCallBack(msg)
--[[{
    required int32              dwUserID        = 1;        //用户 I D
    required int32              lResultCode     = 2;        //操作代码
    required string             szDescribeString    = 3;        //描述消息
    required int32              wAwardTypeComboWin  = 4;        //奖励类型  连胜奖励类型     没有达成时为0   
    required int32              wAwardTypeWin       = 5;        //奖励类型  每胜10局奖励类型 没有达成时为0   
    required int32              dwComboWinCount     = 6;        //当前连胜数                                     
    required int32              dwWinCount      = 7;        //当前赢的次数                                   
}]]
    self.taskBG:show()
    self.taskEffect:show()

    if self.isHappyBeans and msg then
        local rewardtype20 = 0
        local rewardcount20 = 0 
        local rewardtype30 = 0
        local rewardcount30 = 0 
        local rewardList = RunTimeData:getCouponConfig()
        local type20 = false
        local type30 = false
        local str20 = ""
        local isrepeat = false
        if msg.wAwardTypeComboWin >10 and msg.wAwardTypeComboWin <=20 then
            type20 = true
            local lianshengList = RunTimeData.lianshengConfig
            rewardcount20 = lianshengList[msg.wAwardTypeComboWin-10]["count"]
            rewardtype20 = lianshengList[msg.wAwardTypeComboWin-10]["kind"]
            str20 = "连胜"..(msg.wAwardTypeComboWin-10).." 局获得"..rewardcount20
            local rewardIcon = ""
            if rewardtype20 == 1 then
                str20 = str20.."金币"
                rewardIcon = "common/gold.png"
            else
                str20 = str20.."礼券"
                rewardIcon = "liquan/lq_icon0.png"
            end

            print(str20)
            
            -- UserService:sendQueryInsureInfo()
            -- BankInfoInGame:sendQueryRequest()
            -- Hall.showTips(str20, 1)
            local myChairID = DataManager:getMyChairID()
            local mypos = cc.p(display.left + 70, display.bottom + 45)
            self:AnimationBezierTo(cc.p(display.right-79, 267),mypos,rewardIcon)
            self:performWithDelay(function ()
                local armature = EffectFactory:getInstance():getJieSuanAnimation(1)
                self.container:addChild(armature ,LAYER_Z_ORDER.Z_BUTTONS)
                armature:setPosition(mypos)
            end, 1)
            if rewardtype20 == 2 then
                AccountInfo:setPresent(AccountInfo.present+rewardcount20)

                self:initSeatInfo()
                self:playEffect()
                isrepeat = true
            end
        end
        local str30 = ""
        if msg.wAwardTypeWin == 30 then
            type30 = true
            rewardcount30 = rewardList[30]["count"]
            rewardtype30 = rewardList[30]["kind"]
            str30 = "获胜10局获得"..rewardcount30
            local rewardIcon = ""
            if rewardtype30 == 1 then
                str30 = str30.."金币"
                rewardIcon = "common/gold.png"
            else
                str30 = str30.."礼券"
                rewardIcon = "liquan/lq_icon0.png"
            end

            print(str30)
            
            -- UserService:sendQueryInsureInfo()
            BankInfoInGame:sendQueryRequest()
            -- Hall.showTips(str30, 1)
            local myChairID = DataManager:getMyChairID()
            local mypos = cc.p(display.left + 70, display.bottom + 45)
            self:AnimationBezierTo(cc.p(display.right-79, 267),mypos,rewardIcon)
            self:performWithDelay(function ()
                local armature = EffectFactory:getInstance():getJieSuanAnimation(1)
                self.container:addChild(armature ,LAYER_Z_ORDER.Z_BUTTONS)
                armature:setPosition(mypos)
            end, 1)
            if rewardtype30 == 2 and isrepeat == false then
                AccountInfo:setPresent(AccountInfo.present+rewardcount30)
                self:initSeatInfo()
                self:playEffect()
            end
        end

        if type20 == true and type30 == true then
            Hall.showTaskTips(str20..","..str30, 1)
            self:showTaskCompleteEffect()
        elseif type20 == true then
            Hall.showTaskTips(str20, 1)
            self:showTaskCompleteEffect()
        elseif type30 == true then
            Hall.showTaskTips(str30, 1)
            self:showTaskCompleteEffect()
        end

    end
end

function PlayScene:showTaskCompleteEffect()
    local winSize = cc.Director:getInstance():getWinSize()
    
    local node = display.newNode():addTo(self,999):align(display.CENTER, winSize.width/2, winSize.height/2)

    display.newSprite("hall/task/complete.png"):addTo(node):align(display.CENTER, 0, 90)

    local texture2d = cc.Director:getInstance():getTextureCache():addImage("effect/XS.png");
    local light = cc.ParticleSystemQuad:create("effect/XS.plist");
    light:setTexture(texture2d);
    light:setPosition(cc.p(0, 50));
    light:setScale(2)
    light:addTo(node)

    node:runAction(cc.Sequence:create(
                        cc.DelayTime:create(2.0), 
                        cc.CallFunc:create(function() node:removeSelf() end)))



    local startX, startY = self.taskNode:getPosition()
    local endX, endY = self.gold[self.myChairID]:getPosition()
    print("start", startX, startY, "end", endX, endY)
    self:AnimationBezierTo(cc.p(startX,startY), cc.p(endX-80, endY), "common/gold.png")
end

function PlayScene:processOpenVoucherCallBack(msg)
    
--[[{
    required int32              dwUserID        = 1;        //用户 I D
    required int32              lResultCode     = 2;        //操作代码
    required string             szDescribeString    = 3;        //描述消息
    required int32              dwTotalVoucherCount = 4;        //礼券池数量
    required int32              cbAwardItemType     = 5;        //开奖类型 1: 金币  2: 礼券
    required int32              dwAwardItemCount    = 6;        //奖励数量
    required int32              wAwardType      = 7;        //奖励类型
}]]

    print("礼券开奖结果---------------")
    print("msg.dwUserID", msg.dwUserID)
    print("msg.lResultCode", msg.lResultCode)
    print("msg.szDescribeString", msg.szDescribeString)
    print("msg.dwTotalVoucherCount", msg.dwTotalVoucherCount)
    print("msg.cbAwardItemType", msg.cbAwardItemType)
    print("msg.dwAwardItemCount", msg.dwAwardItemCount)

    if self.isHappyBeans and msg and msg.lResultCode == 0 then
        
        local rewardList = RunTimeData:getCouponConfig()
        local str = rewardList[msg.wAwardType]["description"].."获得"..rewardList[msg.wAwardType]["count"]
        local rewardIcon = ""
        if rewardList[msg.wAwardType]["kind"] == 1 then
            str = str.."金币"
            rewardIcon = "common/gold.png"
        else
            str = str.."礼券"
            rewardIcon = "liquan/lq_icon0.png"
        end

        print(str)
        
        -- UserService:sendQueryInsureInfo()
        BankInfoInGame:sendQueryRequest()
        Hall.showTips(str, 1)
        local myChairID = DataManager:getMyChairID()
        -- local myposX,myposY = self.playerIcon[myChairID]:getParent():getPosition()
        local mypos = cc.p(display.left + 70, display.bottom + 45)
        self:AnimationBezierTo(cc.p(display.right-79, 267),mypos,rewardIcon)
        self:performWithDelay(function ()
            local armature = EffectFactory:getInstance():getJieSuanAnimation(1)
            self.container:addChild(armature,LAYER_Z_ORDER.Z_BUTTONS)
            armature:setPosition(mypos)
        end, 1)
        if msg.cbAwardItemType == 2 then
            AccountInfo:setPresent(AccountInfo.present+msg.dwAwardItemCount)
            self:initSeatInfo()
            self:playEffect()
        end

    end
end
function PlayScene:playEffect()
    -- self:setLocalZOrder(5)
    local armature = EffectFactory:getInstance():getCouponEffect();
    armature:setPosition(cc.p(display.cx, display.bottom+100))
    self:addChild(armature,100)
    --commodityLightAnimation:getAnimation():setSpeedScale(math.random(1,5) / 5);
    -- armature:getAnimation():setSpeedScale(0.3);

    armature:getAnimation():setFrameEventCallFunc(function(bone,evt,originFrameIndex,currentFrameIndex)
            if evt == "end" then
                -- self:setLocalZOrder(2)
                armature:removeFromParent()
            end
        end)
    armature:getAnimation():playWithIndex(0)

end
function PlayScene:preNextRound()
    --if DataManager:getMyUserInfo().score < 99999 then--金币不足，只能旁观
    if self:userMoney(DataManager:getMyUserInfo()) < 0 then--金币不足，只能旁观
        local winSize = cc.Director:getInstance():getWinSize()
        self._viewTipLayer = viewTipLayer.new({tip="金币不足时，仅能观战哦亲～", lisenter = function() self:onClickBuy() end}):addTo(self):align(display.CENTER,winSize.width/2,winSize.height/2)
        return
    end

    self:reset();
    self:startNextRound();
end

function PlayScene:onClickBuy()
    self:performWithDelay(handler(self, self.showShopLayer), 0.1)
end

function PlayScene:showShopLayer()
    if not self._shopLayer then
        local winSize = cc.Director:getInstance():getWinSize()
        self._shopLayer = viewShopLayer.new():addTo(self):align(display.CENTER,winSize.width/2,winSize.height/2)

    else
        self._shopLayer:show()
    end
end

function PlayScene:onEnter()
    --print("--PlayScene:onEnter 发送场景恢复请求")
    if IS_AUTOMATCH then
        TableInfo:sendAutoMatch()
    end
    TableInfo:sendGameOptionRequest()

    self:registerEventListener();
    -- self.checkKind = 0
    -- self:checkHasBuyGold()

    SoundManager.stopMusic();
    --SoundManager.playMusic("sound/gamebgm.mp3", true);
    SoundManager.playMusicInPlay3()

    -- --更新座位信息
    self:refreshUI()
    self:initSeatInfo()

    self.chatWindow = require("commonView.ViewMessage").new():addTo(self.container, LAYER_Z_ORDER.Z_POPMSG)
    self.chatWindow:hideChat()

    --自动匹配
    -- GameCenter:autoMatch()
    -- self:showMatching()
    print("showMatching()-----onEnter")

end

function PlayScene:onExit()
    for _, bindid in ipairs(self.bindIds) do
        BindTool.unbind(bindid)
    end
    self:unscheduleUpdate()
    HallEvent:removeEventListener(self.eventHandler)

    --[[
    GameCenter:removeEventListenersByEvent(GameCenterEvent.EVENT_USER_SIGNUP)
    GameCenter:removeEventListenersByEvent(GameCenterEvent.EVENT_USER_SIGNUP_NOUSER)
    GameCenter:removeEventListenersByEvent(GameCenterEvent.EVENT_USER_ENTER)
    GameCenter:removeEventListenersByEvent(GameCenterEvent.EVENT_STATUS_CHANGED)
    GameCenter:removeEventListenersByEvent(GameCenterEvent.EVENT_GAME_MESSAGE)
    GameCenter:removeEventListenersByEvent(GameCenterEvent.EVENT_GAME_SCENE)
    GameCenter:removeEventListenersByEvent(GameCenterEvent.EVENT_TIMEBOXAWARD_RESULT)
    GameCenter:removeEventListenersByEvent(GameCenterEvent.EVENT_SYSTEM_MESSAGE)

    GameCenter:removeEventListener(self.handler1)
    GameCenter:removeEventListener(self.handler4)
    -- GameCenter:removeEventListener(self.handler5)
    HallCenter:removeEventListener(self.handler6)
    GameCenter:removeEventListener(self.SMT_TABLE_ROLL)
    GameCenter:removeEventListener(self.handler_RECEIVEGOLD)    
    GameCenter:removeEventListener(self.handler_PROPERTY_SUCCESS)
    GameCenter:removeEventListener(self.handler_QUERY_INSURE_FOR_GAME)
    GameCenter:removeEventListener(self.handler_COUPON)

    if self.giftInfoLayer then
        self.giftInfoLayer:removeEventListenersByEvent(GameCenterEvent.EVENT_BUY_PROPERTY)
    end

    -- UserService:removeEventListenersByEvent(HallCenterEvent.EVENT_EXCHAGE_BEANS)
    --UserService:removeEventListenersByEvent(HallCenterEvent.EVENT_QUERY_INSURE)
    UserService:removeEventListener(self.handler2)
    UserService:removeEventListener(self.handler3)
    UserService:removeEventListener(self.handler_getExchangeValueSuccess)
    UserService:removeEventListener(self.handler_getExchangeValueFailure)
    UserService:removeEventListener(self.handler_room_exchage_beans)
    UserService:removeEventListener(self.handler_AVATARDOWNLOADURL)
    ]]

end

function PlayScene:popMsgWindow(x,y)
    print("popMsgWindow")

    self.chatWindow:showChat()

end

function PlayScene:onBackRoom()
    print("onClickBackRoom")
    if DataManager:getMyUserInfo().userStatus == Define.US_PLAYING then
        self.viewPlayExit = require("commonView.ViewConfirmExit").new({ok=handler(self,self.exitPlay), cancel = handler(self, self.cancelExitPlay)})
        self.viewPlayExit:addTo(self.container, LAYER_Z_ORDER.Z_CONFIRM)
        return
    end

    print("DataManager:getMyUserInfo().userStatus = ", DataManager:getMyUserInfo().userStatus)
    if DataManager:getMyUserInfo().userStatus == Define.US_FREE then
        GameConnection:closeRoomSocketDelay(2.0)
        self:performWithDelay(
            function ()
                self:onServerExitScene(nil);
            end,
            1.0
        )
        return
    end

    self:exitPlay();

end

function PlayScene:exitPlay()

    --GameCenter:standUp();
    self:msgTuoGuan(1)

    GameConnection:closeRoomSocketDelay(2.0)

    self:performWithDelay(
        function ()
            self:onServerExitScene(nil);
        end,
        1.0
    )

end

function PlayScene:cancelExitPlay()
    self.viewPlayExit:removeSelf()
    self.viewPlayExit = nil
end

function PlayScene:onChangeTable()

    self:reset();
    self:restartGame()
    self.leaveType = CHANGE_TABLE

    --显示匹配中
    self:showMatching()
    print("showMatching()--------onChangeTable")
    Hall.showWaiting(0.8, "换桌中。。")
    if self.btnStartGame then
        self.btnStartGame:hide()
    end
end

function PlayScene:restartGame()

    ---判断能否准入
    if self.isHappyBeans then
        if DataManager:getMyUserInfo().score < self:getMinEnterScore() then
            Hall.showTips("欢乐豆不足无法开始游戏", 1)
            self.btnStartGame:show();
            return
        end
    else
        if DataManager:getMyUserInfo().score < self:getMinEnterScore() then
            Hall.showTips("金币不足无法开始游戏", 1)
            self.btnStartGame:show();
            return
        end
    end

    if IS_AUTOMATCH then
        --自动匹配模式下，一局结束后会，服务端会将用户站起(free)
        local myStatus = DataManager:getMyUserStatus()
        if myStatus == Define.US_FREE then
            TableInfo:sendAutoMatch()
        else
            TableInfo:sendUserStandUpRequest()
        end
    else
        --非匹配模式下，一局结束后会，服务端会将用户状态设置为(sitdown)
        TableInfo:sendUserStandUpRequest()
    end
    
    self._step = 0

end

function PlayScene:showMatching()
--[[
    self.vipImage[self.nextID]:hide()
    self.playerIcon[self.nextID]:show()
    self:setPlayerInfo(self.nextID, "icon", "common/matching.png")

    self.vipImage[self.preID]:hide()
    self.playerIcon[self.preID]:show()
    self:setPlayerInfo(self.preID, "icon", "common/matching.png")
]]
end

function PlayScene:onChangeRoom()
    --重连房间
    RunTimeData:onClickFastStart()
    
end

function PlayScene:onTuoGuan()
    
    if not self.tuoguan then
        self.tuoguan = require("landlord.ViewTuoGuanLayer").new({data=self._dataModel, callfunc=function() self:onCancelTuoGuan() end})
        self.tuoguan:addTo(self.container, LAYER_Z_ORDER.Z_TUOGUAN)
    end
    
    --if self._dataModel.isTuoGuan and self._dataModel.isTuoGuan[self.myChairID+1] == 0 then
    self:msgTuoGuan(1)
    --end        
end

function PlayScene:onCancelTuoGuan()
    self:msgTuoGuan(0)
end

function PlayScene:onClickAddGold()
    if self.isHappyBeans then
        require("hall.ShopLayer").new(1):addTo(self.container, LAYER_Z_ORDER.Z_POPMSG)
    else
        require("hall.ShopLayer").new(2):addTo(self.container, LAYER_Z_ORDER.Z_POPMSG)
    end
end

function PlayScene:onClickDouble()
    print("onClickDouble")
end

function PlayScene:onClickUserInfo(index)
    local chairID = {}
    chairID[1] = self.myChairID
    chairID[2] = self.nextID
    chairID[3] = self.preID
    local isshow = false
    if index == 0 then
        isshow = true
    end
    print("onClickUserInfo" .. index)

    
    self.userInfo = require("landlord.ViewPlayerInfo").new({self.isHappyBeans,index})
    self.userInfo:addTo(self.container, LAYER_Z_ORDER.Z_POPMSG)--:align(display.CENTER, display.cx, display.cy)

    local userInfo = DataManager:getUserInfoInMyTableByChairID(chairID[index])
    if userInfo then
        self.userInfo:refreshByIndex({self.isHappyBeans,index})
        self.userInfo:show()
        self.userInfo:setName(userInfo.nickName)
        self.userInfo:setID(userInfo.gameID)
        -- self.userInfo:setHLD(userInfo.beans)
        self.userInfo:setHLD(userInfo.score)
        self.userInfo:setGold(userInfo.score)
        self.userInfo:setLQ(userInfo.present,isshow)
        self.userInfo:setML(userInfo.loveLiness)
        self.userInfo:setMaxGold(userInfo.highestScore)
        self.userInfo:setLevelInfo(userInfo.medal)
        self.userInfo:setSex(userInfo.gender)
        self.userInfo:setIcon(userInfo.faceID,userInfo.platformID, userInfo.platformFace)
        self.userInfo:setVip(userInfo.memberOrder)
        self.userInfo:setUnderWrite(userInfo.signature)
    end
end

function PlayScene:onGameStart(type)
    -- self.needRestart = false
    -- print("onGameStart" .. type)
    -- --self.btnMingPai:hide();
    -- self.btnStartGame:hide();
    ---判断能否准入
    if self.isHappyBeans then
        if DataManager:getMyUserInfo().score < self:getMinEnterScore() then
            Hall.showTips("欢乐豆不足无法开始游戏", 1)
            self.btnStartGame:show();
            return
        end
    else
        if DataManager:getMyUserInfo().score < self:getMinEnterScore() then
            Hall.showTips("金币不足无法开始游戏", 1)
            self.btnStartGame:show();
            return
        end
    end
    -- --发送消息给服务器
    local myUserStatus = DataManager:getMyUserStatus()
    if myUserStatus == Define.US_FREE then
        if IS_AUTOMATCH then
            TableInfo:sendAutoMatch()
        else
            TableInfo:sendUserSitdownRequest(65535, 65535)
        end
        self:showMatching()
        print("showMatching()-----onGameStart")
    
    elseif myUserStatus == Define.US_SIT then
        self:msgReady()
    end
end

-- 抢地主
function PlayScene:onRobLandlord()
    print("onRobLandlord")
end

-- 加倍
function PlayScene:onGameDouble()
    print("onGameDouble" .. type)
end

-- 出牌
function PlayScene:onPlayCards()
    print("onGameStart" .. type)
end

-- 通讯消息
function PlayScene:msgSitDown()
    
end

function PlayScene:msgReady()

    TableInfo:sendUserReadyRequest()

    --换桌时，服务端可能不会返回ready状态，这里将离开状态reset，防止上一局换桌而没有reset离开状态的问题
    self.leaveType = 0
end

function PlayScene:msgLeaveTable()
    --站起
    TableInfo:sendUserReadyRequest()
    GameConnection:closeRoomSocketDelay(2.0)
end

function PlayScene:msgTuoGuan(n)
    if (n == 1 and not self._dataModel:checkTuoGuan(self.myChairID)) or (n == 0 and self._dataModel:checkTuoGuan(self.myChairID)) then
        DoudizhuInfo:sendTuoGuan(n)
    end
end

function PlayScene:gameTuoGuan(bTuoGuan)
    print("PlayScene:gameTuoGuan", bTuoGuan)
    if not self.tuoguan then
        self.tuoguan = require("landlord.ViewTuoGuanLayer").new({data=self._dataModel, callfunc=function() self:onCancelTuoGuan() end})
        self.tuoguan:addTo(self.container, LAYER_Z_ORDER.Z_TUOGUAN)
    end

    --更新托管信息按钮
    self._dataModel:tuoGuan(bTuoGuan)
    self.tuoguan:refresh()
    if self.cardLayer then
        self.cardLayer:tuoGuan()
    end
    
end

function PlayScene:showEffectBianShen(node)

    local x,y = node:getPosition()
    local animation = EffectFactory:getInstance():getAnimationByName("bianshen")
    local sprite = display.newSprite():addTo(node):align(display.CENTER, 50, 50)
    local action = cc.Sequence:create(
                                    cc.FadeIn:create(0.1),
                                    cc.Animate:create(animation),
                                    cc.FadeOut:create(0.1),
                                    cc.CallFunc:create(function() sprite:removeSelf() end)
                                    )
    sprite:runAction(action)

end

--更新头像
function PlayScene:updateIcons()

    for i=1,3 do
        if i == self._dataModel.banker then
            self:setPlayerInfo(i, "icon", "play3/icon_dz.png")
            self:showEffectBianShen(self.playerIcon[i]:getParent())

        else
            self:setPlayerInfo(i, "icon", "play3/icon_nm.png")
            self:showEffectBianShen(self.playerIcon[i]:getParent())
        end
    end

end

--更新倍数信息
function PlayScene:doublePlusNum()
    print("炸弹翻倍前：", self.plusNum:getTag())
    local n = self.plusNum:getTag()*2
    self.plusNum:setTag(n)
    self.plusNum:setString(n)
    self.plusNum:runAction(cc.Sequence:create(
            cc.EaseIn:create(cc.ScaleTo:create(0.2, 3.0), 3),
            cc.EaseOut:create(cc.ScaleTo:create(0.2, 1.0), 3)
        ))
end

function PlayScene:updatePlusNum(n)
    if n ~= 255 and n ~= 255*3 then
        self.plusNum:setTag(n)
        self.plusNum:setString(n)
    end
end

-- 更新玩家金币和昵称
function PlayScene:setPlayerInfo(index, type, value)
    -- print("------------setPlayerInfo", index, type, value)
    if index == self.myChairID then
        if type == "name" then
            self.nickName[index]:setString(FormotGameNickName(value,5))
        elseif type == "gold" then
            self.gold[index]:setTitleText(FormatNumToString(value))
        elseif type == "icon" then
            self.playerIcon[index]:setTexture(value)
        elseif type == "vip" then
            if value >= 1 and value <= 5 then
                self.vipImage[index]:setTexture("hallScene/shop/zuan"..value..".png")
                self.vipImage[index]:setVisible(true)
            else
                self.vipImage[index]:setVisible(false)
            end
        end

    elseif index == self.nextID then
        if type == "name" then
            self.nickName[index]:setString(FormotGameNickName(value,5))
        elseif type == "gold" then
            self.gold[index]:setString(FormatNumToString(value))
        elseif type == "icon" then
            self.playerIcon[index]:setTexture(value)
        elseif type == "vip" then
            if value >= 1 and value <= 5 then
                self.vipImage[index]:setTexture("hallScene/shop/zuan"..value..".png")
                self.vipImage[index]:setVisible(true)
            else
                self.vipImage[index]:setVisible(false)
            end
        end

    elseif index == self.preID then
        if type == "name" then
            self.nickName[index]:setString(FormotGameNickName(value,5))
        elseif type == "gold" then
            self.gold[index]:setString(FormatNumToString(value))
        elseif type == "icon" then
            self.playerIcon[index]:setTexture(value)
        elseif type == "vip" then
            if value >= 1 and value <= 5 then
                if OnlineConfig_review == "off" then
                    self.vipImage[index]:setTexture("hallScene/shop/zuan"..value..".png")
                end
                self.vipImage[index]:setVisible(true)
            else
                self.vipImage[index]:setVisible(false)
            end

        end
    end
    
    if OnlineConfig_review == "on" and type == "vip" then
       self.vipImage[index]:setVisible(false)
    end 
end

function PlayScene:recoverFree(msg)
    self.playConfig = msg

    --更新底分信息
    self.difenNum:setString(FormatDigitToString(self.playConfig.lCellScore,0))
    self:updatePlusNum(0)

    self.isRecover = true
end

function PlayScene:recoverGameJDZ(msg)
--[[
    //时间信息
    required int32                          cbTimeOutCard       = 1;            //出牌时间
    required int32                          cbTimeCallScore     = 2;            //叫分时间
    required int32                          cbTimeStartGame     = 3;            //开始时间
    required int32                          cbTimeHeadOutCard   = 4;            //首出时间

    //游戏信息
    required int64                          lCellScore          = 5;            //单元积分
    required int32                          wCurrentUser        = 6;            //当前玩家
    required int32                          cbBankerScore       = 7;            //庄家叫分
    repeated int32                          cbScoreInfo         = 8;            //叫分信息
    repeated int32                          cbHandCardData      = 9;            //手上扑克

    //历史积分
    repeated int64                          lTurnScore      = 10;           //积分信息
    repeated int64                          lCollectScore       = 11;           //积分信息
]]

    self.playConfig = msg

    --dateModel
    self._dataModel:refreshCards(msg.cbHandCardData)
    self._dataModel:setDiFen(msg.lCellScore)
    self._dataModel:setRobPlus(msg.cbBankerScore)
    self._dataModel:cachePlayerInfo()

    -- 玩家信息
    self:initSeatInfo()

    --更新界面
    self.btnTuoGuan:show()
    if self.btnChangeTable then
        self.btnChangeTable:hide()
    end
    
    self.btnStartGame:hide();
    
    if not self.cardLayer then
        self.cardLayer = viewCardLayer.new(self._dataModel)
                    :addTo(self.container, LAYER_Z_ORDER.Z_CARD)
                    :align(display.CENTER, display.cx, display.cy)
        self.cardLayer:recover(msg)
    end

    if not self.nodeQdz then
        self.nodeQdz = require("landlord.ViewJDZLayer").new({config=self.playConfig})
                    :addTo(self.container, LAYER_Z_ORDER.Z_BUTTONS)
        self.nodeQdz:recover(msg)
    end

    --更新倍数信息
    self.difenNum:setString(FormatDigitToString(self.playConfig.lCellScore,0))
    self:updatePlusNum(msg.cbBankerScore)

    self.isRecover = true
end

function PlayScene:recoverGamePlay(msg)
    --[[
    required int32                          cbTimeOutCard       = 1;            //出牌时间
    required int32                          cbTimeCallScore     = 2;            //叫分时间
    required int32                          cbTimeStartGame     = 3;            //开始时间
    required int32                          cbTimeHeadOutCard   = 4;            //首出时间
                                                    
    //游戏变量                                          
    required int64                          lCellScore      = 5;            //单元积分
    required int32                          cbBombCount         = 6;            //炸弹次数
    required int32                          wBankerUser         = 7;            //庄家用户
    required int32                          wCurrentUser        = 8;            //当前玩家
    required int32                          cbBankerScore       = 9;            //庄家叫分
                                                    
    //出牌信息                                          
    required int32                          wTurnWiner      = 10;           //胜利玩家
    required int32                          cbTurnCardCount     = 11;           //出牌数目
    repeated int32                          cbTurnCardData      = 12;           //出牌数据

    //扑克信息
    repeated int32                          cbBankerCard        = 13;           //游戏底牌
    repeated int32                          cbHandCardData      = 14;           //手上扑克
    repeated int32                          cbHandCardCount     = 15;           //扑克数目

    //历史积分
    repeated int64                          lTurnScore      = 16;           //积分信息
    repeated int64                          lCollectScore       = 17;           //积分信息
]]

    --playconfig

    self.playConfig = msg

    --dateModel
    dump(msg, "recoverGamePlay")
    self._dataModel:refreshCards(msg.cbHandCardData)
    self._dataModel:setBanker(msg.wBankerUser)
    self._dataModel:refreshDiPai(msg.cbBankerCard)
    self._dataModel:setRobPlus(msg.cbBankerScore)
    self._dataModel:setDiFen(msg.lCellScore)
    self._dataModel:cachePlayerInfo()

    -- 玩家信息
    self._step = 4
    self:initSeatInfo()
    self:updateIcons()

    --更新界面
    self.btnTuoGuan:show()
    if self.btnChangeTable then
        self.btnChangeTable:hide()
    end
    
    self.btnStartGame:hide();

    if not self.cardLayer then
        self.cardLayer = viewCardLayer.new(self._dataModel)
                    :addTo(self.container, LAYER_Z_ORDER.Z_CARD)
                    :align(display.CENTER, display.cx, display.cy)
        self.cardLayer:recover(msg)
    end

    if not self.nodeChuPai then
        self.nodeChuPai = require("landlord.ViewChuPaiLayer").new({cardLayer=self.cardLayer, config=self.playConfig})
                    :addTo(self.container, LAYER_Z_ORDER.Z_BUTTONS)
        self.nodeChuPai:showChuPai(msg)
    end

    --更新倍数信息
    self.difenNum:setString(FormatDigitToString(self.playConfig.lCellScore,0))
    local plus = math.pow(2, msg.cbBombCount)
    self:updatePlusNum(plus*msg.cbBankerScore)
    
    self.isRecover = true
end

function PlayScene:requestInsure()
    BankInfoInGame:sendQueryRequest()
end

-- function PlayScene:onQueryUserInsure(event)
--     print("onQueryUserInsure!!")
--     self.lUserMaxScore = event.score
--     self:updateSelfScore()
-- end

function PlayScene:getFlyStartIndex(sourceUserID)
    
    local userInfo = DataManager:getUserInfoByUserID(sourceUserID)
    return userInfo.chairID
end
function PlayScene:onUsePropertyResult(event)
    local result = false
    local propertySuccess = PropertyInfo.usePropertyResult--event.data
    if propertySuccess.code == 1 then
        result = true
    elseif propertySuccess.code == 2 then
    elseif propertySuccess.code == 3 then
    elseif propertySuccess.code == 4 then
    elseif propertySuccess.code == 5 then
    elseif propertySuccess.code == 6 then
    elseif propertySuccess.code == 7 then
    elseif propertySuccess.code == 8 then
    end

    if result == false then
        print("-------使用道具失败-------code--",propertySuccess.code)
        return 
    end
end
function PlayScene:onPropertySuccess(event)

    -- self:requestInsure()
    
    print("--播放道具动画")
    local propertySuccess = PropertyInfo.usePropertyBroadcast
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
end

--赠送礼物动画
function PlayScene:flyGift(startIndex,endIndex,giftIndex,giftCount)
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
    local originNode = self.playerIcon[startIndex]
    local originWorldPosition = originNode:getParent():convertToWorldSpace(cc.p(originNode:getPositionX(),originNode:getPositionY()))
    local originPosition = self.container:convertToNodeSpace(cc.p(originWorldPosition.x,originWorldPosition.y))
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
    local targetNode = self.playerIcon[endIndex]
    local targetWorldPosition = targetNode:getParent():convertToWorldSpace(cc.p(targetNode:getPositionX(),targetNode:getPositionY()))
    local targetPosition = self.container:convertToNodeSpace(cc.p(targetWorldPosition.x,targetWorldPosition.y))

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
end

function PlayScene:showScrollMessage(messageContent,color,labaKind)
    table.insert(self.scrollMessageArr, messageContent)
    table.insert(self.scrollMessageKindArr,labaKind)
    if self.scrollTextContainer and self.scrollTextContainer:isVisible() == false then
        self.scrollTextContainer:setVisible(true)
        self:startScrollMessage(color)
    end
end

function PlayScene:startScrollMessage(color)
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


function PlayScene:pochanEffect(index)

    if index == self.myChairID then -- myself
        local armature = EffectFactory:getInstance():getMyselfPoChanArmature()
        self.container:addChild(armature)
        armature:setPosition(cc.p(display.cx, display.cy))
        armature:runAction(cc.Sequence:create(cc.DelayTime:create(2.0),
                                            cc.CallFunc:create(function() armature:removeSelf() end)))                                  

    else
        local anchorPet = display.newSprite():addTo(self.playerIcon[index]:getParent())
        anchorPet:setPosition(cc.p(46,55))
        local animation = EffectFactory:getInstance():getOthersPoChanEffect()
        local action = cc.Sequence:create(cc.Animate:create(animation),
            cc.DelayTime:create(0.1),
            cc.CallFunc:create(function ()
                anchorPet:removeSelf()
            end))
        anchorPet:runAction(action)
    end
end
return PlayScene
