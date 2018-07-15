local LandlordVideoScene = class("LandlordVideoScene", require("ui.CCBaseScene"))

require("landlordVideo.DefineForLandlordVideo")
require("protocol.game.battleDoudizhu.battleDoudizhu_pb")
require("business.loveRankManager.LoveRankManager")
require("gameSetting.GameConfig")
local CCTimer = require("commonView.CCTimer")




local EffectFactory = require("commonView.DDZEffectFactory")

function LandlordVideoScene:ctor()
    -- 根节点变更为self.container
    self.super.ctor(self)
    
    --防止frames释放
    EffectFactory:getInstance():cacheFrames()

    --背景
    local bgSprite = cc.Sprite:create()
    bgSprite:setTexture("landlordVideo/vipgame_bg.png")
    bgSprite:align(display.CENTER, display.cx, display.cy)
    self.container:addChild(bgSprite)
    local curGameServer = RunTimeData:getCurGameServer()
    local curGameServerID = curGameServer:getServerID()
    local serverIndex = VideoAnchorManager:getAnchorGameServerIndex(curGameServerID)
    if serverIndex then
        self.gameTableBg = ccui.ImageView:create("landlordVideo/vip_table_"..serverIndex..".png")
    end
    self.gameTableBg:setPosition(cc.p(568,402))
    self.container:addChild(self.gameTableBg)

    --初始话数据
    --用户的钱
    self.lUserMaxScore = 0
    --下注区域数据
    self.jettonScoreArr = {100,500,1000,5000}
    self.curSelectJettonButton = 0
    self.visiablePlayer={}
    self.targetJettonCount={}--金币数量
    self.totalJettonScore={}
    self.myJettonScore={}
    self.myTotalJettonScoreForShow = 0
    --是否已重复下注 重复上一轮下注  未重复下注无法选择加倍下注
    self.reJettonArr = {}
    self.reJetton = false
    --下注飞金币动画数组
    self.jettonGoldRecordArr = {}
    --结算金币飞回动画
    self.dispatchGoldRecordArr = {}
    --结算的牌组
    self.tableCardArray = {}
    self.curUserScore = 0                           --玩家成绩
    self.curGameResult = 1 --本局输赢情况 0，1，2 地主 平 农民
    --房间输赢揭露
    self.battleRecord = {}
    self.colorArray = {cc.c3b(253, 234, 109),cc.c3b(188,255,0),cc.c3b(79,214,254),cc.c3b(255,255,255)}--fdea6d  bcff00 4fd6fe ffffff  
    --初始化ui
    self:createUI()
    --菜单展开中
    self.menuOpening = false
    --滚动消息数组
    self.scrollMessageArr = {}
    self.scrollMessageKindArr = {}
    --按键处理
    self:setKeypadEnabled(true)
    self:addNodeEventListener(cc.KEYPAD_EVENT, function(event)
        if event.key == "back" then
            self:onClickBack()
        end
    end)
end

function LandlordVideoScene:resetAllData()
    --下注区域 下注总数  下注金币
    for i=1,3 do
        local jettonArea = self.gameContainer:getChildByTag(500+i)
        jettonArea:setTouchEnabled(false)
        local totalJettonScore = jettonArea:getChildByTag(1)
        totalJettonScore:setVisible(false)
        local myJettonScore = jettonArea:getChildByTag(2)
        myJettonScore:setVisible(false)
        local goldArea = jettonArea:getChildByTag(4)
        goldArea:removeAllChildren()
    end
    --牌信息
    for i=1,2 do
        local card = self.sendcardContainer:getChildByName("Card"..i)
        if card then
            card:removeFromParent()
        end
    end
    --结算
    --hidegameresult
    self.gameResultLayer:hideGameResult()
    
    --下注按钮区域
    self:onJettonButtonSelected(0)
    self:enableRejettonButton(false)
    self:enableDoubleButton(false)
    --用户信息
    --其他用户信息

    --data
    self.curSelectJettonButton = 0
    cleanTable(self.targetJettonCount)
    self.totalJettonScore = {}
    self.reJettonArr = {}
    copyTable(self.myJettonScore, self.reJettonArr)
    self.reJetton = false
    self.myJettonScore = {}
    self.myTotalJettonScoreForShow = 0
    cleanTable(self.jettonGoldRecordArr)
    cleanTable(self.dispatchGoldRecordArr)
end

function LandlordVideoScene:createVideoAndPlay()
    local gameServer = RunTimeData:getCurGameServer()

    --订阅房间
    local anchorRoomID = VideoAnchorManager:getAnchorRoomID(gameServer:getServerID())
    subScribeAnchorRoom(anchorRoomID)

    local isOnline = VideoAnchorManager:isOnline(gameServer:getServerID())
    self.videoDisableText:setVisible(false)
    if isOnline == 1 then
        --视频加载中文字
        self.anchorAniText:loadTexture("landlordVideo/video_ani_text1.png")

        local videoAreaLayer = self.gameContainer:getChildByName("videoVisiableArea")
        local videoAreaWorldPosition = videoAreaLayer:getParent():convertToWorldSpace(cc.p(videoAreaLayer:getPositionX(),videoAreaLayer:getPositionY()))
        local posX = videoAreaWorldPosition.x * display.contentScaleFactor 
        local posY = videoAreaWorldPosition.y * display.contentScaleFactor 
        local width = (videoAreaLayer:getContentSize().width - 40) * display.contentScaleFactor 
        local height = (videoAreaLayer:getContentSize().height - 30) * display.contentScaleFactor 
        IJKCreateVedioView(posX - width / 2,display.sizeInPixels.height - posY - height / 2,width,height)
        local url = VideoAnchorManager:getAnchorUrl(gameServer:getServerID())
        print("createVideoAndPlay:",url)
        IJKPlayWithUrl(url)
        --开启定时器
        local function onInterval(dt)
            self.anchorAniText:loadTexture("landlordVideo/video_ani_text2.png")
        end
        local scheduler = require("framework.scheduler")
        self.videoLoadingListener = scheduler.performWithDelayGlobal(onInterval, 10)
    else
        --主播mm相亲去了
        self.anchorAniText:loadTexture("landlordVideo/video_ani_text2.png")
    end
end

function LandlordVideoScene:getCurAnchorUserID()
    local curGameServer = RunTimeData:getCurGameServer()
    local curGameServerID = curGameServer:getServerID()
    return VideoAnchorManager:getAnchorGameID(curGameServerID)
end

function LandlordVideoScene:getCurAnchorNickName()
    local curGameServer = RunTimeData:getCurGameServer()
    local curGameServerID = curGameServer:getServerID()
    return VideoAnchorManager:getAnchorName(curGameServerID)
end

--构建界面
function LandlordVideoScene:createUI()
    --游戏区域
    self:createGameContainer()
end

function LandlordVideoScene:createVideoContainer()

    --视频区域
    local videoAreaLayer = ccui.ImageView:create()
    videoAreaLayer:loadTexture("landlordVideo/video_disable_bg.png")
    videoAreaLayer:setPosition(cc.p(281,477))
    videoAreaLayer:setName("videoVisiableArea")
    self.gameContainer:addChild(videoAreaLayer)
    --无视频时显示
    self.videoDisableText = ccui.ImageView:create()
    self.videoDisableText:loadTexture("landlordVideo/video_disable_text.png")
    self.videoDisableText:setPosition(cc.p(223,150))
    videoAreaLayer:addChild(self.videoDisableText)
    --无主播时显示
    local videoDefaultLayer = ccui.ImageView:create()
    videoDefaultLayer:setScale(0.96)
    videoDefaultLayer:loadTexture("landlordVideo/video_default_bg.png")
    videoDefaultLayer:setPosition(cc.p(220.5,152))
    videoAreaLayer:addChild(videoDefaultLayer)

    local anchorDefaultImg = EffectFactory:getInstance():getZhuBoMMAnimation()
    anchorDefaultImg:ignoreAnchorPointForPosition(false)
    anchorDefaultImg:setAnchorPoint(cc.p(0.5,0.5))
    anchorDefaultImg:setPosition(cc.p(120,135))
    videoDefaultLayer:addChild(anchorDefaultImg)
    anchorDefaultImg:getAnimation():playWithIndex(0)

    local jj = display.newSprite("common/ty_xiao_ji.png")
    jj:setPosition(cc.p(300,60))
    videoDefaultLayer:addChild(jj)

    local textBg = display.newSprite("effect/zhu_bo_mm/VIPduih.png")
    textBg:setPosition(cc.p(300,195))
    videoDefaultLayer:addChild(textBg)

    local anchorAniText = ccui.ImageView:create("landlordVideo/video_ani_text2.png")
    anchorAniText:setPosition(cc.p(300,195))
    videoDefaultLayer:addChild(anchorAniText)
    self.anchorAniText = anchorAniText

    self.videoDefaultLayer = videoDefaultLayer
    --退出房间
    local backButton = ccui.Button:create()
    backButton:setTouchEnabled(true)
    backButton:setPressedActionEnabled(true)
    backButton:loadTextures("landlordVideo/vip_back.png","landlordVideo/vip_back.png")
    backButton:setPosition(cc.p(40,590))
    self.gameContainer:addChild(backButton)
    backButton:addTouchEventListener(function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                SoundManager.playSound("sound/buttonclick.mp3")
                self:onClickBack()
            end
        end)

    --功能区域
    --视频seek
    self.videoTypeButton = ccui.Button:create()
    self.videoTypeButton:setTouchEnabled(true)
    self.videoTypeButton:setPressedActionEnabled(true)
    self.videoTypeButton:loadTextures("landlordVideo/video_function_lighton.png","landlordVideo/video_function_lighton.png")
    self.videoTypeButton:setPosition(cc.p(120,320))
    self.gameContainer:addChild(self.videoTypeButton)
    self.videoTypeButton:addTouchEventListener(function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                SoundManager.playSound("sound/buttonclick.mp3")
                self:onVideoSeekToZero()
            end
        end)
    -- self.videoTypeButton:setVisible(false)
    --排名
    local anchorRankButton = ccui.Button:create()
    anchorRankButton:setTouchEnabled(true)
    anchorRankButton:setPressedActionEnabled(true)
    anchorRankButton:loadTextures("landlordVideo/video_function_rank.png","landlordVideo/video_function_rank.png")
    anchorRankButton:setPosition(cc.p(200,320))
    -- anchorRankButton:setPosition(cc.p(120,320))
    self.gameContainer:addChild(anchorRankButton)
    anchorRankButton:addTouchEventListener(function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                SoundManager.playSound("sound/buttonclick.mp3")
                self:showFansRankLayer()
            end
        end)
    -- anchorRankButton:setVisible(false)
    --切换主播
    local changeAnchorButton = ccui.Button:create()
    changeAnchorButton:setTouchEnabled(true)
    changeAnchorButton:setPressedActionEnabled(true)
    changeAnchorButton:loadTextures("landlordVideo/video_function_anchor.png","landlordVideo/video_function_anchor.png")
    changeAnchorButton:setPosition(cc.p(280,320))
    -- changeAnchorButton:setPosition(cc.p(225,320))
    self.gameContainer:addChild(changeAnchorButton)
    changeAnchorButton:addTouchEventListener(function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                SoundManager.playSound("sound/buttonclick.mp3")
                self:showAnchorChangeLayer()
            end
        end)
    -- changeAnchorButton:setVisible(false)
    --送筹码
    local sendGoldButton = ccui.Button:create()
    sendGoldButton:setTouchEnabled(true)
    sendGoldButton:setPressedActionEnabled(true)
    sendGoldButton:loadTextures("landlordVideo/video_function_gold.png","landlordVideo/video_function_gold.png")
    sendGoldButton:setPosition(cc.p(360,320))
    -- sendGoldButton:setPosition(cc.p(335,320))
    self.gameContainer:addChild(sendGoldButton)
    sendGoldButton:addTouchEventListener(function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                SoundManager.playSound("sound/buttonclick.mp3")
                self:onSendGold()
            end
        end)
    -- sendGoldButton:setVisible(false)
    --送道具
    local sendPropertyButton = ccui.Button:create()
    sendPropertyButton:setTouchEnabled(true)
    sendPropertyButton:setPressedActionEnabled(true)
    sendPropertyButton:loadTextures("landlordVideo/video_function_property.png","landlordVideo/video_function_property.png")
    sendPropertyButton:setPosition(cc.p(440,320))
    self.gameContainer:addChild(sendPropertyButton)
    sendPropertyButton:addTouchEventListener(function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                SoundManager.playSound("sound/buttonclick.mp3")
                self:onSendProperty({targetUserID = self:getCurAnchorUserID()})
            end
        end)
    -- sendPropertyButton:setVisible(false)
    --创建视频并播放
    self:createVideoAndPlay()
end

