local ShopLayer = class("ShopLayer", function() return display.newLayer() end)
ShopLayer.productTypeArr = {"193","188","189","190","191","192","194"}
ShopLayer.productIDArr = {"huanle_landpoker_1w","huanle_landpoker_12w","huanle_landpoker_50w","huanle_landpoker_100w","huanle_landpoker_200w","huanle_landpoker_500w","huanle_landpoker_500w","huanle_landpoker_6w"}
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
--结构{工作，补助，手续费，充值送}
-- ShopLayer.tipsData = {{8000,2000,4,6000},{34000,5000,3,40000},{66000,8000,2,100000},{132000,10000,1,300000},{330000,15000,0,900000}}
ShopLayer.tipsData = {
			"每日工资金额8000\n金币\n破产补助金币2000\n银行手续费4%\n充值可获得额外\n金币6000",
			"每日工资金额34000\n金币\n破产补助金币5000\n银行手续费3%\n充值可获得额外\n金币40000",
			"每日工资金额66000\n金币\n破产补助金币8000\n银行手续费2%\n充值可获得额外\n金币100000",
			"每日工资金额132000\n金币\n破产补助金币10000\n银行手续费1%\n充值可获得额外\n金币300000",
			"每日工资金额330000\n金币\n破产补助金币15000\n银行免手续费\n充值可获得额外\n金币900000"
			}
-- ShopLayer.zuanIcon = {"zuan1.png","zuan1.png","zuan2.png","zuan3.png","zuan4.png","zuan5.png"}
--@params popFrom 0从大厅弹出1从房间弹出
function ShopLayer:ctor(params,popFrom)
    self.productPrice = {1,5,10,30}
    -- self.super.ctor(self)
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    self:setNodeEventEnabled(true)
    print("params",params)
    self.params = params
    -- self.showSongTag = true;


    self.currentGoldValue = 0
    self.maxExchangeAbleValue = 0
    self.popFrom = popFrom or 0

    self.oneyuanhaspay = RunTimeData:getChongZhiStatus(1) --1元充值状态
    self.leftExchangeValue = RunTimeData:getLeftExchangeBeans() --0;--剩余可兑换元宝
    self.popFrom = RunTimeData:getPopFrom()
    self:createUI(params);

    self:initUI(params)
end
function ShopLayer:getExchangeValue(kind)
	
	if kind == 1 then
        -- if self.popFrom == 0 then
            -- UserService:sendQueryLeftExchangeBeans();
        -- else
        --     
        --     GameCenter:sendQueryLeftExchangeBeans()
        -- end
		
	else
		-- UserService:sendQueryHasBuyGoldByKind("193");
	end
	
end
function ShopLayer:initUI(kind)
    self.kind = kind
    if kind == 1 then
        self:refreshUI();
    else
        self:refreshBuyGoldUI()
        self:refreshButton()
    end
end
function ShopLayer:onEnter()
    self:registerGameEvent()
    self:getExchangeValue(self.params);
    self:refreshUI()
end
function ShopLayer:onExit()
    self:removeGameEvent()
    print("ShopLayer:onExit")
end
function ShopLayer:createUI(kind)
	-- body

	local displaySize = cc.size(display.width, display.height);
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

    local titlelight = ccui.ImageView:create("common/effect_light.png");
    titlelight:setScaleY(0.94)
    titlelight:setScaleX(1.71)
    titlelight:setPosition(cc.p(567,525));
    self:addChild(titlelight);

    --装饰金币或豆子
    if kind == 1 then
        local zsbean1 = ccui.ImageView:create("hall/shop/zsbean1.png");
        zsbean1:setPosition(cc.p(904,508));
        self:addChild(zsbean1);
        local zsbean4 = ccui.ImageView:create("hall/shop/zsbean4.png");
        zsbean4:setPosition(cc.p(1014,323));
        self:addChild(zsbean4);

    else
        local zsgold3 = ccui.ImageView:create("hall/shop/zsgold3.png");
        zsgold3:setPosition(cc.p(919,503));
        self:addChild(zsgold3);
        local zsgold4 = ccui.ImageView:create("hall/shop/zsgold4.png");
        zsgold4:setPosition(cc.p(1014,316));
        self:addChild(zsgold4);
    end
    local bgSprite = ccui.ImageView:create("common/window.png");
    -- bgSprite:setPosition(cc.p(displaySize.width / 2, displaySize.height / 2));
    bgSprite:setScale9Enabled(true);
    bgSprite:setContentSize(cc.size(891, 489));
    bgSprite:setPosition(cc.p(571,259));
    self:addChild(bgSprite);

    local title = ccui.ImageView:create("common/title.png");
    -- title:setScale9Enabled(true);
    -- title:setContentSize(cc.size(891, 489));
    title:setPosition(cc.p(570,545));
    self:addChild(title,1);

    local shopword = ccui.ImageView:create("hall/shop/shopword.png");
    shopword:setPosition(cc.p(567,537));
    self:addChild(shopword,1);

    -- local selectTag = cc.Sprite:create("hall/shop/selectTag.png")
    -- selectTag:setPosition(cc.p(387,493))
    -- self:addChild(selectTag)
    
    --昵称
    local dikuang = ccui.ImageView:create("hall/shop/dikuang.png")
    self:addChild(dikuang)
    dikuang:setPosition(346, 475)
    local frame = ccui.ImageView:create("play3/frame.png")
    dikuang:addChild(frame)
    frame:setPosition(3, 20)
    frame:setScale(0.5)
    local nickname = ccui.Text:create("",FONT_ART_TEXT,30)
    nickname:setColor(cc.c3b(255, 255, 0))
    nickname:setAnchorPoint(cc.p(0,0.5))
    nickname:setPosition(46, 21)
    dikuang:addChild(nickname)
    local headView = require("commonView.GameHeadView").new(1);
    headView:setPosition(cc.p(50,50))
    frame:addChild(headView)
    self.headImage = headView

    
    local myInfo = DataManager:getMyUserInfo()
    nickname:setString(myInfo.nickName)
    self.headImage:setNewHead(myInfo.faceID,myInfo.platformID, myInfo.platformFace)
    self.headImage:setVipHead(myInfo.memberOrder)
    --金币
    local dikuang = ccui.ImageView:create("hall/shop/dikuang.png")
    self:addChild(dikuang)
    dikuang:setPosition(574, 475)
    local goldtop = ccui.ImageView:create("common/gold.png")
    dikuang:addChild(goldtop)
    goldtop:setPosition(16, 20)
    local goldNum = ccui.Text:create("",FONT_ART_TEXT,30)
    goldNum:setColor(cc.c3b(255, 255, 0))
    goldNum:setAnchorPoint(cc.p(0,0.5))
    goldNum:setPosition(46, 21)
    dikuang:addChild(goldNum)
    self.goldNum = goldNum

    --银行
    local dikuang = ccui.ImageView:create("hall/shop/dikuang.png")
    self:addChild(dikuang)
    dikuang:setPosition(801, 475)
    local bank = ccui.ImageView:create("hall/shop/bankbox.png")
    dikuang:addChild(bank)
    bank:setPosition(16, 20)
    -- bank:setScale(0.6)
    local bankNum = ccui.Text:create("",FONT_ART_TEXT,30)
    bankNum:setColor(cc.c3b(255, 255, 0))
    bankNum:setAnchorPoint(cc.p(0,0.5))
    bankNum:setPosition(46, 21)
    dikuang:addChild(bankNum)
    self.bankNum = bankNum


    self:queryHandler()

