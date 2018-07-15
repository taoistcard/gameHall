require("network.GameConnection")
require("define.CMD_DDZ")
require("protocol.doudizhu.doudizhu_s2c_pb")
require("protocol.doudizhu.doudizhu_c2s_pb")
require("protocol.doudizhu.errendoudizhu_s2c_pb")
require("protocol.doudizhu.errendoudizhu_c2s_pb")

local DoudizhuInfo = {};

function DoudizhuInfo:init()
	self:initData()
	GameConnection:registerCmdReceiveNotify(CMD_DDZ.SUB_S_SCORE_BASE        , self) --底分
    GameConnection:registerCmdReceiveNotify(CMD_DDZ.SUB_S_GAME_START        , self) --游戏开始
    GameConnection:registerCmdReceiveNotify(CMD_DDZ.SUB_S_GAME_START_ANDROID, self) --机器人开始包
    GameConnection:registerCmdReceiveNotify(CMD_DDZ.SUB_S_TUO_GUAN          , self) --托管信息
    GameConnection:registerCmdReceiveNotify(CMD_DDZ.SUB_S_BANKINFO          , self) --庄家信息
    GameConnection:registerCmdReceiveNotify(CMD_DDZ.SUB_S_COMMON            , self) --礼券投注信息
    GameConnection:registerCmdReceiveNotify(CMD_DDZ.SUB_S_GAME_CONCLUDE     , self) --游戏结束信息
    GameConnection:registerCmdReceiveNotify(CMD_DDZ.SUB_S_STATUS_FREE       , self) --空闲状态信息
    GameConnection:registerCmdReceiveNotify(CMD_DDZ.SUB_S_STATUS_CALL       , self) --叫分状态信息
    GameConnection:registerCmdReceiveNotify(CMD_DDZ.SUB_S_STATUS_PLAY       , self) --游戏状态信息
    GameConnection:registerCmdReceiveNotify(CMD_DDZ.SUB_S_GAME_CLOCK        , self) --定时器信息
    GameConnection:registerCmdReceiveNotify(CMD_DDZ.SUB_S_GAME_CONFIG       , self) --游戏状态信息

    GameConnection:registerCmdReceiveNotify(CMD_DDZ.SUB_S_VOUCHER_BET       , self) ----用户投注
    GameConnection:registerCmdReceiveNotify(CMD_DDZ.SUB_S_CALL_SCORE        , self) ----叫分
    GameConnection:registerCmdReceiveNotify(CMD_DDZ.SUB_S_CARD_OUT          , self) ----用户出牌
    GameConnection:registerCmdReceiveNotify(CMD_DDZ.SUB_S_CARD_PASS         , self) ----用户放弃

    ------ 二人场协议 ------
    GameConnection:registerCmdReceiveNotify(CMD_DDZ_1V1.SUB_S_SCORE_BASE        , self) --底分
    GameConnection:registerCmdReceiveNotify(CMD_DDZ_1V1.SUB_S_GAME_START        , self) --游戏开始
    GameConnection:registerCmdReceiveNotify(CMD_DDZ_1V1.SUB_S_GAME_START_ANDROID, self) --机器人开始包
    GameConnection:registerCmdReceiveNotify(CMD_DDZ_1V1.SUB_S_TUO_GUAN          , self) --托管信息
    GameConnection:registerCmdReceiveNotify(CMD_DDZ_1V1.SUB_S_BANKINFO          , self) --庄家信息
    GameConnection:registerCmdReceiveNotify(CMD_DDZ_1V1.SUB_S_COMMON            , self) --礼券投注信息
    GameConnection:registerCmdReceiveNotify(CMD_DDZ_1V1.SUB_S_GAME_CONCLUDE     , self) --游戏结束信息
    GameConnection:registerCmdReceiveNotify(CMD_DDZ_1V1.SUB_S_STATUS_FREE       , self) --空闲状态信息
    GameConnection:registerCmdReceiveNotify(CMD_DDZ_1V1.SUB_S_STATUS_CALL       , self) --叫分状态信息
    GameConnection:registerCmdReceiveNotify(CMD_DDZ_1V1.SUB_S_STATUS_PLAY       , self) --游戏状态信息
    GameConnection:registerCmdReceiveNotify(CMD_DDZ_1V1.SUB_S_GAME_CLOCK        , self) --定时器信息
    GameConnection:registerCmdReceiveNotify(CMD_DDZ_1V1.SUB_S_GAME_CONFIG       , self) --游戏状态信息

    GameConnection:registerCmdReceiveNotify(CMD_DDZ_1V1.SUB_S_VOUCHER_BET       , self) ----用户投注
    GameConnection:registerCmdReceiveNotify(CMD_DDZ_1V1.SUB_S_CALL_SCORE        , self) ----叫分
    GameConnection:registerCmdReceiveNotify(CMD_DDZ_1V1.SUB_S_CARD_OUT          , self) ----用户出牌
    GameConnection:registerCmdReceiveNotify(CMD_DDZ_1V1.SUB_S_CARD_PASS         , self) ----用户放弃
    GameConnection:registerCmdReceiveNotify(CMD_DDZ_1V1.SUB_S_FARMERFIRST       , self) --让先
