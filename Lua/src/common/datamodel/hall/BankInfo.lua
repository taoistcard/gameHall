require("network.HallConnection")
require("define.CMD_HALL")
require("protocol.loginServer.loginServer_bank_c2s_pb")
require("protocol.loginServer.loginServer_bank_s2c_pb")

local BankInfo = {};

function BankInfo:init()
	HallConnection:registerCmdReceiveNotify(CMD_HALL.DEPOSIT_BANK, self)
	HallConnection:registerCmdReceiveNotify(CMD_HALL.WITHDRAW_BANK, self)
	HallConnection:registerCmdReceiveNotify(CMD_HALL.QUERY_BANK, self)
end

function BankInfo:onReceiveCmdResponse(mainID, subID, data)
	if mainID == CMD_HALL.DEPOSIT_BANK then
		self:onReceiveDepositResponse(data)
	elseif mainID == CMD_HALL.WITHDRAW_BANK then
		self:onReceiveWithDrawResponse(data)
	elseif mainID == CMD_HALL.QUERY_BANK then
		self:onReceiveQueryResponse(data)
	end
end

function BankInfo:sendDepositRequest(amount)
	local request = protocol.loginServer.loginServer.bank.c2s_pb.Deposit()
	request.amount = amount
    local pData = request:SerializeToString()
    local pDataLen = string.len(pData)
    HallConnection:sendCommand(CMD_HALL.DEPOSIT_BANK , 0, pData, pDataLen)
end

function BankInfo:sendWithdrawRequest(amount)
	local request = protocol.loginServer.loginServer.bank.c2s_pb.Withdraw()
	request.amount = amount
    local pData = request:SerializeToString()
    local pDataLen = string.len(pData)
    HallConnection:sendCommand(CMD_HALL.WITHDRAW_BANK , 0, pData, pDataLen)
end

function BankInfo:sendQueryRequest()
	local request = protocol.loginServer.loginServer.bank.c2s_pb.Query()
    HallConnection:sendCommand(CMD_HALL.QUERY_BANK , 0, nil, nil)
end


function BankInfo:onReceiveDepositResponse(data)
	local response = protocol.loginServer.loginServer.bank.s2c_pb.Deposit()
	response:ParseFromString(data)

	if response.code == 1 then
    	AccountInfo:setScore(response.score)
		AccountInfo:setInsure(response.insure)
		AccountInfo:setUserInfoChange(true)
    else
    	Hall.showTips(response.msg)
    end
end

function BankInfo:onReceiveWithDrawResponse(data)
	local response = protocol.loginServer.loginServer.bank.s2c_pb.Withdraw()
	response:ParseFromString(data)

	if response.code == 1 then
    	AccountInfo:setScore(response.score)
		AccountInfo:setInsure(response.insure)
		AccountInfo:setUserInfoChange(true)
    else
    	Hall.showTips(response.msg)
    end
end

function BankInfo:onReceiveQueryResponse(data)
	local response = protocol.loginServer.loginServer.bank.s2c_pb.Query()
	response:ParseFromString(data)

	if response.code == 1 then
		AccountInfo:setScore(response.score)
		AccountInfo:setInsure(response.insure)
		AccountInfo:setUserInfoChange(true)
	else
		Hall.showTips(response.msg)
	end
end

return BankInfo