if kind == 1 then
	self.kind = 1
        local zsbean1 = ccui.ImageView:create("hall/shop/zsbean1.png");
        zsbean1:setPosition(cc.p(129,164));
        self:addChild(zsbean1);
        local zsbean3 = ccui.ImageView:create("hall/shop/zsbean3.png");
        zsbean3:setPosition(cc.p(163,82));
        self:addChild(zsbean3);
        local zsbean5 = ccui.ImageView:create("hall/shop/zsbean5.png");
        zsbean5:setPosition(cc.p(1021,124));
        self:addChild(zsbean5);
	local panel = ccui.ImageView:create("common/panel.png")
	panel:setScale9Enabled(true);
    panel:setContentSize(cc.size(132*5.50, 132*1.62));
    panel:setPosition(cc.p(575,304+ly));
    self:addChild(panel);

	local text1 = ccui.Text:create()
    text1:setString("每日兑换上限：")
    text1:setFontSize(24)
    text1:setColor(cc.c3b(248,255,0,255))
    text1:setPosition(307, 430)
    text1:enableOutline(cc.c4b(151,68,34,255), 2)
    self:addChild(text1)

    local maxExchange = ccui.Text:create("",FONT_NORMAL,24)
    maxExchange:setString("10万")
    maxExchange:setFontSize(24)
    maxExchange:setColor(cc.c4b(240,49,34,255))
    maxExchange:setPosition(403, 431)
    maxExchange:enableOutline(cc.c4b(132,11,14), 2)
    self:addChild(maxExchange)
    self.maxExchange = maxExchange;

	local text2 = ccui.Text:create("",FONT_NORMAL,24)
    text2:setString(",今日还可兑换")
    text2:setFontSize(24)
    text2:setColor(cc.c3b(248,255,0,255))
    text2:setPosition(510, 430)
    text2:enableOutline(cc.c4b(151,68,34,255), 2)
    self:addChild(text2)

    local leftExchange = ccui.Text:create("",FONT_NORMAL,24)
    leftExchange:setString("0万")
    leftExchange:setFontSize(24)
    leftExchange:setColor(cc.c4b(143,231,0,255))
    leftExchange:setPosition(609, 430)
    leftExchange:enableOutline(cc.c4b(36,68,0,255), 2)
    self:addChild(leftExchange)
    self.leftExchange = leftExchange;

	-- local text3 = ccui.Text:create()
 --    text3:setString("*1金币=1欢乐豆")
 --    text3:setFontSize(24)
 --    text3:setColor(cc.c3b(255, 255, 0))
 --    text3:setPosition(901, 397)
 --    self:addChild(text3)

 --上面的当前金币和欢乐豆

    local goldIconCurrent = ccui.ImageView:create("common/gold.png")
    goldIconCurrent:setPosition(677, 423)
    self:addChild(goldIconCurrent)

	-- local text4 = ccui.Text:create()
 --    text4:setString("当前金币：")
 --    text4:setFontSize(24)
 --    text4:setColor(cc.c3b(226, 195, 14))
 --    text4:setPosition(825, 433)
 --    self:addChild(text4)


    local currentGold = ccui.Text:create("","",24)
    currentGold:setString(FormatNumToString(0))
    currentGold:setPosition(742, 423)
    currentGold:setColor(cc.c3b(254,255,227))
    -- currentGold:setScale(0.67)
    self:addChild(currentGold)
    self.currentGold = currentGold;
    self.currentGold:retain()

    local beanIconCurrent = ccui.ImageView:create("common/huanledou.png")
    beanIconCurrent:setPosition(825, 423)
    self:addChild(beanIconCurrent)

    local currentBean = ccui.Text:create("","",24)
    currentBean:setString(FormatNumToString(0))
    currentBean:setPosition(890, 423)
    currentBean:setColor(cc.c3b(254,255,227))
    -- currentGold:setScale(0.67)
    self:addChild(currentBean)
    self.currentBean = currentBean;
    self.currentBean:retain()
    -- local goldIconBg = cc.Sprite:create("common/effect_light.png")
    -- goldIconBg:setPosition(319,307)
    -- self:addChild(goldIconBg)
    -- goldIconBg:setScale(0.8)

    -- local goldIconShadow = cc.Sprite:create("common/common_shadow.png")
    -- goldIconShadow:setPosition(319,282)
    -- self:addChild(goldIconShadow)
    local beanbg = cc.Sprite:create("hall/shop/beanBg.png")
    beanbg:setPosition(319+100,307+ly)
    beanbg:setScaleX(-1)
    self:addChild(beanbg)

    local goldIcon = cc.Sprite:create("common/huanledou.png")
    goldIcon:setPosition(311, 310+ly);
    self:addChild(goldIcon)

    -- local beanIconBg = cc.Sprite:create("common/effect_light.png")
    -- beanIconBg:setPosition(836,307)
    -- self:addChild(beanIconBg)
    -- beanIconBg:setScale(0.8)

    -- local beanIconShadow = cc.Sprite:create("common/common_shadow.png")
    -- beanIconShadow:setPosition(833,283)
    -- self:addChild(beanIconShadow)

    local beanbg = cc.Sprite:create("hall/shop/beanBg.png")
    beanbg:setPosition(833-100,307+ly)
    self:addChild(beanbg)

    local beanIcon = cc.Sprite:create("hall/shop/bean.png")
    beanIcon:setPosition(836, 316+ly);
    self:addChild(beanIcon)


        local cuntips = cc.Sprite:create("hall/shop/qipao.png")
    cuntips:setPosition(355, 375+ly)
    self:addChild(cuntips)
    self.cuntips = cuntips;
    -- local cuntxt = display.newBMFontLabel({
    --     text = "0",
    --     font = "fonts/jinbiSZ.fnt",
    --     --align = cc.ui.TEXT_ALIGN_LEFT,
    --     x = 250,
    --     y = 197,
    -- })
    local cuntxt = ccui.Text:create("",FONT_ART_TEXT,22)
    cuntxt:setString("0")
    cuntxt:setPosition(355, 390+ly)
    cuntxt:setColor(cc.c4b(248, 255, 255,255))
    cuntxt:enableOutline(cc.c4b(160,86,15,255), 2)
    self:addChild(cuntxt)
    self.cuntxt = cuntxt;

    local hld = ccui.Text:create("",FONT_ART_TEXT,22)
    hld:setString("欢乐豆")--金币
    hld:setPosition(355, 365+ly)
    hld:setColor(cc.c4b(248, 255, 255,255))
    hld:enableOutline(cc.c4b(160,86,15,255), 2)
    self:addChild(hld)
    self.hld = hld;





    local leftGold = ccui.Text:create("",FONT_ART_TEXT,30)
    leftGold:setString("0万")--金币
    leftGold:setPosition(318, 249-40)
    leftGold:setColor(cc.c4b(255, 255, 0,255))
    leftGold:enableOutline(cc.c4b(159,68,38,200), 2)
    -- leftGold:setScale(0.67)
    self:addChild(leftGold)
    self.leftGold = leftGold;

    local rightGold = ccui.Text:create("",FONT_ART_TEXT,30)
    rightGold:setString("0万")--欢乐豆
    rightGold:setPosition(840, 249-40)
    rightGold:setColor(cc.c4b(255, 255, 0,255))
    rightGold:enableOutline(cc.c4b(159,68,38,200), 2)
    -- rightGold:setScale(0.67)
    self:addChild(rightGold)
    self.rightGold = rightGold;


    local exchangeprogress = cc.ControlSlider:create("hall/shop/exchangeProgressBg.png","hall/shop/exchangeProgressNow.png","hall/shop/exchangeProgressSlide.png")
    self:addChild(exchangeprogress)
    exchangeprogress:setPosition(577, 293)
    exchangeprogress:setMinimumValue(0);
    exchangeprogress:setMaximumValue(10);
    exchangeprogress:registerControlEventHandler(
        function ( sender )
            self:exchangeprogressHandler(exchangeprogress);
        end,
        cc.CONTROL_EVENTTYPE_VALUE_CHANGED
        )
    self.exchangeprogress = exchangeprogress;
    --print("create===self.exchangeprogress",tostring(self.exchangeprogress))

    local exchangeGoldBg = ccui.ImageView:create("hall/shop/exchangeGoldBg.png")
    exchangeGoldBg:setPosition(600, 233)
    self:addChild(exchangeGoldBg)
    local costGold = ccui.ImageView:create("common/gold.png")
    costGold:setPosition(547, 233)
    costGold:setScale(0.67)
    self:addChild(costGold)

    local costGoldText = ccui.Text:create("",FONT_ART_TEXT,24)
    costGoldText:setString("0万")--金币
    costGoldText:setPosition(600, 233)
    costGoldText:setColor(cc.c4b(255, 255, 249,255))
    costGoldText:enableOutline(cc.c4b(219,3,30,200), 2)
    self:addChild(costGoldText)
    self.costGoldText = costGoldText;

    local exchangeButton = ccui.Button:create("common/common_button3.png","common/common_button3.png","common/common_button0.png");--common/common_button3.png
		    exchangeButton:setScale9Enabled(true)
		    exchangeButton:setContentSize(163*1.13,72)
		    exchangeButton:setPosition(cc.p(568,130));
        	
		    exchangeButton:setPressedActionEnabled(true);
