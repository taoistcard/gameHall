--新手礼包（首充礼包）／每日礼包
local GuestLiBaoLayer = class("GuestLiBaoLayer", function() return display.newLayer() end)

function GuestLiBaoLayer:ctor(param)
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
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
    local displaySize = cc.size(display.width, display.height);
    local winSize = cc.Director:getInstance():getWinSize();
    -- 蒙板
    local maskLayer = ccui.ImageView:create("black.png");
    maskLayer:setScale9Enabled(true);
    maskLayer:setContentSize(cc.size(winSize.width, winSize.height));
    maskLayer:setPosition(cc.p(displaySize.width / 2, displaySize.height / 2));
    maskLayer:setTouchEnabled(true);
    maskLayer:addTo(self);
   

    local bgSprite = display.newSprite("hallScene/exchange/bg.jpg"):pos(winSize.width/2, winSize.height/2+20)
    bgSprite:addTo(maskLayer)

    --top
    local scaleValue = 0.7
    display.newSprite("hallScene/dailyGold/top1.png"):addTo(bgSprite,1):align(display.CENTER, 297, -20):scale(scaleValue)
    
    --frame
    display.newSprite("hallScene/dailyGold/frame.png"):addTo(bgSprite):align(display.BOTTOM_RIGHT, 297, -20):flipY(true):scale(scaleValue)
    display.newSprite("hallScene/dailyGold/frame.png"):addTo(bgSprite):align(display.BOTTOM_LEFT, 297, -20):flipX(true):flipY(true):scale(scaleValue)

    --新手礼包    
    self.container1 = display.newNode():addTo(bgSprite,3)

    --首充礼包
    self.container2 = display.newNode():addTo(bgSprite,3)

    --banner
    display.newSprite("hallScene/exchange/03.png"):addTo(bgSprite,2):align(display.CENTER, -30, 220)
    display.newSprite("hallScene/libao/banner6.png"):addTo(bgSprite,2):align(display.CENTER, 297, -10)
    display.newSprite("hallScene/libao/banner4.png"):addTo(bgSprite,2):align(display.CENTER, 150, -10)
    display.newSprite("hallScene/libao/banner5.png"):addTo(bgSprite,2):align(display.CENTER, 440, -10)


    --关闭按钮
    local exit = ccui.Button:create("common/hall_close.png");
    exit:setPosition(cc.p(614,299));
    exit:addTo(bgSprite,1)
    exit:setPressedActionEnabled(true);
    exit:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:close();
            end
        end
    )
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
            self:refreshTabFirstChargeAndroid()
        else
            self:refreshTabFirstChargeIOS()
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

    --banner
    display.newSprite("hallScene/libao/banner3.png"):addTo(self.container1,2):align(display.CENTER, -20, 30)
    display.newSprite("hallScene/libao/banner0.png"):addTo(self.container1,2):align(display.CENTER, 630, 125)


    local exchange = ccui.Button:create("hallScene/libao/btn_gift.png","hallScene/libao/btn_gift.png");
    exchange:setPosition(cc.p(297,10));
    exchange:addTo(self.container1,1)
    exchange:setPressedActionEnabled(true);
    exchange:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:onClickGetGift()
            end
        end
    )
    local animation = self:getLiBaoAnimation()
    local size = exchange:getContentSize()
    animation:setPosition(size.width/2, size.height/2)
    exchange:addChild(animation)

    --title
    local bgTitle = display.newSprite("hallScene/dailyGold/title_bg.png"):addTo(self.container1,1):align(display.CENTER, 297, 320)
    display.newSprite("hallScene/libao/title_sc.png"):addTo(self.container1,1):align(display.CENTER, 297, 320)
    display.newSprite("hallScene/exchange/title3.png"):addTo(self.container1,1):align(display.CENTER, 305, 330)

    display.newSprite("hallScene/libao/item01.png"):addTo(self.container1,1):align(display.CENTER_LEFT, 20, 240)
    
   --items
    display.newSprite("hallScene/libao/item_bg.png"):addTo(self.container1,1):align(display.CENTER, 160, 140)
    display.newSprite("hallScene/shop/gold1.png"):addTo(self.container1,1):align(display.CENTER, 160, 140)
    display.newSprite("hallScene/libao/item0.png"):addTo(self.container1,1):align(display.CENTER, 300, 140)
    display.newSprite("hallScene/libao/item_bg.png"):addTo(self.container1,1):align(display.CENTER, 440, 140)
    display.newSprite("hallScene/shop/gold2.png"):addTo(self.container1,1):align(display.CENTER, 440, 140)

    --金币数量
    local couponTxt = ccui.Text:create("500金币","fonts/HKBDTW12.TTF",24)
    couponTxt:setFontSize(26)
    couponTxt:setAnchorPoint(cc.p(0,0.5))
    couponTxt:setColor(cc.c4b(0xfe, 0xff, 0x79,255))
    couponTxt:enableOutline(cc.c4b(0x3d,0x1b,0x02,255), 2)
    couponTxt:addTo(self.container1,1):align(display.CENTER, 160, 80)

    --金币数量
    local goldTxt = ccui.Text:create("加送4500金币","fonts/HKBDTW12.TTF",24)
    goldTxt:setFontSize(26)
    goldTxt:setAnchorPoint(cc.p(0,0.5))
    goldTxt:setColor(cc.c4b(0xfe, 0xff, 0x79,255))
    goldTxt:enableOutline(cc.c4b(0x3d,0x1b,0x02,255), 2)
    goldTxt:addTo(self.container1,1):align(display.CENTER, 440, 90)

    -- if couponNum <= 0 then
    --     exchange:setEnabled(false)
    --     exchange:setBright(false)
    -- end
