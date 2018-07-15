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
local priceName = {"5万金币+绿钻", "25万金币(赠5万)+蓝钻", "50万金币(赠20万)+紫钻", "150万金币(赠100万)+黄钻", "250万金币(赠200万)+皇冠", "2500万金币(赠2500万)"}
local buyName = {"10元","50元","100元","300元","500元","5000元"}
local zjhCanWeiChatVersion = "1.0.4"--炸金花支持微信支付的版本
local jssCanWeiChatVersion = "3.3.0"--金三顺支持微信支付的版本
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

    -- 蒙板
    local maskLayer = ccui.ImageView:create("black.png");
    maskLayer:setScale9Enabled(true);
    maskLayer:setContentSize(cc.size(winSize.width, winSize.height));
    -- maskLayer:setAnchorPoint(cc.p(0,0))
    maskLayer:setPosition(cc.p(DESIGN_WIDTH/2, DESIGN_HEIGHT/2));
    maskLayer:setTouchEnabled(true);
    maskLayer:addTo(self);


    local containerLayer = ccui.Layout:create()
    -- containerLayer:setAnchorPoint(cc.p(0.5,0.5))
    containerLayer:setContentSize(cc.size(1136,640))
    -- containerLayer:setPosition(-1136/2+724/2, -640/2+514/2)
    -- containerLayer:setBackGroundColorType(1)
    -- containerLayer:setBackGroundColor(cc.c3b(100,123,100))
    self.containerLayer = containerLayer
    self:addChild(containerLayer)

    local shopBg = ccui.ImageView:create("hall/preferentialRecharge/shopBg.png")
    shopBg:setPosition(611,306)
    shopBg:setScale9Enabled(true)
    shopBg:setContentSize(cc.size(610, 407));
    containerLayer:addChild(shopBg)

    local kuangBg = ccui.ImageView:create("hall/preferentialRecharge/kuangBg.png")
    kuangBg:setPosition(304,204)
    kuangBg:setScale9Enabled(true)
    kuangBg:setContentSize(cc.size(618, 412));
    shopBg:addChild(kuangBg)

    local payModeBg = ccui.ImageView:create("hall/preferentialRecharge/payModeBg.png")
    payModeBg:setPosition(296, 417)
    payModeBg:setScale9Enabled(true)
    payModeBg:setContentSize(cc.size(436, 117));
    shopBg:addChild(payModeBg)
    local payMode = ccui.ImageView:create("hall/preferentialRecharge/payMode.png")
    payMode:setPosition(226, 64)
    payModeBg:addChild(payMode)
   
    local gold = ccui.Text:create("",FONT_PTY_TEXT,24)
    gold:setTextColor(cc.c4b(201,179,236,255))
    gold:enableOutline(cc.c4b(42,18,60,255), 2)
    gold:setPosition(cc.p(38,349))
    gold:setAnchorPoint(cc.p(0.0,0.5))
    shopBg:addChild(gold)
    self.gold = gold
    self.gold:setString("获得金币："..priceName[self.index])

    local price = ccui.Text:create("价格：50",FONT_PTY_TEXT,24)
    price:setTextColor(cc.c4b(201,179,236,255))
    price:enableOutline(cc.c4b(42,18,60,255), 2)
    price:setPosition(cc.p(438,349))
    price:setAnchorPoint(cc.p(0.0,0.5))
    shopBg:addChild(price)
    self.price = price
    self.price:setString("价格："..buyName[self.index])

    self.listView = ccui.ListView:create()
    self.listView:setDirection(ccui.ScrollViewDir.vertical)
    self.listView:setBounceEnabled(false)
    self.listView:setContentSize(cc.size(549, 310))
    self.listView:setPosition(30,19)
    shopBg:addChild(self.listView)

    self:itemList()
    local exit = ccui.Button:create("common/close1.png", "common/close1.png");
    shopBg:addChild(exit);
    exit:setPosition(600,392);
    exit:onClick(function()self:removeFromParent();end);
end

function ChooseChargeLayer:itemList()

    --先开启微信和支付宝充值
    local count = 2
    local itemIcon = {"typeWX","typeZFB","typeYLK","tpyeJD","typeCZK","typeWX"}--
    print("itemList-getAppVersion()",getAppVersion())
    if  getAppVersion() >= "2.0.0" then--炸金花和金三顺两个版本的特殊处理（炸金花保证小于2.0.0）
        if getAppVersion() < jssCanWeiChatVersion then
            count = 1
            itemIcon = {"typeZFB","typeZFB","typeYLK","tpyeJD","typeCZK","typeWX"}
        end
    else
        if getAppVersion() < zjhCanWeiChatVersion then
            count = 1
            itemIcon = {"typeZFB","typeZFB","typeYLK","tpyeJD","typeCZK","typeWX"}
        end
    end

    local row =  math.ceil(count/3)
    local index = 1
    for i=1,row do
        local col = count-(i-1)*3
        if col >3 then
            col = 3
        end
        local custom_item = ccui.Layout:create()
        custom_item:setTouchEnabled(true)
        custom_item:setContentSize(cc.size(549,155))
        
        for j=1,col do
            local item = ccui.Layout:create()
            item:setTouchEnabled(true)
            item:setContentSize(cc.size(183,155))
            item:setPosition(183*(j-1),0)
            custom_item:addChild(item)

            -- local itemBg = ccui.ImageView:create("hall/shop/selectItem/itemBg.png")
            -- itemBg:setPosition(97,101)
            -- item:addChild(itemBg)

            local typeBg = ccui.Button:create("hall/preferentialRecharge/"..itemIcon[index]..".png")
            typeBg:setPosition(92,78)
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
    print("getAppVersion()",getAppVersion())
    if  getAppVersion() >= "2.0.0" then--炸金花和金三顺两个版本的特殊处理（炸金花保证小于2.0.0）
        if getAppVersion() < jssCanWeiChatVersion then--大于等于3.3.0之后才支持微信支付
            print("金三顺确实可以比较")
            channelID = {2,2,3,4,5}
            packageType = 2--屏蔽微信支付(只剩支付宝)的特殊处理
        else--大于等于3.3.0之后才支持微信支付
            print("******金三顺确实可以比较")
        end
    else
        if getAppVersion() < zjhCanWeiChatVersion then--大于等于1.0.4之后才支持微信支付
            print("炸金花确实可以比较")
            channelID = {2,2,3,4,5}
            packageType = 2--屏蔽微信支付(只剩支付宝)的特殊处理
        else--大于等于1.0.4之后才支持微信支付
            print("******炸金花确实可以比较")
        end
    end
    local chargePackage = PurcharseConfig:getPackage(packageType)
    print("channel",channelID[packageType],"price",chargePackage.productPrice[self.index])    
    Hall.showTips("支付跳转中，请不要重复点击！！", 2)
    AppPurcharse({channel=channelID[packageType], price=chargePackage.productPrice[self.index]})
end


return ChooseChargeLayer