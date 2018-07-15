require("network.HallConnection")
require("define.CMD_HALL")
require("protocol.loginServer.loginServer_login_c2s_pb")
require("protocol.loginServer.loginServer_login_s2c_pb")
require("protocol.loginServer.loginServer_account_c2s_pb")
require("protocol.loginServer.loginServer_account_s2c_pb")

require("tools.BindTool")

local AccountInfo = {};

function AccountInfo:init()
	self:initData()
	HallConnection:registerCmdReceiveNotify(CMD_HALL.LOGIN, self)
	HallConnection:registerCmdReceiveNotify(CMD_HALL.LOGOUT, self)
	HallConnection:registerCmdReceiveNotify(CMD_HALL.USER_SCORE, self)
	HallConnection:registerCmdReceiveNotify(CMD_HALL.CHANGE_FACEID, self)
	HallConnection:registerCmdReceiveNotify(CMD_HALL.CHANGE_SIGNATURE, self)
	HallConnection:registerCmdReceiveNotify(CMD_HALL.CHANGE_NICK_NAME, self)
	HallConnection:registerCmdReceiveNotify(CMD_HALL.CHECK_NICK_NAME, self)
	HallConnection:registerCmdReceiveNotify(CMD_HALL.CHANGE_GENDER, self)
	HallConnection:registerCmdReceiveNotify(CMD_HALL.CHANGE_PLATFORM_FACE, self)
	HallConnection:registerCmdReceiveNotify(CMD_HALL.SETBINDINGINFO, self)
end

function AccountInfo:onReceiveCmdResponse(mainID, subID, data)
	if mainID == CMD_HALL.LOGIN then
		self:onReceiveLoginResponse(data)
	elseif mainID == CMD_HALL.LOGOUT then
		--提示玩家被挤下线
	elseif mainID == CMD_HALL.USER_SCORE then
		self:onReceiveUserScoreInfo(data)
	elseif mainID == CMD_HALL.CHANGE_FACEID then
		self:onReceiveChangeFaceIdResponse(data)
	elseif mainID == CMD_HALL.CHANGE_SIGNATURE then
		self:onReceiveChangeSignatureResponse(data)
	elseif mainID == CMD_HALL.CHANGE_NICK_NAME then
		self:onReceiveChangeNickNameResponse(data)
	elseif mainID == CMD_HALL.CHECK_NICK_NAME then
		self:onReceiveCheckNickNameResponse(data)
	elseif mainID == CMD_HALL.CHANGE_GENDER then
		self:onReceiveChangeGenderResponse(data)
	elseif mainID == CMD_HALL.CHANGE_PLATFORM_FACE then
		self:onReceiveChangePlatformFaceResponse(data)
	elseif mainID == CMD_HALL.SETBINDINGINFO then
		self:onReceiveSetBindingInfoResponse(data)
	end
end
function AccountInfo:sendSetBindingInfo()
	local request = protocol.loginServer.loginServer.account.s2c_pb.SetBindingInfo()
    HallConnection:sendCommand(CMD_HALL.SETBINDINGINFO , 0, nil, nil)
end
function AccountInfo:sendLoginRequest(nickName)
	local logon = protocol.loginServer.loginServer.login.c2s_pb.Login()
	logon.session = SessionId
	logon.nickName = nickName or ""
	logon.machineID = GetDeviceID()
	logon.scoreTag = false
	local kinds = HallSetting.getAllGameKindID()
	for k,v in pairs(kinds) do
        logon.kindID:append(v)
    end
	-- logon.scoreTag = APP_CHANNEL

    print("统一平台登陆成功:", logon.session, logon.nickName, logon.machineID, logon.kindID, logon.channelId)


    local pData = logon:SerializeToString()
    local pDataLen = string.len(pData)
    HallConnection:sendCommand(CMD_HALL.LOGIN , 0, pData, pDataLen)
end

