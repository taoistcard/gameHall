local ShopLayer = class("ShopLayer", function() return display.newLayer() end)
ShopLayer.showSongTag = false;
ShopLayer.kind = 1;
ShopLayer.leftExchangeValue = 0;
ShopLayer.oneyuanhaspay = 0 --今天充值过吗 0:没有 1:已经充值过
ShopLayer.selectScore = 0
ShopLayer.buttonArray = {};
ShopLayer.lastTime = 0
ShopLayer.currentTime = 0;
ShopLayer.lastTime = 0
ShopLayer.firstbeanUI = 0

local EffectFactory = require("commonView.EffectFactory")
--结构{工作，补助，手续费，充值送}
-- ShopLayer.tipsData = {{8000,2000,4,6000},{34000,5000,3,40000},{66000,8000,2,100000},{132000,10000,1,300000},{330000,15000,0,900000}}
ShopLayer.vipTipsData = {
			[1] = "专属绿钻标识\n破产补助每日3次\n每次金币5000\n银行手续费1%",
			[2] = "专属蓝钻标识\n破产补助每日3次\n每次金币10000\n银行手续费0.5%",
			[3] = "专属紫钻标识\n破产补助每日3次\n每次金币20000\n银行手续费0.2%",
			[4] = "专属金钻标识\n破产补助每日3次\n每次金币50000\n银行手续费0%",
            [5] = "专属皇冠标识\n破产补助每日3次\n每次金币100000\n银行手续费0%",
			}
ShopLayer.chargeItems = {}
local zjhCanWeiChatVersion = "1.0.4"--炸金花支持微信支付的版本
local jssCanWeiChatVersion = "3.3.0"--金三顺支持微信支付的版本
if OnlineConfig_review == nil or OnlineConfig_review == "on" then
    print("on")
    ShopLayer.chargeItems = {}
    -- table.insert(ShopLayer.chargeItems,{price = "10000金币", choumaindex = 0, buttonPrice = "1元", packageid = 318, productid = "zjh_3card_1w"})
    -- table.insert(ShopLayer.chargeItems,{price = "6万金币", choumaindex = 0, buttonPrice = "6元",  packageid = 319, productid = "zjh_3card_6w"})
    if  getAppVersion() >= "2.0.0" then--炸金花和金三顺两个版本的特殊处理（炸金花保证小于2.0.0)
        table.insert(ShopLayer.chargeItems,{price = "6万金币", choumaindex = 0, buttonPrice = "12元", packageid = 427, productid = "jss_3card_6W"})
        table.insert(ShopLayer.chargeItems,{price = "25万金币", choumaindex = 1, buttonPrice = "50元", packageid = 428, productid = "jss_3card_25W"})
        table.insert(ShopLayer.chargeItems,{price = "49万金币", choumaindex = 2, buttonPrice = "98元", packageid = 429, productid = "jss_3card_49W"})
        table.insert(ShopLayer.chargeItems,{price = "149万金币", choumaindex = 2, buttonPrice = "298元", packageid = 430, productid = "jss_3card_149W"})
        table.insert(ShopLayer.chargeItems,{price = "248万金币", choumaindex = 3, buttonPrice = "488元", packageid = 431, productid = "jss_3card_248W"})
    else
        table.insert(ShopLayer.chargeItems,{price = "6万金币", choumaindex = 0, buttonPrice = "12元", packageid = 427, productid = "zjh_3card_6W"})
        table.insert(ShopLayer.chargeItems,{price = "25万金币", choumaindex = 1, buttonPrice = "50元", packageid = 428, productid = "zjh_3card_25W"})
        table.insert(ShopLayer.chargeItems,{price = "49万金币", choumaindex = 2, buttonPrice = "98元", packageid = 429, productid = "zjh_3card_50W"})
        table.insert(ShopLayer.chargeItems,{price = "149万金币", choumaindex = 2, buttonPrice = "298元", packageid = 430, productid = "zjh_3card_149W"})
        table.insert(ShopLayer.chargeItems,{price = "248万金币", choumaindex = 3, buttonPrice = "488元", packageid = 431, productid = "zjh_3card_248W"})
    end