--		    exchangeButton:setTag(100+i)		
            exchangeButton:setTitleFontName(FONT_ART_BUTTON);    
		    exchangeButton:setTitleFontSize(28)            
            exchangeButton:setTitleText("兑换");
            exchangeButton:getTitleRenderer():enableOutline(COLOR_BTN_GREEN,2)
            self:addChild(exchangeButton);
		    exchangeButton:addTouchEventListener(
		        function(sender,eventType)
		            if eventType == ccui.TouchEventType.ended then
		                self:exchangebeanHandler(sender);
		            end
		        end
		    )
    self.exchangeButton = exchangeButton
else
    if kind == 2 then
        --todo
    
        local zsgold2 = ccui.ImageView:create("hall/shop/zsgold2.png");
        zsgold2:setPosition(cc.p(128,166));
        self:addChild(zsgold2);
        local zsgold1 = ccui.ImageView:create("hall/shop/zsgold1.png");
        zsgold1:setPosition(cc.p(171,80));
        self:addChild(zsgold1);
        local zsgold5 = ccui.ImageView:create("hall/shop/zsgold5.png");
        zsgold5:setPosition(cc.p(1021,126));
        self:addChild(zsgold5);
    elseif kind == 3 then
        local zsgold1 = ccui.ImageView:create("hall/shopAndroid/zsyd1.png");
        zsgold1:setPosition(cc.p(171,80));
        self:addChild(zsgold1);
        local zsgold5 = ccui.ImageView:create("hall/shopAndroid/zsyd2.png");
        zsgold5:setPosition(cc.p(1021,126));
        self:addChild(zsgold5);
    elseif kind == 4 then
        local zsgold1 = ccui.ImageView:create("hall/shopAndroid/zszfb1.png");
        zsgold1:setPosition(cc.p(171,80));
        self:addChild(zsgold1);
        local zsgold5 = ccui.ImageView:create("hall/shopAndroid/zszfb2.png");
        zsgold5:setPosition(cc.p(1021,126));
        self:addChild(zsgold5);
    elseif kind == 5 then
        local zsgold2 = ccui.ImageView:create("hall/shop/zsgold2.png");
        zsgold2:setPosition(cc.p(128,166));
        self:addChild(zsgold2);
        local zsgold1 = ccui.ImageView:create("hall/shop/zsgold1.png");
        zsgold1:setPosition(cc.p(171,80));
        self:addChild(zsgold1);
        local zsgold5 = ccui.ImageView:create("hall/shop/zsgold5.png");
        zsgold5:setPosition(cc.p(1021,126));
        self:addChild(zsgold5);
    end
    local zuanIcon = {"zuan1.png","zuan1.png","zuan2.png","zuan3.png","zuan4.png","zuan5.png"}
    local beanPrice = {"12万豆","50万豆","98万豆","198万豆","488万豆","500万豆"}
    local goldPrice = {"12万金币","50万金币","98万金币","198万金币","488万金币","5000金币"}
    local beanSong = {1000,2000,3000,4000,5000,6000};
    local goldSong = {100,200,300,400,500,600}
    local beanButtonPrice = {"12万","50万","98万","198万","488万","1万"}
    local beanButtonPriceNum = {"12","50","98","198","488","500"}--一定要number
    self.beanButtonPrice = beanButtonPrice;
    self.beanButtonPriceNum = beanButtonPriceNum;
    local goldButtonPrice = {"12元","50元","98元","198元","488元","1元"}
    local beanIconResouce = {"bean1.png","bean2.png","bean3.png","bean4.png","bean5.png","bean6.png"};
    local goldIconResouce = {"gold1.png","gold2.png","gold3.png","gold4.png","gold5.png","gold6.png"};
    local price = {}
    local iconResource = {}
    local song = {}
    local buttonPrice = {}

	if kind == 1  then
		price = beanPrice
		iconResource = beanIconResouce
		song = beanSong
		buttonPrice = beanButtonPrice
		self.kind = 1
	elseif kind == 2 then
		
		price = goldPrice
		iconResource = goldIconResouce
		song = goldSong
		buttonPrice = goldButtonPrice
		self.kind = 2;
	end
--	selectTag:setPosition(cc.p(754,493))

--vipinfo
    local inReview = false;
    if OnlineConfig_review == nil or OnlineConfig_review == "on" then
        inReview = true;
    end

    if inReview == false then
        
        local vipInfoBtnEffect = ccui.ImageView:create("hall/vipInfo/vipInfoBtnEffect.png")
        vipInfoBtnEffect:setPosition(cc.p(998,370))
        self:addChild(vipInfoBtnEffect)
        local action = cc.RepeatForever:create(cc.RotateBy:create(0.5, 90)) 
        vipInfoBtnEffect:runAction(action)
        local vipInfoBtn = ccui.Button:create("hall/vipInfo/vipInfoBtn.png","hall/vipInfo/vipInfoBtn.png");
        vipInfoBtn:setPosition(cc.p(998,368))
        vipInfoBtn:setPressedActionEnabled(true)
        vipInfoBtn:addTouchEventListener(
            function(sender,eventType)
                if eventType == ccui.TouchEventType.ended then
                    self:vipInfoBtnClickHandler(sender);
                end
            end
        )
        self:addChild( vipInfoBtn)
        self.vipInfoBtn = vipInfoBtn

    end

--  listview
    self.listView = ccui.ListView:create()
    -- set list view ex direction
    self.listView:setDirection(ccui.ScrollViewDir.horizontal)
    self.listView:setBounceEnabled(true)
    self.listView:setContentSize(cc.size(750,329+40))
    self.listView:setAnchorPoint(cc.p(0.5,0.5))
    self.listView:setPosition(583,276)
    self:addChild(self.listView)

