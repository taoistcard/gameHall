
require("network.HallConnection")
require("define.CMD_HALL")
require("protocol.loginServer.loginServer_ranking_c2s_pb")
require("protocol.loginServer.loginServer_ranking_s2c_pb")

local RankingInfo = {};

function RankingInfo:init()
	self:initData()
	HallConnection:registerCmdReceiveNotify(CMD_HALL.QUERY_WEALTH_RANKING, self)
	HallConnection:registerCmdReceiveNotify(CMD_HALL.QUERY_LOVELINESS_RANKING, self)
end

function RankingInfo:onReceiveCmdResponse(mainID, subID, data)
	if mainID == CMD_HALL.QUERY_WEALTH_RANKING then
		self:onReceiveWealthRankingResponse(data)

	elseif mainID == CMD_HALL.QUERY_LOVELINESS_RANKING then
		self:onReceiveLoveLinessRankingRespons(data)
	end
end

function RankingInfo:sendScoreActivityRequest()
	local request = protocol.loginServer.loginServer.ranking.c2s_pb.QueryWealthRanking()

    local pData = request:SerializeToString()
    local pDataLen = string.len(pData)
    HallConnection:sendCommand(CMD_HALL.QUERY_WEALTH_RANKING , 0, pData, pDataLen)
end

function RankingInfo:sendQueryLoveLinesActivityRequest()
	local request = protocol.loginServer.loginServer.ranking.c2s_pb.QueryLoveLinesRanking()

    local pData = request:SerializeToString()
    local pDataLen = string.len(pData)
    HallConnection:sendCommand(CMD_HALL.QUERY_LOVELINESS_RANKING , 0, pData, pDataLen)
end

function RankingInfo:onReceiveWealthRankingResponse(data)
	local response = protocol.loginServer.loginServer.ranking.s2c_pb.WealthRanking()
	response:ParseFromString(data)

	self:setWealthRankList(copyProtoTable(response.list))
end

function RankingInfo:onReceiveLoveLinessRankingRespons(data)
	local response = protocol.loginServer.loginServer.ranking.s2c_pb.LoveLinesRanking()
	response:ParseFromString(data)

	self:setLoveLinessList(copyProtoTable(response.list))
end

function RankingInfo:initData()
	BindTool.register(self, "wealthRankList", {})
	BindTool.register(self, "loveLinessList", {})
end

return RankingInfo