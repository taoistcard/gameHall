
require("network.GameConnection")
require("define.CMD_GAME")
require("protocol.gameServer.gameServer_misc_s2c_pb")
require("tools.BindTool")
local UserScoreInfo = {};

function UserScoreInfo:init()
	self:initData()
	GameConnection:registerCmdReceiveNotify(CMD_GAME.USER_SCORE_PUSH, self)
	GameConnection:registerCmdReceiveNotify(CMD_GAME.PAY_MENT_NOTIFY, self)
end

function UserScoreInfo:onReceiveCmdResponse(mainID, subID, data)
	if mainID == CMD_GAME.USER_SCORE_PUSH then
		self:onReceiveUserScoreResponse(data)
	elseif mainID == CMD_GAME.PAY_MENT_NOTIFY then 
		self:onReceivePaymentNotifyResponse(data)
	end
end


function UserScoreInfo:onReceiveUserScoreResponse(data)
	local response = protocol.gameServer.gameServer.misc.s2c_pb.UserScore()
	response:ParseFromString(data)
	DataManager:setUserScore(response)
	self:setUserScore(response)
end

function UserScoreInfo:onReceivePaymentNotifyResponse(data)
	local response = protocol.gameServer.gameServer.misc.s2c_pb.PaymentNotify()
	response:ParseFromString(data)
	self:setPaymentNotify(response)
end
function UserScoreInfo:initData()
	BindTool.register(self, "userScore", nil)
	BindTool.register(self, "paymentNotify", nil)

end

return UserScoreInfo