end

    -- local beanIcon = ccui.Button:create("hall/shop/beanIcon.png","hall/shop/beanIconSelected.png");
    -- beanIcon:setPosition(cc.p(186,252))
    -- beanIcon:setPressedActionEnabled(true)
    -- beanIcon:addTouchEventListener(
    --             function(sender,eventType)
    --                 if eventType == ccui.TouchEventType.ended then
    --                     self:beanClickHandler(sender);
    --                 end
    --             end
    --         )
    -- self:addChild( beanIcon)
    -- self.beanIcon = beanIcon


    -- local goldIcon = ccui.Button:create("hall/shop/goldIcon.png","hall/shop/goldIconSelected.png");
    -- goldIcon:setPosition(cc.p(186,374))
    -- goldIcon:setPressedActionEnabled(true)
    -- goldIcon:addTouchEventListener(
    --             function(sender,eventType)
    --                 if eventType == ccui.TouchEventType.ended then
    --                     self:goldClickHandler(sender);                        
    --                 end
    --             end
    --         )
    -- self:addChild(goldIcon)
    -- self.goldIcon = goldIcon
    -- if  kind == 1 then
    --     beanIcon:loadTextures("hall/shop/beanIconSelected.png","hall/shop/beanIconSelected.png")
    -- else
    --     goldIcon:loadTextures("hall/shop/goldIconSelected.png","hall/shop/goldIconSelected.png")
    -- end
    
    --根据渠道过滤计费点    
    if true == PlatformGetChannel() then
        if AppChannel == "CMCC" then
            local beanIcon = ccui.Button:create("hall/shopAndroid/ydIcon.png","hall/shopAndroid/ydIconSelected.png");
            beanIcon:setPosition(cc.p(176,374))
            beanIcon:setPressedActionEnabled(true)
            beanIcon:addTouchEventListener(
                        function(sender,eventType)
                            if eventType == ccui.TouchEventType.ended then
                                self:yidongClickHandler(sender);
                            end
                        end
                    )
            self:addChild( beanIcon)
            self.beanIcon = beanIcon


            local goldIcon = ccui.Button:create("hall/shopAndroid/zfbIcon.png","hall/shopAndroid/zfbIconSelected.png");
            goldIcon:setPosition(cc.p(176,212))
            goldIcon:setPressedActionEnabled(true)
            goldIcon:addTouchEventListener(
                        function(sender,eventType)
                            if eventType == ccui.TouchEventType.ended then
                                self:zhifubaoClickHandler(sender);                        
                            end
                        end
                    )
            self:addChild(goldIcon)
            self.goldIcon = goldIcon
            if  kind == 3 then
                beanIcon:setHighlighted(true)
            else
                goldIcon:setHighlighted(true)
            end
        
        end
    end

    local exit = ccui.Button:create("common/close.png");
    exit:setPosition(cc.p(975,479));
    self:addChild(exit);
    exit:setPressedActionEnabled(true);
    exit:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then

                self:removeFromParent();

            end
        end
    )

    local restorePurchaseButton = ccui.Button:create("hall/shop/restoreButton.png");
    restorePurchaseButton:setPosition(cc.p(568,65));
    self:addChild(restorePurchaseButton);
    restorePurchaseButton:setPressedActionEnabled(true);
    restorePurchaseButton:hide()
    restorePurchaseButton:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                print("restorePurchaseButton click!")
                self:dispatchEvent({name=HallCenterEvent.EVENT_SHOW_RESTORELAYER})
            end
        end
    )


    local EffectFactory = require("commonView.DDZEffectFactory");
    local titleLightAnimation = EffectFactory:getInstance():getShopAnimation();
    titleLightAnimation:setPosition(cc.p(567,515));
    self:addChild(titleLightAnimation,1);

end
function ShopLayer:vipInfoBtnClickHandler()
    local vipInfo = require("hall.VipInfoLayer").new()
    self:addChild(vipInfo,1)
end
--移动
function ShopLayer:yidongClickHandler(sender)
    self.kind = 3
    self:removeAllChildren();
    self:createUI(3)

    self:refreshBuyGoldUI()
    self.beanIcon:setHighlighted(true)
    self.goldIcon:setHighlighted(false)
end
--支付宝
function ShopLayer:zhifubaoClickHandler(sender)
    self.kind = 4
    self:removeAllChildren();
    self:createUI(4)

    self:refreshBuyGoldUI()
    self.beanIcon:setHighlighted(false)
    self.goldIcon:setHighlighted(true)
end
function ShopLayer:beanClickHandler(sender)
    self.kind = 1
	self:removeAllChildren();
	self:createUI(1)
	-- self:getExchangeValue(1);
    self:refreshUI();
    self.beanIcon:loadTextures("hall/shop/beanIconSelected.png","hall/shop/beanIconSelected.png")
    self.goldIcon:loadTextures("hall/shop/goldIcon.png","hall/shop/goldIconSelected.png")
end

function ShopLayer:goldClickHandler(sender)
    self.kind = 2
	self:removeAllChildren();
    print("goldClickHandler===self.exchangeprogress",tostring(self.exchangeprogress))
	self:createUI(2)
	-- self:getExchangeValue(2);
    self:refreshBuyGoldUI()
    self.beanIcon:loadTextures("hall/shop/beanIcon.png","hall/shop/beanIconSelected.png")
    self.goldIcon:loadTextures("hall/shop/goldIconSelected.png","hall/shop/goldIconSelected.png")
end

function ShopLayer:exchangeprogressHandler(sender)
	local tag = sender:getTag();
	local value = sender:getValue();

    local scoreNow = self.leftExchangeValue*value/10.0;
    -- local x  = value/10.0*self.leftExchangeValue/10000
    -- x = math.math.floor(x)
    -- print("x=",x)
    local widthmax = self.exchangeprogress:getContentSize().width
    local posX = 295+140+widthmax*value/10.0;
    -- print("scoreNow",scoreNow,"self.score",self.score,"widthmax",widthmax,"posX",posX)
    self.cuntips:setPositionX(posX);
    self.cuntxt:setPositionX(posX)
    self.hld:setPositionX(posX)
    self.selectScore = math.floor(scoreNow/10000)*10000
    if self.max then
        self.selectScore = self.max
        self.max = nil
    end
    local a = self.maxExchangeAbleValue*10000/self.leftExchangeValue*10+0.1
    if self.leftExchangeValue == 0 and value > 0 then
        -- print("a=======",a)
        local nowtime = os.time()
        if nowtime - self.lastTime >1 then
            Hall.showTips("今日可兑换金币已用完！", 1)
            self.lastTime = nowtime
        end
        
        a = 0
        sender:setValue(a)
    end
    -- print("value",value,"a",a,"self.maxExchangeAbleValue",self.maxExchangeAbleValue,"self.leftExchangeValue",self.leftExchangeValue)
    if self.maxExchangeAbleValue*10000 < self.leftExchangeValue and  value >= a  then
        value = self.maxExchangeAbleValue
        
        if value == 0 then
            sender:setValue(0)            
        else
            sender:setValue(a-0.1)            
        end
        local nowtime = os.time()
        if nowtime - self.lastTime >1 and self.firstbeanUI > 0 then
            Hall.showTips("金币不足！", 1)
            self.lastTime = nowtime
        end
        self.firstbeanUI = self.firstbeanUI+1
        self.selectScore = self.maxExchangeAbleValue*10000
        -- print("a",a,"value",value,"self.maxExchangeAbleValue",self.maxExchangeAbleValue)
        self.max = self.selectScore
    end
    --[[if self.selectScore > self.maxExchangeAbleValue*10000 then
        self.selectScore = self.maxExchangeAbleValue*10000
        sender:setValue(self.maxExchangeAbleValue)
        print("self.maxExchangeAbleValue",self.maxExchangeAbleValue)

        self.cuntxt:setString(self:FormatNumToWan(self.selectScore))
        local leftvalue = self.currentGoldValue-self.selectScore

        self.leftGold:setString(FormatNumToString(leftvalue).."金币")--self.leftExchangeValue-self.selectScore
        self.rightGold:setString(self:FormatNumToWan(self.selectScore).."欢乐豆")
        return
    end]]
    -- self.exchangeprogress:setValue(x/self.leftExchangeValue)
    -- print("self.selectScore",self.selectScore,"self:FormatNumToWan(self.selectScore)",self:FormatNumToWan(self.selectScore))
    self.cuntxt:setString("+"..self:FormatNumToWan(self.selectScore))
    local leftvalue = self.currentGoldValue-self.selectScore

    self.leftGold:setString(FormatNumToString(0))--.."金币"--self.leftExchangeValue-self.selectScore
    self.rightGold:setString(self:FormatNumToWan(self.leftExchangeValue))--.."欢乐豆"
    self.costGoldText:setString("-"..self:FormatNumToWan(self.selectScore))
