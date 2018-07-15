local ShopLayer = class( "ShopLayer", function() return display.newLayer(); end )

function ShopLayer:ctor(kind)
    self.bindIds = {}
    self.bindIds[#self.bindIds + 1] = BindTool.bind(AccountInfo, "nickName", handler(self, self.refreshNickName))
    self.bindIds[#self.bindIds + 1] = BindTool.bind(AccountInfo, "score", handler(self, self.refreshScore))
    self.bindIds[#self.bindIds + 1] = BindTool.bind(AccountInfo, "insure", handler(self, self.refreshInsure))
    self.bindIds[#self.bindIds + 1] = BindTool.bind(PayInfo, "paymentNofity", handler(self, self.refreshButtonStatus))
    self:setNodeEventEnabled(true)
    self.kind = kind or 1
	self:createUI()
end

function ShopLayer:refreshButtonStatus()
    if PayInfo:getChargeStatusById(444) and self.specChargeItem then
        self.specChargeItem:setVisible(false)
    end
end

function ShopLayer:onEnter()
    print("ShopLayer:onEnter")
    BankInfo:sendQueryRequest()
end

function ShopLayer:onExit()
    print("ShopLayer:onExit")
    for _, bindid in ipairs(self.bindIds) do
        BindTool.unbind(bindid)
    end
end

function ShopLayer:createUI()
    local winSize = cc.Director:getInstance():getWinSize()
    -- 蒙板
    local maskLayer = ccui.ImageView:create()
    maskLayer:loadTexture("black.png")
    maskLayer:setOpacity(153)
    maskLayer:setScale9Enabled(true)
    maskLayer:setCapInsets(cc.rect(4,4,1,1))
    maskLayer:setContentSize(cc.size(winSize.width, winSize.height));
    maskLayer:setPosition(cc.p(winSize.width/2, winSize.height/2));
    maskLayer:setTouchEnabled(true);
    self:addChild(maskLayer)

    self:setContentSize(winSize);

    local extra_add_y = (winSize.height-640)/2

    local shopBg = ccui.ImageView:create("hall/shop/shopBg.png")
    shopBg:setPosition(569,269+extra_add_y)
    self:addChild(shopBg)

    local nameBg = ccui.ImageView:create("hall/shop/nameBg.png")
    nameBg:setPosition(185,585)
    shopBg:addChild(nameBg)

    local headView = require("show.popView_Hall.HeadView").new(1,true);
    headView:setPosition(cc.p(64,57));
    headView:setScale(0.64);
    nameBg:addChild(headView);
    
    headView:setNewHead(AccountInfo.faceId, AccountInfo.cy_userId, AccountInfo.headFileMD5);
    --vip信息
    if OnlineConfig_review == "off" and AccountInfo.memberOrder > 0 then
        headView:setVipHead(AccountInfo.memberOrder,1)
    end    

    local nickNameBg = ccui.ImageView:create("hall/shop/nickNameBg.png")
    nickNameBg:setPosition(189,57)
    nickNameBg:setScale9Enabled(true)
    nickNameBg:setContentSize(cc.size(160, 33));
    nameBg:addChild(nickNameBg)

    local nickName = ccui.Text:create(FormotGameNickName(AccountInfo.nickName,6),FONT_PTY_TEXT,22)
    nickName:setTextColor(cc.c4b(255,251,255,255))
    nickName:enableOutline(cc.c4b(0,3,8,255), 2)
    nickName:setPosition(cc.p(80,16))
    nickName:setAnchorPoint(cc.p(0.5,0.5))
    nickNameBg:addChild(nickName)
    self.nickName = nickName

    local moneyBg = ccui.ImageView:create("hall/shop/moneyBg.png")
    moneyBg:setPosition(626,589)
    shopBg:addChild(moneyBg)

    local nickNameBg = ccui.ImageView:create("hall/shop/nickNameBg.png")
    nickNameBg:setPosition(189,47)
    nickNameBg:setScale9Enabled(true)
    nickNameBg:setContentSize(cc.size(160, 33));
    moneyBg:addChild(nickNameBg)

    local goldIcon = ccui.ImageView:create("hall/shop/gold.png")
    goldIcon:setPosition(67,49)
    moneyBg:addChild(goldIcon)

    local gold = ccui.Text:create(FormatNumToString(AccountInfo.score),FONT_PTY_TEXT,22)
    gold:setTextColor(cc.c4b(254,224,25,255))
    gold:enableOutline(cc.c4b(4,0,12,255), 2)
    gold:setPosition(cc.p(80,16))
    gold:setAnchorPoint(cc.p(0.5,0.5))
    nickNameBg:addChild(gold)
    self.gold = gold

    local nickNameBg = ccui.ImageView:create("hall/shop/nickNameBg.png")
    nickNameBg:setPosition(432,47)
    nickNameBg:setScale9Enabled(true)
    nickNameBg:setContentSize(cc.size(160, 33));
    moneyBg:addChild(nickNameBg)

    local bankIcon = ccui.ImageView:create("hall/shop/hall_btn_icon_bank.png")
    bankIcon:setPosition(322,51)
    bankIcon:setScale(0.75)
    moneyBg:addChild(bankIcon)

    local bank = ccui.Text:create(FormatNumToString(AccountInfo.insure),FONT_PTY_TEXT,22)
    bank:setTextColor(cc.c4b(254,224,25,255))
    bank:enableOutline(cc.c4b(4,0,12,255), 2)
    bank:setPosition(cc.p(80,16))
    bank:setAnchorPoint(cc.p(0.5,0.5))
    nickNameBg:addChild(bank)
    self.bank = bank

    self.listView = ccui.ListView:create()
    -- set list view ex direction
    self.listView:setDirection(ccui.ScrollViewDir.vertical)
    self.listView:setBounceEnabled(true)
    self.listView:setContentSize(cc.size(840, 400))
    self.listView:setPosition(74,58)
    shopBg:addChild(self.listView)
    self:itemList()
    if self.kind == 1 then
        local zs = ccui.ImageView:create("hall/shop/zs.png")
        zs:setPosition(761,154)
        shopBg:addChild(zs)
    end

    local bottomIcon = ccui.ImageView:create("common/ty_icon_bottom.png")
    bottomIcon:setPosition(859,-5.7)
    bottomIcon:setScale(1.25)
    bottomIcon:setAnchorPoint(cc.p(0,0))
    shopBg:addChild(bottomIcon)

    local haimaIcon = ccui.ImageView:create("common/ty_hai_ma.png")
    haimaIcon:setPosition(-34,5)
    haimaIcon:setScale(1.25)
    haimaIcon:setAnchorPoint(cc.p(0,0))
    shopBg:addChild(haimaIcon)

    local paopaoIcon = ccui.ImageView:create("common/ty_pao_pao_1.png")
    paopaoIcon:setPosition(-6.5,448)
    paopaoIcon:setScale(1.25)
    shopBg:addChild(paopaoIcon)

    if self.kind == 1 then

        if OnlineConfig_review == "off" then
            local btn_yh = ccui.Button:create("hall/shop/btn_yh.png");
            shopBg:addChild(btn_yh);
            btn_yh:setPosition(755,89);
            btn_yh:onClick(function()self:discountRecharge();end);
        end

    elseif self.kind == 2 then

        local zhifubao = ccui.Button:create("hall/shop/zfbSelected.png");
        shopBg:addChild(zhifubao);
        zhifubao:setPosition(23,374);
        zhifubao:onClick(function()print("zhifubao")end);

    end

    local exit = ccui.Button:create("common/ty_close.png");
    shopBg:addChild(exit);
    exit:setPosition(929,501);
    exit:onClick(function()self:removeFromParent();end);

    if OnlineConfig_review == "off" then
        --vip btn
        local vip_btn = ccui.Button:create("shop/vipInfo/vipInfoBtn.png");
        vip_btn:setPosition(cc.p(960,360));
        vip_btn:onClick(
            function()
                local vipLayer = require("show.popView_Hall.VipInfoLayer").new()
                self:addChild(vipLayer)
            end
        );
        shopBg:addChild(vip_btn);
    end

    --补单按钮
    local vip_btn = ccui.Button:create("shop/shop_bu_recharge.png");
    vip_btn:setPosition(cc.p(930,40));
    vip_btn:onClick(
        function()
            local vipLayer = require("show.popView_Hall.BuDanLayer").new()
            self:addChild(vipLayer)
        end
    );
    shopBg:addChild(vip_btn);

end

function ShopLayer:itemList()

    local priceName = {"6万金币","25万金币","49万金币","149万金币","248万金币"}
    local buyName = {"12元","50元","98元","298元","488元"}
    local zuanIcon = {"zuan1","zuan2","zuan3","zuan4","zuan5"}
    local coinIcon = {"coins_1","coins_2","coins_3","coins_4","coins_5","coins_6"}
    local donateStr = {"","赠2.5万金币","赠6万金币","赠26万金币","赠52万金币",""}
    --充值项
    if self.kind == 1 then    
        self.productTypeArr = {"432","433","434","435","436"}
        if OnlineConfig_review == "on" then
            self.productTypeArr = {"427","428","429","430","431"}
        end
        self.productIDArr = {"jieji_hall_12","jieji_hall_50","jieji_hall_98","jieji_hall_298","jieji_hall_488"}
    elseif self.kind == 2 then
        --优惠充值(去PurcharseConfig中对应)
        self.productTypeArr = {"439","440","441","442","443","444"}
        priceName = {"5万金币", "25万金币", "50万金币", "150万金币", "250万金币", "2500万金币"}
        buyName = {"10元","50元","100元","300元","500元","5000元"}
        zuanIcon = {"zuan1","zuan2","zuan3","zuan4","zuan5","blank"}
        donateStr = {"","赠5万金币","赠20万金币","赠100万金币","赠200万金币","赠2500万金币"}
    end
    local count = #self.productTypeArr--5
    local row =  math.ceil(count/3)
    local index = 1
	for i=1,row do
		local col = count-(i-1)*3
		if col >3 then
			col = 3
		end
        local custom_item = ccui.Layout:create()
        custom_item:setTouchEnabled(true)
        custom_item:setContentSize(cc.size(822,200))
        
		for j=1,col do
	        local item = ccui.Layout:create()
	        item:setTouchEnabled(true)
	        item:setContentSize(cc.size(280,200))
	        item:setPosition(6+274*(j-1),0)
	        custom_item:addChild(item)

		    local itemBg = ccui.ImageView:create("hall/shop/itemBg_fish.png")
		    itemBg:setPosition(124,99)
		    item:addChild(itemBg)

	        local priceLabel = ccui.Text:create(priceName[index],FONT_PTY_TEXT,24)
	        priceLabel:setTextColor(cc.c4b(255,226,10,255))
	        priceLabel:setPosition(cc.p(52,170))
		    priceLabel:enableOutline(cc.c4b(2,0,3,255), 2)
	        priceLabel:setAnchorPoint(cc.p(0,0.5))
	        item:addChild(priceLabel)

            local coins = ccui.ImageView:create("hall/shop/"..coinIcon[index]..".png")
            coins:setPosition(122,100)
            item:addChild(coins)

            if OnlineConfig_review == "off" then
                local donateLabel = ccui.Text:create(donateStr[index],FONT_PTY_TEXT,20)
                donateLabel:setTextColor(cc.c4b(255,255,255,255))
                donateLabel:setPosition(cc.p(52,140))
                donateLabel:enableOutline(cc.c4b(108,52,122,255), 2)
                donateLabel:setAnchorPoint(cc.p(0,0.5))
                item:addChild(donateLabel)

                local zuan = ccui.ImageView:create("hall/shop/"..zuanIcon[index]..".png")
                zuan:setPosition(230,154)
                item:addChild(zuan)
            end

            --优惠充值里面的
            if self.productTypeArr[index] == "444" then
                local daySprite = display.newSprite("hall/shop/once_per_day.png")
                daySprite:setAnchorPoint(cc.p(0,0.5))
                daySprite:setPosition(-12, 150)
                item:addChild(daySprite)

                if PayInfo:getChargeStatusById(444) then
                    item:setVisible(false)
                end
                self.specChargeItem = item
            end          

		    local buy = ccui.Button:create("hall/shop/btn.png","hall/shop/btn.png");
		    buy:setScale9Enabled(true)
		    buy:setContentSize(cc.size(142, 52))
		    buy:setPosition(cc.p(121,38));
		    buy:setTag(index)
		    buy:setTitleFontName(FONT_PTY_TEXT);
		    buy:setTitleText(buyName[index]);
		    buy:setTitleColor(cc.c4b(219,255,139,255));
		    buy:setTitleFontSize(30);
		    buy:getTitleRenderer():enableOutline(cc.c4b(37,95,14,255),2)
		    item:addChild(buy);
		    buy:setPressedActionEnabled(true);
		    buy:addTouchEventListener(
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

function ShopLayer:discountRecharge()
	print("discountRecharge")
    local youhui = require("show.popView_Hall.ShopLayer").new(2)
    self:getParent():addChild(youhui,1000)
end

function ShopLayer:buyHandler(sender)

    if self.kind == 1 then

        local index = sender:getTag()
        local args = {packageID = self.productTypeArr[index],productId = self.productIDArr[index]}
        print("args.packageID",args.packageID,"productId",args.productId)
        PlatformAppPurchases(args);

    elseif self.kind == 2 then

        local index = sender:getTag()
        local chargeLayer = require("show.popView_Hall.ChooseChargeLayer").new({index=index})
        chargeLayer:addTo(self)

    end

end

function ShopLayer:refreshNickName()
    print("refreshNickName")
    self.name:setString(FormotGameNickName(AccountInfo.nickName,6))
end

function ShopLayer:refreshScore()
    print("refreshScore")
    self.gold:setString(FormatNumToString(AccountInfo.score))
end

function ShopLayer:refreshInsure()
    print("refreshInsure")
    self.bank:setString(FormatNumToString(AccountInfo.insure))
end

return ShopLayer