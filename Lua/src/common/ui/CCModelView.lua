--
-- Author: Your Name
-- Date: 2015-04-14 20:00:08
--


local CCModelView = class("CCModelView", function() return display.newLayer(); end );

function CCModelView:ctor()
    local winSize = cc.Director:getInstance():getWinSize()
    -- 蒙板
    local maskLayer = ccui.ImageView:create()
    maskLayer:loadTexture("black.png")
    maskLayer:setOpacity(153)
    maskLayer:setScale9Enabled(true)
    maskLayer:setCapInsets(cc.rect(4,4,1,1))
    maskLayer:setContentSize(cc.size(winSize.width, winSize.height));
    maskLayer:setPosition(cc.p(DESIGN_WIDTH/2,DESIGN_HEIGHT/2));
    maskLayer:setTouchEnabled(true);
    self:addChild(maskLayer)
end

return CCModelView
