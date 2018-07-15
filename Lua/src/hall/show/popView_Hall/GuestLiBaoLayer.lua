local GuestLiBaoLayer = class("GuestLiBaoLayer", require("show.popView_Hall.baseWindow"))

function GuestLiBaoLayer:ctor(param)
    self.super.ctor(self, 3);

    self:setNodeEventEnabled(true)
    
    self:createUI()
    self.kind = param

end

function GuestLiBaoLayer:onEnter()
    self:onClickTab(self.kind)
end

function GuestLiBaoLayer:onExit()
end

function GuestLiBaoLayer:createUI()
    local bgSprite = self.bgSprite  
    self.container1 = display.newNode():addTo(bgSprite,3)
    self.container2 = display.newNode():addTo(bgSprite,3)
end

function GuestLiBaoLayer:getTodayWasNotPaySuccess(event)
    local info = protocol.hall.treasureInfo_pb.CMD_GP_QueryTodayWasnotPayResult_Pro();
    info:ParseFromString(event.data)

    if info.dwWasTodayPayed == 1 then
        self:close()
    end
end

function GuestLiBaoLayer:onClickTab(index)
    if index == 1 then
        if device.platform == "android" then
            self:refreshTabNewGusetAndroid()
        else
            self:refreshTabNewGusetIOS()
        end
    else
        if device.platform == "android" then
            self:refreshTabDailyChargeAndroid()
        else
            self:refreshTabDailyChargeIOS()
        end
    end

end

function GuestLiBaoLayer:getLiBaoAnimation()
    local name = "anniu_tongyong"

    local filePath = "hallEffect/anniu_tongyong/"..name..".ExportJson"
    local imagePath = "hallEffect/anniu_tongyong/"..name.."0.png"
    local plistPath = "hallEffect/anniu_tongyong/"..name.."0.plist"
    
    local manager = ccs.ArmatureDataManager:getInstance()
    if manager:getAnimationData(name) == nil then
        manager:addArmatureFileInfo(imagePath,plistPath,filePath)
    end
    local armature = ccs.Armature:create(name)
    armature:getAnimation():playWithIndex(0)

    return armature;

end

function GuestLiBaoLayer:refreshTabNewGusetAndroid()

    self.container1:removeAllChildren()
    self.container1:show()
    self.container2:hide()

    local exchange = ccui.Button:create("hall/dailyGold/btn_charge.png","hall/dailyGold/btn_charge.png");
    exchange:setPosition(cc.p(360,78));
    exchange:addTo(self.container1,1)
    exchange:setPressedActionEnabled(true);
    exchange:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:onClickGetGift()
            end
        end
    )

    --title
    local bgTitle = display.newSprite("hall/firstCharge/title.png"):addTo(self.container1,1):align(display.CENTER, 375, 505)

    --items
    display.newSprite("hall/firstCharge/tip_01_yuan.png"):addTo(self.container1,1):align(display.LEFT_CENTER, 80, 415)
    display.newSprite("hall/firstCharge/bg2.png"):addTo(self.container1,1):align(display.CENTER, 368, 300)
    display.newSprite("hall/firstCharge/item2.png"):addTo(self.container1,1):align(display.CENTER, 368, 300)
    
    --金币数量
    local goldTxt = ccui.Text:create("1万金币","fonts/FZPTYJW.TTF",28)
    goldTxt:setFontSize(26)
    goldTxt:setAnchorPoint(cc.p(0,0.5))
    goldTxt:setColor(cc.c4b(0xfe, 0xff, 0x79,255))
    goldTxt:enableOutline(cc.c4b(0x3d,0x1b,0x02,255), 2)
    goldTxt:addTo(self.container1,1):align(display.CENTER, 368, 205)

end

