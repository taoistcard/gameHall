local CompeteSelectLayer = class("CompeteSelectLayer", function() return display.newLayer() end)
function CompeteSelectLayer:ctor()
    self:setNodeEventEnabled(true);
    self.serveridlist = {}
    self.serverImageArray = {}
	self:createUI()
end
function CompeteSelectLayer:onEnter()
    self.bindIds = {}
    self.bindIds[#self.bindIds + 1] = BindTool.bind(MatchInfo, "matchServerInfoList", handler(self, self.refreshMatchServernfoList))
    

    MatchInfo:sendQueryMatchServerInfo(self.serveridlist)
end
function CompeteSelectLayer:onExit()
    for _, bindid in ipairs(self.bindIds) do
        BindTool.unbind(bindid)
    end
end
function CompeteSelectLayer:refreshMatchServernfoList()

    for i,v in ipairs(self.serverImageArray) do
        local serverID = v:getTag()
        for j,w in ipairs(MatchInfo.matchServerInfoList) do
            if w.serverID == serverID then
                local matchServerInfo =  DataManager:getMatchConfigItemByServerID(serverID)
                if matchServerInfo then
                    v:getChildByName("roomName"):setString(matchServerInfo.name)
                else
                    Hall.showTips("没有"..serverID.."这个比赛场的信息", 2)
                end
                
                v:getChildByName("totalUsers"):setString(w.totalUsers.."人")
                v:getChildByName("startNeedCount"):setString("满"..w.matchUsers.."人开赛")
                
            end
        end
    end
end
function CompeteSelectLayer:createUI()
	local displaySize = cc.size(DESIGN_WIDTH, DESIGN_HEIGHT);
    local winSize = cc.Director:getInstance():getWinSize();
    -- 蒙板
    local maskLayer = ccui.ImageView:create()
    maskLayer:loadTexture("common/black.png")
    maskLayer:setContentSize(cc.size(winSize.width, winSize.height));
    maskLayer:setScale9Enabled(true)
    maskLayer:setCapInsets(cc.rect(4,4,1,1))
    maskLayer:setPosition(cc.p(DESIGN_WIDTH/2, DESIGN_HEIGHT/2));
    maskLayer:setTouchEnabled(true)
    self:addChild(maskLayer)

    local bgSprite = ccui.ImageView:create("hall/competeSelect/competeBg.png");
    -- bgSprite:setScale9Enabled(true);
    -- bgSprite:setContentSize(cc.size(642, 452));
    bgSprite:setPosition(cc.p(576,299));
    self:addChild(bgSprite);

    local bgLayer = ccui.Layout:create()
    bgLayer:setContentSize(cc.size(636, 429))
    bgLayer:setPosition(cc.p(0,0))
    bgSprite:addChild(bgLayer, 1)
    self.bgLayer = bgLayer
    local titleSprite = ccui.ImageView:create("hall/competeSelect/titleBg.png");
    -- titleSprite:setScale9Enabled(true);
    -- titleSprite:setContentSize(cc.size(235, 58));
    titleSprite:setPosition(cc.p(441, 545));
    bgSprite:addChild(titleSprite,2);

    local titleName = ccui.ImageView:create("hall/competeSelect/title.png");
    titleName:setPosition(cc.p(212, 63))
    titleSprite:addChild(titleName);

    self.listView = ccui.ListView:create()
    self.listView:setDirection(ccui.ScrollViewDir.horizontal)
    self.listView:setBounceEnabled(true)
    self.listView:setContentSize(cc.size(830, 465))
    self.listView:setPosition(21,44)
    bgLayer:addChild(self.listView)
    local function listViewEvent(sender, eventType)  
        -- 事件类型为点击结束  
        if eventType == ccui.ListViewEventType.ONSELECTEDITEM_END then  
            print("select child index = ",sender:getCurSelectedIndex(),"self.tableNum",self.tableNum)
            self:selectTableAction(sender:getCurSelectedIndex()+1)
            local tag = sender:getCurSelectedIndex()+1
            local tableNum = self.tableNum
            local maxdis = 830*(tableNum-1)
            local moveX = (tag-1)*830
            if maxdis>0 then
                self.listView:scrollToPercentHorizontal(100*moveX/maxdis,1,true)
            end
        end  
    end  
    -- 设置ListView的监听事件
    self.listView:addEventListener(listViewEvent)
    self.listView:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            print("eventType=ended111")
            self.moveCount = 0
            self:performWithDelay(function ()
                self:selectTableStop()
            end, 0.5)
        elseif eventType == ccui.TouchEventType.began then
            return true
        elseif eventType == ccui.TouchEventType.canceled then
            -- print("eventType=canceledcanceledcanceled")
            self.moveCount = 0
            self:performWithDelay(function ()
                self:selectTableStop()
            end, 0.5)
        elseif eventType == ccui.TouchEventType.moved then
            --todo
            if self.moveCount == 0 then
                self.moveCount = self.moveCount + 1
                -- self.singleTable:runAction(cc.ScaleTo:create(0.2, ScaleMode.INIT))
            end
        end
        -- print("eventType",eventType)
    end)
    local close = ccui.Button:create()
    close:loadTextures("common/close1.png", "common/close1.png")
    close:setPosition(cc.p(869, 541))
    close:addTouchEventListener(
                function(sender,eventType)
                    if eventType == ccui.TouchEventType.ended then
                		self:removeFromParent()
                    end
                end
            )
    bgLayer:addChild(close)

    self:refreshList()
