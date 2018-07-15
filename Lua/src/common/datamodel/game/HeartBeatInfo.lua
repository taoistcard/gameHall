
require("network.GameConnection")
require("define.CMD_GAME")
require("protocol.gameServer.gameServer_heartBeat_c2s_pb")
require("protocol.gameServer.gameServer_heartBeat_s2c_pb")

local HeartBeatInfo = {};

function HeartBeatInfo:init()
	GameConnection:registerCmdReceiveNotify(CMD_GAME.HEART_BEAT, self)

	GameConnection:addEventListener(NetworkManagerEvent.SOCKET_CONNECTED, handler(self, self.onSocketStatus))
	GameConnection:addEventListener(NetworkManagerEvent.SOCKET_CLOSED, handler(self, self.onSocketStatus))
	GameConnection:addEventListener(NetworkManagerEvent.SOCKET_CONNECTE_FAILURE, handler(self, self.onSocketStatus))
end

function HeartBeatInfo:onReceiveCmdResponse(mainID, subID, data)
	if mainID == CMD_GAME.HEART_BEAT then
		self.lastReceiveTime = os.time()
	end
end

function HeartBeatInfo:onSocketStatus(event)
	if event.name == NetworkManagerEvent.SOCKET_CONNECTED then
		self:startHeartBeatScheduler()
	elseif event.name == NetworkManagerEvent.SOCKET_CLOSED then
		self:stopHeartBeatScheduler()
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
            -- GameConnection:closeConnect()
            -- GameConnection:reconnectServer()
        else
            self:sendHeartBeat()
        end
    end , 3) -- 间隔一定时间调用
end

function HeartBeatInfo:sendHeartBeat()
    local logon = protocol.gameServer.gameServer.heartBeat.c2s_pb.HeartBeat()
    local pData = logon:SerializeToString()
    local pDataLen = string.len(pData)
    GameConnection:sendCommand(CMD_GAME.HEART_BEAT , 0, pData, pDataLen)
end


return HeartBeatInfo