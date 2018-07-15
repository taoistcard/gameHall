local DataManager = class("DataManager");

function DataManager:ctor()
	self:initDatas();
	self:bindEvent();
end

function DataManager:bindEvent()

    self.bindIds = {}
    self.bindIds[#self.bindIds + 1] = BindTool.bind(RoomInfo, "userInfo", handler(self, self.refreshUserInfo));
    self.bindIds[#self.bindIds + 1] = BindTool.bind(RoomInfo, "userInfoList", handler(self, self.refreshUserInfoList));
    self.bindIds[#self.bindIds + 1] = BindTool.bind(TableInfo, "userStatus", handler(self, self.refreshUserStatus));
    self.bindIds[#self.bindIds + 1] = BindTool.bind(RoomInfo, "tableStatus", handler(self, self.refreshTableStatus));
    self.bindIds[#self.bindIds + 1] = BindTool.bind(RoomInfo, "tableStatusList", handler(self, self.refreshTableStatuList));
    self.bindIds[#self.bindIds + 1] = BindTool.bind(AccountInfo, "userInfoAccount", handler(self, self.refreshMyUserInfo));
    self.bindIds[#self.bindIds + 1] = BindTool.bind(AccountInfo, "score", handler(self, self.refreshMyScore));
	self.bindIds[#self.bindIds + 1] = BindTool.bind(AccountInfo, "insure", handler(self, self.refreshMyInsure));
    self.bindIds[#self.bindIds + 1] = BindTool.bind(AccountInfo, "scoreInfoAccount", handler(self, self.refreshMyUserScoreInfo));
    self.bindIds[#self.bindIds + 1] = BindTool.bind(AccountInfo, "bindingInfo", handler(self, self.refreshBindingInfo));
    self.bindIds[#self.bindIds + 1] = BindTool.bind(AccountInfo, "present", handler(self, self.refreshPresentInfo));

end

function DataManager:unBindEvent()
    for _, bindid in ipairs(self.bindIds) do
        BindTool.unbind(bindid)
    end
end

function DataManager:initDatas()
	self.allUserInfo = {};
	self.myUserInfo = require("datamodel.struct.UserInfo").new()--nil;
	self.tableInfo = {};
	BindTool.register(self, "tabelInfoChange", false);

	self.allTableStatus = {}
	BindTool.register(self, "tabelStatuChange", false);

	self.changeUserInfo = nil
	BindTool.register(self, "changeUser", false);

end

function DataManager:refreshBindingInfo()
	-- body
	print("bindingInfo",AccountInfo.bindingInfo)
end

function DataManager:refreshTableStatus(event)
	local flag = false
	for _, tastatus in ipairs(self.allTableStatus) do
		if tastatus.tableID == RoomInfo.tableStatus.tableID then
			for key, value in pairs(RoomInfo.tableStatus) do
				tastatus[key] = value
			end
			flag = true
			break
		end
	end

	if flag == false then
		table.insert(self.allTableStatus, RoomInfo.tableStatus)
	end
	-- print("setTabelStatuChange")
	self:setTabelStatuChange(true)
end

function DataManager:refreshTableStatuList(event)
	self.allTableStatus = RoomInfo.tableStatusList
	self:setTabelStatuChange(true)
end

function DataManager:refreshMyScore()
	if self.myUserInfo then
		self.myUserInfo.score = AccountInfo.score
	end
end

function DataManager:refreshMyInsure()
	if self.myUserInfo then
		self.myUserInfo.insure = AccountInfo.insure
	end
end

function DataManager:refreshMyUserInfo()
	-- print(" AccountInfo.userInfoAccount", AccountInfo.userInfoAccount,tostring(AccountInfo.userInfoAccount))
	if self.myUserInfo == nil then
		-- self.myUserInfo = AccountInfo.userInfoAccount
		print("self.myUserInfo == nil")
	else
		-- for k,v in pairs(AccountInfo.userInfoAccount) do
		-- 	print(k,v)
		-- 	self.myUserInfo[k] = v
		-- end
		local data = AccountInfo.userInfoAccount
	    for k,v in pairs(self.myUserInfo) do
	        -- print("UserScoreInfo",k,v)
	        if data[k] then
	            self.myUserInfo[k] = data[k]
	        else
 
	        end
	        
	    end
	end
end

function DataManager:refreshPresentInfo()
	-- print(" AccountInfo.scoreInfoAccount", AccountInfo.scoreInfoAccount,tostring(AccountInfo.scoreInfoAccount))
	if self.myUserInfo == nil then
		-- self.myUserInfo = AccountInfo.userInfoAccount
		print("self.myUserInfo == nil")
	else
		self.myUserInfo.present = AccountInfo.present
	end
end

function DataManager:refreshMyUserScoreInfo()
	-- print(" AccountInfo.scoreInfoAccount", AccountInfo.scoreInfoAccount,tostring(AccountInfo.scoreInfoAccount))
	if self.myUserInfo == nil then
		-- self.myUserInfo = AccountInfo.userInfoAccount
		print("self.myUserInfo == nil")
	else
		local data = AccountInfo.scoreInfoAccount
	    for k,v in pairs(self.myUserInfo) do
	        -- print("UserScoreInfo",k,v)
	        if data[k] then
	            
	            self.myUserInfo[k] = data[k]
	        else
 
	        end
	        
	    end
	end

end

function DataManager:cleanAllUserInfo()
	print("DataManager:cleanAllUserInfo!")
	self.allUserInfo = {}
	self.myUserInfo = {}
end

function DataManager:refreshUserInfo(event)
	-- print("新玩家进入:",RoomInfo.userInfo.userID,RoomInfo.userInfo.score,RoomInfo.userInfo.nickName)
	if RoomInfo.userInfo.userID == AccountInfo.userId then
		self.myUserInfo = RoomInfo.userInfo
	end

	local flag = false
	for _, user in ipairs(self.allUserInfo) do
		if user.userID == RoomInfo.userInfo.userID then
			for key, value in pairs(RoomInfo.userInfo) do
				user[key] = value
			end
			flag = true
			break
		end
	end
	-- print("新玩家进入:",flag)
	if flag == false then
		table.insert(self.allUserInfo, RoomInfo.userInfo)
	end
	self:refreshTabelInfo()

	self:refreshOnePlayer(RoomInfo.userInfo)
end

function DataManager:refreshUserInfoList(event)
	-- print("测试......DataManager......",#self.allUserInfo,#RoomInfo.userInfoList)
	
    --测试数据 对比桌子上数据变化 请勿删除!!!!!!
	-- for i,v in ipairs(self.allUserInfo) do
	-- 	if v.tableID == 1 and v.tableID ~= 65535 then
	--         local name = v.nickName
	--         if string.len(name) <= 0 then
	--             name = v.gameID
	--         end
	--         print("1---DataManager:refreshUserInfoList",v.chairID,name)
	-- 	end
	-- end
	-- for i,v in ipairs(RoomInfo.userInfoList) do
	-- 	if v.tableID == 1 and v.tableID ~= 65535 then
	--         local name = v.nickName
	--         if string.len(name) <= 0 then
	--             name = v.gameID
	--         end
	--         print("2---DataManager:refreshUserInfoList",v.chairID,name)
	-- 	end
	-- end

	self.allUserInfo = RoomInfo.userInfoList
	table.insert(self.allUserInfo, self.myUserInfo)
	self:refreshTabelInfo();
end

function DataManager:getTableUserInfo(tableId)
	local tableInfo = {};
	for i,v in ipairs(self.allUserInfo) do
		if v.tableID == tableId and v.tableID ~= 65535 then
			table.insert(tableInfo,v);
		end
	end
	return tableInfo
end

function DataManager:refreshUserStatus(event)

	for _, user in ipairs(self.allUserInfo) do
		if user.userID == TableInfo.userStatus.userID then
			user.tableID = TableInfo.userStatus.tableID
			user.chairID = TableInfo.userStatus.chairID
			user.userStatus = TableInfo.userStatus.userStatus
			break
		end
	end

	self:refreshTabelInfo();
end

function DataManager:refreshTabelInfo()

	local tableInfo = {};
	for i,v in ipairs(self.allUserInfo) do
		if v.tableID == self.myUserInfo.tableID and v.tableID ~= 65535 then
			table.insert(tableInfo,v);
		end
	end
	self.tableInfo = tableInfo;
	self:setTabelInfoChange(true);

end
function DataManager:setAutoHallLogin(value)
	self.autoHallLogin = value
end
function DataManager:getAutoHallLogin()
	return self.autoHallLogin
end
function DataManager:setMyPlatformID(platformID)
	self.myUserInfo.platformID = platformID
end

function DataManager:getMyTableID()
	return self.myUserInfo.tableID
end

function DataManager:getMyChairID()
	return self.myUserInfo.chairID
end

function DataManager:getMyUserID()
	return self.myUserInfo.userID
end

function DataManager:getMyUserInfo()
	return self.myUserInfo
end

function DataManager:getMyUserStatus()
	return self.myUserInfo.userStatus
end

-- 通过用户ID返回用户信息
function DataManager:getUserInfoByUserID( nUserID)
    if (self.myUserInfo.userID == nUserID) then
        return self.myUserInfo,0
    end

    for key, var in ipairs(self.allUserInfo) do
        local userinfo = var
        if ((userinfo ~= nil) and (userinfo.userID == nUserID)) then
            return userinfo,key
        end
    end
    return nil,0
end

-- 通过本桌椅子ID返回用户信息--不包括旁观用户
function DataManager:getUserInfoInMyTableByChairID(chairID)
    for key, var in ipairs(self.allUserInfo) do
        if (var and var.tableID == self:getMyTableID() and var.chairID == chairID and var.userStatus ~= Define.US_LOOKON) then
            return var
        end
    end
    return nil
end

-- 通过本桌椅子ID返回用户信息--不包括旁观用户
function DataManager:getUserInfoInMyTableByChairIDExceptLookOn(chairID)
    for key, var in ipairs(self.allUserInfo) do
        if (var and var.tableID == self:getMyTableID() and var.chairID == chairID and var.userStatus ~= Define.US_LOOKON) then
            return var
        end
    end
    return nil
end

-- 通过选中桌椅子ID返回用户信息--不包括旁观用户和自己
function DataManager:getUserInfoInSelectedTableByChairIDExceptLookOn(selectTableID,chairID)
	-- print("self.allUserInfo",#self.allUserInfo)
    for key, var in ipairs(self.allUserInfo) do
    	-- print("tableID=",var.tableID,"chairID=",var.chairID,"userStatus=",var.userStatus,"userID=",var.userID)
        if (var and var.tableID == selectTableID and var.chairID == chairID and var.userStatus ~= Define.US_LOOKON and var.userID~=self:getMyUserID()) then
            return var
        end
    end
    return nil
end

function DataManager:getPlayerUserInMyTable()
    local tableIDArray = {}
    for key, var in ipairs(self.allUserInfo) do
        if (var and var.tableID == self:getMyTableID()) then
            table.insert(tableIDArray,table.maxn(tableIDArray) + 1,var)
        end
    end
    -- 排序
    if (table.maxn(tableIDArray) > 2) then
        table.sort(tableIDArray,function(x,y) return x.score > y.score end)
    end
    return tableIDArray
end

function DataManager:setUserScore(userScore) -- CMD_GR_UserScore
    local pUserInfo,index = self:getUserInfoByUserID(userScore.userID)
    if (pUserInfo ==nil) then
        pUserInfo = require("datamodel.struct.UserInfo").new()
        --todo
        table.insert(self.allUserInfo, pUserInfo)
        return
    end
    self:copyUserScoreToUserInfoStruct(userScore,pUserInfo)
    self:refreshOnePlayer(userScore)
end

--刷新和我同桌的玩家的分数情况
function DataManager:refreshOnePlayer(userScore)
	for i,v in ipairs(self.tableInfo) do
		if v.userID == userScore.userID then
			--只刷新这一个人的信息
			self.changeUserInfo = userScore
			-- dump(self.changeUserInfo,"self.changeUserInfo")
			self:setChangeUser(true)
			break
		end
	end
end

function DataManager:copyUserScoreToUserInfoStruct(pUserScore,pUserInfo)
    pUserInfo.userID = pUserScore.userID

    pUserInfo.score = pUserScore.score

    pUserInfo.grade = pUserScore.grade
    pUserInfo.insure = pUserScore.insure
   
    pUserInfo.winCount = pUserScore.winCount
    pUserInfo.lostCount = pUserScore.lostCount
    pUserInfo.drawCount = pUserScore.drawCount
    pUserInfo.fleeCount = pUserScore.fleeCount
    
    pUserInfo.medal = pUserScore.medal
    pUserInfo.experience = pUserScore.experience
    pUserInfo.loveLiness = pUserScore.loveliness--服务端的两个数据结构里的这个字段大小写不统一（卧槽）
end

--根据serverID获取知道比赛场的信息
function DataManager:getMatchConfigItemByServerID(serverID)
	local serverInfo = nil
	for i,v in ipairs(ServerInfo.matchConfigList) do
		if v.serverID == serverID then
			serverInfo = v
		end
	end
	return serverInfo
end

return DataManager;