end

function DoudizhuInfo:onReceiveCmdResponse(mainID, subID, data)
	self.mainID = mainID
	self:setDDZ_PROTOCOL(data)
end

function DoudizhuInfo:sendVoucherBet(isBet)

	local request = protocol.doudizhu.doudizhu.c2s_pb.CMD_C_VoucherBetting_Pro()
	request.cbIsBet = isBet

    local pData = request:SerializeToString()
    local pDataLen = string.len(pData)
    GameConnection:sendCommand(CMD_DDZ.SUB_C_VOUCHER_BET , 0, pData, pDataLen)
end

function DoudizhuInfo:sendCallScore(score)
	local request = protocol.doudizhu.doudizhu.c2s_pb.CMD_C_CallScore_Pro()
	request.cbCallScore = score

    local pData = request:SerializeToString()
    local pDataLen = string.len(pData)
    GameConnection:sendCommand(CMD_DDZ.SUB_C_CALL_SCORE , 0, pData, pDataLen)
end

function DoudizhuInfo:sendOutCards(cards)
	local request = protocol.doudizhu.doudizhu.c2s_pb.CMD_C_OutCard_Pro()
	request.cbCardCount = #cards
	for _, card in ipairs(cards) do
        print("sendOutCards:", card)
		table.insert(request.cbCardData, card)
	end

    local pData = request:SerializeToString()
    local pDataLen = string.len(pData)
    GameConnection:sendCommand(CMD_DDZ.SUB_C_CARD_OUT , 0, pData, pDataLen)
end

function DoudizhuInfo:sendPassCards()
    GameConnection:sendCommand(CMD_DDZ.SUB_C_CARD_PASS , 0, pData, pDataLen)
end

function DoudizhuInfo:sendTuoGuan(isTuoGuan)
    local request = protocol.doudizhu.doudizhu.c2s_pb.CMD_C_TuoGuan_Pro()
    request.bTuoGuan = isTuoGuan

    local pData = request:SerializeToString()
    local pDataLen = string.len(pData)
    GameConnection:sendCommand(CMD_DDZ.SUB_C_TUO_GUAN , 0, pData, pDataLen)
end

------ 二人场协议发送 begin ------
function DoudizhuInfo:sendVoucherBet2(isBet)

    local request = protocol.doudizhu.errendoudizhu.c2s_pb.CMD_C_VoucherBetting_Pro()
    request.cbIsBet = isBet

    local pData = request:SerializeToString()
    local pDataLen = string.len(pData)
    GameConnection:sendCommand(CMD_DDZ_1V1.SUB_C_VOUCHER_BET , 0, pData, pDataLen)
end

function DoudizhuInfo:sendCallScore2(score)
    local request = protocol.doudizhu.errendoudizhu.c2s_pb.CMD_C_CallScore_Pro()
    request.cbCallScore = score

    local pData = request:SerializeToString()
    local pDataLen = string.len(pData)
    GameConnection:sendCommand(CMD_DDZ_1V1.SUB_C_CALL_SCORE , 0, pData, pDataLen)
end

function DoudizhuInfo:sendFarmerFirst(isFarmerFirst)
    local request = protocol.doudizhu.errendoudizhu.c2s_pb.CMD_C_FarmerFirst_Pro()
    request.bFarmerFirst = isFarmerFirst

    local pData = request:SerializeToString()
    local pDataLen = string.len(pData)
    GameConnection:sendCommand(CMD_DDZ_1V1.SUB_C_FARMERFIRST , 0, pData, pDataLen)

end

function DoudizhuInfo:sendOutCards2(cards)
    local request = protocol.doudizhu.errendoudizhu.c2s_pb.CMD_C_OutCard_Pro()
    request.cbCardCount = #cards
    for _, card in ipairs(cards) do
        print("sendOutCards:", card)
        table.insert(request.cbCardData, card)
    end

    local pData = request:SerializeToString()
    local pDataLen = string.len(pData)
    GameConnection:sendCommand(CMD_DDZ_1V1.SUB_C_CARD_OUT , 0, pData, pDataLen)
end

function DoudizhuInfo:sendPassCards2()
    GameConnection:sendCommand(CMD_DDZ_1V1.SUB_C_CARD_PASS , 0, pData, pDataLen)
end

function DoudizhuInfo:sendTuoGuan2(isTuoGuan)
    local request = protocol.doudizhu.errendoudizhu.c2s_pb.CMD_C_TuoGuan_Pro()
    request.bTuoGuan = isTuoGuan

    local pData = request:SerializeToString()
    local pDataLen = string.len(pData)
    GameConnection:sendCommand(CMD_DDZ_1V1.SUB_C_TUO_GUAN , 0, pData, pDataLen)
end
------- 二人场协议发送 end ------

function DoudizhuInfo:initData()
	BindTool.register(self, "DDZ_PROTOCOL", nil)
end

return DoudizhuInfo