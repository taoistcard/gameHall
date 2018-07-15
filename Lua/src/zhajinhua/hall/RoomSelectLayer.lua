local RoomSelectLayer = class( "RoomSelectLayer", function() return display.newLayer() end)

function RoomSelectLayer:ctor(kind)
    self.kind = kind
	-- body
	self:createUI()
end

function RoomSelectLayer:createUI()
    local winSize = cc.Director:getInstance():getWinSize()

    -- 蒙板
    local maskLayer = ccui.ImageView:create()
    maskLayer:loadTexture("common/black.png")
    maskLayer:setContentSize(winSize);
    maskLayer:setScale9Enabled(true)
    maskLayer:setCapInsets(cc.rect(4,4,1,1))
    maskLayer:setPosition(cc.p(display.cx, display.cy));
    maskLayer:setTouchEnabled(true)
    self:addChild(maskLayer)


    local bankConainer = ccui.ImageView:create("common/pop_bg.png");
    bankConainer:setScale9Enabled(true);
    bankConainer:setContentSize(cc.size(640, 410));
    bankConainer:setPosition(cc.p(winSize.width / 2, winSize.height / 2));
    self:addChild(bankConainer);

    local fangjian = ccui.Text:create()
    fangjian:setPosition(130, 375)
    bankConainer:addChild(fangjian)
    fangjian:setFontSize(24)
    fangjian:setColor(cc.c3b(0, 255, 0))
    fangjian:setString("房间")

    local fangjian = ccui.Text:create()
    fangjian:setPosition(370, 375)
    bankConainer:addChild(fangjian)
    fangjian:setFontSize(24)
    fangjian:setColor(cc.c3b(0, 255, 0))
    fangjian:setString("火热度")

    local onLineCount = ccui.Text:create()
    onLineCount:setPosition(540, 375)
    bankConainer:addChild(onLineCount)
    onLineCount:setFontSize(24)
    onLineCount:setColor(cc.c3b(0, 255, 0))
    onLineCount:setString("在线人数")

--  listview
    self.listView = ccui.ListView:create()
    -- set list view ex direction
    self.listView:setDirection(ccui.ScrollViewDir.vertical)
    self.listView:setBounceEnabled(true)
    self.listView:setContentSize(cc.size(576, 320))
    self.listView:setAnchorPoint(cc.p(0,0))
    self.listView:setPosition(35, 30)
    bankConainer:addChild(self.listView)

    -- ListView点击事件回调
    -- local function listViewEvent(sender, eventType)
    --     -- 事件类型为点击结束
    --     if eventType == ccui.ListViewEventType.ONSELECTEDITEM_END then
    --         -- local obj = sender:getUserObject()
    --         -- dump(obj, "obj")
    --         local nodeCount = sender:getTag()/10000
    --         local roomCount = sender:getTag()%10000
    --         print("select child index = ",sender:getCurSelectedIndex(),sender:getTag(),nodeCount,roomCount)
    --     end
    -- end
    -- 设置ListView的监听事件
    -- self.listView:addEventListener(listViewEvent)
    self:refreshRoomList()

    local exit = ccui.Button:create("common/close.png");
    exit:setPosition(cc.p(626, 404));
    bankConainer:addChild(exit);
    exit:setPressedActionEnabled(true);
    exit:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:removeFromParent();
            end
        end
    )
