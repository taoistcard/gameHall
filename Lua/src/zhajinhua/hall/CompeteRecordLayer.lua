local CompeteRecordLayer = class("CompeteRecordLayer", function() return display.newLayer() end)
local EffectFactory = require("commonView.EffectFactory")
local DateModel = require("zhajinhua.DateModel")
function CompeteRecordLayer:ctor(serverID)
    self:setNodeEventEnabled(true);
    self.serverID = serverID
	self:createUI(serverID)
    self:updateValue()
    self:refreshValue()
end
function CompeteRecordLayer:refreshValue()

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
            end
        end

end
function CompeteRecordLayer:createUI(serverID)
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

    local nk = ccui.ImageView:create("hall/competeSignUp/nk.png");
    nk:setScale9Enabled(true);
    nk:setContentSize(cc.size(540, 292));
    nk:setPosition(cc.p(317, 215));
    bgLayer:addChild(nk);

    -- if 1 then
        local signUped = ccui.Text:create("暂无战绩，快去报名比赛吧！", "", 30);
        signUped:setColor(cc.c3b(235,235,235));
        signUped:setAnchorPoint(cc.p(0.5,0.5))
        signUped:setPosition(273,150)
        self.signUped = signUped
        nk:addChild(signUped)
    -- else
        local recordContainer = ccui.Layout:create()
        recordContainer:setContentSize(cc.size(540, 292))
        recordContainer:setPosition(cc.p(47,70))
        self.recordContainer = recordContainer
        bgLayer:addChild(recordContainer, 1)

        local record_zs = ccui.ImageView:create("hall/competeSignUp/record_zs.png")
        record_zs:setPosition(72,160)
        recordContainer:addChild(record_zs)

        local record_zs2 = ccui.ImageView:create("hall/competeSignUp/record_zs.png")
        record_zs2:setPosition(464,160)
        record_zs2:setScaleX(-1)
        recordContainer:addChild(record_zs2)

        local bestRecord = ccui.Text:create("最佳战绩：第四名", "", 30);
        bestRecord:setColor(cc.c3b(235,235,235));
        bestRecord:setAnchorPoint(cc.p(0.5,0.5))
        bestRecord:setPosition(271,169)
        recordContainer:addChild(bestRecord)
        self.bestRecord = bestRecord

        local chip = ccui.Text:create("获得筹码：0", "", 20);
        chip:setColor(cc.c3b(235,235,235));
        chip:setAnchorPoint(cc.p(0.0,0.5))
        chip:setPosition(50,39)
        recordContainer:addChild(chip)
        self.chip = chip

        local fusai = ccui.Text:create("进入复赛:0", "", 20);
        fusai:setColor(cc.c3b(235,235,235));
        fusai:setAnchorPoint(cc.p(0.0,0.5))
        fusai:setPosition(216,39)
        recordContainer:addChild(fusai)
        self.fusai = fusai

        local juesai = ccui.Text:create("进入决赛:0", "", 20);
        juesai:setColor(cc.c3b(235,235,235));
        juesai:setAnchorPoint(cc.p(0.0,0.5))
        juesai:setPosition(384,39)
        recordContainer:addChild(juesai)
        self.juesai = juesai
    -- end

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
function CompeteRecordLayer:updateValue()
    local bestRecordValue = 5
    local chipValue = 5
    local fusaiValue = 5
    local juesaiValue = 5
    self.bestRecord:setString("最佳战绩:第"..bestRecordValue.."名")
    self.chip:setString("获得筹码:"..chipValue)
    self.fusai:setString("进入复赛:"..fusaiValue)
    self.juesai:setString("进入决赛:"..juesaiValue)
    if false then
        self.recordContainer:hide()
        self.signUped:show()
    else
        self.signUped:hide()
        self.recordContainer:show()
    end
end
return CompeteRecordLayer