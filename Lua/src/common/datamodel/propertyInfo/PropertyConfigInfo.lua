PropertyConfigInfo = {}

local PropertyObject = require("datamodel.propertyInfo.PropertyObject")

function PropertyConfigInfo:init()
    self._propertyInfoArray = {}
end

function PropertyConfigInfo:parseAndSavePropertyConfigInfo(pConfigProperty)
    local propertyCount = pConfigProperty.cbPropertyCount
    self:clearPropertyInfoArray()

    for key, var in ipairs(pConfigProperty.PropertyInfo) do
        local bean = PropertyObject.new()
        bean:setIndex(var.wIndex)
        bean:setDiscount(var.wDiscount)
        bean:setIssueArea(var.wIssueArea)
        bean:setPropertyGold(var.lPropertyGold)
        bean:setPropertyCash(var.dPropertyCash)
        bean:setSendLoveLiness(var.lSendLoveLiness)
        bean:setRecvLoveLiness(var.lRecvLoveLiness)
        -- print("wIndex",var.wIndex,"wDiscount",var.wDiscount,"wIssueArea",var.wIssueArea,"lPropertyGold",var.lPropertyGold,"lSendLoveLiness",var.lSendLoveLiness,"lRecvLoveLiness",var.lRecvLoveLiness)
        table.insert(self._propertyInfoArray,key,bean)
    end
end

function PropertyConfigInfo:parseAndSavePropertyConfigInfoNew(list)

    self:clearPropertyInfoArray()

    for key, var in ipairs(list) do
        local bean = PropertyObject.new()
        bean:setIndex(var.id)
        bean:setDiscount(var.discount)
        bean:setIssueArea(0)
        bean:setPropertyGold(var.propertyGold)
        bean:setPropertyCash(0)
        bean:setSendLoveLiness(var.sendLoveLiness)
        bean:setRecvLoveLiness(var.recvLoveLiness)
        -- print("var.id",var.id,"var.discount",var.discount,"var.propertyGold",var.propertyGold,"var.sendLoveLiness",var.sendLoveLiness,"var.recvLoveLiness",var.recvLoveLiness)
        table.insert(self._propertyInfoArray,key,bean)
    end
end

function PropertyConfigInfo:clearPropertyInfoArray()
    for i=#self._propertyInfoArray, 1, -1 do
        table.remove(self._propertyInfoArray,i)
    end
end

function PropertyConfigInfo:obtainPropertyobjectByIndex(index)
    for key, var in ipairs(self._propertyInfoArray) do
        if var:getIndex() == index then
            return var
        end
    end
    return nil
end

function PropertyConfigInfo:propertyCount()
    return #self._propertyInfoArray
end

PropertyConfigInfo:init()