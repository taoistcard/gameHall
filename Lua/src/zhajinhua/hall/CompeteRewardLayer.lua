local CompeteRewardLayer = class("CompeteRewardLayer", function() return display.newLayer() end)
local EffectFactory = require("commonView.EffectFactory")
local DateModel = require("zhajinhua.DateModel")
function CompeteRewardLayer:ctor(serverID)
    self:setNodeEventEnabled(true);
    self.serverID = serverID
	self:createUI(serverID)
end
function CompeteRewardLayer:createUI(serverID)
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

    self.listView = ccui.ListView:create()
    self.listView:setDirection(ccui.ScrollViewDir.vertical)
    self.listView:setBounceEnabled(true)
    self.listView:setContentSize(cc.size(380, 160))
    self.listView:setPosition(89,89)
    nk:addChild(self.listView)

    self:refreshReward()

    local description = ccui.Text:create("注:赢得奖牌可至兑换中心兑换", "", 20);
    description:setColor(cc.c3b(235,235,235))
    description:setAnchorPoint(cc.p(0.5,0.5))
    description:setPosition(243,28)
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
function CompeteRewardLayer:refreshReward()
    local serverID = self.serverID
    for j,w in ipairs(MatchInfo.matchServerInfoList) do
        if w.serverID == serverID then
            local matchConfigItem =  DataManager:getMatchConfigItemByServerID(serverID)
            if matchConfigItem then
                self.roomName:setString(matchConfigItem.name)
                for i,v in ipairs(matchConfigItem.awardList) do
                    print(i,"rank=",v.rank,v.gold,v.medal,v.exp)
		            local custom_item = ccui.Layout:create()
		            custom_item:setTouchEnabled(true)
		            custom_item:setContentSize(cc.size(380, 26))
		            self.listView:pushBackCustomItem(custom_item)

			        local rank = ccui.Text:create("第"..v.rank.."名", "", 20);
			        rank:setColor(cc.c3b(235,235,235));
			        rank:setAnchorPoint(cc.p(0.0,0.5))
			        rank:setPosition(20,13)
			        custom_item:addChild(rank)

			        local reward = ccui.Text:create("", "", 20);
			        reward:setColor(cc.c3b(235,235,235));
			        reward:setAnchorPoint(cc.p(0.0,0.5))
			        reward:setPosition(146,13)
			        custom_item:addChild(reward)
			        local rewardStr = ""
			        if v.gold > 0 then
			        	rewardStr = rewardStr.."筹码:"..v.gold
			        end
			        if v.medal > 0 then
			        	rewardStr = "+"..rewardStr.."奖牌:"..v.medal
			        end
			        if v.exp > 0 then
			        	rewardStr = "+"..rewardStr.."经验:"..v.exp
			        end
			        reward:setString(rewardStr)
                end
                
            else
                Hall.showTips("没有"..serverID.."这个比赛场的信息", 2)
            end
        end
    end
end
return CompeteRewardLayer