
require("network.HallConnection")
require("define.CMD_HALL")
require("protocol.loginServer.loginServer_pay_c2s_pb")
require("protocol.loginServer.loginServer_pay_s2c_pb")

local PayInfo = {};

function PayInfo:init()
	self:initData()

	HallConnection:registerCmdReceiveNotify(CMD_HALL.QUERY_PAY_ORDER_ITEMS, self)
	HallConnection:registerCmdReceiveNotify(CMD_HALL.QUERY_FREE_SCORE, self)
	HallConnection:registerCmdReceiveNotify(CMD_HALL.GET_FREE_SCORE, self)
	HallConnection:registerCmdReceiveNotify(CMD_HALL.QUERY_VIP_FREE_SCORE, self)
	HallConnection:registerCmdReceiveNotify(CMD_HALL.GET_VIP_FREE_SCORE, self)
	HallConnection:registerCmdReceiveNotify(CMD_HALL.GET_GIFT_SCORE, self)
	HallConnection:registerCmdReceiveNotify(CMD_HALL.QUERY_VIP_INFO, self)

	HallConnection:registerCmdReceiveNotify(CMD_HALL.PAYMENT_NOTIFY, self)
	HallConnection:registerCmdReceiveNotify(CMD_HALL.BACK_QUERY_FREE_SCORE, self)
	HallConnection:registerCmdReceiveNotify(CMD_HALL.BACK_GET_FREE_SCORE, self)
	HallConnection:registerCmdReceiveNotify(CMD_HALL.BACK_QUERY_VIP_FREE_SCORE, self)
	HallConnection:registerCmdReceiveNotify(CMD_HALL.BACK_GET_VIP_FREE_SCORE, self)
	HallConnection:registerCmdReceiveNotify(CMD_HALL.BACK_GET_GIFT_SCORE, self)
	HallConnection:registerCmdReceiveNotify(CMD_HALL.BACK_QUERY_VIP_INFO, self)
	HallConnection:registerCmdReceiveNotify(CMD_HALL.REFRESH_GIFT, self)
	HallConnection:registerCmdReceiveNotify(CMD_HALL.REFRESH_LOVELINES, self)

	self.chargeAvailableTimes = {}
end

function PayInfo:onReceiveCmdResponse(mainID, subID, data)
	if mainID == CMD_HALL.QUERY_PAY_ORDER_ITEMS then
		self:onReceivePayOrderItemsResponse(data)
	elseif mainID == CMD_HALL.PAYMENT_NOTIFY then
		self:onReceivePaymentNotifyResponse(data)
	elseif mainID == CMD_HALL.BACK_QUERY_FREE_SCORE then
		self:onReceiveQueryFreeScoreResponse(data)
	elseif mainID == CMD_HALL.BACK_GET_FREE_SCORE then
		self:onReceiveGetFreeScoreResponse(data)
	elseif mainID == CMD_HALL.BACK_QUERY_VIP_FREE_SCORE then
		self:onReceiveQueryVipFreeScoreResponse(data)
	elseif mainID == CMD_HALL.BACK_GET_VIP_FREE_SCORE then
		self:onReceiveGetVipFreeScoreResponse(data)
	elseif mainID == CMD_HALL.BACK_GET_GIFT_SCORE then
		self:onReceiveGetGiftScoreResponse(data)
	elseif mainID == CMD_HALL.BACK_QUERY_VIP_INFO then
		self:onReceiveQueryVipInfoResponse(data)
	elseif mainID == CMD_HALL.REFRESH_GIFT then
		self:onReceiveRefreshGiftResponse(data)
	elseif mainID == CMD_HALL.REFRESH_LOVELINES then
		self:onReceiveRefreshLoveLinesResponse(data)
	end
end

function PayInfo:sendPayOrderItemsRequest()
	local request = protocol.loginServer.loginServer.pay.c2s_pb.QueryPayOrderItem()

    local pData = request:SerializeToString()
    local pDataLen = string.len(pData)
    HallConnection:sendCommand(CMD_HALL.QUERY_PAY_ORDER_ITEMS , 0, pData, pDataLen)
end