function GuestLiBaoLayer:refreshTabDailyChargeAndroid()

    self.container1:removeAllChildren()
    self.container1:show()
    self.container2:hide()

    local exchange = ccui.Button:create("hall/dailyGold/btn_charge.png","hall/dailyGold/btn_charge.png");
    exchange:setPosition(cc.p(360,78));
    exchange:addTo(self.container1,1)
    exchange:setPressedActionEnabled(true);
    exchange:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:onClickGetGift()
            end
        end
    )

    --title
    local bgTitle = display.newSprite("hall/dailyGold/title_xinshou.png"):addTo(self.container1,1):align(display.CENTER, 375, 505)

    --items
    display.newSprite("hall/dailyGold/tip_12_yuan.png"):addTo(self.container1,1):align(display.LEFT_CENTER, 80, 415)
    display.newSprite("hall/firstCharge/bg2.png"):addTo(self.container1,1):align(display.CENTER, 225, 300)
    display.newSprite("hall/dailyGold/jb.png"):addTo(self.container1,1):align(display.CENTER, 225, 300)
    display.newSprite("hall/dailyGold/jia.png"):addTo(self.container1,1):align(display.CENTER, 368, 300)
    local zuanSprite = display.newSprite("shop/zuan1.png"):addTo(self.container1,1):align(display.CENTER, 430, 350)
    zuanSprite:setScale(0.74)
    display.newSprite("hall/firstCharge/bg2.png"):addTo(self.container1,1):align(display.CENTER, 510, 300)
    display.newSprite("hall/dailyGold/jb.png"):addTo(self.container1,1):align(display.CENTER, 510, 300)
    -- display.newSprite("hall/shop/zuan1.png"):addTo(self.container1,1):align(display.CENTER, 580, 330)

    --金币数量
    local couponTxt = ccui.Text:create("5万金币","fonts/FZPTYJW.TTF",28)
    couponTxt:setFontSize(26)
    couponTxt:setAnchorPoint(cc.p(0,0.5))
    couponTxt:setColor(cc.c4b(0xfe, 0xff, 0x79,255))
    couponTxt:enableOutline(cc.c4b(0x3d,0x1b,0x02,255), 2)
    couponTxt:addTo(self.container1,1):align(display.CENTER, 225, 205)

    --金币数量
    local goldTxt = ccui.Text:create("加送5万金币","fonts/FZPTYJW.TTF",28)
    goldTxt:setFontSize(26)
    goldTxt:setAnchorPoint(cc.p(0,0.5))
    goldTxt:setColor(cc.c4b(0xfe, 0xff, 0x79,255))
    goldTxt:enableOutline(cc.c4b(0x3d,0x1b,0x02,255), 2)
    goldTxt:addTo(self.container1,1):align(display.CENTER, 510, 205)

end

function GuestLiBaoLayer:refreshTabNewGusetIOS()

    self.container1:removeAllChildren()
    self.container1:show()
    self.container2:hide()
   
    local exchange = ccui.Button:create("hall/dailyGold/btn_charge.png","hall/dailyGold/btn_charge.png");
    exchange:setPosition(cc.p(360,78));
    exchange:addTo(self.container1,1)
    exchange:setPressedActionEnabled(true);
    exchange:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:onClickGetGift()
            end
        end
    )

    --title
    local bgTitle = display.newSprite("hall/firstCharge/title.png"):addTo(self.container1,1):align(display.CENTER, 375, 505)

    --items
    display.newSprite("hall/firstCharge/tip_1_yuan.png"):addTo(self.container1,1):align(display.LEFT_CENTER, 80, 415)
    display.newSprite("hall/firstCharge/bg2.png"):addTo(self.container1,1):align(display.CENTER, 225, 300)
    display.newSprite("hall/firstCharge/item1.png"):addTo(self.container1,1):align(display.CENTER, 225, 300)
    display.newSprite("hall/dailyGold/jia.png"):addTo(self.container1,1):align(display.CENTER, 368, 300)
    local zuanSprite = display.newSprite("shop/zuan1.png"):addTo(self.container1,1):align(display.CENTER, 430, 350)
    zuanSprite:setScale(0.74)
    display.newSprite("hall/firstCharge/bg2.png"):addTo(self.container1,1):align(display.CENTER, 510, 300)
    display.newSprite("hall/firstCharge/item2.png"):addTo(self.container1,1):align(display.CENTER, 510, 300)

    --金币数量
    local couponTxt = ccui.Text:create("5千金币","fonts/FZPTYJW.TTF",28)
    couponTxt:setFontSize(26)
    couponTxt:setAnchorPoint(cc.p(0,0.5))
    couponTxt:setColor(cc.c4b(0xfe, 0xff, 0x79,255))
    couponTxt:enableOutline(cc.c4b(0x3d,0x1b,0x02,255), 2)
    couponTxt:addTo(self.container1,1):align(display.CENTER, 225, 205)

    --金币数量
    local goldTxt = ccui.Text:create("加送2万金币","fonts/FZPTYJW.TTF",28)
    goldTxt:setFontSize(26)
    goldTxt:setAnchorPoint(cc.p(0,0.5))
    goldTxt:setColor(cc.c4b(0xfe, 0xff, 0x79,255))
    goldTxt:enableOutline(cc.c4b(0x3d,0x1b,0x02,255), 2)
    goldTxt:addTo(self.container1,1):align(display.CENTER, 510, 205)

