require("network.GameConnection")
require("define.CMD_GAME")
require("protocol.gameServer.gameServer_table_c2s_pb")
require("protocol.gameServer.gameServer_table_s2c_pb")

-- 用户状态
US_NULL = 0x00;                -- 没有状态
US_FREE = 0x01;                -- 站立状态
US_SIT = 0x02;                -- 坐下状态
US_READY = 0x03;                -- 同意状态
US_LOOKON = 0x04;                -- 旁观状态
US_PLAYING = 0x05;                -- 游戏状态
US_OFFLINE = 0x06;                -- 断线状态

GAME_PLAYER = 6;


PlazaVersion = 101056515
GAME_STATUS_FREE = 0;                   -- 空闲状态
GAME_STATUS_PLAY = 1;                 -- 游戏状态
GAME_STATUS_WAIT = 2;                 -- 等待状态
GAME_SCENE_CALL  = GAME_STATUS_PLAY			--叫分状态
GAME_SCENE_PLAY  = GAME_STATUS_PLAY + 100		--游戏进行
GAME_SCENE_BET	 = GAME_STATUS_PLAY + 109		--礼券投注
GAME_STATUS_FIRST= GAME_STATUS_PLAY + 101		--游戏让先

local TableInfo = {};

function TableInfo:init()
	self:initData()

	GameConnection:registerCmdReceiveNotify(CMD_GAME.USER_SITDOWN, self)
	GameConnection:registerCmdReceiveNotify(CMD_GAME.USER_STAND_UP, self)
	GameConnection:registerCmdReceiveNotify(CMD_GAME.USER_LOOK_ON, self)
	GameConnection:registerCmdReceiveNotify(CMD_GAME.KICK_USER, self)

	GameConnection:registerCmdReceiveNotify(CMD_GAME.USER_STATUS, self)
	GameConnection:registerCmdReceiveNotify(CMD_GAME.GAME_STATUS, self)
	GameConnection:registerCmdReceiveNotify(CMD_GAME.ALL_PLAYER_LEFT, self)
	GameConnection:registerCmdReceiveNotify(CMD_GAME.KICK_USER_NOTIFY, self)

	GameConnection:registerCmdReceiveNotify(CMD_GAME.USER_INFO, self)
	GameConnection:registerCmdReceiveNotify(CMD_GAME.USER_INFO_LIST, self)
	GameConnection:registerCmdReceiveNotify(CMD_GAME.AUTO_MATCH, self)
	GameConnection:registerCmdReceiveNotify(CMD_GAME.USERSLOOKONINFO, self)
end

function TableInfo:onReceiveCmdResponse(mainID, subID, data)
	if mainID == CMD_GAME.USER_SITDOWN then
		self:onReceiveUserSitdownResponse(data)
	elseif mainID == CMD_GAME.USER_STAND_UP then 
		self:onReceiveUserStandUpResponse(data)
	elseif mainID == CMD_GAME.USER_LOOK_ON then 
		self:onReceiveUserLookOnResponse(data)
	elseif mainID == CMD_GAME.KICK_USER then 
		self:onReceiveKickUserResponse(data)
	elseif mainID == CMD_GAME.USER_STATUS then 
		self:onReceiveUserStatusResponse(data)
	elseif mainID == CMD_GAME.GAME_STATUS then 
		self:onReceiveGameStatusResponse(data)
	elseif mainID == CMD_GAME.ALL_PLAYER_LEFT then 
		self:onReceiveAllPlayerLeftResponse(data)
	elseif mainID == CMD_GAME.KICK_USER_NOTIFY then 
		self:onReceiveKickUserNotifyResponse(data)
	elseif mainID == CMD_GAME.AUTO_MATCH then 
		self:onReceiveAutoMatchResponse(data)

	elseif mainID == CMD_GAME.USERSLOOKONINFO then 
		self:onReceiveUsersLookOnInfoResponse(data)
	end
end
function TableInfo:sendUsersLookOnInfoRequest(tableID)
	local request = protocol.gameServer.gameServer.table.c2s_pb.UsersLookonInfo()
	request.tableID = tableID

    local pData = request:SerializeToString()
    local pDataLen = string.len(pData)
    GameConnection:sendCommand(CMD_GAME.USERSLOOKONINFO , 0, pData, pDataLen)
