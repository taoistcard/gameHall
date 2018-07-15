
require("network.HallConnection")
require("define.CMD_HALL")
require("protocol.loginServer.loginServer_message_c2s_pb")
require("protocol.loginServer.loginServer_message_s2c_pb")

local MessageInfo = {};

function MessageInfo:init()
	self:initData()
	HallConnection:registerCmdReceiveNotify(CMD_HALL.SYSTEM_LOGON_MESSAGE, self)
	HallConnection:registerCmdReceiveNotify(CMD_HALL.USER_LOGON_MESSAGE, self)
	HallConnection:registerCmdReceiveNotify(CMD_HALL.QUERY_EXCHANGE_MESSAGE, self)
end

function MessageInfo:onReceiveCmdResponse(mainID, subID, data)
	if mainID == CMD_HALL.SYSTEM_LOGON_MESSAGE then
		self:onReceiveSystemMessageResponse(data)
	elseif mainID == CMD_HALL.USER_LOGON_MESSAGE then
		self:onReceiveUserMessageResponse(data)
	elseif mainID == CMD_HALL.QUERY_EXCHANGE_MESSAGE then
		self:onReceiveExchangeMessageResponse(data)
	end
end

function MessageInfo:sendExchangeMessageRequest()
	local request = protocol.loginServer.loginServer.message.c2s_pb.QueryExchangeMessage()

    local pData = request:SerializeToString()
    local pDataLen = string.len(pData)
    HallConnection:sendCommand(CMD_HALL.QUERY_EXCHANGE_MESSAGE , 0, pData, pDataLen)
end

function MessageInfo:onReceiveSystemMessageResponse(data)
	local response = protocol.loginServer.loginServer.message.s2c_pb.SystemLogonMessage()
	response:ParseFromString(data)
	self:setSystemLogonMsg(copyProtoTable(response.list))
end

function MessageInfo:onReceiveUserMessageResponse(data)
	local response = protocol.loginServer.loginServer.message.s2c_pb.UserLogonMessage()
	response:ParseFromString(data)

	self:setUserLogonMsg(copyProtoTable(response.list))
end

function MessageInfo:onReceiveExchangeMessageResponse(data)
	local response = protocol.loginServer.loginServer.message.s2c_pb.ExchangeMessage()
	response:ParseFromString(data)

	self:setExchangeMsg(copyProtoTable(response.msg))
end

function MessageInfo:initData()
	BindTool.register(self, "systemLogonMsg", nil)
	BindTool.register(self, "userLogonMsg", nil)
	BindTool.register(self, "exchangeMsg", nil)
end

return MessageInfo