local ChargeLayer = class("ChargeLayer", function() return display.newLayer() end)
local itemInfo = {
    itemSize = cc.size(240,185),
    itemBg = "hall/appstore/item_bg.png",
    [1]={--微信／支付宝

        itemIcon = {"hallScene/shop/gold1.png", "hallScene/shop/gold2.png", "hallScene/shop/gold3.png", "hallScene/shop/gold4.png", "hallScene/shop/gold5.png", "hallScene/shop/gold6.png"},
        itemTxt = {"5万", "25万", "50万", "100万", "250万", "2500万"},
        itemTxtColor = cc.c3b(0xff, 0xf6, 0x28),
        itemOutline = cc.c4b(0x66, 0x1e, 0x08, 0xff),
        itemTxtSize = 24,

        vip = "hallScene/shop/vipWord.png",
        vipIcon = {"hallScene/shop/zuan1.png","hallScene/shop/zuan2.png","hallScene/shop/zuan3.png","hallScene/shop/zuan4.png","hallScene/shop/zuan5.png","hallScene/shop/zuan5.png"},
        vipTxt = {"送1天","送2天","送2天","送2天","送2天","送2天"},

        -- button = {"shop/10.png","shop/50.png","shop/100.png","shop/200.png","shop/500.png","shop/1000.png"},
        price = {10,50,100,200,500,5000},
        present = {"", "", "hall/charge/z40w.png", "hall/charge/z80w.png", "hall/charge/z200w.png", "hall/charge/z2500w.png"},
        presentBg = "hall/charge/present.png"
    },
    [2]={--骏网卡
        itemIcon = {"hallScene/shop/gold2.png", "hallScene/shop/gold3.png", "hallScene/shop/gold4.png", "hallScene/shop/gold5.png", "hallScene/shop/gold6.png"},
        itemTxt = {"10万", "25万", "50万", "100万", "250万"},
        itemTxtColor = cc.c3b(0xff, 0xf6, 0x28),
        itemOutline = cc.c4b(0x66, 0x1e, 0x08, 0xff),
        itemTxtSize = 24,

        vip = "hallScene/shop/vipWord.png",
        vipIcon = {"hallScene/shop/zuan1.png","hallScene/shop/zuan2.png","hallScene/shop/zuan3.png","hallScene/shop/zuan4.png","hallScene/shop/zuan5.png"},
        vipTxt = {"送2天","送2天","送2天","送2天","送2天"},

        -- button = {"shop/10.png","shop/50.png","shop/100.png","shop/200.png","shop/500.png","shop/1000.png"},
        price = {20,50,100,200,500},
        present = {"hall/charge/z2w.png", "hall/charge/z5w.png", "hall/charge/z10w.png", "hall/charge/z20w.png", "hall/charge/z50w.png"},
        presentBg = "hall/charge/present.png"
    },
    [3]={--电信卡
        itemIcon = {"hallScene/shop/gold2.png", "hallScene/shop/gold3.png", "hallScene/shop/gold4.png", "hallScene/shop/gold5.png", "hallScene/shop/gold6.png"},
        itemTxt = {"18万", "45万", "90万", "180万", "450万"},
        itemTxtColor = cc.c3b(0xff, 0xf6, 0x28),
        itemOutline = cc.c4b(0x66, 0x1e, 0x08, 0xff),
        itemTxtSize = 24,

        vip = "hallScene/shop/vipWord.png",
        vipIcon = {"hallScene/shop/zuan1.png","hallScene/shop/zuan2.png","hallScene/shop/zuan3.png","hallScene/shop/zuan4.png","hallScene/shop/zuan5.png"},
        vipTxt = {"送1天","送2天","送2天","送2天","送2天"},

        -- button = {"shop/10.png","shop/50.png","shop/100.png","shop/200.png","shop/500.png","shop/1000.png"},
        price = {20,50,100,200,500},
        present = {},
        presentBg = "hall/charge/present.png"
    }
}
--[[
local itemInfo = {
    itemSize = cc.size(240,185),
    itemBg = "hallScene/dailyGold/item_bg.png",
    itemIcon = {"hallScene/shop/gold1.png", "hallScene/shop/gold2.png", "hallScene/shop/gold3.png", "hallScene/shop/gold4.png", "hallScene/shop/gold5.png", "hallScene/shop/gold6.png"},
    itemTxt = {"10万", "50万", "100万", "200万", "500万", "1000万"},
    itemTxtColor = cc.c3b(0xff, 0xf6, 0x28),
    itemOutline = cc.c3b(0x66, 0x1e, 0x08),
    itemTxtSize = 24,

    vip = "hallScene/shop/vipWord.png",
    vipIcon = {"shop/zuan1.png","shop/zuan2.png","shop/zuan3.png","shop/zuan4.png","shop/zuan5.png","shop/zuan5.png"},
    vipTxt = {"送5天","送5天","送5天","送5天","送5天","送10天"},

    button = {"shop/10.png","shop/50.png","shop/100.png","shop/200.png","shop/500.png","shop/1000.png"},
    present = {"赠5千", "赠6万", "赠15万", "赠40万", "赠125万", "赠300万"},
    presentBg = "shop/present.png"
    
}
]]
function ChargeLayer:ctor(params)
    -- self.super.ctor(self)
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    self:setNodeEventEnabled(true)


    self:createUI(params);

