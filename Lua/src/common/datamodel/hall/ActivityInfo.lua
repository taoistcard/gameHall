














-------------------------弃用了--------------------------
-- require("network.HallConnection")
-- require("define.CMD_HALL")
-- require("protocol.loginServer.loginServer_activity_c2s_pb")
-- require("protocol.loginServer.loginServer_activity_s2c_pb")

-- local ActivityInfo = {};

-- function ActivityInfo:init()
-- 	HallConnection:registerCmdReceiveNotify(CMD_HALL.SCORE_ACTIVITY, self)
-- 	HallConnection:registerCmdReceiveNotify(CMD_HALL.ALMS_ACTIVITY, self)
-- end

-- function ActivityInfo:onReceiveCmdResponse(mainID, subID, data)
-- 	if mainID == CMD_HALL.SCORE_ACTIVITY then
-- 		self:onReceiveScoreActivityResponse(data)
-- 	elseif mainID == CMD_HALL.ALMS_ACTIVITY then
-- 		self:onReceiveAlmsActivityResponse(data)
-- 	end
-- end

-- function ActivityInfo:sendScoreActivityRequest()
-- 	local request = protocol.loginServer.loginServer.activity.c2s_pb.QueryScoreActivity()

--     local pData = request:SerializeToString()
--     local pDataLen = string.len(pData)
--     HallConnection:sendCommand(CMD_HALL.SCORE_ACTIVITY , 0, pData, pDataLen)
-- end

-- function ActivityInfo:sendAlmsActivityRequest()
-- 	local request = protocol.loginServer.loginServer.activity.c2s_pb.Alms()

--     local pData = request:SerializeToString()
--     local pDataLen = string.len(pData)
--     HallConnection:sendCommand(CMD_HALL.ALMS_ACTIVITY , 0, pData, pDataLen)
-- end

-- function ActivityInfo:onReceiveScoreActivityResponse(data)
-- 	local response = protocol.loginServer.loginServer.activity.s2c_pb.QueryScoreActivity()
-- 	response:ParseFromString(data)


-- end

-- function ActivityInfo:onReceiveAlmsActivityResponse(data)
-- 	local response = protocol.loginServer.loginServer.activity.s2c_pb.Alms()
-- 	response:ParseFromString(data)

-- 	if response.code == 1 then
    	
--     else
    	
--     end
-- end

-- return ActivityInfo