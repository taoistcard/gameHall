
-- 投注界面--金豆场
-- Author: <zhaxun>
-- Date: 2015-10-07 09:19:22
--

require("landlord.CMD_LandlordMsg")

local GameItemFactory = require("commonView.GameItemFactory"):getInstance()

local EffectFactory = require("commonView.DDZEffectFactory")


local ViewCoupon2Layer = class( "ViewCoupon2Layer", function() return display.newLayer() end)

function ViewCoupon2Layer:ctor(param)
	self:setNodeEventEnabled(true)
    self:setTouchEnabled(true)
    self:setTouchSwallowEnabled(false)
    self.rankType = 1

	-- 金币池
    local liquan = require("commonView.Coupon2View").new({lisenter=handler(self,self.onClick)})
    liquan:align(display.CENTER, 710, 530)
    self:addChild(liquan)
    liquan:setValide(true)

    -- 效果
	local ani = EffectFactory:getInstance():getCouponLightAnimation()
    display.newSprite():addTo(liquan):runAction(cc.RepeatForever:create(cc.Animate:create(ani)))


	self:createUI()
    self:onClickItem(1)
end

function ViewCoupon2Layer:onEnter()

    
    -- QueryService:addEventListener(QueryService.QUERY_LISTENER, handler(self, self.onRequestInfoFinished))

    
    -- self.handler_AVATARDOWNLOADURL = UserService:addEventListener(HallCenterEvent.EVENT_AVATARDOWNLOADURL, handler(self, self.customFaceUrlBackHandler))

    -- QueryService:sendHappyBeanRankPacket()
    -- QueryService:sendHisHappyBeanRankPacket()
    
end

function ViewCoupon2Layer:onExit()
	-- QueryService:removeEventListenersByEvent(QueryService.QUERY_LISTENER)

    
 --    UserService:removeEventListener(self.handler_AVATARDOWNLOADURL)

end

