local MarriagePropose = class("MarriagePropose",function ()
	return display.newLayer()
end)

function MarriagePropose:ctor(huntMarriage)
	self.userID = huntMarriage.dwUserID
	self:createUI(huntMarriage)
end

function MarriagePropose:createUI(huntMarriage)
	local displaySize = cc.size(display.width, display.height);
    local winSize = cc.Director:getInstance():getWinSize();
    -- 蒙板
    local maskLayer = ccui.ImageView:create("black.png");
    maskLayer:setScale9Enabled(true);
    maskLayer:setContentSize(cc.size(winSize.width, winSize.height));
    maskLayer:setPosition(cc.p(displaySize.width / 2, displaySize.height / 2));
    maskLayer:setTouchEnabled(true);
    maskLayer:addTo(self);

    local bgSprite = ccui.ImageView:create("common/pop_bg.png");
    bgSprite:setScale9Enabled(true);
    bgSprite:setContentSize(cc.size(674, 433));
    bgSprite:setPosition(cc.p(571,312));
    self:addChild(bgSprite);

    local panel = ccui.ImageView:create("common/panel.png")
    panel:setScale9Enabled(true);
    panel:setContentSize(cc.size(585,280));
    panel:setPosition(332, 251)
    bgSprite:addChild(panel)

    local pop_title = ccui.ImageView:create("common/pop_title.png");
    pop_title:setPosition(cc.p(131,400-10));
    bgSprite:addChild(pop_title);

    local marriagehunt = display.newTTFLabel({text = "送彩礼",
                                size = 24,
                                color = cc.c3b(255,233,110),
                                font = FONT_ART_TEXT,
                            })
                :addTo(bgSprite)
    marriagehunt:setPosition(133, 421-10)
    marriagehunt:setTextColor(cc.c4b(251,248,142,255))
    marriagehunt:enableOutline(cc.c4b(137,0,167,200), 2)

    local name = huntMarriage.szNickName--"就爱斗地主"
    local money = huntMarriage.lGiftForMarry
    local TargetUserGold = huntMarriage.lTargetUserGold

    local TargetUserLevel = getLevelByExp(huntMarriage.dwTargetUserLevel)
    local lefttime = huntMarriage.dwTimeLimit
    local minute = lefttime%60
    local hour = (lefttime-minute)/60%24
    local day = ((lefttime-minute)/60-hour)/24
    local leftTimeTxt = day.."天"..hour.."小时"..minute.."分"
    local contentTxt = "您将赠送\""..name.."\""..money.."彩礼，赠送后就确立游戏内婚姻关系咯!\n要求身家："..TargetUserGold.."\n要求等级："..TargetUserLevel.."\n结婚时间："..leftTimeTxt
    local content = ccui.Text:create("","",26)
    content:setPosition(568, 332)
    content:setString(contentTxt)
    content:setColor(cc.c3b(216, 213, 111))
    content:setTextAreaSize(cc.size(470,200))
    content:ignoreContentAdaptWithSize(false)
    content:setTextHorizontalAlignment(0)
    content:setTextVerticalAlignment(0)
    self:addChild(content)    
    self.content = content

    local yes = ccui.Button:create("common/button_green.png")
    bgSprite:addChild(yes)
    yes:setPosition(cc.p(334,72));
    yes:setScale9Enabled(true)
    yes:setContentSize(cc.size(163*1.12, 72))
    yes:setTitleFontName(FONT_ART_BUTTON);
    yes:setTitleText("赠送");
    yes:setTitleColor(cc.c3b(255,255,255));
    yes:setTitleFontSize(28);
    yes:getTitleRenderer():enableOutline(COLOR_BTN_BLUE,2)
    yes:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:giveHandler(money)
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

function MarriagePropose:giveHandler(money)
    
    UserService:sendMarriagePropose(self.userID,money)
end

return MarriagePropose