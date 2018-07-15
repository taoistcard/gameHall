local updateInfoLayer = class("updateInfoLayer", function() return display.newLayer(); end )

function updateInfoLayer:ctor()
	self:createUI()
end

function updateInfoLayer:createUI()
    local displaySize = cc.size(display.width, display.height);
    local winSize = cc.Director:getInstance():getWinSize();

    -- 蒙板
    local maskLayer = ccui.ImageView:create("black.png");
    maskLayer:setScale9Enabled(true);
    maskLayer:setContentSize(cc.size(winSize.width, winSize.height));
    -- maskLayer:setAnchorPoint(cc.p(0,0))
    maskLayer:setPosition(cc.p(DESIGN_WIDTH/2, DESIGN_HEIGHT/2));
    maskLayer:setTouchEnabled(true);
    maskLayer:addTo(self);

    local containerLayer = ccui.Layout:create()
    -- containerLayer:setAnchorPoint(cc.p(0.5,0.5))
    containerLayer:setContentSize(cc.size(1136,640))
    -- containerLayer:setPosition(-1136/2+724/2, -640/2+514/2)
    -- containerLayer:setBackGroundColorType(1)
    -- containerLayer:setBackGroundColor(cc.c3b(100,123,100))
    self.containerLayer = containerLayer
    self:addChild(containerLayer)

    local shopBg = ccui.ImageView:create("shopBg.png")
    shopBg:setPosition(611,306)
    shopBg:setScale9Enabled(true)
    shopBg:setContentSize(cc.size(610, 407));
    containerLayer:addChild(shopBg)

    local kuangBg = ccui.ImageView:create("kuangBg.png")
    kuangBg:setPosition(304,204)
    kuangBg:setScale9Enabled(true)
    kuangBg:setContentSize(cc.size(618, 412));
    shopBg:addChild(kuangBg)
   
    local info = ccui.Text:create("","",24)
    info:setTextColor(cc.c4b(201,179,236,255))
    info:enableOutline(cc.c4b(42,18,60,255), 2)
    info:setPosition(cc.p(55,372))
    info:setAnchorPoint(cc.p(0,1))
    -- info:setString("更新内容：\n1.游戏改版为大厅模式，新增捕鱼等游戏。\n2.修复选桌界面退到后台后无法坐下的问题\n3.修复入座后看不到5号椅子的玩家的牌的bug\n4.加入500万筹码和1千万筹码")
    info:setString("更新内容：\n1.修复旁观后，点击快速开始，开始不了游戏的问题。\n2.加入游戏版本号的显示")
    info:setTextAreaSize(cc.size(500,350))
    info:ignoreContentAdaptWithSize(false)
    info:setTextHorizontalAlignment(0)
    info:setTextVerticalAlignment(0)
    shopBg:addChild(info)


    local exit = ccui.Button:create("close1.png", "close1.png");
    shopBg:addChild(exit);
    exit:setPosition(600,392);
    exit:onClick(
        function()
    	   SHOWUPDATEINFO = false
    	   self:removeFromParent();
        end
    );

end

return updateInfoLayer