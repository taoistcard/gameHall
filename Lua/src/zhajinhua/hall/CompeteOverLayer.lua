local CompeteOverLayer = class("CompeteOverLayer", function() return display.newLayer() end)
local DateModel = require("zhajinhua.DateModel")
function CompeteOverLayer:ctor(userRank)
    self:setNodeEventEnabled(true);
    self.serveridlist = {}
	self:createUI(userRank)
end
function CompeteOverLayer:createUI(userRank)
	local nicknameValue = DataManager:getMyUserInfo().nickName
	local roomNameValue = "roomNameValue"
	local rankValue = userRank.ranking
	local countValue = 96
	local liQuanValue = 100
	local goldValue = 100
	local expValue = 100
	local matchServerID = DateModel:getInstance():getCurrentMatchServerID()
	local matchServerInfo = nil
	for i,v in ipairs(MatchInfo.matchServerInfoList) do
		if v.serverID == matchServerID then
			matchServerInfo = v
		end
	end
	local serverInfo = nil
	for i,v in ipairs(ServerInfo.matchConfigList) do
		if v.serverID == matchServerID then
			serverInfo = v
		end
	end
	if serverInfo then
		roomNameValue = serverInfo.name
	end
	if matchServerInfo then
		countValue = matchServerInfo.matchUsers
		liQuanValue = 200
		goldValue = 200
		expValue = 200
	end

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

    local bgSprite = ccui.ImageView:create("hall/competeOver/bg.png");
    -- bgSprite:setScale9Enabled(true);
    -- bgSprite:setContentSize(cc.size(642, 452));
    bgSprite:setPosition(cc.p(576,299));
    self:addChild(bgSprite);

    local bgkuang = ccui.ImageView:create("hall/competeOver/bgkuang.png");
    bgkuang:setScale9Enabled(true);
    bgkuang:setContentSize(cc.size(660, 434));
    bgkuang:setPosition(cc.p(327,213));
    bgSprite:addChild(bgkuang)

    local nickname = ccui.Text:create(nicknameValue, "", 24);
    nickname:setColor(cc.c3b(255,230,100));
    nickname:setAnchorPoint(cc.p(0.5,0.5))
    nickname:setPosition(117,376)
    bgSprite:addChild(nickname);

    local roomNameBg = ccui.ImageView:create("hall/competeOver/roomName.png");
    roomNameBg:setPosition(cc.p(340,327));
    bgSprite:addChild(roomNameBg);

    local left = ccui.ImageView:create("hall/competeOver/left.png");
    left:setPosition(cc.p(168,203));
    bgSprite:addChild(left);

    local right = ccui.ImageView:create("hall/competeOver/right.png");
    right:setPosition(cc.p(469,195));
    bgSprite:addChild(right);

    local word1 = ccui.ImageView:create("hall/competeOver/word1.png");
    word1:setPosition(cc.p(222,215));
    bgSprite:addChild(word1);
    local rank = require("hall.NumberRankLayer").new()
    rank:setPosition(cc.p(280,160));
    rank:updateNum(1,rankValue)
    bgSprite:addChild(rank);

    local word2 = ccui.ImageView:create("hall/competeOver/word2.png");
    word2:setPosition(cc.p(445,215));
    bgSprite:addChild(word2);

    local roomName = ccui.Text:create(roomNameValue, "", 24);
    roomName:setColor(cc.c3b(255,230,100));
    roomName:setAnchorPoint(cc.p(0.5,0.5))
    roomName:setPosition(304,325)
    bgSprite:addChild(roomName);

    local count = ccui.Text:create(countValue, "", 24);
    count:setColor(cc.c3b(255,230,100));
    count:setAnchorPoint(cc.p(0.5,0.5))
    count:setPosition(485,328)
    bgSprite:addChild(count);

    local liQuan = ccui.Text:create("礼券:"..liQuanValue, "", 24);
    liQuan:setColor(cc.c3b(255,230,100));
    liQuan:setAnchorPoint(cc.p(0.5,0.5))
    liQuan:setPosition(172,61)
    bgSprite:addChild(liQuan);

    local gold = ccui.Text:create("金币:"..goldValue, "", 24);
    gold:setColor(cc.c3b(255,230,100));
    gold:setAnchorPoint(cc.p(0.5,0.5))
    gold:setPosition(327,61)
    bgSprite:addChild(gold);

    local exp = ccui.Text:create("经验"..expValue, "", 24);
    exp:setColor(cc.c3b(255,230,100));
    exp:setAnchorPoint(cc.p(0.5,0.5))
    exp:setPosition(479,61)
    bgSprite:addChild(exp);

    local fanhui = ccui.Button:create()
    fanhui:loadTextures("common/blueBtn.png", "common/blueBtn.png")
    fanhui:setPosition(cc.p(88, -79))
    fanhui:setTitleFontName(FONT_ART_TEXT);
    fanhui:setTitleText("返回");
    fanhui:setPressedActionEnabled(true)
    fanhui:setTitleColor(cc.c3b(255,255,255));
    fanhui:setTitleFontSize(28);
    fanhui:getTitleRenderer():enableOutline(COLOR_BTN_BLUE,2)
    fanhui:addTouchEventListener(
                function(sender,eventType)
                    if eventType == ccui.TouchEventType.ended then
                		self:gotoRoomScene()
                    end
                end
            )
    bgSprite:addChild(fanhui)

    local share = ccui.Button:create()
    share:loadTextures("common/blueBtn.png", "common/blueBtn.png")
    share:setPosition(cc.p(329, -79))
    share:setTitleFontName(FONT_ART_TEXT);
    share:setTitleText("分享");
    share:setPressedActionEnabled(true)
    share:setTitleColor(cc.c3b(255,255,255));
    share:setTitleFontSize(28);
    share:getTitleRenderer():enableOutline(COLOR_BTN_BLUE,2)
    share:addTouchEventListener(
                function(sender,eventType)
                    if eventType == ccui.TouchEventType.ended then
                		self:share()
                    end
                end
            )
    bgSprite:addChild(share)

    local playAgin = ccui.Button:create()
    playAgin:loadTextures("common/blueBtn.png", "common/blueBtn.png")
    playAgin:setPosition(cc.p(573, -79))
    playAgin:setTitleFontName(FONT_ART_TEXT);
    playAgin:setTitleText("再玩一次");
    playAgin:setPressedActionEnabled(true)
    playAgin:setTitleColor(cc.c3b(255,255,255));
    playAgin:setTitleFontSize(28);
    playAgin:getTitleRenderer():enableOutline(COLOR_BTN_BLUE,2)
    playAgin:addTouchEventListener(
                function(sender,eventType)
                    if eventType == ccui.TouchEventType.ended then
                		self:playAgin()
                    end
                end
            )
    bgSprite:addChild(playAgin)

    local close = ccui.Button:create()
    close:loadTextures("common/close1.png", "common/close1.png")
    close:setPosition(cc.p(647, 417))
    close:addTouchEventListener(
                function(sender,eventType)
                    if eventType == ccui.TouchEventType.ended then
                		self:removeFromParent()
                    end
                end
            )
    bgSprite:addChild(close)
end
function CompeteOverLayer:gotoRoomScene()
    GameConnection:closeConnect()
    local roomScene = require("hall.RoomScene_New")
    cc.Director:getInstance():replaceScene(cc.TransitionSlideInT:create(0.5, roomScene.new()))
end
function CompeteOverLayer:share()
end
function CompeteOverLayer:playAgin()
    local serverid = DateModel:getInstance():getCurrentMatchServerID()
    MatchInfo:sendMatchSignUp(serverid)
end
return CompeteOverLayer