function ViewCoupon2Layer:createUI()
	local winSize = cc.Director:getInstance():getWinSize()
    -- 蒙板
    local maskLayer = ccui.ImageView:create()
    maskLayer:loadTexture("common/black.png")
    maskLayer:setOpacity(153)
    maskLayer:setScale9Enabled(true)
    maskLayer:setCapInsets(cc.rect(4,4,1,1))
    maskLayer:setContentSize(cc.size(winSize.width, winSize.height));
    maskLayer:setPosition(cc.p(display.cx, display.cy));
    maskLayer:setTouchEnabled(true);
    self:addChild(maskLayer)
	self.maskLayer = maskLayer
	self.maskLayer:hide()

	local file = nil
	local vx = -100
	local vy = 50
	local sharedSpriteFrameCache = cc.SpriteFrameCache:getInstance()
	if true then
		--光圈
		local effect = display.newSprite("common/effect_light.png"):addTo(maskLayer):align(display.CENTER, display.cx, display.cy + 220)
		effect:scale(2.0)
		effect:runAction(cc.RepeatForever:create(cc.RotateBy:create(3.0, 360)))
		
		--窗体
		local bgSize = cc.size(710, 500)
        local bgSprite = ccui.ImageView:create("common/pop_bg.png");
	    bgSprite:setScale9Enabled(true);
	    bgSprite:setContentSize(bgSize);
	    bgSprite:setPosition(cc.p(winSize.width / 2, winSize.height / 2));
	    bgSprite:addTo(maskLayer)
	    self.bgImage = bgSprite

	
		local leftLoudspeaker = display.newSprite("#animationSuccess1.png")
		leftLoudspeaker:setPosition(bgSize.width/2-150, bgSize.height)
		leftLoudspeaker:addTo(bgSprite)

		local animation = EffectFactory:getInstance():getAnimationSuccess()
		cc.Animate:create(animation)

		leftLoudspeaker:runAction(cc.RepeatForever:create(
                                    cc.Sequence:create(
                                        cc.Animate:create(animation),
                                        cc.DelayTime:create(0.0))))

		local rightLoudspeaker = display.newSprite("#animationSuccess1.png")
		rightLoudspeaker:setPosition(bgSize.width/2+150, bgSize.height)
		rightLoudspeaker:addTo(bgSprite)
		rightLoudspeaker:setScaleX(-1)
		local animation2 = EffectFactory:getInstance():getAnimationSuccess()
		cc.Animate:create(animation2)

		rightLoudspeaker:runAction(cc.RepeatForever:create(
                                    cc.Sequence:create(
                                        cc.Animate:create(animation2),
                                        cc.DelayTime:create(0.0))))

		--title
		local title = display.newSprite("common/title.png")
		title:addTo(bgSprite,2)
		title:align(display.CENTER, bgSize.width/2, bgSize.height + 10)

		--txt
    	local titleword = display.newSprite("coupon/title.png")
	    titleword:setPosition(153, 74)
	    title:addChild(titleword)


	    --关闭按钮
        local exit = ccui.Button:create("common/close.png");
	    exit:setPosition(cc.p(680,480));
	    exit:addTo(bgSprite);
	    exit:setPressedActionEnabled(true);
	    exit:addTouchEventListener(
	        function(sender,eventType)
	            if eventType == ccui.TouchEventType.ended then

	                self:onClickClose()

	            end
	        end
	    )

	    --特效
	    local texture2d = cc.Director:getInstance():getTextureCache():addImage("effect/XS.png");
		local light = cc.ParticleSystemQuad:create("effect/XS.plist");
		light:setTexture(texture2d);
		light:align(display.CENTER, bgSize.width/2, bgSize.height + 10)
		light:setScale(2)
		light:addTo(bgSprite,1)

		-- local EffectFactory = require("commonView.DDZEffectFactory");
		-- local commodityLightAnimation = EffectFactory:getInstance():getCommodityAnimation();
		-- commodityLightAnimation:setPosition(145,45);
		-- title:addChild(commodityLightAnimation);
		-- --commodityLightAnimation:getAnimation():setSpeedScale(math.random(1,5) / 5);
		-- commodityLightAnimation:getAnimation():setSpeedScale(0.3);

	    local titleLightAnimation = EffectFactory:getInstance():getShopAnimation();
	    titleLightAnimation:setPosition(cc.p(150,50));
	    title:addChild(titleLightAnimation);


	    ------------------排行信息--------------
	    --bg
	    local panel = ccui.ImageView:create("common/panel.png")
	    panel:setScale9Enabled(true);
	    panel:setContentSize(cc.size(540,380));
	    panel:setPosition(370, 250)
	    bgSprite:addChild(panel)

	   	local btnToday = ccui.Button:create("coupon/btnToday.png","coupon/btnToday1.png","coupon/btnToday1.png");
	    btnToday:setPosition(cc.p(75,330))
	    btnToday:setPressedActionEnabled(true)
	    btnToday:addTouchEventListener(
	                function(sender,eventType)
	                    if eventType == ccui.TouchEventType.ended then
	                    	self:onClickItem(1)
	                    end
	                end
	            )
	    bgSprite:addChild( btnToday)
	    self.btnToday = btnToday


	   	local btnYesterday = ccui.Button:create("coupon/btnYesterday.png","coupon/btnYesterday1.png","coupon/btnYesterday1.png");
	    btnYesterday:setPosition(cc.p(75,200))
	    btnYesterday:setPressedActionEnabled(true)
	    btnYesterday:addTouchEventListener(
	                function(sender,eventType)
	                    if eventType == ccui.TouchEventType.ended then
	                        self:onClickItem(2)
	                    end
	                end
	            )
	    bgSprite:addChild(btnYesterday)
	    self.btnYesterday = btnYesterday


        self.listView = ccui.ListView:create()
        -- set list view ex direction
        self.listView:setDirection(ccui.ScrollViewDir.vertical)
        self.listView:setBounceEnabled(true)
        self.listView:setContentSize(cc.size(505, 360))
        self.listView:setPosition(17,10)
        panel:addChild(self.listView)
        -- ListView点击事件回调
        local function listViewEvent(sender, eventType)
            -- 事件类型为点击结束
            if eventType == ccui.ListViewEventType.ONSELECTEDITEM_END then
                print("select child index = ",sender:getCurSelectedIndex())
            end
        end
        -- 设置ListView的监听事件
        self.listView:addEventListener(listViewEvent)

        --我的排名
        local itemName = ccui.Text:create("我的排名：","",20)
        itemName:setTextColor(cc.c4b(0xf9,0xfa,0x83,255))
        itemName:setAnchorPoint(cc.p(0,0.5))
        itemName:setPosition(cc.p(117,46))
        bgSprite:addChild(itemName)

        local itemName = ccui.Text:create("第3名","",20)
        itemName:setTextColor(cc.c4b(0xf9,0xfa,0x83,255))
        itemName:setAnchorPoint(cc.p(0,0.5))
        itemName:setPosition(cc.p(220,46))
        bgSprite:addChild(itemName)
        self.myRankLabel = itemName

	    --banner
	    -- display.newSprite("hall/shop/zsgold2.png"):addTo(bgSprite):align(display.CNETER,0,100)
	    -- display.newSprite("hall/shop/zsgold5.png"):addTo(bgSprite):align(display.CNETER,bgSize.width +20,150)
		
		--button readme
	    local vipInfoBtnEffect = ccui.ImageView:create("hall/vipInfo/vipInfoBtnEffect.png")
	    vipInfoBtnEffect:setPosition(cc.p(bgSize.width,370))
	    bgSprite:addChild(vipInfoBtnEffect)
	    local action = cc.RepeatForever:create(cc.RotateBy:create(0.5, 90)) 
	    vipInfoBtnEffect:runAction(action)
	    local vipInfoBtn = ccui.Button:create("coupon/readme.png","coupon/readme.png");
	    vipInfoBtn:setPosition(cc.p(bgSize.width,368))
	    vipInfoBtn:setPressedActionEnabled(true)
	    vipInfoBtn:addTouchEventListener(
	                function(sender,eventType)
	                    if eventType == ccui.TouchEventType.ended then
	                        self:onClickRule()
	                    end
	                end
	            )
	    bgSprite:addChild( vipInfoBtn)
	end
