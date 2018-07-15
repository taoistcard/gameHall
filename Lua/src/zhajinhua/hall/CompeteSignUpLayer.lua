local CompeteSignUpLayer = class("CompeteSignUpLayer", function() return display.newLayer() end)
local EffectFactory = require("commonView.EffectFactory")
local DateModel = require("zhajinhua.DateModel")
CompeteSignUpLayer.isSignUp = false
function CompeteSignUpLayer:ctor(serverID)
    self:setNodeEventEnabled(true);
    self.serverID = serverID
	self:createUI(serverID)
    self:updateRoomName()
end
function CompeteSignUpLayer:onEnter()
    self.bindIds = {}
    self.bindIds[#self.bindIds + 1] = BindTool.bind(MatchInfo, "matchServerInfoList", handler(self, self.refreshMatchServernfoList))
    if self.serverID then
        MatchInfo:sendQueryMatchServerInfo({self.serverID})
    end
end
function CompeteSignUpLayer:onExit()
    for _, bindid in ipairs(self.bindIds) do
        BindTool.unbind(bindid)
    end
end
function CompeteSignUpLayer:updateRoomName()
    local serverID = self.serverID
    local matchConfigItem =  DataManager:getMatchConfigItemByServerID(serverID)
    if matchConfigItem then
        self.roomName:setString(matchConfigItem.name)
        self.enterMin:setString(matchConfigItem.fee)
    else
        Hall.showTips("没有"..serverID.."这个比赛场的信息", 2)
    end
end
function CompeteSignUpLayer:refreshMatchServernfoList()

        local serverID = self.serverID
        for j,w in ipairs(MatchInfo.matchServerInfoList) do
            if w.serverID == serverID then
                local matchConfigItem =  DataManager:getMatchConfigItemByServerID(serverID)
                if matchConfigItem then
                    self.roomName:setString(matchConfigItem.name)
                    for i,v in ipairs(matchConfigItem.awardList) do
                        print(i,"rank=",v.rank,v.gold,v.medal,v.exp)
                    end
                    
                else
                    Hall.showTips("没有"..serverID.."这个比赛场的信息", 2)
                end
                self.signUpCount:setString(w.signUsers.."人")
                self.startNeed:setString("满"..w.matchUsers.."人开启")
            end
        end

end
function CompeteSignUpLayer:createUI(serverID)
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
    self:addChild(maskLayer)

    local bgSprite = ccui.ImageView:create("hall/competeSignUp/signUpBg.png");
    -- bgSprite:setScale9Enabled(true);
    -- bgSprite:setContentSize(cc.size(642, 452));
    bgSprite:setPosition(cc.p(576,299));
    self:addChild(bgSprite);

    local animation = EffectFactory:getInstance():getPaoMaDeng()
    animation:setPosition(320,215)
    bgSprite:addChild(animation)

    local bgLayer = ccui.Layout:create()
    bgLayer:setContentSize(cc.size(876, 545))
    bgLayer:setPosition(cc.p(0,0))
    bgSprite:addChild(bgLayer, 1)
    
    local titleSprite = ccui.ImageView:create("hall/competeSelect/titleBg.png");
    -- titleSprite:setScale9Enabled(true);
    -- titleSprite:setContentSize(cc.size(235, 58));
    titleSprite:setPosition(cc.p(322, 425));
    bgSprite:addChild(titleSprite,2);

    -- local titleName = ccui.ImageView:create("hall/competeSelect/title.png");
    -- titleName:setPosition(cc.p(212, 63))
    -- titleSprite:addChild(titleName);

    local roomName = ccui.Text:create("我是比赛场名称", "", 50);
    roomName:setColor(cc.c3b(174,113,46));
    roomName:setAnchorPoint(cc.p(0.5,0.5))
    roomName:setPosition(212, 63)
    self.roomName = roomName
    titleSprite:addChild(roomName);

    local reward_btn = ccui.Button:create()
    reward_btn:loadTextures("hall/competeSignUp/reward_btn.png", "hall/competeSignUp/reward_btn.png")
    reward_btn:setPosition(cc.p(150, 295))
    reward_btn:setTitleFontName(FONT_ART_TEXT);
    reward_btn:setTitleText("奖励方案");
    reward_btn:setTitleColor(cc.c3b(255,255,255));
    reward_btn:setTitleFontSize(28);
    reward_btn:getTitleRenderer():enableOutline(COLOR_BTN_BLUE,2)
    reward_btn:addTouchEventListener(
                function(sender,eventType)
                    if eventType == ccui.TouchEventType.ended then
                		self:rewardHandler()
                    end
                end
            )
    bgLayer:addChild(reward_btn)

    local detail_btn = ccui.Button:create()
    detail_btn:loadTextures("hall/competeSignUp/detail_btn.png", "hall/competeSignUp/detail_btn.png")
    detail_btn:setPosition(cc.p(150, 210))
    detail_btn:setTitleFontName(FONT_ART_TEXT);
    detail_btn:setTitleText("比赛详情");
    detail_btn:setTitleColor(cc.c3b(255,255,255));
    detail_btn:setTitleFontSize(28);
    detail_btn:getTitleRenderer():enableOutline(COLOR_BTN_GREEN,2)
    detail_btn:addTouchEventListener(
                function(sender,eventType)
                    if eventType == ccui.TouchEventType.ended then
                		self:detailHandler()
                    end
                end
            )
    bgLayer:addChild(detail_btn)

    local record_btn = ccui.Button:create()
    record_btn:loadTextures("hall/competeSignUp/record_btn.png", "hall/competeSignUp/record_btn.png")
    record_btn:setPosition(cc.p(150, 127))
    record_btn:setTitleFontName(FONT_ART_TEXT);
    record_btn:setTitleText("我的战绩");
    record_btn:setTitleColor(cc.c3b(255,255,255));
    record_btn:setTitleFontSize(28);
    record_btn:getTitleRenderer():enableOutline(COLOR_BTN_YELLOW,2)
    record_btn:addTouchEventListener(
                function(sender,eventType)
                    if eventType == ccui.TouchEventType.ended then
                		self:recordHandler()
                    end
                end
            )
    bgLayer:addChild(record_btn)

    local nk = ccui.ImageView:create("hall/competeSignUp/nk.png");
    nk:setScale9Enabled(true);
    nk:setContentSize(cc.size(316, 292));
    nk:setPosition(cc.p(423, 211));
    bgLayer:addChild(nk);


    local startTxT = ccui.Text:create("开赛时间：", "", 23);
    startTxT:setColor(cc.c3b(255,230,100));
    startTxT:setAnchorPoint(cc.p(0.5,0.5))
    startTxT:setPosition(89,258)
    nk:addChild(startTxT);

    local startNeed = ccui.Text:create("满XXX人开启", "", 23);
    startNeed:setColor(cc.c3b(255,230,100));
    startNeed:setAnchorPoint(cc.p(0.0,0.5))
    startNeed:setPosition(149,258)
    self.startNeed = startNeed
    nk:addChild(startNeed);

    local chipBg = ccui.ImageView:create("hall/competeSignUp/chipBg.png");
    -- chipBg:setScale9Enabled(true);
    -- chipBg:setContentSize(cc.size(316, 292));
    chipBg:setPosition(cc.p(160, 195));
    nk:addChild(chipBg);

    local chip = ccui.ImageView:create("hall/competeSignUp/chip.png");
    chip:setPosition(cc.p(48, 29));
    chipBg:addChild(chip)

    local enterMin = ccui.Text:create("500", "", 60);
    enterMin:setColor(cc.c3b(255,186,0));
    enterMin:setAnchorPoint(cc.p(0.0,0.5))
    enterMin:setPosition(86,31)
    self.enterMin = enterMin
    chipBg:addChild(enterMin)

    local signUped = ccui.Text:create("已报名：", "", 20);
    signUped:setColor(cc.c3b(255,230,100));
    signUped:setAnchorPoint(cc.p(0.5,0.5))
    signUped:setPosition(71,123)
    nk:addChild(signUped);

    local signUpCount = ccui.Text:create("52665人", "", 20);
    signUpCount:setColor(cc.c3b(255,230,100));
    signUpCount:setAnchorPoint(cc.p(0.0,0.5))
    signUpCount:setPosition(106,123)
    self.signUpCount = signUpCount
    nk:addChild(signUpCount);

    local signUp_btn = ccui.Button:create()
    signUp_btn:loadTextures("hall/competeSignUp/signUp_btn.png", "hall/competeSignUp/signUp_btn.png")
    signUp_btn:setPosition(cc.p(161, 58))
    signUp_btn:setTitleFontName(FONT_ART_TEXT);
    signUp_btn:setTitleText("报名");
    signUp_btn:setTitleColor(cc.c3b(255,255,255));
    signUp_btn:setTitleFontSize(28);
    signUp_btn:getTitleRenderer():enableOutline(COLOR_BTN_BLUE,2)
    signUp_btn:addTouchEventListener(
                function(sender,eventType)
                    if eventType == ccui.TouchEventType.ended then
                		self:signUpHandler()
                    end
                end
            )
    self.signUp_btn = signUp_btn
    nk:addChild(signUp_btn)

    local close = ccui.Button:create()
    close:loadTextures("common/close1.png", "common/close1.png")
    close:setPosition(cc.p(621, 418))
    close:addTouchEventListener(
                function(sender,eventType)
                    if eventType == ccui.TouchEventType.ended then
                		self:removeFromParent()
                    end
                end
            )
    bgLayer:addChild(close)
end
function CompeteSignUpLayer:signUpHandler()
	local serverid = ServerInfo.matchConfigList[1].serverID
	print("serverid",serverid);
    if self.isSignUp == false then
        MatchInfo:sendMatchSignUp(serverid)
        self.signUp_btn:setTitleText("退赛");
        self.isSignUp = true
        print("signUpHandler")
    else
        MatchInfo:sendCancleSignUp(serverid)
        self.signUp_btn:setTitleText("报名");
        self.isSignUp = false
        print("sendCancleSignUp")
    end
end
function CompeteSignUpLayer:rewardHandler()
	-- MatchInfo:sendCancleSignUp(self.serverID)
    local reward = require("hall.CompeteRewardLayer").new(self.serverID)
    self:addChild(reward)
end
function CompeteSignUpLayer:detailHandler()
    local detail = require("hall.CompeteDetailLayer").new(self.serverID)
    self:addChild(detail)
end
function CompeteSignUpLayer:recordHandler()
    local record = require("hall.CompeteRecordLayer").new(self.serverID)
    self:addChild(record)
end
return CompeteSignUpLayer