function AccountInfo:sendSimulatorLoginRequest(nickName)
	-- nickName = "lhj1"
	local logon = protocol.loginServer.loginServer.login.c2s_pb.SimulatorLogin()
	logon.session = SessionId
	logon.nickName = nickName or ""
	logon.machineID = GetDeviceID()
	logon.scoreTag = false
	print(type(logon.kindID), "type of logon.kindID","nickName",nickName,"SessionId",SessionId)

	local kinds = HallSetting.getAllGameKindID()
	for k,v in pairs(kinds) do
		print("append",v)
        logon.kindID:append(v)		
    end
	-- logon.scoreTag = APP_CHANNEL


    local pData = logon:SerializeToString()
    local pDataLen = string.len(pData)
    HallConnection:sendCommand(CMD_HALL.SIMULATOR_LOGIN , 0, pData, pDataLen)
end

function AccountInfo:sendChangeFaceIdRequest(faceid)
	local request = protocol.loginServer.loginServer.account.c2s_pb.ChangeFaceID()
	request.faceID = faceid
	self.temFaceID = faceid
    local pData = request:SerializeToString()
    local pDataLen = string.len(pData)
    HallConnection:sendCommand(CMD_HALL.CHANGE_FACEID , 0, pData, pDataLen)
end

function AccountInfo:sendChangeSignatureRequest(signature)
	local request = protocol.loginServer.loginServer.account.c2s_pb.ChangeSignature()
	request.signature = signature
	self.temSignature = signature
    local pData = request:SerializeToString()
    local pDataLen = string.len(pData)
    print("sendChangeSignatureRequest",signature)
    HallConnection:sendCommand(CMD_HALL.CHANGE_SIGNATURE , 0, pData, pDataLen)
end

function AccountInfo:sendChangeNickNameRequest(nickName, isScoreCharged)
	local free = cc.UserDefault:getInstance():getBoolForKey("hasChangedNickName", false)
	local request = protocol.loginServer.loginServer.account.c2s_pb.ChangeNickname()
	request.nickName = nickName
	request.isScoreCharged = free--isScoreCharged or false
	self.temNickName = nickName
	print("nickName",nickName,"isScoreCharged",isScoreCharged)
    local pData = request:SerializeToString()
    local pDataLen = string.len(pData)
    HallConnection:sendCommand(CMD_HALL.CHANGE_NICK_NAME , 0, pData, pDataLen)
end

function AccountInfo:sendCheckNickNameRequest(nickName)
	local request = protocol.loginServer.loginServer.account.c2s_pb.CheckNickname()
	request.nickName = nickName

    local pData = request:SerializeToString()
    local pDataLen = string.len(pData)
    HallConnection:sendCommand(CMD_HALL.CHECK_NICK_NAME , 0, pData, pDataLen)
end

function AccountInfo:sendChangeGenderRequest(gender)
	local request = protocol.loginServer.loginServer.account.c2s_pb.ChangeGender()
	request.gender = gender
	self.temGender = gender
    local pData = request:SerializeToString()
    local pDataLen = string.len(pData)
    HallConnection:sendCommand(CMD_HALL.CHANGE_GENDER , 0, pData, pDataLen)
end

function AccountInfo:sendSetPlatformFaceRequest(platformFace)
	local request = protocol.loginServer.loginServer.account.c2s_pb.SetPlatformFace()
	request.platformFace = platformFace
	self.temPlatformFace = platformFace
    local pData = request:SerializeToString()
    local pDataLen = string.len(pData)
    HallConnection:sendCommand(CMD_HALL.CHANGE_PLATFORM_FACE , 0, pData, pDataLen)
end

