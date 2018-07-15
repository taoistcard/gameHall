local RoomInfoLayer = class("RoomInfoLayer", function() return display.newLayer(); end );

function RoomInfoLayer:ctor()
    self:setContentSize(cc.size(540,345))
    self:createUI()
end

function RoomInfoLayer:createUI()
    local roomNameBg = ccui.ImageView:create("landlordVideo/vip_roomname_bg.png")
    roomNameBg:setScale9Enabled(true)
    roomNameBg:setContentSize(cc.size(164,39))
    roomNameBg:setPosition(cc.p(270,360))
    self:addChild(roomNameBg)

    self.roomNameLabel = ccui.Text:create()
    self.roomNameLabel:setFontSize(20)
    self.roomNameLabel:setString("百人场百人场")
    self.roomNameLabel:setColor(cc.c3b(255,239,55))
    self.roomNameLabel:setPosition(cc.p(82,19))
    roomNameBg:addChild(self.roomNameLabel)

    local gameTable = ccui.ImageView:create()
    local curGameServer = RunTimeData:getCurGameServer()
    local curGameServerID = curGameServer:getServerID()
    local serverIndex = 1
    if serverIndex then
        gameTable:loadTexture("landlordVideo/vip_table_"..serverIndex..".png")
    end
    gameTable:setPosition(cc.p(270,190))
    gameTable:setScale(0.5)
    self:addChild(gameTable)

    self.gameRecord = ccui.ImageView:create("landlordVideo/vip_roominfo_bg.png")
    self.gameRecord:setScale9Enabled(true)
    self.gameRecord:setContentSize(cc.size(324,136))
    self.gameRecord:setPosition(cc.p(270,270))
    self:addChild(self.gameRecord)

    self.gameDisRecord = ccui.ImageView:create("landlordVideo/vip_roominfo_bg.png")
    self.gameDisRecord:setScale9Enabled(true)
    self.gameDisRecord:setContentSize(cc.size(324,136))
    self.gameDisRecord:setPosition(cc.p(270,120))
    self:addChild(self.gameDisRecord)
    local recordScrollView = ccui.ScrollView:create();
    recordScrollView:setDirection(ccui.ScrollViewDir.horizontal);
    recordScrollView:setContentSize(cc.size(312, 136));
    recordScrollView:setAnchorPoint(cc.p(0.5,0.5));
    recordScrollView:setPosition(162, 68);
    recordScrollView:addTo(self.gameDisRecord);
    self.recordScrollView = recordScrollView


    local roomSumInfoBg = ccui.ImageView:create("landlordVideo/roomSumInfoBg.png")
    roomSumInfoBg:setScale9Enabled(true)
    roomSumInfoBg:setContentSize(cc.size(440,46))
    roomSumInfoBg:setPosition(cc.p(270,23))
    self:addChild(roomSumInfoBg)

    self.lordCount = ccui.Text:create()
    self.lordCount:setFontSize(20)
    self.lordCount:setColor(cc.c3b(255,51,52))
    self.lordCount:setString("地主:19")
    self.lordCount:setAnchorPoint(cc.p(0,0.5))
    self.lordCount:setPosition(cc.p(30,20))
    roomSumInfoBg:addChild(self.lordCount)
    self.farmerCount = ccui.Text:create()
    self.farmerCount:setFontSize(20)
    self.farmerCount:setColor(cc.c3b(83,132,253))
    self.farmerCount:setString("农民:19")
    self.farmerCount:setAnchorPoint(cc.p(0.5,0.5))
    self.farmerCount:setPosition(cc.p(220,20))
    roomSumInfoBg:addChild(self.farmerCount)
    self.drawCount = ccui.Text:create()
    self.drawCount:setFontSize(20)
    self.drawCount:setColor(cc.c3b(138,238,88))
    self.drawCount:setString("平局:19")
    self.drawCount:setAnchorPoint(cc.p(1,0.5))
    self.drawCount:setPosition(cc.p(410,20))
    roomSumInfoBg:addChild(self.drawCount)
end

