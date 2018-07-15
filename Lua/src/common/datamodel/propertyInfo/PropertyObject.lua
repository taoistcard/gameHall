local PropertyObject = class("PropertyObject")

function PropertyObject:ctor()
    --道具信息
    self._index = 0                          --道具标识
    self._discount = 0                       --会员折扣
    self._issueArea = 0                      --发布范围
    
    --销售价格
    self._propertyGold = 0                   --道具金币
    self._propertyCash = 0                   --道具价格
    
    --赠送魅力
    self._sendLoveLiness = 0                 --赠送魅力
    self._recvLoveLiness = 0                 --接受魅力
end

function PropertyObject:getIndex()
    return self._index
end

function PropertyObject:setIndex(index)
    self._index = index
end

function PropertyObject:getDiscount()
    return self._discount
end

function PropertyObject:setDiscount(discount)
    self._discount = discount
end

function PropertyObject:getIssueArea()
    return self._issueArea
end

function PropertyObject:setIssueArea(issueArea)
    self._issueArea = issueArea
end

function PropertyObject:getPropertyGold()
    return self._propertyGold
end

function PropertyObject:setPropertyGold(propertyGold)
    self._propertyGold = propertyGold
end

function PropertyObject:getPropertyCash()
    return self._propertyCash
end

function PropertyObject:setPropertyCash(propertyCash)
    self._propertyCash = propertyCash
end

function PropertyObject:getSendLoveLiness()
    return self._sendLoveLiness
end

function PropertyObject:setSendLoveLiness(sendLoveLiness)
    self._sendLoveLiness = sendLoveLiness
end

function PropertyObject:getRecvLoveLiness()
    return self._recvLoveLiness
end

function PropertyObject:setRecvLoveLiness(recvLoveLiness)
    self._recvLoveLiness = recvLoveLiness
end
return PropertyObject