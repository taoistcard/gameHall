
require("tools.BindTool")
require("tools.tools")
require("gameConfig");
require("platform.PlatformFunction")

require("network.HallConnection")
require("network.GameConnection")

AccountInfo = require("datamodel.hall.AccountInfo")
BankInfo = require("datamodel.hall.BankInfo")
HeartBeatInfo = require("datamodel.hall.HeartBeatInfo")
MessageInfo = require("datamodel.hall.MessageInfo")
PayInfo = require("datamodel.hall.PayInfo")
RankingInfo = require("datamodel.hall.RankingInfo")
ServerInfo = require("datamodel.hall.ServerInfo")

ChatInfo = require("datamodel.game.ChatInfo")
GameUserInfo = require("datamodel.game.GameUserInfo")
GameHeartBeatInfo = require("datamodel.game.HeartBeatInfo")
PropertyInfo = require("datamodel.game.PropertyInfo")
RoomInfo = require("datamodel.game.RoomInfo")
TableInfo = require("datamodel.game.TableInfo")
GameUserInfo = require("datamodel.game.GameUserInfo")


FishInfo = require("datamodel.fish.FishInfo")

SystemMessageInfo = require("datamodel.common.SystemMessageInfo")

local scheduler = require("framework.scheduler")

local NetWorkTestScene = class("NetWorkTestScene", function()
    return display.newScene()
end)

function NetWorkTestScene:ctor()
    self:setNodeEventEnabled(true)

    local winSize = cc.Director:getInstance():getWinSize()

    -- 基本容器 1136*640
    self.container = cc.Layer:create()
    -- self.container:setContentSize(cc.size(display.width,display.height))
    -- self.container:setPosition(cc.p(winSize.width/2,winSize.height/2));
    -- self.container:setAnchorPoint(cc.p(0.5,0.5))
    -- self.container:ignoreAnchorPointForPosition(false)
    self:addChild(self.container)

    -- self.container:setRotation(180)

    -------------变量------------------
    self.listMsg = {}
    self.curFish = {}

    -------初始化---datamodel--------
    -- AccountInfo:init()
    -- BankInfo:init()
    -- HeartBeatInfo:init()
    -- MessageInfo:init()
    -- PayInfo:init()
    -- RankingInfo:init()
    -- ServerInfo:init()

    -- GameUserInfo:init()
    -- GameHeartBeatInfo:init()
    -- PropertyInfo:init()
    -- RoomInfo:init()
    -- TableInfo:init()
    -- ChatInfo:init()
    -- GameUserInfo:init()
    -- FishInfo:init()
    -- SystemMessageInfo:init()



    self:bindEvent()

    

end

function NetWorkTestScene:onEnter()

	self.listView = ccui.ListView:create()
    self.listView:setDirection(ccui.ScrollViewDir.vertical)
    self.listView:setBounceEnabled(true)
    self.listView:setContentSize(cc.size(600, 640))
    self.listView:setPosition(450,0)
    self.container:addChild(self.listView)

	local btn = ccui.Button:create("btn_green.png");
    btn:setTitleText("登陆");
    btn:setTitleFontSize(30);
    btn:setScale9Enabled(true);
    btn:setContentSize(cc.size(200, 60));
    btn:setPosition(cc.p(80, 620));
    self.container:addChild(btn);
    btn:setPressedActionEnabled(true);
    btn:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                AccountInfo:sendSimulatorLoginRequest("捕鱼达人852221"..math.random(0,100))
            end
        end
    )

    local btn = ccui.Button:create("btn_green.png");
    btn:setTitleText("登陆房间");
    btn:setTitleFontSize(30);
    btn:setScale9Enabled(true);
    btn:setContentSize(cc.size(200, 60));
    btn:setPosition(cc.p(80, 540));
    self.container:addChild(btn);
    btn:setPressedActionEnabled(true);
    btn:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                RoomInfo:sendLoginRequest(0, 60)
            end
        end
    )

    local btn = ccui.Button:create("btn_green.png");
    btn:setTitleText("坐下打渔");
    btn:setTitleFontSize(30);
    btn:setScale9Enabled(true);
    btn:setContentSize(cc.size(200, 60));
    btn:setPosition(cc.p(80, 460));
    self.container:addChild(btn);
    btn:setPressedActionEnabled(true);
    btn:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                TableInfo:sendUserSitdownRequest(self.sitTableId, 2, "")
            end
        end
    )

    local btn = ccui.Button:create("btn_green.png");
    btn:setTitleText("坐下打渔2");
    btn:setTitleFontSize(30);
    btn:setScale9Enabled(true);
    btn:setContentSize(cc.size(200, 60));
    btn:setPosition(cc.p(80, 380));
    self.container:addChild(btn);
    btn:setPressedActionEnabled(true);
    btn:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                TableInfo:sendUserSitdownRequest(self.sitTableId, 3, "")
            end
        end
    )

    local btn = ccui.Button:create("btn_green.png");
    btn:setTitleText("站起");
    btn:setTitleFontSize(30);
    btn:setScale9Enabled(true);
    btn:setContentSize(cc.size(200, 60));
    btn:setPosition(cc.p(80, 300));
    self.container:addChild(btn);
    btn:setPressedActionEnabled(true);
    btn:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                TableInfo:sendUserStandUpRequest(true);
            end
        end
    )
