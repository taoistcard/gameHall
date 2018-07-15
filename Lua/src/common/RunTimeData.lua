RunTimeData = {}

function RunTimeData:initData()
    self.kindID = {}
    self.curGameID = 200
    self.curGameServerType = 0
    self.popFrom = 0
    self.curRoomIndex = 0
    self.curGameServer = nil
    self.nickname = ""
    self.autoLogin = false
    self.couponConfig = {
        {description = "分别打出两个炸弹并获胜",kind=1,count=5},
        {description = "打出三连飞机并获胜",kind=1,count=25},
        {description = "分别打出三个炸弹并获胜",kind=1,count=100},
        {description = "分别打出四个炸弹并获胜",kind=2,count=2},
        [30]={description = "获胜10局",kind=1,count=10,completeCount=21},
    }
    self.lianshengConfig = {
        [1]={description = "1连胜",kind=1,count=2,completeCount=1},
        [2]={description = "1连胜",kind=1,count=4,completeCount=2},
        [3]={description = "1连胜",kind=1,count=10,completeCount=3},
        [4]={description = "1连胜",kind=1,count=25,completeCount=4},
        [5]={description = "1连胜",kind=1,count=50,completeCount=5},
        [6]={description = "1连胜",kind=1,count=100,completeCount=6},
        [7]={description = "1连胜",kind=1,count=200,completeCount=7},
        [8]={description = "1连胜",kind=1,count=500,completeCount=8},
        [9]={description = "1连胜",kind=2,count=2,completeCount=9},
        [10]={description = "1连胜",kind=2,count=5,completeCount=10},
    }
    self.chongzhiStatus = {[1]=0,[6]=0,[12]=0,[50]=0,[100]=0,[200]=0,[500]=0}
    self.chargeStatus={}
    self.leftExchangeBeans = 0
    self.taskCount = {[1]=0,[2]=0,[3]=0,[4]=0,[20]=0,[30]=0}
    self.queryTask = 0
    -- self:loadTimeBoxRecord()

    --应用推荐列表数据
    self.recommandAppListData = nil

    self.payorderitems = nil --新游戏服务器充值项从服务端返回
end

function RunTimeData:loadTimeBoxRecord()
    local timeBoxRecord = {}

    local timeBoxRecordStr = cc.UserDefault:getInstance():getStringForKey("timeBoxRecord","")
    local splitArr = string.split(timeBoxRecordStr,",")

    local curDate = os.date("%Y%m%d")
    if #splitArr == 4 and curDate == splitArr[1] then
        timeBoxRecord.recordDate = splitArr[1]
        timeBoxRecord.boxType = tonumber(splitArr[2]) 
        timeBoxRecord.leftSecond = tonumber(splitArr[3])
        timeBoxRecord.userID = tonumber(splitArr[4])
        timeBoxRecord.hasBox = true

        if timeBoxRecord.boxType > #TimeBoxConfig then
            timeBoxRecord.hasBox = false
        end

        return timeBoxRecord
    end
    --[[
    timeBoxRecord.recordDate = curDate
    timeBoxRecord.boxType = 1
    timeBoxRecord.leftSecond = TimeBoxConfig[timeBoxRecord.boxType]
    timeBoxRecord.hasBox = true
    ]]
    return nil
end

function RunTimeData:getDefaultRecord()
    local timeBoxRecord = {}
    timeBoxRecord.recordDate = os.date("%Y%m%d")
    timeBoxRecord.boxType = 1
    timeBoxRecord.leftSecond = TimeBoxConfig[timeBoxRecord.boxType]
    timeBoxRecord.hasBox = true
    timeBoxRecord.userID = PlayerInfo:getMyUserID()

    return timeBoxRecord
end

function RunTimeData:saveTimeBoxRecord(timeBoxRecord)
    local timeBoxRecordStr = timeBoxRecord.recordDate..","..timeBoxRecord.boxType..","..timeBoxRecord.leftSecond..","..timeBoxRecord.userID
    cc.UserDefault:getInstance():setStringForKey("timeBoxRecord", timeBoxRecordStr)
end

function RunTimeData:loadAccount()
    if (self.account == nil) then
        return cc.UserDefault:getInstance():getStringForKey("account","")
    end
    return self.account;
end

function RunTimeData:loadPassword()
    if (self.password == nil) then
        return cc.UserDefault:getInstance():getStringForKey("password","")
    end
    return self.password;
end