end

function ShopLayer:showZuanTips(sender)
	local tag = sender:getTag();
	print("tag=",tag)
	local index = tag-200;
	local containLayer = sender:getParent();
	if self.tipshow ~= nil and self.tipshow:getParent() ~= nil then
		self.tipshow:removeFromParent()
	end
	if self.tiptxt ~= nil  and self.tiptxt:getParent() ~= nil then
		self.tiptxt:removeFromParent()
	end

	if self.showZuanTipsHandler ~= nil then
		local scheduler = require("framework.scheduler")
		scheduler.unscheduleGlobal(self.showZuanTipsHandler)
	end
        local bgX = 244/2
        local bgY = 314/2
        local vx  = bgX-342
        local vy  = bgY-274
    local tips = cc.Sprite:create("hall/shop/zuanTips.png")
	containLayer:addChild(tips)
	tips:setPosition(246+vx, 305+vy)
	local tiptxt = ccui.Text:create()
	-- tiptxt:setString("每日工资金额\n"..tipsData[index][1].."金币\n破产补助金币"..tipsData[index][2].."\n银行手续费"..tipsData[index][3].."%\n充值可获得额外金币\n"..tipsData[index][4])
	if self.oneyuanhaspay == 0 then
		index = index-1
	end
	local tipInfo = self.tipsData[index]
	if tipInfo == nil then
		tipInfo = self.tipsData[1]
	end
	tiptxt:setString(tipInfo);
	tiptxt:setPosition(233+vx, 334+vy)
	tiptxt:setFontSize(18)
	containLayer:addChild(tiptxt)
	tiptxt:retain()
	tips:retain()
	self.tipshow = tips
	self.tiptxt  = tiptxt

    local function onInterval(dt)
		if self.tipshow ~= nil and self.tipshow:getParent() ~= nil then
			self.tipshow:removeFromParent()
		end
		if self.tiptxt ~= nil  and self.tiptxt:getParent() ~= nil then
			self.tiptxt:removeFromParent()
		end
    end
    local scheduler = require("framework.scheduler")
    local handle = scheduler.performWithDelayGlobal(onInterval, 2)
    self.showZuanTipsHandler = handle
end

function ShopLayer:exchangebeanHandler( sender )

		if self.leftExchangeValue <=0 then
			Hall.showTips("今日可兑换的欢乐豆已达上限！")
			return
		end
    	;
        local dwUserID = DataManager:getMyUserID()
        local currentUserScore = DataManager:getMyUserInfo().tagUserInfo.lScore;

		local wMainID = CMD_LogonServer.MDM_GP_USER_SERVICE
    	local wSubID = CMD_LogonServer.SUB_GP_USER_EXCHAGE_BEANS
	    local data = protocol.hall.treasureInfo_pb.CMD_GP_UserExchageBeans_Pro();

	    data.dwUserID = dwUserID;
	    -- Hall.showTips(dwUserID,1)
	    data.lExchageGold = self.selectScore;
	    data.cdExchageWay = 1;
	    data.szPassword = GetDeviceID();
	    data.szMachineID = GetDeviceID();
	    print("GetDeviceID()=",data.szPassword)
	    local pData = data:SerializeToString()
	    local pDataLen = string.len(pData)
        -- if self.popFrom == 0 then
            
            HallCenter:send(wMainID,wSubID,pData,pDataLen)
        -- else
        --     wMainID = CMD_GameServer.MDM_GR_USER
        --     wSubID = CMD_GameServer.SUB_GR_USER_EXCHAGEBEANS
        --     
        --     GameCenter:sendData(wMainID,wSubID,pData,pDataLen)
        -- end


end
function ShopLayer:buy( sender )
	-- body
	local tag = sender:getTag();
	print("tag=",tag, self.kind)
	local index = tag-100;
    
   	self.currentTime = os.time()

   	
   	-- print("self.currentTime",self.currentTime,"self.lastTime",self.lastTime)
   	if (self.lastTime + 1.5)>self.currentTime then
   		self.lastTime = self.currentTime
   		Hall.showTips("操作过于频繁！",1)
   		return
   	end

    --刷脸测试
    -- local args = {packageID = self.productTypeArr[index],productId = self.productIDArr[index], productName="刷脸测试项", price=1}
    -- FaceVisaAppPurchases(args);
    -- if index > 0 then return end


   	self.lastTime = self.currentTime
    if self.kind == 1 then
    	local buyNum = self.beanButtonPriceNum[index]
    	print("buyNum=",buyNum)
    	local exchangegold = 10000*buyNum;

        local dwUserID = DataManager:getMyUserID()
        local currentUserScore = DataManager:getMyUserInfo().tagUserInfo.lScore;
    	print("currentUserScore=",currentUserScore)
    	if exchangegold>currentUserScore then
    		Hall.showTips("您当前金币的可用余额不足，请充值后再次尝试！",1);
    		return;
    	end
    	local wMainID = CMD_LogonServer.MDM_GP_USER_SERVICE
    	local wSubID = CMD_LogonServer.SUB_GP_USER_EXCHAGE_BEANS
	    local data = protocol.hall.treasureInfo_pb.CMD_GP_UserExchageBeans_Pro();

	    data.dwUserID = dwUserID;
	    -- Hall.showTips(dwUserID,1)
	    data.lExchageGold = exchangegold
	    data.cdExchageWay = 1;
	    data.szPassword = GetDeviceID();
	    data.szMachineID = GetDeviceID();
	    print("GetDeviceID()=",data.szPassword)
	    local pData = data:SerializeToString()
	    local pDataLen = string.len(pData)
	    
	    HallCenter:send(wMainID,wSubID,pData,pDataLen)
	elseif self.kind == 2 or self.kind == 4 then
        --友盟计费点统计
        if index == 1 then
            onUmengEvent("1026")
        elseif index == 2 then
            onUmengEvent("1027")
        elseif index == 3 then
            onUmengEvent("1028")
        elseif index == 4 then
            onUmengEvent("1029")
        elseif index == 5 then
            onUmengEvent("1030")
        elseif index == 6 then
            onUmengEvent("1031")
        elseif index == 7 then
        end
        if index == 7 then
            local args = {packageID = "232",productId = "huanle_landpoker_6w"}
            PlatformAppPurchases(args);
            return 
        end
    	local args = {packageID = self.productTypeArr[index],productId = self.productIDArr[index]}
    	PlatformAppPurchases(args); 
    	print("productID:"..self.productIDArr[index],"productTypeArr",self.productTypeArr[index]);
    	print("args",unpack(args))


    	-- sender:setEnabled(false)
    	--模拟充值成功
	    -- local function onInterval(dt)
     --        onUnitedPlatFormAppPurchaseResult({["resultCode"]=1})
	    -- end
	    -- local scheduler = require("framework.scheduler")
	    -- local handle = scheduler.performWithDelayGlobal(onInterval, 2)
    elseif self.kind == 3 then
        local args = {packageID = self.productTypeArr[index],productId = self.productIDArr[index]}
        PlatformCMCCPurchases(args); 

    elseif self.kind == 5 then
        local args = {packageID = self.productTypeArr[index],productId = self.productIDArr[index],productPrice = self.productPrice[index]}
        PlatformCTCCPurchases(args); 
    end
