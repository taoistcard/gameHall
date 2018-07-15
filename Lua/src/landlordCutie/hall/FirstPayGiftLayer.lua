--首充礼包
local FirstPayGiftLayer = class("FirstPayGiftLayer", function() return display.newLayer() end)
local EffectFactory = require("commonView.DDZEffectFactory")

FirstPayGiftLayer.productTypeArr = {"386","380","381"}
FirstPayGiftLayer.productPrice = {6,12,50}
FirstPayGiftLayer.productIDArr = {"huanle_landpoker_06w","huanle_landpoker_006w","huanle_landpoker_25w"}

FirstPayGiftLayer.receivedBankruptcyHelpCount = 0
FirstPayGiftLayer.receivedBankruptcyHelpMaxCount = 1
FirstPayGiftLayer.bankruptcyKind = 0--0欢乐场破产，1金币场破产
FirstPayGiftLayer.kind = 1--1:首充 2: ￥12 3: ￥50
FirstPayGiftLayer.wenxintishi = 0--0首充或者充值,1温馨提示
-- #define GAME_GENRE_GOLD             0x0001                              //金币类型
-- #define GAME_GENRE_SCORE            0x0002                              //点值类型
-- #define GAME_GENRE_MATCH            0x0004                              //比赛类型
-- #define GAME_GENRE_EDUCATE          0x0008                              //训练类型
-- #define GAME_GENRE_HAPPYBEANS       0x0010                              //欢乐豆类型
function FirstPayGiftLayer:ctor(params,wenxintishi,tipStr)
	-- body
	self:setNodeEventEnabled(true)
    self.wenxintishi = wenxintishi
    self.tipStr = tipStr or ""
    self.giftkind = params
	self:createUI(params,self.tipStr)
