local JiShaoChengDuo = class("JiShaoChengDuo",function() return display.newLayer() end)

local huodongManager = require("hall.huodong.HuoDongManager"):getInstance();
local EffectFactory = require("commonView.EffectFactory")
local VIP_LABEL = {
        "绿钻",
        "蓝钻",
        "紫钻",
        "金钻",
        "王冠",
        }

local VIP_IMG = {
        "hall/shop/zuan1.png",
        "hall/shop/zuan2.png",
        "hall/shop/zuan3.png",
        "hall/shop/zuan4.png",
        "hall/shop/zuan5.png"
        }

local choumaindex = {1,1,2,2,2,3,3,3,3};

function JiShaoChengDuo:ctor(romscene)
    
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    self:setNodeEventEnabled(true)

    self.roomscene = romscene
    local winSize = cc.Director:getInstance():getWinSize()
    local contentSize = cc.size(winSize.width,winSize.height)
    self:setContentSize(contentSize)

    -- 蒙板
    local maskLayer = ccui.ImageView:create()
    maskLayer:loadTexture("common/black.png")
    maskLayer:setContentSize(contentSize);
    maskLayer:setScale9Enabled(true)
    maskLayer:setCapInsets(cc.rect(4,4,1,1))
    maskLayer:setPosition(cc.p(contentSize.width/2, DESIGN_HEIGHT/2));
    maskLayer:setTouchEnabled(true)
    self:addChild(maskLayer)

    self:createUI();

	huodongManager:requestLeiJiChongZhiInfo(DataManager:getMyUserID(), handler(self, self.onLeiJiInfoHandler))
	-- huodongManager:requestLeiJiChongZhiInfo(2152743, handler(self, self.onLeiJiInfoHandler))
    
	onUmengEvent("jishaochengduo")
end

