
local roomSelectLayer = class("roomSelectLayer", require("show.popView_Hall.baseWindow") );

function roomSelectLayer:ctor(parent)

    self.preConnect = false
    self.parent = parent
    self.super.ctor(self, 1)
    self:setNodeEventEnabled(true)
    self:createUI()

end

function roomSelectLayer:createUI()

    local size = self:getContentSize();

    local title = display.newSprite("room/room_select_title.png", size.width/2, size.height/2+250);
    title:setScale(0.9)
    self:addChild(title);

    self.listView = ccui.ListView:create()
    self.listView:setDirection(ccui.ScrollViewDir.vertical)
    self.listView:setBounceEnabled(true)
    self.listView:setContentSize(cc.size(580,400))
    self.listView:setAnchorPoint(cc.p(0.5,0.5))
    self.listView:setPosition(cc.p(size.width/2, size.height/2))
    self:addChild(self.listView)

    self:refreshRoomList()

end

function roomSelectLayer:refreshRoomList()
    self.listView:removeAllItems()

    -- dump(ServerInfo.nodeItemList, "ServerInfo.nodeItemList")

    self.room_list = {}
    for k,v in pairs(ServerInfo.nodeItemList) do
        -- print(k,v.nodeID,v.name,self.parent.roomIndex,self.parent.room_node_id[self.parent.roomIndex])
        if self.parent.room_node_id[self.parent.roomIndex] == v.nodeID then
            self.room_list = v.serverList
            break;
        end
    end

    if #self.room_list > 0 then

        for i,v in ipairs(self.room_list) do

            print(i,v.serverName)
            local num = 0
            local item = self:createRoomItem(v)

            if i == self.parent.roomID then
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
            custom_item:setContentSize(cc.size(580,110))
            custom_item:setTag(i)
            item:setTag(i)
            custom_item:addChild(item)
            
            self.listView:pushBackCustomItem(custom_item)

        end

        -- ListView点击事件回调
        local function listViewEvent(sender, eventType)
            -- 事件类型为点击结束
            if eventType == ccui.ListViewEventType.ONSELECTEDITEM_END then
                self.index = sender:getCurSelectedIndex() + 1
                for i=1,10 do
                    if i == self.index then
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
                --切换房间逻辑--发送登出房间之后立即关闭 GameConnection
                if self.parent.roomID == self.index then
                    Hall.showTips("您当前正在该房间中!")
                else
                    RoomInfo:sendLogoutRequest()
                    GameConnection:closeConnect()

                    Hall.showWaitingState("切换房间中，请稍候 ...")

                    self:performWithDelay(
                        function()
                            print(self.index.."进入"..self.room_list[self.index].serverName..":"..self.room_list[self.index].serverPort.."...."..self.room_list[self.index].serverAddr)
                            self.roomAddr = self.room_list[self.index].serverAddr
                            if string.len(ServerHostBackUp) > 0 then
                                self.roomAddr = ServerHostBackUp
                            end
                            self.roomPort = self.room_list[self.index].serverPort
                            self.preConnect = true

                            if GameConnection.isConnected then
                                GameConnection:closeConnect();
                            end
                            GameConnection:connectServer(self.roomAddr, self.roomPort)
                        end,
                        1.0
                    )
                end

            end
        end
        self.listView:addEventListener(listViewEvent)
    end

end

