require("network.GameConnection")
require("define.CMD_ZJH")

local ZhajinhuaInfo = {};

function ZhajinhuaInfo:init()
	self:initData()
	GameConnection:registerCmdReceiveNotify(CMD_ZJH.SUB_S_GAME_START, self)
	GameConnection:registerCmdReceiveNotify(CMD_ZJH.SUB_S_ADD_SCORE, self)
	GameConnection:registerCmdReceiveNotify(CMD_ZJH.SUB_S_GIVE_UP, self)

	GameConnection:registerCmdReceiveNotify(CMD_ZJH.SUB_S_GAME_END, self)
	GameConnection:registerCmdReceiveNotify(CMD_ZJH.SUB_S_COMPARE_CARD, self)
	GameConnection:registerCmdReceiveNotify(CMD_ZJH.SUB_S_COMPARE_ALL, self)
	GameConnection:registerCmdReceiveNotify(CMD_ZJH.SUB_S_LOOK_CARD, self)
	GameConnection:registerCmdReceiveNotify(CMD_ZJH.SUB_S_OPEN_CARD, self)

	GameConnection:registerCmdReceiveNotify(CMD_ZJH.SUB_S_WAIT_COMPARE, self)
	GameConnection:registerCmdReceiveNotify(CMD_ZJH.SUB_S_CLOCK, self)
	GameConnection:registerCmdReceiveNotify(CMD_ZJH.SUB_S_SHOW_CARD, self)
	GameConnection:registerCmdReceiveNotify(CMD_ZJH.SUB_S_STATUSFREE, self)
	GameConnection:registerCmdReceiveNotify(CMD_ZJH.SUB_S_STATUSPLAY, self)
	GameConnection:registerCmdReceiveNotify(CMD_ZJH.SUB_S_GAMECELLINFO, self)
end

function ZhajinhuaInfo:onReceiveCmdResponse(mainID, subID, data)

	-- self:setMainID(mainID)
	self.mainID = mainID

	if mainID == CMD_ZJH.SUB_S_STATUSFREE or mainID == CMD_ZJH.SUB_S_STATUSPLAY then
		self:setRecoverGameScene(data)
	else
		self:setData(data)
	end
end
function ZhajinhuaInfo:initData()
	BindTool.register(self, "mainID", nil)
	BindTool.register(self, "data", nil)
	BindTool.register(self, "gameStatus", nil)
	BindTool.register(self, "recoverGameScene", nil)
end

return ZhajinhuaInfo