cc.utils                = require("framework.cc.utils.init")
cc.net                  = require("framework.cc.net.init")

NetworkSocketEvent = {
    EVENT_RECEIVE_DATA = "SOCKET_RECEIVE_DATA",
    EVENT_SOCKET_CHANGED = "EVENT_SOCKET_CHANGED"
}

SocketStatus = {
    STATUS_CONNECTING = "SOCKET_STATUS_CONNECTING",
    STATUS_CLOSED = "SOCKET_STATUS_CLOSED",
    STATUS_CONNECTED = "SOCKET_STATUS_CONNECTED",
    STATUS_CONNECT_FAILURE = "SOCKET_STATUS_CONNECT_FAILURE"
}

local NetworkSocket = class("NetworkSocket")

function NetworkSocket:ctor()
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    self:initSocket()
    self:initBuffer()
    self._lastServerIP = nil
    self._lastServerPort = 0

    self.socketStatus = SocketStatus.STATUS_CLOSED
end


-- -------------------------------------public method-------------------------------------
function NetworkSocket:getCurSocketStatus()
    return self.socketStatus
end

function NetworkSocket:reconnectServer()
    self:connectServer(self._lastServerIP, self._lastServerPort)
end

-- 连接服务器
function NetworkSocket:connectServer(serverIP,serverPort)
    if serverIP == nil then print("serverIP can not be nil!") return end

    if self.socketStatus == SocketStatus.STATUS_CONNECTED then
        self:closeSocket()
    elseif self.socketStatus == SocketStatus.STATUS_CONNECTING then print("socket connectting! cannot connect now")
        return
    end

    print("connectServer:", serverIP, serverPort)

    self._socket:connect(serverIP, serverPort, true)
    
    self._lastServerIP = serverIP
    self._lastServerPort = serverPort

    self.socketStatus = SocketStatus.STATUS_CONNECTING

    self:dispatchEvent({name = NetworkSocketEvent.EVENT_SOCKET_CHANGED, status = self.socketStatus})
end

-- 关闭连接
function NetworkSocket:closeSocket()
    self._socket:close()
    self._socket:disconnect()

    self.socketStatus = SocketStatus.STATUS_CLOSED
end

--发送数据
function NetworkSocket:sendData(wMainID, wSubID, pData, wDataSize)
    if self.socketStatus == SocketStatus.STATUS_CONNECTING or self.socketStatus == SocketStatus.STATUS_CLOSED then printInfo("---NetworkSocket--status--%s--can not sendData---", self.socketStatus) return end

    wDataSize = wDataSize or 0

    self._socketData:SetDataFlag(0x47)
    if self._socketData:InitSocketData(wMainID,wSubID,pData,wDataSize) == false then 
        print("---NetworkSocket---严重错误:c++层加密数据失败------")
        return
    end
    
    local dataBuffer = self._socketData:GetDataBuffer()
    if wMainID > 0 and wMainID ~= 0x020000 and wMainID ~= 0x020008 then
        if wMainID ~= 0x010000 then
            -- print("----send--wMainID----", string.format("0x%06x", wMainID))
        end
    end
    self._socket:send(dataBuffer)
end

-- -----------------------------------private method-----------------------------------------
function NetworkSocket:onStatus(__event)
    printInfo("socket status: %s", __event.name)

    if __event.name == cc.net.SocketTCP.EVENT_CLOSE then
    elseif __event.name == cc.net.SocketTCP.EVENT_CLOSED then
        self.socketStatus = SocketStatus.STATUS_CLOSED
        self:dispatchEvent({name = NetworkSocketEvent.EVENT_SOCKET_CHANGED, status = self.socketStatus})
    elseif __event.name == cc.net.SocketTCP.EVENT_CONNECTED then
        self.socketStatus = SocketStatus.STATUS_CONNECTED
        self:initSocketData()
        self:dispatchEvent({name = NetworkSocketEvent.EVENT_SOCKET_CHANGED, status = self.socketStatus})
    elseif __event.name == cc.net.SocketTCP.EVENT_CONNECT_FAILURE then
        self.socketStatus = SocketStatus.STATUS_CONNECT_FAILURE
        self:dispatchEvent({name = NetworkSocketEvent.EVENT_SOCKET_CHANGED, status = self.socketStatus})
    end
end

--新的游戏服务器处理
function NetworkSocket:onData(__event)
    self._buf:setPos(self._buf:getLen()+1)
    self._buf:writeBuf(__event.data)
    self._buf:setPos(1)

    self._wRecvSize = self._wRecvSize + string.len(__event.data)

    local wPacketSize = 0
    while self._wRecvSize >= 6 do
        wPacketSize = self._buf:readUShort() + 2
        if wPacketSize > 16384 - 6 then print("数据包太大") return false end
        if self._wRecvSize < wPacketSize then print("数据包太小") return false end

        self._buf:setPos(1)
        local __dispatchPacket = self._buf:readBuf(wPacketSize)
        self._wRecvSize = self._wRecvSize - wPacketSize;

        -- clear buffer on exhausted
        if self._buf:getAvailable() <= 0 then
            self:initBuffer()
        else
            local __tmp = NetworkSocket.getBaseBA()
            self._buf:readBytes(__tmp, 1, self._buf:getAvailable())
            self._buf = __tmp
            self._buf:setPos(1)
        end

        self._socketData:SetDataFlag(0)
        self._socketData:SetBufferData(function(wMainID, wSubID, pData) self:OnReceiveMessage(wMainID, wSubID, pData) end, __dispatchPacket, wPacketSize)
    end
end

function NetworkSocket:OnReceiveMessage(wMainID, wSubID, pData)
    if wMainID > 0 and wMainID ~= 0x010000 and wMainID ~= 0x020010 and wMainID ~= 0x020000 and wMainID ~= 0x020008 then
        if wMainID ~= 0x010201 and wMainID ~= 0x010104 and wMainID ~= 0x01ff01 then
            -- print("----receive--wMainID----", string.format("0x%06x", wMainID)) 
        end        
    end
    self:dispatchEvent({name = NetworkSocketEvent.EVENT_RECEIVE_DATA, mainID = wMainID, subID = wSubID, data = pData})
end

function NetworkSocket:initSocket()
    if not self._socket then
        self._socket = cc.net.SocketTCP.new()
        self._socket:setReconnTime(1)
        self._socket:addEventListener(cc.net.SocketTCP.EVENT_CONNECTED, handler(self, self.onStatus))
        self._socket:addEventListener(cc.net.SocketTCP.EVENT_CLOSE, handler(self,self.onStatus))
        self._socket:addEventListener(cc.net.SocketTCP.EVENT_CLOSED, handler(self,self.onStatus))
        self._socket:addEventListener(cc.net.SocketTCP.EVENT_CONNECT_FAILURE, handler(self,self.onStatus))
        self._socket:addEventListener(cc.net.SocketTCP.EVENT_DATA, handler(self,self.onData))
    end
end

function NetworkSocket:initBuffer()
    self._buf = NetworkSocket.getBaseBA()
    self._wRecvSize = 0
end

function NetworkSocket:initSocketData()
    if not self._socketData then
        self._socketData = NewCTCPSocketData:create()
    end
    self._socketData:clearSocketData()
end

function NetworkSocket.getBaseBA()
    return cc.utils.ByteArrayVarint.new(cc.utils.ByteArrayVarint.ENDIAN_BIG) 
end

return NetworkSocket