function LandlordVideoScene:createGameContainer()
    self.gameContainer = ccui.Layout:create()
    self.gameContainer:setContentSize(cc.size(1136,640))
    self.container:addChild(self.gameContainer)

    --个人信息区域
    local selfInfoLayer = ccui.ImageView:create()
    selfInfoLayer:loadTexture("landlordVideo/selfinfo_bg.png")
    selfInfoLayer:setScale9Enabled(true)
    selfInfoLayer:ignoreAnchorPointForPosition(true)
    selfInfoLayer:setContentSize(cc.size(490,102))
    selfInfoLayer:setCapInsets(cc.rect(50,50,1,1))
    selfInfoLayer:setPosition(cc.p(12, 0)) 
    self.gameContainer:addChild(selfInfoLayer)
    --头像
    self.selfHeadBorder = ccui.ImageView:create()
    self.selfHeadBorder:loadTexture("landlordVideo/selfhead_border.png")
    self.selfHeadBorder:setScale9Enabled(true)
    self.selfHeadBorder:setContentSize(cc.size(96,96))
    self.selfHeadBorder:setCapInsets(cc.rect(19,20,1,1))
    self.selfHeadBorder:setPosition(cc.p(62,50))
    selfInfoLayer:addChild(self.selfHeadBorder)
    local headImage = ccui.ImageView:create()
    headImage:setName("HeadImage")
    headImage:setScale(0.66)
    headImage:loadTexture("head/default.png")
    headImage:setPosition(cc.p(44,52))
    self.selfHeadBorder:addChild(headImage)
    local vipImage = ccui.ImageView:create()
    vipImage:setName("VipImage")
    vipImage:setPosition(cc.p(90,100))
    self.selfHeadBorder:addChild(vipImage)
    --昵称
    local selfNickNameBg = ccui.ImageView:create()
    selfNickNameBg:loadTexture("landlordVideo/video_info_bg.png")
    selfNickNameBg:setScale9Enabled(true)
    selfNickNameBg:setContentSize(cc.size(138,28))
    selfNickNameBg:setCapInsets(cc.rect(12,13,1,1))
    selfNickNameBg:setAnchorPoint(cc.p(0,0.5))
    selfNickNameBg:setPosition(cc.p(110,73))
    selfInfoLayer:addChild(selfNickNameBg)
    self.nickNameLabel = ccui.Text:create("百人斗地主",FONT_ART_TEXT,22)
    self.nickNameLabel:setColor(cc.c3b(253,253,253))
    self.nickNameLabel:enableOutline(cc.c3b(7,1,3), 2)
    self.nickNameLabel:setAnchorPoint(cc.p(0,0.5))
    self.nickNameLabel:setPosition(cc.p(10,15))
    selfNickNameBg:addChild(self.nickNameLabel)
    --金币
    local selfScoreBg = ccui.ImageView:create()
    selfScoreBg:loadTexture("landlordVideo/video_info_bg.png")
    selfScoreBg:setScale9Enabled(true)
    selfScoreBg:setContentSize(cc.size(138,28))
    selfScoreBg:setCapInsets(cc.rect(12,13,1,1))
    selfScoreBg:setAnchorPoint(cc.p(0,0.5))
    selfScoreBg:setPosition(cc.p(110,35))
    selfInfoLayer:addChild(selfScoreBg)
    local goldImage = ccui.ImageView:create()
    goldImage:loadTexture("common/gold.png")
    goldImage:setPosition(cc.p(2,13))
    goldImage:setScale(0.6)
    goldImage:setAnchorPoint(cc.p(0,0.5))
    selfScoreBg:addChild(goldImage)
    self.goldLabel = ccui.Text:create("9999.9万",FONT_ART_TEXT,22)
    self.goldLabel:setColor(cc.c3b(255,237,86))
    self.goldLabel:enableOutline(cc.c3b(0,4,8), 2)
    self.goldLabel:setAnchorPoint(cc.p(0,0.5))
    self.goldLabel:setPosition(cc.p(38,15))
    selfScoreBg:addChild(self.goldLabel)
    --特殊功能按钮
    self.rejettonButton = ccui.Button:create()
    self.rejettonButton:setTouchEnabled(true)
    self.rejettonButton:setPressedActionEnabled(true)
    self.rejettonButton:loadTextures("landlordVideo/rejetton.png","landlordVideo/rejetton.png")
    self.rejettonButton:setPosition(cc.p(310,53))
    selfInfoLayer:addChild(self.rejettonButton)
    self.rejettonButton:addTouchEventListener(function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                -- SoundManager.playSound("sound/buttonclick.mp3")
                self:onReJetton()
            end
        end)
    self.doubleButton = ccui.Button:create()
    self.doubleButton:setTouchEnabled(true)
    self.doubleButton:setPressedActionEnabled(true)
    self.doubleButton:loadTextures("landlordVideo/double_jetton.png","landlordVideo/double_jetton.png")
    self.doubleButton:setPosition(cc.p(415,53))
    selfInfoLayer:addChild(self.doubleButton)
    self.doubleButton:addTouchEventListener(function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                -- SoundManager.playSound("sound/buttonclick.mp3")
                self:onDoubleJetton()
            end
        end)

    --其他玩家
    self:initOtherPlayer()

    --房间胜负纪录
    local RoomChangeButton = require("landlordVideo.RoomChangeButton")
    self.roomChangeButton = RoomChangeButton.new()
    self.roomChangeButton:setPosition(cc.p(925,-2))
    self.gameContainer:addChild(self.roomChangeButton)

    --下注区域
    self.jettonAreaLayer = ccui.Layout:create()
    self.jettonAreaLayer:setContentSize(cc.size(360,100))
    self.jettonAreaLayer:setPosition(cc.p(530,0))
    self.gameContainer:addChild(self.jettonAreaLayer)
    local jettonAreaBg = ccui.ImageView:create("landlordVideo/vip_jettonbuttonbg.png")
    jettonAreaBg:setScale9Enabled(true)
    jettonAreaBg:setContentSize(cc.size(400,90))
    jettonAreaBg:setPosition(cc.p(180,48))
    self.jettonAreaLayer:addChild(jettonAreaBg)

    --下注按钮
    for i=1,4 do
        local jettonButton = ccui.ImageView:create()
        jettonButton:setTag(i)
        jettonButton:setTouchEnabled(true)
        jettonButton:loadTexture("landlordVideo/jetton_button"..i..".png")
        jettonButton:setPosition(cc.p(90*i-45,45))
        self.jettonAreaLayer:addChild(jettonButton)
        local jettonSelected = ccui.ImageView:create()
        jettonSelected:setVisible(false)
        jettonSelected:setName("JettonSelected")
        jettonSelected:loadTexture("landlordVideo/jetton_selected.png")
        jettonSelected:setPosition(cc.p(36,41))
        jettonButton:addChild(jettonSelected)
        local jettonLabel = ccui.Text:create()
        jettonLabel:setName("JettonValue")
        jettonLabel:setString(self.jettonScoreArr[i])
        jettonLabel:setFontSize(20)
        jettonLabel:enableOutline(cc.c3b(0,0,0), 2)
        jettonLabel:setPosition(cc.p(36,40))
        jettonButton:addChild(jettonLabel)
        jettonButton:addTouchEventListener(function(sender,eventType)
            if eventType == ccui.TouchEventType.began then
                SoundManager.playSound("sound/buttonclick.mp3")
                jettonButton:setScale(1.1)
            elseif eventType == ccui.TouchEventType.ended then
                jettonButton:setScale(1.0)
                self:onJettonButtonSelected(jettonButton:getTag())
            elseif eventType == ccui.TouchEventType.canceled then
                jettonButton:setScale(1.0)
            end
        end)
    end
    --下注区域 1地主 2平 3农民
    -- local drawJettonArea = cc.rect(249,428,162,145)
    -- local loadJettonArea = cc.rect(70,268,260,160)
    -- local farmerJettonArea = cc.rect(330,268,260,160)
    local jettonAreaSize = {
        {270,150},
        {200,220},
        {270,150}
    }
    local jettonAreaPosition = {
        {680,440},
        {480,330},
        {680,290}
    }
    local pointImg = {
        "landlordVideo/dizhuPoint.png",
        "landlordVideo/pingjuPoint.png",
        "landlordVideo/nongminPoint.png"
    }
    local pointImgPosition = {
        {55,85},
        {25,140},
        {55,92}
    }
    local pressedImg = {
        "landlordVideo/dizhuPressed.png",
        "landlordVideo/pingjuPressed.png",
        "landlordVideo/nongminPressed.png"
    }
    local pressedImgPosition = {
        {130,108},
        {86,111},
        {130,42}
    }
    local winResultImg = {
        "landlordVideo/dizhuWin.png",
        "landlordVideo/pingjuWin.png",
        "landlordVideo/nongminWin.png"
    }
    for i=1,3 do
        -- local tColor = 1
        -- if i == 1 then
        --     tColor = cc.c4b(255,0,0,255)
        -- elseif i == 2 then
        --     tColor = cc.c4b(0,255,0,255)
        -- elseif i == 3 then
        --     tColor = cc.c4b(0,0,255,255)
        -- end
        -- local colorLayer = cc.LayerColor:create(tColor)
        -- colorLayer:setContentSize(cc.size(jettonAreaSize[i][1],jettonAreaSize[i][2]))
        -- colorLayer:setPosition(cc.p(jettonAreaPosition[i][1],jettonAreaPosition[i][2]))
        -- self.gameContainer:addChild(colorLayer)
        local jettonArea = ccui.Layout:create()
        -- local jettonArea = cc.LayerColor:create(cc.c4b(200,0,0,255))
        jettonArea:setTag(500+i)
        jettonArea:setTouchEnabled(true)
        jettonArea:setContentSize(cc.size(jettonAreaSize[i][1],jettonAreaSize[i][2]))
        jettonArea:setPosition(cc.p(jettonAreaPosition[i][1],jettonAreaPosition[i][2]))
        self.gameContainer:addChild(jettonArea)
        --指示点
        local hintPointImg = ccui.ImageView:create(pointImg[i])
        hintPointImg:setPosition(cc.p(pointImgPosition[i][1],pointImgPosition[i][2]))
        jettonArea:addChild(hintPointImg)
        --按压效果
        local pointPressedImg = ccui.ImageView:create(pressedImg[i])
        pointPressedImg:setName("pointPressedImg")
        pointPressedImg:setPosition(cc.p(pressedImgPosition[i][1],pressedImgPosition[i][2]))
        pointPressedImg:setVisible(false)
        jettonArea:addChild(pointPressedImg)
        jettonArea:addTouchEventListener(function(sender,eventType)
            if eventType == ccui.TouchEventType.began then
                pointPressedImg:setVisible(true)
            elseif eventType == ccui.TouchEventType.ended then
                self:onJettonAreaClick(jettonArea:getTag()-500)
                pointPressedImg:setVisible(false)
            elseif eventType == ccui.TouchEventType.canceled then
                pointPressedImg:setVisible(false)
            end
        end)
        --赢效果
        local winResultImg = ccui.ImageView:create(winResultImg[i])
        winResultImg:setName("winResultImg")
        winResultImg:setPosition(cc.p(pressedImgPosition[i][1],pressedImgPosition[i][2]))
        winResultImg:setVisible(false)
        jettonArea:addChild(winResultImg)

        local goldArea = ccui.Layout:create()
        goldArea:setTag(4)
        goldArea:setContentSize(cc.size(jettonAreaSize[i][1],jettonAreaSize[i][2]))
        goldArea:setPosition(cc.p(0,0))
        jettonArea:addChild(goldArea)

        local totalJettonScorePosX = 200
        local totalJettonScorePosY = 90
        local totalJettonScoreAnchor = cc.p(0,0.5)
        if i==2 then
            totalJettonScorePosX = 95
            totalJettonScorePosY = 190
            totalJettonScoreAnchor = cc.p(0.5,0.5)
        end
        local totalJettonScore = ccui.Text:create()
        totalJettonScore:setTag(1)
        totalJettonScore:setFontSize(25)
        totalJettonScore:setAnchorPoint(totalJettonScoreAnchor)
        totalJettonScore:setPosition(cc.p(totalJettonScorePosX,totalJettonScorePosY))
        totalJettonScore:setColor(cc.c3b(254, 241, 66))
        totalJettonScore:enableOutline(cc.c3b(0,0,0), 2)
        totalJettonScore:setString(1000*i)
        jettonArea:addChild(totalJettonScore)
        totalJettonScore:setVisible(false)

        local myJettonScorePosX = 200
        local myJettonScorePosY = 40
        local myJettonScoreAnchor = cc.p(0,0.5)
        if i==2 then
            myJettonScorePosX = 95
            myJettonScorePosY = 30
            myJettonScoreAnchor = cc.p(0.5,0.5)
        end
        local myJettonScore = ccui.Text:create()
        myJettonScore:setTag(2)
        myJettonScore:setFontSize(25)
        myJettonScore:setAnchorPoint(myJettonScoreAnchor)
        myJettonScore:setPosition(cc.p(myJettonScorePosX,myJettonScorePosY))
        myJettonScore:setColor(cc.c3b(75, 250, 253))
        myJettonScore:enableOutline(cc.c3b(0,0,0), 2)
        myJettonScore:setString(1000)
        jettonArea:addChild(myJettonScore)
        myJettonScore:setVisible(false)
    end

    --滚动消息
    local scrollTextContainer = ccui.Layout:create()
    scrollTextContainer:setContentSize(cc.size(626,30))
    scrollTextContainer:setPosition(cc.p(510,595))
    self.gameContainer:addChild(scrollTextContainer)
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

    --计时器
    self.clock = require("commonView.CCTimer").new():addTo(self.gameContainer)
    self.clock:setPosition(cc.p(1015,355))
    
    --菜单按钮
    local menuButton = ccui.Button:create()
    menuButton:setTouchEnabled(true)
    menuButton:setPressedActionEnabled(true)
    menuButton:loadTextures("landlordVideo/vipButton_menu.png","landlordVideo/vipButton_menu.png")
    menuButton:setPosition(cc.p(1095,590))
    self.gameContainer:addChild(menuButton)
    menuButton:addTouchEventListener(function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                SoundManager.playSound("sound/buttonclick.mp3")
                self:onClickMenu()
            end
        end)
    self.menuButton = menuButton
    --菜单列表
    self.menuLayer = ccui.Layout:create()
    self.menuLayer:setContentSize(cc.size(300,80))
    self.menuLayer:setPosition(cc.p(1136,550))
    self.gameContainer:addChild(self.menuLayer)
    local menuBg = ccui.ImageView:create("landlordVideo/vipMenu_bg.png")
    menuBg:setScale9Enabled(true)
    menuBg:setContentSize(cc.size(300,80))
    menuBg:ignoreAnchorPointForPosition(true)
    menuBg:setPosition(cc.p(0,10))
    self.menuLayer:addChild(menuBg)
    --帮助
    local helpButton = ccui.Button:create()
    helpButton:setTouchEnabled(true)
    helpButton:setPressedActionEnabled(true)
    helpButton:loadTextures("landlordVideo/video_help.png","landlordVideo/video_help.png")
    helpButton:setPosition(cc.p(100,40))
    self.menuLayer:addChild(helpButton)
    helpButton:addTouchEventListener(function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                SoundManager.playSound("sound/buttonclick.mp3")
                self:onClickHelp()
            end
        end)

    --银行
    local bankButton = ccui.Button:create()
    bankButton:setTouchEnabled(true)
    bankButton:setPressedActionEnabled(true)
    bankButton:loadTextures("landlordVideo/video_bank.png","landlordVideo/video_bank.png")
    bankButton:setPosition(cc.p(180,40))
    self.menuLayer:addChild(bankButton)
    bankButton:addTouchEventListener(function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                SoundManager.playSound("sound/buttonclick.mp3")
                local bank = require("landlordVideo.VideoBankLayer").new(true);
                self.gameContainer:addChild(bank);
            end
        end)

    --声音开关
    local soundControlButton = ccui.Button:create()
    soundControlButton:setTouchEnabled(true)
    soundControlButton:setPressedActionEnabled(true)
    soundControlButton:setPosition(cc.p(260,40))
    self.menuLayer:addChild(soundControlButton)
    local isSoundOpen = SoundManager.isSoundOpen()
    if isSoundOpen == 1 then
        soundControlButton:loadTextures("landlordVideo/video_soundon.png","landlordVideo/video_soundon.png")
    else
        soundControlButton:loadTextures("landlordVideo/video_soundoff.png","landlordVideo/video_soundoff.png")
    end
    soundControlButton:addTouchEventListener(function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                SoundManager.playSound("sound/buttonclick.mp3")
                local isSoundOpen = SoundManager.isSoundOpen() 
                if isSoundOpen == 1 then
                    soundControlButton:loadTextures("landlordVideo/video_soundoff.png","landlordVideo/video_soundoff.png")
                    SoundManager.saveSoundSwitch(0)
                else
                    soundControlButton:loadTextures("landlordVideo/video_soundon.png","landlordVideo/video_soundon.png")
                    SoundManager.saveSoundSwitch(1)
                end
            end
        end)

    --收起按钮
    local menuCloseButton = ccui.ImageView:create("blank.png")
    menuCloseButton:setScale9Enabled(true)
    menuCloseButton:setTouchEnabled(true)
    menuCloseButton:setContentSize(cc.size(60,80))
    menuCloseButton:setPosition(cc.p(40,40))
    self.menuLayer:addChild(menuCloseButton)
    local menuArrow = ccui.ImageView:create("landlordVideo/vipButton_menuArrow.png")
    menuArrow:setPosition(cc.p(30,40))
    menuCloseButton:addChild(menuArrow)
    menuCloseButton:addTouchEventListener(function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                SoundManager.playSound("sound/buttonclick.mp3")
                self:onClickMenuClose()
            end
        end)

    --聊天
    self.vipChatLayer = require("landlordVideo.VipChatLayer").new()
    self.gameContainer:addChild(self.vipChatLayer)
    self.vipChatLayer:hide()            
    local chatButton = ccui.Button:create()
    chatButton:setTouchEnabled(true)
    chatButton:setPressedActionEnabled(true)
    chatButton:loadTextures("landlordVideo/vipButton_chat.png","landlordVideo/vipButton_chat.png")
    chatButton:setPosition(cc.p(1095,510))
    self.gameContainer:addChild(chatButton)
    chatButton:addTouchEventListener(function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                SoundManager.playSound("sound/buttonclick.mp3")
                self.vipChatLayer:showVipChatLayer()
            end
        end)

    --其他玩家
    local otherPlayerButton = ccui.Button:create()
    otherPlayerButton:setTouchEnabled(true)
    otherPlayerButton:setPressedActionEnabled(true)
    otherPlayerButton:loadTextures("landlordVideo/vipButton_otherPlayer.png","landlordVideo/vipButton_otherPlayer.png")
    otherPlayerButton:setPosition(cc.p(1095,430))
    self.gameContainer:addChild(otherPlayerButton)
    otherPlayerButton:addTouchEventListener(function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                SoundManager.playSound("sound/buttonclick.mp3")
                self:showOtherPlayerList()
            end
        end)
    self.showOtherPlayerButton = otherPlayerButton
    --快速充值
    local quickChargeButton = ccui.Button:create()
    quickChargeButton:setTouchEnabled(true)
    quickChargeButton:setPressedActionEnabled(true)
    quickChargeButton:loadTextures("landlordVideo/vipButton_quickCharge.png","landlordVideo/vipButton_quickCharge.png")
    quickChargeButton:setPosition(cc.p(1095,350))
    self.gameContainer:addChild(quickChargeButton)
    quickChargeButton:addTouchEventListener(function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                SoundManager.playSound("sound/buttonclick.mp3")
                if self.quickChargeLayer == nil then
                    self.quickChargeLayer = require("landlordVideo.QuickRechargeLayer").new()
                    self.gameContainer:addChild(self.quickChargeLayer)
                end
                self.quickChargeLayer:showQuickRechargeLayer()
            end
        end)
    if OnlineConfig_review == "off" then
        quickChargeButton:setVisible(true)
    else
        quickChargeButton:setVisible(false)
    end

    --庄家默认位置  确认金币位置
    self.bankLayer = ccui.ImageView:create()
    -- self.bankLayer:loadTexture("head/default.png")
    self.bankLayer:setVisible(false)
    self.bankLayer:setPosition(cc.p(648,640))
    self.gameContainer:addChild(self.bankLayer)

    --发牌显示
    self.sendcardContainer = ccui.Layout:create()
    self.sendcardContainer:setContentSize(cc.size(656,640))
    self.sendcardContainer:setPosition(cc.p(490,0))
    self.gameContainer:addChild(self.sendcardContainer)

    --结算layout
    self.gameResultLayer = require("landlordVideo.GameResultLayer").new()
    self.gameResultLayer:setVisible(false)
    self.gameContainer:addChild(self.gameResultLayer)

    --宠物
    local anchorPet = display.newSprite():addTo(self.gameContainer)
    anchorPet:setPosition(cc.p(550,340))
    anchorPet:setName("anchorPet")
    local animation = EffectFactory:getInstance():getEffectByName("zcm-dj-", 0.2, 1, 3)
    local action = cc.RepeatForever:create(cc.Animate:create(animation))
    anchorPet:runAction(action)
    --大动画位置
    local giftEffect = display.newSprite():addTo(self.gameContainer)
    giftEffect:setPosition(cc.p(770,380))
    giftEffect:setName("giftEffect")

    --视频区域
    self:createVideoContainer()
    
