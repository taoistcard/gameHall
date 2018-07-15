local RoomChangeButton = class("RoomChangeButton", function() return display.newLayer(); end );

function RoomChangeButton:ctor()
    self:setContentSize(cc.size(200,136))
    self:createUI()
end

function RoomChangeButton:createUI()
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    local roomChangeButton = ccui.ImageView:create()
    roomChangeButton:loadTexture("landlordVideo/roomrecord_bg1.png")
    roomChangeButton:setTouchEnabled(true)
    roomChangeButton:setPosition(cc.p(100,68))
    self:addChild(roomChangeButton)
    roomChangeButton:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.began then
            -- SoundManager:getInstance():playSoundByType(SoundType.BTN_CLICK)
            roomChangeButton:setScale(1.1)
        elseif eventType == ccui.TouchEventType.ended then
            roomChangeButton:setScale(1.0)
            self:showRoomListLayer()
        elseif eventType == ccui.TouchEventType.canceled then
            roomChangeButton:setScale(1.0)
        end
    end)
    self.lordValue = ccui.Text:create()
    self.lordValue:setString(10)
    self.lordValue:setFontSize(17)
    self.lordValue:setPosition(cc.p(25,103))
    roomChangeButton:addChild(self.lordValue)
    self.farmerValue = ccui.Text:create()
    self.farmerValue:setString(9)
    self.farmerValue:setFontSize(17)
    self.farmerValue:setPosition(cc.p(25,64))
    roomChangeButton:addChild(self.farmerValue)
    self.drawValue = ccui.Text:create()
    self.drawValue:setString(10)
    self.drawValue:setFontSize(17)
    self.drawValue:setPosition(cc.p(25,28))
    roomChangeButton:addChild(self.drawValue)

    self.recordLayer = ccui.Layout:create()
    self.recordLayer:setContentSize(cc.size(95, 114))
    self.recordLayer:setPosition(cc.p(50, 16))
    roomChangeButton:addChild(self.recordLayer)
end

function RoomChangeButton:updateGameRecord(gameRecord)
    self.recordLayer:removeAllChildren()
    if gameRecord == nil then
        return
    end
    local winCount = {0,0,0}
    local recordImg = {"landlordVideo/red_solidcircle.png","landlordVideo/green_solidcircle.png","landlordVideo/blue_solidcircle.png"}
    for i=1,table.maxn(gameRecord) do
        local result = gameRecord[i]
        winCount[result+1] = winCount[result+1] + 1
        local row = i % 6
        local col = math.modf(i / 6) + 1
        if row == 0 then
            row = 6
            col = col - 1
        end
        local circle = ccui.ImageView:create()
        circle:loadTexture(recordImg[result+1])
        circle:setPosition(cc.p((col - 1) * 21 + 10,(6-row)*19 + 9.5))
        self.recordLayer:addChild(circle)
    end
    self.lordValue:setString(winCount[1])
    self.drawValue:setString(winCount[2])
    self.farmerValue:setString(winCount[3])
end

function RoomChangeButton:showRoomListLayer()
    self:dispatchEvent({name=LandlordEvent.SHOW_ROOMCHANGELAYER})
end

return RoomChangeButton