else
    print("off")
    ShopLayer.chargeItems = {}
    -- table.insert(ShopLayer.chargeItems,{price = "5000金币", choumaindex = 0, buttonPrice = "1元", packageid = 385, productid = "zjh_3card_10w"})
    -- table.insert(ShopLayer.chargeItems,{price = "3万金币", choumaindex = 0, buttonPrice = "6元",  packageid = 386, productid = "zjh_3card_6w"})
    if  getAppVersion() >= "2.0.0" then
        table.insert(ShopLayer.chargeItems,{price = "6万金币", song = "2",choumaindex = 0, buttonPrice = "12元", vipIndex = 1, zuan = "zuan1.png", packageid = 432, productid = "jss_3card_6W"})
        table.insert(ShopLayer.chargeItems,{price = "25万金币",song = "2", choumaindex = 1, buttonPrice = "50元", vipIndex = 2, zuan = "zuan2.png", packageid = 433, productid = "jss_3card_25W" })
        table.insert(ShopLayer.chargeItems,{price = "49万金币", song = "2",choumaindex = 2, buttonPrice = "98元", vipIndex = 3, zuan = "zuan3.png", packageid = 434, productid = "jss_3card_49W"})
        table.insert(ShopLayer.chargeItems,{price = "149万金币",song = "2", choumaindex = 2, buttonPrice = "298元", vipIndex = 4, zuan = "zuan4.png", packageid = 435, productid = "jss_3card_149W"})
        table.insert(ShopLayer.chargeItems,{price = "248万金币",song = "2", choumaindex = 3, buttonPrice = "488元", vipIndex = 5, zuan = "zuan5.png", packageid = 436, productid = "jss_3card_248W"})
    else

        table.insert(ShopLayer.chargeItems,{price = "6万金币", song = "2",choumaindex = 0, buttonPrice = "12元", vipIndex = 1, zuan = "zuan1.png", packageid = 432, productid = "zjh_3card_6W"})
        table.insert(ShopLayer.chargeItems,{price = "25万金币",song = "2", choumaindex = 1, buttonPrice = "50元", vipIndex = 2, zuan = "zuan2.png", packageid = 433, productid = "zjh_3card_25W" })
        table.insert(ShopLayer.chargeItems,{price = "49万金币", song = "2",choumaindex = 2, buttonPrice = "98元", vipIndex = 3, zuan = "zuan3.png", packageid = 434, productid = "zjh_3card_50W"})
        table.insert(ShopLayer.chargeItems,{price = "149万金币",song = "2", choumaindex = 2, buttonPrice = "298元", vipIndex = 4, zuan = "zuan4.png", packageid = 435, productid = "zjh_3card_149W"})
        table.insert(ShopLayer.chargeItems,{price = "248万金币",song = "2", choumaindex = 3, buttonPrice = "488元", vipIndex = 5, zuan = "zuan5.png", packageid = 436, productid = "zjh_3card_248W"})
    end
end
local scheduler = require("framework.scheduler")

--@params popFrom 0从大厅弹出1从房间弹出
function ShopLayer:ctor(kind,popFrom)
    self.productPrice = {1,5,10,30}


    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    self:setNodeEventEnabled(true)

    self.kind = kind

    -- onUmentEvent("chongzhi")

    self.popFrom = popFrom or 0

    self:registerGameEvent()

    self:createUI(kind);

    
end
function ShopLayer:setPurchaseCallBack(handler,callbackFunc)
    self.purchaseCallBack = callbackFunc
    self.handler = handler
end
function ShopLayer:executePurchaseCallBack()
    print("self.handler",tostring(self.handler))
    self.purchaseCallBack(self.handler)
end
function ShopLayer:onEnter()
    PayInfo:sendPayOrderItemsRequest()
end
function ShopLayer:onExit()
    self:removeGameEvent()
end