function PayInfo:sendQueryFreeScoreRequest()
	local request = protocol.loginServer.loginServer.pay.c2s_pb.QueryFreeScore()

    local pData = request:SerializeToString()
    local pDataLen = string.len(pData)
    HallConnection:sendCommand(CMD_HALL.QUERY_FREE_SCORE , 0, pData, pDataLen)
end

function PayInfo:sendGetFreeScoreRequest()
	local request = protocol.loginServer.loginServer.pay.c2s_pb.GetFreeScore()

    local pData = request:SerializeToString()
    local pDataLen = string.len(pData)
    HallConnection:sendCommand(CMD_HALL.GET_FREE_SCORE , 0, pData, pDataLen)
end

function PayInfo:sendQueryVipFreeScoreRequest()
	local request = protocol.loginServer.loginServer.pay.c2s_pb.QueryVipFreeScore()

    local pData = request:SerializeToString()
    local pDataLen = string.len(pData)
    HallConnection:sendCommand(CMD_HALL.QUERY_VIP_FREE_SCORE , 0, pData, pDataLen)
end

function PayInfo:sendGetVipFreeScoreRequest(memberType)
	local request = protocol.loginServer.loginServer.pay.c2s_pb.GetVipFreeScore()
	request.memberType = memberType
    local pData = request:SerializeToString()
    local pDataLen = string.len(pData)
    HallConnection:sendCommand(CMD_HALL.GET_VIP_FREE_SCORE , 0, pData, pDataLen)
end

function PayInfo:sendGetGiftScoreRequest(gift)
	local request = protocol.loginServer.loginServer.pay.c2s_pb.GetGiftScore()
	request.gift = gift
    local pData = request:SerializeToString()
    local pDataLen = string.len(pData)
    HallConnection:sendCommand(CMD_HALL.GET_GIFT_SCORE , 0, pData, pDataLen)
end

function PayInfo:sendQueryVipInfoRequest()
	local request = protocol.loginServer.loginServer.pay.c2s_pb.QueryVipInfo()

    local pData = request:SerializeToString()
    local pDataLen = string.len(pData)
    HallConnection:sendCommand(CMD_HALL.QUERY_VIP_INFO , 0, pData, pDataLen)
end

-- message PayOrderItem
-- {
-- 	required uint32 id=1;
-- 	required float price=2;
-- 	required uint32 gold=3;
-- 	required uint32 goldExtra=4;
-- 	required uint32 limitTimes=5;
-- 	required uint32 limitDays=6;
-- 	required bool isRecommend=7;
-- 	required bool isPepeatable=8;
-- 	required int32 startSecond=9;
-- 	required int32 endSecond=10;
-- 	required uint32 memberOrder=11;
-- 	required uint32 memberOrderDays=12;
-- 	required string name=13;
-- 	required uint32 availableTimes=14;
-- }

function PayInfo:onReceivePayOrderItemsResponse(data)
	local response = protocol.loginServer.loginServer.pay.s2c_pb.QueryPayOrderItem()
	response:ParseFromString(data)

	self.orderItemList = copyProtoTable(response.list)

	for i,v in ipairs(self.orderItemList) do
		-- print(i,v.id,v.availableTimes,v.name)
		self.chargeAvailableTimes[v.id] = v.availableTimes
	end

	self:setOrderItemList(copyProtoTable(response.list))

	-- dump(self.chargeAvailableTimes, "self.chargeAvailableTimes")

end

function PayInfo:onReceivePaymentNotifyResponse(data)
	local response = protocol.loginServer.loginServer.pay.s2c_pb.PaymentNotify()
	response:ParseFromString(data)

	local notifyObj = {}
	notifyObj.orderID = response.orderID
	notifyObj.currencyType = response.currencyType
	notifyObj.currencyAmount = response.currencyAmount
	notifyObj.payID = response.payID
	notifyObj.score = response.score
	notifyObj.memberOrder = response.memberOrder
	notifyObj.userRight = response.userRight
	notifyObj.currentScore = response.currentScore
	notifyObj.currentInsure = response.currentInsure

	self:setPaymentNofity(notifyObj)

	AccountInfo:setMemberOrder(notifyObj.memberOrder)
	AccountInfo:setScore(notifyObj.currentScore)
	AccountInfo:setInsure(notifyObj.currentInsure)
	AccountInfo:setUserRight(notifyObj.userRight)

	--只能充值一次
	if notifyObj.payID == 437 or notifyObj.payID == 438 or notifyObj.payID == 444 then
		self.chargeAvailableTimes[notifyObj.payID] = 0
	end
