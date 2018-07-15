require("network.GameConnection")
require("define.CMD_GAME")
require("protocol.gameServer.gameServer_jinhuaLottery_c2s_pb")
require("protocol.gameServer.gameServer_jinhuaLottery_s2c_pb")

local jinhuaLottery = {};

function jinhuaLottery:init()
	self:initData()
	GameConnection:registerCmdReceiveNotify(CMD_GAME.ADD_LOTTERY_SCORE, self)
	GameConnection:registerCmdReceiveNotify(CMD_GAME.LOTTERY_AWARD, self)
	GameConnection:registerCmdReceiveNotify(CMD_GAME.LOTTERY_SINK_INFO, self)
end

function jinhuaLottery:sendAddLotteryScoreRequest()
	local request = protocol.gameServer.gameServer.jinhuaLottery.c2s_pb.AddLotteryScore()
    GameConnection:sendCommand(CMD_GAME.ADD_LOTTERY_SCORE , 0, nil, nil)
end

function jinhuaLottery:sendLotteryAwardRequest()
	local request = protocol.gameServer.gameServer.jinhuaLottery.c2s_pb.LotteryAward()
    GameConnection:sendCommand(CMD_GAME.LOTTERY_AWARD , 0, nil, nil)
end

function jinhuaLottery:onReceiveCmdResponse(mainID, subID, data)
	if mainID == CMD_GAME.ADD_LOTTERY_SCORE then
		self:onReceiveAddLotteryScoreResponse(data)
	elseif mainID == CMD_GAME.LOTTERY_AWARD then
		self:onReceiveLotteryAwardResponse(data)
	elseif mainID == CMD_GAME.LOTTERY_SINK_INFO then
		self:onReceiveLotterySinkInfoResponse(data)
	end
end

function jinhuaLottery:onReceiveAddLotteryScoreResponse(data)
	
	local response = protocol.gameServer.gameServer.jinhuaLottery.s2c_pb.AddLotteryScore()
	response:ParseFromString(data)

	if response.code == 0 then
    	self:setAwardType(response.cardType)
    	self:setAwardValue(response.score)
		self:setCbCardValue(response.cbCardValue)
		-- print("测试中奖金额:",response.score)
    else
    	Hall.showTips("抱歉，金币不足！")
    end
end

function jinhuaLottery:onReceiveLotteryAwardResponse(data)
	local response = protocol.gameServer.gameServer.jinhuaLottery.s2c_pb.LotteryAward()
	response:ParseFromString(data)

	self:setRecord(response.record)
	-- message LotteryAwardInfo
	-- {
	-- 	required int32 awardType = 1;//获奖类型
	-- 	repeated int32 cbCardValue = 2;//牌信息
	-- 	required int64 score = 3;//中奖金币
	-- 	required string nickName = 4;//昵称
	-- }
	for i,v in ipairs(self.record) do
		-- print(i,v.awardType,v.cbCardValue,v.score,v.nickName)
	end
end

function jinhuaLottery:onReceiveLotterySinkInfoResponse(data)
	local response = protocol.gameServer.gameServer.jinhuaLottery.s2c_pb.LotterySinkInfo()
	response:ParseFromString(data)

	self:setPoolScore(response.score)
	-- print("测试奖池:",self.poolScore)
end

function jinhuaLottery:initData()
	BindTool.register(self, "cbCardValue", {})--牌信息
	BindTool.register(self, "awardType", 0)--中奖类型
	BindTool.register(self, "awardValue", 0)--中奖金额
	BindTool.register(self, "record", {})--中奖纪录
	BindTool.register(self, "poolScore", 0)--奖池金额
end

return jinhuaLottery