end

function ChargeLayer:onEnter()
    self:registerGameEvent()
    self:refreshMyInfo()
    self:onClickTab(1)
end

function ChargeLayer:onExit()
    self:removeGameEvent()

end
function ChargeLayer:createUI()
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

    local bgSprite = display.newSprite("hall/charge/bg2.png"):pos(winSize.width/2 + 110, winSize.height/2-30)
    bgSprite:addTo(maskLayer,1)

    --title
    local title = display.newSprite("hall/charge/bg.png"):addTo(maskLayer):align(display.CENTER, 125, winSize.height/2-30)
    display.newSprite("hall/charge/title.png"):addTo(title):align(display.CENTER, 100, 365)

    self.tabs = {}
    for i=1,3 do
        local tab = ccui.ImageView:create("hall/charge/tab" .. i .. ".png"):addTo(title):align(display.CENTER, 112, 260 - (i-1)*50)
        tab:setTouchEnabled(true)
        tab:addTouchEventListener(
            function(sender,eventType)
                if eventType == ccui.TouchEventType.ended then
                    self:onClickTab(i)
                    Click();
                end
            end
        )
        if i==2 then
            tab:hide()
        end
        if i==3 then
            tab:hide()
        end
        table.insert(self.tabs, tab)
    end
    --[[
    for i=1,3 do
        local tab = ccui.ImageView:create("hall/charge/tab" .. i .. ".png"):addTo(title):align(display.CENTER, 112, 260 - (i-1)*85)
        tab:setTouchEnabled(true)
        tab:addTouchEventListener(
            function(sender,eventType)
                if eventType == ccui.TouchEventType.ended then
                    self:onClickTab(i)
                    Click();
                end
            end
        )
        table.insert(self.tabs, tab)
    end
    ]]
    --关闭按钮
    local exit = ccui.Button:create("common/hall_close.png");
    exit:setPosition(cc.p(850,468));
    exit:addTo(bgSprite,1)
    exit:setPressedActionEnabled(true);
    exit:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:close();
            end
        end
    )

    local myInfo = display.newNode():addTo(bgSprite,1):pos(50, 408)
    --个人信息
    local headView = require("show_ddz.HeadView").new(1);
    headView:setPosition(cc.p(20, 43));
    headView:addTo(myInfo,1)
    headView:scale(70/90)
    self.headView = headView;

    --name
    local bgName = display.newScale9Sprite("hallScene/personalCenter/level_bg.png", 0, 0, cc.size(150, 40))
    bgName:setPosition(cc.p(120, 40));
    bgName:addTo(myInfo)

    local name = ccui.Text:create("", "", 24);
    name:setColor(cc.c3b(0xff,0xff,0x84));
    name:setAnchorPoint(cc.p(0,0));
    name:setPosition(cc.p(20,5));
    name:addTo(bgName)
    self.name = name;

    --gold
    local bgGold = display.newScale9Sprite("hallScene/personalCenter/level_bg.png", 0, 0, cc.size(140, 40))
    bgGold:setPosition(cc.p(290, 40));
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
    bgBank:setPosition(cc.p(460, 40));
    bgBank:addTo(myInfo)

    display.newSprite("hallScene/hall_bankbox.png"):addTo(bgBank):pos(0, 20)

    local bank = ccui.Text:create("", "", 24);
    bank:setColor(cc.c3b(255,255,255));
    bank:setColor(cc.c3b(0xff,0xff,0x84));
    bank:setAnchorPoint(cc.p(0,0));
    bank:setPosition(cc.p(20,5));
    bank:addTo(bgBank)
    self.bank = bank

    --frame
    display.newScale9Sprite("hall/charge/hall_frame.png", 432, 220, cc.size(820, 400)):addTo(bgSprite)

    --banner
    display.newSprite("hall/charge/banner1.png"):addTo(bgSprite,3):align(display.CENTER, 700, 490)
    display.newSprite("hall/charge/banner2.png"):addTo(bgSprite,3):align(display.CENTER, -5, 55)
    display.newSprite("hall/charge/banner2.png"):addTo(bgSprite,3):align(display.CENTER, 872, 216):flipX(true)


    --container
    self.listView = ccui.ListView:create()
    -- set list view ex direction
    self.listView:setDirection(ccui.ScrollViewDir.vertical)
    self.listView:setBounceEnabled(true)
    self.listView:setContentSize(cc.size(800,380))
    self.listView:setPosition(30, 30)
    -- self.listView:setBackGroundColorType(1)
    -- self.listView:setBackGroundColor(cc.c3b(0,123,0))
    self.listView:addTo(bgSprite,1)


end