end

function LandlordVideoScene:initOtherPlayer()
    local otherPlayerPos = {
        {x=86,y=218},
        {x=271,y=200},
        {x=473,y=190},
        {x=673,y=190},
        {x=871,y=200},
        {x=1046,y=218},
    }
    self.otherPlayerLayer = ccui.Layout:create()
    self.otherPlayerLayer:setContentSize(cc.size(1136,640))
    self.gameContainer:addChild(self.otherPlayerLayer)
    for i = 1,6 do
        local playerInfoItem = ccui.ImageView:create("landlordVideo/playerInfoItemBg.png")
        playerInfoItem:setTouchEnabled(true)
        playerInfoItem:addTouchEventListener(function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                SoundManager.playSound("sound/buttonclick.mp3")
                local playerInfo = DataManager:getUserInfoInMyTableByChairID(self.visiablePlayer[i])
                self:showPlayerDetailInfo(playerInfo)
            end
        end)
        local itemWidth = playerInfoItem:getContentSize().width
        local itemHeight = playerInfoItem:getContentSize().height
        --昵称
        local nickName = ccui.Text:create()
        nickName:setPosition(cc.p(itemWidth / 2 ,itemHeight / 2 + 68))
        nickName:setFontSize(18)
        nickName:setName("nickName")
        playerInfoItem:addChild(nickName)
        --头像
        local headImage = ccui.ImageView:create()
        headImage:setName("headImage")
        headImage:setPosition(cc.p(itemWidth / 2,itemHeight / 2))
        playerInfoItem:addChild(headImage)
        --VIP
        local vipImage = ccui.ImageView:create()
        vipImage:setName("vipImage")
        vipImage:setPosition(cc.p(114,137))
        playerInfoItem:addChild(vipImage)
        --金币
        local goldImage = ccui.ImageView:create("common/gold.png")
        goldImage:setName("goldImage")
        goldImage:setScale(0.6)
        goldImage:setPosition(cc.p(19.5,itemHeight / 2 - 68))
        playerInfoItem:addChild(goldImage)
        local scoreLabel = ccui.Text:create()
        scoreLabel:setPosition(cc.p(37,itemHeight / 2 - 68))
        scoreLabel:setFontSize(18)
        scoreLabel:setAnchorPoint(cc.p(0,0.5))
        scoreLabel:setColor(cc.c3b(255,255,99))
        scoreLabel:setName("scoreLabel")
        playerInfoItem:addChild(scoreLabel)

        playerInfoItem:setName("playerInfo"..i)
        playerInfoItem:setPosition(cc.p(otherPlayerPos[i].x,otherPlayerPos[i].y))
        self.otherPlayerLayer:addChild(playerInfoItem)
    end
end



-- click event
function LandlordVideoScene:showPlayerDetailInfo(playerInfo)
    if self.playerDetailInfo == nil then
        self.playerDetailInfo = require("landlordVideo.PlayerDetailInfoLayer").new()
        self.playerDetailInfo:addEventListener(GameCenterEvent.EVENT_SEND_GIFT, handler(self, self.onSendProperty))
        self.gameContainer:addChild(self.playerDetailInfo)
    end
    if playerInfo ~= nil then
        self.playerDetailInfo:showPlayerDetailInfo(playerInfo)
    else
        self.playerDetailInfo:hide()
    end
    
end

function LandlordVideoScene:onClickMenu()
    if self.menuOpening == false then
        self.menuOpening = true
        self.menuButton:setVisible(false)
        local moveAction = cc.Sequence:create(
                        cc.EaseIn:create(cc.MoveBy:create(0.5, cc.p(-300,0)), 0.2),
                        cc.CallFunc:create(function() self.menuOpening = false end)
                    )
        self.menuLayer:runAction(moveAction)
    end
end

function LandlordVideoScene:onClickMenuClose()
    if self.menuOpening == false then
        self.menuOpening = true
        self.menuButton:setVisible(true)
        local moveAction = cc.Sequence:create(
                        cc.EaseOut:create(cc.MoveBy:create(0.5, cc.p(300,0)), 0.2),
                        cc.CallFunc:create(function() self.menuOpening = false end)
                    )
        self.menuLayer:runAction(moveAction)
    end
end

function LandlordVideoScene:onClickHelp()
    self:showHelpLayer()
end

function LandlordVideoScene:sendChatMessage(messageContent)
    print("sendChatMessage:",messageContent)
    -- TTCChat(messageContent)
end

function LandlordVideoScene:onVideoSeekToZero()
    IJKSeekToZero()
end

function LandlordVideoScene:onVideoTypeSelected()
    -- local result = TTCChangeMode()
    -- if result == 1 then
    --     self.videoTypeButton:loadTextures("landlordVideo/video_function_lighton.png","landlordVideo/video_function_lighton.png")
    --     TTCSetViewVisible(true)
    -- elseif result == 0 then
    --     self.videoTypeButton:loadTextures("landlordVideo/video_function_lightoff.png","landlordVideo/video_function_lightoff.png")
    --     TTCSetViewVisible(false)
    -- end
end

function LandlordVideoScene:onSendProperty(event)
    if self.giftInfoLayer == nil then
        self.giftInfoLayer = require("landlordVideo.GiftInfoLayer").new({sceneID=3})
        self.giftInfoLayer:addEventListener(GameCenterEvent.EVENT_BUY_PROPERTY, handler(self, self.sendGift))
        self.gameContainer:addChild(self.giftInfoLayer)
    end
    local targetUserID = event.targetUserID
    print("LandlordVideoScene...onSendProperty:",targetUserID)
    self.giftInfoLayer:showGiftInfoLayer(targetUserID)
end

function LandlordVideoScene:sendGift(event)
    self.giftInfoLayer:hide()
    local giftIndex = event.giftIndex
    local giftPrice = event.giftPrice
    local giftCount = event.giftCount
    local targetUserID = event.targetUserID

    local curTotalJettonScore = 0
    for i,v in pairs(self.myJettonScore) do
        curTotalJettonScore = curTotalJettonScore + v
    end
    if (curTotalJettonScore + giftPrice * giftCount) > self.lUserMaxScore then
        Hall.showTips("您的金币不足！", 1.0)
        return
    end
    local wMainID = CMD_GameServer.MDM_GR_USER
    local wSubID = CMD_GameServer.SUB_GR_PROPERTY_BUY

    local sendGift = protocol.hall.treasureInfo_pb.CMD_GR_C_PropertyBuy_Pro()
    sendGift.cbRequestArea = 1
    sendGift.cbConsumeScore = 1
    sendGift.wItemCount = giftCount
    sendGift.wPropertyIndex = giftIndex
    --主播的userID
    sendGift.dwTargetUserID = targetUserID

    local pData = sendGift:SerializeToString()
    local pDataLen = string.len(pData)

    GameCenter:sendData(wMainID,wSubID,pData,pDataLen)
end

function LandlordVideoScene:onSendGold()
    if self.goldInfoLayer == nil then
        self.goldInfoLayer = require("landlordVideo.GoldInfoLayer").new()
        self.goldInfoLayer:addEventListener(GameCenterEvent.EVENT_SEND_GOLD, handler(self, self.sendGold))
        self.gameContainer:addChild(self.goldInfoLayer)
    end
    self.goldInfoLayer:showGoldInfoLayer()
end

function LandlordVideoScene:sendGold(event)
    self.goldInfoLayer:hide()
    local gold = event.gold

    local curTotalJettonScore = 0
    for i,v in pairs(self.myJettonScore) do
        curTotalJettonScore = curTotalJettonScore + v
    end
    if (curTotalJettonScore + gold) > self.lUserMaxScore then
        Hall.showTips("您的金币不足！", 1.0)
        return
    end
    local wMainID = CMD_GameServer.MDM_GR_INSURE
    local wSubID = CMD_GameServer.SUB_GR_DASANG_VIP_SCORE_REQUEST

    local sendGold = protocol.hall.treasureInfo_pb.CMD_GP_C_DaSangVIPScoreRequest_Pro()
    sendGold.cbActivityGame = 1
    sendGold.cbByNickName = 0
    sendGold.lTransferScore = gold
    sendGold.szNickName = self:getCurAnchorNickName()
    sendGold.szInsurePass = GetDeviceID()
    sendGold.cbConsumeScore = 1
    --主播的userID
    sendGold.dwVIPUserID = self:getCurAnchorUserID()

    local pData = sendGold:SerializeToString()
    local pDataLen = string.len(pData)

    GameCenter:sendData(wMainID,wSubID,pData,pDataLen)
end

function LandlordVideoScene:showOtherPlayerList()
    if self.playerListLayer == nil then
        local PlayerListLayer = require("landlordVideo.PlayerListLayer")
        self.playerListLayer = PlayerListLayer.new()
        self.playerListLayer:addEventListener(GameCenterEvent.EVENT_SHOW_PLAYER_DETAIL, handler(self, self.onSelectPlayerInfo))
        self.gameContainer:addChild(self.playerListLayer)
    end
    local otherPlayerList = DataManager:getPlayerUserInMyTable()
    local otherPlayerWithoutTableUser = {}
    for key, var in ipairs(otherPlayerList) do
        if (self:getVisiablePlayerIndex(var.chairID) == 0) then
            table.insert(otherPlayerWithoutTableUser,table.maxn(otherPlayerWithoutTableUser) + 1,var)
        end
    end
    self.playerListLayer:showPlayerList(otherPlayerWithoutTableUser)
end

function LandlordVideoScene:onSelectPlayerInfo(event)
    local playerInfo = event.playerInfo
    if playerInfo ~= nil then
        self:showPlayerDetailInfo(playerInfo)
    end
end

function LandlordVideoScene:getVisiablePlayerIndex(wChairID)
    local visiableIndex = 0
    for k,v in pairs(self.visiablePlayer) do
        if wChairID == v then
            --可见的6个其他玩家下注
            visiableIndex = k
            break
        end
    end
    return visiableIndex
end

function LandlordVideoScene:onClickBack()
    print("LandlordVideoScene onClickBack!")
    self:showExitLayer()
end

function LandlordVideoScene:showExitLayer()
    if self.exitLayer == nil then
        local size = self.gameContainer:getContentSize()
        self.exitLayer = ccui.Layout:create()
        self.exitLayer:setContentSize(size)
        self.gameContainer:addChild(self.exitLayer)

        local winSize = cc.Director:getInstance():getWinSize()
        local contentSize = cc.size(1136,winSize.height)
        -- 蒙板
        local maskLayer = ccui.ImageView:create("blank.png")
        maskLayer:setScale9Enabled(true)
        maskLayer:setContentSize(contentSize)
        maskLayer:setPosition(cc.p(display.cx, display.cy));
        maskLayer:setTouchEnabled(true)
        self.exitLayer:addChild(maskLayer)
        local maskImg = ccui.ImageView:create("landlordVideo/video_mask.png")
        maskImg:setPosition(cc.p(757, winSize.height / 2));
        maskLayer:addChild(maskImg)

        local exitLayerBg = ccui.ImageView:create()
        exitLayerBg:loadTexture("common/pop_bg.png")
        exitLayerBg:setScale9Enabled(true)
        exitLayerBg:setContentSize(cc.size(600,433))
        exitLayerBg:setCapInsets(cc.rect(115,215,1,1))
        exitLayerBg:setPosition(cc.p(818,size.height/2))
        self.exitLayer:addChild(exitLayerBg)

        local title_text_bg = ccui.ImageView:create()
        title_text_bg:loadTexture("common/pop_title.png")
        title_text_bg:setAnchorPoint(cc.p(0,0.5))
        title_text_bg:setPosition(cc.p(42,388))
        exitLayerBg:addChild(title_text_bg)
        local title_text = ccui.Text:create("提示", FONT_ART_TEXT, 24)
        title_text:setColor(cc.c3b(255,233,110));
        title_text:enableOutline(cc.c4b(141,0,166,255*0.7),2);
        title_text:setPosition(cc.p(68,65));
        title_text:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER);
        title_text_bg:addChild(title_text);

        local exitTextPanel = ccui.ImageView:create("common/panel.png")
        exitTextPanel:setScale9Enabled(true)
        exitTextPanel:setContentSize(cc.size(500,180))
        exitTextPanel:setPosition(cc.p(300,250))
        exitLayerBg:addChild(exitTextPanel)

        local hintText = ccui.Text:create()
        hintText:setFontSize(26)
        hintText:setColor(cc.c3b(255,231,147))
        hintText:enableOutline(cc.c3b(0,0,0), 2)
        hintText:setPosition(cc.p(340,110))
        -- hintText:ignoreContentAdaptWithSize(false)
        hintText:setContentSize(cc.size(292,120))
        exitTextPanel:addChild(hintText)
        hintText:setString("    客观，留下再赢一次呗， \
主播MM不想让你离开哦！")

        local loadImg = ccui.ImageView:create("landlordVideo/video_landlord.png")
        loadImg:setPosition(cc.p(120,215))
        loadImg:setScale(0.8)
        exitLayerBg:addChild(loadImg)

        local leaveButton = ccui.Button:create("landlordVideo/video_bulebutton_bg.png");
        leaveButton:setScale9Enabled(true)
        leaveButton:setContentSize(cc.size(125, 67))
        leaveButton:setPosition(cc.p(200,90));
        leaveButton:setTitleFontName(FONT_ART_BUTTON);
        leaveButton:getTitleRenderer():enableOutline(COLOR_BTN_BLUE,2);
        leaveButton:setTitleText("离开");
        leaveButton:setTitleColor(cc.c3b(255,255,255));
        leaveButton:setTitleFontSize(28);
        exitLayerBg:addChild(leaveButton)
        leaveButton:setPressedActionEnabled(true);
        leaveButton:addTouchEventListener(
            function(sender,eventType)
                if eventType == ccui.TouchEventType.ended then
                    self.exitLayer:hide()
                    --站起
                    self._isLeaveType = 1

                    GameCenter:standUp(1);
                    GameCenter:closeRoomSocketDelay(3.0)

                    self:sceneBackToRoom()
                    --友盟视频场事件统计
                    onUmengEventEnd("1083")
                end
            end
        )

        local stayButton = ccui.Button:create("landlordVideo/video_greenbutton_bg.png");
        stayButton:setScale9Enabled(true)
        stayButton:setContentSize(cc.size(125, 67))
        stayButton:setPosition(cc.p(400,90));
        stayButton:setTitleFontName(FONT_ART_BUTTON);
        stayButton:getTitleRenderer():enableOutline(COLOR_BTN_GREEN,2);
        stayButton:setTitleText("留下");
        stayButton:setTitleColor(cc.c3b(255,255,255));
        stayButton:setTitleFontSize(28);
        exitLayerBg:addChild(stayButton)
        stayButton:setPressedActionEnabled(true);
        stayButton:addTouchEventListener(
            function(sender,eventType)
                if eventType == ccui.TouchEventType.ended then
                    self.exitLayer:hide()
                end
            end
        )
        
    end
    self.exitLayer:show()
