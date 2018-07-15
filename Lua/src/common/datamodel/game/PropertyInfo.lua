
require("network.GameConnection")
require("define.CMD_GAME")
require("protocol.gameServer.gameServer_property_c2s_pb")
require("protocol.gameServer.gameServer_property_s2c_pb")

local PropertyInfo = {};

function PropertyInfo:init()
	self:initData()
	GameConnection:registerCmdReceiveNotify(CMD_GAME.BUY_PROPERTY, self)
	GameConnection:registerCmdReceiveNotify(CMD_GAME.USE_PROPERTY, self)
	GameConnection:registerCmdReceiveNotify(CMD_GAME.SEND_TRUMPET, self)
	GameConnection:registerCmdReceiveNotify(CMD_GAME.PROPERTY_CONFIG, self)
	GameConnection:registerCmdReceiveNotify(CMD_GAME.PROPERTY_REPOSITORY, self)
	GameConnection:registerCmdReceiveNotify(CMD_GAME.TRUMPET_SCORE, self)
	GameConnection:registerCmdReceiveNotify(CMD_GAME.USE_PROPERTY_BRODCAST, self)
	GameConnection:registerCmdReceiveNotify(CMD_GAME.PROPERTY_REPOSITORY_UPDATE, self)
	GameConnection:registerCmdReceiveNotify(CMD_GAME.TRUMPET_MSG, self)
end

function PropertyInfo:onReceiveCmdResponse(mainID, subID, data)
	if mainID == CMD_GAME.BUY_PROPERTY then
		self:onReceiveBuyPropertyResponse(data)
	elseif mainID == CMD_GAME.USE_PROPERTY then 
		self:onReceiveUsePropertyResponse(data)
	elseif mainID == CMD_GAME.SEND_TRUMPET then 
		self:onReceiveSendTrumpetResponse(data)
	elseif mainID == CMD_GAME.PROPERTY_CONFIG then 
		self:onReceivePropertyConfigResponse(data)
	elseif mainID == CMD_GAME.PROPERTY_REPOSITORY then 
		self:onReceivePropertyRepositoryResponse(data)
	elseif mainID == CMD_GAME.TRUMPET_SCORE then 
		self:onReceiveTrumpetScoreResponse(data)
	elseif mainID == CMD_GAME.USE_PROPERTY_BRODCAST then 
		self:onReceiveUsePropertyBroadcastResponse(data)
	elseif mainID == CMD_GAME.PROPERTY_REPOSITORY_UPDATE then 
		self:onReceivePropertyRepositoryUpdateResponse(data)
	elseif mainID == CMD_GAME.TRUMPET_MSG then 
		self:onReceiveTrumpetMsgResponse(data)
	end
end

function PropertyInfo:sendBuyPropertyRequest(propertyID, propertyCount)
	local request = protocol.gameServer.gameServer.property.c2s_pb.BuyProperty()
	request.propertyID = propertyID
	request.propertyCount = propertyCount
	
    local pData = request:SerializeToString()
    local pDataLen = string.len(pData)
    GameConnection:sendCommand(CMD_GAME.BUY_PROPERTY , 0, pData, pDataLen)
end

function PropertyInfo:sendUsePropertyRequest(propertyID, propertyCount, targetUserID)
	local request = protocol.gameServer.gameServer.property.c2s_pb.UseProperty()
	request.propertyID = propertyID
	request.propertyCount = propertyCount
	request.targetUserID = targetUserID

    local pData = request:SerializeToString()
    local pDataLen = string.len(pData)
    GameConnection:sendCommand(CMD_GAME.USE_PROPERTY , 0, pData, pDataLen)
end

function PropertyInfo:sendSendTrumpetRequest(trumpetID, color, msg)
	local request = protocol.gameServer.gameServer.property.c2s_pb.SendTrumpet()
	request.trumpetID = trumpetID
	request.color = color
	request.msg = msg

    local pData = request:SerializeToString()
    local pDataLen = string.len(pData)
    GameConnection:sendCommand(CMD_GAME.SEND_TRUMPET , 0, pData, pDataLen)
end


function PropertyInfo:onReceiveUsePropertyResponse(data)
	local response = protocol.gameServer.gameServer.property.s2c_pb.UseProperty()
	response:ParseFromString(data)
	self:setUsePropertyResult(response)
	if response.code == 1 then
		local tem = {}
		tem.propertyID = response.propertyID
		tem.propertyCount = response.propertyCount
		tem.sourceUserID = response.sourceUserID
		tem.targetUserID = response.targetUserID

		self:setUsePropertyParam(tem)
		-- self:setUsePropertyResult(true)
	else
		
	end
