--
-- Author: <zhaxun>
-- Date: 2015-05-22 10:22:02
--
-- 闹钟
local scheduler = require("framework.scheduler")

local CCTimer = class("CCTimer", function() return display.newNode() end)
function CCTimer:ctor()
	self:setNodeEventEnabled(true)

	local clock = display.newSprite("play3/clock.png"):addTo(self)
    self.time = display.newBMFontLabel({
        text = "12",
        font = "fonts/naozhongSZ.fnt",
        x = 42,
        y = 36,
    })
    :addTo(clock,0,1)
    self._handle = nil
    self._callBack = nil
    self._time = 0
end

function CCTimer:startTimer(time, callback, enableWaring, warningTime)
    enableWaring = enableWaring or false
    warningTime = warningTime or 3
    self:show();
    
    if self._handle then scheduler.unscheduleGlobal(self._handle) end

    self.time:setString(time)
    self._time = time
    self._callBack = callback

    local function onInterval(dt)
        self._time = self._time - 1
        if enableWaring then
            if self._time <= warningTime then
                if self._time == warningTime then
                    SoundManager.playSound("sound/warning.mp3")
                end
                SoundManager.playSound("sound/tick.mp3")
            end
        end

        if self._time > 0 then
            self.time:setString(tostring(self._time))

        elseif self._time == 0 then
            -- 停止定时器(需要计时器句柄)
            scheduler.unscheduleGlobal(self._handle)
            self._handle = nil
           
           if self._callBack then
               self._callBack()
           end
        end
    end
    
    self._handle = scheduler.scheduleGlobal(onInterval, 1)
end

function CCTimer:stopTimer()
	self:hide();
	if self._handle then 
		scheduler.unscheduleGlobal(self._handle)
		self._handle = nil
	end

end

function CCTimer:onEnter()

end

function CCTimer:onExit()
    if self._handle then scheduler.unscheduleGlobal(self._handle); self._handle = nil; end
end

return CCTimer