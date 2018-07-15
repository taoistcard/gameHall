
require("network.GameConnection")
require("define.CMD_GAME")
require("protocol.gameServer.gameServer_login_c2s_pb")
require("protocol.gameServer.gameServer_login_s2c_pb")

local RoomInfo = {};

function RoomInfo:init()
	self:initData()
	GameConnection:registerCmdReceiveNotify(CMD_GAME.LOGIN, self)
	GameConnection:registerCmdReceiveNotify(CMD_GAME.LOGIN_ANDROID, self)
	GameConnection:registerCmdReceiveNotify(CMD_GAME.LOGOUT, self)
	GameConnection:registerCmdReceiveNotify(CMD_GAME.SERVER_CONFIG, self)
	GameConnection:registerCmdReceiveNotify(CMD_GAME.TABLE_STATUS, self)
	GameConnection:registerCmdReceiveNotify(CMD_GAME.TABLE_STATUS_LIST, self)
	GameConnection:registerCmdReceiveNotify(CMD_GAME.USER_INFO, self)
	GameConnection:registerCmdReceiveNotify(CMD_GAME.USER_INFO_LIST, self)
end

function RoomInfo:onReceiveCmdResponse(mainID, subID, data)
	if mainID == CMD_GAME.LOGIN then
		self:onReceiveLoginResponse(data)
	elseif mainID == CMD_GAME.LOGIN_ANDROID then 
		self:onReceiveAndroidLoginResponse(data)
	elseif mainID == CMD_GAME.LOGOUT then 
		self:onReceiveLogoutResponse(data)
	elseif mainID == CMD_GAME.SERVER_CONFIG then 
		self:onReceiveServerConfigResponse(data)
	elseif mainID == CMD_GAME.TABLE_STATUS then 
		self:onReceiveTableStatusResponse(data)
	elseif mainID == CMD_GAME.TABLE_STATUS_LIST then 
		self:onReceiveTableStatusListResponse(data)
	elseif mainID == CMD_GAME.USER_INFO then 
		self:onReceiveUserInfoResponse(data)
	elseif mainID == CMD_GAME.USER_INFO_LIST then 
		self:onReceiveUserInfoViewPortResponse(data)
	end
end

function RoomInfo:sendLoginRequest(behaviorFlags, pageTableCount)
	local request = protocol.gameServer.gameServer.login.c2s_pb.Login()
	request.session = SessionId
	request.behaviorFlags = behaviorFlags
	request.machineID = GetDeviceID()
	request.pageTableCount = pageTableCount

    local pData = request:SerializeToString()
    local pDataLen = string.len(pData)
    GameConnection:sendCommand(CMD_GAME.LOGIN , 0, pData, pDataLen)
end

function RoomInfo:sendLoginAndroidRequest(behaviorFlags, pageTableCount)
	local request = protocol.gameServer.gameServer.login.c2s_pb.AndroidLogin()
	request.session = SessionId
	request.behaviorFlags = behaviorFlags
	request.machineID = GetDeviceID()
	request.pageTableCount = pageTableCount

    local pData = request:SerializeToString()
    local pDataLen = string.len(pData)
    GameConnection:sendCommand(CMD_GAME.LOGIN_ANDROID , 0, pData, pDataLen)
end

function RoomInfo:sendLogoutRequest()
	local request = protocol.gameServer.gameServer.login.c2s_pb.Logout()

    local pData = request:SerializeToString()
    local pDataLen = string.len(pData)
    GameConnection:sendCommand(CMD_GAME.LOGOUT , 0, pData, pDataLen)
end

function RoomInfo:onReceiveLoginResponse(data)
	local response = protocol.gameServer.gameServer.login.s2c_pb.Login()
	response:ParseFromString(data)

	if response.code == 0 then
		self:setLoginResult(true)

	elseif response.code == 19 then
		self.loginResultCode = response.code
		self.loginResultMsg = response.msg
		self:setLoginResult(false)

	else
		self.loginResultCode = response.code
		self:setLoginResult(false)
		Hall.showTips(response.msg,2)
	end
	-- print(response.code, "...RoomInfo...onReceiveLoginResponse..."..response.msg)
end

function RoomInfo:onReceiveServerConfigResponse(data)
	local response = protocol.gameServer.gameServer.login.s2c_pb.ServerConfig()
	response:ParseFromString(data)

	local tem = {}
	tem.tableCount = response.tableCount
	tem.chairCount = response.chairCount
	tem.serverType = response.serverType
	tem.serverRule = response.serverRule

	self:setServerConfig(tem)
end

function RoomInfo:onReceiveTableStatusResponse(data)
	local response = protocol.gameServer.gameServer.login.s2c_pb.TableStatus()
	response:ParseFromString(data)

	local tem = {}
	tem.tableID = response.tableID
	tem.isLocked = response.isLocked
	tem.isStarted = response.isStarted
	tem.sitCount = response.sitCount

	-- if self.tableStatusList then
	-- 	for _, table in ipairs(self.tableStatusList) do
	-- 		if table.tableID == tem.tableID then
	-- 			table.isLocked = tem.isLocked
	-- 			table.isStarted = tem.isStarted
	-- 			table.sitCount = tem.sitCount
	-- 			break;
	-- 		end
	-- 	end
	-- end

	self:setTableStatus(tem)
end

function RoomInfo:onReceiveTableStatusListResponse(data)
	local response = protocol.gameServer.gameServer.login.s2c_pb.TableStatusList()
	response:ParseFromString(data)

	self:setTableStatusList(copyProtoTable(response.list))