function RunTimeData:loadUserID()
    if (self.userID == nil) then
        return cc.UserDefault:getInstance():getStringForKey("userID","")
    end
    return self.userID;
end

function RunTimeData:getCouponConfig()
    return self.couponConfig
end

function RunTimeData:getMachineID()
    return GetDeviceID();
end

function RunTimeData:loadTokenID()
    if (self.tokenID == nil) then
        return cc.UserDefault:getInstance():getStringForKey("tokenID","")
    end
    return self.tokenID;
end

function RunTimeData:saveTokenID(tokenID)
    --重复登陆，self.tokenID不为空，而且可能换账号登陆，这里不可以加判断
	-- if self.tokenID==nil then
        self.tokenID = tokenID
        cc.UserDefault:getInstance():setStringForKey("tokenID", tokenID)
    -- end
end
function RunTimeData:setHasQueryTask(hasQuery)
    self.queryTask = hasQuery
end
function RunTimeData:getHasQureyTask()
    return self.queryTask
end
--任务完成次数
--@param  key 1打出两炸弹并获胜,2打出三连飞机并获胜,3打出三炸弹并获胜,4打出四炸弹并获胜
function RunTimeData:setTaskCount(key,value)
    self.taskCount[key] = value
end
function RunTimeData:getTaskCount(key)
    return self.taskCount[key]
end
--连胜次数
function RunTimeData:setLeftExchangeBeans(value)
    self.leftExchangeBeans = value
end
function RunTimeData:getLeftExchangeBeans()
    return self.leftExchangeBeans
end
--@ param  key 1~500元
--@ param  value 0没充值过 1充值过
function RunTimeData:setChongZhiStatus(key,value)
    self.chongzhiStatus[key] = value
end
function RunTimeData:getChongZhiStatus(key)
    return self.chongzhiStatus[key]
end

function RunTimeData:setChargeStatus(productType, value)
    if value then
        self.chargeStatus[productType] = 1
    else
        self.chargeStatus[productType] = nil
    end
end

function RunTimeData:getChargeStatus(productType)
    return self.chargeStatus[productType]
end

function RunTimeData:getNewGuestChargeStatus()
    if device.platform == "android" then
        return RunTimeData:getChargeStatus("394")
    else
        return RunTimeData:getChargeStatus("385")
    end
end

function RunTimeData:getDailyChargeStatus()
    if device.platform == "android" then
        return RunTimeData:getChargeStatus("393")
    else
        return RunTimeData:getChargeStatus("386")
    end
end

function RunTimeData:setNickName(name)
    self.nickname = name
end
function RunTimeData:getNickName()
    return self.nickname
end
--设置自动登录大厅
function RunTimeData:setAutoLogin(isauto)
    self.autoLogin = isauto
end
function RunTimeData:getAutoLogin()
    return self.autoLogin
end
--自定义头像地址
function RunTimeData:setCustomFaceUrl(url)
    self.customFaceUrl = url
end
function RunTimeData:getCustomFaceUrl()
    return self.customFaceUrl
end
--获取本地已保存的自定义头像地址
function RunTimeData:getLocalAvatarImageUrlByTokenID( tokenID )
    -- print("RunTimeData:getLocalAvatarImageUrlByTokenID")
    if device.platform == "ios" then
        return cc.FileUtils:getInstance():getWritablePath().."avatarImages/"..tokenID

    elseif device.platform == "android" then
        print("RunTimeData:getLocalAvatarImageUrlByTokenID ----- android")
        return getLocalAvatarImageUrlByUserID(tokenID)
        
    else
        return cc.FileUtils:getInstance():getWritablePath().."avatarImages/"..tokenID
    end
end
function RunTimeData:setCurKindID(kindID)
    cleanTable(self.kindID)
    for k,v in pairs(kindID) do
        self.kindID[k] = v
    end
end

function RunTimeData:getCurKindID()
    return self.kindID
end
--@params gameID 游戏类型 201视频场，200斗地主，202二人斗地主
function RunTimeData:setCurGameID(gameID)
    self.curGameID = gameID
end

function RunTimeData:getCurGameID()
    return self.curGameID
end
function RunTimeData:setCurGameNode(nodeID)
    self.curGameNode = nodeID
end
function RunTimeData:getCurGameNode()
    return self.curGameNode
end

function RunTimeData:setCurGameServer(gameServer)
    self.curGameServer = gameServer

    if (bit.band(self.curGameServer.serverType, Define.GAME_AUTO_ALLOC) == Define.GAME_AUTO_ALLOC) then
        IS_AUTOMATCH = true
    else
        IS_AUTOMATCH = false
    end

