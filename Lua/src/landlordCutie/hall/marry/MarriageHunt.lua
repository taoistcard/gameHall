local MarriageHunt = class("MarriageHunt",function () return display.newLayer() end )


require("protocol.hall.business_pb")

function MarriageHunt:ctor()
	self:createUI()
    self:setNodeEventEnabled(true)
end

function MarriageHunt:onEnter()
    self.MARRIAGEHUNT = UserService:addEventListener(HallCenterEvent.EVENT_MARRIAGEHUNT, handler(self, self.marriageHuntHandler))
end

function MarriageHunt:onExit()
    UserService:removeEventListener(self.MARRIAGEHUNT)
end

function MarriageHunt:marriageHuntHandler(event)
    local MarriageHunt = protocol.hall.business_pb.DBR_GR_MarriageHunting_Result_Pro()
    MarriageHunt:ParseFromString(event.data)
    if MarriageHunt.nResultCode == 0 then
        self:removeFromParent()
    end
end

function MarriageHunt:createUI()
	local displaySize = cc.size(display.width, display.height);
    local winSize = cc.Director:getInstance():getWinSize();
    -- 蒙板
    local maskLayer = ccui.ImageView:create("black.png");
    maskLayer:setScale9Enabled(true);
    maskLayer:setContentSize(cc.size(winSize.width, winSize.height));
    maskLayer:setPosition(cc.p(displaySize.width / 2, displaySize.height / 2));
    maskLayer:setTouchEnabled(true);
    maskLayer:addTo(self);


    local bgSpritepop = ccui.ImageView:create("common/pop_bg.png");
    bgSpritepop:setScale9Enabled(true);
    bgSpritepop:setContentSize(cc.size(674, 433));
    bgSpritepop:setPosition(cc.p(571,312));
    self:addChild(bgSpritepop);

    local bgSprite = ccui.Layout:create()
    bgSprite:setTouchEnabled(true)
    bgSprite:setAnchorPoint(cc.p(0.5,0.5))
    bgSprite:setContentSize(cc.size(674, 433))
    bgSprite:setPosition(cc.p(571,312));
    self:addChild(bgSprite)
    

    local panel = ccui.ImageView:create("common/panel.png")
    panel:setScale9Enabled(true);
    panel:setContentSize(cc.size(585,280));
    panel:setPosition(332, 251)
    bgSprite:addChild(panel)

    local pop_title = ccui.ImageView:create("common/pop_title.png");
    pop_title:setPosition(cc.p(131,400));
    bgSprite:addChild(pop_title);

    local marriagehunt = display.newTTFLabel({text = "征婚",
                                size = 24,
                                color = cc.c3b(255,233,110),
                                font = FONT_ART_TEXT,
                            })
                :addTo(bgSprite)
    marriagehunt:setPosition(133, 421)
    marriagehunt:setTextColor(cc.c4b(251,248,142,255))
    marriagehunt:enableOutline(cc.c4b(137,0,167,200), 2)
    --彩礼金额：
    local cailijiner = ccui.Text:create("彩礼金额：",FONT_ART_TEXT,20)
    cailijiner:setPosition(153, 347)
    cailijiner:setColor(cc.c3b(255, 233, 110))
    bgSprite:addChild(cailijiner)

    local kuangBg = ccui.ImageView:create("hall/marry/shijiankuang.png")
    kuangBg:setPosition(389, 349)
    kuangBg:setScale9Enabled(true);
    kuangBg:setContentSize(cc.size(340, 38))
    bgSprite:addChild(kuangBg)

    local cailiTextEdit = ccui.EditBox:create(cc.size(320,35), "blank.png");
    -- cailiTextEdit:setAnchorPoint(cc.p(0,0.5));
    cailiTextEdit:setPosition(cc.p(396, 346));
    cailiTextEdit:setFontSize(16);
    cailiTextEdit:setPlaceHolder("请输入彩礼金额，最少50万");
    cailiTextEdit:setPlaceholderFontColor(cc.c3b(139,103,57));
    cailiTextEdit:setPlaceholderFontSize(16);
    cailiTextEdit:setInputMode(InputMode_PHONE_NUMBER);
    cailiTextEdit:setMaxLength(13);
    bgSprite:addChild(cailiTextEdit);
    self.cailiTextEdit = cailiTextEdit

    ------对方身家：
    local cailijiner = ccui.Text:create("对方身家：",FONT_ART_TEXT,20)
    cailijiner:setPosition(153, 294)
    cailijiner:setColor(cc.c3b(255, 233, 110))
    bgSprite:addChild(cailijiner)

    local kuangBg = ccui.ImageView:create("hall/marry/shijiankuang.png")
    kuangBg:setPosition(389, 298)
    kuangBg:setScale9Enabled(true);
    kuangBg:setContentSize(cc.size(340, 38))
    bgSprite:addChild(kuangBg)

    local worthTextEdit = ccui.EditBox:create(cc.size(320,35), "blank.png");
    -- worthTextEdit:setAnchorPoint(cc.p(0,0.5));
    worthTextEdit:setPosition(cc.p(396, 295));
    worthTextEdit:setFontSize(16);
    worthTextEdit:setPlaceHolder("请输入对方身家");
    worthTextEdit:setPlaceholderFontColor(cc.c3b(139,103,57));
    worthTextEdit:setPlaceholderFontSize(16);
    worthTextEdit:setInputMode(InputMode_PHONE_NUMBER);
    worthTextEdit:setMaxLength(13);
    bgSprite:addChild(worthTextEdit);
    self.worthTextEdit = worthTextEdit

    --------对方等级：
    local cailijiner = ccui.Text:create("对方等级：",FONT_ART_TEXT,20)
    cailijiner:setPosition(153, 243)
    cailijiner:setColor(cc.c3b(255, 233, 110))
    bgSprite:addChild(cailijiner)

    local kuangBg = ccui.ImageView:create("hall/marry/shijiankuang.png")
    kuangBg:setPosition(389, 246)
    kuangBg:setScale9Enabled(true);
    kuangBg:setContentSize(cc.size(340, 38))
    bgSprite:addChild(kuangBg)

    local levelTextEdit = ccui.EditBox:create(cc.size(320,35), "blank.png");
    -- levelTextEdit:setAnchorPoint(cc.p(0,0.5));
    levelTextEdit:setPosition(cc.p(396, 243));
    levelTextEdit:setFontSize(16);
    levelTextEdit:setPlaceHolder("请输入对方等级");
    levelTextEdit:setPlaceholderFontColor(cc.c3b(139,103,57));
    levelTextEdit:setPlaceholderFontSize(16);
    levelTextEdit:setInputMode(InputMode_PHONE_NUMBER);
    levelTextEdit:setMaxLength(13);
    bgSprite:addChild(levelTextEdit);
    self.levelTextEdit = levelTextEdit
    --------爱情宣言：
    local cailijiner = ccui.Text:create("爱情宣言：",FONT_ART_TEXT,20)
    cailijiner:setPosition(153, 193)
    cailijiner:setColor(cc.c3b(255, 233, 110))
    bgSprite:addChild(cailijiner)

    local kuangBg = ccui.ImageView:create("hall/marry/shijiankuang.png")
    kuangBg:setPosition(389, 196)
    kuangBg:setScale9Enabled(true);
    kuangBg:setContentSize(cc.size(340, 38))
    bgSprite:addChild(kuangBg)

    local xuanyanTextEdit = ccui.EditBox:create(cc.size(320,35), "blank.png");
    -- xuanyanTextEdit:setAnchorPoint(cc.p(0,0.5));
    xuanyanTextEdit:setPosition(cc.p(396, 193));
    xuanyanTextEdit:setFontSize(16);
    xuanyanTextEdit:setPlaceHolder("请输入爱情宣言");
    xuanyanTextEdit:setPlaceholderFontColor(cc.c3b(139,103,57));
    xuanyanTextEdit:setPlaceholderFontSize(16);
    -- xuanyanTextEdit:setInputMode(InputMode_PHONE_NUMBER);
    xuanyanTextEdit:setMaxLength(23);
    bgSprite:addChild(xuanyanTextEdit);
    self.xuanyanTextEdit = xuanyanTextEdit

    -----结婚时间：
    local cailijiner = ccui.Text:create("结婚时间：",FONT_ART_TEXT,20)
    cailijiner:setPosition(153, 148)
    cailijiner:setColor(cc.c3b(255, 233, 110))
    bgSprite:addChild(cailijiner)
    local timeTxt = {"天","小时","分"}
    self.timeEdit = {}
    local intervalx = 125
    for i=1,3 do 	
    	-- local i = 1
	    local kuangBg = ccui.ImageView:create("hall/marry/shijiankuang.png")
	    kuangBg:setPosition(222+intervalx*(i-1), 149)
	    kuangBg:setAnchorPoint(cc.p(0,0.5));
	    kuangBg:setScale9Enabled(true);
	    kuangBg:setContentSize(cc.size(64, 38))
	    bgSprite:addChild(kuangBg)

	    local tianTextEdit = ccui.EditBox:create(cc.size(64,35), "blank.png");
	    tianTextEdit:setAnchorPoint(cc.p(0,0.5));
	    tianTextEdit:setPosition(cc.p(230+intervalx*(i-1), 146));

	    tianTextEdit:setFontSize(16);
	    tianTextEdit:setPlaceHolder("0");
	    tianTextEdit:setPlaceholderFontColor(cc.c3b(255,255,100));
	    tianTextEdit:setPlaceholderFontSize(16);

	    tianTextEdit:setInputMode(InputMode_PHONE_NUMBER);
	    tianTextEdit:setMaxLength(3);
        if i ~= 1 then
            tianTextEdit:setMaxLength(2);
        end

	    bgSprite:addChild(tianTextEdit);
	    self.timeEdit[i] = tianTextEdit

	    local tian = ccui.Text:create("天",FONT_ART_TEXT,20)
	    tian:setPosition(292+intervalx*(i-1), 149)
	    tian:setAnchorPoint(cc.p(0,0.5))
	    tian:setString(timeTxt[i])
	    tian:setColor(cc.c3b(255, 233, 110))
	    bgSprite:addChild(tian)
    end

    local yes = ccui.Button:create("common/button_green.png")
    bgSprite:addChild(yes)
    yes:setPosition(cc.p(334,72));
    yes:setScale9Enabled(true)
    yes:setContentSize(cc.size(163*1.12, 72))
    yes:setTitleFontName(FONT_ART_BUTTON);
    yes:setTitleText("确定");
    yes:setTitleColor(cc.c3b(255,255,255));
    yes:setTitleFontSize(28);
    yes:getTitleRenderer():enableOutline(COLOR_BTN_BLUE,2)
    yes:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:submitHandler()
            end
        end
    )

    local exit = ccui.Button:create("common/close.png");
    exit:setPosition(cc.p(649,406));
    bgSprite:addChild(exit);
    exit:setPressedActionEnabled(true);
    exit:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:removeFromParent()
            end
        end
    )