end
function FirstPayGiftLayer:createUI(kind,tipStr)
	self.kind = kind
	local displaySize = cc.size(display.width, display.height);
    local winSize = cc.Director:getInstance():getWinSize();

    self:setContentSize(displaySize);
    local priceTextArray = {"tip1.png","tip2.png","tip3.png"}
    local wordArray = {"word1.png","word2.png","word3.png"}
    local gold1Array = {"gold2.png","",""}--1左边没有图标就填"",2左边有图标就填对应的icon
    local gold2Array = {"gold2.png","gold5.png","gold6.png"}
    local goldDes1Array = {"3万金币","",""}--1左边没有金币描述就填"",2左边有金币描述就填对应的钱
    local goldDes2Array = {"赠3万金币","6万金币+绿钻VIP","25万金币＋蓝钻VIP"}
    local zuanIconArray = {"","zuan1.png","zuan2.png"}--1不送VIP就填"",2送VIP就填VIP图标
    local zuantxtArray = {"","绿钻VIP特权","蓝钻VIP特权"}
    if device.platform == "android" then
        priceTextArray = {"tip4.png","tip3.png"}
        wordArray = {"word1.png","word2.png","word3.png"}
        gold1Array = {"gold2.png",""}
        gold2Array = {"gold2.png","gold6.png"}
        goldDes1Array = {"5万金币",""}
        goldDes2Array = {"赠5万金币+绿钻VIP","25万金币＋蓝钻VIP"}
        zuanIconArray = {"zuan1.png","zuan2.png"}
    end
    self.kindCounts = #priceTextArray
    -- 蒙板
    local maskLayer = ccui.ImageView:create("black.png");
    maskLayer:setScale9Enabled(true);
    maskLayer:setContentSize(cc.size(winSize.width, winSize.height));
    maskLayer:setPosition(cc.p(displaySize.width / 2, displaySize.height / 2));
    maskLayer:setTouchEnabled(true);
    maskLayer:addTo(self);

    local titlelight = ccui.ImageView:create("common/effect_light.png");
    titlelight:setScaleY(0.94)
    titlelight:setScaleX(1.71)
    titlelight:setPosition(cc.p(display.cx, 500));
    self:addChild(titlelight);

    local bgSprite = ccui.ImageView:create("hall/pochan/bg.png");
    bgSprite:setScale9Enabled(true);
    bgSprite:setPosition(cc.p(display.cx,300));
    self:addChild(bgSprite);


    local title = ccui.ImageView:create("hall/pochan/title.png")
    bgSprite:addChild(title)
    title:setPosition(320, 465)

    local particle = cc.ParticleSystemQuad:create("particle/title.plist")
    particle:setScale(3)
    --particle:setEmissionRate(20000)
    particle:addTo(bgSprite,999):align(display.CENTER, 318, 490)


    local exit = ccui.Button:create("common/close.png");
    exit:setPosition(cc.p(633,460));
    bgSprite:addChild(exit);
    exit:setPressedActionEnabled(true);
    exit:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:removeSelf()
            end
        end
    )

    --人物
    local dizhu = ccui.ImageView:create("common/ty_dizhu.png")
    dizhu:setPosition(-15,400)
    -- dizhu:setScaleX(-1)
    bgSprite:addChild(dizhu,1)

    local light = ccui.ImageView:create("hall/libao/light.png")
    light:setPosition(115, 80)
    dizhu:addChild(light)

    local action = cc.ScaleBy:create(0.8,3)
    local repeatAction = cc.RepeatForever:create(
                            cc.Sequence:create(
                                cc.EaseOut:create(action, 3),
                                cc.EaseIn:create(action:reverse(), 3)))
        

    light:runAction(repeatAction)

    local anchorDefaultImg = EffectFactory:getInstance():getZhuBoMMAnimation()
    anchorDefaultImg:ignoreAnchorPointForPosition(false)
    anchorDefaultImg:setAnchorPoint(cc.p(0.5,0.5))
    anchorDefaultImg:setPosition(cc.p(680, 200))
    anchorDefaultImg:setScaleX(-1)
    bgSprite:addChild(anchorDefaultImg,1)
    anchorDefaultImg:getAnimation():playWithIndex(0)

    local text = display.newSprite("effect/zhu_bo_mm/wao.png")
    text:setPosition(cc.p(570, 260))
    bgSprite:addChild(text,1)

    
    if self.wenxintishi == 0 then
        -- local word = ccui.ImageView:create("hall/pochan/"..wordArray[self.kind])
        -- -- local word = ccui.ImageView:create("hall/libao/word1.png")
        -- word:setPosition(55, 164)
        -- word:setAnchorPoint(cc.p(0,0.5))
        -- bgSprite:addChild(word)
        -- self.word = word
        local tips = "很遗憾，金币不足，还差30金币！"
        local tiptxt = ccui.Text:create()
        tiptxt:setString(tips)
        tiptxt:setPosition(284, 164)
        tiptxt:setAnchorPoint(cc.p(0,0.5))
        tiptxt:setFontSize(22)
        tiptxt:setColor(cc.c3b(254, 253, 54))
        bgSprite:addChild(tiptxt)
    elseif tipStr then
        local tiptxt = ccui.Text:create()
        tiptxt:setString(tipStr)
        tiptxt:setPosition(55, 164)
        tiptxt:setAnchorPoint(cc.p(0,0.5))
        tiptxt:setFontSize(24)
        tiptxt:setColor(cc.c3b(254, 253, 54))
        bgSprite:addChild(tiptxt)
    end


    local tipPrice = display.newSprite("hall/pochan/"..priceTextArray[self.kind]):addTo(bgSprite):align(display.CENTER, 94, 420)
    local item2Pos 
    local goldDes2Pos
    local vipPos
    if gold1Array[self.kind] ~= "" then
        local itemBg = display.newSprite("hall/libao/itembg.png"):addTo(bgSprite):align(display.CENTER, 178, 320)
        local item = display.newSprite("hall/shop/"..gold1Array[self.kind]):addTo(bgSprite):align(display.CENTER, 178, 320)

        ---price
        local goldDes1 = ccui.Text:create("",FONT_ART_TEXT,24)
        goldDes1:setString(goldDes1Array[self.kind])
        goldDes1:setFontSize(24)
        goldDes1:setColor(cc.c4b(255, 255, 0, 255))
        goldDes1:enableOutline(cc.c4b(0,0,0,200), 2)
        goldDes1:setPosition(178,233)
        bgSprite:addChild(goldDes1)
        self.goldDes1 = goldDes1

        display.newSprite("hall/libao/plus.png"):addTo(bgSprite,1):align(display.CENTER, 300, 320)
        display.newSprite("hall/pochan/zeng.png"):addTo(bgSprite,1):align(display.CENTER, 360, 350)
        item2Pos = cc.p(432, 320)
        goldDes2Pos = cc.p(432,233)
        vipPos = cc.p(489, 356)
    else
        item2Pos = cc.p(323, 320)
        goldDes2Pos = cc.p(321,233)
        vipPos = cc.p(411, 356)
    end
    --赠送
    local itemBg2 = display.newSprite("hall/libao/itembg.png"):addTo(bgSprite):align(display.CENTER, item2Pos.x, item2Pos.y)
    local item2 = display.newSprite("hall/shop/"..gold2Array[self.kind]):addTo(bgSprite):align(display.CENTER, item2Pos.x, item2Pos.y)

    local goldDes2 = ccui.Text:create("",FONT_ART_TEXT,24)
    goldDes2:setString(goldDes2Array[self.kind])
    goldDes2:setPosition(goldDes2Pos)
    goldDes2:setFontSize(24)
    goldDes2:setColor(cc.c4b(255, 255, 0,255))
    goldDes2:enableOutline(cc.c4b(0,0,0,200), 2)
    bgSprite:addChild(goldDes2)

    if zuanIconArray[self.kind] ~= "" then
        local vip = ccui.ImageView:create("hall/shop/vipWord.png")
        vip:setPosition(vipPos)
        bgSprite:addChild(vip)
        local zuan = ccui.ImageView:create("hall/shop/"..zuanIconArray[self.kind])
        zuan:setPosition(49, 45)
        vip:addChild(zuan)
    end

    --刷新按钮
    local changeShop = ccui.Button:create("hall/pochan/changeGift.png","hall/pochan/changeGift.png")
    changeShop:setPosition(559, 455)
    changeShop:setAnchorPoint(cc.p(0.32,0.99))
    changeShop:setPressedActionEnabled(true)
    changeShop:addTouchEventListener(
        function ( sender,eventType )
            if eventType == ccui.TouchEventType.ended then
                self:refreshUI()
            end
        end
        )

    changeShop:addTo(bgSprite)

    --免费按钮
    local goFree = ccui.Button:create("common/button_blue.png","common/button_blue.png")
    goFree:setPosition(185, 70)
    goFree:setZoomScale(0.1)
    goFree:setPressedActionEnabled(true)
    goFree:setTitleText("换场")
    goFree:setTitleFontSize(30)
    goFree:setTitleFontName(FONT_ART_BUTTON)
    goFree:setTitleColor(cc.c4b(255, 255, 255,255))
    goFree:getTitleRenderer():enableOutline(COLOR_BTN_GREEN,2)
    goFree:addTouchEventListener(
        function ( sender,eventType )
            if eventType == ccui.TouchEventType.ended then
                self:goFreeHandler()
            end
        end
        )
    bgSprite:addChild(goFree)

    --购买按钮
    local getbutton = ccui.Button:create("common/button_green.png","common/button_green.png")
    -- getbutton:setScale9Enabled(true)
    -- getbutton:setContentSize(cc.size(157*1.16, 73*1.05))
    getbutton:setPosition(450, 70)
    getbutton:setZoomScale(0.1)
    getbutton:setPressedActionEnabled(true)
    getbutton:setTitleText("获取礼包")
    getbutton:setTitleFontSize(30)
    getbutton:setTitleFontName(FONT_ART_BUTTON)
    getbutton:setTitleColor(cc.c4b(255, 255, 255,255))
    getbutton:getTitleRenderer():enableOutline(COLOR_BTN_GREEN,2)
    getbutton:addTouchEventListener(
        function ( sender,eventType )
            if eventType == ccui.TouchEventType.ended then
                self:getGift()
            end
        end
        )
    bgSprite:addChild(getbutton)

    --banner
    display.newSprite("hall/shop/zsgold2.png"):addTo(bgSprite):align(display.CENTER, 10, 202)
    display.newSprite("hall/shop/zsgold5.png"):addTo(bgSprite):align(display.CENTER, 630, 30)


