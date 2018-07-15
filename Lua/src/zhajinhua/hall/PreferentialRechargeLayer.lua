local PreferentialRechargeLayer = class("PreferentialRechargeLayer", function() return display.newLayer() end)
function PreferentialRechargeLayer:ctor()
	self:setNodeEventEnabled(true)
	self:createUI()
end
function PreferentialRechargeLayer:onEnter()
    self.bindIds = {}

    self.bindIds[#self.bindIds + 1] = BindTool.bind(PayInfo, "paymentNofity", handler(self, self.refresh));
end
function PreferentialRechargeLayer:onExit()
    for _, bindid in ipairs(self.bindIds) do
        BindTool.unbind(bindid)
    end
end
function PreferentialRechargeLayer:createUI()
    local winSize = cc.Director:getInstance():getWinSize()
    -- 蒙板
    local maskLayer = ccui.ImageView:create()
    maskLayer:loadTexture("common/black.png")
    maskLayer:setContentSize(cc.size(winSize.width, winSize.height));
    maskLayer:setScale9Enabled(true)
    maskLayer:setCapInsets(cc.rect(4,4,1,1))
    maskLayer:setPosition(cc.p(DESIGN_WIDTH/2, DESIGN_HEIGHT/2));
    maskLayer:setTouchEnabled(true)
    self:addChild(maskLayer)

    local shopBg = ccui.ImageView:create("hall/preferentialRecharge/shopBg.png")
    shopBg:setPosition(569,269)
    shopBg:setScale9Enabled(true)
    shopBg:setContentSize(cc.size(703, 559));
    self:addChild(shopBg)

    local kuangBg = ccui.ImageView:create("hall/preferentialRecharge/kuangBg.png")
    kuangBg:setPosition(349,276)
    kuangBg:setScale9Enabled(true)
    kuangBg:setContentSize(cc.size(711, 567));
    shopBg:addChild(kuangBg)

    self.listView = ccui.ListView:create()
    -- set list view ex direction
    self.listView:setDirection(ccui.ScrollViewDir.vertical)
    self.listView:setBounceEnabled(true)
    self.listView:setContentSize(cc.size(651, 530))
    self.listView:setPosition(27,4)
    shopBg:addChild(self.listView)
    self:itemList()

    local topBg = ccui.ImageView:create("hall/preferentialRecharge/topBg.png")
    topBg:setPosition(460,572)
    topBg:setScale9Enabled(true)
    topBg:setContentSize(cc.size(586, 68));
    shopBg:addChild(topBg)

    local nickNameBg = ccui.ImageView:create("hall/preferentialRecharge/txtBg.png")
    nickNameBg:setPosition(104,34)
    nickNameBg:setScale9Enabled(true)
    nickNameBg:setContentSize(cc.size(174, 37));
    topBg:addChild(nickNameBg)

    local nickName = ccui.Text:create(FormotGameNickName(AccountInfo.nickName,6),FONT_PTY_TEXT,24)
    nickName:setTextColor(cc.c4b(255,251,255,255))
    nickName:enableOutline(cc.c4b(0,3,8,255), 2)
    nickName:setPosition(cc.p(94,19))
    nickName:setAnchorPoint(cc.p(0.5,0.5))
    nickNameBg:addChild(nickName)
    self.nickName = nickName



    local goldBg = ccui.ImageView:create("hall/preferentialRecharge/txtBg.png")
    goldBg:setPosition(294,34)
    goldBg:setScale9Enabled(true)
    goldBg:setContentSize(cc.size(174, 37));
    topBg:addChild(goldBg)

    local goldIcon = ccui.ImageView:create("hall/room/hall_icon_free.png")
    goldIcon:setPosition(11,17)
    goldIcon:setScale(0.7)
    goldBg:addChild(goldIcon)

    local gold = ccui.Text:create(FormatNumToString(AccountInfo.score),FONT_PTY_TEXT,24)
    gold:setTextColor(cc.c4b(255,251,255,255))
    gold:enableOutline(cc.c4b(4,0,12,255), 2)
    gold:setPosition(cc.p(94,19))
    gold:setAnchorPoint(cc.p(0.5,0.5))
    goldBg:addChild(gold)
    self.gold = gold

    local bankBg = ccui.ImageView:create("hall/preferentialRecharge/txtBg.png")
    bankBg:setPosition(477,34)
    bankBg:setScale9Enabled(true)
    bankBg:setContentSize(cc.size(174, 37));
    topBg:addChild(bankBg)

    local bankIcon = ccui.ImageView:create("common/hall_icon_bank.png")
    bankIcon:setPosition(11,17)
    bankIcon:setScale(0.75)
    bankBg:addChild(bankIcon)

    local bank = ccui.Text:create(FormatNumToString(AccountInfo.insure),FONT_PTY_TEXT,24)
    bank:setTextColor(cc.c4b(255,251,255,255))
    bank:enableOutline(cc.c4b(4,0,12,255), 2)
    bank:setPosition(cc.p(94,19))
    bank:setAnchorPoint(cc.p(0.5,0.5))
    bankBg:addChild(bank)
    self.bank = bank


    local titlebg = ccui.ImageView:create("hall/preferentialRecharge/titlebg.png")
    titlebg:setPosition(14,565)
    shopBg:addChild(titlebg)


    local headView = require("commonView.HeadView").new(1);
    headView:setScale(0.90)
    headView:setPosition(cc.p(291,54))
    titlebg:addChild(headView);
    self.headImage = headView;
    local myInfo = DataManager:getMyUserInfo()
    self.headImage:setNewHead(myInfo.faceID, myInfo.platformID, myInfo.platformFace)
    self.headImage:setVipHead(AccountInfo.memberOrder)

    local exit = ccui.Button:create("common/close1.png", "common/close1.png");
    shopBg:addChild(exit);
    exit:setPosition(708,517);
    exit:onClick(function()self:removeFromParent();end);

end
function PreferentialRechargeLayer:refresh()
	self.listView:removeAllItems()
	self:itemList()
end
function PreferentialRechargeLayer:itemList()

    local priceName = {"6万金币","25万金币","49万金币","149万金币","248万金币"}
    local buyName = {"12元","50元","98元","298元","488元"}
    local zuanIcon = {"zuan1","zuan2","zuan3","zuan4","zuan5"}
    local coinIcon = {"coins_1","coins_2","coins_3","coins_4","coins_5","coins_6"}

        self.productTypeArr = {"439","440","441","442","443","444"}
        priceName = {"5万金币", "25万金币", "50万金币", "150万金币", "250万金币", "2500万金币"}
        buyName = {"10元","50元","100元","300元","500元","5000元"}
        zuanIcon = {"zuan1","zuan2","zuan3","zuan4","zuan5","blank"}
        local songIcon = {"song1","song2","song2","song2","song2","blank"}
        local songGold = {"","赠5万","赠20万","赠100万","赠200万","赠2500万",}

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
        custom_item:setContentSize(cc.size(651,265))
        
		for j=1,col do
	        local item = ccui.Layout:create()
	        item:setTouchEnabled(true)
	        item:setContentSize(cc.size(217,265))
	        item:setPosition(217*(j-1),0)
	        custom_item:addChild(item)

		    local itemBg = ccui.ImageView:create("hall/preferentialRecharge/itemBg.png")
		    itemBg:setPosition(111,144)
		    item:addChild(itemBg)
		    if PayInfo:getChargeStatusById(self.productTypeArr[index]) then
		    	itemBg:hide()
		    end
            local goldIcon = ccui.ImageView:create("hall/room/hall_icon_free.png")
            goldIcon:setPosition(33,52)
            goldIcon:setScale(0.7)
            itemBg:addChild(goldIcon)
	        local priceLabel = ccui.Text:create(priceName[index],FONT_PTY_TEXT,25)
	        priceLabel:setTextColor(cc.c4b(240,182,108,255))
	        priceLabel:setPosition(cc.p(118,51))
		    priceLabel:enableOutline(cc.c4b(126,0,56,255), 2)
	        priceLabel:setAnchorPoint(cc.p(0.5,0.5))
	        itemBg:addChild(priceLabel)

            if OnlineConfig_review == "off" then
                local zuan = ccui.ImageView:create("hall/preferentialRecharge/"..zuanIcon[index]..".png")
                zuan:setPosition(145,193)
                itemBg:addChild(zuan)
                local song = ccui.ImageView:create("hall/preferentialRecharge/"..songIcon[index]..".png")
                song:setPosition(68,-6)
                zuan:addChild(song)
            end
            if songGold[index] ~= "" then
	            local leftTop = ccui.ImageView:create("hall/preferentialRecharge/leftTop.png")
	            leftTop:setPosition(52,172)
	            itemBg:addChild(leftTop)

		        local songLabel = ccui.Text:create(songGold[index],"",23)
		        songLabel:setTextColor(cc.c4b(240,249,249,255))
		        songLabel:setPosition(cc.p(39,73))
			    songLabel:enableOutline(cc.c4b(179,93,0,255), 2)
		        songLabel:setAnchorPoint(cc.p(0.5,0.5))
		        songLabel:setRotation(315)
		        leftTop:addChild(songLabel)
            end
            local coins = ccui.ImageView:create("hall/preferentialRecharge/"..coinIcon[index]..".png")
            coins:setPosition(102,114)
            itemBg:addChild(coins)

		    local buy = ccui.Button:create("hall/preferentialRecharge/btn.png","hall/preferentialRecharge/btn.png");
		    -- buy:setScale9Enabled(true)
		    -- buy:setContentSize(cc.size(142, 52))
		    buy:setPosition(cc.p(98,1));
		    buy:setTag(index)
		    buy:setTitleFontName(FONT_PTY_TEXT);
		    buy:setTitleText(buyName[index]);
		    buy:setTitleColor(cc.c4b(230,230,230,255));
		    buy:setTitleFontSize(30);
		    buy:getTitleRenderer():enableOutline(cc.c4b(0,68,92,255),2)
		    itemBg:addChild(buy);
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
function PreferentialRechargeLayer:buyHandler(sender)


    local index = sender:getTag()
    local packageType = 2--微信和支付宝的套餐ID是一样的
	local chargePackage = PurcharseConfig:getPackage(packageType)
	print("productType=",chargePackage.productType[index])
    if PayInfo:getChargeStatusById(chargePackage.productType[index]) then
        Hall.showTips("该充值项今日次数已用完，请明天再试！", 1)
    else
        local chargeLayer = require("hall.ChooseChargeLayer").new({index=index})
        chargeLayer:addTo(self)
    end
    -- PayInfo.chargeAvailableTimes[444] = 0--模拟充值成功
    -- PayInfo:setPaymentNofity()
end
return PreferentialRechargeLayer