end
function ShopLayer:refreshUI()
    if self.kind == 1 then
        print("refreshUIself.kind == 1")
    else
        print("refreshUIself.kind == 2")
    end
    
    self.firstbeanUI = 0
    self.leftExchangeValue = RunTimeData:getLeftExchangeBeans()
    -- print("self.leftExchangeValue",self.leftExchangeValue)
	if self.leftExchange then
        self.leftExchange:setString(self:FormatNumToWan(self.leftExchangeValue))
    end
	

	self.leftGold:setString(0)
    self.leftGold:retain()
	self.rightGold:setString(self:FormatNumToWan(self.leftExchangeValue).."欢乐豆")
    
    local beancount = DataManager:getMyUserInfo().beans
    self.currentBean:setString(FormatNumToString(beancount))
    if self.exchangeprogress then
        self.exchangeprogress:setValue(0)
    end
	
	-- self:queryHandler()
end
function ShopLayer:refreshBuyGoldUI()
    self.oneyuanhaspay = RunTimeData:getChongZhiStatus(1)
    local inReview = false;
    if OnlineConfig_review == nil or OnlineConfig_review == "on" then
        inReview = true;
    end

    local zuanIcon0 = {"zuan1.png","zuan1.png","zuan2.png","zuan3.png","zuan4.png","zuan5.png"}
    local zuanIcon1 = {"zuan1.png","zuan2.png","zuan3.png","zuan4.png","zuan5.png","zuan1.png"}
    local goldPrice0 = {"1万金币","12万金币","50万金币","98万金币","198万金币","488万金币"}
    local goldPrice1 = {"12万金币","50万金币","98万金币","198万金币","488万金币","1万金币"}
    local goldSong0 = {"赠送1万","赠送6000","赠送4万","赠送10万","赠送30万","赠送90万"};
    local goldSong1 = {"赠送6000","赠送4万","赠送10万","赠送30万","赠送90万",""};

    if inReview then
        goldPrice0 = {"1万金币","12万金币","50万金币","100万金币","200万金币","500万金币"};
        goldPrice1 = {"12万金币","50万金币","100万金币","200万金币","500万金币","1万金币"}
    end
    
    local beanButtonPriceNum = {"12","50","98","198","488","500"}--一定要number
    self.beanButtonPrice = beanButtonPrice;
    self.beanButtonPriceNum = beanButtonPriceNum;
    local goldButtonPrice0 = {"1元","12元","50元","98元","198元","488元"}
    local goldButtonPrice1 = {"12元","50元","98元","198元","488元","1元"}
    local goldIconResouce0 = {"gold1.png","gold2.png","gold3.png","gold4.png","gold5.png","gold6.png"};
    local goldIconResouce1 = {"gold2.png","gold3.png","gold4.png","gold5.png","gold6.png","gold1.png"};
    local price = {}
    local iconResource = {}
    local song = {}
    local buttonPrice = {}
    local tuijianNum = {0,0,0,0,0,0,0,0,0}--0不推荐1推荐
    local nozuanIcon = {1,1,1,1,1,1,1,1,1}--0显示钻1不显示钻
    local zuanIcon = {}
	if self.oneyuanhaspay == 0 then--今天充值过吗 0:没有 1:已经充值过
		price = goldPrice0
		iconResource = goldIconResouce0
		buttonPrice = goldButtonPrice0
		song = goldSong0
		tuijianNum = {1,1,0,0,0,0}
		nozuanIcon = {1,0,0,0,0,0}
		zuanIcon = zuanIcon0
		self.productTypeArr = {"193","188","189","190","191","192"}
        if inReview then
            self.productTypeArr = {"231","233","234","235","236","237"}
        end
		self.productIDArr = {"huanle_landpoker_1w","huanle_landpoker_12w","huanle_landpoker_50w","huanle_landpoker_100w",
		"huanle_landpoker_200w","huanle_landpoker_500w"}
	elseif self.oneyuanhaspay == 1 then
		price = goldPrice1
		iconResource = goldIconResouce1
		buttonPrice = goldButtonPrice1
		song = goldSong1
		tuijianNum = {1,0,0,0,0,0}
		nozuanIcon = {0,0,0,0,0,1}
		zuanIcon = zuanIcon1
		self.productTypeArr = {"188","189","190","191","192","193"}
        if inReview then
            self.productTypeArr = {"233","234","235","236","237","231"}
        end
		self.productIDArr = {"huanle_landpoker_12w","huanle_landpoker_50w","huanle_landpoker_100w",
		"huanle_landpoker_200w","huanle_landpoker_500w","huanle_landpoker_1w"}
	end
	self.listView:removeAllItems();
	self.buttonArray = {}
    local bgX = 244/2
    local bgY = 314/2
    local vx  = bgX-342
    local vy  = bgY-274
    local total = 6
    local itembgUrl = "hall/shop/itemBg.png"
    local tuijianUrl = "hall/shop/tuijian.png"
    if self.kind == 3 then
        total = 4
        itembgUrl = "hall/shopAndroid/itemBg.png"
        tuijianUrl = "hall/shopAndroid/tuijianBule.png"
        self.productTypeArr = {"257","258","259","260"}
        self.productIDArr = {"30000811695201","30000811695202","30000811695203","30000811695204"}
        iconResource = {"gold1.png","gold2.png","gold3.png","gold4.png"}
        buttonPrice = {"1元","5元","10元","30元"}
        price = {"1万金币","5万金币","10万金币","30万金币"}
        tuijianNum = {1,1,0,0,0,0}
        nozuanIcon = {1,1,0,0,0,0}
        zuanIcon = {"zuan1.png","zuan1.png","zuan1.png","zuan2.png","zuan4.png","zuan5.png"}
    elseif self.kind == 4 then
        --todo
    elseif self.kind == 5 then
        total = 4
        itembgUrl = "hall/shopAndroid/itemBg.png"
        tuijianUrl = "hall/shopAndroid/tuijianBule.png"
        self.productTypeArr = {"257","258","259","260"}
        self.productIDArr = {"30000811695201","30000811695202","30000811695203","30000811695204"}
        iconResource = {"gold1.png","gold2.png","gold3.png","gold4.png"}
        buttonPrice = {"1元","5元","10元","30元"}
        price = {"1万金币","5万金币","10万金币","30万金币"}
        tuijianNum = {1,1,0,0,0,0}
        nozuanIcon = {1,1,0,0,0,0}
        zuanIcon = {"zuan1.png","zuan1.png","zuan1.png","zuan2.png","zuan4.png","zuan5.png"}
    end
	for i=1,total do

		local shopItemLayer = display.newLayer()


        shopItemLayer:setContentSize(cc.size(244-1,314))
        -- shopItemLayer:setCapInsets(cc.rect(50,50,1,1))
        -- shopItemLayer:setAnchorPoint(cc.p(0.5,.5))
        -- shopItemLayer:ignoreAnchorPointForPosition(false)
        shopItemLayer:setName("ListItem")
        shopItemLayer:setTag(i);

        local bg = ccui.ImageView:create()
        bg:loadTexture(itembgUrl)
        bg:setScale9Enabled(true);
        bg:setPosition(bgX, bgY)
        shopItemLayer:addChild(bg)

        local light = ccui.ImageView:create()
        light:loadTexture("common/effect_light.png")
        light:setPosition(cc.p(340+vx,308+vy))
        light:setScale(0.8)
        shopItemLayer:addChild(light)

        local shadow = ccui.ImageView:create()
        shadow:loadTexture("common/common_shadow.png")
        shadow:setPosition(cc.p(339+vx,281+vy))
        shopItemLayer:addChild(shadow)

        local pic = ccui.ImageView:create()
        if self.kind == 3 then
            pic:loadTexture("hall/shopAndroid/"..iconResource[i])
        else
            pic:loadTexture("hall/shop/"..iconResource[i])
        end
        
        pic:setPosition(343+vx, 298+vy)
        shopItemLayer:addChild(pic)
        ------songtag

		---price
		local priceText = ccui.Text:create("",FONT_ART_TEXT,24)
	    priceText:setString(price[i])
	    priceText:setFontSize(24)
	    priceText:setColor(cc.c4b(255, 255, 0,255))
        priceText:enableOutline(cc.c4b(159,68,38,200), 2)
	    priceText:setPosition(343+vx, 238+vy)
	    shopItemLayer:addChild(priceText)

		---song
		local songText = ccui.Text:create("",FONT_ART_TEXT,24)
	    songText:setString(song[i])
	    songText:setFontSize(24)
	    songText:setColor(cc.c4b(166, 255, 0,255))
        songText:enableOutline(cc.c4b(44,68,0,255), 2)
	    songText:setPosition(340+vx, 208+vy)
	    shopItemLayer:addChild(songText)

        if inReview or self.kind == 3 or self.kind == 5 then
            songText:setVisible(false);
        end

        local EffectFactory = require("commonView.DDZEffectFactory");
        local commodityLightAnimation = EffectFactory:getInstance():getCommodityAnimation();
        commodityLightAnimation:setPosition(pic:getPosition() );
        shopItemLayer:addChild(commodityLightAnimation);
        --commodityLightAnimation:getAnimation():setSpeedScale(math.random(1,5) / 5);
        commodityLightAnimation:getAnimation():setSpeedScale(0.3);

		---button buy
        local buy = ccui.Button:create("hall/shop/buyButton.png");--common/common_button3.png
	    -- buy:setScale9Enabled(true)
	    -- buy:setContentSize(186,72)
	    buy:setPosition(cc.p(342+vx,157+vy));
	    shopItemLayer:addChild(buy);
	    buy:setPressedActionEnabled(true);
	    buy:setTag(100+i)
        buy:setTitleFontName(FONT_ART_BUTTON)
	    buy:setTitleText(buttonPrice[i]);
	    buy:setTitleFontSize(30)
        buy:getTitleRenderer():enableOutline(COLOR_BTN_GREEN,2)
	    self.buttonArray[i] = buy
	    buy:addTouchEventListener(
	        function(sender,eventType)
	            if eventType == ccui.TouchEventType.ended then
	                self:buy(sender);
	            end
	        end
	    )
	    if kind == 1 then
	    	local goldImage2 = ccui.ImageView:create()
		    goldImage2:loadTexture("common/gold.png")
		    goldImage2:setPosition(cc.p(343+vx, 298+vy))
		    shopItemLayer:addChild(goldImage2)
	    end
	    if 0 == nozuanIcon[i]  and inReview == false then


            if self.kind == 3 or self.kind == 5 then
                
                local vipword = ccui.Button:create("hall/shop/"..zuanIcon[i]);
                vipword:setPosition(416+vx, 397+vy)
                shopItemLayer:addChild(vipword)
                vipword:setTag(200+i)
                vipword:addTouchEventListener(
                    function ( sender,eventType )
                        if eventType == ccui.TouchEventType.ended then
                            self:showZuanTips(sender);
                        end
                    end
                )
                
                local text = ccui.Text:create("VIP",FONT_ART_TEXT,30)
                text:setColor(cc.c4b(255, 255, 0,255))
                text:enableOutline(cc.c4b(159,68,38,200), 2)
                text:setPosition(-35, 20)
                text:enableOutline(cc.c4b(160,86,15,255), 2)
                vipword:addChild(text)
                local tt = ""
                if i==3 then
                    tt = "送5天"
                elseif i==4 then
                    tt = "送3天"
                end
                local text = ccui.Text:create(tt,FONT_ART_TEXT,20)
                text:setColor(cc.c4b(255, 255, 0,255))
                text:enableOutline(cc.c4b(159,68,38,200), 2)
                text:setPosition(0, -10)
                text:enableOutline(cc.c4b(160,86,15,255), 2)
                vipword:addChild(text)

            else
                local zuan = cc.Sprite:create("hall/shop/"..zuanIcon[i]);
                zuan:setPosition(416+vx, 397+vy)
                shopItemLayer:addChild(zuan)

    		    local vipword = ccui.Button:create("hall/shop/vipWord.png");
    		    vipword:setPosition(406+vx, 382+vy)
    		    shopItemLayer:addChild(vipword)
    		    vipword:setTag(200+i)
    		    vipword:addTouchEventListener(
    		    	function ( sender,eventType )
    		    		if eventType == ccui.TouchEventType.ended then
    		    			self:showZuanTips(sender);
    		    		end
    		    	end
    		    )
            end
	    end

	    if 1 == tuijianNum[i] then
	    	local tuijian = cc.Sprite:create("hall/shop/tuijian.png")
	    	tuijian:setPosition(258+vx, 388+vy)
	    	shopItemLayer:addChild(tuijian)

	    end

        local custom_item = ccui.Layout:create()
        custom_item:setTouchEnabled(true)
        custom_item:setContentSize(shopItemLayer:getContentSize())
        custom_item:addChild(shopItemLayer)
        
        self.listView:pushBackCustomItem(custom_item)
	end
    if inReview then
        local i = 7
        local shopItemLayer = display.newLayer()


        shopItemLayer:setContentSize(cc.size(244-1,314))
        -- shopItemLayer:setCapInsets(cc.rect(50,50,1,1))
        -- shopItemLayer:setAnchorPoint(cc.p(0.5,.5))
        -- shopItemLayer:ignoreAnchorPointForPosition(false)
        shopItemLayer:setName("ListItem")
        shopItemLayer:setTag(i);

        local bg = ccui.ImageView:create()
        bg:loadTexture("hall/shop/itemBg.png")
        bg:setScale9Enabled(true);
        bg:setPosition(bgX, bgY)
        shopItemLayer:addChild(bg)

        local light = ccui.ImageView:create()
        light:loadTexture("common/effect_light.png")
        light:setPosition(cc.p(340+vx,308+vy))
        light:setScale(0.8)
        shopItemLayer:addChild(light)

        local shadow = ccui.ImageView:create()
        shadow:loadTexture("common/common_shadow.png")
        shadow:setPosition(cc.p(339+vx,281+vy))
        shopItemLayer:addChild(shadow)

        local pic = ccui.ImageView:create()
        pic:loadTexture("hall/shop/"..iconResource[1])
        pic:setPosition(343+vx, 298+vy)
        shopItemLayer:addChild(pic)
        ------songtag

        ---price
        local priceText = ccui.Text:create("",FONT_ART_TEXT,24)
        priceText:setString("6万金币")
        priceText:setFontSize(24)
        priceText:setColor(cc.c4b(255, 255, 0,255))
        priceText:enableOutline(cc.c4b(159,68,38,200), 2)
        priceText:setPosition(343+vx, 238+vy)
        shopItemLayer:addChild(priceText)

        ---song
        local songText = ccui.Text:create("",FONT_ART_TEXT,24)
        -- songText:setString(song[i])
        songText:setFontSize(24)
        songText:setColor(cc.c4b(166, 255, 0,255))
        songText:enableOutline(cc.c4b(44,68,0,255), 2)
        songText:setPosition(340+vx, 208+vy)
        shopItemLayer:addChild(songText)

        if inReview then
            songText:setVisible(false);
        end

        local EffectFactory = require("commonView.DDZEffectFactory");
        local commodityLightAnimation = EffectFactory:getInstance():getCommodityAnimation();
        commodityLightAnimation:setPosition(pic:getPosition() );
        shopItemLayer:addChild(commodityLightAnimation);
        --commodityLightAnimation:getAnimation():setSpeedScale(math.random(1,5) / 5);
        commodityLightAnimation:getAnimation():setSpeedScale(0.3);

        ---button buy
        local buy = ccui.Button:create("hall/shop/buyButton.png");--common/common_button3.png
        -- buy:setScale9Enabled(true)
        -- buy:setContentSize(186,72)
        buy:setPosition(cc.p(342+vx,157+vy));
        shopItemLayer:addChild(buy);
        buy:setPressedActionEnabled(true);
        buy:setTag(100+i)
        buy:setTitleFontName(FONT_ART_BUTTON)
        buy:setTitleText("6元");
        buy:setTitleFontSize(30)
        buy:getTitleRenderer():enableOutline(COLOR_BTN_GREEN,2)
        self.buttonArray[i] = buy
        buy:addTouchEventListener(
            function(sender,eventType)
                if eventType == ccui.TouchEventType.ended then
                    self:buy(sender);
                end
            end
        )
        if kind == 1 then
            local goldImage2 = ccui.ImageView:create()
            goldImage2:loadTexture("common/gold.png")
            goldImage2:setPosition(cc.p(343+vx, 298+vy))
            shopItemLayer:addChild(goldImage2)
        end
        if nozuanIcon ~= i and inReview == false then
            local zuan = cc.Sprite:create("hall/shop/"..zuanIcon[1]);
            zuan:setPosition(416+vx, 397+vy)
            shopItemLayer:addChild(zuan)
            local vipword = ccui.Button:create("hall/shop/vipWord.png");
            vipword:setPosition(406+vx, 382+vy)
            shopItemLayer:addChild(vipword)
            vipword:setTag(200+i)
            vipword:addTouchEventListener(
                function ( sender,eventType )
                    if eventType == ccui.TouchEventType.ended then
                        self:showZuanTips(sender);
                    end
                end
            )
        end

        -- if i<=tuijianNum then
        --     local tuijian = cc.Sprite:create("hall/shop/tuijian.png")
        --     tuijian:setPosition(261+vx, 393+vy)
        --     shopItemLayer:addChild(tuijian)

        -- end

        local custom_item = ccui.Layout:create()
        custom_item:setTouchEnabled(true)
        custom_item:setContentSize(shopItemLayer:getContentSize())
        custom_item:addChild(shopItemLayer)
        
        self.listView:pushBackCustomItem(custom_item)
    end
