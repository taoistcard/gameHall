
require("network.HallConnection")
require("define.CMD_HALL")
require("protocol.loginServer.loginServer_heartBeat_c2s_pb")
require("protocol.loginServer.loginServer_heartBeat_s2c_pb")

local HeartBeatInfo = {};

function HeartBeatInfo:init()
	HallConnection:registerCmdReceiveNotify(CMD_HALL.HEART_BEAT, self)

	HallConnection:addEventListener(NetworkManagerEvent.SOCKET_CONNECTED, handler(self, self.onSocketStatus))
	HallConnection:addEventListener(NetworkManagerEvent.SOCKET_CLOSED, handler(self, self.onSocketStatus))
	HallConnection:addEventListener(NetworkManagerEvent.SOCKET_CONNECTE_FAILURE, handler(self, self.onSocketStatus))
end

function HeartBeatInfo:onReceiveCmdResponse(mainID, subID, data)
	if mainID == CMD_HALL.HEART_BEAT then
		self.lastReceiveTime = os.time()
	end
end

function HeartBeatInfo:onSocketStatus(event)
	if event.name == NetworkManagerEvent.SOCKET_CONNECTED then
		self:startHeartBeatScheduler()
        if self.socket_closed then
            if DataManager:getAutoHallLogin() then
                AccountInfo:sendLoginRequest(AccountInfo.nickName)
            end
            self.socket_closed = false
        end
	elseif event.name == NetworkManagerEvent.SOCKET_CLOSED then
		self:stopHeartBeatScheduler()
        self.socket_closed = true
	elseif event.name == NetworkManagerEvent.SOCKET_CONNECTE_FAILURE then
		self:stopHeartBeatScheduler()
	end
end

function HeartBeatInfo:stopHeartBeatScheduler()
    if(self.handler ~= nil) then
        scheduler.unscheduleGlobal(self.handler)
        self.handler = nil
    end
end 

function HeartBeatInfo:startHeartBeatScheduler()
    self:stopHeartBeatScheduler()

    self.lastReceiveTime = os.time()
    self.handler = scheduler.scheduleGlobal(function()
        if(os.time() - self.lastReceiveTime > 9) then
            -- 断线了，断线重连
            print("心跳，断线重连")
            HallConnection:closeConnect()
            HallConnection:reconnectServer()
        else
            self:sendHeartBeat()
        end
    end , 3) -- 间隔一定时间调用
end

function HeartBeatInfo:sendHeartBeat()
    local logon = protocol.loginServer.loginServer.heartBeat.c2s_pb.HeartBeat()
    local pData = logon:SerializeToString()
    local pDataLen = string.len(pData)
    HallConnection:sendCommand(CMD_HALL.HEART_BEAT , 0, pData, pDataLen)
end


return HeartBeatInfo