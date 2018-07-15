local ChooseChargeLayer = class("ChooseChargeLayer", function() return display.newLayer() end)
local itemInfo = {
    itemSize = cc.size(205,135),
    itemBg = "hall/appstore/item_bg.png",
    itemIcon = {"chargeType/type_wechat.png", "chargeType/type_alipay.png", "chargeType/type_other.png", "chargeType/type_unionpay.png", "chargeType/type_jd.png"},
    itemTxt = {"微信支付", "支付宝", "其他", "银联卡", "京东支付"},
    itemChargeType = {PurcharseConfig.ch_Wechat, --"微信支付" 
                PurcharseConfig.ch_Alipay,--"支付宝"
                PurcharseConfig.ch_Other, --"其他"
                PurcharseConfig.ch_UnionPay,--"银联卡"
                PurcharseConfig.ch_JD--"京东支付"
                },

    itemTxtColor = cc.c3b(0xf6, 0xf6, 0x75),
    itemOutline = cc.c4b(0x4d, 0x23, 0x11, 0xff),
    itemTxtSize = 24
}
local chargeItemTips = {

    [1] = {--apple
            "获得金币:5万金币+2日绿钻VIP                      价格:10元",
            "获得金币:25万金币+2日蓝钻VIP                    价格:50元",
            "获得金币:50万金币+2日紫钻VIP                    价格:98元",
            "获得金币:100万金币+2日黄钻VIP                  价格:198元",
            "获得金币:248万金币+2日皇冠VIP                  价格:488元",
            "获得金币:3万金币+赠送3万                         价格:6元",
            "获得金币:5000金币+赠送95000+1日绿钻VIP           价格:1元",
            "获得金币:6万金币+6万金币+1日绿钻VIP              价格:12元",
        },

    [2] = {
            "获得金币:5万金币+1日绿钻VIP                      价格:10元",
            "获得金币:25万金币+2日蓝钻VIP                     价格:50元",
            "获得金币:50万金币+40万赠送+2日紫钻VIP             价格:100元",
            "获得金币:100万金币+80万赠送+2日黄钻VIP          价格:200元",
            "获得金币:250万金币+200万赠送+2日皇冠VIP         价格:500元",
            "获得金币:2500万金币+2500万赠送+2日皇冠VIP     价格:5000元",
            "获得金币:500金币+赠送4500                    价格:0.1元",
            "获得金币:5万金币+5万金币+1日绿钻VIP              价格:10元",
        }

}

function ChooseChargeLayer:ctor(params)
    -- self.super.ctor(self)
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    self:setNodeEventEnabled(true)

    self.chargeIndex = params.index
    
    self:createUI(params);

end
function ChooseChargeLayer:onEnter()
    self:registerGameEvent()

end
function ChooseChargeLayer:onExit()
    self:removeGameEvent()

