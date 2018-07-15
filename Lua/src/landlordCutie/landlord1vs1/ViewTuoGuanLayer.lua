--
-- Author: <zhaxun>
-- Date: 2015-05-28 16:23:43
--
local EffectFactory = require("commonView.DDZEffectFactory")


local ViewTuoGuanLayer = class( "ViewTuoGuanLayer", function() return display.newNode() end)

function ViewTuoGuanLayer:switchChairID()
    if self.myChairID == 1 then
        self.nextID = 2
        self.preID = 3
    elseif self.myChairID == 2 then
        self.nextID = 1
        self.preID = 3
    else
        print("ViewTuoGuanLayer 座位分配失败！", self.myChairID)
    end
end

function ViewTuoGuanLayer:ctor(param)

	self.data = param.data

    local winSize = cc.Director:getInstance():getWinSize()
    self.myTG = display.newColorLayer(cc.c4b(255,255,255,0)):addTo(self):hide()
    self.myTG:setContentSize(cc.size(winSize.width, winSize.height))
    -- self.myTG:align(display.CENTER, display.cx, display.cy)

    local button = ccui.Button:create("common/common_button2.png","common/common_button2.png");
    button:setScale9Enabled(true);
    button:setContentSize(cc.size(200, 70));
    --button:setCapInsets(cc.rect(130, 33, 1, 1));
    --button:setPosition(cc.p(840,56));
    button:setTitleFontName(FONT_ART_BUTTON);
    button:setTitleText("取消托管");
    button:setTitleColor(cc.c3b(255,255,255));
    button:setTitleFontSize(36);
    button:setPressedActionEnabled(true);
    button:getTitleRenderer():enableOutline(COLOR_BTN_BLUE,2);
    --button:getTitleRenderer():enableShadow();
    button:addTouchEventListener(
        function ( sender,eventType )
            if eventType == ccui.TouchEventType.ended then
                param.callfunc()
                SoundManager.playSound("sound/buttonclick.mp3")
            end
        end
        )
    button:align(display.CENTER, display.cx, display.cy-170)
    button:addTo(self.myTG,1)

	-- self.preSprTG = cc.Sprite:create()
	-- self.preSprTG:addTo(self):align(display.CENTER, display.cx-450, display.cy+90):hide()

	self.nextSprTG = cc.Sprite:create()
	self.nextSprTG:addTo(self):align(display.CENTER, display.cx+450, display.cy+90):hide()
    
    self.myChairID = DataManager:getMyChairID()
    self:switchChairID()

end

function ViewTuoGuanLayer:onEnter()
    -- self:test()
end

function ViewTuoGuanLayer:onExit()

end

function ViewTuoGuanLayer:test()
	self.myTG:show()
	self.preSprTG:show()
	-- self.nextSprTG:show()
end

function ViewTuoGuanLayer:refresh()

	local bTuoGuan = self.data.isTuoGuan
	if not bTuoGuan then
		self:hide()
	else
		self:show()
	end

   	for k,v in ipairs(bTuoGuan) do
        local chairID = k
        if chairID == self.myChairID then
            if v == 1 then--托管
            	self.myTG:show()
            else
            	self.myTG:hide()
            end

        elseif chairID == self.nextID then
        	if v == 1 then
        		self:showTuoGuan(self.nextSprTG:show())
        	else
        		self.nextSprTG:hide()
        	end

        -- elseif chairID == self.preID then
        -- 	if v == 1 then
        -- 		self:showTuoGuan(self.preSprTG:show())
        -- 	else
        -- 		self.preSprTG:hide()
        -- 	end

        end

    end
end

function ViewTuoGuanLayer:showTuoGuan(target)
    local ani = EffectFactory:getInstance():getAnimationByName("tuoguan")
    target:runAction(cc.RepeatForever:create(
                                    cc.Sequence:create(
                                        cc.Animate:create(ani),
                                        cc.DelayTime:create(2.5))))

end

return ViewTuoGuanLayer