end

function ViewCoupon2Layer:onClickItem(index)
	if index == 1 then
		self.btnToday:setEnabled(false)
		self.btnToday:setBright(false)
		self.btnYesterday:setEnabled(true)
		self.btnYesterday:setBright(true)
        self.rankType = 1

	elseif index == 2 then
		self.btnToday:setEnabled(true)
		self.btnToday:setBright(true)
		self.btnYesterday:setEnabled(false)
		self.btnYesterday:setBright(false)
        self.rankType = 2

	end

    -- self:onRequestRankingResult()
end

function ViewCoupon2Layer:onRequestRankingResult()
    -- 获取排行榜数据
    local myRanking = 0
    local rankingArray
    if self.rankType == 1 then
        rankingArray = QueryService:getRankingHappyBeans()
    elseif self.rankType == 2 then
        rankingArray = QueryService:getRankingHisHappyBeans()
    end
    -- 如果排行榜没有数据，那么发送获取排行榜数据请求
    if(rankingArray == nil or #rankingArray == 0) then
        -- queryService:queryWealthRanking()
        print("rankingArray",rankingArray)
        if rankingArray then
            print("#rankingArray",#rankingArray)
        end
    else
        self.listView:removeAllItems()
        local count = #rankingArray
        print("排行榜的个数= === ",count)
        -- 添加自定义item
        for i = 1, count do
            local bangItemLayer = ccui.ImageView:create()
            bangItemLayer:loadTexture("common/list_item.png")
            bangItemLayer:setScale9Enabled(true)
            bangItemLayer:setContentSize(cc.size(505,92))
            bangItemLayer:setCapInsets(cc.rect(50,40,10,10))
            bangItemLayer:ignoreAnchorPointForPosition(true)
            bangItemLayer:setName("ListItem")
            bangItemLayer:setTag(i)
            --树叶装饰
            display.newSprite("hall/room/list_banner.png", 450, 35):addTo(bangItemLayer)

            -- 排名图片
            local itemRankImage = ccui.ImageView:create()
            itemRankImage:loadTexture("hall/room/hall_bang_1.png")
            itemRankImage:setPosition(cc.p(40,42+10))
            bangItemLayer:addChild(itemRankImage)
            itemRankImage:setName("itemRankImage")
            -- 排名名字
            local itemRankLblBG = ccui.ImageView:create()
            itemRankLblBG:loadTexture("hall/room/hall_bang_0.png")
            itemRankLblBG:setPosition(cc.p(40,42))
            bangItemLayer:addChild(itemRankLblBG)
            itemRankLblBG:setName("itemRankLblBG")

            local itemRankLabel = ccui.Text:create("",FONT_ART_TEXT,38)
            itemRankLabel:setTextColor(cc.c4b(140,58,0,255))
            itemRankLabel:setPosition(cc.p(40,40))
            --itemRankLabel:enableOutline(cc.c4b(140,58,0,200), 3)
            bangItemLayer:addChild(itemRankLabel)
            itemRankLabel:setName("itemRankLabel")

            -- 人物头像图片
            local headBg = ccui.ImageView:create()
            headBg:loadTexture("head/frame.png")
            headBg:setCapInsets(cc.rect(45,45,10,10))
            headBg:setScale9Enabled(true)
            headBg:setContentSize(cc.size(85,85))
            headBg:setPosition(cc.p(120+3,45))
            bangItemLayer:addChild(headBg)

            local itemHead = ccui.ImageView:create()
            itemHead:loadTexture("head/default.png")
            itemHead:setScale(0.58)
            itemHead:setPosition(cc.p(116+3,49))
            bangItemLayer:addChild(itemHead)
            itemHead:setName("ItemHead")
            -- 名字
            local itemName = ccui.Text:create("","",22)
            itemName:setTextColor(cc.c4b(140,58,0,255))
            itemName:setAnchorPoint(cc.p(0,0.5))
            itemName:setPosition(cc.p(180,65))
            bangItemLayer:addChild(itemName)
            itemName:setName("ItemName")
            -- 筹码
            local itemScore = ccui.Text:create("","",20)
            itemScore:setTextColor(cc.c4b(140,58,0,255))
            itemScore:setAnchorPoint(cc.p(0,0.5))
            itemScore:setPosition(cc.p(210,25))
            bangItemLayer:addChild(itemScore)
            itemScore:setName("ItemScore")
            --欢乐豆
            local icon = display.newSprite("common/huanledou.png");
            icon:setPosition(cc.p(190,26))
            icon:setScale(0.6);
            bangItemLayer:addChild(icon)

            --金币奖励数量
            if i <= 3 and self.rankType == 2 then
                local icon = display.newSprite("coupon/prize.png");
                icon:setPosition(cc.p(355,44))
                bangItemLayer:addChild(icon)

                local ItemPrize = ccui.Text:create("","",20)
                ItemPrize:setTextColor(cc.c4b(0xff,0xf9,0x43,255))
                ItemPrize:setAnchorPoint(cc.p(0,0.5))
                ItemPrize:enableOutline(cc.c4b(0x68,0x23,0x0d,255), 2)
                ItemPrize:setPosition(cc.p(405,44))
                bangItemLayer:addChild(ItemPrize)
                ItemPrize:setName("ItemPrize")
                if i == 1 then
                    ItemPrize:setString("10万")
                elseif i == 2 then
                    ItemPrize:setString("5万")
                elseif i == 3 then
                    ItemPrize:setString("2万")
                end
            end
            ---------add item-----------------
            local custom_item = ccui.Layout:create()
            custom_item:setTouchEnabled(true)
            custom_item:setContentSize(bangItemLayer:getContentSize())
            custom_item:addChild(bangItemLayer)
            
            self.listView:pushBackCustomItem(custom_item)
        end

        -- 设置item data
        local items_count = table.getn(self.listView:getItems())
        for i = 1, items_count do
            -- 获取当前的名次的排行榜上人的属性
            local itemInfo = rankingArray[i]
            if(itemInfo == nil) then
                break
            end
            -- 返回一个索引和参数相同的项.
            local item = self.listView:getItem( i - 1 )
            local itemLayer = item:getChildByName("ListItem")
            local index = self.listView:getIndex(item)

            -- 排名图片
            local itemRankImage = itemLayer:getChildByName("itemRankImage")
            -- 排名名字
            local itemRankLabelBG = itemLayer:getChildByName("itemRankLblBG")
            local itemRankLabel = itemLayer:getChildByName("itemRankLabel")
            -- 人物头像图片
            local itemHead = itemLayer:getChildByName("ItemHead")
            -- 名字
            local itemName = itemLayer:getChildByName("ItemName")
            -- 筹码
            local itemScore = itemLayer:getChildByName("ItemScore")
            

            itemRankLabel:setString(i)
            -- 排名前三的显示奖杯
            local jaingbeiImage = {"coupon/top1.png","coupon/top2.png","coupon/top3.png"}
            itemRankImage:loadTexture("hall/room/hall_bang_light.png")
            if(i <= 3 ) then
                -- itemRankImageOn = :loadTexture(jaingbeiImage[i])
                local itemRankImageOn = ccui.ImageView:create(jaingbeiImage[i])
                itemRankImageOn:setPosition(40,42)
                itemLayer:addChild(itemRankImageOn)
                local itemStar = ccui.ImageView:create("hall/room/hall_bang_star.png")
                itemLayer:addChild(itemStar)
                itemStar:setPosition(30,32)
                itemStar:setScale(1.5)
                local seq = transition.sequence(
                        {
                            cc.FadeOut:create(0.5),
                            cc.FadeIn:create(0.5)
                        }
                    )
                itemStar:runAction(cc.RepeatForever:create(seq))
                local rotateBy = cc.RotateBy:create(3,360)
                itemRankImage:runAction(cc.RepeatForever:create(rotateBy))
                itemRankImage:setVisible(true)
                itemRankLabel:setVisible(false)
                itemRankLabelBG:setVisible(false)
            else
                itemRankImage:setVisible(false)
                itemRankLabel:setVisible(true)
                itemRankLabelBG:setVisible(true)
            end
            local nickName = FormotGameNickName(itemInfo.nickName,8)
            itemName:setString(nickName)
            
            
            itemScore:setString(FormatNumToString(itemInfo:getUserScore()))
            if itemInfo:getUserID() == DataManager:getMyUserID() then
                local banner = ccui.ImageView:create("coupon/you.png")
                banner:setPosition(2,92)
                banner:setAnchorPoint(cc.p(0,1))
                itemLayer:addChild(banner)
                --我的排名
                myRanking = i
            end

            -- print("faceID==",itemInfo.faceID(),"getTokenID",itemInfo.tokenID(),"nickname",itemInfo.nickName,"userID",itemInfo:getUserID())
            if itemInfo.faceID() >= 1 and itemInfo.faceID() <= 37 then
                itemHead:loadTexture("head/head_"..itemInfo.faceID()..".png")
            elseif itemInfo.faceID() == 999 and itemInfo.tokenID() then
                local imageName = RunTimeData:getLocalAvatarImageUrlByTokenID(itemInfo.tokenID())
                local localmd5 = cc.Crypto:MD5File(imageName)
                -- print("排行榜=====","localmd5",localmd5,"headFile",itemInfo.platformFace,"is_file_exists(imageName)",is_file_exists(imageName))
                if is_file_exists(imageName) and localmd5 == itemInfo.platformFace then
                    head = itemHead:loadTexture(imageName)
                else
                    head = itemHead:loadTexture("head/default.png")
                    PlatformDownloadAvatarImage(itemInfo.platformID,itemInfo.platformFace)
                end
            else
                itemHead:loadTexture("head/default.png")
            end

        end
    end

    if myRanking == 0 then
        self.myRankLabel:setString("未进入榜单")
    else
        self.myRankLabel:setString("第"..myRanking.."名")
    end

end
--下载头像回调
function ViewCoupon2Layer:customFaceUrlBackHandler(event)
    -- body
    print("customFaceUrlBackHandler下载头像回调event.url",event.url,"tokenID=",event.tokenID)

    self:refreshRank(event)
end

function ViewCoupon2Layer:refreshRank(event)
    local tokenID = event.tokenID
    -- 获取排行榜数据
    local rankingArray
    if self.rankType == 1 then
        rankingArray = QueryService:getRankingHappyBeans()
    elseif self.rankType == 2 then
        rankingArray = QueryService:getRankingHisHappyBeans()
    end
    -- 如果排行榜没有数据，那么发送获取排行榜数据请求
    if(rankingArray == nil or #rankingArray == 0) then

    else
 -- 设置item data
        local items_count = table.getn(self.listView:getItems())
        -- print("下载头像回调event-------------------items_count",items_count,"tokenID",tokenID)
        for i = 1, items_count do
            -- 获取当前的名次的排行榜上人的属性
            local itemInfo = rankingArray[i]
            if(itemInfo == nil) then
                break
            end
            -- 返回一个索引和参数相同的项.
            local item = self.listView:getItem( i - 1 )
            local itemLayer = item:getChildByName("ListItem")
            local index = self.listView:getIndex(item)

             -- 人物头像图片
            local itemHead = itemLayer:getChildByName("ItemHead")
            local itemTokenID = itemInfo.platformID

            if tokenID == itemTokenID then
                local imageName = RunTimeData:getLocalAvatarImageUrlByTokenID(itemInfo.tokenID())
                -- print("下载头像排行榜=====","getTokenID",itemInfo.tokenID(),"localmd5",localmd5,"headFile",itemInfo.platformFace,"is_file_exists(imageName)",is_file_exists(imageName))
                local localmd5 = cc.Crypto:MD5File(imageName)
                if is_file_exists(imageName) and localmd5 == itemInfo.platformFace then
                    
                    self:performWithDelay(function (  )
                        -- print("延迟加载头像",imageName)
                       head = itemHead:loadTexture(imageName)
                    end, 0)
                else
                    head = itemHead:loadTexture("head/default.png")
                    
                end
            end

        end
    end
end

function ViewCoupon2Layer:onClickClose()
	self:setLocalZOrder(2)

	if self.maskLayer and self.maskLayer:isVisible() then
		self.maskLayer:hide()
	end
end

function ViewCoupon2Layer:onClick()
	self:setLocalZOrder(13)

	if self.maskLayer and self.maskLayer:isVisible() then
		self.maskLayer:hide()
	elseif self.maskLayer and not self.maskLayer:isVisible() then
		self.maskLayer:show()
        QueryService:sendHappyBeanRankPacket()
	end

end

function ViewCoupon2Layer:onClickRule()
    local winSize = cc.Director:getInstance():getWinSize()
 
    -- 蒙板
    local maskLayer = ccui.ImageView:create()
    maskLayer:loadTexture("common/black.png")
    maskLayer:setOpacity(153)
    maskLayer:setScale9Enabled(true)
    maskLayer:setCapInsets(cc.rect(4,4,1,1))
    maskLayer:setContentSize(cc.size(winSize.width, winSize.height));
    maskLayer:setPosition(cc.p(display.cx, display.cy));
    maskLayer:setTouchEnabled(true);
    self:addChild(maskLayer)

	--窗体
	local bgSize = cc.size(675, 434)
    local bgSprite = ccui.ImageView:create("common/pop_bg.png");
    bgSprite:setScale9Enabled(true);
    bgSprite:setContentSize(bgSize);
    bgSprite:setPosition(cc.p(winSize.width / 2, winSize.height / 2));
    bgSprite:addTo(maskLayer)
    
    --标题
    local titleSprite = cc.Sprite:create("common/pop_title.png");
    titleSprite:setPosition(cc.p(145, 400));
    bgSprite:addChild(titleSprite);

    local title = ccui.Text:create("规则", FONT_ART_TEXT, 35)
    title:setPosition(cc.p(66,68))
    title:setTextColor(cc.c4b(251,248,142,255))
    title:enableOutline(cc.c4b(137,0,167,200), 3)
    title:addTo(titleSprite)

    --bg
    local panel = ccui.ImageView:create("common/panel.png")
    panel:setScale9Enabled(true);
    panel:setContentSize(cc.size(600,300));
    panel:setPosition(338,210)
    bgSprite:addChild(panel)


    local listView = ccui.ListView:create()
    -- set list view ex direction
    listView:setDirection(ccui.ScrollViewDir.vertical)
    listView:setBounceEnabled(true)
    listView:setContentSize(cc.size(580, 280))
    listView:setPosition(15,10)
    panel:addChild(listView)
    

    local infoArray = {
        "*在免费场，若欢乐豆少于1000万，则每次重新进房间就会补足至1000万；若欢乐豆多于1000万，则当日进出免费场都会保留欢乐豆数值。",
        "*每日系统对所有免费场内玩家的欢乐豆数量进行排名，前三可获得金币奖励哦！奖励在次日00:05前发放至游戏银行内。",
        "第一名奖励：100000金币",
        "第二名奖励：50000金币",
        "第三名奖励：20000金币",
        "*欢乐豆多于1000万，当日在免费场会保留数值，用于排名，次日登录会恢复至1000万"}

    local custom_itemY = 300
    local custom_itemX = 580
    local custom_item = ccui.Layout:create()
    custom_item:setTouchEnabled(true)
    custom_item:setContentSize(cc.size(custom_itemX,custom_itemY))
    custom_item:setAnchorPoint(cc.p(0,1))
    custom_item:setPosition(300, 100)

    local intervalI = {0,3,2,1,1,1,2}

    local length = #infoArray
    for i=1,length do 
        local height = 0
        for j=1,i do
            height = height + intervalI[j]
        end

        infoText = ccui.Text:create("","",20)
        infoText:setPosition(0, custom_itemY-height*30)
        infoText:setAnchorPoint(cc.p(0,1))
        infoText:setColor(cc.c3b(249,247,123))
        infoText:setString(infoArray[i])
        infoText:setTextAreaSize(cc.size(580,300))
        infoText:ignoreContentAdaptWithSize(false)
        infoText:setTextHorizontalAlignment(0)
        infoText:setTextVerticalAlignment(0)
        custom_item:addChild(infoText)
    end
    listView:pushBackCustomItem(custom_item)

    --关闭按钮
    local exit = ccui.Button:create("common/close.png");
    exit:setPosition(cc.p(640,406));
    exit:addTo(bgSprite);
    exit:setPressedActionEnabled(true);
    exit:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                maskLayer:removeSelf()
            end
        end
    )
end

function ViewCoupon2Layer:onRequestInfoFinished(event)
	if event and event.type == 1 then--今日
        print("今日金豆排行返回")
	elseif event and event.type == 2 then--昨日
        print("昨日金豆排行返回")
	end

    self:onRequestRankingResult()
end

return ViewCoupon2Layer