function ShopLayer:createUI(kind)
	-- body

	local displaySize = cc.size(DESIGN_WIDTH, DESIGN_HEIGHT);
    local winSize = cc.Director:getInstance():getWinSize();

    self:setContentSize(displaySize);
    local ly = -18
    -- 蒙板
    local maskLayer = ccui.ImageView:create("common/black.png");
    maskLayer:setScale9Enabled(true);
    maskLayer:setContentSize(cc.size(winSize.width, winSize.height));
    maskLayer:setPosition(cc.p(displaySize.width / 2, displaySize.height / 2));
    maskLayer:setTouchEnabled(true);
    maskLayer:addTo(self);

    local bgSprite = ccui.ImageView:create("hall/shop/diban.png");
    bgSprite:setPosition(cc.p(displaySize.width / 2, displaySize.height / 2 - 20));
    bgSprite:setScale9Enabled(true);
    bgSprite:setContentSize(cc.size(930, 500));
    self:addChild(bgSprite);

    local particle = cc.ParticleSystemQuad:create("hall/shop/eff_store_1.plist")
    particle:setScale(3)
    particle:setEmissionRate(2000)
    particle:addTo(bgSprite,999):align(display.CENTER, 465, 480)

    local title = EffectFactory:createShopTitleEffect()
    bgSprite:addChild(title)
    title:setPosition(465, 500)

    --vipinfo
    local inReview = false;
    if OnlineConfig_review == nil or OnlineConfig_review == "on" then
        inReview = true;
    end
    print("inReview",inReview)
    if inReview == false then
        if AppRestorePurchaseList ~= nil and #AppRestorePurchaseList > 0 then
            local restorePurchaseButton = ccui.Button:create("hall/shop/restoreButton.png");
            restorePurchaseButton:setPosition(cc.p(950, 30));
            bgSprite:addChild(restorePurchaseButton);
            restorePurchaseButton:setPressedActionEnabled(true);
            --restorePurchaseButton:hide()
            restorePurchaseButton:addTouchEventListener(
                function(sender,eventType)
                    if eventType == ccui.TouchEventType.ended then
                        print("restorePurchaseButton click!")
                        -- self:dispatchEvent({name=HallCenterEvent.EVENT_SHOW_RESTORELAYER})
                        self:executePurchaseCallBack()
                    end
                end
            )
        else
            local vipInfoBtnEffect = ccui.ImageView:create("hall/vipInfo/vipInfoBtnEffect.png")
            vipInfoBtnEffect:setPosition(cc.p(930+20, 50+300))
            bgSprite:addChild(vipInfoBtnEffect, 1)
            local action = cc.RepeatForever:create(cc.RotateBy:create(0.5, 90)) 
            vipInfoBtnEffect:runAction(action)
            local vipInfoBtn = ccui.Button:create("hall/vipInfo/vipInfoBtn.png","hall/vipInfo/vipInfoBtn.png");
            vipInfoBtn:setPosition(cc.p(930+20, 50+300))
            vipInfoBtn:setPressedActionEnabled(true)
            vipInfoBtn:addTouchEventListener(
                function(sender,eventType)
                    if eventType == ccui.TouchEventType.ended then
                        self:vipInfoBtnClickHandler(sender);
                    end
                end
            )
            bgSprite:addChild(vipInfoBtn, 1)
            self.vipInfoBtn = vipInfoBtn


            local preferentialBtn = ccui.Button:create("hall/preferentialRecharge/preferentialBtn.png","hall/preferentialRecharge/preferentialBtn.png");
            preferentialBtn:setPosition(cc.p(910, 50))
            preferentialBtn:setPressedActionEnabled(true)
            preferentialBtn:addTouchEventListener(
                function(sender,eventType)
                    if eventType == ccui.TouchEventType.ended then
                        self:preferentialRechargeBtnClickHandler(sender);
                    end
                end
            )
            bgSprite:addChild(preferentialBtn, 1)
            self.preferentialBtn = preferentialBtn
        end
    end

