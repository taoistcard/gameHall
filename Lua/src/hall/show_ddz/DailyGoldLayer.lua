--每日金币
local DailyGoldLayer = class("DailyGoldLayer", function() return display.newLayer() end)

function DailyGoldLayer:ctor()
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    self:setNodeEventEnabled(true)
    self.itemInfo = {
        valide = {0,0,0,0,0},
        valideDay = {0,0,0,0,0},
        valideTimes = {0,1,1,1,1},
        gold = {"8000金币", "3.4万金币", "6.6万金币", "13.2万金币", "33万金币"},
        itemIcon = {"hallScene/shop/gold1.png", "hallScene/shop/gold2.png", "hallScene/shop/gold3.png", "hallScene/shop/gold4.png", "hallScene/shop/gold5.png",},
        viplevel = {"hallScene/shop/zuan1.png", "hallScene/shop/zuan2.png", "hallScene/shop/zuan3.png", "hallScene/shop/zuan4.png", "hallScene/shop/zuan5.png"},
        vip = "hallScene/shop/vipWord.png"}

	self:createUI()
end

function DailyGoldLayer:onEnter()
    self.handlerVOUCHEREXCHANGE = UserService:addEventListener(HallCenterEvent.EVENT_QUERYVIPWAGERECEIVETIMES,handler(self, self.eventQueryVipWage))
    self.handlerQUERYRECORDVOUCHEREXCHANGE = UserService:addEventListener(HallCenterEvent.EVENT_VIPWAGERECEIVE,handler(self, self.eventVipWage))
    self.handler_QUERY_INSURE = UserService:addEventListener(HallCenterEvent.EVENT_QUERY_INSURE_FOR_ROOM, handler(self, self.refreshMyInfo))
    

    UserService:sendQueryVipWageReceiveTimes()
    self:refreshMyInfo()
end

function DailyGoldLayer:onExit()
    print("DailyGoldLayer:onExit()")

    UserService:removeEventListener(self.handlerVOUCHEREXCHANGE)
    UserService:removeEventListener(self.handlerQUERYRECORDVOUCHEREXCHANGE)
    UserService:removeEventListener(self.handler_QUERY_INSURE)

end

