local AppRestorePurchaseLayer = class("AppRestorePurchaseLayer", function() return display.newLayer() end)

function AppRestorePurchaseLayer:ctor()
    local displaySize = cc.size(display.width, display.height);
    local winSize = cc.Director:getInstance():getWinSize();

    self:setContentSize(displaySize);

    -- 蒙板
    local maskLayer = ccui.ImageView:create("black.png");
    maskLayer:setScale9Enabled(true);
    maskLayer:setContentSize(cc.size(winSize.width, winSize.height));
    maskLayer:setPosition(cc.p(displaySize.width / 2, displaySize.height / 2));
    maskLayer:setTouchEnabled(true);
    maskLayer:addTo(self);

    local bgSprite = ccui.ImageView:create("common/pop_bg.png");
    bgSprite:setScale9Enabled(true);
    bgSprite:setContentSize(cc.size(620, 620));
    bgSprite:setPosition(cc.p(displaySize.width / 2, displaySize.height / 2));
    self:addChild(bgSprite);
    --标题
    local titleSprite = ccui.ImageView:create("common/pop_title.png");
    titleSprite:setScale9Enabled(true)
    titleSprite:setContentSize(cc.size(200, 52));
    titleSprite:setPosition(cc.p(310, 584));
    bgSprite:addChild(titleSprite);

    local title = ccui.Text:create("补", FONT_ART_TEXT, 24)
    title:setPosition(cc.p(60,30))
    title:setTextColor(cc.c4b(251,248,142,255))
    title:enableOutline(cc.c4b(137,0,167,200), 3)
    title:addTo(titleSprite)

    title = ccui.Text:create("单", FONT_ART_TEXT, 24)
    title:setPosition(cc.p(85,30))
    title:setTextColor(cc.c4b(251,248,142,255))
    title:enableOutline(cc.c4b(137,0,167,200), 3)
    title:addTo(titleSprite)

    title = ccui.Text:create("列", FONT_ART_TEXT, 24)
    title:setPosition(cc.p(110,30))
    title:setTextColor(cc.c4b(251,248,142,255))
    title:enableOutline(cc.c4b(137,0,167,200), 3)
    title:addTo(titleSprite)

    title = ccui.Text:create("表", FONT_ART_TEXT, 24)
    title:setPosition(cc.p(135,30))
    title:setTextColor(cc.c4b(251,248,142,255))
    title:enableOutline(cc.c4b(137,0,167,200), 3)
    title:addTo(titleSprite)
    --列表
    self.listView = ccui.ListView:create()
    self.listView:setDirection(ccui.ScrollViewDir.vertical)
    self.listView:setBounceEnabled(true)
    self.listView:setContentSize(cc.size(542,488))
    self.listView:setAnchorPoint(cc.p(0.5,0.5))
    self.listView:setPosition(305,300)
    bgSprite:addChild(self.listView)
    --更新数据
    local count = 0
    if AppRestorePurchaseList then
        count = #AppRestorePurchaseList
    end
    for i = 1,count do
        local restoreItem = AppRestorePurchaseList[i]
        local custom_item = ccui.Layout:create()
        custom_item:setTouchEnabled(true)
        custom_item:setContentSize(cc.size(542,120))
        self.listView:pushBackCustomItem(custom_item)

        local restoreItemBg = ccui.ImageView:create("hall/shop/restoreItemBg.png")
        restoreItemBg:setPosition(cc.p(271,60))
        custom_item:addChild(restoreItemBg)

        local orderDateString = ccui.Text:create()
        orderDateString:setString(restoreItem.orderDate)
        orderDateString:setColor(cc.c3b(149,56,22))
        orderDateString:setFontSize(22)
        orderDateString:setAnchorPoint(cc.p(0,0.5))
        orderDateString:setPosition(cc.p(30,75))
        restoreItemBg:addChild(orderDateString)

        local orderResultString = ccui.Text:create()
        orderResultString:setString("苹果订单验证失败。")
        orderResultString:setColor(cc.c3b(149,56,22))
        orderResultString:setFontSize(22)
        orderResultString:setAnchorPoint(cc.p(0,0.5))
        orderResultString:setPosition(cc.p(30,38))
        restoreItemBg:addChild(orderResultString)

        local restoreButton = ccui.Button:create("hall/shop/buyButton.png");
        restoreButton:setPosition(cc.p(425,56));
        restoreItemBg:addChild(restoreButton);
        restoreButton:setPressedActionEnabled(true);
        restoreButton:setTitleFontName(FONT_ART_BUTTON)
        restoreButton:setTitleText("我要补单");
        restoreButton:setTitleFontSize(24)
        restoreButton:getTitleRenderer():enableOutline(COLOR_BTN_GREEN,2)
        restoreButton:addTouchEventListener(
            function(sender,eventType)
                if eventType == ccui.TouchEventType.ended then
                    local args = {orderID=restoreItem.orderID,receipt=restoreItem.receipt}
                    PlatformAppRestorePurchases(args)
                    self:removeFromParent()
                end
            end
        )
    end
    --关闭按钮
    local exit = ccui.Button:create("common/close.png");
    exit:setPosition(cc.p(605,605));
    bgSprite:addChild(exit);
    exit:setPressedActionEnabled(true);
    exit:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                package.loaded["hall.AppRestorePurchaseLayer"] = nil
                self:removeFromParent();
            end
        end
    )
end

return AppRestorePurchaseLayer