end

function LandlordVideoScene:onJettonButtonSelected(index)
    self.curSelectJettonButton = index
    for i=1,4 do
        local jettonButton = self.jettonAreaLayer:getChildByTag(i)
        local jettonSelected = jettonButton:getChildByName("JettonSelected")
        jettonSelected:setVisible(false)
    end
    local jettonButton = self.jettonAreaLayer:getChildByTag(index)
    if jettonButton then
        local jettonSelected = jettonButton:getChildByName("JettonSelected")
        jettonSelected:setVisible(true)
        local action = cc.RepeatForever:create(cc.RotateBy:create(0.2, 20)) 
        jettonSelected:runAction(action)
    end
end

function LandlordVideoScene:onReJetton()
    print("LandlordVideoScene onReJetton!")
    self:enableRejettonButton(false)
    self:enableDoubleButton(false)
    self.reJetton = true
    --发送重复下注
    for k,v in pairs(self.reJettonArr) do
        self:sendJettonScore(k-1, v)
    end
end

function LandlordVideoScene:onDoubleJetton()
    print("LandlordVideoScene onDoubleJetton!")
    self:enableRejettonButton(false)
    self:enableDoubleButton(false)
    self.reJetton = true
    --发送加倍下注
    for k,v in pairs(self.reJettonArr) do
        self:sendJettonScore(k-1, v * 2)
    end
end

function LandlordVideoScene:onJettonAreaClick(index)
    if self.curSelectJettonButton > 0 and self.curSelectJettonButton <= table.maxn(self.jettonScoreArr) then
        local score = self.jettonScoreArr[self.curSelectJettonButton]
        self:sendJettonScore(index-1, score)
    else
        Hall.showTips("您的筹码不足！", 1.0)
    end
end

function LandlordVideoScene:sendJettonScore(area,score)
    local wMainID = CMD_GameServer.MDM_GF_GAME
    local wSubID = LandlordVideoCmd.SUB_C_PLACE_JETTON

    local addScore = protocol.game.battleDoudizhu.battleDoudizhu_pb.CMD_C_PlaceJetton_Pro()
    addScore.cbJettonArea = area
    addScore.lJettonScore = score

    local pData = addScore:SerializeToString()
    local pDataLen = string.len(pData)

    GameCenter:sendData(wMainID,wSubID,pData,pDataLen)
end

-- animation
function LandlordVideoScene:sendCard()

    local cardPosition = {
        {280,500},
        {280,330}
    }
    for i=1,2 do
        local cardNum = self.tableCardArray[i];
        local kind = math.floor( cardNum / 0x10 );
        local num = cardNum % 0x10;

        local card = display.newSprite("card/kb_0_0.png")
        card:setPosition(cc.p(328,300))
        card:setName("Card"..i)
        card:setScale(0.33)
        card:setOpacity(0)
        self.sendcardContainer:addChild(card)

        local action1 = cc.MoveTo:create(0.5,cc.p(cardPosition[i][1], cardPosition[i][2]))
        local action2 = cc.ScaleTo:create(0.5,1)
        local action3 = cc.FadeIn:create(0.5)
        local action4 = cc.CallFunc:create(function() SoundManager.playSound("sound/outcard.mp3") end)
        local sequence = cc.Spawn:create(cc.EaseOut:create(action1,3),action2,action3,action4)

        local changeCard = cc.CallFunc:create(
            function()
                local filename = "card/kb_"..kind.."_"..num..".png";
                local sprite = display.newSprite(filename);
                local frame = cc.SpriteFrame:create(filename, sprite:getTextureRect());
                card:setSpriteFrame(frame);
            end
        );
        local showPoint = cc.CallFunc:create(
            function()
                local cardPoint = display.newBMFontLabel({
                    text = num.."点",
                    font = "fonts/paishuzi.fnt",
                    x = card:getContentSize().width/2,
                    y = card:getContentSize().height + 30,
                })
                card:addChild(cardPoint)
            end
        );
        local sequence1 = transition.sequence(
                        {
                            cc.DelayTime:create(0.1),
                            cc.OrbitCamera:create(0.3, 1.0, 0, 0, 90, 0, 0),
                            changeCard,
                            cc.OrbitCamera:create(0.3, 1.0, 0, -90, 90, 0, 0),
                            showPoint
                        }
                    )
        local animEnd = cc.CallFunc:create(
            function()
                if i == 2 then
                    self:showGameResult()
                end
            end
        );
        card:runAction(cc.Sequence:create(cc.DelayTime:create(i * 0.5),sequence,sequence1,cc.DelayTime:create(0.5),animEnd))
    end
end

function LandlordVideoScene:flyGold(startIndex,targetArea,score)
    local jettonArea = self.gameContainer:getChildByTag(500+targetArea+1)
    local goldArea = jettonArea:getChildByTag(4)
    -- 随即飞出去金币的位置
    local x = math.random(goldArea:getContentSize().width * 0.05,goldArea:getContentSize().width*0.7)
    local y = math.random(goldArea:getContentSize().height * 0.2,goldArea:getContentSize().height*0.7)
    if (targetArea + 1) == 2 then
        x = math.random(goldArea:getContentSize().width * 0.2,goldArea:getContentSize().width*0.9)
        y = math.random(goldArea:getContentSize().height * 0.25,goldArea:getContentSize().height*0.75)
    end
    local actionGoldFly = cc.MoveTo:create(0.3,cc.p(x,y))
    local action1 = cc.MoveBy:create(0.1,cc.p(0,20))
    local action2 = action1:reverse()
    local acitionHead = cc.Sequence:create(action1,action2)

    local headTarget = nil
    local goldTarget = nil
    if startIndex == 7 then
        --自己
        headTarget = self.selfHeadBorder
    elseif startIndex == 8 then
        headTarget = self.showOtherPlayerButton
    else
        headTarget = self.otherPlayerLayer:getChildByName("playerInfo"..startIndex)
    end

    local headWorldPosition = headTarget:getParent():convertToWorldSpace(cc.p(headTarget:getPositionX(),headTarget:getPositionY()))
    local thisPosition = goldArea:convertToNodeSpace(cc.p(headWorldPosition.x,headWorldPosition.y))

    self.targetJettonCount[targetArea + 1] = self.targetJettonCount[targetArea + 1] or 0
    self.targetJettonCount[targetArea + 1] = self.targetJettonCount[targetArea + 1] + 1
    local goldTag = startIndex * 1000 + self.targetJettonCount[targetArea + 1]
    goldTarget = ccui.ImageView:create()
    goldTarget:setTag(goldTag)
    goldTarget:loadTexture("common/gold.png")
    goldTarget:setScale(0.6)
    goldTarget:setPosition(cc.p(thisPosition.x,thisPosition.y))
    goldArea:addChild(goldTarget)

    if startIndex ~= 8 then
        headTarget:runAction(acitionHead)
    end
    goldTarget:runAction(actionGoldFly)
    SoundManager.playSound("sound/bet.mp3")
end

function LandlordVideoScene:showDispatchGoldAnimation()
    for i=1,3 do
        if (self.curGameResult + 1) == i then
            self:dispatchResultGold(i,false)
        else
            if self.curGameResult == 1 then
                self:dispatchResultGold(i,false)
            else
                self:dispatchResultGold(i,true)
            end
        end
    end
end

function LandlordVideoScene:dispatchResultGold(dispatchArea,flyToBank)
    local jettonArea = self.gameContainer:getChildByTag(500 + dispatchArea)
    local goldArea = jettonArea:getChildByTag(4)
    for i,child in ipairs(goldArea:getChildren()) do
        local childTag = child:getTag()
        local dispatchGoldRecord = {
            dispatchArea = dispatchArea,
            goldTag = childTag,
            flyToBank = flyToBank
        }
        table.insert(self.dispatchGoldRecordArr, dispatchGoldRecord)
    end
end

function LandlordVideoScene:dispatchGold(dispatchArea,goldTag,flyToBank)
    local jettonArea = self.gameContainer:getChildByTag(500 + dispatchArea)
    local goldArea = jettonArea:getChildByTag(4)
    local child = goldArea:getChildByTag(goldTag)
    if child then
        local childTag = child:getTag()
        local targetLayer = nil
        if flyToBank then
            targetLayer = self.bankLayer
        else
            local startIndex = math.floor(childTag / 1000)
            if startIndex == 7 then
                --自己
                targetLayer = self.selfHeadBorder
            elseif startIndex == 8 then
                targetLayer = self.showOtherPlayerButton
            else
                targetLayer = self.otherPlayerLayer:getChildByName("playerInfo"..startIndex)
            end
        end

        local targetWorldPosition = targetLayer:getParent():convertToWorldSpace(cc.p(targetLayer:getPositionX(),targetLayer:getPositionY()))
        local thisPosition = goldArea:convertToNodeSpace(cc.p(targetWorldPosition.x,targetWorldPosition.y))

        --飞金币
        local callfunc = cc.CallFunc:create(function()
            child:removeFromParent()
            if flyToBank then
                return
            end
            local startIndex = math.floor(childTag / 1000)
            if startIndex == 7 then
                -- 特效
                local vipJiesuanArmature = EffectFactory:getInstance():getVipJiesuanArmature()
                vipJiesuanArmature:setAnchorPoint(cc.p(0.5,0.5))
                vipJiesuanArmature:setPosition(cc.p(targetLayer:getContentSize().width/2-6,targetLayer:getContentSize().height/2))
                targetLayer:addChild(vipJiesuanArmature)
                if vipJiesuanArmature then
                    vipJiesuanArmature:getAnimation():setFrameEventCallFunc(function(bone,evt,originFrameIndex,currentFrameIndex)
                            if evt == "end" then
                                vipJiesuanArmature:removeFromParent()
                            end
                        end)
                    vipJiesuanArmature:getAnimation():playWithIndex(1)
                end
            elseif startIndex == 8 then
                
            else
                local vipJiesuanArmature = EffectFactory:getInstance():getVipJiesuanArmature()
                vipJiesuanArmature:setAnchorPoint(cc.p(0.5,0.5))
                vipJiesuanArmature:setPosition(cc.p(targetLayer:getContentSize().width/2,targetLayer:getContentSize().height/2))
                targetLayer:addChild(vipJiesuanArmature)
                if vipJiesuanArmature then
                    vipJiesuanArmature:getAnimation():setFrameEventCallFunc(function(bone,evt,originFrameIndex,currentFrameIndex)
                            if evt == "end" then
                                vipJiesuanArmature:removeFromParent()
                            end
                        end)
                    vipJiesuanArmature:getAnimation():playWithIndex(0)
                end
            end
        end);
        local actionGoldFly = cc.Sequence:create(cc.MoveTo:create(0.3,cc.p(thisPosition.x,thisPosition.y)),callfunc) 
        child:runAction(actionGoldFly)
        -- SoundManager.playSound("sound/bet.mp3")
    end
end

-- refresh view
function LandlordVideoScene:updateSelfScore()
    -- 筹码
    self.goldLabel:setString(FormatDigitToString(self.lUserMaxScore - self.myTotalJettonScoreForShow,1))
end

function LandlordVideoScene:refreshSelfInfo()
    self.userInfo = DataManager:getMyUserInfo()
    -- 自己的头像设置
    local headImage = self.selfHeadBorder:getChildByName("HeadImage")
    if self.userInfo.faceID >= 1 and self.userInfo.faceID <= 37 then
        headImage:loadTexture("head/head_"..self.userInfo.faceID..".png")
    elseif self.userInfo.faceID == 999 then
        local tokenID = self.userInfo.platformID;    
        headImage:loadTexture(RunTimeData:getLocalAvatarImageUrlByTokenID(tokenID))
    else
        headImage:loadTexture("head/default.png")
    end
    
    --vip
    local vipImage = self.selfHeadBorder:getChildByName("VipImage")
    if OnlineConfig_review == "on" then
        vipImage:setVisible(false)
    else
        if self.userInfo.memberOrder >= 1 and self.userInfo.memberOrder <= 5 then
            vipImage:setVisible(true)
            vipImage:loadTexture("hall/shop/zuan"..self.userInfo.memberOrder..".png")
        else
            vipImage:setVisible(false)
        end
    end
    -- 昵称
    self.nickNameLabel:setString(FormotGameNickName(self.userInfo.nickName, 5) )
    -- 筹码
    self.goldLabel:setString(FormatDigitToString(self.userInfo.score,1))
end


function LandlordVideoScene:refreshOtherPlayerInfo()
    cleanTable(self.visiablePlayer)
    local otherPlayerArr = DataManager:getPlayerUserInMyTable()
    local otherPlayerCount = table.maxn(otherPlayerArr)
    for i = 1,6 do
        local playerInfoItem = self.otherPlayerLayer:getChildByName("playerInfo"..i)
        if i > otherPlayerCount then
            playerInfoItem:setVisible(false)
        else
            playerInfoItem:setVisible(true)
            local otherPlayerInfo = otherPlayerArr[i]
            local otherPlayerInfo = otherPlayerArr[i]
            self.visiablePlayer[i] = otherPlayerInfo.chairID
            if otherPlayerInfo.chairID == DataManager:getMyChairID() then
                playerInfoItem:loadTexture("landlordVideo/playerInfoItemBgSelf.png")
            else
                playerInfoItem:loadTexture("landlordVideo/playerInfoItemBg.png")
            end
            local itemWidth = playerInfoItem:getContentSize().width
            local itemHeight = playerInfoItem:getContentSize().height
            --昵称
            local nickName = playerInfoItem:getChildByName("nickName")
            nickName:setPosition(cc.p(itemWidth / 2 ,itemHeight / 2 + 68))
            nickName:setString(FormotGameNickName(otherDataManager.nickName, 5))
            --头像
            local headImage = playerInfoItem:getChildByName("headImage")
            if otherPlayerInfo.faceID >= 1 and otherPlayerInfo.faceID <= 37 then
                headImage:loadTexture("head/head_"..otherPlayerInfo.faceID..".png")
            elseif otherPlayerInfo.faceID == 999 then
                local tokenID = otherDataManager.platformID
                local url = RunTimeData:getLocalAvatarImageUrlByTokenID(tokenID)
                local md5 = otherDataManager.platformFace
                local localmd5 = cc.Crypto:MD5File(url)
                print("localmd5,md5",localmd5,md5)
                if localmd5 ~= md5 then
                    PlatformDownloadAvatarImage(tokenID, md5)
                else    
                    headImage:loadTexture(RunTimeData:getLocalAvatarImageUrlByTokenID(tokenID))
                end
            else
                headImage:loadTexture("head/default.png")
            end

            if otherPlayerInfo.chairID == DataManager:getMyChairID() then
                headImage:setPosition(cc.p(itemWidth / 2,itemHeight / 2))
            end
            --VIP
            local vipImage = playerInfoItem:getChildByName("vipImage")
            if OnlineConfig_review == "on" then
                vipImage:setVisible(false)
            else
                if otherPlayerInfo.memberOrder >= 1 and otherPlayerInfo.memberOrder <= 5 then
                    vipImage:setVisible(true)
                    vipImage:loadTexture("hall/shop/zuan"..otherPlayerInfo.memberOrder..".png")
                else
                    vipImage:setVisible(false)
                end
            end
            --金币
            local goldImage = playerInfoItem:getChildByName("goldImage")
            goldImage:setPosition(cc.p(19.5,itemHeight / 2 - 68))
            local scoreLabel = playerInfoItem:getChildByName("scoreLabel")
            scoreLabel:setPosition(cc.p(37,itemHeight / 2 - 68))
            scoreLabel:setString(FormatDigitToString(otherPlayerInfo.score, 1))
        end
    end