end

function RoomInfo:onReceiveUserInfoResponse(data)
	local response = protocol.gameServer.gameServer.login.s2c_pb.UserInfo()
	response:ParseFromString(data)

	local tem = require("datamodel.struct.UserInfo").new() --{}
	tem:dataUserInfo(response)
	-- dump(response, "====onReceiveUserInfoResponse=====")
	-- tem.gameID=response.gameID;							--//游戏 I D
	-- tem.userID=response.userID;							--//用户 I D
	-- tem.platformID=response.platformID;
	-- tem.faceID=response.faceID;							--//头像索引
	-- tem.nickName=response.nickName;							--//用户昵称
	-- tem.gender=response.gender;							--//用户性别
	-- tem.memberOrder=response.memberOrder;						--//会员等级
	-- tem.masterOrder=response.masterOrder;						--//管理等级
	-- tem.tableID=response.tableID;							--//桌子索引
	-- tem.chairID=response.chairID;							--//椅子索引
	-- tem.userStatus=response.userStatus;						--//用户状态

	-- tem.score=response.score;							--//用户分数
	-- tem.insure=response.insure;							--//用户银行

	-- tem.medal=response.medal;							--//用户奖牌
	-- tem.experience=response.experience;						--//经验数值
	-- tem.loveLiness=response.loveLiness;						--//用户魅力
	-- tem.gift=response.gift;							--//礼券数
	-- tem.present=response.present;							--//优优奖牌

	-- tem.grade=response.grade;							--//用户成绩
	
	-- tem.winCount=response.winCount;						--//胜利盘数
	-- tem.lostCount=response.lostCount;						--//失败盘数
	-- tem.drawCount=response.drawCount;						--//和局盘数
	-- tem.fleeCount=response.fleeCount;						--//逃跑盘数

	-- tem.signature=response.signature;						--//个性签名
	-- tem.platformFace=response.platformFace;
	-- tem.scoreInGame = 0 								--游戏中人身上的钱（游戏中临时变量）

	-- if self.userInfoList then
	-- 	local flag = false
	-- 	for _, user in ipairs(self.userInfoList) do
	-- 		if user.userID == tem.userID then
	-- 			flag = true
	-- 			for key, value in pairs(user) do
	-- 				user[key] = tem[key]
	-- 			end
	-- 		end
	-- 	end
	-- 	if flag == false then
	-- 		self.userInfoList[#self.userInfoList + 1] = tem
	-- 	end
	-- else
	-- 	self.userInfoList = {}
	-- 	self.userInfoList[1] = tem
	-- end

	self:setUserInfo(tem)
end

function RoomInfo:onReceiveUserInfoViewPortResponse(data)
	local response = protocol.gameServer.gameServer.login.s2c_pb.UserInfoViewPort()
	response:ParseFromString(data)
	local list = copyProtoTable(response.list)

	--test 桌子上数据变化 请勿删除!!!!!!
	-- for i,v in ipairs(list) do
	-- 	if v.tableID == 1 and v.tableID ~= 65535 then
	--         local name = v.nickName
	--         if string.len(name) <= 0 then
	--             name = v.gameID
	--         end
	--         print("---RoomInfo:onReceiveUserInfoResponse",v.chairID,name)
	-- 	end
	-- end
	--test

	-- if self.userInfoList then
	-- 	if list then
	-- 		for _, user in ipairs(list) do
	-- 			local flag = false
	-- 			for _, useralr in ipairs(self.userInfoList) do
	-- 				if user.userID == useralr.userID then
	-- 					flag = true
	-- 					for key, value in pairs(user) do
	-- 						useralr[key] = value
	-- 					end
	-- 					break
	-- 				end
	-- 			end

	-- 			if flag == false then
	-- 				self.userInfoList[#self.userInfoList + 1] = user
	-- 			end
	-- 		end
	-- 	else
	-- 		--除了自己都没有人了，不管是在房间还是桌子上
	-- 		local selfUserInfo = nil
	-- 		for _, useralr in ipairs(self.userInfoList) do
	-- 			if useralr.userID == AccountInfo.userId then
	-- 				selfUserInfo = useralr
	-- 				break
	-- 			end
	-- 		end
	-- 		self.userInfoList = {}
	-- 		if selfUserInfo then
	-- 			self.userInfoList[1] = selfUserInfo
	-- 		end
	-- 	end
	-- else
	-- 	self.userInfoList = list
	-- end

	-- self:setUserInfoList(self.userInfoList)

	if list == nil then 
		self:setUserInfoList({})
	else
		self:setUserInfoList(list)
	end

end

function RoomInfo:onReceiveAndroidLoginResponse(data)
	local response = protocol.gameServer.gameServer.login.s2c_pb.AndroidLogin()
	response:ParseFromString(data)

end

function RoomInfo:onReceiveLogoutResponse(data)
	local response = protocol.gameServer.gameServer.login.s2c_pb.Logout()
	response:ParseFromString(data)
	if response.code == 0 then
		self:setLogoutResult(true)
	end
end

function RoomInfo:initData()
	BindTool.register(self, "loginResult", false)
	BindTool.register(self, "serverConfig", nil)
	BindTool.register(self, "tableStatus", nil)
	BindTool.register(self, "tableStatusList", nil)
	BindTool.register(self, "userInfo", nil)
	BindTool.register(self, "userInfoList", nil)
	BindTool.register(self, "logoutResult", false)
end

return RoomInfo