end
function RoomSelectLayer:refreshRoomList()

    local wCurKind = RunTimeData:getCurGameID();
    local wCurNode = RunTimeData:getCurGameNode();
    local nodeItem = ServerInfo:getServerNodeItemByNodeID(wCurKind, wCurNode)

    local vx = -590+281
    local vy = -412+35
    local colorArray = {cc.c4b(255, 255, 255, 255),cc.c4b(255, 255, 255, 255),cc.c4b(255, 255, 255, 255),cc.c4b(255, 255, 255, 255)}
    -- for i=1,nodeCount do
        local i = self.kind
        local roomCount = #nodeItem.serverList
        print("roomCount====", roomCount)

        for j=1,roomCount do
            -- print(i,j)
            
            local gameServer = nodeItem.serverList[j]

            local bangItemLayer = ccui.Button:create("hall/roomselect/bg_normal.png")
            -- bangItemLayer:loadTexture("common/list_item.png")
            bangItemLayer:setScale9Enabled(true)
            bangItemLayer:setContentSize(cc.size(570, 60))
            -- bangItemLayer:setCapInsets(cc.rect(50,40,10,10))
            bangItemLayer:setPressedActionEnabled(true);
            bangItemLayer:ignoreAnchorPointForPosition(true)
            bangItemLayer:setName("ListItem")
            bangItemLayer:setTag(i*10000+j)
            -- bangItemLayer:setUserObject({nodeID=i,roomIndex=j})
            bangItemLayer:addTouchEventListener(
                function(sender,eventType)
                    if eventType == ccui.TouchEventType.ended then
                        if self:checkTips(i) then
                            local nodeCount = math.floor(sender:getTag()/10000)
                            local roomCount = sender:getTag()%10000
                            print("select child bangItemLayer = ",sender:getTag(),nodeCount,roomCount)
                            Hall.printKind = 0
                            RunTimeData:setCurGameServer(gameServer)
                            RunTimeData:setRoomIndex(nodeCount)
                            RunTimeData:connectToRoom(wCurKind,nodeCount,roomCount)
                            local function onInterval(dt)
                                print("Hall.printKind = 1")
                                Hall.printKind = 1
                            end
                            local scheduler = require("framework.scheduler")
                            scheduler.performWithDelayGlobal(onInterval, 1)
                            self:removeFromParent();
                        end
                    end
                end
            )
            local wordcolor = colorArray[i]
            if wordcolor == nil then
                wordcolor = colorArray[4]
            end
            -- 房间名字
            local itemName = ccui.Text:create("单挑玩法初级场（1）",FONT_ART_TEXT,21)
            itemName:setTextColor(wordcolor)
            itemName:setAnchorPoint(cc.p(0,0.5))
            itemName:setPosition(cc.p( 20, 30))
            bangItemLayer:addChild(itemName)
            itemName:setName("ItemName")

            itemName:setString(gameServer.serverName)

            local olcount = gameServer.onlineCount
            local fullCount = gameServer.fullCount
            local scle = olcount / fullCount
            local fireNode = ccui.Layout:create()
            bangItemLayer:addChild(fireNode)
            
            --scle = 0.8
            local fireCount = 3
            -- 准入条件
            if scle < 0.25 then --三星
                fireCount = 3
                fireNode:setPosition(300, 30)
            elseif scle < 0.5 then --四星
                fireCount = 4
                fireNode:setPosition(288, 30)
            else --五星
                fireCount = 5
                fireNode:setPosition(276, 30)
            end
            for i=1, fireCount do
                local fire = ccui.ImageView:create("hall/roomselect/fire_icon.png"):addTo(fireNode);
                fire:setPosition(24 * i - 12, 0)
            end

            -- local itemScore = ccui.Text:create("110万欢乐豆准入",FONT_ART_TEXT,21)
            -- itemScore:setTextColor(wordcolor)
            -- itemScore:setAnchorPoint(cc.p(0.5, 0.5))
            -- itemScore:setPosition(cc.p(340, 30))
            -- bangItemLayer:addChild(itemScore)
            -- itemScore:setName("ItemScore")

            -- local min = gameServer:getMinEnterScore()
            -- local minEnterScore = ""
            -- if gameServer:getServerType() == Define.GAME_GENRE_HAPPYBEANS then
            --     minEnterScore = FormatDigitToString(min,0).."欢乐豆准入"
            -- else
            --     minEnterScore = FormatDigitToString(min,0).."金币准入"
            -- end
            -- itemScore:setString(minEnterScore)

            --进度
      --       local expPos = cc.p(771+vx, 30);
      --       local expBgSprite = cc.Sprite:create("hall/roomselect/progress_bg.png");
      --       expBgSprite:setPosition(expPos);
      --       bangItemLayer:addChild(expBgSprite);

      --       local expNowExp = display.newProgressTimer("hall/roomselect/progress_now.png", display.PROGRESS_TIMER_BAR);
      --       expNowExp:align(display.CENTER, expPos.x, expPos.y)
      --       expNowExp:setMidpoint(cc.p(0, 0.5))
      --       expNowExp:setBarChangeRate(cc.p(1.0, 0))
      --       bangItemLayer:addChild(expNowExp);
      --       expNowExp:setName("expNowExp")
      --       expNowExp:setPercentage(100*5/10)
      --       -- self.expNowExp = expNowExp;
      -- --       self.expNowExp:setPercentage(100*5/10)
            
            
            print("olcount=",olcount,"fullCount=",fullCount)
      --       expNowExp:setPercentage(100*olcount/fullCount)

            local countText = ccui.Text:create()
            countText:setFontSize(24)
            countText:setColor(cc.c3b(226, 195, 14))
            countText:setPosition(505, 30)
            countText:setString(olcount.."/"..fullCount);
            bangItemLayer:addChild(countText)

            local custom_item = ccui.Layout:create()
            custom_item:setTouchEnabled(true)
            custom_item:setContentSize(bangItemLayer:getContentSize())
            custom_item:addChild(bangItemLayer)
            custom_item:setTag(i*10000+j)
            
            self.listView:pushBackCustomItem(custom_item)
        end
    -- end
end
--检测是否弹提示
function RoomSelectLayer:checkTips(index)

    -- if 1 then
    --     return true
    -- end
    local wCurKind = RunTimeData:getCurGameID();
    local wCurNode = RunTimeData:getCurGameNode();
    local nodeItem = ServerInfo:getNodeItemByNodeID(wCurKind, wCurNode)
    local userInfo = DataManager:getMyUserInfo()
    local roomIndex = 0
    local popTips = true

    local gameServer = nodeItem.serverList[index]
    if gameServer then
        local min = gameServer.minEnterScore
        local max = gameServer.maxEnterScore
                    
        if gameServer.serverType == Define.GAME_GENRE_HAPPYBEANS then
            if (userInfo.score+userInfo.insure>=2000) then
                Hall.showTips("你的金币超过2000，请前往金币场！", 1)
                return false
            end
        else
            if (userInfo.score <= max or max == 0) then
                popTips = false
                return true
            end
        end
    else
        return true
    end

end
return RoomSelectLayer