function DailyGoldLayer:createUI()
	local displaySize = cc.size(display.width, display.height);
    local winSize = cc.Director:getInstance():getWinSize();
    -- 蒙板
    local maskLayer = ccui.ImageView:create("black.png");
    maskLayer:setScale9Enabled(true);
    maskLayer:setContentSize(cc.size(winSize.width, winSize.height));
    maskLayer:setPosition(cc.p(displaySize.width / 2, displaySize.height / 2));
    maskLayer:setTouchEnabled(true);
    maskLayer:addTo(self);
   

    local bgSprite = display.newScale9Sprite("hallScene/dailyGold/bg.png", winSize.width/2, winSize.height/2-30, cc.size(948, 420))
    bgSprite:addTo(maskLayer)
    self.bgSprite = bgSprite

    --title
    display.newSprite("hallScene/dailyGold/title_bg.png"):addTo(bgSprite,2):align(display.CENTER, 75, 500):rotation(-10)
    display.newSprite("hallScene/dailyGold/title.png"):addTo(bgSprite,2):align(display.CENTER, 75, 500)
    display.newSprite("hallScene/exchange/title3.png"):addTo(bgSprite,2):align(display.CENTER, 75, 510):rotation(-10)

    --banner
    display.newSprite("hallScene/dailyGold/banner1.png"):addTo(bgSprite,2):align(display.CENTER, -20, 0)
    display.newSprite("hallScene/dailyGold/banner1.png"):addTo(bgSprite,2):align(display.CENTER, 950, 370):flipX(true)
    display.newSprite("hallScene/dailyGold/banner2.png"):addTo(bgSprite,2):align(display.CENTER, -20, 330)
    display.newSprite("hallScene/dailyGold/banner2.png"):addTo(bgSprite,2):align(display.CENTER, 960, 30):flipX(true):scale(0.8):rotation(10)
    display.newSprite("hallScene/dailyGold/banner3.png"):addTo(bgSprite,2):align(display.CENTER, 160, 0)
    display.newSprite("hallScene/dailyGold/banner4.png"):addTo(bgSprite,2):align(display.CENTER, 155, 460)

    if (device.platform == "ios" or device.platform == "mac") and OnlineConfig_review == "off" then    --优惠充值按钮
        local chargeButton = ccui.Button:create("hallScene/dailyGold/btn_charge.png");
        chargeButton:setPosition(cc.p(870,-18));
        chargeButton:addTo(bgSprite,2)
        chargeButton:setPressedActionEnabled(true);
        chargeButton:addTouchEventListener(
            function(sender,eventType)
                if eventType == ccui.TouchEventType.ended then
                    self:onClickCharge()
                end
            end
        )

        local effect = self:getChargeButtonEffect()
        local size = chargeButton:getContentSize()
        effect:setPosition(size.width/2+6, size.height/2)
        effect:getAnimation():playWithIndex(0)
        chargeButton:addChild(effect)
        
    end
    
    --top
    display.newSprite("hallScene/dailyGold/top1.png"):addTo(bgSprite,1):align(display.CENTER, 474, 450)
    local myInfo = display.newScale9Sprite("hallScene/dailyGold/top2.png", display.cx, display.cy, cc.size(640, 86))
        :addTo(bgSprite,1):align(display.CENTER, 560, 490)
    display.newSprite("hallScene/dailyGold/top3.png"):addTo(myInfo):align(display.CENTER, 330, 43)

    --split
    display.newScale9Sprite("hallScene/dailyGold/splitV.png", 474, 370, cc.size(894, 18)):addTo(bgSprite, 1)
    -- local splitH = display.newSprite("hallScene/dailyGold/splitH.png"):addTo(bgSprite,1):align(display.TOP_CENTER, 474, 363)
    -- display.newSprite("hallScene/dailyGold/splitH.png"):addTo(splitH):flipY(true):align(display.TOP_LEFT, 0, 0)

    --tip
    display.newSprite("common/loudspeaker.png"):addTo(bgSprite,1):align(display.CENTER, 190, 400)
    local tip = ccui.Text:create("温馨提示：VIP等级越高，每日可领取金币越多哦！", "", 24);
    tip:setColor(cc.c3b(0xfd,0xe3,0xb9));
    tip:setAnchorPoint(cc.p(0,0));
    tip:setPosition(cc.p(220,385));
    tip:addTo(bgSprite,1)

    --frame
    display.newSprite("hallScene/dailyGold/frame.png"):addTo(bgSprite):align(display.BOTTOM_RIGHT, 474, -50)
    display.newSprite("hallScene/dailyGold/frame.png"):addTo(bgSprite):align(display.BOTTOM_LEFT, 474, -50):flipX(true)

    --个人信息
    local headView = require("show_ddz.HeadView").new(1);
    headView:setPosition(cc.p(20, 43));
    headView:addTo(myInfo,1)
    self.headView = headView;

    --name
    local bgName = display.newScale9Sprite("hallScene/personalCenter/level_bg.png", 0, 0, cc.size(140, 40))
    bgName:setPosition(cc.p(120, 40));
    bgName:addTo(myInfo)

    local name = ccui.Text:create("", "", 24);
    name:setColor(cc.c3b(0xff,0xff,0x84));
    name:setAnchorPoint(cc.p(0,0));
    name:setPosition(cc.p(20,5));
    name:addTo(bgName)
    self.name = name;

    --gold
    local bgGold = display.newScale9Sprite("hallScene/personalCenter/level_bg.png", 0, 0, cc.size(120, 40))
    bgGold:setPosition(cc.p(275, 40));
    bgGold:addTo(myInfo)

    display.newSprite("hallScene/hall_gold.png"):addTo(bgGold):pos(0, 20)

    local gold = ccui.Text:create("", "", 24);
    gold:setColor(cc.c3b(0xff,0xff,0x84));
    gold:setAnchorPoint(cc.p(0,0));
    gold:setPosition(cc.p(20,5));
    gold:addTo(bgGold)
    self.gold = gold;

    --bank
    local bgBank = display.newScale9Sprite("hallScene/personalCenter/level_bg.png", 0, 0, cc.size(120, 40))
    bgBank:setPosition(cc.p(418, 40));
    bgBank:addTo(myInfo)

    display.newSprite("hallScene/hall_bankbox.png"):addTo(bgBank):pos(0, 20)

    local bank = ccui.Text:create("", "", 24);
    bank:setColor(cc.c3b(255,255,255));
    bank:setColor(cc.c3b(0xff,0xff,0x84));
    bank:setAnchorPoint(cc.p(0,0));
    bank:setPosition(cc.p(20,5));
    bank:addTo(bgBank)
    self.bank = bank

    --coupon
    local bgCoupon = display.newScale9Sprite("hallScene/personalCenter/level_bg.png", 0, 0, cc.size(120, 40))
    bgCoupon:setPosition(cc.p(562, 40));
    bgCoupon:addTo(myInfo)

    display.newSprite("hallScene/hall_present.png"):addTo(bgCoupon):pos(0, 20)

    local coupon = ccui.Text:create("", "", 24);
    coupon:setColor(cc.c3b(0xff,0xff,0x84));
    coupon:setAnchorPoint(cc.p(0,0));
    coupon:setPosition(cc.p(25,5));
    coupon:addTo(bgCoupon)
    self.coupon = coupon


    --关闭按钮
    local exit = ccui.Button:create("common/hall_close.png");
    exit:setPosition(cc.p(930,470));
    exit:addTo(bgSprite,1)
    exit:setPressedActionEnabled(true);
    exit:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:close();
            end
        end
    )

    self.items={}
    for i=1,5 do
        local item = self:createItem(i)
        item:addTo(bgSprite):align(display.CENTER_TOP, 115 + (i-1)*176, 322)
        table.insert(self.items, item)
    end
    