end

function GuestLiBaoLayer:refreshTabFirstChargeAndroid()

    self.container1:removeAllChildren()
    self.container1:show()
    self.container2:hide()

    --banner
    display.newSprite("hallScene/libao/banner1.png"):addTo(self.container1,2):align(display.CENTER, -20, 30)
    display.newSprite("hallScene/libao/banner2.png"):addTo(self.container1,2):align(display.CENTER, 630, 125)


    local exchange = ccui.Button:create("hallScene/libao/btn_gift.png","hallScene/libao/btn_gift.png");
    exchange:setPosition(cc.p(297,10));
    exchange:addTo(self.container1,1)
    exchange:setPressedActionEnabled(true);
    exchange:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:onClickGetGift()
            end
        end
    )
    local animation = self:getLiBaoAnimation()
    local size = exchange:getContentSize()
    animation:setPosition(size.width/2, size.height/2)
    exchange:addChild(animation)

    --title
    local bgTitle = display.newSprite("hallScene/dailyGold/title_bg.png"):addTo(self.container1,1):align(display.CENTER, 297, 320)
    display.newSprite("hallScene/libao/title_mr.png"):addTo(self.container1,1):align(display.CENTER, 297, 320)
    display.newSprite("hallScene/exchange/title3.png"):addTo(self.container1,1):align(display.CENTER, 305, 330)
    
    display.newSprite("hallScene/libao/item02.png"):addTo(self.container1,1):align(display.CENTER_LEFT, 20, 240)

    --items
    display.newSprite("hallScene/libao/item_bg.png"):addTo(self.container1,1):align(display.CENTER, 160, 140)
    display.newSprite("hallScene/shop/gold4.png"):addTo(self.container1,1):align(display.CENTER, 160, 140)
    display.newSprite("hallScene/libao/item0.png"):addTo(self.container1,1):align(display.CENTER, 300, 140)
    display.newSprite("hallScene/libao/item_bg.png"):addTo(self.container1,1):align(display.CENTER, 440, 140)
    display.newSprite("hallScene/shop/gold4.png"):addTo(self.container1,1):align(display.CENTER, 440, 140)

    --金币数量
    local couponTxt = ccui.Text:create("5万金币","fonts/HKBDTW12.TTF",24)
    couponTxt:setFontSize(26)
    couponTxt:setAnchorPoint(cc.p(0,0.5))
    couponTxt:setColor(cc.c4b(0xfe, 0xff, 0x79,255))
    couponTxt:enableOutline(cc.c4b(0x3d,0x1b,0x02,255), 2)
    couponTxt:addTo(self.container1,1):align(display.CENTER, 160, 80)

    --金币数量
    local goldTxt = ccui.Text:create("加送5万金币","fonts/HKBDTW12.TTF",24)
    goldTxt:setFontSize(26)
    goldTxt:setAnchorPoint(cc.p(0,0.5))
    goldTxt:setColor(cc.c4b(0xfe, 0xff, 0x79,255))
    goldTxt:enableOutline(cc.c4b(0x3d,0x1b,0x02,255), 2)
    goldTxt:addTo(self.container1,1):align(display.CENTER, 440, 90)

    --送vip
    display.newSprite("hallScene/shop/zuan1.png"):addTo(self.container1,1):align(display.CENTER, 530, 185)
    display.newSprite("hallScene/shop/vipWord.png"):addTo(self.container1,1):align(display.CENTER, 487, 192)
    local title = ccui.Text:create("送1天","fonts/HKBDTW12.TTF", 20)
    title:align(display.RIGHT_CENTER,555,155)
    title:setColor(cc.c4b(0xf7, 0x8f, 0x1d, 0xff))
    title:enableOutline(cc.c4b(0x4b, 0x03, 0x00, 0xff), 2)
    title:addTo(self.container1,1)

    -- if couponNum <= 0 then
    --     exchange:setEnabled(false)
    --     exchange:setBright(false)
    -- end
