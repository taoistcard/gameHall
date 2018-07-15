
require("network.GameConnection")
require("define.CMD_GAME")
-- require("protocol.gameServer.gameServer_login_c2s_pb")
-- require("protocol.gameServer.gameServer_login_s2c_pb")
require("protocol.gameServer.gameServer_mission_c2s_pb")
require("protocol.gameServer.gameServer_mission_s2c_pb")


local MissionInfo = {};

function MissionInfo:init()
	self:initData()
	GameConnection:registerCmdReceiveNotify(CMD_GAME.SUB_S_WINTASK, self)
	GameConnection:registerCmdReceiveNotify(CMD_GAME.SUB_S_VOUCHER_DRAWING, self)
	GameConnection:registerCmdReceiveNotify(CMD_GAME.SUB_S_VOUCHER_COUNT, self)
	GameConnection:registerCmdReceiveNotify(CMD_GAME.SUB_S_VOUCHER_BET, self)
	GameConnection:registerCmdReceiveNotify(CMD_GAME.SUB_S_NEARLYDRAWED_USERLIST, self)
	GameConnection:registerCmdReceiveNotify(CMD_GAME.SUB_S_USERDRAWED_COUNTLIST, self)
	GameConnection:registerCmdReceiveNotify(CMD_GAME.SUB_S_MISSION_COUNTINFO, self)

end

function MissionInfo:onReceiveCmdResponse(mainID, subID, data)
	self.mainID = mainID

-- SUB_C_VOUCHER_BET               =0x051000, --"doudizhu.c2s.CMD_C_VoucherBetting_Pro",   --用户投注
-- SUB_C_QUERY_VOUCHER             =0x010802, --"gameServer.mission.c2s.QueryVoucherInfo",     --查询池中礼券数量
-- SUB_C_QUERY_VOUCHER_PLAYER      =0x010804, --"gameServer.mission.c2s.QueryVoucherInfo",     --最新礼券中奖玩家查询
-- SUB_C_QUERY_VOUCHER_COUNT       =0x010805, --"gameServer.mission.c2s.QueryVoucherInfo",     --最新玩家中奖次数查询
            
-- SUB_S_WINTASK                   =0x010800, --"gameServer.mission.s2c.userWinTaskCalc",      --胜利类型任务奖励及次数回包
-- SUB_S_VOUCHER_DRAWING           =0x010801, --"gameServer.mission.s2c.VoucherDrawing",       --礼券开奖
-- SUB_S_VOUCHER_COUNT             =0x010802, --"gameServer.mission.s2c.QueryVoucherCount",    --查询池中礼券数量
-- SUB_S_VOUCHER_BET               =0x010803, --"gameServer.mission.s2c.VoucherBetting",       --礼券投注

-- SUB_S_NEARLYDRAWED_USERLIST     =0x010804, --"gameServer.mission.s2c.NearlyDrawedUserList", --最新礼券中奖玩家
-- SUB_S_USERDRAWED_COUNTLIST      =0x010805, --"gameServer.mission.s2c.UserDrawedCountList",  --玩家中奖次数
-- SUB_S_MISSION_COUNTINFO         =0x010806, --"gameServer.mission.s2c.MissionCountInfo",     --打出大牌类型任务,胜利类型任务奖励及次数回包

	if mainID == CMD_GAME.SUB_S_VOUCHER_DRAWING then
        self:updateDrawedCount(data)
    
    elseif mainID == CMD_GAME.SUB_S_USERDRAWED_COUNTLIST then
        self:userDrawedCount(data)

    elseif mainID == CMD_GAME.SUB_S_WINTASK then
        self:winTASKCALC_REPLY(data)

	end

    self:setMissionInfo(data)

end

--完成任务，任务次数+1（礼券开奖）
function MissionInfo:updateDrawedCount(data)
    local msg = protocol.gameServer.gameServer.mission.s2c_pb.VoucherDrawing()
    msg:ParseFromString(data)
    -- Hall.showTips("msg.wAwardType=="..msg.wAwardType, 1)
    local count =  RunTimeData:getTaskCount(msg.wAwardType)
    if count then
        RunTimeData:setTaskCount(msg.wAwardType, tonumber(count)+1)
    else
        print("RunTimeData:getTaskCount...............出错了")
    end
