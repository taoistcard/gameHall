
local ccuiButton = ccui.Button;

ccuiButton.onClick = function(self,callback)
    -- print(callback,type(callback));
    self:setPressedActionEnabled(true);
    self:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.began then
            self:setScale(1.15)
            SoundManager.playSound("sound/buttonclick.mp3");
        elseif eventType == ccui.TouchEventType.ended then
            self:setScale(1.0)
            callback();
        elseif eventType == ccui.TouchEventType.canceled then
            self:setScale(1.0)
        end
    end)

end
function Click()

    SoundManager.playSound("sound/buttonclick.mp3");

end
