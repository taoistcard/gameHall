
require("network.GameConnection")
require("define.CMD_GAME")
require("protocol.gameServer.gameServer_chat_c2s_pb")
require("protocol.gameServer.gameServer_chat_s2c_pb")

local ChatInfo = {};

function ChatInfo:init()
	self:initData()
	GameConnection:registerCmdReceiveNotify(CMD_GAME.USER_CHAT, self)
	GameConnection:registerCmdReceiveNotify(CMD_GAME.USER_EXPRESSION, self)
	GameConnection:registerCmdReceiveNotify(CMD_GAME.USER_MULTIMEDIA, self)
end

function ChatInfo:onReceiveCmdResponse(mainID, subID, data)
	if mainID == CMD_GAME.USER_CHAT then
		self:onReceiveUserChatResponse(data)
	elseif mainID == CMD_GAME.USER_EXPRESSION then 
		self:onReceiveUserExpressionResponse(data)
	elseif mainID == CMD_GAME.USER_MULTIMEDIA then 
		self:onReceiveUserMultimediaResponse(data)
	end
end

function ChatInfo:sendUserChatRequest(color, content)
	local request = protocol.gameServer.gameServer.chat.c2s_pb.UserChat()
	request.color = color
	request.content = content
    local pData = request:SerializeToString()
    local pDataLen = string.len(pData)
    GameConnection:sendCommand(CMD_GAME.USER_CHAT , 0, pData, pDataLen)
end

function ChatInfo:sendUserExpressionRequest(expressionid)
	local request = protocol.gameServer.gameServer.chat.c2s_pb.UserExpression()
	request.expressID = expressionid
    local pData = request:SerializeToString()
    local pDataLen = string.len(pData)
    GameConnection:sendCommand(CMD_GAME.USER_EXPRESSION , 0, pData, pDataLen)
end

function ChatInfo:sendUserMultimediaRequest(utype, url)
	local request = protocol.gameServer.gameServer.chat.c2s_pb.UserMultimedia()
	request.type = utype
	request.url = url
    local pData = request:SerializeToString()
    local pDataLen = string.len(pData)
    GameConnection:sendCommand(CMD_GAME.USER_MULTIMEDIA , 0, pData, pDataLen)
end

function ChatInfo:onReceiveUserChatResponse(data)
	local response = protocol.gameServer.gameServer.chat.s2c_pb.UserChat()
	response:ParseFromString(data)
	local chat = {}
	chat.chatType = 1
	chat.color = response.color
	chat.sendUserID = response.sendUserID
	chat.sendNickname = response.sendNickname
	chat.content = response.content

	self.chatList[#self.chatList + 1] = chat

	self:setChatMsg(chat)
	self:setChatList(self.chatList)
	self:setChatMsgData(chat)
end

function ChatInfo:onReceiveUserExpressionResponse(data)
	local response = protocol.gameServer.gameServer.chat.s2c_pb.UserExpression()
	response:ParseFromString(data)

	local chat = {}
	chat.chatType = 2
	chat.expressID = response.expressID
	chat.sendUserID = response.sendUserID
	chat.sendNickname = response.sendNickname

	self.chatList[#self.chatList + 1] = chat

	self:setChatFace(chat)
	self:setChatList(self.chatList)
	self:setChatMsgData(chat)
end

function ChatInfo:onReceiveUserMultimediaResponse(data)
	local response = protocol.gameServer.gameServer.chat.s2c_pb.UserMultimedia()
	response:ParseFromString(data)

	local chat = {}
	chat.chatType = 3
	chat.type = response.type
	chat.sendUserID = response.sendUserID
	chat.sendNickname = response.sendNickname
	chat.url = response.url

	self.chatList[#self.chatList + 1] = chat

	self:setChatMultimedia(chat)
	self:setChatList(self.chatList)
end

function ChatInfo:initData()
	BindTool.register(self, "chatList", {})
	BindTool.register(self, "chatMsg", {})
	BindTool.register(self, "chatFace", {})
	BindTool.register(self, "chatMultimedia", {})
	BindTool.register(self, "chatMsgData", {})
end

return ChatInfo