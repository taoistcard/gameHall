local HundredBankerLayer = class("HundredBankerLayer", function() return display.newLayer() end)
local EffectFactory = require("commonView.EffectFactory")
function HundredBankerLayer:ctor()
    -- self:setNodeEventEnabled(true);
	self:createUI()
    self:refreshItem()
end
function HundredBankerLayer:createUI()
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


    local bgSprite = ccui.ImageView:create("hundredRoom/commonBg.png");
    -- bgSprite:setScale9Enabled(true);
    -- bgSprite:setContentSize(cc.size(642, 452));
    bgSprite:setPosition(cc.p(576,299));
    self:addChild(bgSprite);

    local animation = EffectFactory:getInstance():getPaoMaDeng()
    animation:setPosition(318,214)
    bgSprite:addChild(animation)

    local bgLayer = ccui.Layout:create()
    bgLayer:setContentSize(cc.size(636, 429))
    bgLayer:setPosition(cc.p(0,0))
    bgLayer:setAnchorPoint(cc.p(0.0,0.0))
    bgSprite:addChild(bgLayer, 1)
    
    local titleBg = ccui.ImageView:create("hundredRoom/titleBg.png");
    -- titleBg:setScale9Enabled(true);
    -- titleBg:setContentSize(cc.size(235, 58));
    titleBg:setPosition(cc.p(322, 425));
    bgSprite:addChild(titleBg,2);

    local titleName = ccui.ImageView:create("hundredRoom/hundredBanker/title.png");
    titleName:setPosition(cc.p(214, 65))
    titleBg:addChild(titleName);

    local kuang = ccui.ImageView:create("hundredRoom/hundredBanker/kuang.png");
    kuang:setPosition(cc.p(316, 259))
    bgLayer:addChild(kuang);


    --listview
    local list = ccui.ListView:create()
    list:setDirection(ccui.ScrollViewDir.vertical)
    list:setBounceEnabled(true)
    list:setContentSize(cc.size(545, 250))
    list:setPosition(42, 130)
    -- list:setBackGroundColorType(1)
    -- list:setBackGroundColor(cc.c3b(100,123,100))
    bgLayer:addChild(list)
    self.list = list

    local tip = ccui.Text:create("上庄至少需要：10000000", FONT_ART_TEXT, 24)
    tip:setTextColor(cc.c4b(255,255,255,255))
    tip:setAnchorPoint(cc.p(0.5, 0.5))
    tip:setPosition(309,108)
    bgLayer:addChild(tip)


    local shangzhuang = ccui.Button:create("hundredRoom/hundredBanker/btn.png")
    -- shangzhuang:loadTextures("hundredRoom/hundredBanker/btn.png")
    shangzhuang:setPressedActionEnabled(true);
    shangzhuang:setTitleText("我要上庄")
    shangzhuang:setTitleFontSize(26);
    shangzhuang:setTitleColor(display.COLOR_WHITE);
    shangzhuang:setPosition(cc.p(310, 63))
    shangzhuang:addTouchEventListener(
                function(sender,eventType)
                    if eventType == ccui.TouchEventType.ended then
                        self:shangzhuangHandler()
                    end
                end
            )
    bgLayer:addChild(shangzhuang)

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
function HundredBankerLayer:shangzhuangHandler()
    -- body
end
function HundredBankerLayer:refreshItem()
    -- body
    for i=1,10 do
        local custom_item = ccui.Layout:create()
        custom_item:setContentSize(cc.size(545, 96))
        custom_item:setPosition(cc.p(0,0))

        local bankerIcon = ccui.ImageView:create("hundredRoom/hundredBanker/bankerIcon.png");
        bankerIcon:setPosition(53,46);
        custom_item:addChild(bankerIcon)

        local headview = require("commonView.HeadView").new(1)
        headview:setPosition(206,49)
        headview:setScale(0.64)
        custom_item:addChild(headview)

        local name = ccui.Text:create(FormotGameNickName("v.nickName", 8), "", 22)
        name:setTextColor(cc.c4b(255,255,255,255))
        name:setAnchorPoint(cc.p(0, 0.5))
        name:setPosition(250,45)
        custom_item:addChild(name)

        local chipIcon = ccui.ImageView:create("common/chouma_icon.png");
        chipIcon:setPosition(375,46);
        chipIcon:setScale(0.75)
        custom_item:addChild(chipIcon)

        local chip = ccui.Text:create("100000", "", 22)
        chip:setTextColor(cc.c4b(255,255,255,255))
        chip:setAnchorPoint(cc.p(0, 0.5))
        chip:setPosition(403,45)
        -- chip:setName("chip")
        custom_item:addChild(chip)

        self.list:pushBackCustomItem(custom_item)
    end
end
return HundredBankerLayer