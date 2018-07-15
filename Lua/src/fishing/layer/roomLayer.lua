
local roomLayer = class("roomLayer", function() return display.newLayer(); end );

function roomLayer:ctor(roomIndex,roomID,sitTableId)

    self.sitTableId = sitTableId

    --1免费场;2激情场;3VIP场
    self.roomIndex = roomIndex
    --某个场的第几个房间
    self.roomID = roomID

    --三个房间的nodeID
    self.room_node_id = {1100,1101,1102}

    self.bindIds = {}
    self.bindIds[#self.bindIds + 1] = BindTool.bind(FishInfo, "gameConfig", handler(self, self.refreshFishGameConfig))  
    self.bindIds[#self.bindIds + 1] = BindTool.bind(TableInfo, "userSitDownResult", handler(self, self.refreshSitDown))
    self.bindIds[#self.bindIds + 1] = BindTool.bind(RoomInfo, "userInfoList", handler(self, self.refreshGameServerMsg))
    --房间桌子信息
    self.bindIds[#self.bindIds + 1] = BindTool.bind(RoomInfo, "tableStatusList", handler(self, self.refreshTableStatusList))
    --房间桌子变化
    self.bindIds[#self.bindIds + 1] = BindTool.bind(DataManager, "tabelStatuChange", handler(self, self.refreshTabelStatuChange))

    self:setNodeEventEnabled(true)
    self:createUI()

    --临时这么改
    self.state1 = true
    self.state2 = true

end

function roomLayer:createUI()

	local winSize = cc.Director:getInstance():getWinSize()

    self:setContentSize(cc.size(winSize.width, winSize.height))

    --蒙板
    local backgroundLayer = ccui.ImageView:create()
    backgroundLayer:loadTexture("black.png")
    backgroundLayer:setOpacity(255)
    backgroundLayer:setScale9Enabled(true)
    backgroundLayer:setCapInsets(cc.rect(4,4,1,1))
    backgroundLayer:setContentSize(cc.size(winSize.width, winSize.height));
    backgroundLayer:setPosition(cc.p(winSize.width/2, winSize.height/2));
    backgroundLayer:setTouchEnabled(true);
    self:addChild(backgroundLayer)

    local backgroundSprite = cc.Sprite:create("hall/hall_background.jpg");
    backgroundSprite:setPosition(getSrcreeCenter());
    backgroundLayer:addChild(backgroundSprite);

    --返回
    local backBtn = ccui.Button:create("hall/hall_back.png");
    backBtn:setPosition(cc.p(70,winSize.height-70));
    backBtn:setPressedActionEnabled(true);
    backBtn:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                for _, bindid in ipairs(self.bindIds) do
                    BindTool.unbind(bindid)
                end
                --发送登出房间之后立即关闭 GameConnection
                RoomInfo:sendLogoutRequest()
                GameConnection:closeConnect()

                local hall = require("layer.hallLayer").new();
                display.replaceScene(hall:scene());
            end
        end
    )
    self:addChild(backBtn)

	local room_scene = cc.Sprite:create("room/room_scene.png");
	room_scene:setPosition(cc.p(winSize.width/2-200,winSize.height/2-40));
	backgroundLayer:addChild(room_scene);
    self.room_scene = room_scene;

    --初始化第一桌玩家信息
    -- self:refreshUserList(self.sitTableId)

    local bgSprite = ccui.ImageView:create("room/room_dk.png");
    -- bgSprite:setScale9Enabled(true);
    -- bgSprite:setContentSize(cc.size(480, 530));
    bgSprite:ignoreAnchorPointForPosition(false)
    bgSprite:setAnchorPoint(cc.p(1.0,0.5))
    bgSprite:setPosition(cc.p(winSize.width-20,winSize.height/2-50));
    self:addChild(bgSprite)

    self.listView = ccui.ListView:create()
    self.listView:setDirection(ccui.ScrollViewDir.vertical)
    self.listView:setBounceEnabled(true)
    self.listView:setContentSize(cc.size(420,380))
    self.listView:setAnchorPoint(cc.p(0,0))
    self.listView:setPosition(cc.p(44,96))
    bgSprite:addChild(self.listView)

    -- self:refreshRoomList()

    local bgSprite_cover = ccui.ImageView:create("room/room_dk_2.png");
    -- bgSprite_cover:setScale9Enabled(true);
    -- bgSprite_cover:setContentSize(cc.size(480, 530));
    bgSprite_cover:ignoreAnchorPointForPosition(false)
    bgSprite_cover:setAnchorPoint(cc.p(1.0,0.5))
    bgSprite_cover:setPosition(cc.p(winSize.width-20,winSize.height/2-50));
    self:addChild(bgSprite_cover)

    local roomTitleStr = "room/room_title_free.png"
    if self.roomIndex == 1 then
        roomTitleStr = "room/room_title_free.png"
    elseif self.roomIndex == 2 then
        roomTitleStr = "room/room_title_spirit.png"
    elseif self.roomIndex == 3 then
        roomTitleStr = "room/room_title_vip.png"
    end

    local room_title = cc.Sprite:create(roomTitleStr);
    room_title:setPosition(cc.p(bgSprite_cover:getContentSize().width/2,bgSprite_cover:getContentSize().height+8));
    bgSprite_cover:addChild(room_title);

    local room_title = cc.Sprite:create("common/ty_icon_left.png");
    room_title:setPosition(cc.p(bgSprite_cover:getContentSize().width/2-130,bgSprite_cover:getContentSize().height+8));
    bgSprite_cover:addChild(room_title);

    local room_title = cc.Sprite:create("common/ty_icon_right.png");
    room_title:setPosition(cc.p(bgSprite_cover:getContentSize().width/2+130,bgSprite_cover:getContentSize().height+8));
    bgSprite_cover:addChild(room_title);
    
    --切换房间
    local change_room = ccui.Button:create("room/room_change.png");
    change_room:setPosition(cc.p(240-100,50));
    change_room:setPressedActionEnabled(true);
    change_room:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                local selectLayer = require("layer.roomSelectLayer").new(self);
                self:addChild(selectLayer,100)
            end
        end
    )
    bgSprite_cover:addChild(change_room)

    --快速开始
    local change_room = ccui.Button:create("room/room_quick_start.png");
    change_room:setPosition(cc.p(240+100,50));
    change_room:setPressedActionEnabled(true);
    change_room:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:quickStart()
            end
        end
    )
    bgSprite_cover:addChild(change_room)

end

function roomLayer:quickStart()

    -- TableInfo:sendUserSitdownRequest(6, 4, "")
    local sit_table = 1
    local sit_pos = 1
    local bFindTable = false
    for i=1,60 do
        local tableInfo = DataManager:getTableUserInfo(i)
        if #tableInfo < 4 then
            for n=1,4 do
                local bFind = false
                for k,v in pairs(tableInfo) do
                    if n == v.chairID then
                        bFind = true
                        break
                    end
                end
                if not bFind then
                    bFindTable = true
                    sit_pos = n
                    break
                end
            end
        end
        if bFindTable then
            sit_table = i
            break
        end
    end
    TableInfo:sendUserSitdownRequest(sit_table, sit_pos, "")

end

--恢复上次listView的位置
function roomLayer:refreshListViewPos()
    print(".....refreshListViewPos.....",self.sitTableId)
    if self.listView and self.sitTableId then
        local maxDistance = math.abs(self.listView:getInnerContainer():getPositionY())*2
        local percent = 100*(self.sitTableId-1)*120/(maxDistance-380)
        self.listView:scrollToPercentVertical(percent,0.6,true)
    end
end

function roomLayer:refreshRoomList()
    self.state2 = false

    self.listView:removeAllItems()

    if RoomInfo and #RoomInfo.tableStatusList > 0 then
        for i=1,#RoomInfo.tableStatusList do

            local num = RoomInfo.tableStatusList[i].sitCount

            local item = self:createRoomItem(i,num)

            if i == self.sitTableId then
                local progressBg = item:getChildByTag(500)
                local progressBg2 = item:getChildByTag(510)
                if progressBg then
                    progressBg:hide()
                end
                if progressBg2 then
                    progressBg2:show()
                end
            end

            local custom_item = ccui.Layout:create()
            custom_item:setTouchEnabled(true)
            custom_item:setContentSize(cc.size(400,100))
            custom_item:setTag(i)
            item:setTag(i)
            custom_item:addChild(item)
            
            self.listView:pushBackCustomItem(custom_item)

        end
    end

    -- ListView点击事件回调
    local function listViewEvent(sender, eventType)
        -- 事件类型为点击结束
        if eventType == ccui.ListViewEventType.ONSELECTEDITEM_END then
            local index = sender:getCurSelectedIndex() + 1
            self.sitTableId = index
            --刷新第index桌的信息
            self:refreshUserList(index)

            for i=1,#RoomInfo.tableStatusList do
                if i == index then
                    local item_parent = sender:getChildByTag(i)
                    if item_parent then
                        local item = item_parent:getChildByTag(i)
                        if item then
                            local progressBg = item:getChildByTag(500)
                            local progressBg2 = item:getChildByTag(510)
                            if progressBg then
                                progressBg:hide()
                            end
                            if progressBg2 then
                                progressBg2:show()
                            end                    
                        end
                    end                    
                else
                    local item_parent = sender:getChildByTag(i)
                    if item_parent then
                        local item = item_parent:getChildByTag(i)
                        if item then
                            local progressBg = item:getChildByTag(500)
                            local progressBg2 = item:getChildByTag(510)
                            if progressBg then
                                progressBg:show()
                            end
                            if progressBg2 then
                                progressBg2:hide()
                            end                    
                        end
                    end
                end
            end

        end
    end
    self.listView:addEventListener(listViewEvent)

    self.state2 = true

end

function roomLayer:createRoomItem(index,nums)

    local node = display.newLayer()
    node:setContentSize(cc.size(380,110));

    local insidebg = ccui.ImageView:create("common/ty_scale_bg_1.png");
    insidebg:setScale9Enabled(true);
    insidebg:setContentSize(cc.size(382,92));
    insidebg:setPosition(cc.p(190,36));
    insidebg:setTag(500)
    node:addChild(insidebg)

    local insidebg2 = ccui.ImageView:create("common/ty_scale_bg_selected.png");
    insidebg2:setScale9Enabled(true);
    insidebg2:setContentSize(cc.size(382,92));
    insidebg2:setPosition(cc.p(190,36));
    insidebg2:setTag(510);
    insidebg2:hide();
    node:addChild(insidebg2);

    local progress_bg = cc.Sprite:create("common/ty_progress_bg.png");
    progress_bg:setPosition(cc.p(190,22));
    node:addChild(progress_bg)

    local progress = cc.Sprite:create("common/ty_progress_lv.png");
    progress:setAnchorPoint(cc.p(0.0,0.5));
    progress:setPosition(cc.p(125,22.5));
    node:addChild(progress);
    progress:setTextureRect(cc.rect(0,0,math.floor(130*nums/4),37));

    local content = display.newTTFLabel({text = index.."号桌",
                                        size = 27,
                                        color = cc.c3b(240,240,50),
                                        font = FONT_PTY_TEXT,
                                        align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                                    })
    content:enableOutline(cc.c4b(141,0,166,255*0.7),2)
    content:setPosition(cc.p(60,36))
    node:addChild(content)

    local content = display.newTTFLabel({text = nums.."/4",
                                        size = 27,
                                        color = cc.c3b(240,240,50),
                                        font = FONT_PTY_TEXT,
                                        align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                                    })
    content:enableOutline(cc.c4b(141,0,166,255*0.7),2)
    content:setPosition(cc.p(190,58))
    node:addChild(content)

    local text = "可加入"
    if nums >= 4 then
        text = "满桌"
    end

    local content = display.newTTFLabel({text = text,
                                        size = 27,
                                        color = cc.c3b(240,240,50),
                                        font = FONT_PTY_TEXT,
                                        align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                                    })
    content:enableOutline(cc.c4b(141,0,166,255*0.7),2)
    content:setPosition(cc.p(320,36))
    node:addChild(content)

    return node

end

function roomLayer:refreshUserList(index)

    self.state1 = false

    for i=1,4 do
        local child = self.room_scene:getChildByTag(500+i)
        if child then
            child:removeFromParent()
        end
    end

    local tableInfo = DataManager:getTableUserInfo(index)
    -- dump(tableInfo, "tableInfo")

    --四个位置的坐标
    self.posArr = {cc.p(50,180),cc.p(410,180),cc.p(390,410),cc.p(70,400)}

    for i=1,4 do

        local bFind = false
        for k,v in pairs(tableInfo) do
            if i == v.chairID then
                local headInfo = require("common_view.HeadInfoLayer").new()
                headInfo:setPosition(self.posArr[i])
                local name = v.nickName
                if string.len(name) <= 0 then
                    name = v.gameID
                end
                headInfo:setHeadIcon(v.faceID,v.platformID,v.platformFace)
                headInfo:setName(name)
                headInfo:setCoin(v.score)
                headInfo:setTag(500+i)
                self.room_scene:addChild(headInfo)
                bFind = true
                break
            end
        end
        if not bFind then
            local sitBtn = ccui.Button:create("room/sit_down_btn.png");
            sitBtn:setPosition(self.posArr[i]);
            sitBtn:setPressedActionEnabled(true);
            sitBtn:addTouchEventListener(
                function(sender,eventType)
                    if eventType == ccui.TouchEventType.ended then
                        TableInfo:sendUserSitdownRequest(self.sitTableId, i, "")
                    end
                end
            )
            sitBtn:setTag(500+i)
            self.room_scene:addChild(sitBtn)
        end

    end

    self.state1 = true

end

function roomLayer:scene()

    local scene = display.newScene("hallScene");
    scene:addChild(self);

    touchLayer = display.newLayer():addTo(scene);
    touchLayer:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE);
    touchLayer:setTouchEnabled(true);
    touchLayer:addNodeEventListener(cc.NODE_TOUCH_EVENT,
        function(event)
        end
    )
    return scene;

end

function roomLayer:onEnter()
    print("···roomLayer:onEnter",self.state2,self.state1)


    --测试数据
    -- local tableInfo = DataManager:getTableUserInfo(self.sitTableId)    
    -- for k,v in pairs(tableInfo) do
    --     local name = v.nickName
    --     if string.len(name) <= 0 then
    --         name = v.gameID
    --     end
    --     print("roomLayer:onEnter···",v.chairID,name)
    -- end


    self:refreshListViewPos()
    if self.state2 then
        print("···roomLayer:onEnter")
        self:refreshRoomList()
    end
    --初始化桌子玩家信息
    if self.state1 then
        print("···roomLayer:onEnter")
        self:refreshUserList(self.sitTableId)
    end
end

function roomLayer:onExit()
    print("···roomLayer:onExit")
    for _, bindid in ipairs(self.bindIds) do
        BindTool.unbind(bindid)
    end
end

function roomLayer:refreshSitDown(event)
    --坐下成功
    TableInfo:sendGameOptionRequest(true)
end

function roomLayer:refreshFishGameConfig(event)

    for _, bindid in ipairs(self.bindIds) do
        BindTool.unbind(bindid)
    end
    
    print("------roomLayer:refreshFishGameConfig-----")
    local gameLayer = require("layer.gameLayer").new();
    gameLayer:cacheLastSceneData(self.roomIndex,self.roomID,self.sitTableId)
    display.replaceScene(gameLayer:scene());
    
end

function roomLayer:refreshGameServerMsg(event)

    -- print("·roomLayer··userInfoList: 刷新 !!!!!!!!!!")
    --测试数据
    -- local tableInfo = DataManager:getTableUserInfo(self.sitTableId)    
    -- for k,v in pairs(tableInfo) do
    --     local name = v.nickName
    --     if string.len(name) <= 0 then
    --         name = v.gameID
    --     end
    --     print("roomLayer:refreshGameServerMsg",v.chairID,name)
    -- end

    for _, stat in ipairs(RoomInfo.userInfoList) do
        if stat.userID == AccountInfo.userId and stat.userStatus == US_PLAYING then
            --自己断线重连，不用坐下，直接发gameoption
            TableInfo:sendGameOptionRequest(true)
            print("roomLayer:refreshGameServerMsg.....断线重连")
        else
            --初始化桌子玩家信息
            if self.state1 then
                -- print("roomLayer:refreshGameServerMsg.....初始化桌上玩家信息")
                -- self:refreshUserList(self.sitTableId)
            end
        end
    end
end

function roomLayer:refreshTableStatusList(event)
    -- print("roomLayer:refreshTableStatusList..............")
    --测试数据
    -- local tableInfo = DataManager:getTableUserInfo(self.sitTableId)    
    -- for k,v in pairs(tableInfo) do
    --     local name = v.nickName
    --     if string.len(name) <= 0 then
    --         name = v.gameID
    --     end
    --     print("roomLayer:refreshTableStatusList",v.chairID,name)
    -- end

    if self.state2 then
        self:refreshRoomList()
    end
    --初始化桌子玩家信息
    if self.state1 then
        self:refreshUserList(self.sitTableId)
    end
    self:refreshListViewPos()
end

function roomLayer:refreshTabelStatuChange(event)
    -- print("roomLayer:refreshTabelStatuChange..............")
    --测试数据
    -- local tableInfo = DataManager:getTableUserInfo(self.sitTableId)    
    -- for k,v in pairs(tableInfo) do
    --     local name = v.nickName
    --     if string.len(name) <= 0 then
    --         name = v.gameID
    --     end
    --     print("roomLayer:onEnter···",v.chairID,name)
    -- end

    if self.state2 then
        self:refreshRoomList()
    end
    --初始化桌子玩家信息
    if self.state1 then
        self:refreshUserList(self.sitTableId)
    end
end

return roomLayer