function JiShaoChengDuo:createUI()
    local contentSize = self:getContentSize()

    local backConainer = ccui.ImageView:create("hall/huodong/bg_activity.png");
    backConainer:setScale9Enabled(true);
    backConainer:setContentSize(cc.size(940, 540));
    backConainer:setPosition(cc.p(DESIGN_WIDTH/2, DESIGN_HEIGHT/2-20));
    self:addChild(backConainer);

    local exit = ccui.Button:create("common/close2.png");
    exit:setPosition(cc.p(930, 530));
    backConainer:addChild(exit);
    exit:setPressedActionEnabled(true);
    exit:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                package.loaded["hall.huodong.JiShaoChengDuo"] = nil
                self:removeFromParent();
            end
        end
    )

    local titlebg = ccui.ImageView:create("hall/huodong/title_bg.png")
    titlebg:setPosition(cc.p(470, 550));
    backConainer:addChild(titlebg)

    local girl = ccui.ImageView:create("hall/huodong/title_word.png")
    girl:setPosition(cc.p(310, 43));
    titlebg:addChild(girl)

    local girl = ccui.ImageView:create("hall/huodong/girl.png")
    girl:setPosition(cc.p(55, 315));
    backConainer:addChild(girl)

    local listviewwidth = 680    
    self.listView = ccui.ListView:create()
    self.listView:setDirection(ccui.ScrollViewDir.horizontal)
    self.listView:setBounceEnabled(true)
    self.listView:setContentSize(cc.size(listviewwidth, 410))
    self.listView:setAnchorPoint(cc.p(0, 0))
    self.listView:setPosition(190, 105)
    backConainer:addChild(self.listView)

    local maskl = ccui.ImageView:create("common/horizental_mask.png")
    maskl:setScale9Enabled(true)
    maskl:setContentSize(cc.size(32, 410))
    maskl:setFlippedX(true)
    maskl:setAnchorPoint(cc.p(0,0))
    maskl:setPosition(210, 105)
    backConainer:addChild(maskl)

    local maskr = ccui.ImageView:create("common/horizental_mask.png")
    maskr:setScale9Enabled(true)
    maskr:setContentSize(cc.size(32, 410))
    maskr:setAnchorPoint(cc.p(1,0))
    maskr:setPosition(880, 105)
    backConainer:addChild(maskr)

    --箭头-右
    local goRight = ccui.ImageView:create("common/ty_jiantou.png");
    goRight:addTo(backConainer)
    goRight:align(display.CENTER, 905, 300)
    goRight:setTouchEnabled(true);
    goRight:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            -- self.listView:scrollToRight(1, true)
            local incontener = self.listView:getInnerContainer()
            local consize = incontener:getContentSize()
            local percent = (-incontener:getPositionX() + listviewwidth)/(consize.width - listviewwidth)

            if percent < 0 then percent = 0
            elseif percent > 1 then percent = 1 end
            self.listView:scrollToPercentHorizontal(100 * percent, 1, true)
        end
    end)

    --箭头-左
    local goLeft = ccui.ImageView:create("common/ty_jiantou.png");
    goLeft:setFlippedX(true)
    goLeft:addTo(backConainer)
    goLeft:align(display.CENTER, 160, 300)
    goLeft:setTouchEnabled(true);
    goLeft:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            -- self.listView:scrollToLeft(1, true)
            local incontener = self.listView:getInnerContainer()
            local consize = incontener:getContentSize()
            local percent = (-incontener:getPositionX() - listviewwidth)/(consize.width - listviewwidth)
            if percent < 0 then percent = 0
            elseif percent > 1 then percent = 1 end
            self.listView:scrollToPercentHorizontal(100 * percent, 1, true)
        end
    end)
    

    --底部
    local botmbg = ccui.ImageView:create("hall/huodong/bottom_bg.png");
    botmbg:setScale9Enabled(true);
    botmbg:setContentSize(cc.size(990, 116));
    botmbg:setPosition(470, 80);
    backConainer:addChild(botmbg);

    local zhshi = ccui.ImageView:create("hall/huodong/zhuangshi.png");
    zhshi:setPosition(10, 40);
    backConainer:addChild(zhshi);

    local expPos = cc.p(425, 50);
    local expBgSprite = ccui.ImageView:create("hall/huodong/progressbar_bg.png");
    expBgSprite:setScale9Enabled(true);
    expBgSprite:setContentSize(cc.size(652, 7));
    expBgSprite:setPosition(expPos);
    botmbg:addChild(expBgSprite);

    local unit = 652 / 8
    local posx = {0, unit, unit * 2, unit * 3, unit * 4, unit * 5, unit * 6, unit * 7, unit * 8}
    for _, pox in ipairs(posx) do
        local dot = display.newSprite("hall/huodong/dot_black.png"):addTo(expBgSprite)
        --dot:setScale(1.5)
        dot:setPosition(pox, 4)
    end

    local expNowExp = display.newProgressTimer("hall/huodong/progressbar.png", display.PROGRESS_TIMER_BAR);
    expNowExp:setAnchorPoint(cc.p(0, 0.5))
    expNowExp:setPosition(0, 4)
    expNowExp:setMidpoint(cc.p(0, 0.5))
    expNowExp:setBarChangeRate(cc.p(1.0, 0))
    expBgSprite:addChild(expNowExp);
    self.expNowExp = expNowExp;

    local leichong = {"50","100","200","400","600","1000","2000","5000","10000"}
    self.lightdots = {}
    self.moneyNums = {}
    for k, pox in ipairs(posx) do
        local dot = display.newSprite("hall/huodong/dot.png"):addTo(expBgSprite)
        dot:setPosition(pox, 4)
        dot:setVisible(false)
        self.lightdots[#self.lightdots + 1] = dot

        local jine = ccui.Text:create(leichong[k], FONT_ART_TEXT, 28)
        jine:setColor(cc.c3b(183,100,163))
        jine:setPosition(pox, -22)
        expBgSprite:addChild(jine)
        self.moneyNums[#self.moneyNums+1]=jine
    end

    local button = ccui.Button:create()
    button:setTitleFontName(FONT_ART_TEXT);
    button:setTitleText("充值");
    button:loadTextures("hall/shop/buyButton.png", "hall/shop/buyButton.png")

    button:setTitleColor(cc.c3b(255,255,255));
    button:setTitleFontSize(30);
    button:setPressedActionEnabled(true);
    button:getTitleRenderer():enableOutline(COLOR_BTN_BLUE,1);
    button:addTouchEventListener(
        function ( sender,eventType )
            if eventType == ccui.TouchEventType.ended then
                --调起充值界面
                self.roomscene:onClickBuy()
            end
        end
    )
    button:setPosition(890, 40)
    botmbg:addChild(button)

end

function JiShaoChengDuo:onLeiJiInfoHandler()
	local lightArrIndexs = huodongManager:getLightLingQuBtnArray()
	--dump(lightArrIndexs)

    local alreadyList = huodongManager:getAlreadyLingQuBtnArray()
    --dump(alreadyList)

    local myleijiInfo = huodongManager:getMyLeiJiChongZhiInfo()

    local leijiItems = huodongManager:getLeiJiChongZhiItems()

    self.listView:removeAllChildren()

    for ind, itemconf in ipairs(leijiItems) do
        local itemLayer = ccui.ImageView:create("hall/huodong/item_bg.png")
        itemLayer:setPosition(103, 220)

        --筹码
        local pic = EffectFactory:ceateChouMaEffect(choumaindex[ind])
        pic:setPosition(97, 220)
        itemLayer:addChild(pic)

        local chouma = ccui.Text:create(FormatNumToString(itemconf.score), FONT_ART_TEXT, 30)
        chouma:setAnchorPoint(cc.p(0.5, 0.5))
        chouma:setPosition(97, 135)
        chouma:setColor(cc.c4b(255, 255, 31,255))
        chouma:enableOutline(cc.c4b(61, 44, 5, 255), 2)
        itemLayer:addChild(chouma)

        --送vip
        local song = ccui.ImageView:create("hall/huodong/song.png")
        song:setPosition(36, 95)
        itemLayer:addChild(song)
        song:setScale(0.8)

        local zuan = ccui.ImageView:create(VIP_IMG[itemconf.memberorder]);
        zuan:setPosition(80, 95)
        itemLayer:addChild(zuan)
        zuan:setScale(0.8)

        local jine = ccui.Text:create("X"..itemconf.day.."天", FONT_ART_TEXT, 26)
        jine:setAnchorPoint(cc.p(0, 0.5))
        jine:setPosition(100, 90)
        jine:setColor(cc.c4b(100, 230, 42, 255))
        jine:enableOutline(cc.c4b(65, 44, 9, 255), 2)
        itemLayer:addChild(jine)


        --累积充值
        local jine = ccui.Text:create("当天累计充值", FONT_ART_TEXT, 22)
        jine:setPosition(103,45)
        jine:setColor(cc.c4b(255, 255, 254, 255))
        -- jine:enableOutline(cc.c4b(26, 13, 6, 255), 2)
        itemLayer:addChild(jine)

        local jine = ccui.Text:create(itemconf.amount.."元", FONT_ART_TEXT, 24)
        jine:setPosition(103, 20)
        jine:setColor(cc.c4b(45, 255, 38,255))
        -- jine:enableOutline(cc.c4b(26, 13, 6, 255), 2)
        itemLayer:addChild(jine)
        

        local islingqu = false
        for _, alind in ipairs(alreadyList) do 
            if ind == tonumber(alind) then 
                islingqu = true
                break
            end
        end

        local canlingqu = false
        for _, canind in ipairs(lightArrIndexs) do
            if canind == ind then
                canlingqu = true break
            end
        end
 
        local button = ccui.Button:create()
        button:setTitleFontName(FONT_ART_TEXT);
        button:setTag(itemconf.key)
        if islingqu == true then
            button:setTitleText("已领取");
            button:loadTextures("hall/shop/buyButton.png", "hall/shop/buyButton.png")
            button:setOpacity(125)
        else
            button:setTitleText("领取");
            button:loadTextures("hall/shop/buyButton.png", "hall/shop/buyButton.png")
        end

        if canlingqu == true then
            
        else
            --button:setEnabled(false)
        end

        button:setTitleColor(cc.c3b(255,255,255));
        button:setTitleFontSize(30);
        button:setPressedActionEnabled(true);

        button:getTitleRenderer():enableOutline(COLOR_BTN_BLUE,1);
        button:addTouchEventListener(
            function ( sender,eventType )
                if eventType == ccui.TouchEventType.ended then
                    huodongManager:requestGetReward(DataManager:getMyUserID(), button:getTag(), handler(self, self.onGetLeiJiInfoHandler))
                    -- huodongManager:requestGetReward(2152743, button:getTag(), handler(self, self.onGetLeiJiInfoHandler))
                end
            end
        )
        button:setPosition(100, -50)
        itemLayer:addChild(button)


        local custom_item = ccui.Layout:create()
        custom_item:setTouchEnabled(true)
        custom_item:setContentSize(cc.size(215, 370))
        custom_item:addChild(itemLayer)
        
        self.listView:pushBackCustomItem(custom_item)
    end

    for k, v in ipairs(self.lightdots) do
        if k <= #alreadyList then
            v:setVisible(true)
            self.moneyNums[k]:setColor(cc.c3b(255,197,21))
        end
    end

    local unit = 652 / 8

    self.expNowExp:setPercentage(100*((#alreadyList - 1) * unit)/652)

end

function JiShaoChengDuo:onGetLeiJiInfoHandler(result)

    if result.ret == 2 then
        Hall.showTips(result.msg, 3)
    else
        local tipstr = "恭喜获得 : "..VIP_LABEL[result.memberorder].." X "..result.day.." 天 + "..FormatNumToString(result.score) .. " 筹码"
        Hall.showTips(tipstr, 3)
    end

    scheduler.performWithDelayGlobal(function() 
        huodongManager:requestLeiJiChongZhiInfo(DataManager:getMyUserID(), handler(self, self.onLeiJiInfoHandler))
    end, 0.3)
end

return JiShaoChengDuo


