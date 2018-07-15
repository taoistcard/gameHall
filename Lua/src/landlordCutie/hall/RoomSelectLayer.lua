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
    bankConainer:setContentSize(cc.size(674, 433*1.167));
    bankConainer:setPosition(cc.p(591,305));
    self:addChild(bankConainer);

    local panel = ccui.ImageView:create("common/panel.png")
    panel:setScale9Enabled(true);
    panel:setContentSize(cc.size(590,390));
    panel:setPosition(592, 296)
    self:addChild(panel)

    local pop_title = ccui.ImageView:create("common/pop_title.png");
    pop_title:setPosition(cc.p(391,522));
    self:addChild(pop_title);

    local roomword = display.newTTFLabel({text = "房间",
                                size = 24,
                                color = cc.c3b(255,233,110),
                                font = FONT_ART_TEXT,
                            })
                :addTo(self)
    roomword:setPosition(389, 543)
    roomword:setTextColor(cc.c4b(251,248,142,255))
    roomword:enableOutline(cc.c4b(137,0,167,200), 2)

    local fangjian = ccui.Text:create()
    fangjian:setPosition(410, 462)
    self:addChild(fangjian)
    fangjian:setFontSize(24)
    fangjian:setColor(cc.c3b(0, 255, 0))
    fangjian:setString("房间")

    local onLineCount = ccui.Text:create()
    onLineCount:setPosition(769, 462)
    self:addChild(onLineCount)
    onLineCount:setFontSize(24)
    onLineCount:setColor(cc.c3b(0, 255, 0))
    onLineCount:setString("在线人数")

