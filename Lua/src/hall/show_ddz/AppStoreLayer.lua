--苹果商店购买
local AppStoreLayer = class("AppStoreLayer", function() return display.newLayer() end)

local itemInfo = {
        itemBg = "hall/appstore/item_bg.png",
        itemIcon = {"hallScene/shop/gold1.png", "hallScene/shop/gold2.png", "hallScene/shop/gold4.png", "hallScene/shop/gold5.png", "hallScene/shop/gold6.png"},
        itemTxt = {"6万金币", "25万金币", "50万金币", "149万金币", "248万金币"},
        itemPos = {cc.p(120,270), cc.p(380,270), cc.p(640,270), cc.p(250,45), cc.p(510,45)},

        itemSize = cc.size(230,220),
        itemTxtColor = cc.c3b(0xff, 0xf6, 0x28),
        itemOutline = cc.c4b(0x66, 0x1e, 0x08, 0xff),
        itemTxtSize = 24,

        vip = "hallScene/shop/vipWord.png",
        vipIcon = {"hallScene/shop/zuan1.png","hallScene/shop/zuan2.png","hallScene/shop/zuan3.png","hallScene/shop/zuan4.png","hallScene/shop/zuan5.png"},
        vipTxt = {"送1天","送2天","送2天","送2天","送2天"},

        price = {12,50,98,298,488},

        tuijian = {"hall/appstore/tuijian.png"}

    }

function AppStoreLayer:ctor()
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    self:setNodeEventEnabled(true)


	self:createUI()
end

