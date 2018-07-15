local BuDanLayer = class("BuDanLayer", require("show.popView_Hall.baseWindow") );

function BuDanLayer:ctor(mode)

    self.super.ctor(self,mode);

    local size = self:getContentSize();

    local title = display.newSprite("shop/shop_bu_dan_title.png", size.width/2, size.height/2+250);
    self:addChild(title);

    self:refreshRankingTable();

end

function BuDanLayer:refreshRankingTable()

    if self.rankContainer then
        self.rankContainer:removeFromParent();
        self.rankContainer = nil;
    end

    local rankContainer = display.newLayer();
    self.contentNode:addChild(rankContainer);
    self.rankContainer = rankContainer;

    local listView = ccui.ListView:create();
    listView:setDirection(ccui.ScrollViewDir.vertical);
    listView:setBounceEnabled(true);
    listView:setContentSize(cc.size(600,420));
    listView:setAnchorPoint(cc.p(0,0));
    listView:setPosition(cc.p(60,45));
    rankContainer:addChild(listView);

    --更新数据
    local count = 0
    if AppRestorePurchaseList then
        count = #AppRestorePurchaseList
    end
    for i = 1,count do
    -- for i=1,10 do

        local item = ccui.Layout:create();
        item:setContentSize(cc.size(600,100));

        local restoreItemBg = ccui.ImageView:create("common/ty_scale_bg_1.png");
        restoreItemBg:setScale9Enabled(true);
        restoreItemBg:setContentSize(cc.size(580,94));
        restoreItemBg:setPosition(cc.p(300,47));
        item:addChild(restoreItemBg);

        local restoreItem = AppRestorePurchaseList[i]

        local orderDateString = ccui.Text:create(restoreItem.orderDate,FONT_PTY_TEXT,22)
        orderDateString:setColor(cc.c3b(255,224,20))
        orderDateString:setAnchorPoint(cc.p(0,0.5))
        orderDateString:setPosition(cc.p(30,75))
        orderDateString:enableOutline(cc.c4b(0,0,0,255),2)
        restoreItemBg:addChild(orderDateString)

        local orderResultString = ccui.Text:create("苹果订单验证失败!",FONT_PTY_TEXT,22)
        orderResultString:setColor(cc.c3b(255,224,20))
        orderResultString:setAnchorPoint(cc.p(0,0.5))
        orderResultString:setPosition(cc.p(30,38))
        orderResultString:enableOutline(cc.c4b(0,0,0,255),2)
        restoreItemBg:addChild(orderResultString)

        local restoreButton = ccui.Button:create("common/ty_green_btn.png");
        restoreButton:setPosition(cc.p(425,56));
        restoreItemBg:addChild(restoreButton);

        restoreButton:setPressedActionEnabled(true);
        restoreButton:setTitleFontName(FONT_PTY_TEXT)
        restoreButton:setTitleText("我要补单");
        restoreButton:setTitleFontSize(24)
        restoreButton:addTouchEventListener(
            function(sender,eventType)
                if eventType == ccui.TouchEventType.ended then
                    local args = {orderID=restoreItem.orderID,receipt=restoreItem.receipt}
                    PlatformAppRestorePurchases(args)
                    self:removeFromParent()
                end
            end
        )
        
        listView:pushBackCustomItem(item);

    end 

end

return BuDanLayer;