--  listview
    local listviewwidth = 780   
    self.listView = ccui.ListView:create()
    -- set list view ex direction
    self.listView:setDirection(ccui.ScrollViewDir.horizontal)
    self.listView:setBounceEnabled(true)
    self.listView:setContentSize(cc.size(listviewwidth, 420))
    self.listView:setAnchorPoint(cc.p(0.5,0))
    self.listView:setPosition(465, 20)
    bgSprite:addChild(self.listView)


    -- local maskl = ccui.ImageView:create("common/horizental_mask.png")
    -- maskl:setScale9Enabled(true)
    -- maskl:setContentSize(cc.size(32, 420))
    -- maskl:setFlippedX(true)
    -- maskl:setAnchorPoint(cc.p(0,0))
    -- maskl:setPosition(92, 20)
    -- bgSprite:addChild(maskl)
    -- maskl:setOpacity(100)

    -- local maskr = ccui.ImageView:create("common/horizental_mask.png")
    -- maskr:setScale9Enabled(true)
    -- maskr:setContentSize(cc.size(32, 420))
    -- maskr:setAnchorPoint(cc.p(1,0))
    -- maskr:setPosition(870, 20)
    -- bgSprite:addChild(maskr)
    -- maskr:setOpacity(100)


    --箭头-右
    local goRight = ccui.ImageView:create("common/ty_jiantou.png");
    goRight:addTo(bgSprite)
    goRight:align(display.CENTER, 890, 270)
    goRight:setTouchEnabled(true);
    goRight:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            -- self.listView:scrollToRight(1, true)
            local incontener = self.listView:getInnerContainer()
            local consize = incontener:getContentSize()
            local percent = (-incontener:getPositionX() + listviewwidth)/(consize.width - listviewwidth)

            if percent < 0 then percent = 0
            elseif percent > 1 then percent = 1 end
            self.listView:scrollToPercentHorizontal(100 * percent, 1, true)
        end
    end)

    --箭头-左
    local goLeft = ccui.ImageView:create("common/ty_jiantou.png");
    goLeft:setFlippedX(true)
    goLeft:addTo(bgSprite)
    goLeft:align(display.CENTER, 40, 270)
    goLeft:setTouchEnabled(true);
    goLeft:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            -- self.listView:scrollToLeft(1, true)
            local incontener = self.listView:getInnerContainer()
            local consize = incontener:getContentSize()
            local percent = (-incontener:getPositionX() - listviewwidth)/(consize.width - listviewwidth)
            if percent < 0 then percent = 0
            elseif percent > 1 then percent = 1 end
            self.listView:scrollToPercentHorizontal(100 * percent, 1, true)
        end
    end)
    
    -- --根据渠道过滤计费点    
    -- if true == PlatformGetChannel() then
    --     if AppChannel == "CMCC" then
    --         local beanIcon = ccui.Button:create("hall/shopAndroid/ydIcon.png","hall/shopAndroid/ydIconSelected.png");
    --         beanIcon:setPosition(cc.p(176,374))
    --         beanIcon:setPressedActionEnabled(true)
    --         beanIcon:addTouchEventListener(
    --                     function(sender,eventType)
    --                         if eventType == ccui.TouchEventType.ended then
    --                             self:yidongClickHandler(sender);
    --                         end
    --                     end
    --                 )
    --         self:addChild( beanIcon)
    --         self.beanIcon = beanIcon


    --         local goldIcon = ccui.Button:create("hall/shopAndroid/zfbIcon.png","hall/shopAndroid/zfbIconSelected.png");
    --         goldIcon:setPosition(cc.p(176,212))
    --         goldIcon:setPressedActionEnabled(true)
    --         goldIcon:addTouchEventListener(
    --                     function(sender,eventType)
    --                         if eventType == ccui.TouchEventType.ended then
    --                             self:zhifubaoClickHandler(sender);                        
    --                         end
    --                     end
    --                 )
    --         self:addChild(goldIcon)
    --         self.goldIcon = goldIcon
    --         if  kind == 3 then
    --             beanIcon:setHighlighted(true)
    --         else
    --             goldIcon:setHighlighted(true)
    --         end
        
    --     end
    -- end

    local exit = ccui.Button:create("common/close2.png");
    exit:setPosition(cc.p(920, 485));
    bgSprite:addChild(exit);
    exit:setPressedActionEnabled(true);
    exit:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                package.loaded["show_zjh.popView_Hall.ShopLayer_New"] = nil
                package.loaded["show_zjh.popView_Hall.VipInfoLayer"] = nil
                self:removeFromParent();

            end
        end
    )
    self:refreshBuyGoldUI()
end

function ShopLayer:vipInfoBtnClickHandler()
    local vipInfo = require("show_zjh.popView_Hall.VipInfoLayer").new()
    self:addChild(vipInfo,1)
end

function ShopLayer:preferentialRechargeBtnClickHandler()
    local preferentialRecharge = require("show_zjh.popView_Hall.PreferentialRechargeLayer").new()
    self:addChild(preferentialRecharge,1)
end