end
function CompeteSelectLayer:selectTableAction(tableIndex)
    local tag = tableIndex
    print("tag",tag)
    local tableNum = self.tableNum
    local maxdis = 830*(tableNum-1)
    local moveX = (tag-1)*830
    if maxdis>0 then
        self.listView:scrollToPercentHorizontal(100*moveX/maxdis,1,true)
    end
    for i,v in ipairs(self.slideArray) do
        if v:getTag() == tag then
            v:loadTexture("hall/competeSelect/slidebtnSelect.png")
        else
            v:loadTexture("hall/competeSelect/slidebtn.png")
        end
    end
end
function CompeteSelectLayer:selectTableStop(sender)
    -- print("selectTableStop")
    -- print("xxxx",self.listView:getInnerContainer():getPositionX())
    -- local p = sender:getTouchEndPosition()
    -- dump(p, "p")
    -- local pp = sender:convertToNodeSpace(p)
    -- dump(pp, "pp")
    local tag = math.floor((415-self.listView:getInnerContainer():getPositionX())/830)+1
    -- print("selectTableStop-tagtagtag",tag,sender:getTag())
    local tableNum = self.tableNum
    local maxdis = 830*(tableNum-1)
    local moveX = (tag-1)*830
    if maxdis>0 then
        self.listView:scrollToPercentHorizontal(100*moveX/maxdis,1,true)
    else
        print("maxdis",maxdis)
    end
    
    for i,v in ipairs(self.slideArray) do
        if v:getTag() == tag then
            v:loadTexture("hall/competeSelect/slidebtnSelect.png")
        else
            v:loadTexture("hall/competeSelect/slidebtn.png")
        end
    end
end
function CompeteSelectLayer:itemBgClick(sender)
    local serverID = sender:getTag()
    Hall.showTips("serverID="..serverID, 2)
    local signUp = require("hall.CompeteSignUpLayer").new(serverID)

    self:addChild(signUp)
end
function CompeteSelectLayer:itemClick(sender)
    
    local clickPoint = sender:convertToNodeSpace(self.endPoint)
    dump(clickPoint, "clickPoint")
    local col = math.ceil(clickPoint.x/415)
    local row = math.ceil(clickPoint.y/155)
    if row == 0 then
        row = 1
    end 
    if col == 0 then
        col = 1
    end
    row = 4-row
    print("col",col,"row",row)
    local j = (row-1)*2+col
    local index = (sender:getTag()-1)*6+j
    if index > #ServerInfo.matchConfigList then
        return
    end
    local serverID = self.serveridlist[index]
    if serverID == nil then
        serverID = 99
    end
    Hall.showTips("serverID="..serverID..",j="..j, 2)
    local signUp = require("hall.CompeteSignUpLayer").new(serverID)

    self:addChild(signUp)
