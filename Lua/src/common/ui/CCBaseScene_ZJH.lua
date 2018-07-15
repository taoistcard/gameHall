local CCBaseScene_ZJH = class("CCBaseScene_ZJH", function()
    return display.newScene()
end)

function CCBaseScene_ZJH:ctor()
    local winSize = cc.Director:getInstance():getWinSize()
    -- 基本容器 1136*640
    self.container = cc.Layer:create()
    self.container:setContentSize(cc.size(1136,640))
    self.container:setPosition(cc.p(winSize.width/2-568,winSize.height/2-320));
    -- self.container:setAnchorPoint(cc.p(0.5,0.5))
    -- self.container:ignoreAnchorPointForPosition(false)
    self:addChild(self.container)
end

function CCBaseScene_ZJH:onEnter()
end

function CCBaseScene_ZJH:onExit()
end

return CCBaseScene_ZJH