end

function LandlordVideoScene:resetJettonScoreArr(userScore,enable)
    if userScore < 100000 then
        self.jettonScoreArr = {100,500,1000,5000}   -- 修改按钮下注按钮显示的金额
    else
        local max = math.pow(10, string.len(userScore)-1)
        self.jettonScoreArr = {max/100, max/20, max/10, max/2}   -- 修改按钮下注按钮显示的金额
    end
    self:refreshJettonButtonScore()
    for i=1,4 do
        self:enableJettonButton(enable,i)
    end
end

function LandlordVideoScene:refreshJettonButtonScore()
    for i=1,4 do
        local jettonButton = self.jettonAreaLayer:getChildByTag(i)
        local jettonLabel = jettonButton:getChildByName("JettonValue")
        jettonLabel:setString(FormatDigitToString(self.jettonScoreArr[i], 0))
    end
end 

function LandlordVideoScene:checkJettonButtonStatus(userScore)
    local curTotalJettonScore = 0
    for i,v in pairs(self.myJettonScore) do
        curTotalJettonScore = curTotalJettonScore + v
    end
    local canJettonIndex = 0
    for i=1,4 do
        if (curTotalJettonScore + self.jettonScoreArr[i]) > userScore then
            self:enableJettonButton(false,i)
        else
            self:enableJettonButton(true,i)
            canJettonIndex = i
        end
    end
    if self.curSelectJettonButton == 0 then
        self:onJettonButtonSelected(canJettonIndex)
    end
    if self.curSelectJettonButton > canJettonIndex then
        self:onJettonButtonSelected(canJettonIndex)
    end

    if table.maxn(self.reJettonArr) == 0 then
        self:enableRejettonButton(false)
        self:enableDoubleButton(false)
    else
        local reJettonTotalScore = 0
        for i,v in pairs(self.reJettonArr) do
            reJettonTotalScore = reJettonTotalScore + v
        end
        if self.reJetton then
            self:enableRejettonButton(false)
            self:enableDoubleButton(false)
        else
            if reJettonTotalScore + curTotalJettonScore > userScore then
                self:enableRejettonButton(false)
            else
                self:enableRejettonButton(true)
            end
            if reJettonTotalScore * 2 + curTotalJettonScore > userScore then
                self:enableDoubleButton(false)
            else
                self:enableDoubleButton(true)
            end
        end
    end
end

function LandlordVideoScene:enableJettonArea(enable)
    for i=1,3 do
        local jettonArea = self.gameContainer:getChildByTag(500+i)
        -- local jettonArea = cc.LayerColor:create(cc.c4b(200,0,0,255))
        -- jettonArea:setTag(500+i)
        jettonArea:setTouchEnabled(enable)

        local pointPressedImg = jettonArea:getChildByName("pointPressedImg")
        if enable == false then
            pointPressedImg:setVisible(false)
        end
    end
end

function LandlordVideoScene:enableRejettonButton(enable)
    local opacity = 255
    if enable == false then
        opacity = 153
    end
    self.rejettonButton:setTouchEnabled(enable)
    self.rejettonButton:setOpacity(opacity)
end

function LandlordVideoScene:enableDoubleButton(enable)
    local opacity = 255
    if enable == false then
        opacity = 153
    end
    self.doubleButton:setTouchEnabled(enable)
    self.doubleButton:setOpacity(opacity)
end

function LandlordVideoScene:enableJettonButton(enable,buttonIndex)
    local opacity = 255
    if enable == false then
        opacity = 153
    end
    local jettonButton = self.jettonAreaLayer:getChildByTag(buttonIndex)
    jettonButton:setTouchEnabled(enable)
    jettonButton:setOpacity(opacity)
end

function LandlordVideoScene:showGameResult()
    --下注区域亮一下
    local jettonArea = self.gameContainer:getChildByTag(500+self.curGameResult+1)
    local winResultImg = jettonArea:getChildByName("winResultImg")
    local acitionResult = cc.Sequence:create(cc.Show:create(),cc.DelayTime:create(2),cc.Hide:create())
    winResultImg:runAction(acitionResult)


    self:showDispatchGoldAnimation()

    self.myTotalJettonScoreForShow = 0
    self:updateSelfScore()

    --showgameresult
    self.gameResultLayer:showGameResult(self.curGameResult,self.curUserScore)

end

-- game logic
function LandlordVideoScene:onReceiveGameMessage(event)
    -- print("onReceiveGameMessage:",event.subId)
    if(event.subId == LandlordVideoCmd.SUB_S_GAME_FREE) then-- 游戏空闲
        -- print("游戏空闲")
        self:onGameFree(event.data)
    elseif(event.subId == LandlordVideoCmd.SUB_S_GAME_START) then --游戏开始
        -- print("游戏开始")
        self:onGameStart(event.data)
    elseif(event.subId == LandlordVideoCmd.SUB_S_PLACE_JETTON) then --用户下注
        -- print("用户下注")
        self:onPlaceJetton(event.data)
    elseif(event.subId == LandlordVideoCmd.SUB_S_GAME_END) then --游戏结束
        -- print("游戏结束")
        self:onGameEnd(event.data)
    elseif(event.subId == LandlordVideoCmd.SUB_S_APPLY_BANKER) then --申请庄家
        -- print("申请庄家")
        self:onApplyBanker(event.data)
    elseif(event.subId == LandlordVideoCmd.SUB_S_CHANGE_BANKER) then --切换庄家
        -- print("切换庄家")
        self:onChangeBanker(event.data)
    elseif(event.subId == LandlordVideoCmd.SUB_S_CHANGE_USER_SCORE) then --更新积分
        -- print("更新积分")
        self:onChangeUserScore(event.data)
    elseif(event.subId == LandlordVideoCmd.SUB_S_SEND_RECORD) then --游戏记录
        -- print("游戏记录")
        self:onReceiveRecord(event.data)
    elseif(event.subId == LandlordVideoCmd.SUB_S_PLACE_JETTON_FAIL) then --下注失败
        -- print("下注失败")
        self:onPlaceJettonFail(event.data)
    elseif(event.subId == LandlordVideoCmd.SUB_S_CANCEL_BANKER) then --取消申请庄家
        -- print("取消申请庄家")
        self:onCancelBanker(event.data)
    elseif(event.subId == LandlordVideoCmd.SUB_S_SEND_USERS_SCORE_RESULT) then --每个玩家输赢记录
        -- print("每个玩家输赢记录")
        self:onReceiveUserScoreResult(event.data)
    else
        print("未处理的命令：",event.subId)
    end
end

function LandlordVideoScene:onGameFree(pData)
    local gameFree = protocol.game.battleDoudizhu.battleDoudizhu_pb.CMD_S_GameFree_Pro()
    gameFree:ParseFromString(pData)
    local cbTimeLeave = gameFree.cbTimeLeave                      --剩余时间
    self.clock:startTimer(cbTimeLeave, nil)
    --清理
    self:resetAllData()
end

function LandlordVideoScene:onGameStart(pData)
    SoundManager.playSound("sound/Hundred_Start_01.wav")
    local gameStart = protocol.game.battleDoudizhu.battleDoudizhu_pb.CMD_S_GameStart_Pro()
    gameStart:ParseFromString(pData)
    local wBankerUser = gameStart.wBankerUser
    local lBankerScore = gameStart.lBankerScore
    self.lUserMaxScore = gameStart.lUserMaxScore
    local nChipRobotCount = gameStart.nChipRobotCount
    local cbTimeLeave = gameStart.cbTimeLeave                      --剩余时间
    self.clock:startTimer(cbTimeLeave, nil, true, 3)

    --更新下注区域状态
    self:resetJettonScoreArr(self.lUserMaxScore,true)
    self:checkJettonButtonStatus(self.lUserMaxScore)
    self:enableJettonArea(true)
    --更新其他玩家信息
    self:refreshOtherPlayerInfo()

    self:showStatusHint(true)
    SoundManager.playSound("sound/Hundred_Start_02.wav")
end

function LandlordVideoScene:onPlaceJetton(pData)
    local placeJetton = protocol.game.battleDoudizhu.battleDoudizhu_pb.CMD_S_PlaceJetton_Pro()
    placeJetton:ParseFromString(pData)
    local wChairID = placeJetton.wChairID
    local cbJettonArea = placeJetton.cbJettonArea
    local lJettonScore = placeJetton.lJettonScore
    local cbAndroid = placeJetton.cbAndroid
    local jettonArea = self.gameContainer:getChildByTag(500 + cbJettonArea + 1)
    local flyGoldStartIndex = 0
    if wChairID == DataManager:getMyChairID() then
        --自己下注
        flyGoldStartIndex = 7
        --更新下注信息
        local myJettonScore = jettonArea:getChildByTag(2)
        if self.myJettonScore[cbJettonArea+1] == nil then
            self.myJettonScore[cbJettonArea+1] = 0
            myJettonScore:setVisible(true)
        end
        self.myJettonScore[cbJettonArea+1] = self.myJettonScore[cbJettonArea+1] + lJettonScore
        myJettonScore:setString(FormatDigitToString(self.myJettonScore[cbJettonArea+1], 1))
        self:checkJettonButtonStatus(self.lUserMaxScore)
        self.myTotalJettonScoreForShow = self.myTotalJettonScoreForShow + lJettonScore
        self:updateSelfScore()
    else
        --不可见的其他玩家下注
        flyGoldStartIndex = 8
        --其他玩家
        for k,v in pairs(self.visiablePlayer) do
            if wChairID == v then
                --可见的6个其他玩家下注
                flyGoldStartIndex = k
                break
            end
        end
    end
    local totalJettonScore = jettonArea:getChildByTag(1)
    if self.totalJettonScore[cbJettonArea+1] == nil then
        self.totalJettonScore[cbJettonArea+1] = 0
        totalJettonScore:setVisible(true)
    end
    self.totalJettonScore[cbJettonArea+1] = self.totalJettonScore[cbJettonArea+1] + lJettonScore
    totalJettonScore:setString(FormatDigitToString(self.totalJettonScore[cbJettonArea+1], 1) )

    local jettonGoldRecord = {
        startIndex = flyGoldStartIndex,
        jettonArea = cbJettonArea,
        jettonScore = lJettonScore
    }
    table.insert(self.jettonGoldRecordArr, jettonGoldRecord)
    -- self:flyGold(flyGoldStartIndex, cbJettonArea, lJettonScore)
end

function LandlordVideoScene:onGameEnd(pData)
    SoundManager.playSound("sound/Hundred_Push_End.wav")
    local gameEnd= protocol.game.battleDoudizhu.battleDoudizhu_pb.CMD_S_GameEnd_Pro()
    gameEnd:ParseFromString(pData)

    local cbTimeLeave = gameEnd.cbTimeLeave                      --剩余时间
    self.clock:startTimer(cbTimeLeave, nil)

    -- 解析扑克牌
    for i, cardData in ipairs(gameEnd.cbTableCardArray) do
        self.tableCardArray[i] = cardData
    end

    local lBankerScore = gameEnd.lBankerScore                         --庄家成绩
    local lBankerTotallScore = gameEnd.lBankerTotallScore                  --庄家成绩
    local nBankerTime = gameEnd.lBankerTime                          --做庄次数
    --玩家成绩
    self.curUserScore = gameEnd.lUserScore                           --玩家成绩
    local lUserReturnScore = gameEnd.lUserReturnScore                      --返回积分
    --全局信息
    local lRevenue = gameEnd.lRevenue                              --游戏税收

    --本局输赢情况 0，1，2 地主 平 农民
    self.curGameResult = gameEnd.stNowRecord
    self:appendGameRecord(gameEnd.stNowRecord)
    self.lUserMaxScore = self.lUserMaxScore + gameEnd.lUserScore

    --UI更新
    --更新下注区域状态
    self:resetJettonScoreArr(self.lUserMaxScore,false)
    self:onJettonButtonSelected(0)
    self:enableJettonArea(false)
    self:enableRejettonButton(false)
    self:enableDoubleButton(false)
    -- 开始发牌
    self:showStatusHint(false)
    self:sendCard()
end

function LandlordVideoScene:onApplyBanker(pData)
    print("onApplyBanker!")
end

function LandlordVideoScene:onChangeBanker(pData)
    print("onChangeBanker!")
end

function LandlordVideoScene:onChangeUserScore(pData)
    print("onChangeUserScore!")
end

function LandlordVideoScene:onReceiveRecord(pData)
    local gameRecord = protocol.game.battleDoudizhu.battleDoudizhu_pb.CMD_S_SendRecord_Pro()
    gameRecord:ParseFromString(pData)
    if gameRecord.cbResult == nil then
        return
    end
    if self.gameRecord ~= nil and #self.gameRecord > 15 then
        return
    end
    self.gameRecord = copyProtoTable(gameRecord.cbResult)
    self.roomChangeButton:updateGameRecord(gameRecord.cbResult)
end

function LandlordVideoScene:appendGameRecord(curGameRecord)
    local recordCount = #self.gameRecord
    if recordCount >=41 then
        for i=1,6 do
            table.remove(self.gameRecord,1)
        end
    else
        table.insert(self.gameRecord, curGameRecord)
    end
    self.roomChangeButton:updateGameRecord(self.gameRecord)
end

function LandlordVideoScene:onPlaceJettonFail(pData)
    local jettonFail = protocol.game.battleDoudizhu.battleDoudizhu_pb.CMD_S_PlaceJettonFail_Pro()
    jettonFail:ParseFromString(pData)
    local wPlaceuser = jettonFail.wPlaceuser
    local lJettonArea = jettonFail.lJettonArea
    local lPlaceScore = jettonFail.lPlaceScore
    print("onPlaceJettonFail:",wPlaceuser,lJettonArea,lPlaceScore)
end

function LandlordVideoScene:onCancelBanker(pData)
    print("onCancelBanker!")
end

function LandlordVideoScene:onReceiveUserScoreResult(pData)

end

function LandlordVideoScene:onProcessGameScene(event)
    local status = GameCenter._gameStatus
    if(status == LandlordVideoGameStatus.GAME_SCENE_FREE) then -- 空闲
        self:processGameSceneFree(event.data)
    elseif(status== LandlordVideoGameStatus.GAME_SCENE_PLACE_JETTON) then -- 下注
        self:processGameScenePlay(event.data)
    elseif(status == LandlordVideoGameStatus.GAME_SCENE_GAME_END) then -- 结算 
        self:processGameScenePlay(event.data)
    end
    --更新其他玩家信息
    self:refreshOtherPlayerInfo()
    --刷新魅力排行
    self:requestVipLoveOrder(1)
    self:requestVipLoveOrder(2)
    self:requestVipLoveOrder(3)
end

function LandlordVideoScene:processGameSceneFree(pData)
    local gameSceneFree = protocol.game.battleDoudizhu.battleDoudizhu_pb.CMD_S_StatusFree_Pro()
    gameSceneFree:ParseFromString(pData)
    --全局信息
    local cbTimeLeave = gameSceneFree.cbTimeLeave                     --剩余时间
    self.clock:startTimer(cbTimeLeave, nil)
    --玩家信息
    self.lUserMaxScore = gameSceneFree.lUserMaxScore                        --玩家金币
    
    --房间信息
    self.szGameRoomName = gameSceneFree.szGameRoomName          --房间名称

    self:refreshSelfInfo()
    --更新下注区域状态
    self:resetJettonScoreArr(self.lUserMaxScore,false)
    self:onJettonButtonSelected(0)
    self:enableRejettonButton(false)
    self:enableDoubleButton(false)
    self:enableJettonArea(false)
end

