local RoomChangeLayer = class("RoomChangeLayer", function() return display.newLayer(); end );

function RoomChangeLayer:ctor()
    local winSize = cc.Director:getInstance():getWinSize()
    local contentSize = cc.size(1136,winSize.height)
    -- 蒙板
    local maskLayer = ccui.ImageView:create("blank.png")
    maskLayer:setScale9Enabled(true)
    maskLayer:setContentSize(contentSize)
    maskLayer:setPosition(cc.p(display.cx, display.cy));
    maskLayer:setTouchEnabled(true)
    self:addChild(maskLayer)
    local maskImg = ccui.ImageView:create("landlordVideo/video_mask.png")
    maskImg:setPosition(cc.p(757, winSize.height / 2));
    maskLayer:addChild(maskImg)

    self:createUI()
end

function RoomChangeLayer:createUI()
    local roomList = ccui.ImageView:create()
    roomList:loadTexture("common/pop_bg.png")
    roomList:setScale9Enabled(true)
    roomList:setContentSize(cc.size(622,622))
    roomList:setCapInsets(cc.rect(115,215,1,1))
    roomList:setPosition(cc.p(808,315))
    self:addChild(roomList)
    local title_text_bg = ccui.ImageView:create()
    title_text_bg:loadTexture("common/pop_title.png")
    title_text_bg:setAnchorPoint(cc.p(0,0.5))
    title_text_bg:setPosition(cc.p(45,580))
    roomList:addChild(title_text_bg)
    local title_text = ccui.Text:create("走势查看", FONT_ART_TEXT, 24)
    title_text:setColor(cc.c3b(255,233,110));
    title_text:enableOutline(cc.c4b(141,0,166,255*0.7),2);
    title_text:setPosition(cc.p(68,65));
    title_text:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER);
    title_text_bg:addChild(title_text);

    -- local maskLayer = cc.LayerColor:create(cc.c4b(255, 0, 0, 255))
    -- maskLayer:setContentSize(cc.size(540, 345));
    -- maskLayer:setPosition(cc.p(40, 100));
    -- roomList:addChild(maskLayer)
    local roomInfoLayer = require("landlordVideo.RoomInfoLayer").new()
    roomInfoLayer:setPosition(cc.p(40,130))
    roomList:addChild(roomInfoLayer)
    self.roomInfoLayer = roomInfoLayer

    --关闭按钮
    local closeButton = ccui.Button:create()
    closeButton:setTouchEnabled(true)
    closeButton:setPressedActionEnabled(true)
    closeButton:loadTextures("common/close.png","common/close.png")
    closeButton:setPosition(cc.p(590,585))
    roomList:addChild(closeButton)
    closeButton:addTouchEventListener(function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                SoundManager.playSound("sound/buttonclick.mp3")
                self:onCloseClick()
            end
        end)
end

function RoomChangeLayer:onCloseClick()
    self:hide()
end

function RoomChangeLayer:showRoomListLayer(gameRoomName,battleRecord)
    print("RoomChangeLayer:showRoomListLayer")
    self:show()
    self.roomInfoLayer:updateGameRecord(gameRoomName,battleRecord)
end

return RoomChangeLayer