--  listview
    self.listView = ccui.ListView:create()
    -- set list view ex direction
    self.listView:setDirection(ccui.ScrollViewDir.vertical)
    self.listView:setBounceEnabled(true)
    self.listView:setContentSize(cc.size(590,360))
    self.listView:setAnchorPoint(cc.p(0.5,0.5))
    self.listView:setPosition(593+15,269-5)
    self:addChild(self.listView)

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
    exit:setPosition(cc.p(893,528));
    self:addChild(exit);
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
    local nodeItem = ServerInfo:getNodeItemByIndex(wCurKind,self.kind)
    local nodeCount = #nodeItem.serverList

    local vx = -590+281
    local vy = -412+35
    local colorArray = {cc.c4b(51,89,35,255),cc.c4b(28,83,102,255),cc.c4b(63,39,104,255),cc.c4b(132,37,37,255)}
    -- for i=1,nodeCount do
        local i = self.kind
        local roomCount = #nodeItem.serverList

        for j=1,roomCount do
            -- print(i,j)
            
            local gameServer = nodeItem.serverList[j]
            dump(gameServer, "gameServer====")

            local bangItemLayer = ccui.Button:create("common/list_item.png")
            -- bangItemLayer:loadTexture("common/list_item.png")
            bangItemLayer:setScale9Enabled(true)
            bangItemLayer:setContentSize(cc.size(562,70+10))
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
                            GameConnection:connectServer(gameServer.serverAddr,gameServer.serverPort)
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
            itemName:setPosition(cc.p(318+vx,415+vy))
            bangItemLayer:addChild(itemName)
            itemName:setName("ItemName")

            itemName:setString(gameServer.serverName)
            -- 准入条件
            local itemScore = ccui.Text:create("110万欢乐豆准入",FONT_ART_TEXT,21)
            itemScore:setTextColor(wordcolor)
            itemScore:setAnchorPoint(cc.p(0,0.5))
            itemScore:setPosition(cc.p(525+vx,416+vy))
            bangItemLayer:addChild(itemScore)
            itemScore:setName("ItemScore")

            local min = gameServer.minEnterScore
            local minEnterScore = ""
            if bit.band(gameServer.serverType,Define.GAME_GENRE_EDUCATE) == Define.GAME_GENRE_EDUCATE then
                minEnterScore = FormatDigitToString(min,0).."欢乐豆准入"
            else
                minEnterScore = FormatDigitToString(min,0).."金币准入"
            end
            itemScore:setString(minEnterScore)
            --进度
            local expPos = cc.p(771+vx, 417+vy);
            local expBgSprite = cc.Sprite:create("hall/roomselect/progress_bg.png");
            expBgSprite:setPosition(expPos);
            bangItemLayer:addChild(expBgSprite);

            local expNowExp = display.newProgressTimer("hall/roomselect/progress_now.png", display.PROGRESS_TIMER_BAR);
            expNowExp:align(display.CENTER, expPos.x, expPos.y)
            expNowExp:setMidpoint(cc.p(0, 0.5))
            expNowExp:setBarChangeRate(cc.p(1.0, 0))
            bangItemLayer:addChild(expNowExp);
            expNowExp:setName("expNowExp")
            expNowExp:setPercentage(100*5/10)
            -- self.expNowExp = expNowExp;
      --       self.expNowExp:setPercentage(100*5/10)
            local olcount = gameServer.onlineCount
            local fullCount = gameServer.fullCount
            print("olcount=",olcount,"fullCount=",fullCount)
            expNowExp:setPercentage(100*olcount/fullCount)

            local countText = ccui.Text:create()
            countText:setFontSize(22)
            -- countText:setColor(cc.c3b(226, 195, 14))
            countText:setPosition(771+vx,417+vy)
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
    local wCurKind = RunTimeData:getCurGameID()
    local nodeItem = ServerInfo:getNodeItemByIndex(wCurKind, index)
    local userInfo = DataManager:getMyUserInfo()
    local roomIndex = 0
    local popTips = true

    local gameServer = nodeItem.serverList[1]
    if gameServer then
        local min = gameServer.minEnterScore
        local max = gameServer.maxEnterScore
                    
        if bit.band(gameServer.serverType,Define.GAME_GENRE_EDUCATE) == Define.GAME_GENRE_EDUCATE then
            if (userInfo.score+userInfo.insure>=2000) then
                -- Hall.showTips("你的金币超过2000，请前往金币场！", 1)
                -- return false
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


    local myInfo = DataManager:getMyUserInfo()
    local kind = 0
    local tipStr = ""
    if index == 2 and popTips then
        kind = 1
        tipStr = "客官，看你骨骼惊奇，是块斗地主的好料，初级场不适合你，还是去中场去看看吧。"
        --检测下一个场是否超出准入限制
        local isnext = true
        local nodeItem = ServerInfo:getNodeItemByIndex(wCurKind, index)
        local gameServer =  nil 
        if nodeItem then
            gameServer = nodeItem.serverList[1]
        end
        if gameServer then
            local min = gameServer.minEnterScore
            local max = gameServer.maxEnterScore
                        
            if bit.band(gameServer.serverType,Define.GAME_GENRE_EDUCATE) == Define.GAME_GENRE_EDUCATE then

                if (userInfo.beans <= max or max == 0) then
                    isnext = false
                    
                end

            else
                if (userInfo.score <= max or max == 0) then
                    isnext = false
                    
                end
            end
        end

        if isnext then
            kind = 2
            tipStr = "客官，我果然没看错你，高手场才是您真正应该战斗的地方"
            index = index+1
        end
    end
    if index == 3 and popTips then
        kind = 2
        tipStr = "客官，我果然没看错你，高手场才是您真正应该战斗的地方"
    end

    if kind >0 then
        local tips = require("hall.WenXinTiShiLayer").new(SystemNoticeType.ClientNoticeType_goNextRoom,tipStr,index)

        self:addChild(tips)
        return false
    end
    if (userInfo.score+userInfo.insure>=2000) then
        -- Hall.showTips("你的金币超过2000，请前往金币场！", 1)
        -- return false
    end
    return true
end
return RoomSelectLayer