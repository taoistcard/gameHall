
local NetworkSocket = require("network.NetworkSocket")

NetworkManagerEvent = {
    SOCKET_CONNECTED = "SOCKET_CONNECTED",
    SOCKET_CONNECTE_FAILURE = "SOCKET_CONNECTE_FAILURE",
    SOCKET_CLOSED = "SOCKET_CLOSED",
    SOCKET_CONNECTING = "SOCKET_CONNECTING"
}

local NetworkManager = class("NetworkManager")

function NetworkManager:ctor(kind)
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()

    self.networkSocket        = NetworkSocket.new()
    self.dataListener         = {}
    self.connectFailTimes     = 0
    self.isConnected          = false

    self.networkSocket:addEventListener(NetworkSocketEvent.EVENT_RECEIVE_DATA, handler(self, self.onNetworkSocketReceiveData))
    self.networkSocket:addEventListener(NetworkSocketEvent.EVENT_SOCKET_CHANGED, handler(self, self.onNetworkSocketStatusChanged))
    self.kind = kind
end

function NetworkManager:connectServer(ip, port)

    self.ip = ip
    self.port = port

    if self.networkSocket and (self.networkSocket:getCurSocketStatus() == SocketStatus.STATUS_CLOSED or self.networkSocket:getCurSocketStatus() == SocketStatus.STATUS_CONNECT_FAILURE )then
        self.networkSocket:connectServer(ip, port)
    else
        print("---NetworkManager---network's status is not closed, cannot connect server now-----", self.networkSocket:getCurSocketStatus()) 
        self:dispatchEvent({name = NetworkManagerEvent.SOCKET_CONNECTED})
    end

end

function NetworkManager:reconnectRoomServer(roomServerIP, roomServerPort)
    if self.isConnected then
        self:closeConnect()
    end

    if roomServerIP ~= nil and roomServerPort > 0 then
        if _handle then scheduler.unscheduleGlobal(_handle) end
        if not self._roomConnection then
            self.networkSocket = NetworkSocket.new()            
        end
        RunTimeData:setCurConnectServer(roomServerIP, roomServerPort)
        self:connectServer(roomServerIP,roomServerPort)
    else
        print("invalid roomServer:",roomServerIP,roomServerPort)
    end
end

function NetworkManager:reconnectServer()
    self.networkSocket:reconnectServer()
end

function NetworkManager:reconnectBackUpServer()
    if string.len(ServerHostBackUp) > 0 and (self.ip ~= ServerHostBackUp) then
        print("...NetworkManager...备用IP...",ServerHostBackUp)
        self:connectServer(ServerHostBackUp, self.port)
    elseif self.ip ~= ServerHost then
        print("...NetworkManager...备用IP...",ServerHost)
        self:connectServer(ServerHost, self.port)
    else
        -- Hall.showTips("服务器忙，请耐心等待！")
    end
end

function NetworkManager:closeConnect()
    self.networkSocket:closeSocket()
end

function NetworkManager:closeRoomSocketDelay(delay)
    if self.handle then scheduler.unscheduleGlobal(_handle) end

    local function onInterval(dt)
        scheduler.unscheduleGlobal(self.handle)
        self.networkSocket:closeSocket()
        self.handle = nil
    end

    self.handle = scheduler.scheduleGlobal(onInterval, delay)
end

function NetworkManager:onNetworkSocketReceiveData(event)
    if self.dataListener[event.mainID] ~= nil then
        for i, listener in pairs(self.dataListener[event.mainID]) do
            listener:onReceiveCmdResponse(event.mainID, event.subID, event.data)
        end
    else
        print("----NetworkManager---收到命令，但是没有找到接收者----", event.mainID) 
    end
end

function NetworkManager:onNetworkSocketStatusChanged(event)
    --print("我是什么socket连接",self.kind,tostring(self))
    -- print("..NetworkManager..SocketStatusChanged.."..event.status,SocketStatus.STATUS_CONNECTED)
    if event.status == SocketStatus.STATUS_CONNECT_FAILURE then
        --立刻重新连接，连续失败三次不再尝试
        self.connectFailTimes = self.connectFailTimes + 1
        self.isConnected = false
        if self.connectFailTimes >= 3 then
            self.networkSocket:closeSocket()
            --尝试备用IP链接
            print("NetworkManager......开始尝试备用IP链接......")
            self:reconnectBackUpServer()
            self:dispatchEvent({name = NetworkManagerEvent.SOCKET_CONNECTE_FAILURE})

            if self.connectFailTimes > 4 and self.connectFailTimes % 4 == 0 then
                Hall.showTips("服务器忙，请耐心等待！")
            end
        else
            --print("我是重连kind=",self.kind,self.connectFailTimes)
            self.networkSocket:reconnectServer()
        end
        --提示网络不稳定
        if self.connectFailTimes == 1 then
            self:dispatchEvent({name = NetworkManagerEvent.SOCKET_CONNECTING})
        end

    elseif event.status == SocketStatus.STATUS_CLOSED then
        self.isConnected = false
        self:dispatchEvent({name = NetworkManagerEvent.SOCKET_CLOSED})

    elseif event.status == SocketStatus.STATUS_CONNECTING then
        --弹出网络连接的遮罩

    elseif event.status == SocketStatus.STATUS_CONNECTED then

        --取消网络连接的遮罩,清零连接失败的记录,发出网络连接的通知
        self.connectFailTimes = 0
        self.isConnected = true
        self:dispatchEvent({name = NetworkManagerEvent.SOCKET_CONNECTED})

    end

end

---注册网络数据接收通知
-- @param #int 监听的协议id
-- @param #obj listener 需实现回调函数 onReceiveCmdResponse(httpCode，data)
function NetworkManager:registerCmdReceiveNotify(cmdId, listener)

    if self.dataListener[cmdId] == nil then
        self.dataListener[cmdId] = {}
    end

    if listener and listener.onReceiveCmdResponse then
        self.dataListener[cmdId][tostring(listener)] = listener
    else
        print("NetworkManager: listener is nil or noHttpResponse() function not implemented!")
    end
end

---注销网络数据接收通知
-- @param #int cmdId 监听的协议id
-- @param #obj listener
function NetworkManager:unregisterCmdReceiveNotify(cmdId,listener)
    if self.dataListener[cmdId] ~= nil then
        self.dataListener[cmdId][tostring(listener)] = nil
    end
end

function NetworkManager:clearAllRegisterCmdNotify()
    self.dataListener = {}
end

function NetworkManager:sendCommand(wMainID, wSubID, pData, wDataSize)

    if self.networkSocket == nil then
        print "NetworkManager: httpNetwork not inited!"
    end
    self.networkSocket:sendData(wMainID, wSubID, pData, wDataSize)
end

return NetworkManager