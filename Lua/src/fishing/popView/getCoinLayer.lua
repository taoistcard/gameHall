local getCoinLayer = class("getCoinLayer", require("show.popView_Hall.baseWindow"))

function getCoinLayer:ctor(index)
    self.super.ctor(self, 6)
    self:setNodeEventEnabled(true)

    self.index = index

    if OnlineConfig_review == "on" then
        self.priceName = {"6万金币","25万金币","49万金币","149万金币","248万金币"}
        self.buyName = {"12元可获得","50元可获得","98元可获得","298元可获得","488元可获得"}
    else
        --优惠充值
        self.priceName = {"5万金币","25万金币","50万金币","150万金币","250万金币"}
        self.buyName = {"10元可获得","50元可获得","100元可获得","300元可获得","500元可获得"}
    end


    self.zuanIcon = {"zuan1","zuan2","zuan3","zuan4","zuan5"}
    self.skillDesc = {"子弹加速","子弹无限反弹","解锁急速射击","解锁追踪弹","解锁锁定减速"}
    self.productTypeArr = {"427","428","429","430","431"}
    self.productIDArr = {"jieji_hall_12","jieji_hall_50","jieji_hall_98","jieji_hall_298","jieji_hall_488"}

    self:createUI()
end

function getCoinLayer:onEnter()
end

function getCoinLayer:onExit()
end

function getCoinLayer:createUI()
    local size = self:getContentSize();
    local title = display.newSprite("game/game_get_coin_title.png", size.width/2, size.height/2+200);
    title:setScale(1.12)
    self:addChild(title);

    local labelBg = display.newSprite("game/game_get_coin_bg.png", size.width/2-160, size.height/2+96);
    self:addChild(labelBg);

    self.priceLabel = ccui.Text:create(self.buyName[self.index],FONT_PTY_TEXT,28)
    self.priceLabel:setTextColor(cc.c4b(255,255,255,255))
    self.priceLabel:setPosition(cc.p(labelBg:getContentSize().width/2,labelBg:getContentSize().height/2+10))
    self.priceLabel:enableOutline(cc.c4b(0,0,0,255), 1)
    labelBg:addChild(self.priceLabel)

    local coins = display.newSprite("game/game_get_coins_icon.png", size.width/2-100, size.height/2);
    self:addChild(coins);

    self.nameLabel = ccui.Text:create(self.priceName[self.index],FONT_PTY_TEXT,27)
    self.nameLabel:setTextColor(cc.c4b(255,255,255,255))
    self.nameLabel:setPosition(cc.p(size.width/2-110, size.height/2-80))
    self.nameLabel:enableOutline(cc.c4b(0,0,0,255), 2)
    self:addChild(self.nameLabel)

    local addSprite = display.newSprite("game/game_add_icon.png", size.width/2+80, size.height/2);
    self:addChild(addSprite);

    local vipItem = ccui.ImageView:create("shop/"..self.zuanIcon[self.index]..".png")
    vipItem:setPosition(size.width/2+150, size.height/2)
    self:addChild(vipItem)
    self.vipItem = vipItem

    self.descLabel = ccui.Text:create(self.skillDesc[self.index],FONT_PTY_TEXT,27)
    self.descLabel:setTextColor(cc.c4b(255,255,255,255))
    self.descLabel:setPosition(cc.p(size.width/2+150, size.height/2-80))
    self.descLabel:enableOutline(cc.c4b(0,0,0,255), 2)
    self:addChild(self.descLabel)

    local refreshBtn = ccui.Button:create("game/game_refresh_btn.png");
    refreshBtn:setAnchorPoint(cc.p(0.5,0.5));
    refreshBtn:setPosition(cc.p(size.width/2+180, size.height/2+90));
    refreshBtn:onClick(
        function()
            self:refreshView()
        end
    );
    self:addChild(refreshBtn);    

    local btn = ccui.Button:create("common/ty_green_btn.png");
    btn:setAnchorPoint(cc.p(0.5,0.5));
    btn:setPosition(cc.p(size.width/2, size.height/2-150));
    btn:onClick(
        function()
            self:onClickGet()
        end
    );
    self:addChild(btn);

    local btnWord = display.newSprite("game/game_sure_word.png")
    btnWord:setPosition(btn:getContentSize().width/2, btn:getContentSize().height/2)
    btn:addChild(btnWord)
end

function getCoinLayer:refreshView()
    self.index = self.index + 1
    if self.index > 5 then
        self.index = 1
    end
    self.priceLabel:setString(self.buyName[self.index])
    self.nameLabel:setString(self.priceName[self.index])
    self.descLabel:setString(self.skillDesc[self.index])
    self.vipItem:loadTexture("shop/"..self.zuanIcon[self.index]..".png")
end

function getCoinLayer:onClickGet()

    if OnlineConfig_review == "on" then
        local args = {packageID = self.productTypeArr[self.index],productId = self.productIDArr[self.index]}
        print("args.packageID",args.packageID,"productId",args.productId)
        PlatformAppPurchases(args);
    else
        local chargeLayer = require("show.popView_Hall.ChooseChargeLayer").new({index=self.index})
        chargeLayer:addTo(self)
    end

end

return getCoinLayer