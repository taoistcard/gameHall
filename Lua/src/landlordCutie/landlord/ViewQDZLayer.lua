--
-- Author: <zhaxun>
-- Date: 2015-05-22 09:25:39
--
local GameItemFactory = require("commonView.GameItemFactory"):getInstance()

local ViewQDZLayer = class( "ViewQDZLayer", function() return display.newNode() end )

local posTimer = {
	[1] = cc.p(display.cx,display.cy),
	[2] = cc.p(display.cx + 330, display.cy + 100),
	[3] = cc.p(display.cx - 330, display.cy + 100),
}

function ViewQDZLayer:ctor()

end

function ViewQDZLayer:onEnter()

end

function ViewQDZLayer:onExit()

end

function ViewQDZLayer:showJDZ(index)

	if index > 3 then
		index = index - 3
	end
	self.index = index;


	if not self.btnJDZ then
		self.btnJDZ = GameItemFactory:getBtnJDZ(function() self:onClickJDZ(self.index) end):addTo(self):align(display.CENTER, display.cx-150, display.cy)
	end

	if not self.btnBJDZ then
		self.btnBJDZ = GameItemFactory:getBtnBJDZ(function() self:onClickBJDZ(self.index) end):addTo(self):align(display.CENTER, display.cx+150, display.cy)
	end

	if index == 1 then
		self.btnJDZ:show();
		self.btnBJDZ:show();
	else
		self.btnJDZ:hide()
		self.btnBJDZ:hide()
	end

	--定时闹钟
	if not self.timer then
		self.timer = require("commonView.CCTimer").new():addTo(self)
	end
	self.timer:setPosition(posTimer[self.index])
	self.timer:startTimer(10, function() self:showJDZ(self.index+1) end)

end

function ViewQDZLayer:showQDZ(index)

	if index > 3 then
		index = index - 3
	end
	self.index = index
	
	if not self.btnQDZ then
		self.btnQDZ = GameItemFactory:getBtnQDZ(function() self:onClickQDZ(self.index) end)
                		:addTo(self)
                		:align(display.CENTER, display.cx - 150, display.cy)
	end

	if not self.btnBQDZ then
		self.btnBQDZ = GameItemFactory:getBtnBQDZ(function() self:onClickBQDZ(self.index) end)
                		:addTo(self)
                		:align(display.CENTER, display.cx + 150, display.cy)
	end

	if index == 1 then
		self.btnQDZ:show();
		self.btnBQDZ:show();
	else
		self.btnQDZ:hide()
		self.btnBQDZ:hide()
	end
	--定时闹钟
	self.timer:setPosition(posTimer[self.index])
	self.timer:startTimer(10, function() self:showQDZ(self.index+1) end)
end

function ViewQDZLayer:onClickJDZ()
	SoundManager.playSound("sound/buttonclick.mp3")

	self.timer:stopTimer();
	self:msgJDZ(true)
	self:showQDZ(self.index+1)
	
	self.btnJDZ:hide()
	self.btnBJDZ:hide();
end

function ViewQDZLayer:onClickBJDZ()
	SoundManager.playSound("sound/buttonclick.mp3")
	
	self.timer:stopTimer();
	self:msgJDZ(false)
	self:showJDZ(self.index+1)

	self.btnJDZ:hide()
	self.btnBJDZ:hide();
end

function ViewQDZLayer:onClickQDZ()
	SoundManager.playSound("sound/buttonclick.mp3")
	self.timer:stopTimer();
	self:msgQDZ(true);
	self:showQDZ(self.index+1)

	self.btnQDZ:hide()
	self.btnBQDZ:hide()
end

function ViewQDZLayer:onClickBQDZ()
	SoundManager.playSound("sound/buttonclick.mp3")
	self.timer:stopTimer();
	self:msgQDZ(false)
	self:showQDZ(self.index+1)

	self.btnQDZ:hide()
	self.btnBQDZ:hide()
end

return ViewQDZLayer