end

function PayInfo:onReceiveQueryFreeScoreResponse(data)
	local response = protocol.loginServer.loginServer.pay.s2c_pb.BackQueryFreeScore()
	response:ParseFromString(data)

	local free = {}
	free.limitScore = response.limitScore
	free.freeScore = response.freeScore
	free.freeTime = copyProtoTable(response.freeTime)
	free.recvNum = response.recvNum
	free.nowTime = response.nowTime

	self:setFreeScore(free)
end

function PayInfo:onReceiveGetFreeScoreResponse(data)
	local response = protocol.loginServer.loginServer.pay.s2c_pb.BackGetFreeScore()
	response:ParseFromString(data)

	if response.code == 0 then
		AccountInfo:setScore(response.score)
	else
		
	end
end

function PayInfo:onReceiveQueryVipFreeScoreResponse(data)
	local response = protocol.loginServer.loginServer.pay.s2c_pb.BackQueryVipFreeScore()
	response:ParseFromString(data)

	local vfree = {}
	vfree.vipFreeScore = copyProtoTable(response.vipFreeScore)
	vfree.recvState = response.recvState
	vfree.nowTime = response.nowTime

	self:setVipFreeScore(vfree)
end

function PayInfo:onReceiveGetVipFreeScoreResponse(data)
	local response = protocol.loginServer.loginServer.pay.s2c_pb.BackGetVipFreeScore()
	response:ParseFromString(data)

	if response.code == 0 then
		AccountInfo:setScore(response.score)
	else
		
	end
end

function PayInfo:onReceiveGetGiftScoreResponse(data)
	local response = protocol.loginServer.loginServer.pay.s2c_pb.BackGetGiftScore()
	response:ParseFromString(data)

	-- if response.code == 0 then
		AccountInfo:setScore(response.score)
		AccountInfo:setPresent(response.gift)
	-- else
		PayInfo:setGetGiftScore(response)
	-- end
end

function PayInfo:onReceiveQueryVipInfoResponse(data)
	local response = protocol.loginServer.loginServer.pay.s2c_pb.BackQueryVipInfo()
	response:ParseFromString(data)

	local tem = {}
	tem.nowTime = response.nowTime
	tem.vipInfo = copyProtoTable(response.vipInfo)
	self:setVipInfo(tem)
end

function PayInfo:onReceiveRefreshGiftResponse(data)
	local response = protocol.loginServer.loginServer.pay.s2c_pb.RefreshGift()
	response:ParseFromString(data)

	AccountInfo:setGift(response.gift)
end

function PayInfo:onReceiveRefreshLoveLinesResponse(data)
	local response = protocol.loginServer.loginServer.pay.s2c_pb.RefreshLoveliness()
	response:ParseFromString(data)

	AccountInfo:setScore(response.score)
	AccountInfo:setLoveLiness(response.loveliness)
end

function PayInfo:initData()
	BindTool.register(self, "orderItemList", {})
	BindTool.register(self, "paymentNofity", nil)
	BindTool.register(self, "freeScore", nil)
	BindTool.register(self, "vipFreeScore", nil)
	BindTool.register(self, "vipInfo", nil)
	BindTool.register(self, "getGiftScore", nil)
end

--true 表示已经充过(针对只可充一次的充值项状态)
function PayInfo:getChargeStatusById(id)
	-- print(".....测试",self.chargeAvailableTimes[tonumber(id)],id,"--",self.chargeAvailableTimes[444])
	return self.chargeAvailableTimes[tonumber(id)] == 0
end

function PayInfo:getNewGuestChargeStatus()
	if device.platform == "android" then
		return self:getChargeStatusById(445)
	else
		return self:getChargeStatusById(437)
	end
end

function PayInfo:getDailyChargeStatus()
	if device.platform == "android" then
		return self:getChargeStatusById(446)
	else
		return self:getChargeStatusById(438)
	end
end
return PayInfo