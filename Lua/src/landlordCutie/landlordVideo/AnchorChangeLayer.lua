local AnchorChangeLayer = class("AnchorChangeLayer", function() return display.newLayer(); end );

function AnchorChangeLayer:ctor()
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    
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

function AnchorChangeLayer:createUI()
    local anchorList = ccui.ImageView:create()
    anchorList:loadTexture("common/pop_bg.png")
    anchorList:setScale9Enabled(true)
    anchorList:setContentSize(cc.size(622,622))
    anchorList:setCapInsets(cc.rect(115,215,1,1))
    anchorList:setPosition(cc.p(815,315))
    self:addChild(anchorList)
    local title_text_bg = ccui.ImageView:create()
    title_text_bg:loadTexture("common/pop_title.png")
    title_text_bg:setAnchorPoint(cc.p(0,0.5))
    title_text_bg:setPosition(cc.p(45,580))
    anchorList:addChild(title_text_bg)
    local title_text = ccui.Text:create("切换主播", FONT_ART_TEXT, 24)
    title_text:setColor(cc.c3b(255,233,110));
    title_text:enableOutline(cc.c4b(141,0,166,255*0.7),2);
    title_text:setPosition(cc.p(68,65));
    title_text:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER);
    title_text_bg:addChild(title_text);

    -- local maskLayer = cc.LayerColor:create(cc.c4b(255, 0, 0, 255))
    -- maskLayer:setContentSize(cc.size(452, 510));
    -- maskLayer:setPosition(cc.p(102, 50));
    -- self:addChild(maskLayer)
    self.listView = ccui.ListView:create()
    self.listView:setDirection(ccui.ScrollViewDir.vertical)
    self.listView:setBounceEnabled(true)
    self.listView:setContentSize(cc.size(530, 500))
    self.listView:ignoreAnchorPointForPosition(false)
    self.listView:setPosition(44,40)
    anchorList:addChild(self.listView)
    -- ListView点击事件回调
    local function listViewEvent(sender, eventType)
        -- 事件类型为点击结束
        if eventType == ccui.ListViewEventType.ONSELECTEDITEM_END then
            local serverIndex = self.listView:getItem(sender:getCurSelectedIndex()):getTag()
            print("AnchorChangeLayerselect child index = ",serverIndex)
            self:dispatchEvent({name=LandlordEvent.CHANGE_VIDEO_GAMEROOM,index=serverIndex})
        end
    end
    -- 设置ListView的监听事件
    self.listView:addEventListener(listViewEvent)

    --关闭按钮
    local closeButton = ccui.Button:create("common/close.png")
    closeButton:setPressedActionEnabled(true)
    closeButton:setPosition(cc.p(590,585))
    anchorList:addChild(closeButton)
    closeButton:addTouchEventListener(function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                SoundManager.playSound("sound/buttonclick.mp3")
                self:onCloseClick()
            end
        end)
end

function AnchorChangeLayer:onCloseClick()
    self:hide()
end

function AnchorChangeLayer:showAnchorListLayer()
    print("AnchorChangeLayer:showRoomListLayer")
    self.listView:removeAllItems()
    self:show()

    local nodeItem = ServerInfo:getNodeItemByIndex(201, 1)
    if nodeItem == nil then
        print("nodeItem is nil")
        return
    end
    local serverArrCount = #nodeItem.serverList
    local curGameServer = RunTimeData:getCurGameServer()
    for i = 1,serverArrCount do
        local gameServer = nodeItem.serverList[i]
        if curGameServer.serverID ~= gameServer.serverID then
            local anchorInfoLayer = require("landlordVideo.AnchorInfoLayer").new()
            anchorInfoLayer:updateAnchorInfo(gameServer)
            local custom_item = ccui.Layout:create()
            custom_item:setTouchEnabled(true)
            custom_item:setTag(i)
            custom_item:setContentSize(anchorInfoLayer:getContentSize())
            custom_item:addChild(anchorInfoLayer)
            
            self.listView:pushBackCustomItem(custom_item) 
        end
    end
end

return AnchorChangeLayer