function AppStoreLayer:onEnter()  
    self.bindIds = {}
    self.bindIds[#self.bindIds + 1] = BindTool.bind(AccountInfo, "insure", handler(self, self.refreshMyInfo))
    self.bindIds[#self.bindIds + 1] = BindTool.bind(AccountInfo, "userInfoChange", handler(self, self.refreshMyInfo));

    self:refreshMyInfo()

end

function AppStoreLayer:onExit()
    for _, bindid in ipairs(self.bindIds) do
        BindTool.unbind(bindid)
    end
end


function AppStoreLayer:createUI()
	local displaySize = cc.size(display.width, display.height);
    local winSize = cc.Director:getInstance():getWinSize();
    -- 蒙板
    local maskLayer = ccui.ImageView:create("black.png");
    maskLayer:setScale9Enabled(true);
    maskLayer:setContentSize(cc.size(winSize.width, winSize.height));
    maskLayer:setPosition(cc.p(displaySize.width / 2, displaySize.height / 2));
    maskLayer:setTouchEnabled(true);
    maskLayer:addTo(self);
   

    local bgSprite = display.newSprite("hall/appstore/bg.png")
    bgSprite:pos(winSize.width/2, winSize.height/2-30)
    bgSprite:addTo(maskLayer)
    self.bgSprite = bgSprite

    --title    
    display.newSprite("hall/appstore/title.png"):addTo(bgSprite,2):align(display.CENTER, 290, 595)

    --banner
    display.newSprite("hall/appstore/banner1.png"):addTo(bgSprite,2):align(display.CENTER, 1045, 160)
    display.newSprite("hall/appstore/banner2.png"):addTo(bgSprite,2):align(display.CENTER, 850, 200)
    display.newSprite("hall/appstore/banner5.png"):addTo(bgSprite,2):align(display.CENTER, 68, 200)
    display.newSprite("hall/appstore/banner6.png"):addTo(bgSprite,2):align(display.CENTER, 90, 80)

    if (device.platform == "ios" or device.platform == "mac") and OnlineConfig_review == "off" then    --优惠充值按钮
        local chargeButton = ccui.Button:create("hall/appstore/btn_charge.png");
        chargeButton:setPosition(cc.p(860,80));
        chargeButton:addTo(bgSprite,1)
        chargeButton:setPressedActionEnabled(true);
        chargeButton:addTouchEventListener(
            function(sender,eventType)
                if eventType == ccui.TouchEventType.ended then
                    self:onClickOpenCharge()
                end
            end
        )

        -- local effect = self:getChargeButtonEffect()
        -- local size = chargeButton:getContentSize()
        -- effect:setPosition(size.width/2+6, size.height/2)
        -- effect:getAnimation():playWithIndex(0)
        -- chargeButton:addChild(effect)
        
    end
    
    --top
    local myInfo = display.newSprite("hall/appstore/top.png"):addTo(bgSprite,1):align(display.CENTER, 800, 595)

    --个人信息
    local headView = require("show_ddz.HeadView").new(1);
    headView:setPosition(cc.p(30, 45));
    headView:addTo(myInfo,1)
    self.headView = headView;

    --name
    local bgName = display.newScale9Sprite("hallScene/personalCenter/level_bg.png", 0, 0, cc.size(150, 40))
    bgName:setPosition(cc.p(135, 50));
    bgName:addTo(myInfo)

    local name = ccui.Text:create("", "", 24);
    name:setColor(cc.c3b(0xff,0xff,0x84));
    name:setAnchorPoint(cc.p(0,0));
    name:setPosition(cc.p(20,5));
    name:addTo(bgName)
    self.name = name;

    --gold
    local bgGold = display.newScale9Sprite("hallScene/personalCenter/level_bg.png", 0, 0, cc.size(140, 40))
    bgGold:setPosition(cc.p(310, 50));
    bgGold:addTo(myInfo)

    display.newSprite("hallScene/hall_gold.png"):addTo(bgGold):pos(0, 20)

    local gold = ccui.Text:create("", "", 24);
    gold:setColor(cc.c3b(0xff,0xff,0x84));
    gold:setAnchorPoint(cc.p(0,0));
    gold:setPosition(cc.p(20,5));
    gold:addTo(bgGold)
    self.gold = gold;

    --bank
    local bgBank = display.newScale9Sprite("hallScene/personalCenter/level_bg.png", 0, 0, cc.size(140, 40))
    bgBank:setPosition(cc.p(485, 50));
    bgBank:addTo(myInfo)

    display.newSprite("hallScene/hall_bankbox.png"):addTo(bgBank):pos(0, 20)

    local bank = ccui.Text:create("", "", 24);
    bank:setColor(cc.c3b(255,255,255));
    bank:setColor(cc.c3b(0xff,0xff,0x84));
    bank:setAnchorPoint(cc.p(0,0));
    bank:setPosition(cc.p(20,5));
    bank:addTo(bgBank)
    self.bank = bank


   if OnlineConfig_review == "off" then

        local vipInfoBtn = ccui.Button:create("hallScene/vipInfo/vipInfoBtn.png","hallScene/vipInfo/vipInfoBtn.png");
        vipInfoBtn:setPosition(cc.p(1060,440))
        vipInfoBtn:setPressedActionEnabled(true)
        vipInfoBtn:addTouchEventListener(
                    function(sender,eventType)
                        if eventType == ccui.TouchEventType.ended then
                            self:vipInfoBtnClickHandler(sender);
                        end
                    end
                )
        bgSprite:addChild(vipInfoBtn)
        self.vipInfoBtn = vipInfoBtn
    end
    
    --关闭按钮
    local exit = ccui.Button:create("hall/appstore/close.png");
    exit:setPosition(cc.p(70,585));
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
        local item = self:createChargeItem(i)
        item:addTo(bgSprite)--:align(display.CENTER_TOP, 115 + (i-1)*176, 322)
        table.insert(self.items, item)
    end
    
end
--支付项
function AppStoreLayer:createChargeItem(index)

    local item = ccui.ImageView:create(itemInfo.itemBg)
    item:setScale9Enabled(true)
    item:setAnchorPoint(cc.p(0,0))
    item:setContentSize(itemInfo.itemSize)
    item:setTouchEnabled(false)
    item:setPosition(itemInfo.itemPos[index])

    display.newSprite("hall/appstore/light.png"):addTo(item):align(display.CENTER, 50, 160)
    display.newSprite("hall/appstore/light2.png"):addTo(item):align(display.CENTER, 110, 120)

    local button = ccui.Button:create("hall/appstore/button.png");
    button:setScale9Enabled(true);
    button:setContentSize(cc.size(155,46));
    --button:setCapInsets(cc.rect(130, 33, 1, 1));
    button:setTitleFontName("fonts/SXSLST.TTF");
    button:setTitleText(itemInfo.price[index] .. "元");
    button:setTitleColor(cc.c3b(255,255,255));
    button:setTitleFontSize(30);
    button:setPressedActionEnabled(true);
    button:getTitleRenderer():enableOutline(cc.c4b(73,110,4,255*0.7),2);
    button:addTo(item)
    button:pos(120,35)
    button:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:onClickAppCharge(index)
            end
        end
    )

    --金币
    display.newSprite(itemInfo.itemIcon[index]):addTo(item):align(display.CENTER, 110, 120)--:scale(0.95)

    local title = ccui.Text:create(itemInfo.itemTxt[index],"fonts/SXSLST.TTF", itemInfo.itemTxtSize)
    title:setPosition(cc.p(120,75))
    title:setColor(itemInfo.itemTxtColor)
    title:enableOutline(itemInfo.itemOutline, 2)
    title:addTo(item)

    --vip
    if OnlineConfig_review == "off" then
        display.newSprite(itemInfo.vipIcon[index]):addTo(item):align(display.CENTER, 200, 175)
        display.newSprite(itemInfo.vip):addTo(item):align(display.CENTER, 157, 180)
        local title = ccui.Text:create(itemInfo.vipTxt[index],"fonts/SXSLST.TTF", 20)
        title:align(display.RIGHT_CENTER,225,145)
        title:setColor(cc.c4b(0xf7, 0x8f, 0x1d, 0xff))
        title:enableOutline(cc.c4b(0x4b, 0x03, 0x00, 0xff), 2)
        title:addTo(item)
    end

    -- --赠送
    -- display.newSprite(itemInfo.presentBg):addTo(item):align(display.CENTER, 48, 145)
    -- local title = display.newSprite(itemInfo.present[index])
    -- -- title:rotation(-45)
    -- title:align(display.CENTER,35,155)
    -- title:addTo(item)

    --推荐
    if itemInfo.tuijian[index] then
        display.newSprite(itemInfo.tuijian[index]):addTo(item):align(display.CENTER, 50, 175)
    end

    return item
end

function AppStoreLayer:refreshMyInfo()

    local userInfo = DataManager:getMyUserInfo()
    self.gold:setString(FormatNumToString(userInfo.score))
    self.name:setString(FormotGameNickName(userInfo.nickName,5))
    self.bank:setString(FormatNumToString(userInfo.insure))
end

function AppStoreLayer:onClickAppCharge(index)
    local price={12,50,98,298,488}
    if OnlineConfig_review == "on" then
        AppPurcharse({channel=PurcharseConfig.ch_Review, price=price[index]})
    else
        AppPurcharse({channel=PurcharseConfig.ch_Apple, price=price[index]})
    end
end

function AppStoreLayer:onClickOpenCharge()

    local chargeLayer = require("show_ddz.ChargeLayer").new()
    chargeLayer:addTo(self)
end

function AppStoreLayer:close()
    self:removeSelf();
end

function AppStoreLayer:vipInfoBtnClickHandler()
    local vipInfo = require("show_ddz.VipInfoLayer").new()
    self:addChild(vipInfo,1)
end

function AppStoreLayer:getChargeButtonEffect()
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

return AppStoreLayer