end

function GuestLiBaoLayer:refreshTabNewGusetIOS()

    self.container1:removeAllChildren()
    self.container1:show()
    self.container2:hide()

    --banner
    display.newSprite("hallScene/libao/banner3.png"):addTo(self.container1,2):align(display.CENTER, -20, 30)
    display.newSprite("hallScene/libao/banner0.png"):addTo(self.container1,2):align(display.CENTER, 630, 125)


    local exchange = ccui.Button:create("hallScene/libao/btn_gift.png","hallScene/libao/btn_gift.png");
    exchange:setPosition(cc.p(297,10));
    exchange:addTo(self.container1,1)
    exchange:setPressedActionEnabled(true);
    exchange:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:onClickGetGift()
            end
        end
    )
    local animation = self:getLiBaoAnimation()
    local size = exchange:getContentSize()
    animation:setPosition(size.width/2, size.height/2)
    exchange:addChild(animation)

    --title
    local bgTitle = display.newSprite("hallScene/dailyGold/title_bg.png"):addTo(self.container1,1):align(display.CENTER, 297, 320)
    display.newSprite("hallScene/libao/title_sc.png"):addTo(self.container1,1):align(display.CENTER, 297, 320)
    display.newSprite("hallScene/exchange/title3.png"):addTo(self.container1,1):align(display.CENTER, 305, 330)

    display.newSprite("hallScene/libao/item011.png"):addTo(self.container1,1):align(display.CENTER_LEFT, 20, 240)
    
    --items
    display.newSprite("hallScene/libao/item_bg.png"):addTo(self.container1,1):align(display.CENTER, 160, 140)
    display.newSprite("hallScene/shop/gold1.png"):addTo(self.container1,1):align(display.CENTER, 160, 140)
    display.newSprite("hallScene/libao/item0.png"):addTo(self.container1,1):align(display.CENTER, 300, 140)
    display.newSprite("hallScene/libao/item_bg.png"):addTo(self.container1,1):align(display.CENTER, 440, 140)
    display.newSprite("hallScene/shop/gold3.png"):addTo(self.container1,1):align(display.CENTER, 440, 140)
    display.newSprite("hallScene/libao/item2.png"):addTo(self.container1,1):align(display.CENTER, 400, 180)

    --金币数量
    local couponTxt = ccui.Text:create("5千金币","fonts/HKBDTW12.TTF",24)
    couponTxt:setFontSize(26)
    couponTxt:setAnchorPoint(cc.p(0,0.5))
    couponTxt:setColor(cc.c4b(0xfe, 0xff, 0x79,255))
    couponTxt:enableOutline(cc.c4b(0x3d,0x1b,0x02,255), 2)
    couponTxt:addTo(self.container1,1):align(display.CENTER, 160, 80)

    --金币数量
    local goldTxt = ccui.Text:create("加送2万金币","fonts/HKBDTW12.TTF",24)
    goldTxt:setFontSize(26)
    goldTxt:setAnchorPoint(cc.p(0,0.5))
    goldTxt:setColor(cc.c4b(0xfe, 0xff, 0x79,255))
    goldTxt:enableOutline(cc.c4b(0x3d,0x1b,0x02,255), 2)
    goldTxt:addTo(self.container1,1):align(display.CENTER, 440, 90)

    --送vip
    display.newSprite("hallScene/shop/zuan1.png"):addTo(self.container1,1):align(display.CENTER, 530, 185)
    display.newSprite("hallScene/shop/vipWord.png"):addTo(self.container1,1):align(display.CENTER, 487, 192)
    local title = ccui.Text:create("送1天","fonts/HKBDTW12.TTF", 20)
    title:align(display.RIGHT_CENTER,555,155)
    title:setColor(cc.c4b(0xf7, 0x8f, 0x1d, 0xff))
    title:enableOutline(cc.c4b(0x4b, 0x03, 0x00, 0xff), 2)
    title:addTo(self.container1,1)
    -- if couponNum <= 0 then
    --     exchange:setEnabled(false)
    --     exchange:setBright(false)
    -- end
end

