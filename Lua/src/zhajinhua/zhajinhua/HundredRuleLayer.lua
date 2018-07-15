local HundredRuleLayer = class("HundredRuleLayer", function() return display.newLayer() end)
local EffectFactory = require("commonView.EffectFactory")
function HundredRuleLayer:ctor()
    -- self:setNodeEventEnabled(true);
	self:createUI()
end
function HundredRuleLayer:createUI()
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

    local titleName = ccui.ImageView:create("hundredRoom/hundredRule/title.png");
    titleName:setPosition(cc.p(214, 65))
    titleBg:addChild(titleName);

    local shiyitu = ccui.ImageView:create("hundredRoom/hundredRule/shiyitu.png");
    shiyitu:setPosition(cc.p(320, 210))
    bgLayer:addChild(shiyitu);

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
return HundredRuleLayer