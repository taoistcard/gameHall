require("cocos.init")
require("framework.init")
scheduler = require("framework.scheduler")

require("lfs")
require("scripts/channel")

require("tools.tools")

--*****************************************************************
require("gameConfig");
require("platform.PlatformFunction")
require("network.GameConnection")
require("network.HallConnection")
require("event.HallEvent")
require("tools.sound.SoundManager")
SoundManager.loadConfig()
require("business.message.LogonMessageManager")
require("RunTimeData")
require("data.HallSetting")
HallSetting.initSetting()
require("define.Define")
require("commonView.EffectFactory")

AccountInfo = require("datamodel.hall.AccountInfo")
BankInfo = require("datamodel.hall.BankInfo")
BankInfoInGame = require("datamodel.game.BankInfoInGame")
HeartBeatInfo = require("datamodel.hall.HeartBeatInfo")
MessageInfo = require("datamodel.hall.MessageInfo")
PayInfo = require("datamodel.hall.PayInfo")
RankingInfo = require("datamodel.hall.RankingInfo")
ServerInfo = require("datamodel.hall.ServerInfo")
ChatInfo = require("datamodel.game.ChatInfo")
GameHeartBeatInfo = require("datamodel.game.HeartBeatInfo")

LotteryInfo = require("datamodel.game.Lottery")

require("datamodel.propertyInfo.PropertyConfigInfo")

PropertyInfo = require("datamodel.game.PropertyInfo")
RoomInfo = require("datamodel.game.RoomInfo")
TableInfo = require("datamodel.game.TableInfo")
GameUserInfo = require("datamodel.game.GameUserInfo")
FishInfo = require("datamodel.fish.FishInfo")
ZhajinhuaInfo = require("datamodel.zhajinhua.ZhajinhuaInfo")
DoudizhuInfo = require("datamodel.doudizhu.DoudizhuInfo")
MatchInfo = require("datamodel.hall.MatchInfo")
MissionInfo = require("datamodel.game.MissionInfo")

SystemMessageInfo = require("datamodel.common.SystemMessageInfo")

require("data.LevelSetting")

--*************************************************************
--这是个控制模块 不要写UI的业务


local Hall = class("Hall");

NEW_SERVER = true

--全局控制游戏中播放音效的状态
Is_Playing_Sound = false

TESTSERVER_93 = false

--作弊开关
EVILBOY = false

SHOWUPDATEINFO = false

ServerHostBackUp = ""

function Hall:start()

    --强制为大厅模式
    autoSelectGame = false

    local temp = cc.UserDefault:getInstance():getStringForKey("ServerHostBackUp", "")
    if string.len(temp) > 0 then
        ServerHostBackUp = temp
        print("....ServerHostBackUp:",ServerHostBackUp)
    end

    -- ServerHostBackUp = "192.168.0.93"

    self:setRes();
    self:setData();
    self:initDataModel()
    self:bindEvent()

    --全局滚动消息数组
    self.scrollMessageArr = {}

    --HallConnection:connectServer(ServerHost, ServerPort);

    if OnlineConfig_review == "off" then
        require("gameUpdate").showScene()
    else
        self:login();
    end
    
    cc.Director:getInstance():setDisplayStats(false);

    self.run_resource_logic = scheduler.scheduleGlobal(
        function()
            -- display.removeUnusedSpriteFrames()
            -- display.dumpCachedTextureInfo()
        end,
        15
    )
    

    local md5value = cc.Crypto:MD5File("/Users/apple/Documents/OXGame_v2.1.0.apk")
    print("=========md5====== ", md5value)

end

function Hall:login()
    local loginLayer = require("login.login");
    loginLayer:start();
end

function Hall:continue()

    if Hall.phoneNumber ~= nil and Hall.phonepassword ~= nil then
        cc.UserDefault:getInstance():setStringForKey("phoneNumber", Hall.phoneNumber)
        cc.UserDefault:getInstance():setStringForKey("phonepassword", Hall.phonepassword)
        cc.UserDefault:getInstance():flush()
    end

    print("-------Hall:continue-------",autoSelectGame,curGameName)

    if autoSelectGame then

        self:updateAndEnterGame(curGameName);
    
    elseif curGameName == "fishing" then

        local showLayer = require("show.showLayer").new();
        display.replaceScene(showLayer:scene());
    
    elseif curGameName == "zhajinhua" then

        print("进入扎金花大厅")
        local showLayer = require("show_zjh.showLayer").new();
        display.replaceScene(showLayer:scene());
    
    elseif curGameName == "landlordCutie" then

        local nextScene = require("show_ddz.HallScene").new()
        display.replaceScene(nextScene);

    end