end
function TableInfo:sendUserSitdownRequest(tableID, chairID, password)
	local request = protocol.gameServer.gameServer.table.c2s_pb.UserSitDown()
	request.tableID = tableID
	request.chairID = chairID
	request.password = password or ""

    local pData = request:SerializeToString()
    local pDataLen = string.len(pData)
    GameConnection:sendCommand(CMD_GAME.USER_SITDOWN , 0, pData, pDataLen)
end

function TableInfo:sendGameOptionRequest(isAllowLookon)
	local request = protocol.gameServer.gameServer.table.c2s_pb.GameOption()
	request.isAllowLookon = isAllowLookon or false

    local pData = request:SerializeToString()
    local pDataLen = string.len(pData)
    GameConnection:sendCommand(CMD_GAME.GAME_OPTION , 0, pData, pDataLen)
end

function TableInfo:sendUserStandUpRequest(isForce)
	local request = protocol.gameServer.gameServer.table.c2s_pb.UserStandUp()
	request.isForce = isForce or false

    local pData = request:SerializeToString()
    local pDataLen = string.len(pData)
    GameConnection:sendCommand(CMD_GAME.USER_STAND_UP , 0, pData, pDataLen)
end

function TableInfo:sendAutoMatch()
	--0x010230
	print("============sendAutoMatch!")
	GameConnection:sendCommand(CMD_GAME.AUTO_MATCH , 0)

end

function TableInfo:sendUserReadyRequest()
	local request = protocol.gameServer.gameServer.table.c2s_pb.UserReady()
	-- Hall.showTips("我是坐下", 3)
    local pData = request:SerializeToString()
    local pDataLen = string.len(pData)
    GameConnection:sendCommand(CMD_GAME.USER_READY , 0, pData, pDataLen)
end

function TableInfo:sendUserLookonRequest(tableID, chairID, password)
	local request = protocol.gameServer.gameServer.table.c2s_pb.UserLookon()
	request.tableID = tableID
	request.chairID = chairID
	request.password = password

    local pData = request:SerializeToString()
    local pDataLen = string.len(pData)
    GameConnection:sendCommand(CMD_GAME.USER_LOOK_ON , 0, pData, pDataLen)
end

function TableInfo:sendKickUserRequest(chairID)
	local request = protocol.gameServer.gameServer.table.c2s_pb.KickUser()
	request.chairID = chairID
	
    local pData = request:SerializeToString()
    local pDataLen = string.len(pData)
    GameConnection:sendCommand(CMD_GAME.KICK_USER , 0, pData, pDataLen)
end
function TableInfo:onReceiveUsersLookOnInfoResponse(data)
	local response = protocol.gameServer.gameServer.table.s2c_pb.UsersLookonInfo()
	response:ParseFromString(data)
	self:setUsersLookonInfo(copyProtoTable(response))
end
function TableInfo:onReceiveKickUserNotifyResponse(data)
	local response = protocol.gameServer.gameServer.table.s2c_pb.KickUserNotify()
	response:ParseFromString(data)
	print("踢人通知",response.msg)
	Hall.showTips(response.msg, 1)
	self:setKickUserMsg(response.msg)
end

function TableInfo:onReceiveAllPlayerLeftResponse(data)
	local response = protocol.gameServer.gameServer.table.s2c_pb.AllPlayerLeft()
	response:ParseFromString(data)
	self:setAllPlayerLeft(true)
end

function TableInfo:onReceiveGameStatusResponse(data)
	local response = protocol.gameServer.gameServer.table.s2c_pb.GameStatus()
	response:ParseFromString(data)
	self:setGameStatus(response.gameStatus)
end

function TableInfo:onReceiveUserStatusResponse(data)
	local response = protocol.gameServer.gameServer.table.s2c_pb.UserStatus()
	response:ParseFromString(data)
	local tem = {}
	tem.userID = response.userID
	tem.tableID = response.tableID
	tem.chairID = response.chairID
	tem.userStatus = response.userStatus
	-- print("response.userID",response.userID,"response.tableID",response.tableID,"response.chairID",response.chairID,"response.userStatus",response.userStatus)
	local userInfo = DataManager:getUserInfoByUserID(response.userID)
	if userInfo then
		userInfo.userID = response.userID
		userInfo.tableID = response.tableID
		userInfo.chairID = response.chairID
		userInfo.userStatus = response.userStatus
	end

	self:setUserStatus(tem)
