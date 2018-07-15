require("network.GameConnection")
require("define.CMD_FISH")
require("protocol.fish.fish_c2s_pb")
require("protocol.fish.fish_s2c_pb")

local FishInfo = {};

function FishInfo:init()
	self:initData()
	GameConnection:registerCmdReceiveNotify(CMD_FISH.USER_FIRE, self)
	GameConnection:registerCmdReceiveNotify(CMD_FISH.BIG_NET_CATCH_FISH, self)
	GameConnection:registerCmdReceiveNotify(CMD_FISH.CATCH_SWEEP_FISH, self)

	GameConnection:registerCmdReceiveNotify(CMD_FISH.SCENE_END, self)
	GameConnection:registerCmdReceiveNotify(CMD_FISH.SWITCH_SCENE, self)
	GameConnection:registerCmdReceiveNotify(CMD_FISH.MERMAID_CLOTHES, self)
	GameConnection:registerCmdReceiveNotify(CMD_FISH.GAME_CONFIG, self)

	GameConnection:registerCmdReceiveNotify(CMD_FISH.GAME_SCENE, self)
	GameConnection:registerCmdReceiveNotify(CMD_FISH.EXCHANGE_FISH_SCORE, self)
	GameConnection:registerCmdReceiveNotify(CMD_FISH.CATCH_SWEEP_FISH_NOTIFY, self)
	GameConnection:registerCmdReceiveNotify(CMD_FISH.TREASURE_BOX, self)
	GameConnection:registerCmdReceiveNotify(CMD_FISH.CATCH_FISH, self)
	GameConnection:registerCmdReceiveNotify(CMD_FISH.LOCK_TIME_OUT, self)
	GameConnection:registerCmdReceiveNotify(CMD_FISH.BULLET_COMPENSATE, self)
	GameConnection:registerCmdReceiveNotify(CMD_FISH.FISH_SPAWN, self)
end

function FishInfo:onReceiveCmdResponse(mainID, subID, data)
	if mainID == CMD_FISH.USER_FIRE then
		self:onReceiveUserFireResponse(data)
	elseif mainID == CMD_FISH.CATCH_SWEEP_FISH then
		self:onReceiveCatchSweepFishResponse(data)
	elseif mainID == CMD_FISH.SCENE_END then
		self:onReceiveSceneEndResponse(data)							
	elseif mainID == CMD_FISH.SWITCH_SCENE then
		self:onReceiveSwitchSceneResponse(data)							
	elseif mainID == CMD_FISH.MERMAID_CLOTHES then
		self:onReceiveMermaidResponse(data)									
	elseif mainID == CMD_FISH.GAME_CONFIG then
		self:onReceiveGameConfigResponse(data)									
	elseif mainID == CMD_FISH.GAME_SCENE then
		self:onReceiveGameSceneResponse(data)								
	elseif mainID == CMD_FISH.EXCHANGE_FISH_SCORE then
		self:onReceiveExchangeFishScoreResponse(data)								
	elseif mainID == CMD_FISH.CATCH_SWEEP_FISH_NOTIFY then
		self:onReceiveCatchSweepFishNofityResponse(data)							
	elseif mainID == CMD_FISH.TREASURE_BOX then
		self:onReceiveTreasureBoxResponse(data)								
	elseif mainID == CMD_FISH.CATCH_FISH then
		self:onReceiveCatchFishResponse(data)					
	elseif mainID == CMD_FISH.LOCK_TIME_OUT then
		self:onReceiveLockTimeoutResponse(data)								
	elseif mainID == CMD_FISH.BULLET_COMPENSATE then
		self:onReceiveBulletCompensateResponse(data)
	elseif mainID == CMD_FISH.FISH_SPAWN then
		self:onReceiveFishSpawnResponse(data)
	end
end

function FishInfo:sendUserFireRequest(bulletKind, bulletID, angle, bulletMultiple, lockFishID)
	local request = protocol.fish.fish.c2s_pb.UserFire()
	request.bulletKind = bulletKind
	request.bulletID = bulletID
	request.angle = angle
	request.bulletMultiple = bulletMultiple
	request.lockFishID = lockFishID

    local pData = request:SerializeToString()
    local pDataLen = string.len(pData)
    GameConnection:sendCommand(CMD_FISH.USER_FIRE , 0, pData, pDataLen)
end

function FishInfo:sendBigNetCatchFishRequest(bulletID, catchFishIDList)
	local request = protocol.fish.fish.c2s_pb.BigNetCatchFish()
	request.bulletID = bulletID

	for k, id in ipairs(catchFishIDList) do
		table.insert(request.catchFishIDList, id)
	end

    local pData = request:SerializeToString()
    local pDataLen = string.len(pData)
    GameConnection:sendCommand(CMD_FISH.BIG_NET_CATCH_FISH , 0, pData, pDataLen)
end

function FishInfo:sendCatchSweepFishRequest(chairID, sweepID, fishIDList)
	local request = protocol.fish.fish.c2s_pb.CatchSweepFish()
	request.chairID = chairID
	request.sweepID = sweepID
	for k, id in ipairs(fishIDList) do
		table.insert(request.fishIDList, id)
	end

    local pData = request:SerializeToString()
    local pDataLen = string.len(pData)
    GameConnection:sendCommand(CMD_FISH.CATCH_SWEEP_FISH , 0, pData, pDataLen)
end

function FishInfo:onReceiveFishSpawnResponse(data)
	local response = protocol.fish.fish.s2c_pb.FishSpawn()
	response:ParseFromString(data)
	self:setFishSpawnList(copyProtoTable(response.list))
