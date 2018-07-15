local LogonMessageIO = class("LogonMessageIO")

function LogonMessageIO:ctor()
    self.logonMessageFilePath = "local_message.ini"
end

-- 存数据
function LogonMessageIO:write(localMessage)
    local myFile = io.open(self.logonMessageFilePath, "w+")
    if myFile ~= nil then
        -- 将每一个LogonMessage的字段组合到一个string中，以逗号分割
        for key, var in ipairs(localMessage) do
            if(key > 1) then
                myFile:write(string.char (10))
            end

            local stringFormat = string.format("%d,%s,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%s",
                var.message.dwID,
                var.message.wType,
                var.message.dwUserID,
                var.message.wYear,
                var.message.wMonth,
                var.message.wDayOfWeek,
                var.message.wDay,
                var.message.wHour,
                var.message.wMinute,
                var.message.wSecond,
                var.message.wMilliseconds,
                var.message.read,
                var.message.message)
            myFile:write(stringFormat)
        end
        io.close(myFile)
    end
end

-- 读数据
function LogonMessageIO:read()
    local index = 0
    local myLines = {}
    local myFile = io.open(self.logonMessageFilePath, "r")
    if(myFile == null) then
        return index,null
    end
    local myLines = {}
    for line in io.lines(string.format("%s%s", "./",self.logonMessageFilePath)) do
        index = index + 1
        myLines[index] = line
    end
    io.close(myFile)
    return index, myLines --返回文件的行数和一个包括所有行的表
end

return LogonMessageIO