end

function MarriageHunt:submitHandler()
	local lGiftForMarry = tonumber(self.cailiTextEdit:getText()) or 0
	local lTargetUserGold = tonumber(self.worthTextEdit:getText()) or 0
	local dwTargetUserLevel = LevelSetting[tonumber(self.levelTextEdit:getText())] or 0
	local strLoveStroy = self.xuanyanTextEdit:getText() or 0
    local day = 0
    local hour = 0
    local minute = 0
    if #self.timeEdit[1]:getText()>0 then
        day = self.timeEdit[1]:getText()
    end
    if #self.timeEdit[2]:getText()>0 then
        hour = self.timeEdit[2]:getText()
    end
    if #self.timeEdit[3]:getText()>0 then
        minute = self.timeEdit[3]:getText()
    end
	local dwTimeLimit = tonumber(day*24*60+hour*60+minute)

    if lGiftForMarry < 500000 then
        Hall.showTips("彩礼金额不能低于50万", 1)
        return        
    end

    if dwTimeLimit <= 0 then
        Hall.showTips("请填写结婚时间", 1)
        return
    end

	print(lGiftForMarry,lTargetUserGold,dwTargetUserLevel,strLoveStroy,dwTimeLimit)
    
    UserService:sendMarriageHunting(lGiftForMarry,lTargetUserGold,dwTargetUserLevel,strLoveStroy,dwTimeLimit)
end

return MarriageHunt