end

function NetWorkTestScene:onExit()
	self:unBindEvent()
end

function NetWorkTestScene:bindEvent()
    self.bindIds = {}
    self.bindIds[#self.bindIds + 1] = BindTool.bind(AccountInfo, "isRegister", handler(self, self.refreshUserInfo))
    self.bindIds[#self.bindIds + 1] = BindTool.bind(SystemMessageInfo, "msgRresh", handler(self, self.refreshSysMsgRresh))
    self.bindIds[#self.bindIds + 1] = BindTool.bind(MessageInfo, "systemLogonMsg", handler(self, self.refreshSysMsg))
    self.bindIds[#self.bindIds + 1] = BindTool.bind(ServerInfo, "nodeItemList", handler(self, self.refreshServerNode))
    self.bindIds[#self.bindIds + 1] = BindTool.bind(RoomInfo, "tableStatus", handler(self, self.refreshTableStatus))--有人坐下桌子
    self.bindIds[#self.bindIds + 1] = BindTool.bind(RoomInfo, "tableStatusList", handler(self, self.refreshTableStatusMsg))
    self.bindIds[#self.bindIds + 1] = BindTool.bind(RoomInfo, "userInfoList", handler(self, self.refreshGameServerMsg))
    self.bindIds[#self.bindIds + 1] = BindTool.bind(PropertyInfo, "trumpetScore", handler(self, self.refreshProperty))
    self.bindIds[#self.bindIds + 1] = BindTool.bind(TableInfo, "userStatus", handler(self, self.refreshTableUserStatus))
    self.bindIds[#self.bindIds + 1] = BindTool.bind(TableInfo, "userSitDownResult", handler(self, self.refreshSitDown))
    self.bindIds[#self.bindIds + 1] = BindTool.bind(FishInfo, "gameConfig", handler(self, self.refreshFishGameConfig))
    self.bindIds[#self.bindIds + 1] = BindTool.bind(FishInfo, "catchFish", handler(self, self.refreshCatchFish))
    self.bindIds[#self.bindIds + 1] = BindTool.bind(FishInfo, "fishSpawnList", handler(self, self.refreshNewFishList))
end

function NetWorkTestScene:unBindEvent()
    for _, bindid in ipairs(self.bindIds) do
        BindTool.unbind(bindid)
    end
end

function NetWorkTestScene:refreshScrollView()
	self.listView:removeAllItems()

	for _, msg in ipairs(self.listMsg) do
		local itbg = ccui.ImageView:create("btn_green.png")
        itbg:setScale9Enabled(true);
    	itbg:setContentSize(cc.size(600, 60));
        itbg:ignoreAnchorPointForPosition(true)

        local itemName = ccui.Text:create(msg, "Arial", 24)
        itemName:setTextColor(cc.c4b(255, 255, 255, 255))
        itemName:setAnchorPoint(cc.p(0,0.5))
        itemName:setPosition(cc.p(5,30))
        itbg:addChild(itemName)

        local custom_item = ccui.Layout:create()
        custom_item:setContentSize(cc.size(600, 70))
        itbg:setPosition(0, 5)
        custom_item:addChild(itbg)
        
        self.listView:pushBackCustomItem(custom_item)
	end
end

function NetWorkTestScene:refreshUserInfo(event)
    self:pushMsgItem("UserId:"..AccountInfo:getUserId()..";nickName:"..AccountInfo:getNickName())
end

function NetWorkTestScene:refreshSysMsgRresh(event)
	for typeid, msgarr in ipairs(SystemMessageInfo.messages) do
    	self:pushMsgItem("commonSysMsg:"..typeid)
    	for _, msg in ipairs(msgarr) do
    		self:pushMsgItem("comSysMsg:"..msg)
    	end
    end
end


function NetWorkTestScene:refreshSysMsg(event)
	for _, msg in ipairs(MessageInfo.systemLogonMsg) do
    	self:pushMsgItem("SysMsg:"..msg.msg)
    end
end

function NetWorkTestScene:refreshServerNode(event)
	for _, noitem in ipairs(ServerInfo.nodeItemList) do
		self:pushMsgItem("nodeId:"..noitem.nodeID..";kindId:"..noitem.kindID..";name:"..noitem.name)
		for i, room in ipairs(noitem.serverList) do
			self:pushMsgItem("ID:"..room.serverID..";Addr:"..room.serverAddr..";Port:"..room.serverPort..";Name:"..room.serverName)
		end
	end

	local room = ServerInfo.nodeItemList[1].serverList[1]
	self.roomAddr = room.serverAddr
	self.roomPort = room.serverPort
	GameConnection:connectServer(self.roomAddr, self.roomPort)
	self:refreshScrollView()
end

function NetWorkTestScene:refreshTableStatus(event)
	self:pushMsgItem("桌子:"..RoomInfo.tableStatus.tableID.."状态变化:"..tostring(RoomInfo.tableStatus.isStarted)..";count:"..RoomInfo.tableStatus.sitCount)
end

function NetWorkTestScene:refreshTableStatusMsg(event)

	self:pushMsgItem("桌数:"..RoomInfo.serverConfig.tableCount.."椅数:"..RoomInfo.serverConfig.chairCount)

	local table = RoomInfo.tableStatusList[5]
	self.sitTableId = table.tableID
    TableInfo.sitTableId = table.tableID
	self:pushMsgItem("桌子:"..table.tableID.."开始:"..tostring(table.isStarted))
end

function NetWorkTestScene:refreshGameServerMsg(event)
	self:pushMsgItem("id:"..RoomInfo.userInfo.userID..";name:"..RoomInfo.userInfo.nickName..";table:"..RoomInfo.userInfo.tableID)
	self:pushMsgItem("chair:"..RoomInfo.userInfo.chairID..";Sta:"..RoomInfo.userInfo.userStatus..";score:"..RoomInfo.userInfo.score)
	self:pushMsgItem("      -----user--------")
	for _, stat in ipairs(RoomInfo.userInfoList) do
		self:pushMsgItem("id:"..stat.userID..";name:"..stat.nickName..";table:"..stat.tableID)
		self:pushMsgItem("chair:"..stat.chairID..";Sta:"..stat.userStatus..";score:"..stat.score)
		self:pushMsgItem("      -----user----list----")

        if stat.userID == AccountInfo.userId and stat.userStatus == US_PLAYING then print("---自己断线重连----")
            --自己断线重连，不用坐下，直接发gameoption
            TableInfo:sendGameOptionRequest(true)
        end
	end
end

function NetWorkTestScene:refreshProperty(event)
 --[[
	for _, item in ipairs(PropertyInfo.configList) do
    	self:pushMsgItem("property id:"..item.id..";gold:"..item.propertyGold)
    end
    self:pushMsgItem("      -----property--------")
   --]]
    self:refreshScrollView()
end

function NetWorkTestScene:refreshTableUserStatus(event)
	self:pushMsgItem("用户:"..TableInfo.userStatus.userID.."tabId:"..TableInfo.userStatus.tableID..";chaid:"..TableInfo.userStatus.chairID..";sta:"..TableInfo.userStatus.userStatus)

	self:refreshScrollView()
end

function NetWorkTestScene:refreshSitDown(event)
	self:pushMsgItem("坐下成功")
	TableInfo:sendGameOptionRequest(true)
	self:refreshScrollView()
end

function NetWorkTestScene:refreshFishGameConfig(event)
	self.bulletMultipleMin = FishInfo.gameConfig.bulletMultipleMin

    print("------NetWorkTestScene:refreshFishGameConfig-----")
    self:selectGame("fishing")
end

function NetWorkTestScene:getFireGunLevel(gunNumber)
	 local bullet_kinds = 0
    if(gunNumber< self.bulletMultipleMin*10) then
        bullet_kinds = 0
    elseif gunNumber< self.bulletMultipleMin*100 then
         bullet_kinds = 1
    elseif gunNumber< self.bulletMultipleMin*1000 then
         bullet_kinds = 2
    elseif gunNumber< self.bulletMultipleMin*10000 then
         bullet_kinds = 3
    end
    return bullet_kinds;
end

function NetWorkTestScene:refreshCatchFish(event) 
	local catchinfo = FishInfo.catchFish

	self:pushMsgItem("chair:"..catchinfo.chairID..";fish:"..catchinfo.fishID..";fiKind:"..catchinfo.fishKind)
	self:pushMsgItem("score:"..catchinfo.fishScore..";fishMulti:"..catchinfo.fishMulti)
	self:pushMsgItem("      -----抓到鱼了--------")
	self:refreshScrollView()
	local removeindex = -1
	for k, item in ipairs(self.curFish) do
		if item.fishID == catchinfo.fishID and item.fishKind == catchinfo.fishKind then
			removeindex = k
			break
		end
	end
	if removeindex > 0 then
		table.remove(self.curFish, removeindex)
	end
end

function NetWorkTestScene:refreshNewFishList(event)

	for _, item in ipairs(FishInfo.fishSpawnList) do
		self.curFish[#self.curFish + 1] = item
	end

end

function NetWorkTestScene:pushMsgItem(msg)
	-- self.listMsg[#self.listMsg + 1] = msg
	table.insert(self.listMsg, 1, msg)
end

function NetWorkTestScene:selectGame(gameName)

    if LOAD_FROM_BIN then

        cc.LuaLoadChunksFromZIP(gameName.."/"..gameName..".bin");

    end

    package.path = package.path .. ";src/" .. gameName .. "/?.lua";
    
    local gamePath = gameName;

    scheduler.performWithDelayGlobal(
        function()
            local game = require(gamePath).new();
            game:start();
        end,
        0.3
    )

end

return NetWorkTestScene