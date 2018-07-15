require("network.HallConnection")
require("define.CMD_HALL")
require("network.GameConnection")
require("protocol.common.common_misc_s2c_pb")

local SystemMessageInfo = {};

function SystemMessageInfo:init()
	self:initData()
	self.messages = {}
	self.curMessage = nil
	
	HallConnection:registerCmdReceiveNotify(CMD_HALL.SYSTEM_MESSAGE, self)
	GameConnection:registerCmdReceiveNotify(CMD_HALL.SYSTEM_MESSAGE, self)
end

function SystemMessageInfo:onReceiveCmdResponse(mainID, subID, data)
	if mainID == CMD_HALL.SYSTEM_MESSAGE then
		self:onReceiveSystemMessageResponse(data)
	end
end

function SystemMessageInfo:onReceiveSystemMessageResponse(data)
	-- if not XPLAYER then
		local response = protocol.common.common.misc.s2c_pb.SystemMessage()
		response:ParseFromString(data)

		print("SystemMessageInfo....."..response.type,response.msg)
		if response.type == 3 then
			Hall.showTips(response.msg)
		end

		if self.messages[response.type] == nil then
			self.messages[response.type] = {}
		end

		local mesarr = self.messages[response.type]
		mesarr[#mesarr + 1] = response.msg
		
		self.curMessage = response.msg
		self:setMsgRresh(response.type)
	-- end
end

function SystemMessageInfo:initData()
	BindTool.register(self, "msgRresh", 0)
end

return SystemMessageInfo