end

function TableInfo:onReceiveKickUserResponse(data)
	local response = protocol.gameServer.gameServer.table.s2c_pb.KickUser()
	response:ParseFromString(data)


    self:setKickUserResult(response)
     

end

function TableInfo:onReceiveUserLookOnResponse(data)
	local response = protocol.gameServer.gameServer.table.s2c_pb.UserLookon()
	response:ParseFromString(data)
	if response.code == 0 then
		self:setUserLookOnResult(true)
	else
		
	end
end

function TableInfo:onReceiveUserSitdownResponse(data)
	local response = protocol.gameServer.gameServer.table.s2c_pb.UserSitDown()
	response:ParseFromString(data)
	print("------坐下中-------", response.code)
	if response.code == nil then
		self:setUserSitDownResult(response)
	else
		self:setUserSitDownResult(response)
		print("------坐下失败-------", response.code,response.msg)
	end
end

function TableInfo:onReceiveUserStandUpResponse(data)
	local response = protocol.gameServer.gameServer.table.s2c_pb.UserStandUp()
	response:ParseFromString(data)
	if response.code == nil then
		self:setUserStandUpResult(true)
	else
		
	end
end

function TableInfo:onReceiveAutoMatchResponse(data)
	--[[
	message UserAutoAllocSignup 							// 0x010230
	{
		enum RetCode {
			RC_OK=0;
			RC_USER_STATUS_PLAYING=1;						// 您正在游戏中，暂时不能离开，请先结束当前游戏！
			RC_MIN_ENTER_SCORE=2;
			RC_MAX_ENTER_SCORE=3;
			RC_MIN_ENTER_MEMBER=4;
			RC_MAX_ENTER_MEMBER=5;
			RC_MIN_TABLE_SCORE=6;
			RC_ROOM_FULL=7;									// 当前游戏房间已经人满为患了，暂时没有可以让您加入的位置，请稍后再试！
			RC_ROOM_CONFIG_FORBID=8;						// 抱歉，当前游戏桌子禁止用户进入！
			RC_TABLE_GAME_STARTED=9;						// 游戏已经开始了，现在不能进入游戏桌！
			RC_CHAIR_ALREADY_TAKEN=10;
			RC_PASSWORD_ERROR=11;							// 桌子密码错误
			RC_IP_CONFLICT_WITH_OTHER1=12;					// 此游戏桌玩家设置了不跟相同 IP 地址的玩家游戏，您 IP 地址与此玩家的 IP 地址相同，不能加入游戏！
			RC_IP_CONFLICT_WITH_OTHER2=13;					// 您设置了不跟相同 IP 地址的玩家游戏，此游戏桌存在与您 IP 地址相同的玩家，不能加入游戏！
			RC_SAME_IP_EXIST=14;							// 您设置了不跟相同 IP 地址的玩家游戏，此游戏桌存在 IP 地址相同的玩家，不能加入游戏！
			RC_USER_LIMIT_FLEE_RATE=15;
			RC_USER_LIMIT_WIN_RATE=16;
			RC_USER_LIMIT_SCORE_MAX=17;
			RC_USER_LIMIT_SCORE_MIN=18;
			RC_WAIT_DISTRIBUTE=19;							// 等待定时器IDI_DISTRIBUTE_USER进行分配
			RC_TABLE_FRAME_SINK=20;							// 游戏中定义的错误信息
			
		}
		required RetCode code=1;
		optional string msg=2;
		repeated UserInfo userInfoList=3;
	}]]
	local response = protocol.gameServer.gameServer.table.s2c_pb.UserAutoAllocSignup()
	response:ParseFromString(data)
	self:setSignUp(response)
end

function TableInfo:initData()
	BindTool.register(self, "userSitDownResult", nil)
	BindTool.register(self, "userStandUpResult", false)
	BindTool.register(self, "userLookOnResult", false)
	BindTool.register(self, "kickUserResult", false)
	BindTool.register(self, "userStatus", nil)
	BindTool.register(self, "gameStatus", 0)
	BindTool.register(self, "allPlayerLeft", false)
	BindTool.register(self, "kickUserMsg", nil)
	BindTool.register(self, "signUp", nil)
	BindTool.register(self, "usersLookonInfo", nil)
end

return TableInfo