end

function FirstPayGiftLayer:goFreeHandler()
    RunTimeData:onClickFastStart()
end
function FirstPayGiftLayer:refreshUI()
    self:removeAllChildren()
    self:createUI(self.giftkind%self.kindCounts+1, self.tipStr)
    self.giftkind = self.giftkind + 1
end
function FirstPayGiftLayer:getGift()
	-- body
    local index = self.kind
    local inReview = false;
    if OnlineConfig_review == nil or OnlineConfig_review == "on" then
        inReview = true;
    end
    if inReview then
        self.productTypeArr = {232,233,234}
    end
    local args = {packageID = self.productTypeArr[index],productId = self.productIDArr[index], productPrice = self.productPrice[index]}

    if true == PlatformGetChannel() then
        if AppChannel == "CMCC" then
            PlatformCMCCPurchases(args)

        elseif AppChannel == "CTCC" then
            PlatformCTCCPurchases(args)

        else
            PlatformAppPurchases(args)
        end
    else

        PlatformAppPurchases(args); 
    end
    print("productID:"..self.productIDArr[index],"productTypeArr",self.productTypeArr[index]);
    print("args",unpack(args))
    -----模拟测试充值成功
        --[[
        UserService:sendQueryInsureInfo()
        local function onInterval(dt)
            
			UserService:sendQueryInsureInfo()
            UserService:AppPurchaseResult()
            print("----------------充值成功回调")
        end
        local scheduler = require("framework.scheduler")
        scheduler.performWithDelayGlobal(onInterval, 3)]]

end
return FirstPayGiftLayer