end
function ChooseChargeLayer:createUI(params)
	-- body

	local displaySize = cc.size(display.width, display.height);
    local winSize = cc.Director:getInstance():getWinSize();

    self:setContentSize(displaySize);
    -- 蒙板
    local maskLayer = ccui.ImageView:create("common/black.png");
    maskLayer:setScale9Enabled(true);
    maskLayer:setContentSize(cc.size(winSize.width, winSize.height));
    maskLayer:setPosition(cc.p(displaySize.width / 2, displaySize.height / 2));
    maskLayer:setTouchEnabled(true);
    maskLayer:addTo(self);

    --718,403
    local bgSprite = display.newSprite("common/hall_frame_bg.png"):pos(winSize.width/2, winSize.height/2-30)
    bgSprite:addTo(maskLayer)

    --title
    display.newSprite("hall/chargeType/title_bg.png"):addTo(bgSprite,2):align(display.CENTER, 359, 416)
    display.newSprite("hall/chargeType/title1.png"):addTo(bgSprite,2):align(display.CENTER, 359, 436)

    --关闭按钮
    local exit = ccui.Button:create("common/hall_close.png");
    exit:setPosition(cc.p(715,395));
    exit:addTo(bgSprite,1)
    exit:setPressedActionEnabled(true);
    exit:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:close();
            end
        end
    )

    --frame
    display.newScale9Sprite("hall/charge/hall_frame.png", 359, 180, cc.size(674, 315)):addTo(bgSprite)

    --banner
    display.newSprite("hall/charge/banner2.png"):addTo(bgSprite,3):align(display.CENTER, -5, 55)
    display.newSprite("hall/charge/banner2.png"):addTo(bgSprite,3):align(display.CENTER, 720, 216):flipX(true)

    --充值提示
    local chargeTip = ccui.Text:create("","",24)
    if device.platform == "android" then
        chargeTip:setString(chargeItemTips[2][params.index])
    else
        chargeTip:setString(chargeItemTips[1][params.index])
    end
    chargeTip:setColor(cc.c4b(0xf6, 0xf6, 0x75,255))
    chargeTip:enableOutline(cc.c4b(0x4d,0x23,0x11,255), 2)
    chargeTip:addTo(bgSprite,1):align(display.LEFT_CENTER, 30, 360)


    --container
    self.listView = ccui.ListView:create()
    -- set list view ex direction
    self.listView:setDirection(ccui.ScrollViewDir.vertical)
    self.listView:setBounceEnabled(true)
    self.listView:setContentSize(cc.size(650,290))
    self.listView:setPosition(30, 30)
    -- self.listView:setBackGroundColorType(1)
    -- self.listView:setBackGroundColor(cc.c3b(0,123,0))
    self.listView:addTo(bgSprite,1)

    local row =1
    local col =1
    local curRow = 0
    local custom_item = nil
    local height = 0
    local custom_itemY = 145
    local custom_itemX = 660
    for i=1,2 do
        row = math.ceil(i/3)
        col = i%3
        if col == 0 then
            col = 3
        end

        if curRow ~= row then
            custom_item = ccui.Layout:create()
            custom_item:setTouchEnabled(true)
            custom_item:setContentSize(cc.size(custom_itemX,custom_itemY))
            custom_item:setAnchorPoint(cc.p(0,1))
            curRow = row

            self.listView:pushBackCustomItem(custom_item)
        end

        local item = self:createChargeButton(i)
        item:setAnchorPoint(cc.p(0.5,0.5))
        item:setPosition((col-0.5)*215, 0.5*145)
        custom_item:addChild(item)
    end
end

function ChooseChargeLayer:createChargeButton(index)
   
    local item = ccui.ImageView:create(itemInfo.itemBg)
    item:setScale9Enabled(true)
    item:setContentSize(itemInfo.itemSize)
    item:setTouchEnabled(true)
    item:addTouchEventListener(
        function(sender,eventType)
            print("###########",eventType)
            if eventType == ccui.TouchEventType.began then
                sender:scale(1.1)
            elseif eventType == ccui.TouchEventType.ended then
                sender:scale(1.0)
                self:onClickChargeType(itemInfo.itemChargeType[index])
                Click();

            elseif eventType == ccui.TouchEventType.canceled then
                sender:scale(1.0)
            end
        end
    )

    display.newSprite(itemInfo.itemIcon[index]):addTo(item):align(display.CENTER, 102, 84)

    local title = ccui.Text:create(itemInfo.itemTxt[index],"fonts/SXSLST.TTF", itemInfo.itemTxtSize)
    title:setPosition(cc.p(102,25))
    title:setColor(itemInfo.itemTxtColor)
    title:enableOutline(itemInfo.itemOutline, 2)
    title:addTo(item)

    return item
end

function ChooseChargeLayer:onClickChargeType(index)

    local chargePackage = PurcharseConfig:getPackage(index)
    AppPurcharse({channel=index, product=chargePackage.productType[self.chargeIndex]})
    
    -- AppPurcharse({channel=index, price=chargePackage.productPrice[self.chargeIndex]})
    
end

function ChooseChargeLayer:close()
    self:removeSelf();
end

function ChooseChargeLayer:queryHandler()    
    UserService:sendQueryInsureInfo()
end

function ChooseChargeLayer:registerGameEvent()
  
end

function ChooseChargeLayer:removeGameEvent()

end

return ChooseChargeLayer