function ChargeLayer:onClickTab(index)
        
    if self.selectTab == index then
        return
    else
        self.selectTab = index
        
        for i=1,3 do
            if i == index then
                self.tabs[i]:loadTexture("hall/charge/tab" ..i..i.. ".png")
            else
                self.tabs[i]:loadTexture("hall/charge/tab" ..i.. ".png")
            end
            
        end
        

        self:createChargeItems(index)        
    end


end

function ChargeLayer:createChargeItems(chargeType)

    self.listView:removeAllChildren()

    local row =1
    local col =1
    local curRow = 0
    local custom_item = nil
    local height = 0
    local custom_itemY = 188
    local custom_itemX = 790

    
    for i=1, #itemInfo[chargeType].price do
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

        local item = self:createChargeItem(chargeType, i)
        item:setAnchorPoint(cc.p(0.5,0.5))
        item:setPosition((col-0.5)*265, 0.5*188)
        custom_item:addChild(item)
    

    end    
end

--支付项
function ChargeLayer:createChargeItem(_type, index)

    local item = ccui.ImageView:create(itemInfo.itemBg)
    item:setScale9Enabled(true)
    item:setContentSize(itemInfo.itemSize)
    item:setTouchEnabled(false)

    display.newSprite("hall/appstore/light.png"):addTo(item):align(display.CENTER, 50, 160)
    display.newSprite("hall/appstore/light2.png"):addTo(item):align(display.CENTER, 110, 120)

    local button = ccui.Button:create("common/btn_green.png");
    button:setScale9Enabled(true);
    button:setContentSize(cc.size(155,46));
    --button:setCapInsets(cc.rect(130, 33, 1, 1));
    button:setTitleFontName("fonts/JDQTJ.TTF");
    button:setTitleText(itemInfo[_type].price[index] .. "元");
    button:setTitleColor(cc.c3b(255,255,255));
    button:setTitleFontSize(30);
    button:setPressedActionEnabled(true);
    button:getTitleRenderer():enableOutline(cc.c4b(73,110,4,255*0.7),2);
    button:addTo(item)
    button:pos(120,35)
    button:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:onClickCharge(_type, index)
            end
        end
    )

    --金币
    display.newSprite(itemInfo[_type].itemIcon[index]):addTo(item):align(display.CENTER, 120, 120)--:scale(0.95)

    local title = ccui.Text:create(itemInfo[_type].itemTxt[index].."金币","fonts/SXSLST.TTF", itemInfo[_type].itemTxtSize)
    title:setPosition(cc.p(120,75))
    title:setColor(itemInfo[_type].itemTxtColor)
    title:enableOutline(itemInfo[_type].itemOutline, 2)
    title:addTo(item)

    --vip
    display.newSprite(itemInfo[_type].vipIcon[index]):addTo(item):align(display.CENTER, 210, 160)
    display.newSprite(itemInfo[_type].vip):addTo(item):align(display.CENTER, 167, 167)
    local title = ccui.Text:create(itemInfo[_type].vipTxt[index],"fonts/SXSLST.TTF", 20)
    title:align(display.RIGHT_CENTER,235,130)
    title:setColor(cc.c4b(0xf7, 0x8f, 0x1d, 0xff))
    title:enableOutline(cc.c4b(0x4b, 0x03, 0x00, 0xff), 2)
    title:addTo(item)

    --赠送
    if itemInfo[_type].presentBg and itemInfo[_type].present and itemInfo[_type].present[index] 
        and itemInfo[_type].present[index] ~= "" then 
        display.newSprite(itemInfo[_type].presentBg):addTo(item):align(display.CENTER, 48, 145)
        local title = display.newSprite(itemInfo[_type].present[index])
        title:align(display.CENTER,35,155)
        title:addTo(item)
    end

    return item
end

function ChargeLayer:refreshMyInfo()
    local userInfo = DataManager:getMyUserInfo()
    self.gold:setString(FormatNumToString(userInfo.score))
    self.name:setString(FormotGameNickName(userInfo.nickName,5))
    self.bank:setString(FormatNumToString(userInfo.insure))
end

function ChargeLayer:onClickCharge(_type, index)

    if _type == 1 then--wechat/alipay

        local chargeLayer = require("show_ddz.ChooseChargeLayer").new({index=index})
        chargeLayer:addTo(self)

    elseif _type == 2 then
        AppPurcharse({channel=PurcharseConfig.ch_JCard, price=itemInfo[_type].price[index]})
    
    elseif _type == 3 then
        AppPurcharse({channel=PurcharseConfig.ch_DXCard, price=itemInfo[_type].price[index]})
    end
end

function ChargeLayer:close()
    self:removeSelf();
end

function ChargeLayer:registerGameEvent()
    self.bindIds = {}
    self.bindIds[#self.bindIds + 1] = BindTool.bind(AccountInfo, "insure", handler(self, self.refreshMyInfo))
end

function ChargeLayer:removeGameEvent()
    for _, bindid in ipairs(self.bindIds) do
        BindTool.unbind(bindid)
    end
end

function ChargeLayer:onClickChargeIndex(index, pos)
 
end

return ChargeLayer