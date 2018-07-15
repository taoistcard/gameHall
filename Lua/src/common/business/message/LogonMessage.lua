local LogonMessage = class("LogonMessage")

function LogonMessage:ctor()
    self.message = {
        self.dwID,
        self.wType,
        self.dwUserID,

        self.wYear,
        self.wMonth,
        self.wDayOfWeek,
        self.wDay,
        self.wHour,
        self.wMinute,
        self.wSecond,
        self.wMilliseconds,

        self.read,

        self.message
    }
end

function LogonMessage:getMessageID()
    return self.message.dwID
end

function LogonMessage:getUserID()
    return self.message.dwUserID
end

function LogonMessage:getType()
    return self.message.wType
end

function LogonMessage:getRead()
    return self.message.read
end

function LogonMessage:setRead(state)
    self.message.read = state
end
function LogonMessage:setMessage(message)
    self.message.message = message
end
function LogonMessage:getMessage()
    return self.message.message
end
return LogonMessage