function LandlordVideoScene:processGameScenePlay(pData)
    local gameScenePlay = protocol.game.battleDoudizhu.battleDoudizhu_pb.CMD_S_StatusPlay_Pro()
    gameScenePlay:ParseFromString(pData)

    --房间信息
    self.szGameRoomName = gameScenePlay.szGameRoomName          --房间名称
    --玩家信息
    self.lUserMaxScore = gameScenePlay.lUserMaxScore

    -- 全局下注信息
    for i, score in ipairs(gameScenePlay.lAreaInAllScore) do
        local jettonArea = self.gameContainer:getChildByTag(500 + i)
        local totalJettonScore = jettonArea:getChildByTag(1)
        if score > 0 then
            totalJettonScore:setString(FormatDigitToString(score, 1) )
            totalJettonScore:setVisible(true)
            self.totalJettonScore[i]=score
        end
    end

    for i, score in ipairs(gameScenePlay.lUserInAllScore) do
        local jettonArea = self.gameContainer:getChildByTag(500 + i)
        local myJettonScore = jettonArea:getChildByTag(2)
        if score > 0 then
            myJettonScore:setVisible(true)
            myJettonScore:setString(FormatDigitToString(score, 1))
            self.myJettonScore[i]=score
        end
    end

    local cbTimeLeave = gameScenePlay.cbTimeLeave
    self.clock:startTimer(cbTimeLeave, nil)
    if(gameScenePlay.cbGameStatus == LandlordVideoGameStatus.GAME_SCENE_PLACE_JETTON) then
        -- 如果是下注阶段

        --更新下注区域状态
        self:resetJettonScoreArr(self.lUserMaxScore,true)
        self:checkJettonButtonStatus(self.lUserMaxScore)
        self:enableJettonArea(true)
    else
        -- 结束信息
        local lEndBankerScore = gameScenePlay.lEndBankerScore                        --庄家成绩
        --玩家成绩
        local lEndUserScore = gameScenePlay.lEndUserScore                          --玩家成绩
        local lUserReturnScore = gameScenePlay.lEndUserReturnScore                    --返回积分
        local lRevenue = gameScenePlay.lEndRevenue                            --游戏税收
        -- 扑克牌
        for i, cardData in ipairs(gameScenePlay.cbTableCardArray) do
            -- print("cbTableCardArray:",i,cardData)
        end
        for i, cardData in ipairs(gameScenePlay.cbCardCount) do
            -- print("cbCardCount:",i,cardData)
        end
        --更新下注区域状态
        self:resetJettonScoreArr(self.lUserMaxScore,false)
        self:onJettonButtonSelected(0)
        self:enableRejettonButton(false)
        self:enableDoubleButton(false)
        self:enableJettonArea(false)
    end

    self:refreshSelfInfo()

end

-- scene event
function LandlordVideoScene:showRoomChangeLayer()
    if self.roomChangeLayer == nil then
        local RoomChangeLayer = require("landlordVideo.RoomChangeLayer")
        self.roomChangeLayer = RoomChangeLayer.new()
        self.gameContainer:addChild(self.roomChangeLayer)
    end
    self.roomChangeLayer:showRoomListLayer(self:getCurAnchorNickName(),self.gameRecord)
end

function LandlordVideoScene:changeGameRoom(event)
    self.nextRoomIndex = event.index
    self._isLeaveType = 2
    GameCenter:standUp(1);
    GameCenter:closeRoomSocketDelay(3.0)
    self.anchorChangeLayer:hide()

    --退订房间
    local curGameServer = RunTimeData:getCurGameServer()
    local anchorRoomID = VideoAnchorManager:getAnchorRoomID(curGameServer:getServerID())
    unSubScribeAnchorRoom(anchorRoomID)
end

function LandlordVideoScene:onReceiveBattleRecord(event)
    local battleRecord = event.pData
    cleanTable(self.battleRecord)
    self.battleRecord = copyProtoTable(battleRecord)
end

function LandlordVideoScene:showAnchorChangeLayer()
    if self.anchorChangeLayer == nil then
        local AnchorChangeLayer = require("landlordVideo.AnchorChangeLayer")
        self.anchorChangeLayer = AnchorChangeLayer.new()
        self.anchorChangeLayer:addEventListener(LandlordEvent.CHANGE_VIDEO_GAMEROOM, handler(self, self.changeGameRoom))
        self.gameContainer:addChild(self.anchorChangeLayer)
    end
    self.anchorChangeLayer:showAnchorListLayer()
end

function LandlordVideoScene:showFansRankLayer()
    if self.fansRankLayer == nil then
        self.fansRankLayer = require("landlordVideo.FansRankLayer").new()
        self.gameContainer:addChild(self.fansRankLayer)
    end
    self.fansRankLayer:showFansRankLayer()
end

function LandlordVideoScene:onQueryUserInsure(event)
    print("onQueryUserInsure!!")
    self.lUserMaxScore = event.score
    self:updateSelfScore()
end

function LandlordVideoScene:onUserMessage(event)
    local msgContent = {}
    local msg = nil
    if event.subId == CMD_GameServer.SUB_GF_USER_CHAT then
        msg = protocol.game.gameServer_pb.CMD_GF_S_UserChat_Pro()
        msg:ParseFromString(event.data)
        msgContent.type = 1
        msgContent.content = msg.szChatString
        msgContent.sendUserId = msg.dwSendUserID

    elseif event.subId == CMD_GameServer.SUB_GF_USER_EXPRESSION then
        msg = protocol.game.gameServer_pb.CMD_GF_S_UserExpression_Pro()
        msg:ParseFromString(event.data)
        msgContent.type = 2
        msgContent.content = msg.wItemIndex
        msgContent.sendUserId = msg.dwSendUserID

    else
        print("unsupport type:",event.subId)
        -- if event.subId == CMD_GameServer.SUB_GF_USER_MULTIMEDIA then
        --     msg = protocol.game.gameServer_pb.CMD_GF_S_UserMultimedia_Pro()
        -- end
    end
    local sendUser = DataManager:getUserInfoByUserID(msgContent.sendUserId)
    if sendUser == nil then
        return
    end
    --头像
    msgContent.head = {}
    msgContent.head.faceID = sendUser.faceID
    msgContent.head.tokenID = sendUser.platformID
    msgContent.head.headFile = sendUser.platformFace
    msgContent.head.member = sendUser.memberOrder

    msgContent.nickName = sendUser.nickName
    --游戏界面弹出气泡
    self:popMsg(msgContent)
    --添加到聊天界面
    self.vipChatLayer:onReceiveChatMsg(msgContent)

end

function LandlordVideoScene:onChatServerMessage(event)
    if event.data == nil then
        return
    end
    --游戏界面弹出气泡
    self:popMsg(event.data)
    --添加到聊天界面
    self.vipChatLayer:onReceiveChatMsg(event.data)
end

function LandlordVideoScene:popMsg(msgContent)
    if msgContent == nil then
        return
    end
    local popMsgIndex = nil
    local sendUser = DataManager:getUserInfoByUserID(msgContent.sendUserId)

    --找到说话的人
    if DataManager:getMyChairID() == sendUser.chairID then
        popMsgIndex = 8
    else
        --不可见的其他玩家说话
        popMsgIndex = 7
        --其他玩家
        for k,v in pairs(self.visiablePlayer) do
            if wChairID == v then
                --可见的6个其他玩家说话
                popMsgIndex = k
                break
            end
        end
    end

    local contentType,content = self:formatChatContent(msgContent.content)

    local headTarget = nil
    local popMsgContainer = ccui.ImageView:create("landlordVideo/video_chat_pop.png")
    if contentType == 2 then
        popMsgContainer:loadTexture("blank.png")
    end
    popMsgContainer:setScale9Enabled(true)
    local posX = nil
    local posY = nil

    if popMsgIndex == 8 then
        --自己
        headTarget = self.selfHeadBorder

        if contentType == 2 then
            posX = 80
            posY = 110
            popMsgContainer:setCapInsets(cc.rect(60,25,1,1))
            popMsgContainer:setContentSize(cc.size(96,96))
            popMsgContainer:addChild(content)
        else
            posX = 30
            posY = 90
            popMsgContainer:setAnchorPoint(cc.p(0,0.5))
            popMsgContainer:setCapInsets(cc.rect(60,25,1,1))
            popMsgContainer:setContentSize(cc.size(200,60))
            popMsgContainer:addChild(content)
        end

        -- if msgContent.type == 2 then
        --     posX = 80
        --     posY = 110
        --     popMsgContainer:setCapInsets(cc.rect(60,25,1,1))
        --     popMsgContainer:setContentSize(cc.size(96,96))
        --     local content = ccui.ImageView:create(customFace[msgContent.content])
        --     content:setName("PopContent")
        --     -- content:setScale(0.6)
        --     content:setPosition(cc.p(48,52))
        --     popMsgContainer:addChild(content)
        -- else
        --     posX = 30
        --     posY = 90
        --     popMsgContainer:setAnchorPoint(cc.p(0,0.5))
        --     popMsgContainer:setCapInsets(cc.rect(60,25,1,1))
        --     popMsgContainer:setContentSize(cc.size(200,60))
        --     local content = ccui.Text:create()
        --     content:setName("PopContent")
        --     content:setPosition(cc.p(8,36))
        --     content:setFontSize(18)
        --     content:setAnchorPoint(cc.p(0,0.5))
        --     content:setString(msgContent.content)
        --     content:ignoreContentAdaptWithSize(false)
        --     content:setContentSize(cc.size(190,52))
        --     content:setColor(cc.c3b(255,255,0))
        --     content:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT);
        --     content:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER);
        --     popMsgContainer:addChild(content)
        -- end
    elseif popMsgIndex == 7 then
        headTarget = self.showOtherPlayerButton

        if msgContent.type == 2 then
            posX = 5
            posY = 70
            popMsgContainer:setCapInsets(cc.rect(60,25,1,1))
            popMsgContainer:setContentSize(cc.size(96,96))
            popMsgContainer:addChild(content)
        else
            posX = 55
            posY = 52
            popMsgContainer:setAnchorPoint(cc.p(1,0.5))
            popMsgContainer:setCapInsets(cc.rect(10,25,1,1))
            popMsgContainer:setContentSize(cc.size(200,60))
            popMsgContainer:addChild(content)
        end

        -- if msgContent.type == 2 then
        --     posX = 5
        --     posY = 70
        --     popMsgContainer:setCapInsets(cc.rect(60,25,1,1))
        --     popMsgContainer:setContentSize(cc.size(96,96))
        --     local content = ccui.ImageView:create(customFace[msgContent.content])
        --     content:setName("PopContent")
        --     -- content:setScale(0.6)
        --     content:setPosition(cc.p(48,52))
        --     popMsgContainer:addChild(content)
        -- else
        --     posX = 55
        --     posY = 52
        --     popMsgContainer:setAnchorPoint(cc.p(1,0.5))
        --     popMsgContainer:setCapInsets(cc.rect(10,25,1,1))
        --     popMsgContainer:setContentSize(cc.size(200,60))
        --     local content = ccui.Text:create()
        --     content:setName("PopContent")
        --     content:setPosition(cc.p(8,36))
        --     content:setFontSize(18)
        --     content:setAnchorPoint(cc.p(0,0.5))
        --     content:setString(msgContent.content)
        --     content:ignoreContentAdaptWithSize(false)
        --     content:setContentSize(cc.size(190,52))
        --     content:setColor(cc.c3b(255,255,0))
        --     content:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT);
        --     content:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER);
        --     popMsgContainer:addChild(content)
        -- end
    else
        headTarget = self.otherPlayerLayer:getChildByName("playerInfo"..popMsgIndex)

        if msgContent.type == 2 then
            if popMsgIndex == 6 then
                posX = 10
                posY = 110
            else
                posX = 110
                posY = 110
            end
            popMsgContainer:setCapInsets(cc.rect(60,25,1,1))
            popMsgContainer:setContentSize(cc.size(96,96))
            popMsgContainer:addChild(content)
        else
            posX = 60
            posY = 90
            if popMsgIndex == 6 then
                popMsgContainer:setAnchorPoint(cc.p(1,0.5))
                popMsgContainer:setCapInsets(cc.rect(10,25,1,1))
            else
                popMsgContainer:setAnchorPoint(cc.p(0,0.5))
                popMsgContainer:setCapInsets(cc.rect(60,25,1,1))
            end
            popMsgContainer:setContentSize(cc.size(200,60))
            popMsgContainer:addChild(content)
        end

        -- if msgContent.type == 2 then
        --     if popMsgIndex == 6 then
        --         posX = 10
        --         posY = 110
        --     else
        --         posX = 110
        --         posY = 110
        --     end
        --     popMsgContainer:setCapInsets(cc.rect(60,25,1,1))
        --     popMsgContainer:setContentSize(cc.size(96,96))
        --     local content = ccui.ImageView:create(customFace[msgContent.content])
        --     content:setName("PopContent")
        --     -- content:setScale(0.6)
        --     content:setPosition(cc.p(48,52))
        --     popMsgContainer:addChild(content)
        -- else
        --     posX = 60
        --     posY = 90
        --     if popMsgIndex == 6 then
        --         popMsgContainer:setAnchorPoint(cc.p(1,0.5))
        --         popMsgContainer:setCapInsets(cc.rect(10,25,1,1))
        --     else
        --         popMsgContainer:setAnchorPoint(cc.p(0,0.5))
        --         popMsgContainer:setCapInsets(cc.rect(60,25,1,1))
        --     end
        --     popMsgContainer:setContentSize(cc.size(200,60))
        --     local content = ccui.Text:create()
        --     content:setName("PopContent")
        --     content:setPosition(cc.p(8,36))
        --     content:setFontSize(18)
        --     content:setAnchorPoint(cc.p(0,0.5))
        --     content:setString(msgContent.content)
        --     content:ignoreContentAdaptWithSize(false)
        --     content:setContentSize(cc.size(190,52))
        --     content:setColor(cc.c3b(255,255,0))
        --     content:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT);
        --     content:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER);
        --     popMsgContainer:addChild(content)
        -- end
    end

    local targetWorldPosition = headTarget:convertToWorldSpace(cc.p(posX,posY))
    local targetThisPosition = self.gameContainer:convertToNodeSpace(cc.p(targetWorldPosition.x,targetWorldPosition.y))

    popMsgContainer:setPosition(cc.p(targetThisPosition.x,targetThisPosition.y))
    self.gameContainer:addChild(popMsgContainer)
    self:performWithDelay(
        function ()
            popMsgContainer:removeFromParent()
        end,
        1.5
    )
end

function LandlordVideoScene:formatChatContent(contentStr)
    local chatContent = nil
    local contentType = 1

    local contentLen = string.len(contentStr)
    local index = 1
    local startIndex = string.find(contentStr,"[`",index,true)
    if startIndex ~= nil then
        local endIndex = string.find(contentStr,"`]",startIndex + 1,true)
        local imgName = string.sub(contentStr,startIndex+2,endIndex-1)
        chatContent = cc.Sprite:create("chat/bq/"..imgName..".png")
        chatContent:setName("PopContent")
        chatContent:setPosition(cc.p(48,52))
        contentType = 2
    else
        chatContent = ccui.Text:create()
        chatContent:setName("PopContent")
        chatContent:setPosition(cc.p(8,36))
        chatContent:setFontSize(18)
        chatContent:setAnchorPoint(cc.p(0,0.5))
        chatContent:setString(contentStr)
        chatContent:ignoreContentAdaptWithSize(false)
        chatContent:setColor(cc.c3b(255,255,0))
        chatContent:setContentSize(cc.size(190,52))
        chatContent:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT);
        chatContent:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER);
        contentType = 1
    end
    return contentType,chatContent
end

function LandlordVideoScene:requestInsure()

    local dwUserID = DataManager:getMyUserID()

    local queryInsureInfo = protocol.hall.treasureInfo_pb.CMD_GR_C_QueryInsureInfo_Pro()
    queryInsureInfo.cbActivityGame = dwUserID
    local pData = queryInsureInfo:SerializeToString()
    local pDataLen = string.len(pData)

    local main = CMD_GameServer.MDM_GR_INSURE
    local sub = CMD_GameServer.SUB_GR_QUERY_INSURE_INFO
    
    GameCenter:sendData(main,sub,pData,pDataLen)
end