end

--设置用户任务完成次数
function MissionInfo:userDrawedCount(data)
    local UserDrawedCount = protocol.gameServer.gameServer.mission.s2c_pb.UserDrawedCountList()
    UserDrawedCount:ParseFromString(data)
    for i,v in ipairs(UserDrawedCount.arrDrawedCountList) do
        print("设置用户任务完成次数",i,v.wCount,"v.wAwardType",v.wAwardType)
        if v.wAwardType >10 and v.wAwardType <=20 then
            v.wAwardType = 20
        end
        RunTimeData:setTaskCount(v.wAwardType, v.wCount)
    end
    RunTimeData:setHasQueryTask(RunTimeData:getCurGameID())
end

--胜利类型任务奖励及次数回包
function MissionInfo:winTASKCALC_REPLY(data)
    local WinTaskCalc = protocol.gameServer.gameServer.mission.s2c_pb.userWinTaskCalc()
    WinTaskCalc:ParseFromString(data)
    print("szDescribeString",WinTaskCalc.szDescribeString,"wAwardTypeComboWin",WinTaskCalc.wAwardTypeComboWin,"wAwardTypeWin",WinTaskCalc.wAwardTypeWin,"dwComboWinCount",WinTaskCalc.dwComboWinCount,"dwWinCount",WinTaskCalc.dwWinCount)
    
    RunTimeData:setTaskCount(20, WinTaskCalc.dwComboWinCount)
    RunTimeData:setTaskCount(30, WinTaskCalc.dwWinCount)
end

--用户投注
function MissionInfo:sendVoucherBet()
    local request = protocol.doudizhu.doudizhu.c2s_pb.CMD_C_VoucherBetting_Pro()
    request.cbIsBet = 1
    
    local pData = request:SerializeToString()
    local pDataLen = string.len(pData)
    GameConnection:sendCommand(CMD_DDZ.SUB_C_VOUCHER_BET , 0, pData, pDataLen)
end

--用户投注
function MissionInfo:sendVoucherBet2()
    local request = protocol.doudizhu.doudizhu.c2s_pb.CMD_C_VoucherBetting_Pro()
    request.cbIsBet = 1
    
    local pData = request:SerializeToString()
    local pDataLen = string.len(pData)
    GameConnection:sendCommand(CMD_DDZ_1V1.SUB_C_VOUCHER_BET , 0, pData, pDataLen)
end

--查询池中礼券数量
function MissionInfo:sendQueryVoucherCount()
    local request = protocol.gameServer.gameServer.mission.c2s_pb.QueryVoucherInfo()
    request.dwVoucherPoolType = 1
    
    local pData = request:SerializeToString()
    local pDataLen = string.len(pData)
    GameConnection:sendCommand(CMD_GAME.SUB_C_QUERY_VOUCHER , 0, pData, pDataLen)
end
--最新礼券中奖玩家查询
function MissionInfo:sendQueryNearlyDrawedUserList()
    local request = protocol.gameServer.gameServer.mission.c2s_pb.QueryVoucherInfo()
    request.dwVoucherPoolType = 1
    
    local pData = request:SerializeToString()
    local pDataLen = string.len(pData)
    GameConnection:sendCommand(CMD_GAME.SUB_C_QUERY_VOUCHER_PLAYER , 0, pData, pDataLen)
end
--最新玩家中奖次数查询
function MissionInfo:sendQueryUserDrawedCountList()
    local request = protocol.gameServer.gameServer.mission.c2s_pb.QueryVoucherInfo()
    request.dwVoucherPoolType = 1
    
    local pData = request:SerializeToString()
    local pDataLen = string.len(pData)
    GameConnection:sendCommand(CMD_GAME.SUB_C_QUERY_VOUCHER_COUNT, 0, pData, pDataLen)
end

function MissionInfo:initData()
	BindTool.register(self, "missionInfo", nil)
end

return MissionInfo