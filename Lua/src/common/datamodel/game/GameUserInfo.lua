require("network.GameConnection")
require("define.CMD_GAME")
require("protocol.gameServer.gameServer_misc_s2c_pb")

local GameUserInfo = {};

function GameUserInfo:init()
	self:initData()
	GameConnection:registerCmdReceiveNotify(CMD_GAME.USER_SCORE_PUSH, self)
	GameConnection:registerCmdReceiveNotify(CMD_GAME.PAY_MENT_NOTIFY, self)
end

function GameUserInfo:onReceiveCmdResponse(mainID, subID, data)
	if mainID == CMD_GAME.USER_SCORE_PUSH then
		self:onReceiveUserScoreResponse(data)
	elseif mainID == CMD_GAME.PAY_MENT_NOTIFY then 
		self:onReceivePaymentNotifyResponse(data)
	end
end

function GameUserInfo:onReceiveUserScoreResponse(data)
	local response = protocol.gameServer.gameServer.misc.s2c_pb.UserScore()
	response:ParseFromString(data)
	DataManager:setUserScore(response)
	self:setUserScore(response)
	if response.userID == AccountInfo:getUserId() then
		AccountInfo:setScore(response.score)
		AccountInfo:setInsure(response.insure)
		AccountInfo:setGrade(response.grade)
		AccountInfo:setMedal(response.medal)
		AccountInfo:setGift(response.gift)
		AccountInfo:setPresent(response.present)
		AccountInfo:setExperience(response.experience)
		AccountInfo:setLoveLiness(response.loveliness)
		AccountInfo:setWinCount(response.winCount)
		AccountInfo:setLostCount(response.lostCount)
		AccountInfo:setDrawCount(response.drawCount)
		AccountInfo:setFleeCount(response.fleeCount)
	end
end

function GameUserInfo:onReceivePaymentNotifyResponse(data)
	local response = protocol.gameServer.gameServer.misc.s2c_pb.PaymentNotify()
	response:ParseFromString(data)
	self:setPaymentNotify(response)
	local notifyObj = {}
	notifyObj.orderID = response.orderID
	notifyObj.currencyType = response.currencyType
	notifyObj.currencyAmount = response.currencyAmount
	notifyObj.payID = response.payID
	notifyObj.score = response.score
	notifyObj.memberOrder = response.memberOrder
	notifyObj.userRight = response.userRight

	self:setPaymentNofity(notifyObj)

	AccountInfo:setMemberOrder(notifyObj.memberOrder)
	AccountInfo:setScore(notifyObj.score)
	AccountInfo:setUserRight(notifyObj.userRight)
end

function GameUserInfo:initData()
	BindTool.register(self, "userScore", nil)
	BindTool.register(self, "paymentNofity", nil)
end

return GameUserInfo