function LandlordVideoScene:onPropertySuccess(event)
    local propertySuccess = event.data
    print("propertySuccess:",propertySuccess.cbRequestArea,
            propertySuccess.wItemCount,
            propertySuccess.wPropertyIndex,
            propertySuccess.dwSourceUserID,
            propertySuccess.dwTargetUserID)
    self:requestInsure()
    --播放道具动画
    local startIndex = self:getFlyStartIndex(propertySuccess.dwSourceUserID)
    local endIndex = self:getFlyStartIndex(propertySuccess.dwTargetUserID)
    if endIndex == 9 then
        --请求主播排名
        self:requestVipLoveOrder(1)
    end
    if startIndex == endIndex then
        --都是无座玩家赠送道具不播放动画
    else
        self:flyGift(startIndex,endIndex,propertySuccess.wPropertyIndex,propertySuccess.wItemCount)
    end
    --添加聊天记录
    local msgContent = {}
    msgContent.type = 1
    
    local senderStr = ""
    local sourceUser = DataManager:getUserInfoByUserID(propertySuccess.dwSourceUserID)
    if sourceUser == nil then
        return
    end
    if startIndex == 9 then
        senderStr = "主播MM"
    else
        if sourceUser then
            senderStr = sourceUser.nickName
        end
    end
    local targetStr = ""
    if endIndex == 9 then
        targetStr = "主播MM"
    else
        local targetUser = DataManager:getUserInfoByUserID(propertySuccess.dwTargetUserID)
        if targetUser then
            targetStr = targetUser.nickName
        end
    end

    local gift = PropertyConfigInfo:obtainPropertyobjectByIndex(propertySuccess.wPropertyIndex)
    local msgString = senderStr.."赠送"..targetStr..propertySuccess.wItemCount..customGift[gift:getIndex()].giftName
    msgContent.content = msgString

    msgContent.sendUserId = propertySuccess.dwSourceUserID
    --头像
    msgContent.head = {}
    msgContent.head.faceID = sourceUser.faceID
    msgContent.head.tokenID = sourceUser.platformID
    msgContent.head.headFile = sourceUser.platformFace
    msgContent.head.member = sourceUser.memberOrder
    msgContent.nickName = sourceUser.nickName
    --游戏界面弹出气泡
    self:popMsg(msgContent)
    --添加到聊天界面
    -- self.vipChatLayer:onReceiveChatMsg(msgContent)
    --添加滚动消息
    self:showScrollMessage(msgString)
    --通知web端主播
    if propertySuccess.dwSourceUserID == DataManager:getMyUserID() then
        local gameServer = RunTimeData:getCurGameServer()
        local platFormUserID = DataManager:getMyUserInfo().tokenID
        local roomID = VideoAnchorManager:getAnchorRoomID(gameServer:getServerID())
        local nickName = DataManager:getMyUserInfo().nickName
        local userID = DataManager:getMyUserID()
        sendTextMsg(msgString,platFormUserID,roomID,nickName,userID,"4")
        -- sendTextMsg(msgString,platFormUserID,roomID,nickName,userID)
    end
end

-- 有座玩家：1～6 无座玩家：7 自己：8 主播：9 
function LandlordVideoScene:getFlyStartIndex(sourceUserID)
    local anchorUserID = self:getCurAnchorUserID()
    if anchorUserID == sourceUserID then
        return 9
    end
    local sourceUser = DataManager:getUserInfoByUserID(sourceUserID)
    if sourceUser == nil then
        return 7
    end
    local wChairID = sourceUser.chairID
    local flyGoldStartIndex = 0
    if wChairID == DataManager:getMyChairID() then
        --自己下注
        flyGoldStartIndex = 8
    else
        --不可见的其他玩家下注
        flyGoldStartIndex = 7
    end
    --其他玩家
    for k,v in pairs(self.visiablePlayer) do
        if wChairID == v then
            --可见的6个其他玩家下注
            flyGoldStartIndex = k
            break
        end
    end
    return flyGoldStartIndex
end

--赠送礼物动画
function LandlordVideoScene:flyGift(startIndex,endIndex,giftIndex,giftCount)
    print("flyGiftToAnchor:",startIndex,endIndex,giftIndex,giftCount)
    ----主播宠物的位置
    local anchorPet = self.gameContainer:getChildByName("anchorPet")
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
    local originNode = nil
    if startIndex == 8 then
        --自己
        originNode = self.selfHeadBorder
    elseif startIndex == 7 then
        originNode = self.showOtherPlayerButton
    elseif startIndex == 9 then
        originNode = anchorPet
    else
        originNode = self.otherPlayerLayer:getChildByName("playerInfo"..startIndex)
    end
    local originWorldPosition = originNode:getParent():convertToWorldSpace(cc.p(originNode:getPositionX(),originNode:getPositionY()))
    local originPosition = self.gameContainer:convertToNodeSpace(cc.p(originWorldPosition.x,originWorldPosition.y))
    ----动画node
    local giftTarget = ccui.ImageView:create(customGift[giftIndex].giftImg)
    giftTarget:setScale(0.6)
    giftTarget:setPosition(cc.p(originPosition.x,originPosition.y))
    self.gameContainer:addChild(giftTarget)
    ----动画可能的中间位置
    local giftEffect = self.gameContainer:getChildByName("giftEffect")
    local middleWorldPosition = giftEffect:getParent():convertToWorldSpace(cc.p(giftEffect:getPositionX(),giftEffect:getPositionY()))
    local middlePosition = self.gameContainer:convertToNodeSpace(cc.p(middleWorldPosition.x,middleWorldPosition.y))
    ----动画最终目标位置
    local targetNode = nil
    if endIndex == 8 then
        --自己
        targetNode = self.selfHeadBorder
    elseif endIndex == 7 then
        targetNode = self.showOtherPlayerButton
    elseif endIndex == 9 then
        targetNode = anchorPet
    else
        targetNode = self.otherPlayerLayer:getChildByName("playerInfo"..endIndex)
    end
    local targetWorldPosition = targetNode:getParent():convertToWorldSpace(cc.p(targetNode:getPositionX(),targetNode:getPositionY()))
    local targetPosition = self.gameContainer:convertToNodeSpace(cc.p(targetWorldPosition.x,targetWorldPosition.y))

    ----开始播放动画
    ----动画1:送出玩家动画
    if startIndex ~= 7 then
        if startIndex == 9 then
            --todo
        else
            --起始位置动画
            local action1 = cc.MoveBy:create(0.1,cc.p(0,20))
            local action2 = action1:reverse()
            local acitionHead = cc.Sequence:create(action1,action2)
            originNode:runAction(acitionHead)
        end
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
                -- 播放道具动画
                local armature = EffectFactory:getInstance():getGiftArmature(giftIndex)
                if armature then
                    armature:setPosition(cc.p(targetPosition.x,targetPosition.y))
                    self.gameContainer:addChild(armature)
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
                    self.gameContainer:addChild(armature)
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

function LandlordVideoScene:onDasangSuccess(event)
    local dasangSuccess = event.data
    print("dasangSuccess:",dasangSuccess.dwUserID,
            dasangSuccess.dwTargetID,
            dasangSuccess.dwDaSangScore,
            dasangSuccess.bSaveToBank)

    self:requestInsure()
    --播放道具动画
    local startIndex = self:getFlyStartIndex(dasangSuccess.dwUserID)
    self:flyGoldToAnchor(startIndex,dasangSuccess.dwDaSangScore)
    --添加聊天记录
    local msgContent = {}
    msgContent.type = 1
    
    local sourceUser = DataManager:getUserInfoByUserID(dasangSuccess.dwUserID)
    if sourceUser == nil then
        return
    end
    local msgString = sourceUser.nickName.."打赏主播"..FormatDigitToString(dasangSuccess.dwDaSangScore, 0).."金币"
    msgContent.content = msgString

    msgContent.sendUserId = dasangSuccess.dwUserID
    --头像
    msgContent.head = {}
    msgContent.head.faceID = sourceUser.faceID
    msgContent.head.tokenID = sourceUser.platformID
    msgContent.head.headFile = sourceUser.platformFace
    msgContent.head.member = sourceUser.memberOrder
    msgContent.nickName = sourceUser.nickName
    --游戏界面弹出气泡
    self:popMsg(msgContent)
    --添加到聊天界面
    -- self.vipChatLayer:onReceiveChatMsg(msgContent)
    --添加滚动消息
    self:showScrollMessage(msgString)
    --通知web端主播
    if DataManager:getMyUserID() == dasangSuccess.dwUserID then
        local gameServer = RunTimeData:getCurGameServer()
        local platFormUserID = DataManager:getMyUserInfo().tokenID
        local roomID = VideoAnchorManager:getAnchorRoomID(gameServer:getServerID())
        local nickName = DataManager:getMyUserInfo().nickName
        local userID = DataManager:getMyUserID()
        sendTextMsg(msgString,platFormUserID,roomID,nickName,userID,"4")
    end
end

function LandlordVideoScene:flyGoldToAnchor(startIndex,goldNum)
    print("flyGoldToAnchor:",startIndex,goldNum)
    -- 主播宠物的位置
    local anchorPet = self.gameContainer:getChildByName("anchorPet")

    local action1 = cc.MoveBy:create(0.1,cc.p(0,20))
    local action2 = action1:reverse()
    local acitionHead = cc.Sequence:create(action1,action2)

    local headTarget = nil
    if startIndex == 8 then
        --自己
        headTarget = self.selfHeadBorder
    elseif startIndex == 7 then
        headTarget = self.showOtherPlayerButton
    elseif startIndex == 9 then
        headTarget = self.showOtherPlayerButton
    else
        headTarget = self.otherPlayerLayer:getChildByName("playerInfo"..startIndex)
    end

    local headWorldPosition = headTarget:getParent():convertToWorldSpace(cc.p(headTarget:getPositionX(),headTarget:getPositionY()))
    local thisPosition = self.gameContainer:convertToNodeSpace(cc.p(headWorldPosition.x,headWorldPosition.y))

    local giftTarget = ccui.ImageView:create()
    local giftImage = "common/gold.png"
    giftTarget:loadTexture(giftImage)
    giftTarget:setScale(0.6)
    giftTarget:setPosition(cc.p(thisPosition.x,thisPosition.y))
    self.gameContainer:addChild(giftTarget)

    if startIndex ~= 7 then
        headTarget:runAction(acitionHead)
    end

    local remove = cc.CallFunc:create(
        function()
            local petDJ = cc.CallFunc:create(
                function()
                    anchorPet:stopAllActions()
                    local animation = EffectFactory:getInstance():getEffectByName("zcm-dj-", 0.2, 1, 3)
                    local action = cc.RepeatForever:create(cc.Animate:create(animation))
                    anchorPet:runAction(action)
                end
            );
            giftTarget:removeFromParent()
            
            anchorPet:stopAllActions()
            local animation = EffectFactory:getInstance():getEffectByName("zcm-kx-", 0.1, 1, 5)
            local action = cc.Sequence:create(cc.Animate:create(animation),petDJ)
            anchorPet:runAction(action)
        end
    );
    local actionGift1 = cc.MoveTo:create(0.5,cc.p(anchorPet:getPositionX(),anchorPet:getPositionY()))
    local actionGift2 = cc.Sequence:create(cc.FadeIn:create(0.35),cc.FadeOut:create(0.15))
    local actionGiftFly = cc.Sequence:create(cc.Spawn:create(actionGift1,actionGift2),remove)
    giftTarget:runAction(actionGiftFly)
end
function LandlordVideoScene:gameMessageHandler(event)
    local pSystemMessage = protocol.room.game_pb.CMD_CM_SystemMessage_Pro()
    pSystemMessage:ParseFromString(event.data)
    
    local msgString = pSystemMessage.szString
    local wType = pSystemMessage.wType
    local colorkind = 1
    if ((bit.band(pSystemMessage.wType,CMD_Common.SMT_SYSTEM_MSG)) == CMD_Common.SMT_SYSTEM_MSG) then--系统消息
        colorkind = 1
    end
    if ((bit.band(pSystemMessage.wType,CMD_Common.SMT_PLYER_MSG)) == CMD_Common.SMT_PLYER_MSG) then--玩家喊话消息
        colorkind = 2
    end
    if ((bit.band(pSystemMessage.wType,CMD_Common.SMT_AWARD_MSG)) == CMD_Common.SMT_AWARD_MSG) then--奖励消息
        colorkind = 3
    end
    if ((bit.band(pSystemMessage.wType,CMD_Common.SMT_ACTIVITY_MSG)) == CMD_Common.SMT_ACTIVITY_MSG) then--活动消息
        colorkind = 4
    end

    self:showScrollMessage(msgString,self.colorArray[colorkind],colorkind)
end
function LandlordVideoScene:showScrollMessage(messageContent,color,labaKind)
    table.insert(self.scrollMessageArr, messageContent)
    table.insert(self.scrollMessageKindArr,labaKind)
    if self.scrollTextContainer:isVisible() == false then
        self.scrollTextContainer:setVisible(true)
        self:startScrollMessage(color)
    end
end

function LandlordVideoScene:startScrollMessage(color)
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
        scrollText:enableOutline(cc.c3b(7,1,3), 2)

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

function LandlordVideoScene:registerGameEvent()
    QueryService:addEventListener(HallCenterEvent.EVENT_QUERY_BATTLE_RECORD, handler(self, self.onReceiveBattleRecord))
    GameCenter:addEventListener(GameCenterEvent.EVENT_GAME_MESSAGE, handler(self, self.onReceiveGameMessage))
    GameCenter:addEventListener(GameCenterEvent.EVENT_GAME_SCENE, handler(self, self.onProcessGameScene))
    GameCenter:addEventListener(GameMessageType.EVENT_USER_MESSAGE, handler(self, self.onUserMessage))
    -- GameCenter:addEventListener(GameCenterEvent.EVENT_TIMEBOXAWARD_RESULT, handler(self, self.onTimeBoxAwardResult))
    GameCenter:addEventListener(GameCenterEvent.EVENT_EXIT_GAME, handler(self, self.onServerExitScene))
    GameCenter:addEventListener(GameCenterEvent.EVENT_CHANGE_ROOM, handler(self, self.enterGame))
    GameCenter:addEventListener(GameCenterEvent.EVENT_TTC_CHATMESSAGE, handler(self, self.onReceiveTTCChatMessage))
    self.SMT_TABLE_ROLL = GameCenter:addEventListener(GameMessageType.SMT_TABLE_ROLL, handler(self, self.gameMessageHandler))
    -- GameCenter:addEventListener(GameCenterEvent.EVENT_SYSTEM_MESSAGE, handler(self, self.onReceiveSystemMessage))
    -- GameCenter:addEventListener(GameCenterEvent.EVENT_TIMEBOXAWARD_QUERY, handler(self, self.onTimeBoxAwardQuery))
    self.roomChangeButton:addEventListener(LandlordEvent.SHOW_ROOMCHANGELAYER, handler(self, self.showRoomChangeLayer))
    --银行更新
    self.handler_QUERY_INSURE_FOR_GAME = GameCenter:addEventListener(GameCenterEvent.EVENT_QUERY_INSURE_FOR_GAME, handler(self, self.onQueryUserInsure))
    --道具购买成功
    self.handler_PROPERTY_SUCCESS = GameCenter:addEventListener(GameCenterEvent.EVENT_PROPERTY_SUCCESS, handler(self, self.onPropertySuccess))
    --打赏成功
    GameCenter:addEventListener(GameCenterEvent.EVENT_SEND_GOLD_SUCCESS, handler(self, self.onDasangSuccess))
    --聊天服务器事件监听
    self.chatServerListener = GameCenter:addEventListener(GameCenterEvent.EVENT_CHATSERVER_MESSAGE, handler(self, self.onChatServerMessage))
    --视频监听
    self.videoLoadStateChangeListener = GameCenter:addEventListener(VideoEventType.EVENT_LoadStateDidChange, handler(self, self.onLoadStateDidChange))
    self.videoMoviePlayBackFinishListener = GameCenter:addEventListener(VideoEventType.EVENT_MoviePlayBackDidFinish, handler(self, self.onMoviePlayBackDidFinish))
    self.videoMediaIsPreparedListener = GameCenter:addEventListener(VideoEventType.EVENT_MediaIsPreparedToPlayDidChange, handler(self, self.onMediaIsPreparedToPlayDidChange))
    self.videoMoviePlayBackStateChangeListener = GameCenter:addEventListener(VideoEventType.EVENT_MoviePlayBackStateDidChange, handler(self, self.onMoviePlayBackStateDidChange))
    --自定义头像监听
    self.handler_AVATARDOWNLOADURL = UserService:addEventListener(HallCenterEvent.EVENT_AVATARDOWNLOADURL, handler(self, self.customFaceUrlBackHandler))