end

function RunTimeData:getCurGameServer()
    return self.curGameServer
end

function RunTimeData:getCurGameServerType()
    return self.curGameServer.serverType
    -- return self.curGameServerType
end
--@params roomIndex 1无限场2初级场3中级场4高级场
function RunTimeData:setRoomIndex(roomIndex)
    self.curRoomIndex = roomIndex
end
function RunTimeData:getRoomIndex()
    return self.curRoomIndex
end
--
function RunTimeData:setCurConnectServer(ServerAddr,ServerPort)
    self.ServerAddr = ServerAddr
    self.ServerPort = ServerPort
end
function RunTimeData:getRoomIndexByConnectServer()
    if self.ServerAddr ==nil or self.ServerPort == nil then
        return -1
    end
    local wCurKind = RunTimeData:getCurGameID()
    local listData = ServerListDataManager:achieveServerListDataByGameKindID(wCurKind)
    local userInfo = PlayerInfo:getMyUserInfo()
    local roomIndex = 0
    for i=1,4 do
        local roomCount = listData:numberOfRowsInSection(i)
        for j=1,roomCount do
            local gameServer = listData:getGameServer(i,j)
            if gameServer then
                if gameServer:getServerAddr() == self.ServerAddr and  gameServer:getServerPort() == self.ServerPort then
                    print("RunTimeData:getRoomIndexByConnectServer-gameServer:getServerAddr()",gameServer:getServerAddr(),"gameServer:getServerPort()",gameServer:getServerPort(),"getServerName",gameServer:getServerName())
                    -- dump(gameServer.gameServer, "gameServer")
                    roomIndex = i
                end
            end
        end
    end
    return roomIndex
end
--@params popFrom 0从大厅弹出1从房间弹出
function RunTimeData:setPopFrom( popFrom )
    self.popFrom = popFrom
end
function RunTimeData:getPopFrom()
    return self.popFrom
end
function RunTimeData:loadPassword()
    --print("PasswordPasswordPassword",GetDeviceID());
    return GetDeviceID();
end
-- 连接房间
function RunTimeData:connectToRoom(kindID,section,roomIndex)

    local nodeItem = ServerInfo:getNodeItemByIndex(kindID, section)
    local gameServer = nodeItem.serverList[roomIndex]
    if gameServer == nil then
        print("没有房间!!")
        return
    end
    
    --清理用户数据
    DataManager:cleanAllUserInfo()
    
    RunTimeData:setCurGameServer(gameServer)
    -- print("gameServer:getServerAddr(),gameServer:getServerPort()==",gameServer:getServerAddr(),gameServer:getServerPort())
    self:setRoomIndex(section)
     
    GameConnection:reconnectRoomServer(gameServer.serverAddr,gameServer.serverPort)
    Hall.showWaiting(5)
    self.roomInfo = {kindID,section,roomIndex}
end

function RunTimeData:onClickFastStart()

    local wCurKind = RunTimeData:getCurGameID()
    print("wCurKind",wCurKind)
    local listData = ServerListDataManager:achieveServerListDataByGameKindID(wCurKind)
    local userInfo = PlayerInfo:getMyUserInfo()

    for i=4,1,-1 do
        local gameServer = listData:getGameServer(i,1)
        if gameServer then
            local min = gameServer:getMinEnterScore()
            local max = gameServer:getMaxEnterScore()
            -- print("userInfo:score()",userInfo:score(),"userInfo:beans()",userInfo:beans())
            if gameServer:getServerType() == Define.GAME_GENRE_HAPPYBEANS then

                if userInfo:beans() >= min and (userInfo:beans() <= max or max == 0) then
                    self:connectToRoom(wCurKind,i,1)
                    print("wCurKind",wCurKind,"i",i)
                    return       
                end

            else
                if userInfo:score() >= min and (userInfo:score() <= max or max == 0) then
                    self:connectToRoom(wCurKind,i,1)
                    print("wCurKind",wCurKind,"i",i)
                    return
                end
            end
        end
    end

end

function RunTimeData:setRecommandAppListData(data)
    self.recommandAppListData = data;
end

function RunTimeData:setPayOrderItemList(data)
    self.payorderitems = data
end

function RunTimeData:getPayOrderItemList()
    return self.payorderitems
end

RunTimeData:initData()