end

function DailyGoldLayer:refreshItems()
    for _,v in ipairs(self.items) do
        v:removeSelf()
    end

    self.items = {}
    for i=1,5 do
        local item = self:createItem(i)
        item:addTo(self.bgSprite):align(display.CENTER_TOP, 115 + (i-1)*176, 322)
        table.insert(self.items, item)
    end
end

function DailyGoldLayer:createItem(vip)
    local itemInfo = self.itemInfo
    local valide = itemInfo.valide[vip]

    local bgSize = nil
    if valide == 1 then
        bgSize = cc.size(176,290)
    else
        bgSize = cc.size(176,212)
    end

    local item = ccui.ImageView:create("hallScene/dailyGold/item_bg.png");
    item:setScale9Enabled(true);
    item:setContentSize(bgSize);
    item:setTouchEnabled(true);

    --gold
    display.newSprite("hallScene/hall_gold.png"):addTo(item):align(display.CENTER, 22, bgSize.height-27):scale(0.8)
    --gold txt
    local gold = ccui.Text:create(itemInfo.gold[vip],"fonts/HKBDTW12.TTF",24)
    gold:setFontSize(20)
    gold:setAnchorPoint(cc.p(0,0.5))
    gold:setPosition(cc.p(35, bgSize.height-27))
    gold:setColor(cc.c4b(0xf9, 0xff, 0x74,255))
    gold:enableOutline(cc.c4b(0x47,0x25,0x15,255), 2)
    gold:addTo(item)

    --vip
    display.newSprite(itemInfo.viplevel[vip]):addTo(item):align(display.CENTER, 130, bgSize.height-70)
    display.newSprite(itemInfo.vip):addTo(item):align(display.CENTER, 89, bgSize.height-80)

    --item icon
    display.newSprite("hallScene/dailyGold/itembg.png"):addTo(item):align(display.CENTER, bgSize.width/2, bgSize.height-145)
    display.newSprite(itemInfo.itemIcon[vip]):addTo(item):align(display.CENTER, bgSize.width/2, bgSize.height-145)

    --valide txt
    if valide == 1 then
        local valideDay = ccui.Text:create("可领"..itemInfo.valideDay[vip].."天","fonts/HKBDTW12.TTF",24)
        valideDay:setFontSize(22)
        valideDay:setAnchorPoint(cc.p(0.5,0.5))
        valideDay:setPosition(cc.p(bgSize.width/2, bgSize.height-210))
        valideDay:setColor(cc.c4b(0xff, 0xfa, 0xde,255))
        valideDay:enableOutline(cc.c4b(0x4b,0x08,0x00,255), 2)
        valideDay:addTo(item)
    end

    --button
    local button =nil
    if valide == 1 then
        button = ccui.Button:create("hallScene/dailyGold/btn_get.png", "hallScene/dailyGold/btn_get.png", "hallScene/dailyGold/btn_get1.png");
        if itemInfo.valideTimes[vip] == 0 then
            button:setEnabled(false)
            button:setBright(false)
        end
    else
        button = ccui.Button:create("hallScene/dailyGold/btn_wantget.png");
    end
    button:setPosition(cc.p(bgSize.width/2,bgSize.height-250));
    button:addTo(item)
    button:setPressedActionEnabled(true);
    button:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:onClickVip(vip)
            end
        end
    )

    
    return item
end

function DailyGoldLayer:refreshMyInfo()

    local userInfo = DataManager:getMyUserInfo()
    self.gold:setString(FormatNumToString(userInfo.score))
    self.name:setString(FormotGameNickName(userInfo.nickName,5))
    self.bank:setString(FormatNumToString(userInfo:bank()))
    self.coupon:setString(FormatNumToString(userInfo.present))
end