function ShopLayer:showZuanTips(sender, vipIndex)
	local tag = sender:getTag();

	local index = tag-200;
	local containLayer = sender:getParent();

    if self.viptipNode ~= nil then self.viptipNode:removeFromParent() end

    self.viptipNode = display.newNode():addTo(containLayer)

	if self.showZuanTipsHandler ~= nil then
		scheduler.unscheduleGlobal(self.showZuanTipsHandler)
        self.showZuanTipsHandler = nil
	end

    local bgX = 244/2
    local bgY = 314/2
    local vx  = bgX-342
    local vy  = bgY-274
    local tips = ccui.ImageView:create("common/pop_bg2.png")
    tips:setScale9Enabled(true);
    tips:setContentSize(cc.size(257,296));
	self.viptipNode:addChild(tips)
    tips:setScale(0.8)
	tips:setPosition(336+vx, 380+vy)
	local tiptxt = ccui.Text:create()

	local tipInfo = self.vipTipsData[vipIndex]
	if tipInfo == nil then
		tipInfo = self.vipTipsData[1]
	end
    tiptxt:setColor(cc.c3b(249,250,131))
	tiptxt:setString(tipInfo);
	tiptxt:setPosition(335+vx, 380+vy)
	tiptxt:setFontSize(18)
	self.viptipNode:addChild(tiptxt)

    local handle = scheduler.performWithDelayGlobal(function() 
        if self.viptipNode ~= nil then self.viptipNode:removeFromParent() end
        self.viptipNode = nil
    end, 3)
    self.showZuanTipsHandler = handle
end

function ShopLayer:buy( sender )
	local tag = sender:getTag();
	local index = tag-100;
    
   	self.currentTime = os.time()
   	if (self.lastTime + 1.5)>self.currentTime then
   		self.lastTime = self.currentTime
   		Hall.showTips("操作过于频繁！",1)
   		return
   	end

   	self.lastTime = self.currentTime
	if self.kind == 2 or self.kind == 4 then
    	local args = {packageID = self.rechargeConfig[index].packageid ,productId = self.rechargeConfig[index].productid}
    	PlatformAppPurchases(args); 
    	print("productID:"..self.rechargeConfig[index].productid,"packageid",self.rechargeConfig[index].packageid);
    	print("args",unpack(args))


        -- local args = {packageID = self.rechargeConfig[index].packageid,productId = self.rechargeConfig[index].productid, productName="刷脸测试项", price=1}
        -- FaceVisaAppPurchases(args);

    	-- sender:setEnabled(false)
    	--模拟充值成功
	    -- local function onInterval(dt)
     --        onUnitedPlatFormAppPurchaseResult({["resultCode"]=1})
	    -- end
	    -- local scheduler = require("framework.scheduler")
	    -- local handle = scheduler.performWithDelayGlobal(onInterval, 2)
    elseif self.kind == 3 then
        local args = {packageID = self.rechargeConfig[index].packageid, productId = self.rechargeConfig[index].productid}
        PlatformCMCCPurchases(args); 

    elseif self.kind == 5 then
        local args = {packageID = self.rechargeConfig[index].packageid, productId = self.rechargeConfig[index].productid, productPrice = self.rechargeConfig[index].buttonPrice}
        PlatformCTCCPurchases(args); 
    end
end