function AccountInfo:onReceiveLoginResponse(data)
	local logon = protocol.loginServer.loginServer.login.s2c_pb.Login()
	logon:ParseFromString(data)
	print("onReceiveLoginResponse")
    if logon.code == 0 then
        if logon.data.isRegister == true then
            --注册第一次登陆修改昵称
            firstModifyNickname = logon.data.nickName
        end

	    -- self.userId = logon.data.userID
	    -- self.tokenId = logon.data.userId
	    -- self.gameId = logon.data.gameID
	    -- self.nickName = logon.data.nickName
	    -- self.underwrite = logon.data.signature
	    -- self.faceId = logon.data.faceID
	    -- self.headFile = logon.data.platformFace
	    -- self.gender = logon.data.gender
	    -- self.memberOrder = logon.data.memberOrder
	    -- self.isRegister = logon.data.isRegister
		-- local tem = require("datamodel.struct.UserInfo").new() --{}
		-- tem:dataLogin(logon.data)
	    self:setUserId(logon.data.userID)
		self:setTokenId(logon.data.gameID)
		self:setGameId(logon.data.gameID)
		self:setNickName(logon.data.nickName)
		self:setUnderwrite(logon.data.signature)
		self:setFaceId(logon.data.faceID)
		self:setHeadFileMD5(logon.data.platformFace)
		self:setGender(logon.data.gender)
		self:setMemberOrder(logon.data.memberOrder)
		self:setIsRegister(logon.data.isRegister)
		print("tem",tostring(tem))
		self:setUserInfoAccount(logon.data)
		print("userID",logon.data.userID,"gameID=",logon.data.gameID,"platformFace",logon.data.platformFace,"faceID",logon.data.faceID)
	    print("---AccountInfo-登陆成功-----",self.userId, self.faceId, self.nickName,self.score)
    else
    	print("---AccountInfo-登陆失败-----logon.code", logon.code,logon.msg,"qq")
    	-- if logon.msg then
    	-- 	Hall.showTips(logon.msg, 2)
    	-- end
		-- RC_ACCOUNT_NULLITY=6;					//您的帐号处于冻结状态，请与客服联系";
		-- RC_ACCOUNT_STUNDOWN=7;					//您的帐号使用了安全关闭功能，必须重新开通后才能继续使用
		-- RC_ALREADY_LOGIN=8;						//已经登入，换帐号需要先断开连接
    	if logon.code == 6 then
    		Hall.showTips("您的账号已被冻结，如有疑问请咨询QQ客服：2502897974",5)
    	elseif logon.code == 7 then
    		Hall.showTips("您的帐号使用了安全关闭功能，必须重新开通后才能继续使用",2)
    	elseif logon.code == 8 then
    		Hall.showTips("您的帐号已经登入，换帐号需要先断开连接",2)
    	end
    end

    self:setLoginResult(logon.code)
end

function AccountInfo:onReceiveUserScoreInfo(data)
	local response = protocol.loginServer.loginServer.login.s2c_pb.ScoreInfo()
	response:ParseFromString(data)

	self:setMedal(response.medal)
	self:setExperience(response.experience)
	self:setLoveLiness(response.loveLiness)
	self:setScore(response.score)
	self:setInsure(response.insure)
	self:setGift(response.gift)
	self:setPresent(response.present)
	-- local tem = require("datamodel.struct.UserInfo").new() --{}
	-- tem:dataUserScoreInfo(response)
	self:setScoreInfoAccount(response)
    -- self.medal = response.medal
    -- self.experience = response.experience
    -- self.loveLiness = response.loveLiness
    -- self.score = response.score
    -- self.insure = response.insure
    -- self.gift = response.gift
    -- self.present = response.present
end

function AccountInfo:onReceiveChangeFaceIdResponse(data)
	local response = protocol.loginServer.loginServer.account.s2c_pb.ChangeFaceID()
	response:ParseFromString(data)

	if response.code == 1 then
    	self:setFaceId(self.temFaceID)
    	DataManager:getMyUserInfo().faceID = self.temFaceID
    	self:setUserInfoChange(true)
    else
    	
    end
end

function AccountInfo:onReceiveChangeSignatureResponse(data)
	local response = protocol.loginServer.loginServer.account.s2c_pb.ChangeSignature()
	response:ParseFromString(data)
	print("onReceiveChangeSignatureResponse-response.code",response.code)
	if response.code == 1 then
    	DataManager:getMyUserInfo().signature = self.temSignature
    	self:setUnderwrite(self.temSignature)
    	self:setUserInfoChange(true)
    else
    	print("response.code",response.code)
    end
end

function AccountInfo:onReceiveChangeNickNameResponse(data)
	local response = protocol.loginServer.loginServer.account.s2c_pb.ChangeNickname()
	response:ParseFromString(data)

	if response.code == 1 then    	
    	DataManager:getMyUserInfo().nickName = self.temNickName
    	self:setNickName(self.temNickName)
    	self:setUserInfoChange(true)
        cc.UserDefault:getInstance():setBoolForKey("hasChangedNickName", true)
        cc.UserDefault:getInstance():flush()
    else
    	print("response.code",response.code)
    	if response.msg then
    		Hall.showTips(response.msg, 2)
    	end
    	
    end