end

function GuestLiBaoLayer:refreshTabDailyChargeIOS()

    self.container1:removeAllChildren()
    self.container1:show()
    self.container2:hide()

    local exchange = ccui.Button:create("hall/dailyGold/btn_charge.png","hall/dailyGold/btn_charge.png");
    exchange:setPosition(cc.p(360,78));
    exchange:addTo(self.container1,1)
    exchange:setPressedActionEnabled(true);
    exchange:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:onClickGetGift()
            end
        end
    )

    --title
    local bgTitle = display.newSprite("hall/dailyGold/title_xinshou.png"):addTo(self.container1,1):align(display.CENTER, 375, 505)

    --items
    display.newSprite("hall/dailyGold/tip_12_yuan.png"):addTo(self.container1,1):align(display.LEFT_CENTER, 80, 415)
    display.newSprite("hall/firstCharge/bg2.png"):addTo(self.container1,1):align(display.CENTER, 225, 300)
    display.newSprite("hall/dailyGold/jb.png"):addTo(self.container1,1):align(display.CENTER, 225, 300)
    display.newSprite("hall/dailyGold/jia.png"):addTo(self.container1,1):align(display.CENTER, 368, 300)
    local zuanSprite = display.newSprite("shop/zuan1.png"):addTo(self.container1,1):align(display.CENTER, 430, 350)
    zuanSprite:setScale(0.74)
    display.newSprite("hall/firstCharge/bg2.png"):addTo(self.container1,1):align(display.CENTER, 510, 300)
    display.newSprite("hall/dailyGold/jb.png"):addTo(self.container1,1):align(display.CENTER, 510, 300)

    --金币数量
    local couponTxt = ccui.Text:create("6万金币","fonts/FZPTYJW.TTF",28)
    couponTxt:setFontSize(26)
    couponTxt:setAnchorPoint(cc.p(0,0.5))
    couponTxt:setColor(cc.c4b(0xfe, 0xff, 0x79,255))
    couponTxt:enableOutline(cc.c4b(0x3d,0x1b,0x02,255), 2)
    couponTxt:addTo(self.container1,1):align(display.CENTER, 225, 205)

    --金币数量
    local goldTxt = ccui.Text:create("加送6万金币","fonts/FZPTYJW.TTF",28)
    goldTxt:setFontSize(26)
    goldTxt:setAnchorPoint(cc.p(0,0.5))
    goldTxt:setColor(cc.c4b(0xfe, 0xff, 0x79,255))
    goldTxt:enableOutline(cc.c4b(0x3d,0x1b,0x02,255), 2)
    goldTxt:addTo(self.container1,1):align(display.CENTER, 510, 205)

end

function GuestLiBaoLayer:close()
    self:removeSelf();
end

function GuestLiBaoLayer:onClickGetGift()

    --index 7 首充礼包
    --index 8 新手礼包

    if self.kind == 1 then--首充礼包
        local chargeLayer = require("show.popView_Hall.ChooseChargeLayer").new({index=7})
        chargeLayer:addTo(self)
    elseif self.kind == 2 then--新手礼包
        local chargeLayer = require("show.popView_Hall.ChooseChargeLayer").new({index=8})
        chargeLayer:addTo(self)
    end
end

return GuestLiBaoLayer