end

function FishInfo:onReceiveBulletCompensateResponse(data)
	local response = protocol.fish.fish.s2c_pb.BulletCompensate()
	response:ParseFromString(data)

	local tem = {}
	tem.chairID = response.chairID
	tem.compensateScore = response.compensateScore

	self:setBulletCompensate(tem)

end

function FishInfo:onReceiveLockTimeoutResponse(data)
	local response = protocol.fish.fish.s2c_pb.LockTimeout()
	response:ParseFromString(data)
	self:setLockTimeOut(true)
end

function FishInfo:onReceiveCatchFishResponse(data)
	local response = protocol.fish.fish.s2c_pb.CatchFish()
	response:ParseFromString(data)

	local tem = {}
	tem.fishID = response.fishID
	tem.chairID = response.chairID
	tem.fishKind = response.fishKind
	tem.fishScore = response.fishScore
	tem.fishMulti = response.fishMulti

	self:setCatchFish(tem)
end

function FishInfo:onReceiveTreasureBoxResponse(data)
	local response = protocol.fish.fish.s2c_pb.TreasureBox()
	response:ParseFromString(data)

	local tem = {}
	tem.fishID = response.fishID
	tem.chairID = response.chairID
	tem.present = response.present
	tem.score = response.score

	self:setTreasureBox(tem)
end

function FishInfo:onReceiveCatchSweepFishNofityResponse(data)
	local response = protocol.fish.fish.s2c_pb.CatchSweepFish()
	response:ParseFromString(data)

	local tem = {}
	tem.chairID = response.chairID
	tem.fishID = response.fishID

	self:setCatchSweepFish(tem)
end

function FishInfo:onReceiveExchangeFishScoreResponse(data)
	local response = protocol.fish.fish.s2c_pb.ExchangeFishScore()
	response:ParseFromString(data)

	local tem = {}
	tem.chairID = response.chairID
	tem.fishScore = response.fishScore

	self:setExchangeFishScore(tem)
end

function FishInfo:onReceiveGameSceneResponse(data)
	local response = protocol.fish.fish.s2c_pb.GameScene()
	response:ParseFromString(data)

	local tem = {}
	tem.isSpecialScene = response.isSpecialScene
	tem.specialSceneLeftTime = response.specialSceneLeftTime
	tem.scoreList = copyProtoTable(response.scoreList)

	self:setGameScene(tem)
end

function FishInfo:onReceiveGameConfigResponse(data)
	local response = protocol.fish.fish.s2c_pb.GameConfig()
	response:ParseFromString(data)
	local tem = {}
	tem.bulletMultipleMin = response.bulletMultipleMin
	tem.bulletMultipleMax = response.bulletMultipleMax
	tem.bombRangeWidth = response.bombRangeWidth
	tem.bombRangeHeight = response.bombRangeHeight
	tem.fishList = response.fishList
	tem.bulletList = response.bulletList

	self:setGameConfig(tem)
end

function FishInfo:onReceiveMermaidResponse(data)
	local response = protocol.fish.fish.s2c_pb.Mermaid()
	response:ParseFromString(data)
	self:setMermaid(response.clothesID)
end

function FishInfo:onReceiveSwitchSceneResponse(data)
	local response = protocol.fish.fish.s2c_pb.SwitchScene()
	response:ParseFromString(data)
	local tem = {}
	tem.sceneKind = response.sceneKind
	tem.fishList = response.fishList
	self:setSwitchScene(tem)
end

function FishInfo:onReceiveSceneEndResponse(data)
	local response = protocol.fish.fish.s2c_pb.SceneEnd()
	response:ParseFromString(data)
	self:setSceneEnd(true)

end

function FishInfo:onReceiveUserFireResponse(data)
	local response = protocol.fish.fish.s2c_pb.UserFire()
	response:ParseFromString(data)
	local tem = {}
	tem.bulletKind = response.bulletKind
	tem.bulletID = response.bulletID
	tem.chairID = response.chairID
	tem.angle = response.angle
	tem.bulletMultiple = response.bulletMultiple
	tem.lockFishID = response.lockFishID
	self:setUserFireInfo(tem)
end

function FishInfo:onReceiveCatchSweepFishResponse(data)
	local response = protocol.fish.fish.s2c_pb.CatchSweepFishResult()
	response:ParseFromString(data)
	local tem = {}
	tem.chairID = response.chairID
	tem.sweepID = response.sweepID
	tem.fishScore = response.fishScore
	tem.fishMulti = response.fishMulti
	tem.fishIDList = response.fishIDList
	self:setCatchSweepFishResult(tem)
end

function FishInfo:initData()
	BindTool.register(self, "userFireInfo", nil)
	BindTool.register(self, "catchSweepFishResult", nil)
	BindTool.register(self, "sceneEnd", false)
	BindTool.register(self, "switchScene", nil)
	BindTool.register(self, "mermaid", -1)
	BindTool.register(self, "gameConfig", nil)
	BindTool.register(self, "gameScene", nil)
	BindTool.register(self, "exchangeFishScore", nil)
	BindTool.register(self, "catchSweepFish", nil)
	BindTool.register(self, "treasureBox", nil)
	BindTool.register(self, "catchFish", nil)
	BindTool.register(self, "lockTimeOut", false)
	BindTool.register(self, "bulletCompensate", nil)
	BindTool.register(self, "fishSpawnList", nil)
end

return FishInfo