end

function Hall:bindEvent()
    self.bindIds = {}
    -- self.bindIds[#self.bindIds + 1] = BindTool.bind(AccountInfo, "isRegister", handler(self, self.refreshUserInfo))
    -- self.bindIds[#self.bindIds + 1] = BindTool.bind(SystemMessageInfo, "msgRresh", handler(self, self.refreshSysMsgRresh))
    -- self.bindIds[#self.bindIds + 1] = BindTool.bind(MessageInfo, "systemLogonMsg", handler(self, self.refreshSysMsg))
    -- self.bindIds[#self.bindIds + 1] = BindTool.bind(ServerInfo, "nodeItemList", handler(self, self.refreshServerNode))
    -- self.bindIds[#self.bindIds + 1] = BindTool.bind(RoomInfo, "tableStatus", handler(self, self.refreshTableStatus))--有人坐下桌子
    -- self.bindIds[#self.bindIds + 1] = BindTool.bind(RoomInfo, "tableStatusList", handler(self, self.refreshTableStatusMsg))
    -- self.bindIds[#self.bindIds + 1] = BindTool.bind(RoomInfo, "tableStatusList", handler(self, self.refreshTableStatusMsg))
    -- self.bindIds[#self.bindIds + 1] = BindTool.bind(RoomInfo, "userInfoList", handler(self, self.refreshGameServerMsg))
    -- self.bindIds[#self.bindIds + 1] = BindTool.bind(PropertyInfo, "trumpetScore", handler(self, self.refreshProperty))
    -- self.bindIds[#self.bindIds + 1] = BindTool.bind(TableInfo, "userStatus", handler(self, self.refreshTableUserStatus))
    -- self.bindIds[#self.bindIds + 1] = BindTool.bind(TableInfo, "userSitDownResult", handler(self, self.refreshSitDown))
    -- self.bindIds[#self.bindIds + 1] = BindTool.bind(FishInfo, "gameConfig", handler(self, self.refreshFishGameConfig))
    -- self.bindIds[#self.bindIds + 1] = BindTool.bind(FishInfo, "catchFish", handler(self, self.refreshCatchFish))
    -- self.bindIds[#self.bindIds + 1] = BindTool.bind(FishInfo, "fishSpawnList", handler(self, self.refreshNewFishList))
end

function Hall:unBindEvent()
    for _, bindid in ipairs(self.bindIds) do
        BindTool.unbind(bindid)
    end
end

function Hall:updateAndEnterGame(gameName)

    local instance = self;

    local launcher = require("launcher.launcher").new();

    launcher.onDownloadFinish = function(self, errorCode)
        print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
        if errorCode == 0 then
            print("errorCode",errorCode)
            instance:selectGame(gameName);
        else
            local codeText = display.newTTFLabel({
                text = "Http error code "..errorCode,
                font = "Helvetica-Bold",
                color = cc.c3b(255, 255, 255),
                size = 22,
                align = display.TEXT_ALIGN_LEFT,
                dimensions = cc.size(300,50),
            });
            codeText:setAnchorPoint(cc.p(0.0,0.0));
            codeText:setPosition(cc.p(25, 40));
            self:addChild(codeText);

            self:performWithDelay(
                function()
                    instance:selectGame(gameName);
                    print("instance:selectGame(gameName);")
                end,
                1.0
            );
        end
    end

    display.replaceScene(launcher);

end

function Hall:setRes()	--CCFileUtils:sharedFileUtils():addSearchPath("optional/");
	
	local writablePath = cc.FileUtils:getInstance():getWritablePath()
	local UPD_FOLDER = writablePath.."upd/"
    if XPLAYER == true then
        if APP_ID == 1038 then
            cc.FileUtils:getInstance():addSearchPath("baseRes/fishing/");
            cc.FileUtils:getInstance():addSearchPath("baseRes/fishing/hall");
            cc.FileUtils:getInstance():addSearchPath("baseRes/fishing/common");
        elseif APP_ID == 1032 then
            cc.FileUtils:getInstance():addSearchPath("baseRes/zhajinhua/");
            cc.FileUtils:getInstance():addSearchPath("baseRes/zhajinhua/hall");
            cc.FileUtils:getInstance():addSearchPath("baseRes/zhajinhua/common");
        end
    end
	cc.FileUtils:getInstance():addSearchPath(UPD_FOLDER);
    cc.FileUtils:getInstance():addSearchPath(UPD_FOLDER.."hall");
    cc.FileUtils:getInstance():addSearchPath(UPD_FOLDER.."common");

	cc.FileUtils:getInstance():addSearchPath("res/");
	cc.FileUtils:getInstance():addSearchPath("res/hall");
	cc.FileUtils:getInstance():addSearchPath("res/common");

	self.baseSearchPath = serialize( cc.FileUtils:getInstance():getSearchPaths() );

    --font
    FONT_PTY_TEXT = "fonts/FZPTYJW.TTF";

    --fonts
    FONT_NORMAL = "Arial";--STHeitiTC-Medium
    FONT_ART_TEXT = "fonts/JIANZHUNYUAN.ttf";
    FONT_ART_BUTTON = "fonts/JIANZHUNYUAN.ttf";
    --color
    COLOR_BTN_GREEN = cc.c4b(73,110,4,255*0.7)
    COLOR_BTN_BLUE = cc.c4b(24,119,185,255*0.7)
    COLOR_BTN_YELLOW = cc.c4b(165,82,0,255*0.7)

end

function Hall:setData()
	self.basePackagePath = package.path;
end

function Hall:initDataModel()

    -------初始化---datamodel--------
    AccountInfo:init()
    BankInfo:init()
    BankInfoInGame:init()
    HeartBeatInfo:init()
    MessageInfo:init()
    PayInfo:init()
    RankingInfo:init()
    ServerInfo:init()
    LotteryInfo:init()

    GameHeartBeatInfo:init()
    PropertyInfo:init()
    RoomInfo:init()
    TableInfo:init()
    ChatInfo:init()
    GameUserInfo:init()
    FishInfo:init()
    ZhajinhuaInfo:init()
    DoudizhuInfo:init()
    SystemMessageInfo:init()
    MatchInfo:init()
    MissionInfo:init()

    ----------databas-------- global
    DataManager = require("data.dataManager").new();
    require("data.PurcharseConfig")
end

function Hall:resetSearchPath()

    cc.FileUtils:getInstance():setSearchPaths(unserialize( self.baseSearchPath ));
    package.path = self.basePackagePath;

    -- package.loaded["hall.LoginScene"] = nil;
    -- package.loaded["hall.RoomScene"] = nil;
    -- package.loaded["hall.VipRoomLayer"] = nil;
    -- package.loaded["gameSetting.LevelSetting"] = nil;
    -- package.loaded["commonView.GameHeadView"] = nil;
    -- package.loaded["hall.PersonalCenterLayer"] = nil
    -- package.loaded["hall.NoticeLayer"] = nil
    -- package.loaded["hall.ShopLayer"] = nil
    -- package.loaded["hall.HelpLayer"] = nil
    -- package.loaded["commonView.EffectFactory"] = nil
end

function Hall:enterLoginScene()
    local loginLayer = require("login.login");
    loginLayer:start();
end

function Hall:selectGame(gameName)

    if LOAD_FROM_BIN then

        cc.LuaLoadChunksFromZIP(gameName.."/"..gameName..".bin");

    end

    self:resetSearchPath()
    print("selectGame",gameName)
    package.path = package.path .. ";src/" .. gameName .. "/?.lua";
	
	local gamePath = gameName--.."."..gameName;

    curGameName = gameName

    --确认当前游戏的kinds
    local allKindIDs = HallSetting.getAllKindID(curGameName)
    RunTimeData:setCurKindID(allKindIDs)
    --如果是大厅模式，需要单独请求房间列表
    if autoSelectGame == false then
        -- HallCenter:sendGetServerListByGameKindID(allKindIDs)
    end

	scheduler.performWithDelayGlobal(
		function()

			local game = require(gamePath)--.new();

			game:start();

			self.lastGame = game;

		end,
		0.3
	)

end

function Hall:exitGame()

    print("测试:",curGameName)

    if APP_ID == 1038 then
        curGameName = "fishing"
    elseif APP_ID == 1032 then
        curGameName = "zhajinhua"
    elseif APP_ID == 1005 then
        curGameName = "landlordCutie"
    end

    if autoSelectGame then

        local loginLayer = require("login.login");
        loginLayer:start();
        --[[
        local loginBusiness = require("login.loginBusiness");
        self.business = loginBusiness;
        print("APP_ID",APP_ID)
        if APP_ID == 1038 then
            local loginLayer = require("login.fishingLoginLayer").new(loginBusiness);
            display.replaceScene(loginLayer:scene());
        elseif APP_ID == 1032 then
            local loginLayer = require("login.zjhLoginLayer").new(loginBusiness);
            display.replaceScene(loginLayer:scene());
        end
    ]]
    elseif curGameName == "landlordCutie" then
        local nextScene = require("show_ddz.HallScene").new()
        display.replaceScene(nextScene);

    elseif curGameName == "zhajinhua" then
        local nextScene = require("show_zjh.showLayer").new()
        display.replaceScene(nextScene:scene());

    else
        local showLayer = require("show.showLayer").new();
        display.replaceScene(showLayer:scene());
    end
end

function Hall:refreshServerNode(event)
    local room = ServerInfo.nodeItemList[1].serverList[1]
    self.roomAddr = room.serverAddr
    if string.len(ServerHostBackUp) > 0 then
        self.roomAddr = ServerHostBackUp
    end
    self.roomPort = room.serverPort
    GameConnection:connectServer(self.roomAddr, self.roomPort)
end

function Hall.showWaiting(outTime, message)
    if APP_ID ~= 1005 then
        return
    end
    if outTime == nil then
        outTime = 3
    end
    local winSize = cc.Director:getInstance():getWinSize();
    local runningScene = display.getRunningScene();
    local waitingLayer = runningScene:getChildByName("waitingLayer")

    if waitingLayer == nil then
        waitingLayer = display.newLayer();
        waitingLayer:setContentSize(winSize);
        runningScene:addChild(waitingLayer);
        waitingLayer:setName("waitingLayer")
    end

    -- 蒙板
    local maskLayer = ccui.ImageView:create("black.png");
    maskLayer:setScale9Enabled(true);
    maskLayer:setContentSize(winSize);
    maskLayer:setPosition(cc.p(winSize.width / 2, winSize.height / 2));
    maskLayer:setTouchEnabled(true);
    maskLayer:addTo(waitingLayer);

    if autoSelectGame == true then
        if curGameName == "niuniu" then
            local loading = cc.CSLoader:createNode("view/loadingLayer.csb")
            loading:setPosition(cc.p(winSize.width / 2, winSize.height / 2));
            loading:setAnchorPoint(0.5,0.5)
            maskLayer:addChild(loading);

            local lqAction = cc.CSLoader:createTimeline("view/loadingLayer.csb")
            lqAction:gotoFrameAndPlay(0, 76, true)
            loading:runAction(lqAction)
            local cowBg = loading:getChildByName("Image_1")
            local action = cc.RepeatForever:create(cc.Sequence:create(cc.FadeIn:create(1),cc.FadeOut:create(1)))
            cowBg:runAction(action)
        
        elseif curGameName == "zhajinhua" then
            -- require("hall.Waiting").new():addTo(maskLayer)
        
        elseif curGameName == "landlordCutie" then

            if AppChannel == "launcher_ddz" then--小版本斗地主
                -- local loading = display.newSprite("blank.png");
                -- loading:setPosition(cc.p(winSize.width / 2, winSize.height / 2));
                local sprite = display.newSprite("loading/loadingDDZ.png")
                sprite:runAction(cc.RepeatForever:create(
                    cc.Sequence:create(
                        cc.ScaleTo:create(0.2,0.7),
                        cc.DelayTime:create(0.2),
                        cc.ScaleTo:create(0.2,1.0),
                        cc.DelayTime:create(0.2)
                    )))
                sprite:setPosition(cc.p(winSize.width / 2, winSize.height / 2));

                local content = ccui.Text:create("游戏加载中......", FONT_ART_TEXT, 32);
                content:setTextColor(cc.c4b(250,255,120,255));
                content:enableOutline(cc.c4b(106,33,0,200), 2);
                content:setPosition(cc.p(winSize.width / 2 + 50, winSize.height / 2 - 60));
                maskLayer:addChild(sprite)
                maskLayer:addChild(content)

            else
                local loading = display.newSprite("blank.png");
                loading:setPosition(cc.p(winSize.width / 2, winSize.height / 2));
                local frames = {};
                for i = 1, 4 do
                    local fileName = "loading/loading"..i..".png";
                    local sprite = display.newSprite(fileName);
                    local frame = cc.SpriteFrame:create(fileName, sprite:getTextureRect());
                    frames[i] = frame;
                end
                local animation = display.newAnimation(frames, 1.2 / 4) -- 1.0 秒播放 5 桢

                loading:playAnimationForever(animation, 0);
                maskLayer:addChild(loading);
            end
        end
    else
        local name = "qipai_jiazai"
        local filePath = "loading/"..name..".ExportJson"
        local imagePath = "loading/"..name.."0.png"
        local plistPath = "loading/"..name.."0.plist"
        local manager = ccs.ArmatureDataManager:getInstance()
        if manager:getAnimationData(name) == nil then
            manager:addArmatureFileInfo(imagePath,plistPath,filePath)
        end
        local armature = ccs.Armature:create(name)
        armature:setPosition(cc.p(winSize.width / 2, winSize.height / 2))
        maskLayer:addChild(armature);
        armature:getAnimation():playWithIndex(0)
    end
    
    if message then

        local message_text = ccui.Text:create(message,FONT_ART_TEXT,22);
        message_text:setTextColor(cc.c4b(251,248,142,255));
        message_text:enableOutline(cc.c4b(137,0,167,200), 2);
        message_text:setPosition(cc.p(cc.p(winSize.width / 2, winSize.height / 2 - 150)));
        maskLayer:addChild(message_text);
        waitingLayer.messageText = message_text;

    end

    local callfunc = cc.CallFunc:create(function()
        Hall.hideWaiting();
    end);

    local sequence = transition.sequence(
        {
            cc.DelayTime:create(outTime),
            cc.Hide:create(),
            callfunc,
        }
    )
    waitingLayer:runAction(sequence);

end

function Hall.hideWaiting()
    if curGameName == "zhajinhua" or curGameName == "fishing" then
        return
    end
    local runningScene = display.getRunningScene();
    local waitingLayer = runningScene:getChildByName("waitingLayer")
    if waitingLayer ~= nil then
        waitingLayer:stopAllActions();
        waitingLayer:removeFromParent();
    end
end

function Hall.showWaitingState(txt)

    local winSize = cc.Director:getInstance():getWinSize()

    local maskLayer = ccui.ImageView:create()
    maskLayer:loadTexture("blank.png")
    maskLayer:setScale9Enabled(true)
    maskLayer:setContentSize(cc.size(winSize.width, winSize.height));
    maskLayer:setPosition(cc.p(winSize.width/2, winSize.height/2));
    maskLayer:setTouchEnabled(true);
    display.getRunningScene():addChild(maskLayer)
    Hall.maskLayer = maskLayer

    local second = 1

    --bgSprite
    local bgSprite = display.newSprite("common/game_tip_bg.png"):pos(winSize.width/2, winSize.height/2)
    bgSprite:setScaleX(1.2)
    bgSprite:addTo(maskLayer)

    local tip = ccui.Text:create(txt.." "..second.."s",FONT_PTY_TEXT,28)
    tip:setPosition(winSize.width/2, winSize.height/2)
    tip:setColor(cc.c3b(0xfb, 0xdd, 0x1d))
    tip:enableOutline(cc.c4b(0x00,0x0d,0x07,255),2)
    maskLayer:addChild(tip)

    local callFunc = function()
        second = second + 1
        tip:setString(txt.." "..second.."s")
    end

    local sequence = transition.sequence(
        {
            cc.DelayTime:create(1.0),
            cc.CallFunc:create(callFunc)
        }
    )
    maskLayer:runAction(cc.RepeatForever:create(sequence))

end

function Hall.hideWaitingState()
    if Hall.maskLayer then
        Hall.maskLayer:stopAllActions()
        Hall.maskLayer:removeFromParent()
        Hall.maskLayer = nil
    end
end

function Hall.showTips(tip, lastTime)

    local tipView = Hall.createTip(tip, lastTime);
    local runningScene = display.getRunningScene();
    runningScene:addChild(tipView,10000);

end

function Hall.createTip(tip, lastTime)

    local time = lastTime or 2.0;
    
    local winSize = cc.Director:getInstance():getWinSize()
    local layer = display.newLayer();
    layer:setPosition(winSize.width/2, winSize.height/2)
    layer:setAnchorPoint(cc.p(0.5,0.5))

    local background = display.newScale9Sprite("common/tip.png", display.cx,display.cy, cc.size(607,47));
    layer:addChild(background);

    tip = string.trim(tip)
    local content = display.newTTFLabel({text = string.trim(tip),
                                        size = 32,
                                        color = cc.c3b(249,250,131),
                                        font = FONT_PTY_TEXT,
                                        align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                                    })
                                    
    local textSize = content:getContentSize();
    if textSize.width > display.width*.8 then
        content:setWidth(display.width*.8)
    end
    content:enableOutline(cc.c4b(141,0,166,255*0.7),2)
    content:align(display.CENTER, display.cx, display.cy)
    content:addTo(layer)
    
    textSize = content:getContentSize();
    textSize.width = textSize.width + 50;
    textSize.height = textSize.height + 30;
    background:setContentSize(textSize);

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

--全局滚动消息
function Hall:showScrollMessage(messageContent)

    table.insert(self.scrollMessageArr, messageContent)

    local temp = display.getRunningScene():getChildByTag(10000)
    if temp then
        return
    end

    local winSize = cc.Director:getInstance():getWinSize();

    --滚动消息
    local scrollTextContainer = ccui.Layout:create()
    scrollTextContainer:setAnchorPoint(cc.p(0.5,0.5))
    scrollTextContainer:setContentSize(cc.size(600,30))
    scrollTextContainer:setPosition(cc.p(winSize.width/2, winSize.height-100))
    display.getRunningScene():addChild(scrollTextContainer,10000,10000);

    local scrollBg = ccui.ImageView:create("common/ty_pao_ma_bg.png")
    scrollBg:setScale9Enabled(true)
    scrollBg:setContentSize(cc.size(520, 40))
    scrollBg:ignoreAnchorPointForPosition(false)
    scrollBg:setAnchorPoint(cc.p(0.5,0.5))
    scrollBg:setPosition(cc.p(313,15))
    scrollTextContainer:addChild(scrollBg)

    local scrollTextPanel = ccui.Layout:create()
    scrollTextPanel:setContentSize(cc.size(492,30))
    scrollTextPanel:setPosition(cc.p(80,0))
    scrollTextPanel:setClippingEnabled(true)
    scrollTextPanel:setName("scrollTextPanel")
    scrollTextContainer:addChild(scrollTextPanel)

    local labaImg = ccui.ImageView:create("common/ty_scroll_laba.png")
    labaImg:setPosition(cc.p(68,22))
    scrollTextContainer:addChild(labaImg)

    self:startScrollMessage()

end

function Hall:startScrollMessage()

    local scrollTextContainer = display.getRunningScene():getChildByTag(10000)

    local messageCount = table.maxn(self.scrollMessageArr)
    if messageCount > 0 then

        if scrollTextContainer then
            
            local scrollTextPanel = scrollTextContainer:getChildByName("scrollTextPanel")
            
            local messageContent = self.scrollMessageArr[1]
            table.remove(self.scrollMessageArr,1)

            local scrollText = ccui.Text:create()
            scrollText:setFontSize(24)
            scrollText:setAnchorPoint(cc.p(0,0.5))
            scrollText:setColor(cc.c3b(255,255,255))
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

        else
            --清空消息队列
            self.scrollMessageArr = {}
        end
        
    else
        if scrollTextContainer then
            scrollTextContainer:removeFromParent()
        end
    end
end

function Hall.showTaskTips(tip, lastTime)

    local time = lastTime or 2.0;
    
    local winSize = cc.Director:getInstance():getWinSize()
    local layer = display.newLayer();
    layer:setPosition(winSize.width/2, winSize.height/2)
    layer:setAnchorPoint(cc.p(0.5,0.5))

    local background = display.newSprite("liquan/bg_tip.png"):align(display.CENTER,display.cx,display.cy)
    layer:addChild(background);

    tip = string.trim(tip)
    local content = display.newTTFLabel({text = string.trim(tip),
                                        size = 24,
                                        color = cc.c3b(0xfa,0xe7,0x24),
                                        font = FONT_NORMAL,
                                        align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                                    })
    content:enableOutline(cc.c4b(0xfa,0xe7,0x24,255*0.7),2)
    content:align(display.CENTER, display.cx, display.cy-5)
    content:addTo(layer)

    local callfunc = cc.CallFunc:create(function()layer:removeFromParent();end);
    local sequence = transition.sequence(
        {
            cc.DelayTime:create(time),
            cc.Hide:create(),
            callfunc,
        }
    )
    layer:runAction(sequence);



    local runningScene = display.getRunningScene();
    runningScene:addChild(layer);

end

return Hall