end
function ShopLayer:refreshButton()
	-- for i,v in ipairs(self.buttonArray) do
	-- 	v:setEnabled(true);
	-- end
end
function ShopLayer:FormatNumToWan(value)
    local s = value/10000

	return s.."万"
end
function ShopLayer:queryHandler()
    
    BankInfo:sendQueryRequest()
	print("ShopLayer--queryHandler")
end
function ShopLayer:queryBackHandler(event)
    -- print("queryBackHandler",event.score,event.insure)
    -- self.score = event.score;
    -- self.insure = event.insure;
    self.goldNum:setString(FormatNumToString(event.score))
    self.bankNum:setString(FormatNumToString(event.insure))
    if self.kind == 1 then
        print("self.kind == 1")
    else
        print("self.kind == 2")
        return 
    end
    if self.currentGold ~= nil then
    	self.currentGold:setString(FormatNumToString(event.score))
        self.leftGold:setString(FormatNumToString(event.score).."金币")
        local selectvalue = math.floor(event.score/10000) 
        if event.score<10000 then
            self.leftGold:setColor(cc.c4b(255, 0, 0,255))
        else
            self.leftGold:setColor(cc.c4b(255, 255, 0,255))
        end
        
        if selectvalue*10000 > self.leftExchangeValue then
            selectvalue = self.leftExchangeValue/10000
        end
        self.maxExchangeAbleValue = selectvalue
        -- print("selectvalue",selectvalue)
        self.currentGoldValue = event.score
        local value = selectvalue*10000/self.leftExchangeValue*10+0.1
        if self.leftExchangeValue == 0 then
            value = 0
        end
        self.exchangeprogress:setValue(value)
        if event.score < 10000 or self.leftExchangeValue == 0 then
           self.exchangeButton:setEnabled(false)
           self.exchangeButton:setBright(false)
        else
           self.exchangeButton:setEnabled(true)
           self.exchangeButton:setBright(true)
        end
        -- if self.leftExchangeValue == 0 then
        --    self.exchangeButton:setEnabled(false)
        --    self.exchangeButton:setBright(false)
        -- else
        --    self.exchangeButton:setEnabled(true)
        --    self.exchangeButton:setBright(true)
        -- end
    end
    
    