function ShopLayer:refreshBuyGoldUI()

    local inReview = false;
    if OnlineConfig_review == nil or OnlineConfig_review == "on" then
        inReview = true;
    end

    local rechardConfig = {}
    self.rechargeConfig = rechardConfig

    local listpayitem = PayInfo.orderItemList
    if listpayitem and #listpayitem > 0 then
        for _, v in pairs(listpayitem) do
            print("id",v.id,"price",v.price,"availableTimes",v.availableTimes,"limitDays",v.limitDays)
            for k, con in ipairs(self.chargeItems) do
                if con.packageid == v.id then
                    con.isRecommend = v.isRecommend
                    table.insert(rechardConfig, #rechardConfig + 1, con)
                end
            end
        end
    else
        -- dump(self.chargeItems, "self.chargeItems")
        for k, con in ipairs(self.chargeItems) do
            table.insert(rechardConfig, #rechardConfig + 1, con)
        end
    end

    print("--共有充值项----", #rechardConfig)

	self.listView:removeAllItems();
	self.buttonArray = {}

    local total = #rechardConfig
    local itembgUrl = "hall/shop/itemBg.png"
    local tuijianUrl = "hall/shop/tuijian.png"
    
	for i=1,total do
		local shopItemLayer = display.newLayer()
        shopItemLayer:setContentSize(cc.size(235, 420))
        shopItemLayer:setName("ListItem")
        shopItemLayer:setTag(i);

        local bg = ccui.ImageView:create()
        bg:loadTexture(itembgUrl)
        bg:setScale9Enabled(true);
        bg:setPosition(117, 255)
        shopItemLayer:addChild(bg)

        local pic = EffectFactory:ceateChouMaEffect(rechardConfig[i].choumaindex)
        pic:setPosition(117, 150)
        bg:addChild(pic)

		---price
		local priceText = ccui.Text:create(rechardConfig[i].price, FONT_ART_TEXT,24)
	    priceText:setFontSize(26)
	    priceText:setColor(cc.c4b(189, 255, 36,255))
        priceText:enableOutline(cc.c4b(26, 13, 6, 255), 2)
	    priceText:setPosition(117, 33)
	    bg:addChild(priceText)

		---song
        if rechardConfig[i].song then
		    local songText = ccui.Text:create("送"..rechardConfig[i].song.."天",FONT_ART_TEXT,24)
    	    songText:setFontSize(24)
    	    songText:setColor(cc.c4b(31, 232, 53, 255))
            songText:enableOutline(cc.c4b(26, 13, 8, 255), 2)
    	    songText:setPosition(180, 360)
    	    shopItemLayer:addChild(songText)
        end

		---button buy
        local buy = ccui.Button:create("hall/shop/buyButton.png");
	    buy:setPosition(cc.p(117, 46));
	    shopItemLayer:addChild(buy);
	    buy:setPressedActionEnabled(true);
	    buy:setTag(100+i)
        buy:setTitleFontName(FONT_ART_TEXT)
	    buy:setTitleText(rechardConfig[i].buttonPrice);
	    buy:setTitleFontSize(28)
        buy:getTitleRenderer():enableOutline(cc.c4b(20, 116, 59, 255), 2)
	    self.buttonArray[i] = buy
	    buy:addTouchEventListener(
	        function(sender,eventType)
	            if eventType == ccui.TouchEventType.ended then
	                self:buy(sender);
	            end
	        end
	    )

        if rechardConfig[i].zuan then
            local zuan = cc.Sprite:create("hall/shop/"..rechardConfig[i].zuan);
            zuan:setPosition(203, 395)
            shopItemLayer:addChild(zuan)

    	    local vipword = ccui.Button:create("hall/shop/vipWord.png");
    	    vipword:setPosition(140, 392)
    	    shopItemLayer:addChild(vipword)
    	    vipword:setTag(200+i)
    	    vipword:addTouchEventListener(
    	    	function ( sender,eventType )
    	    		if eventType == ccui.TouchEventType.ended then
    	    			-- self:showZuanTips(sender, rechardConfig[i].vipIndex);
    	    		end
    	    	end
    	    )

            -- local songday = cc.Sprite:create("hall/shop/songdaytip.png")
            -- songday:setPosition(180, 360)
            -- shopItemLayer:addChild(songday)
        end

        if rechardConfig[i].isRecommend then
            local tuijian = cc.Sprite:create("hall/shop/tuijian.png")
            tuijian:setPosition(48, 272)
            bg:addChild(tuijian)
        end

        local custom_item = ccui.Layout:create()
        custom_item:setTouchEnabled(true)
        custom_item:setContentSize(shopItemLayer:getContentSize())
        custom_item:addChild(shopItemLayer)
        
        self.listView:pushBackCustomItem(custom_item)
	end
end

function ShopLayer:FormatNumToWan(value)
    local s = value/10000
	return s.."万"
end


function ShopLayer:registerGameEvent()
    self.bindIds = {}

    self.bindIds[#self.bindIds + 1] = BindTool.bind(PayInfo, "orderItemList", handler(self, self.refreshBuyGoldUI));
end

function ShopLayer:removeGameEvent()
    for _, bindid in ipairs(self.bindIds) do
        BindTool.unbind(bindid)
    end
end

return ShopLayer