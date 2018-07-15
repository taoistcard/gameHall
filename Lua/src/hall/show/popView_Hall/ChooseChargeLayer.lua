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

function ChooseChargeLayer:ctor(params)
    -- self.super.ctor(self)
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    self:setNodeEventEnabled(true)

    self.index = params.index
    
    self:createUI();

end

function ChooseChargeLayer:onEnter()
end

function ChooseChargeLayer:onExit()
end

function ChooseChargeLayer:createUI()
	-- body
    local displaySize = cc.size(display.width, display.height);
    local winSize = cc.Director:getInstance():getWinSize();

    -- self:setContentSize(displaySize);

    -- 蒙板
    local maskLayer = ccui.ImageView:create("black.png");
    maskLayer:setScale9Enabled(true);
    maskLayer:setContentSize(cc.size(winSize.width, winSize.height));
    maskLayer:setAnchorPoint(cc.p(0,0))
    maskLayer:setPosition(cc.p(0, 0));
    maskLayer:setTouchEnabled(true);
    -- maskLayer:addTo(self);
    -- print("winSize.width",winSize.width,"winSize.height",winSize.height)

    -- local bgSprite = ccui.ImageView:create("common/pop_bg.png");
    -- bgSprite:setScale9Enabled(true);
    -- bgSprite:setContentSize(cc.size(674, 433));
    -- bgSprite:setPosition(cc.p(588,320));
    -- containerLayer:addChild(bgSprite);
    local basewindow = require("show.popView_Hall.baseWindow").new()
    self:addChild(basewindow)
    -- basewindow:setPosition(-10,-70)

    local containerLayer = ccui.Layout:create()
    -- containerLayer:setAnchorPoint(cc.p(0.5,0.5))
    containerLayer:setContentSize(cc.size(1136,640))
    containerLayer:setPosition(-1136/2+724/2, -640/2+514/2)
    -- containerLayer:setBackGroundColorType(1)
    -- containerLayer:setBackGroundColor(cc.c3b(100,123,100))
    self.containerLayer = containerLayer
    basewindow:getContentNode():addChild(containerLayer)
    local titleicon = ccui.ImageView:create("hall/shop/selectItem/title.png")
    titleicon:setPosition(575, 576)
    containerLayer:addChild(titleicon)
   
    self.listView = ccui.ListView:create()
    self.listView:setDirection(ccui.ScrollViewDir.vertical)
    self.listView:setBounceEnabled(false)
    self.listView:setContentSize(cc.size(600, 390))
    self.listView:setPosition(269,127)
    containerLayer:addChild(self.listView)

    self:itemList()

end

function ChooseChargeLayer:itemList()

    --先开启微信和支付宝充值
    local count = 2

    local row =  math.ceil(count/3)
    local index = 1
    local itemIcon = {"typeWX","typeZFB","typeYLK","tpyeJD","typeCZK","typeWX"}
    for i=1,row do
        local col = count-(i-1)*3
        if col >3 then
            col = 3
        end
        local custom_item = ccui.Layout:create()
        custom_item:setTouchEnabled(true)
        custom_item:setContentSize(cc.size(600,195))
        
        for j=1,col do
            local item = ccui.Layout:create()
            item:setTouchEnabled(true)
            item:setContentSize(cc.size(200,195))
            item:setPosition(200*(j-1),0)
            custom_item:addChild(item)

            local itemBg = ccui.ImageView:create("hall/shop/selectItem/itemBg.png")
            itemBg:setPosition(97,101)
            item:addChild(itemBg)

            local typeBg = ccui.Button:create("hall/shop/selectItem/"..itemIcon[index]..".png")
            typeBg:setPosition(92,87)
            item:addChild(typeBg)
            typeBg:setTag(index)
            typeBg:addTouchEventListener(
                function(sender,eventType)
                    if eventType == ccui.TouchEventType.ended then
                        Click()
                        self:buyHandler(sender);
                    end
                end
            )

            index = index+1

        end
        
        self.listView:pushBackCustomItem(custom_item)
    end
end

function ChooseChargeLayer:buyHandler(sender)
    local packageType = sender:getTag()
    local channelID = {1,2,3,4,5}

    local chargePackage = PurcharseConfig:getPackage(packageType)
    AppPurcharse({channel=packageType, price=chargePackage.productPrice[self.index]})
end


return ChooseChargeLayer