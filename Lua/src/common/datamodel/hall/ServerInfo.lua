
require("network.HallConnection")
require("define.CMD_HALL")
require("protocol.loginServer.loginServer_server_c2s_pb")
require("protocol.loginServer.loginServer_server_s2c_pb")

local ServerInfo = {};

function ServerInfo:init()
	self:initData()
	HallConnection:registerCmdReceiveNotify(CMD_HALL.QUERY_SERVER_NODE_LIST, self)
	HallConnection:registerCmdReceiveNotify(CMD_HALL.QUERY_SERVER_ONLINE, self)
	HallConnection:registerCmdReceiveNotify(CMD_HALL.QUERY_SERVER_MATCH_CONFIG_LIST, self)
	HallConnection:registerCmdReceiveNotify(CMD_HALL.RECEIVE_SERVER_IP_CONFIG, self)
end

function ServerInfo:onReceiveCmdResponse(mainID, subID, data)
	print("==========", mainID, subID)
	if mainID == CMD_HALL.QUERY_SERVER_NODE_LIST then
		self:onReceiveNodeListResponse(data)
	elseif mainID == CMD_HALL.QUERY_SERVER_ONLINE then
		self:onReceiveServerOnLineResponse(data)
	elseif mainID == CMD_HALL.QUERY_SERVER_MATCH_CONFIG_LIST then
		self:onReceiveServerMatchConfigListResponse(data)
	elseif mainID == CMD_HALL.RECEIVE_SERVER_IP_CONFIG then
		self:onReceiveServerIPConfig(data)
	end
end

function ServerInfo:sendQueryServerOnlineRequest(serveridlist)
	local request = protocol.loginServer.loginServer.server.c2s_pb.QueryServerOnline()
	local serlist = request.serverIDList
	for ind, id in ipairs(serveridlist) do
		table.insert(serlist, ind, id)
	end

    local pData = request:SerializeToString()
    local pDataLen = string.len(pData)
    HallConnection:sendCommand(CMD_HALL.QUERY_SERVER_ONLINE , 0, pData, pDataLen)
end

function ServerInfo:onReceiveNodeListResponse(data)
	local response = protocol.loginServer.loginServer.server.s2c_pb.NodeList()
	response:ParseFromString(data)
	-- dump(response.list, "response.list")
	-- for k,v in pairs(response) do
	-- 	print("222",k,v)
	-- 	if type(v) == "table" then
	-- 		-- dump(v, "v")
	-- 		for j,w in pairs(v.list or {}) do
	-- 			print("33",j,w)
	-- 		end
	-- 	end
	-- end
	
	self:setNodeItemList(copyProtoTable(response.list))
	-- dump(self.nodeItemList, "response.list")
end

function ServerInfo:onReceiveServerOnLineResponse(data)
	local response = protocol.loginServer.loginServer.server.s2c_pb.ServerOnline()
	response:ParseFromString(data)

	self:setServerOnlineList(copyProtoTable(response.list))
end

function ServerInfo:onReceiveServerMatchConfigListResponse(data)
	local response = protocol.loginServer.loginServer.server.s2c_pb.MatchConfigList()
	response:ParseFromString(data)

	self:setMatchConfigList(copyProtoTable(response.list))
end

function ServerInfo:onReceiveServerIPConfig(data)
	local response = protocol.loginServer.loginServer.server.s2c_pb.UserIPAddr()
	response:ParseFromString(data)
	if ServerHostBackUp == "192.168.0.93" then
		--todo
		--内网情况下不改变连接的 server host
	else
		ServerHostBackUp = response.ipAddr
		cc.UserDefault:getInstance():setStringForKey("ServerHostBackUp", response.ipAddr)
		cc.UserDefault:getInstance():flush()
		print("...测试...onReceiveServerIPConfig...",ServerHostBackUp,response.ipAddr)
	end
end

function ServerInfo:initData()
	BindTool.register(self, "nodeItemList", {})
	BindTool.register(self, "matchConfigList", {})
	BindTool.register(self, "serverOnlineList", {})
end

function ServerInfo:getNodeListByKind(kind)
	local NodeList = {}
	for k,v in pairs(self.nodeItemList or {}) do
		if v.kindID == kind then
			table.insert(NodeList, v)
		end
	end
	return NodeList
end
function ServerInfo:getServerNodeItemByNodeID( kindID, nodeID )
	local NodeItem
	for k,v in pairs(self.nodeItemList or {}) do
		if v.kindID == kindID and  v.nodeID == nodeID then
			NodeItem = v
		end
	end
	return NodeItem
end
function ServerInfo:getNodeItemByIndex(kindID, sectionIndex)
	local nodeList = self:getNodeListByKind(kindID)
	if nodeList then
		return nodeList[sectionIndex]
	end
	return nil
end

function ServerInfo:getServerItemByNodeIndex(kindID, sectionIndex, roomIndex)
	local nodeItem = self:getNodeItemByIndex(kindID, sectionIndex)
	if nodeItem then
		return nodeItem.serverList[roomIndex]
	else
		return nil
	end
end

function ServerInfo:getNodeItemByNodeID(kindID, nodeID)
	for k,v in pairs(self:getNodeListByKind(kindID)) do
		if v.nodeID == nodeID then
			return v
		end
	end
	return nil
end

function ServerInfo:getServerItemByNodeID(kindID, nodeID, roomIndex)
	local nodeItem = self:getNodeItemByNodeID(kindID, nodeID)
	if nodeItem then
		return nodeItem.serverList[roomIndex]
	else
		return nil
	end
end
function ServerInfo:getServerItemByServerID(serverID)
	local serverItem = nil
	for k,v in pairs(self.nodeItemList or {}) do
		for j,w in pairs(v.serverList or {}) do
			if w.serverID == serverID then
				serverItem = w
				break
			end
		end
	end
	return serverItem
end
function ServerInfo:getOnlineCountByGameKind(kindID)
	local ret = 0
	local nodeList = self:getNodeListByKind(kindID, nodeID)
	for k,v in pairs(nodeList) do
		ret = ret + v.onlineCount
	end
	return ret
end

function ServerInfo:getOnlineCountByGameNodeID(kindID, nodeID)
	local nodeItem = self:getNodeItemByNodeID(kindID, nodeID)
	if nodeItem then
		return nodeItem.onlineCount
	end
	return 0
end

return ServerInfo