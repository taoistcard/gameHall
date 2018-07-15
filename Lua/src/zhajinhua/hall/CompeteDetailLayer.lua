local CompeteDetailLayer = class("CompeteDetailLayer", function() return display.newLayer() end)
local EffectFactory = require("commonView.EffectFactory")
local DateModel = require("zhajinhua.DateModel")
function CompeteDetailLayer:ctor(serverID)
    self:setNodeEventEnabled(true);
    self.serverID = serverID
	self:createUI(serverID)
    self:refreshValue()
end
function CompeteDetailLayer:refreshValue()

        local serverID = self.serverID
        for j,w in ipairs(MatchInfo.matchServerInfoList) do
            if w.serverID == serverID then
                local matchConfigItem =  DataManager:getMatchConfigItemByServerID(serverID)
                if matchConfigItem then
                    self.roomName:setString(matchConfigItem.name)
                    self.description:setString(matchConfigItem.matchDesc)
                    for i,v in ipairs(matchConfigItem.awardList) do
                        print(i,"rank=",v.rank,v.gold,v.medal,v.exp)
                    end
                    
                else
                    Hall.showTips("没有"..serverID.."这个比赛场的信息", 2)
                end
            end
        end

end
function CompeteDetailLayer:createUI(serverID)
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

    local description = ccui.Text:create("获得筹码：0", "", 20);
    description:setColor(cc.c3b(235,235,235));
    description:setAnchorPoint(cc.p(0.0,1.0))
    description:setPosition(92,240)
    description:setTextAreaSize(cc.size(370,200))
    description:ignoreContentAdaptWithSize(false)
    description:setTextHorizontalAlignment(0)
    description:setTextVerticalAlignment(0)
    description:setString("描述：法律上打开附件是李开复法律上打开附件是李开复法律上打开附件是李开复\n规则：\n1.看牌后跟注是两倍\n2.跟注5轮后才可以全场比牌")
    self.description = description
    nk:addChild(description)

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
return CompeteDetailLayer