function RoomInfoLayer:updateGameRecord(gameRoomName,serverResult)
    self.roomNameLabel:setString(FormotGameNickName(gameRoomName, 6))

    local tableRows = 6
    local tableCols = 15

    local lordWinCount = 0
    local farmerWinCount = 0
    local drawWinCount = 0
    local lastWinIndex = 1
    local recordImg1 = {"landlordVideo/red_solidcircle.png","landlordVideo/green_solidcircle.png","landlordVideo/blue_solidcircle.png"}
    local recordImg2 = {"landlordVideo/red_circle.png","landlordVideo/green_circle.png","landlordVideo/blue_circle.png"}
    local curDisrecordRow = 0
    local curDisrecordCol = 0
    for i,v in pairs(serverResult) do
        if i == 1 then
            lastWinIndex = v
            curDisrecordRow = 1
            curDisrecordCol = 1
        else
            if lastWinIndex == v then
                curDisrecordRow = curDisrecordRow + 1
                if curDisrecordRow == 7 then
                    curDisrecordRow = 1
                    curDisrecordCol = curDisrecordCol + 1
                end
            else
                curDisrecordRow = 1
                curDisrecordCol = curDisrecordCol + 1
                lastWinIndex = v
            end
        end
        --绘制第一个
        local row = i % 6
        local col = math.modf(i / 6) + 1
        if row == 0 then
            row = 6
            col = col - 1
        end
        local circle1 = ccui.ImageView:create()
        circle1:loadTexture(recordImg1[v+1])
        circle1:setPosition(cc.p(12 + (col - 1) * 20 + 10,15 + (6-row)*20 + 10))
        self.gameRecord:addChild(circle1)

        --绘制第二个
        local circle2 = ccui.ImageView:create()
        circle2:loadTexture(recordImg2[v+1])
        circle2:setPosition(cc.p(6+(curDisrecordCol - 1) * 20 + 10,15+(6-curDisrecordRow)*20 + 10))
        self.recordScrollView:addChild(circle2)

        --计算输赢总数
        if v == 0 then
            lordWinCount = lordWinCount + 1
        elseif v==1 then
            drawWinCount = drawWinCount + 1
        elseif v==2 then
            farmerWinCount = farmerWinCount + 1
        end
    end
    --绘制第一个表格
    for i=1,tableRows-1 do
        local sepLineH = ccui.ImageView:create("landlordVideo/sep_line1.png")
        sepLineH:setScale9Enabled(true)
        sepLineH:setContentSize(cc.size(305,2))
        sepLineH:setPosition(cc.p(162,15 + i * 20))
        self.gameRecord:addChild(sepLineH)
    end
    for i=1,tableCols-1 do
        local sepLineV = ccui.ImageView:create("landlordVideo/sep_line1.png")
        sepLineV:setScale9Enabled(true)
        sepLineV:setContentSize(cc.size(2,115))
        sepLineV:setPosition(cc.p(12 + i * 20,74))
        self.gameRecord:addChild(sepLineV)
    end
    --绘制第二个表格
    local drawRows = tableRows
    local drawCols = curDisrecordCol
    if drawCols < tableCols then
        drawCols = tableCols
    end
    self.recordScrollView:setInnerContainerSize(cc.size(20 * drawCols + 12, 136))
    for i=1,drawRows-1 do
        local sepLineH = ccui.ImageView:create("landlordVideo/sep_line1.png")
        sepLineH:setScale9Enabled(true)
        sepLineH:setAnchorPoint(cc.p(0,0.5))
        sepLineH:setContentSize(cc.size(20 * drawCols + 5,2))
        sepLineH:setPosition(cc.p(0,15 + i * 20))
        self.recordScrollView:addChild(sepLineH)
    end
    for i=1,drawCols-1 do
        local sepLineV = ccui.ImageView:create("landlordVideo/sep_line1.png")
        sepLineV:setScale9Enabled(true)
        sepLineV:setAnchorPoint(cc.p(0.5,0))
        sepLineV:setContentSize(cc.size(2,115))
        sepLineV:setPosition(cc.p(6 + i * 20,17))
        self.recordScrollView:addChild(sepLineV)
    end

    self.lordCount:setString("地主:"..lordWinCount)
    self.farmerCount:setString("农民:"..farmerWinCount)
    self.drawCount:setString("平局:"..drawWinCount)
end

return RoomInfoLayer