end

function PropertyInfo:onReceiveBuyPropertyResponse(data)
	local response = protocol.gameServer.gameServer.property.s2c_pb.BuyProperty()
	response:ParseFromString(data)

	if response.code == 1 then
		self:updatePropertyRepository(response.propertyID, response.propertyCount)
		
	else
		
	end
	self:setBuyPropertyResult(response)
end

function PropertyInfo:onReceiveSendTrumpetResponse(data)
	local response = protocol.gameServer.gameServer.property.s2c_pb.SendTrumpet()
	response:ParseFromString(data)

	if response.code == 1 then
		self:setSendTrumpetResult(true)
	else
		
	end
end

function PropertyInfo:onReceivePropertyConfigResponse(data)
	local response = protocol.gameServer.gameServer.property.s2c_pb.PropertyConfig()
	response:ParseFromString(data)
	print("PropertyConfigInfo",PropertyConfigInfo)
	PropertyConfigInfo:parseAndSavePropertyConfigInfoNew(copyProtoTable(response.list))
	self:setConfigList(copyProtoTable(response.list))
end

function PropertyInfo:onReceivePropertyRepositoryResponse(data)
	local response = protocol.gameServer.gameServer.property.s2c_pb.PropertyRepository()
	response:ParseFromString(data)

	self:setRepositoryList(copyProtoTable(response.list))
end

function PropertyInfo:onReceiveTrumpetScoreResponse(data)
	local response = protocol.gameServer.gameServer.property.s2c_pb.TrumpetScore()
	response:ParseFromString(data)

	local tem = {}
	tem.smallTrumpetScore = response.smallTrumpetScore
	tem.bigTrumpetScore = response.bigTrumpetScore

	self:setTrumpetScore(tem)
end

function PropertyInfo:onReceiveUsePropertyBroadcastResponse(data)
	local response = protocol.gameServer.gameServer.property.s2c_pb.UsePropertyBroadcast()
	response:ParseFromString(data)

	local tem = {}
	tem.propertyID = response.propertyID
	tem.propertyCount = response.propertyCount
	tem.sourceUserID = response.sourceUserID
	tem.targetUserID = response.targetUserID

	self:setUsePropertyBroadcast(tem)
end

function PropertyInfo:onReceivePropertyRepositoryUpdateResponse(data)
	local response = protocol.gameServer.gameServer.property.s2c_pb.PropertyRepositoryUpdate()
	response:ParseFromString(data)

	self:updatePropertyRepository(response.propertyID, response.propertyCount)
end

function PropertyInfo:onReceiveTrumpetMsgResponse(data)
	local response = protocol.gameServer.gameServer.property.s2c_pb.TrumpetMsg()
	response:ParseFromString(data)

	local tem = {}
	tem.trumpetID = response.trumpetID
	tem.sendUserID = response.sendUserID
	tem.sendNickName = response.sendNickName
	tem.color = response.color
	tem.msg = response.msg

	self:setTrumpetMsg(tem)
end

function PropertyInfo:updatePropertyRepository(propertyID, propertyCount)
	if self.repositoryList then
		local flag = false
		for _, pro in ipairs(self.repositoryList) do
			if pro.propertyID == propertyID then
				flag = true
				pro.propertyCount = propertyCount
				break
			end
		end

		if flag == false then
			local pro = {}
			pro.propertyID = propertyID
			pro.propertyCount = propertyCount
			self.repositoryList[#self.repositoryList + 1] = pro
		end
	else
		self.repositoryList = {}
		local pro = {}
		pro.propertyID = propertyID
		pro.propertyCount = propertyCount
		self.repositoryList[1] = pro
	end
end

function PropertyInfo:initData()
	BindTool.register(self, "configList", {})
	BindTool.register(self, "repositoryList", {})
	BindTool.register(self, "buyPropertyResult", nil)
	BindTool.register(self, "trumpetScore", nil)
	BindTool.register(self, "usePropertyParam", nil)
	BindTool.register(self, "usePropertyResult", nil)
	BindTool.register(self, "usePropertyBroadcast", nil)
	BindTool.register(self, "sendTrumpetResult", false)
	BindTool.register(self, "trumpetMsg", nil)
end

return PropertyInfo