function GuestLiBaoLayer:refreshTabFirstChargeIOS()

    self.container1:removeAllChildren()
    self.container1:show()
    self.container2:hide()

    --banner
    display.newSprite("hallScene/libao/banner1.png"):addTo(self.container1,2):align(display.CENTER, -20, 30)
    display.newSprite("hallScene/libao/banner2.png"):addTo(self.container1,2):align(display.CENTER, 630, 125)


    local exchange = ccui.Button:create("hallScene/libao/btn_gift.png","hallScene/libao/btn_gift.png");
    exchange:setPosition(cc.p(297,10));
    exchange:addTo(self.container1,1)
    exchange:setPressedActionEnabled(true);
    exchange:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:onClickGetGift()
            end
        end
    )
    local animation = self:getLiBaoAnimation()
    local size = exchange:getContentSize()
    animation:setPosition(size.width/2, size.height/2)
    exchange:addChild(animation)

    --title
    local bgTitle = display.newSprite("hallScene/dailyGold/title_bg.png"):addTo(self.container1,1):align(display.CENTER, 297, 320)
    display.newSprite("hallScene/libao/title_mr.png"):addTo(self.container1,1):align(display.CENTER, 297, 320)
    display.newSprite("hallScene/exchange/title3.png"):addTo(self.container1,1):align(display.CENTER, 305, 330)
    
    display.newSprite("hallScene/libao/item022.png"):addTo(self.container1,1):align(display.CENTER_LEFT, 20, 240)

    --items
    display.newSprite("hallScene/libao/item_bg.png"):addTo(self.container1,1):align(display.CENTER, 160, 140)
    display.newSprite("hallScene/shop/gold4.png"):addTo(self.container1,1):align(display.CENTER, 160, 140)
    display.newSprite("hallScene/libao/item0.png"):addTo(self.container1,1):align(display.CENTER, 300, 140)
    display.newSprite("hallScene/libao/item_bg.png"):addTo(self.container1,1):align(display.CENTER, 440, 140)
    display.newSprite("hallScene/shop/gold4.png"):addTo(self.container1,1):align(display.CENTER, 440, 140)
    display.newSprite("hallScene/libao/item2.png"):addTo(self.container1,1):align(display.CENTER, 400, 180)

    --金币数量
    local couponTxt = ccui.Text:create("6万金币","fonts/HKBDTW12.TTF",24)
    couponTxt:setFontSize(26)
    couponTxt:setAnchorPoint(cc.p(0,0.5))
    couponTxt:setColor(cc.c4b(0xfe, 0xff, 0x79,255))
    couponTxt:enableOutline(cc.c4b(0x3d,0x1b,0x02,255), 2)
    couponTxt:addTo(self.container1,1):align(display.CENTER, 160, 80)

    --金币数量
    local goldTxt = ccui.Text:create("加送6万金币","fonts/HKBDTW12.TTF",24)
    goldTxt:setFontSize(26)
    goldTxt:setAnchorPoint(cc.p(0,0.5))
    goldTxt:setColor(cc.c4b(0xfe, 0xff, 0x79,255))
    goldTxt:enableOutline(cc.c4b(0x3d,0x1b,0x02,255), 2)
    goldTxt:addTo(self.container1,1):align(display.CENTER, 440, 90)
    
    --送vip
    display.newSprite("hallScene/shop/zuan1.png"):addTo(self.container1,1):align(display.CENTER, 530, 185)
    display.newSprite("hallScene/shop/vipWord.png"):addTo(self.container1,1):align(display.CENTER, 487, 192)
    local title = ccui.Text:create("送1天","fonts/HKBDTW12.TTF", 20)
    title:align(display.RIGHT_CENTER,555,155)
    title:setColor(cc.c4b(0xf7, 0x8f, 0x1d, 0xff))
    title:enableOutline(cc.c4b(0x4b, 0x03, 0x00, 0xff), 2)
    title:addTo(self.container1,1)
    -- if couponNum <= 0 then
    --     exchange:setEnabled(false)
    --     exchange:setBright(false)
    -- end
end

function GuestLiBaoLayer:close()
    self:removeSelf();
end

function GuestLiBaoLayer:onClickGetGift()
    if self.kind == 1 then--首充礼包
        local chargeLayer = require("show_ddz.ChooseChargeLayer").new({index=7})
        chargeLayer:addTo(self)
    elseif self.kind == 2 then--新手礼包
        local chargeLayer = require("show_ddz.ChooseChargeLayer").new({index=8})
        chargeLayer:addTo(self)
    end

--[[
    if self.kind == 1 then--新手礼包
        if device.platform == "android" then
            AppPurcharse({channel=PurcharseConfig.ch_Other, product="394"})
        else
            AppPurcharse({channel=PurcharseConfig.ch_Apple, product="385"})
        end

    elseif self.kind == 2 then--每日充值
        if device.platform == "android" then
            AppPurcharse({channel=PurcharseConfig.ch_Other, product="393"})
        else
            AppPurcharse({channel=PurcharseConfig.ch_Apple, product="386"})
        end
    end
]]

end

return GuestLiBaoLayer