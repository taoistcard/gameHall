require("network.GameConnection")
require("define.CMD_GAME")
require("protocol.gameServer.gameServer_bank_c2s_pb")
require("protocol.gameServer.gameServer_bank_s2c_pb")
local BankInfoInGame = {};

function BankInfoInGame:init()
	GameConnection:registerCmdReceiveNotify(CMD_GAME.WITHDRAW_BANK, self)
	GameConnection:registerCmdReceiveNotify(CMD_GAME.QUERY_BANK, self)
end

function BankInfoInGame:onReceiveCmdResponse(mainID, subID, data)
	if mainID == CMD_GAME.WITHDRAW_BANK then
		self:onReceiveWithDrawResponse(data)
	elseif mainID == CMD_GAME.QUERY_BANK then
		self:onReceiveQueryResponse(data)
	end
end



function BankInfoInGame:sendWithdrawRequest(amount)
	local request = protocol.gameServer.gameServer.bank.c2s_pb.Withdraw()
	request.amount = amount
    local pData = request:SerializeToString()
    local pDataLen = string.len(pData)
    GameConnection:sendCommand(CMD_GAME.WITHDRAW_BANK , 0, pData, pDataLen)
end

function BankInfoInGame:sendQueryRequest()
	local request = protocol.gameServer.gameServer.bank.c2s_pb.Query()
    GameConnection:sendCommand(CMD_GAME.QUERY_BANK , 0, nil, nil)
end




function BankInfoInGame:onReceiveWithDrawResponse(data)
	local response = protocol.gameServer.gameServer.bank.s2c_pb.Withdraw()
	response:ParseFromString(data)

	if response.code == 1 then
    	AccountInfo:setScore(response.score)
		AccountInfo:setInsure(response.insure)
		AccountInfo:setUserInfoChange(true)
    else
    	Hall.showTips(response.msg)
    end
end

function BankInfoInGame:onReceiveQueryResponse(data)
	local response = protocol.gameServer.gameServer.bank.s2c_pb.Query()
	response:ParseFromString(data)

	if response.code == 1 then
		AccountInfo:setScore(response.score)
		AccountInfo:setInsure(response.insure)
		AccountInfo:setUserInfoChange(true)
	else
		Hall.showTips(response.msg)
	end
end

return BankInfoInGame