end
function ShopLayer:getExchangeValueSuccess(event)
    local info = protocol.hall.treasureInfo_pb.CMD_GP_QuerySurplusExchageResult_Pro();
    info:ParseFromString(event.data)
    self.leftExchangeValue = info.lSurplusExchageCount;
    -- Hall.showTips(info.lSurplusExchageCount)
    self:refreshUI();
end
function ShopLayer:getExchangeValueFailure(event)
    local info = protocol.hall.treasureInfo_pb.CMD_GP_UserInsureFailure_Pro();
    info:ParseFromString(event.data)
    
    Hall.showTips(info.szDescribeString)
end
function ShopLayer:getTodayWasNotPaySuccess(event)
    local info = protocol.hall.treasureInfo_pb.CMD_GP_QueryTodayWasnotPayResult_Pro();
    info:ParseFromString(event.data)
    self.oneyuanhaspay = info.dwWasTodayPayed--//今天充值过吗 0:没有 1:已经充值过
    self:refreshBuyGoldUI()
    self:refreshButton()
    -- Hall.showTips(info.dwWasTodayPayed)
end
function ShopLayer:getTodayWasNotPayFailure(event)
    local info = protocol.hall.treasureInfo_pb.CMD_GP_UserInsureFailure_Pro();
    info:ParseFromString(event.data)
    self:refreshButton()
    Hall.showTips(info.szDescribeString)
end
function ShopLayer:exchangeBeanSuccess(event)
	-- self:getExchangeValue(1)
    self:refreshUI();
end
function ShopLayer:registerGameEvent()
    self.bindIds = {}
    self.bindIds[#self.bindIds + 1] = BindTool.bind(AccountInfo, "insure", handler(self, self.refreshUI))
end
function ShopLayer:removeGameEvent()
    for _, bindid in ipairs(self.bindIds) do
        BindTool.unbind(bindid)
    end
end
return ShopLayer