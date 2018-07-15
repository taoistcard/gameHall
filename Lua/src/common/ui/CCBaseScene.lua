local CCBaseScene = class("CCBaseScene", function()
    return display.newScene()
end)

function CCBaseScene:ctor()
    local winSize = cc.Director:getInstance():getWinSize()
    -- 基本容器 1136*640
    self.container = cc.Layer:create()
    self.container:setContentSize(cc.size(display.width,display.height))
    self.container:setPosition(cc.p(winSize.width/2,winSize.height/2));
    self.container:setAnchorPoint(cc.p(0.5,0.5))
    self.container:ignoreAnchorPointForPosition(false)
    self:addChild(self.container)
end

function CCBaseScene:onEnter()
end

function CCBaseScene:onExit()
end

return CCBaseScene