function DailyGoldLayer:onClickVip(vip)
    if self.itemInfo.valide[vip] == 1 and self.itemInfo.valideTimes[vip]>0 then
        UserService:sendVipWageReceive(vip)
    
    elseif OnlineConfig_review == "on" then
        local price={12,50,98,198,488}
        AppPurcharse({channel=PurcharseConfig.ch_Review, package=PurcharseConfig.package_Common, price=price[vip]})

    else
        if vip == 1 then
            onUmengEvent("1034")
        elseif vip == 2 then
            onUmengEvent("1035")
        elseif vip == 3 then
            onUmengEvent("1036")
        elseif vip == 4 then
            onUmengEvent("1037")
        elseif vip == 5 then
            onUmengEvent("1038")
        end
        local chargeLayer = require("show_ddz.ChooseChargeLayer").new({index=vip+2, package=PurcharseConfig.package_Common})
        chargeLayer:addTo(self)
    end
end

function DailyGoldLayer:eventQueryVipWage(event)
--[[//查询玩家当天领取VIP工资次数信息结果数组结构
message tag_QueryVipWageReceiveTimes_Pro
{
    required int32 CanReceiveTypes      = 1;        // 可领类型
    required int32 CanReceiveDays       = 2;        // 可领天数
    required int32 CanReceiveTimes      = 3;        // 可领次数
    required int32 CanReceiveValue      = 4;        // 可领数量
}
// 查询玩家当天领取VIP工资次数信息结果
message DBR_GR_QueryVipWageReceiveTimes_Pro
{
    repeated tag_QueryVipWageReceiveTimes_Pro ResultList    = 1;    // 可领类型
}
]]
    -- print("查询玩家当天领取VIP工资次数信息结果 返回")
    local pData = protocol.hall.business_pb.DBR_GR_QueryVipWageReceiveTimes_Pro()
    pData:ParseFromString(event.data)
    -- dump(pData.ResultList, "查询玩家当天领取VIP工资次数信息结果 ")
    for k,v in ipairs(pData.ResultList) do
        self.itemInfo.valide[v.CanReceiveTypes] = 1
        self.itemInfo.valideDay[v.CanReceiveTypes] = v.CanReceiveDays
        self.itemInfo.valideTimes[v.CanReceiveTypes] = v.CanReceiveTimes
        -- self.itemInfo.gold[v.CanReceiveTypes] = v.CanReceiveValue
    end

    self:refreshItems()
end

function DailyGoldLayer:eventVipWage(event)
--[[
// 领取VIP工资结果
message DBR_GR_VipWageReceive_Result_Pro
{
    required int32 nResultCode      = 1;        // 是否成功
    required string szDescribe      = 2;        // 文字描述
    required int32 dwUserID         = 3;        // UserID
    required int32 dwReceiveTimes       = 4;        // 领取次数
    required int32 dwReceiveValue       = 5;        // 领取数量
    required int32 dwReceiveType        = 6;        // 领取类型
}
]]
    local pData = protocol.hall.business_pb.DBR_GR_VipWageReceive_Result_Pro()
    pData:ParseFromString(event.data)

    -- dump(pData, "领取VIP工资结果返回 ")
    if pData.nResultCode == 0 then
        self.itemInfo.valideTimes[pData.dwReceiveType] = self.itemInfo.valideTimes[pData.dwReceiveType] - pData.dwReceiveTimes
        self:refreshItems()
        local vip = {"绿钻VIP","蓝钻VIP","红钻VIP","金钻VIP","皇冠VIP"}
        Hall.showTips("每日免费领取" .. vip[pData.dwReceiveType] .."专享福利" .. FormatNumToString(pData.dwReceiveValue) .. "金币成功！")
    else
        Hall.showTips(pData.szDescribe)
    end

    UserService:sendQueryInsureInfo()
end

function DailyGoldLayer:onClickCharge()
    print("DailyGoldLayer:self:onClickCharge")

    local chargeLayer = require("show_ddz.ChargeLayer").new()
    chargeLayer:addTo(self)
end

function DailyGoldLayer:close()
    self:removeSelf();
end

function DailyGoldLayer:getChargeButtonEffect()
    local name = "yhcz_anniu"

    local filePath = "hallEffect/yhcz_anniu/"..name..".ExportJson"
    local imagePath = "hallEffect/yhcz_anniu/"..name.."0.png"
    local plistPath = "hallEffect/yhcz_anniu/"..name.."0.plist"
    
    local manager = ccs.ArmatureDataManager:getInstance()
    if manager:getAnimationData(name) == nil then
        manager:addArmatureFileInfo(imagePath,plistPath,filePath)
    end
    local armature = ccs.Armature:create(name)
    return armature;

end

return DailyGoldLayer