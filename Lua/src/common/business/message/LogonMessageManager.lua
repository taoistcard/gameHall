LogonMessageManager = {}

local LogonMessageIO = require "business.message.LogonMessageIO"
local LogonMessage = require "business.message.LogonMessage"


function LogonMessageManager:init()
    --缓存的收到的推送的系统消息     ArrayList<LogonMessage>
    self.localMessage = {}
    -- 是否需要写文件
    self.isNeedWrite = false
end

-- 判断当前的消息是否已经存过文件了
function LogonMessageManager:isExistLogoMessage(dwID)
    local isExit = false
    if(self.localMessage == nil) then
        return isExit
    end
    for key, var in ipairs(self.localMessage) do
        if(tonumber(var:getMessageID()) == dwID ) then
            isExit = true
            break
        else
            isExit = false
        end
    end
    return isExit
end

-- 内存缓存文件插入
function LogonMessageManager:insertLocalMessage(logonMessage)
    self.isNeedWrite = true
    table.insert(self.localMessage,table.maxn(self.localMessage) + 1,logonMessage)
end

-- 将系统缓存的数据存到文件中
function LogonMessageManager:writeMessageToFile()
    if(self.isNeedWrite == false) then
        return
    end
    -- 如果需要写文件，将localMessage中的数据写到文件中
    local logonMessageIO = LogonMessageIO:new()
    logonMessageIO:write(self.localMessage)
    self.isNeedWrite = false
end

--清空本地缓存的系统消息
function LogonMessageManager:cleanSystemMessage()
    if (self.localMessage ~= nil) then
        cleanTable(self.localMessage)
    end
    -- 读取本地文件，将文件中的保存的消息缓存到内存中
    local logonMessageIO = LogonMessageIO:new()
    local index,myTable = logonMessageIO:read()
    if(myTable ~= null) then
        for key, var in ipairs(myTable) do
            -- print("读出来的文件中的消息每一行==",var)
            local split = stringSplit(var,",")
            -- 储存到一个LogonMessage中
            local msgItem = LogonMessage:new()
            msgItem.message.dwID = tonumber(split[1])
            msgItem.message.wType = tonumber(split[2])
            msgItem.message.dwUserID = split[3]
            msgItem.message.wYear = split[4]
            msgItem.message.wMonth = split[5]
            msgItem.message.wDayOfWeek = split[6]
            msgItem.message.wDay = split[7]
            msgItem.message.wHour = split[8]
            msgItem.message.wMinute = split[9]
            msgItem.message.wSecond = split[10]
            msgItem.message.wMilliseconds = split[11]
            msgItem.message.read = tonumber(split[12])
            msgItem.message.message = split[13]
            
            -- 添加到本地的localMsg中
            table.insert(self.localMessage,table.maxn(self.localMessage) + 1,msgItem)
        end
    end
end

-- 登录消息推送
function LogonMessageManager:insertLogoMessage(logonMessage)
    if(logonMessage.message.wType == CMD_LogonServer.E_MSG_TYPE_USER or -- 个人信息，进行数据库操作
        logonMessage.message.wType == CMD_LogonServer.E_MSG_TYPE_SYSTEM or -- 系统消息,进行数据库操作
        logonMessage.message.wType == CMD_LogonServer.E_MSG_NEWTYPE_SYSTEM) then -- 商城公告,进行数据库操作
        local needWrite = false
        -- 判断当前这条信息是否已经写过文件了, 如果该条消息已经写过了，就不写了
        if(self:isExistLogoMessage(logonMessage.message.dwID)) then
            needWrite = false
        else
            needWrite = true
        end
        -- 如果需要写文件的，添加到缓存数组中，然后待循环结束的时候判断是否需要写文件
        if(self.isNeedWrite or needWrite) then
            self:insertLocalMessage(logonMessage)
        end

    end
end

-- 获取用户信息
function LogonMessageManager:obtainMessages(type)
    local userArray = {}
    local info = PlayerInfo:getMyUserInfo()
    if(info == null) then
        return
    end
    -- 如果是获取系统消息
    if(type == CMD_LogonServer.E_MSG_TYPE_SYSTEM ) then  -- 系统消息
        for key, var in ipairs(self.localMessage) do
            if(CMD_LogonServer.E_MSG_TYPE_SYSTEM == tonumber(var:getType())) then
                table.insert(userArray,table.maxn(userArray) + 1,var)
            end
        end
    end
    -- 如果是获取个人消息
    if(type == CMD_LogonServer.E_MSG_TYPE_USER ) then  -- 个人消息
        for key, var in ipairs(self.localMessage) do
            --print(type(info:userID()),type(var:getUserID()))
            if( CMD_LogonServer.E_MSG_TYPE_USER == tonumber(var:getType())) then--info:userID() == var:getUserID() and
                table.insert(userArray,table.maxn(userArray) + 1,var)
            end
        end
    end
    -- 如果是获取商城消息
    if(type == CMD_LogonServer.E_MSG_NEWTYPE_SYSTEM ) then  -- 商城消息
        for key, var in ipairs(self.localMessage) do
            if(CMD_LogonServer.E_MSG_TYPE_USER == tonumber(var:getType())) then
                table.insert(userArray,table.maxn(userArray) + 1,var)
            end
        end
    end
    return userArray
end

-- 获取对应类型的未读用户信息总条数
function LogonMessageManager:countOfMessagesUnReadByType(type)
    local count = 0

    for key, var in ipairs(self.localMessage) do
        if(tonumber(var:getType()) == type and tonumber(var:getRead()) == 0) then
            count = count + 1
        end
    end
    return count
end

-- 获取未读用户信息总条数
function LogonMessageManager:countOfMessagesUnRead()
    local count = 0
    for key, var in ipairs(self.localMessage) do
        if(tonumber(var:getRead()) == 0) then
            count = count + 1
        end
    end
    return count
end

-- 更新用户信息的状态为已读
function LogonMessageManager:updateUserMeaasgeForReadState(messagetype,messageid)
    local success = false
    for key, var in ipairs(self.localMessage) do
        if(tonumber(var:getMessageID()) == messageid and tonumber(var:getType()) == messagetype) then
            var:setRead(1)
            success = true
            self.isNeedWrite = true
            break
        end
    end
    -- 修改本地文件
    LogonMessageManager:writeMessageToFile()
    return success
end

-- 查询当前消息是否已读
function LogonMessageManager:queryMeaasgeForReadState(messagetype,messageid)
    local state = 0
    for key, var in ipairs(self.localMessage) do
        if(tonumber(var:getMessageID()) == messageid and tonumber(var:getType()) == messagetype) then
            state = var:getRead()
            break
        end
    end
    return state
end
LogonMessageManager:init()