end
function CompeteSelectLayer:refreshList()
	self.listView:removeAllItems()
    self.serveridlist = {}
    self.serverImageArray = {}
    for k,v in pairs(ServerInfo.matchConfigList) do
        table.insert(self.serveridlist,v.serverID)
    end
    local competeRoomCount = #ServerInfo.matchConfigList

    local row = 1
    local col = 1
    if (competeRoomCount % 6) == 0 then
        col = competeRoomCount / 6
    else
        col = math.modf(competeRoomCount / 6) + 1
    end    
    self.tableNum = col
    for i=1,col do
        local customItem = ccui.Layout:create()
        customItem:setContentSize(cc.size(830,465))
        customItem:setPosition(cc.p((i - 1) * 830,0))
        -- customItem:setBackGroundColorType(1)
        -- customItem:setBackGroundColor(cc.c3b(100,123+i*10,100))
        customItem:setTouchEnabled(true)
        customItem:setTouchSwallowEnabled(false)
        customItem:setTag(i)
        customItem:addTouchEventListener(
            function (sender,eventType )
                if eventType == ccui.TouchEventType.ended then
                    print("eventType=ended")
                    self.moveCount = 0
                    self.endPoint = customItem:getTouchEndPosition()
                    if self.endPoint.x == self.beganPoint.x and self.endPoint.y == self.beganPoint.y then
                        self:itemClick(customItem)
                    end
                    self:performWithDelay(function ()
                        self:selectTableStop(sender)
                    end, 0.5)
                elseif eventType == ccui.TouchEventType.began then
                    self.beganPoint = customItem:getTouchBeganPosition()
                    return true
                elseif eventType == ccui.TouchEventType.canceled then
                    -- print("eventType=canceledcanceledcanceled")
                    self.moveCount = 0
                    self:performWithDelay(function ()
                        self:selectTableStop(sender)
                    end, 0.5)
                elseif eventType == ccui.TouchEventType.moved then
                    --todo
                    if self.moveCount == 0 then
                        self.moveCount = self.moveCount + 1
                    end
                end
            end
            )
        self.listView:pushBackCustomItem(customItem)
        for j=1,6 do
            if (i-1)*6+j <= competeRoomCount then
                local index = (i-1)*6+j
                local row_sub = 1
                local col_sub = (j-1)%2
                if (j % 2) == 0 then
                    row_sub = j / 2
                else
                    row_sub = math.modf(j / 2) + 1
                end
                print(j,"col_sub",col_sub)
                local posX = 207+(col_sub)*415
                local posY = 81+465-(row_sub)*155
                local itemBg = ccui.ImageView:create("hall/competeSelect/itemBg1.png")
                itemBg:setPosition(posX, posY)
                customItem:addChild(itemBg)
                itemBg:setTag(self.serveridlist[index])
                -- itemBg:setTouchEnabled(true)
                -- itemBg:addTouchEventListener(
                --             function(sender,eventType)
                --                 if eventType == ccui.TouchEventType.ended then
                --                     self:itemBgClick(sender)
                --                 end
                --             end
                --         )
			    local roomName = ccui.Text:create("", "", 26);
			    roomName:setColor(cc.c3b(255,188,116));
			    roomName:setAnchorPoint(cc.p(0.5,0.5))
			    roomName:setPosition(191,102)
			    roomName:setString(index.."大力杯赛"..j)
                roomName:setName("roomName")
			    itemBg:addChild(roomName)

			    local enterType = ccui.Text:create("", "", 20);
			    enterType:setColor(cc.c3b(255,188,116));
			    enterType:setAnchorPoint(cc.p(0.5,0.5))
			    enterType:setPosition(343,102)
			    enterType:setString("免费报名")
			    itemBg:addChild(enterType)

			    local totalUsers = ccui.Text:create("", "", 18);
			    totalUsers:setColor(cc.c3b(255,255,255));
			    totalUsers:setAnchorPoint(cc.p(1,0.5))
			    totalUsers:setPosition(378,70)
			    totalUsers:setString("456123人")
                totalUsers:setName("totalUsers")
			    itemBg:addChild(totalUsers)

			    local startInterval = ccui.Text:create("", "", 18);
			    startInterval:setColor(cc.c3b(255,255,255));
			    startInterval:setAnchorPoint(cc.p(0.5,0.5))
			    startInterval:setPosition(161,25)
			    startInterval:setString("每5秒开赛一场")
                startInterval:setName("startInterval")
			    itemBg:addChild(startInterval)

			    local startNeedCount = ccui.Text:create("", "", 18);
			    startNeedCount:setColor(cc.c3b(255,255,255));
			    startNeedCount:setAnchorPoint(cc.p(0.5,0.5))
			    startNeedCount:setPosition(343,25)
			    startNeedCount:setString("满3人开赛")
                startNeedCount:setName("startNeedCount")
			    itemBg:addChild(startNeedCount)
                table.insert(self.serverImageArray,itemBg)
            end
        end
    end
    --地下滑动的小点
    local slideLayer = ccui.Layout:create()
    slideLayer:setContentSize(cc.size(60*self.tableNum ,20))
    slideLayer:setPosition(cc.p(432,32))
    slideLayer:setAnchorPoint(cc.p(0.5,0.5))
    -- slideLayer:setBackGroundColorType(1)
    -- slideLayer:setBackGroundColor(cc.c3b(100,123,100))
    self.bgLayer:addChild(slideLayer)
    self.slideArray = {}
    for i=1,self.tableNum  do
        local point = ccui.ImageView:create("hall/competeSelect/slidebtnSelect.png")
        if i>1 then
            point:loadTexture("hall/competeSelect/slidebtn.png")
        end
        point:setPosition(60*(i-1)+30,10)
        slideLayer:addChild(point)
        point:setTag(i)
        table.insert(self.slideArray,point)
    end
end
return CompeteSelectLayer