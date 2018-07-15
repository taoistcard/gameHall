require("define.CMD_HALL")
require("protocol.loginServer.loginServer_match_c2s_pb")
require("protocol.loginServer.loginServer_match_s2c_pb")
require("protocol.gameServer.gameServer_match_s2c_pb")
local MatchInfo = {}
function MatchInfo:init()
	self:initData()
	HallConnection:registerCmdReceiveNotify(CMD_HALL.MATCHSIGNUP, self)
	HallConnection:registerCmdReceiveNotify(CMD_HALL.USER_MATCHINFO, self)
	HallConnection:registerCmdReceiveNotify(CMD_HALL.QUERY_MATCHSERVERINFO, self)
	GameConnection:registerCmdReceiveNotify(CMD_HALL.USERRANKING, self)
	GameConnection:registerCmdReceiveNotify(CMD_HALL.MATCHINFO, self)
end
function MatchInfo:onReceiveCmdResponse(mainID, subID, data)
	print("MatchInfo==========", mainID, subID)
	if mainID == CMD_HALL.MATCHSIGNUP then
		self:onReceiveMatchSignUpResponse(data)
	elseif mainID == CMD_HALL.USER_MATCHINFO then
		self:onReceiveUserMatchInfoResponse(data)
	elseif mainID == CMD_HALL.QUERY_MATCHSERVERINFO then
		self:onReceiveMatchServerInfoListResponse(data)
	elseif mainID == CMD_HALL.USERRANKING then
		self:onReceiveUserRankingResponse(data)
	elseif mainID == CMD_HALL.MATCHINFO then
		self:onReceiveMatchInfoResponse(data)
	end
end
function MatchInfo:sendMatchSignUp(serverID)
	local request = protocol.loginServer.loginServer.match.c2s_pb.matchSignUp()
	request.ServerID = serverID
    local pData = request:SerializeToString()
    local pDataLen = string.len(pData)
    HallConnection:sendCommand(CMD_HALL.MATCHSIGNUP , 0, pData, pDataLen)
end
function MatchInfo:sendUserMatchInfo()
	local request = protocol.loginServer.loginServer.match.c2s_pb.userMatchInfo()
end
function MatchInfo:sendCancleSignUp(serverID)
	local request = protocol.loginServer.loginServer.match.c2s_pb.cancleSignUp()
	request.ServerID = serverID
    local pData = request:SerializeToString()
    local pDataLen = string.len(pData)
    HallConnection:sendCommand(CMD_HALL.CANCLESIGNUP , 0, pData, pDataLen)
end
function MatchInfo:sendQueryMatchServerInfo(serveridlist)
	local request = protocol.loginServer.loginServer.match.c2s_pb.queryMatchServerInfo()
	local serlist = request.ServerID
	for ind, id in ipairs(serveridlist) do
		table.insert(serlist, ind, id)
	end
	dump(request.ServerID, "request.ServerID")
    local pData = request:SerializeToString()
    local pDataLen = string.len(pData)
    HallConnection:sendCommand(CMD_HALL.QUERY_MATCHSERVERINFO , 0, pData, pDataLen)
end
function MatchInfo:onReceiveMatchSignUpResponse(data)
	local response = protocol.loginServer.loginServer.match.s2c_pb.matchSignUp()
	response:ParseFromString(data)
	self:setMatchSignUp(response)
	if response.code == 0 then
		Hall.showTips(response.msg, 2)
	else
		Hall.showTips(response.msg, 2)
	end
	dump(response, "matchSignUp")
end
function MatchInfo:onReceiveUserMatchInfoResponse(data)
	local response = protocol.loginServer.loginServer.match.s2c_pb.userMatchInfo()
	response:ParseFromString(data)
	self:setUserMatchInfo(response)
	print("serverID",response.serverID,"tableID",response.tableID,"chairID",response.chairID)
	-- Hall.showTips("收到桌子号椅子号", 2)
	dump(response, "userMatchInfo")
end
function MatchInfo:onReceiveMatchServerInfoListResponse(data)
	local response = protocol.loginServer.loginServer.match.s2c_pb.queryMatchServerInfo()
	response:ParseFromString(data)
	self:setMatchServerInfoList(copyProtoTable(response.list))
	dump(self.matchServerInfoList, "matchServerInfoList")
end
function MatchInfo:onReceiveUserRankingResponse(data)
	local response = protocol.gameServer.gameServer.match.s2c_pb.userRanking()
	response:ParseFromString(data)
	self:setUserRanking(response)
	dump(self.userRanking, "userRanking")
end
-- message userRanking {					//0x010600
-- 	required int32 ranking=1;
-- 	optional int32 userID=2;
-- }
function MatchInfo:onReceiveMatchInfoResponse(data)
	local response = protocol.gameServer.gameServer.match.s2c_pb.matchInfo()
	response:ParseFromString(data)
	self:setMatchInfo(response)
	dump(self.matchInfo, "matchInfo")
end
function MatchInfo:initData()
	BindTool.register(self, "matchSignUp", {})--0x000900
	BindTool.register(self, "userMatchInfo", {})--0x000901
	BindTool.register(self, "matchServerInfoList", {})--0x000902
	BindTool.register(self, "userRanking", {})--0x010600
	BindTool.register(self, "matchInfo", {})--0x010601
end
return MatchInfo