end

function AccountInfo:onReceiveCheckNickNameResponse(data)
	local response = protocol.loginServer.loginServer.account.s2c_pb.CheckNickname()
	response:ParseFromString(data)

	if response.code == 1 then
    	self:setIsNickNameValid(true)
    	self:setUserInfoChange(true)
    else
    	
    end
end

function AccountInfo:onReceiveChangeGenderResponse(data)
	local response = protocol.loginServer.loginServer.account.s2c_pb.ChangeGender()
	response:ParseFromString(data)
	print("response.code",response.code)
	if response.code == 1 then
    	DataManager:getMyUserInfo().gender = self.temGender
    	self:setGender(self.temGender)
    	self:setUserInfoChange(true)
    else
    	
    end
end

function AccountInfo:onReceiveChangePlatformFaceResponse(data)
	local response = protocol.loginServer.loginServer.account.s2c_pb.SetPlatformFace()
	response:ParseFromString(data)

	if response.code == 1 then
    	DataManager:getMyUserInfo().platformFace = self.temPlatformFace
    	self:setHeadFileMD5(self.temPlatformFace)
    	self:setUserInfoChange(true)
    else
    	
    end
end
function AccountInfo:onReceiveSetBindingInfoResponse(data)
	local response = protocol.loginServer.loginServer.account.s2c_pb.SetBindingInfo()
	response:ParseFromString(data)

	if response.code == 1 then
		BindMobilePhone = true
		cc.UserDefault:getInstance():setBoolForKey("isBindMobile", true)
		print("BindMobilePhone",cc.UserDefault:getInstance():getBoolForKey("isBindMobile"))
    	self:setBindingInfo(true)
    else
    	
    end
end
function AccountInfo:initData()
	BindTool.register(self, "tokenId", 0)
	BindTool.register(self, "sessionId", 0)
	BindTool.register(self, "cy_userId", 0)--统一平台userID,取自定义头像的请求用这个ID
	BindTool.register(self, "userId", 0)
	BindTool.register(self, "gameId", 0)
	BindTool.register(self, "nickName", "")
	BindTool.register(self, "underwrite", 0)
	BindTool.register(self, "faceId", 0)
	BindTool.register(self, "headFileMD5", 0)
	BindTool.register(self, "gender", 0)
	BindTool.register(self, "memberOrder", 0)
	BindTool.register(self, "signature", 0)	
	BindTool.register(self, "score", 0)
	BindTool.register(self, "insure", 0)
	BindTool.register(self, "experience", 0)
	BindTool.register(self, "medal", 0)
	BindTool.register(self, "loveLiness", 0)
	BindTool.register(self, "userRight", 0)
	BindTool.register(self, "gift", 0)
	BindTool.register(self, "grade", 0)
	BindTool.register(self, "present", 0) --UU游戏的用户的奖牌数
	BindTool.register(self, "isRegister", false)

	BindTool.register(self, "isNickNameValid", true)--检查用户名是否合法

	BindTool.register(self, "winCount", 0)
	BindTool.register(self, "lostCount", 0)
	BindTool.register(self, "drawCount", 0)
	BindTool.register(self, "fleeCount", 0)

	BindTool.register(self, "loginResult", 0)
	BindTool.register(self, "userInfoAccount", nil)
	BindTool.register(self, "scoreInfoAccount", nil)
	BindTool.register(self, "bindingInfo", false)
	BindTool.register(self, "userInfoChange", false)
	-- self.tokenId = 0
	-- self.userId = 0 --用户 I D
	-- self.gameId = 0 --游戏 I D
	-- self.nickName = "" --用户昵称
	-- self.underwrite = "" --个性签名
	-- self.faceId = 1 --头像标识
	-- self.headFile = "" --自定义头像md5
	-- self.gender = 1 --用户性别
	-- self.memberOrder = 0 --会员等级
	-- self.score = 0 --用户金币
	-- self.insure = 0 --用户银行
	-- self.experience = 0 --经验数值
	-- self.medal = 0 --用户奖牌
	-- self.loveLiness = 0 --用户魅力
	-- self.gift = 0  --礼券数
	-- self.present = 0 --优优奖牌
	-- self.isRegister = false  --是否注册
end

return AccountInfo