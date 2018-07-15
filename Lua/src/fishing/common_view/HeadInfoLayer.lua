--
-- Author: Your Name
-- Date: 2015-04-14 20:00:08
--
local HeadInfoLayer = class("HeadInfoLayer", function() return ccui.ImageView:create("hall/hall_head_info.png"); end )

function HeadInfoLayer:ctor()
    self:setNodeEventEnabled(true)
    self:setTouchEnabled(true)
    self:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.began then
                self:setScale(1.1)
            elseif eventType == ccui.TouchEventType.ended then
                self:setScale(1.0)
                if self.callback then
                    self.callback()
                end
            elseif eventType == ccui.TouchEventType.canceled then
                self:setScale(1.0)
            end
        end
    )

    self.name = display.newTTFLabel({text = "游客..",
                                        size = 28,
                                        color = cc.c3b(255,255,255),
                                        font = FONT_PTY_TEXT
                                    })
    self.name:enableOutline(cc.c4b(141,0,166,255*0.7),2)
    self.name:setPosition(cc.p(94, 90))
    self.name:setAnchorPoint(cc.p(0,0.5))
    self:addChild(self.name)

    self.coin = display.newTTFLabel({text = "0",
                                        size = 20,
                                        color = cc.c3b(255,255,255),
                                        font = FONT_PTY_TEXT
                                    })
    self.coin:enableOutline(cc.c4b(141,0,166,255*0.7),2)
    self.coin:setPosition(cc.p(120, 52))
    self.coin:setAnchorPoint(cc.p(0,0.5))
    self:addChild(self.coin)

end

function HeadInfoLayer:setHeadIcon(facdID,platformID,platformFace)
    local id = facdID
    if id == 999 then
        id = 1
    end
    local headView = require("show.popView_Hall.HeadView").new(id,true);
    headView:setPosition(cc.p(40,self:getContentSize().height/2+8));
    headView:setScale(0.64);
    self:addChild(headView);
    if facdID == 999 then
        headView:setNewHead(facdID, platformID, platformFace);
    end
end

function HeadInfoLayer:setName(name)
	self.name:setString(FormotGameNickName(name,3))
end

function HeadInfoLayer:setCoin(coin)
	self.coin:setString(""..FormatNumToString(coin))
end

function HeadInfoLayer:onEnter()
end

function HeadInfoLayer:onExit()
end

return HeadInfoLayer