function roomSelectLayer:createRoomItem(info)

    local node = display.newLayer()
    node:setContentSize(cc.size(580,110));

    local insidebg = ccui.ImageView:create("common/ty_scale_bg_1.png");
    insidebg:setScale9Enabled(true);
    insidebg:setContentSize(cc.size(580,100));
    insidebg:setPosition(cc.p(290,52));
    insidebg:setTag(500)
    node:addChild(insidebg)

    local insidebg2 = ccui.ImageView:create("common/ty_scale_bg_selected.png");
    insidebg2:setScale9Enabled(true);
    insidebg2:setContentSize(cc.size(580,100));
    insidebg2:setPosition(cc.p(290,52));
    insidebg2:setTag(510);
    insidebg2:hide();
    node:addChild(insidebg2);

    local progress_bg = ccui.ImageView:create("room/room_progress_bg.png");
    progress_bg:setScale9Enabled(true);
    progress_bg:setContentSize(cc.size(208,33));
    progress_bg:setPosition(cc.p(280,38));
    node:addChild(progress_bg)

    local progress = cc.Sprite:create("room/room_progress_green.png");
    progress:setAnchorPoint(cc.p(0.0,0.5));
    progress:setPosition(cc.p(178,38.5));
    node:addChild(progress);
    progress:setTextureRect(cc.rect(0,0,math.floor(205*info.onlineCount/info.fullCount),31));

    local iconSprite = cc.Sprite:create("room/room_hai_xin.png");
    iconSprite:setPosition(cc.p(80,48));
    node:addChild(iconSprite)    

    local content = display.newTTFLabel({text = ""..info.serverName,
                                        size = 27,
                                        color = cc.c3b(240,240,50),
                                        font = FONT_PTY_TEXT,
                                        align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                                    })
    content:enableOutline(cc.c4b(141,0,166,255*0.7),2)
    content:setPosition(cc.p(280,74))
    node:addChild(content)

    local content = display.newTTFLabel({text = info.onlineCount.."/"..info.fullCount,
                                        size = 27,
                                        color = cc.c3b(240,240,50),
                                        font = FONT_PTY_TEXT,
                                        align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                                    })
    content:enableOutline(cc.c4b(141,0,166,255*0.7),2)
    content:setPosition(cc.p(500,52))
    node:addChild(content)

    return node

end

function roomSelectLayer:onEnter()
    print("roomSelectLayer:onEnter")
    self.bindIds = {}
    self.bindIds[#self.bindIds + 1] = BindTool.bind(RoomInfo, "loginResult", handler(self, self.loginRoomResult))
    self.bindIds[#self.bindIds + 1] = BindTool.bind(RoomInfo, "logoutResult", handler(self, self.logOutResult))
    self.bindIds[#self.bindIds + 1] = BindTool.bind(DataManager, "tabelStatuChange", handler(self, self.onTableStatusChange))
    self.connected_handler = GameConnection:addEventListener(NetworkManagerEvent.SOCKET_CONNECTED, handler(self, self.onSocketStatus))
end

function roomSelectLayer:onExit()

    print("roomSelectLayer:onExit")
    for _, bindid in ipairs(self.bindIds) do
        BindTool.unbind(bindid)
    end
    GameConnection:removeEventListener(self.connected_handler)

end

function roomSelectLayer:onSocketStatus(event)
    print(".... roomSelectLayer:enterRoomRequest back ..............."..event.name)
    if event.name == NetworkManagerEvent.SOCKET_CONNECTED and self.preConnect then
        RoomInfo:sendLoginRequest(0, 60)
    elseif event.name == NetworkManagerEvent.SOCKET_CLOSED then
        
    elseif event.name == NetworkManagerEvent.SOCKET_CONNECTE_FAILURE then
        
    end
end

--登陆返回结果，不一定成功
function roomSelectLayer:loginRoomResult(event)
    if RoomInfo.loginResult == false then
        print("------登陆房间失败code:", RoomInfo.loginResultCode)
        self:performWithDelay(function() GameConnection:closeConnect() end, 0.1)
    else
        print("登陆成功!")
    end
end

--登出房间
function roomSelectLayer:logOutResult(event)
    if RoomInfo.logoutResult == true then
        print("------登出房间成功----------")
        -- GameConnection:closeConnect()
        -- self:performWithDelay(
        --     function()
        --         print(self.index.."进入"..self.room_list[self.index].serverName..":"..self.room_list[self.index].serverPort.."...."..self.room_list[self.index].serverAddr)
        --         self.roomAddr = self.room_list[self.index].serverAddr
        --         self.roomPort = self.room_list[self.index].serverPort
        --         self.preConnect = true

        --         if GameConnection.isConnected then
        --             GameConnection:closeConnect();
        --         end
        --         GameConnection:connectServer(self.roomAddr, self.roomPort)
        --     end,
        --     1.0
        -- )
    end
end

function roomSelectLayer:onTableStatusChange(event)
    print("------roomSelectLayer:onTableStatusChange:", DataManager.myUserInfo.userStatus)
    if DataManager.myUserInfo.userStatus == US_PLAYING then
        TableInfo:sendGameOptionRequest(true)
        print("一般情况下不会进来..........")
    else
        Hall.hideWaitingState()

        local room = require("layer.roomLayer").new(self.parent.roomIndex, self.index, self.parent.sitTableId);
        display.replaceScene(room:scene());
        -- self:removeFromParent()
    end
end

return roomSelectLayer