end

function LandlordVideoScene:customFaceUrlBackHandler(event)
    self:performWithDelay(function ( )
            self:refreshOtherPlayerInfo()
        end, 1)
end

function LandlordVideoScene:onLoadStateDidChange(event)
    print("LandlordVideoScene:onLoadStateDidChange",event.state)
end

function LandlordVideoScene:onMoviePlayBackDidFinish(event)
    print("LandlordVideoScene:onMoviePlayBackDidFinish",event.reason)
    IJKStop()
    IJKSetViewVisible(false)
end

function LandlordVideoScene:onMediaIsPreparedToPlayDidChange()
    print("LandlordVideoScene:onMediaIsPreparedToPlayDidChange")
end

function LandlordVideoScene:onMoviePlayBackStateDidChange(event)
    print("LandlordVideoScene:onMoviePlayBackStateDidChange",event.playbackState)
end

function LandlordVideoScene:removeGameEvent()
    QueryService:removeEventListenersByEvent(HallCenterEvent.EVENT_QUERY_BATTLE_RECORD)
    GameCenter:removeEventListenersByEvent(GameCenterEvent.EVENT_GAME_MESSAGE)
    GameCenter:removeEventListenersByEvent(GameCenterEvent.EVENT_GAME_SCENE)
    GameCenter:removeEventListenersByEvent(GameMessageType.EVENT_USER_MESSAGE)
    GameCenter:removeEventListenersByEvent(GameCenterEvent.EVENT_EXIT_GAME)
    GameCenter:removeEventListenersByEvent(GameCenterEvent.EVENT_CHANGE_ROOM)
    GameCenter:removeEventListener(self.SMT_TABLE_ROLL)

    self.roomChangeButton:removeEventListenersByEvent(LandlordEvent.SHOW_ROOMCHANGELAYER)
    GameCenter:removeEventListener(self.handler_QUERY_INSURE_FOR_GAME)
    if self.giftInfoLayer then
        self.giftInfoLayer:removeEventListenersByEvent(GameCenterEvent.EVENT_BUY_PROPERTY)
    end
    if self.goldInfoLayer then
        self.goldInfoLayer:removeEventListenersByEvent(GameCenterEvent.EVENT_SEND_GOLD)
    end
    GameCenter:removeEventListener(self.handler_PROPERTY_SUCCESS)
    GameCenter:removeEventListenersByEvent(GameCenterEvent.EVENT_SEND_GOLD_SUCCESS)
    if self.playerListLayer then
        self.playerListLayer:removeEventListenersByEvent(GameCenterEvent.EVENT_SHOW_PLAYER_DETAIL)
    end
    GameCenter:removeEventListener(self.chatServerListener)
    --视频监听
    GameCenter:removeEventListener(self.videoLoadStateChangeListener)
    GameCenter:removeEventListener(self.videoMoviePlayBackFinishListener)
    GameCenter:removeEventListener(self.videoMediaIsPreparedListener)
    GameCenter:removeEventListener(self.videoMoviePlayBackStateChangeListener)
    --自定义头像监听
    GameCenter:removeEventListener(self.handler_AVATARDOWNLOADURL)
end

function LandlordVideoScene:enterGame(event)
    -- 发送场景恢复请求
    GameCenter:sendGameConfigInfo()
end

function LandlordVideoScene:onReceiveTTCChatMessage(event)
    if self.chatHistoryLayer then
        self.chatHistoryLayer:appendChatContent(event.message)
    end
end

function LandlordVideoScene:onServerExitScene()
    --收到游戏退出消息，发送坐下命令
    if self._isLeaveType == 1 then --站起
        self._isLeaveType = nil
    elseif self._isLeaveType == nil then--服务端强制站起
        self:sceneBackToRoom()
    elseif self._isLeaveType == 2 then--切换房间
        --连接下一个房间 self.nextRoomIndex
        local nodeItem = ServerInfo:getNodeItemByIndex(201, 1)
        if nodeItem then
            local gameServer = nodeItem.serverList[self.nextRoomIndex]
            RunTimeData:setCurGameServer(gameServer)
            PlayerInfo:clearAllUserInfo()
            print("VipRoomLayer gameServer.serverAddr,gameServer.serverPort==",gameServer.serverAddr,gameServer.serverPort)
            GameConnection:connectRoomServer(gameServer.serverAddr,gameServer.serverPort)
            -- GameCenter:connectRoomServer(gameServer:getServerAddr(),gameServer:getServerPort())

            local serverIndex = VideoAnchorManager:getAnchorGameServerIndex(gameServer.serverID)
            if serverIndex then
                self.gameTableBg:loadTexture("landlordVideo/vip_table_"..serverIndex..".png")
            end
            --切换视频
            IJKStop()
            IJKSetViewVisible(false)
            --退订房间
            local anchorRoomID = VideoAnchorManager:getAnchorRoomID(gameServer.serverID)
            unSubScribeAnchorRoom(anchorRoomID)
            self:createVideoAndPlay()
        end
        self.nextRoomIndex = nil
        self._isLeaveType = 3
        -- self:showWaiting()
        Hall.showWaiting(60)
    elseif self._isLeaveType == 3 then--切换后坐下
        --Clear all data
        self:resetAllData()
        self.reJettonArr = {}
        GameCenter:sitDown(-1,-1)
        Hall.hideWaiting()
    end
end

function LandlordVideoScene:sceneBackToRoom()
    if self.videoLoadingListener then
        scheduler.unscheduleGlobal(self.videoLoadingListener)
    end
    --退订房间
    local curGameServer = RunTimeData:getCurGameServer()
    local anchorRoomID = VideoAnchorManager:getAnchorRoomID(curGameServer:getServerID())
    unSubScribeAnchorRoom(anchorRoomID)
    --清理场景handle
    IJKStop()
    IJKSetViewVisible(false)
    self:removeGameEvent()
    --切换界面
    local roomScene=require("hall.RoomScene").new()
    cc.Director:getInstance():replaceScene(cc.TransitionSlideInT:create(0.5, roomScene))
end

function LandlordVideoScene:showTips(tip, lastTime)

    local time = lastTime or 1.0;

    local size = self.gameContainer:getContentSize()
    local layer = ccui.Layout:create()
    layer:setContentSize(size)
    self.gameContainer:addChild(layer)

    local background = display.newScale9Sprite("tip.png", size.width / 2, size.height / 2, CCSize(607,47));
    layer:addChild(background);

    local content = ccui.Text:create();
    content:setName("roomCountLabel");
    content:setString(tip);
    content:setAnchorPoint(cc.p(0.5,0.5));
    content:setFontSize(25);
    content:enableOutline(cc.c3b(0, 0, 0), 2);
    content:setPosition(cc.p(size.width / 2,size.height / 2));
    content:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER);
    layer:addChild(content);

    layer:setScale(0.01);

    local callfunc = cc.CallFunc:create(function()layer:removeFromParent();end);

    local sequence = transition.sequence(
        {
            cc.ScaleTo:create(0.2, 1.5),
            cc.ScaleTo:create(0.1, 1.0),
            cc.DelayTime:create(time),
            cc.Hide:create(),
            callfunc,
        }
    )
    layer:runAction(sequence);

end

function LandlordVideoScene:createTip(tip, lastTime)

    local time = lastTime or 1.0;

    local layer = display.newLayer();
    layer:setContentSize(cc.Director:getInstance():getWinSize());

    local size = layer:getContentSize();

    local background = display.newScale9Sprite("tip.png", size.width / 2, size.height / 2, CCSize(607,47));
    layer:addChild(background);

    local content = ccui.Text:create();
    content:setName("roomCountLabel");
    content:setString(tip);
    content:setAnchorPoint(cc.p(0.5,0.5));
    content:setFontSize(25);
    content:enableOutline(cc.c3b(0, 0, 0), 2);
    content:setPosition(cc.p(size.width / 2,size.height / 2));
    content:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER);
    layer:addChild(content);

    layer:setScale(0.01);

    local callfunc = cc.CallFunc:create(function()layer:removeFromParent();end);

    local sequence = transition.sequence(
        {
            cc.ScaleTo:create(0.2, 1.5),
            cc.ScaleTo:create(0.1, 1.0),
            cc.DelayTime:create(time),
            cc.Hide:create(),
            callfunc,
        }
    )
    layer:runAction(sequence);

    return layer;

end

function LandlordVideoScene:showStatusHint(isJettonStart)
    local hintImage = ccui.ImageView:create()
    hintImage:loadTexture("landlordVideo/gr_bg.png")
    hintImage:setCapInsets(cc.rect(50,35,1,1))
    hintImage:setScale9Enabled(true)
    hintImage:setContentSize(cc.size(270,76))
    hintImage:setPosition(cc.p(808,560))
    self.gameContainer:addChild(hintImage)
    local hintTextimage = ccui.ImageView:create()
    if isJettonStart then
        hintTextimage:loadTexture("landlordVideo/gamehint_startjetton.png")
    else
        hintTextimage:loadTexture("landlordVideo/gamehint_endjetton.png")
    end
    hintTextimage:setPosition(cc.p(135,35))
    hintImage:addChild(hintTextimage)

    local callfunc = cc.CallFunc:create(function()hintImage:removeFromParent();end);
    local action = cc.Sequence:create(cc.MoveTo:create(0.3,cc.p(808,400)),cc.DelayTime:create(1),callfunc)
    hintImage:runAction(action)
end

function LandlordVideoScene:onEnter()
    self:registerGameEvent()
    -- 发送场景恢复请求
    GameCenter:sendGameConfigInfo()
    -- 发送房间输赢纪录
    -- HallCenter:sendQueryBattleRecord()
    -- 发送主播排名
    LoveRankManager.init()
    -- self:requestVipLoveOrder(1)
    -- self:requestVipLoveOrder(2)
    -- self:requestVipLoveOrder(3)

    SoundManager.stopMusic()
    SoundManager.playSound("sound/Hundred_Enter.wav")

    -- 注册 update 事件
    self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function(dt)
        self:onEnterFrame(dt);
    end)
    self:scheduleUpdate();
end

function LandlordVideoScene:requestVipLoveOrder(orderType)
    -- type 1:今日  2:昨日  3:上周
    local wMainID = CMD_GameServer.MDM_GR_USER
    local wSubID
    if orderType == 1 then
        wSubID = CMD_GameServer.SUB_GR_VIP_TODAY_ORDER
    elseif orderType == 2 then
        wSubID = CMD_GameServer.SUB_GR_VIP_YESTERDAY_ORDER
    else
        wSubID = CMD_GameServer.SUB_GR_VIP_WEEK_ORDER
    end

    GameCenter:sendData(wMainID,wSubID,nil,0)
end

function LandlordVideoScene:onEnterFrame(dt)
    --下注飞金币
    local jettonGoldRecordCount = table.maxn(self.jettonGoldRecordArr)
    if jettonGoldRecordCount > 0 then
        local jettonGoldRecord = self.jettonGoldRecordArr[1]
        self:flyGold(jettonGoldRecord.startIndex, jettonGoldRecord.jettonArea, jettonGoldRecord.jettonScore)
        table.remove(self.jettonGoldRecordArr,1)
    end
    --结算飞回金币
    local dispatchGoldRecordCount = table.maxn(self.dispatchGoldRecordArr)
    if dispatchGoldRecordCount > 0 then
        local dispatchGoldRecord = self.dispatchGoldRecordArr[1]
        self:dispatchGold(dispatchGoldRecord.dispatchArea, dispatchGoldRecord.goldTag, dispatchGoldRecord.flyToBank)
        table.remove(self.dispatchGoldRecordArr,1)
    end

    self:subscribe(dt);
end

function LandlordVideoScene:showHelpLayer()
    if self.helpLayer == nil then
        local size = self.gameContainer:getContentSize()
        self.helpLayer = ccui.Layout:create()
        self.helpLayer:setContentSize(size)
        self.gameContainer:addChild(self.helpLayer)

        local winSize = cc.Director:getInstance():getWinSize()
        local contentSize = cc.size(1136,winSize.height)
        -- 蒙板
        local maskLayer = ccui.ImageView:create("blank.png")
        maskLayer:setScale9Enabled(true)
        maskLayer:setContentSize(contentSize)
        maskLayer:setPosition(cc.p(display.cx, display.cy));
        maskLayer:setTouchEnabled(true)
        self.helpLayer:addChild(maskLayer)
        local maskImg = ccui.ImageView:create("landlordVideo/video_mask.png")
        maskImg:setPosition(cc.p(757, winSize.height / 2));
        maskLayer:addChild(maskImg)


        local helpLayerBg = ccui.ImageView:create()
        helpLayerBg:loadTexture("common/pop_bg.png")
        helpLayerBg:setScale9Enabled(true)
        helpLayerBg:setContentSize(cc.size(600,433))
        helpLayerBg:setCapInsets(cc.rect(115,215,1,1))
        helpLayerBg:setPosition(cc.p(818,size.height/2))
        self.helpLayer:addChild(helpLayerBg)

        local title_text_bg = ccui.ImageView:create()
        title_text_bg:loadTexture("common/pop_title.png")
        title_text_bg:setAnchorPoint(cc.p(0,0.5))
        title_text_bg:setPosition(cc.p(42,388))
        helpLayerBg:addChild(title_text_bg)
        local title_text = ccui.Text:create("帮助", FONT_ART_TEXT, 24)
        title_text:setColor(cc.c3b(255,233,110));
        title_text:enableOutline(cc.c4b(141,0,166,255*0.7),2);
        title_text:setPosition(cc.p(68,65));
        title_text:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER);
        title_text_bg:addChild(title_text);

        local textContainer = ccui.ImageView:create("view/frame1.png")
        textContainer:setScale9Enabled(true)
        textContainer:setContentSize(cc.size(500,260))
        textContainer:setPosition(cc.p(300,210))
        helpLayerBg:addChild(textContainer)

        local helpText = ccui.Text:create()
        helpText:setFontSize(22)
        helpText:setPosition(cc.p(250,110))
        helpText:setColor(cc.c3b(232,216,182))
        helpText:ignoreContentAdaptWithSize(false)
        helpText:setContentSize(cc.size(480,260))
        textContainer:addChild(helpText)
        helpText:setString("牌堆包括：一副扑克牌，不包括大小王 \
\
比牌规则：\
1.K最大，A最小，不比花色\
\
2.开平，若押了左右两侧，则退回所下注金币")

        --关闭按钮
        local closeButton = ccui.Button:create("common/close.png");
        closeButton:setPressedActionEnabled(true)
        closeButton:setPosition(cc.p(570,400))
        helpLayerBg:addChild(closeButton)
        closeButton:addTouchEventListener(function(sender,eventType)
                if eventType == ccui.TouchEventType.ended then
                    SoundManager.playSound("sound/buttonclick.mp3")
                    if self.helpLayer ~= nil then
                        self.helpLayer:hide()
                    end
                end
            end)
    end
    self.helpLayer:show()
end

function LandlordVideoScene:onExit()
    self:unscheduleUpdate()
end

function LandlordVideoScene:subscribe(dt)
    --每隔x分钟去订阅
    local x = 1
    self.elapsed = self.elapsed or x*60

    if self.elapsed > 0 then
        self.elapsed = self.elapsed - dt

        if self.elapsed <= 0 then
            self.elapsed = x*60

            local gameServer = RunTimeData:getCurGameServer()
            local anchorRoomID = VideoAnchorManager:getAnchorRoomID(gameServer:getServerID())
            subScribeAnchorRoom(anchorRoomID)
        end
    end

end

return LandlordVideoScene