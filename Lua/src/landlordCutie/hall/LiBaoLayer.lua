local LiBaoLayer = class("LiBaoLayer", function() return display.newLayer() end)
local EffectFactory = require("commonView.DDZEffectFactory")
LiBaoLayer.productTypeArr = {"193","194"}
LiBaoLayer.productIDArr = {"huanle_landpoker_1w","huanle_landpoker_6w"}

function LiBaoLayer:ctor(kind)
	-- body
    self.kind = kind

    
    self.handler4 = UserService:addEventListener(HallCenterEvent.EVENT_QUERY_TODAYWASNOTPAY_SUCCESS, handler(self, self.getTodayWasNotPaySuccess))
    UserService:sendQueryHasBuyGoldByKind(self.productTypeArr[kind]);
	self:createUI(kind)
end
function LiBaoLayer:createUI(kind)
	local displaySize = cc.size(display.width, display.height);
    local winSize = cc.Director:getInstance():getWinSize();
    -- 蒙板
    local maskLayer = ccui.ImageView:create("black.png");
    maskLayer:setScale9Enabled(true);
    maskLayer:setContentSize(cc.size(winSize.width, winSize.height));
    maskLayer:setPosition(cc.p(displaySize.width / 2, displaySize.height / 2));
    maskLayer:setTouchEnabled(true);
    maskLayer:addTo(self);
    local vx1 = -64
    local vx2 = 75

    -- local zs0 = ccui.ImageView:create("hall/shop/zsgold4.png")
    -- zs0:setPosition(800,489)
    -- self:addChild(zs0)

    -- local zs1 = ccui.ImageView:create("hall/shop/zsgold4.png")
    -- zs1:setPosition(1006+vx1,320)
    -- self:addChild(zs1)
    local bgSprite = ccui.ImageView:create("hall/libao/window.png");
    -- bgSprite:setPosition(cc.p(displaySize.width / 2, displaySize.height / 2));
    -- bgSprite:setScale9Enabled(true);
    -- bgSprite:setContentSize(cc.size(674, 433));
    bgSprite:setPosition(cc.p(582,256));
    self:addChild(bgSprite,1);

    local zs2 = ccui.ImageView:create("hall/shop/zsgold2.png")
    zs2:setPosition(20,160)
    bgSprite:addChild(zs2)

    local zs3 = ccui.ImageView:create("hall/shop/zsgold1.png")
    zs3:setPosition(562,30)
    bgSprite:addChild(zs3)
    local zs4 = ccui.ImageView:create("hall/shop/zsgold4.png")
    zs4:setPosition(910,415)
    self:addChild(zs4)

    -- local zs5 = ccui.ImageView:create("hall/room/roompage_zhuangshi2.png")
    -- zs5:setPosition(137+vx2,439)
    -- self:addChild(zs5)
    -- local zs6 = ccui.ImageView:create("hall/room/roompage_zhuangshi2.png")
    -- zs6:setPosition(772,54)
    -- self:addChild(zs6)

    local titlelight = ccui.ImageView:create("common/effect_light.png");
    titlelight:setScaleY(0.94)
    titlelight:setScaleX(1.71)
    titlelight:setPosition(cc.p(587,460));
    self:addChild(titlelight);
    local itemArray = {"hall/libao/gold1.png","hall/libao/gold2.png"}
    local wordtxtArray = {"1万金币","6万金币"}
    local wordtxtArray2 = {"加送1万金币","加送6万金币"}
    -- local title = ccui.ImageView:create("common/title.png")
    -- self:addChild(title)
    -- title:setPosition(562, 524)

    local title = ccui.ImageView:create("hall/libao/titleword"..kind..".png")
    bgSprite:addChild(title)
    title:setPosition(350, 400)


    -- local tabbg = ccui.ImageView:create("hall/libao/tabbg.png")
    -- tabbg:setPosition(250, 411)
    -- self:addChild(tabbg)

    -- local tabword = ccui.ImageView:create("hall/libao/tabword"..kind..".png")
    -- self:addChild(tabword)
    -- tabword:setPosition(249, 427)


    local lbbig1 = ccui.ImageView:create("hall/libao/lbbig"..kind..".png")
    bgSprite:addChild(lbbig1)
    lbbig1:setPosition(150, 450)

    local updown = cc.MoveBy:create(1,cc.p(0,20))
    local lbRepeate = cc.RepeatForever:create(cc.Sequence:create(updown,updown:reverse()))
    lbbig1:runAction(lbRepeate)

    local lbsmall1 = ccui.ImageView:create("hall/libao/lbsmall"..kind..".png")
    bgSprite:addChild(lbsmall1)
    lbsmall1:setPosition(550, 370)
    local updown2 = cc.MoveBy:create(1,cc.p(0,20))
    local lbRepeate2 = cc.RepeatForever:create(cc.Sequence:create(updown2,updown2:reverse()))
    lbsmall1:runAction(lbRepeate2)

    local word = ccui.ImageView:create("hall/libao/word"..kind..".png")
    bgSprite:addChild(word)
    word:setPosition(300, 298)
    local vx3 = -100
    local vy3 = -54
    local itembg = ccui.ImageView:create("hall/libao/itembg.png")
    itembg:setPosition(330+vx3, 235+vy3)
    bgSprite:addChild(itembg)

    local item = ccui.ImageView:create(itemArray[kind])
    item:setPosition(324+vx3, 217+vy3)
    bgSprite:addChild(item)

    local itembg = ccui.ImageView:create("hall/libao/itembg.png")
    itembg:setPosition(589+vx3, 235+vy3)
    bgSprite:addChild(itembg)

    local item = ccui.ImageView:create(itemArray[kind])
    item:setPosition(583+vx3, 216+vy3)
    bgSprite:addChild(item)

    local plus = ccui.ImageView:create("hall/libao/plus.png")
    bgSprite:addChild(plus)
    plus:setPosition(465+vx3, 266+vy3)

    local song = ccui.ImageView:create("hall/libao/song.png")
    bgSprite:addChild(song)
    song:setPosition(517+vx3, 275+vy3)

    -- local wordtxt = ccui.Text:create("","fonts/HKBDTW12.TTF",24)
    -- wordtxt:setString(wordtxtArray[kind])
    -- wordtxt:setFontSize(24)
    -- wordtxt:setColor(cc.c3b(255, 239, 97))
    -- bgSprite:addChild(wordtxt)
    -- wordtxt:setPosition(324+vx3, 172+vy3)

    -- local wordtxt2 = ccui.Text:create("","fonts/HKBDTW12.TTF",24)
    -- wordtxt2:setString(wordtxtArray2[kind])
    -- wordtxt2:setFontSize(24)
    -- wordtxt2:setColor(cc.c3b(255, 239, 97))
    -- bgSprite:addChild(wordtxt2)
    -- wordtxt2:setPosition(583+vx3, 172+vy3)
    local wordtxt = ccui.ImageView:create("hall/libao/money"..kind..".png")
    wordtxt:setPosition(324+vx3, 132+vy3)
    bgSprite:addChild(wordtxt)

    local wordtxt2 = ccui.ImageView:create("hall/libao/moneysong"..kind..".png")
    wordtxt2:setPosition(583+vx3, 132+vy3)
    bgSprite:addChild(wordtxt2)

    local dizhu = ccui.ImageView:create("common/ty_dizhu.png")
    dizhu:setPosition(20,300)
    -- dizhu:setScaleX(-1)
    bgSprite:addChild(dizhu)

    local light = ccui.ImageView:create("hall/libao/light.png")
    light:setPosition(115, 80)
    dizhu:addChild(light)

    local action = cc.ScaleBy:create(1,2)

    local repeatAction = cc.RepeatForever:create(cc.Sequence:create(action,action:reverse()))

    light:runAction(repeatAction)

    local anchorDefaultImg = EffectFactory:getInstance():getZhuBoMMAnimation()
    anchorDefaultImg:ignoreAnchorPointForPosition(false)
    anchorDefaultImg:setAnchorPoint(cc.p(0.5,0.5))
    anchorDefaultImg:setPosition(cc.p(700, 130))
    anchorDefaultImg:setScaleX(-1)
    bgSprite:addChild(anchorDefaultImg)
    anchorDefaultImg:getAnimation():playWithIndex(0)

    local text = display.newSprite("effect/zhu_bo_mm/wao.png")
    text:setPosition(cc.p(595, 220))
    bgSprite:addChild(text,1)


    local particle = cc.ParticleSystemQuad:create("particle/title.plist")
    particle:setScale(3)
    --particle:setEmissionRate(20000)
    particle:addTo(bgSprite,999):align(display.CENTER, 350, 400)


    local getbutton = ccui.Button:create("common/button_green.png","common/button_green.png")
    -- getbutton:setScale9Enabled(true)
    -- getbutton:setContentSize(cc.size(157*1.16, 73*1.05))
    getbutton:setPosition(357, 36)
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


    local exit = ccui.Button:create("common/close.png");
    exit:setPosition(cc.p(650,397));
    bgSprite:addChild(exit);
    exit:setPressedActionEnabled(true);
    exit:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then


                self:close();

            end
        end
    )
end
function LiBaoLayer:close()
    
    UserService:removeEventListener(self.handler4)
    self:removeFromParent();
end
function LiBaoLayer:getTodayWasNotPaySuccess(event)
    local info = protocol.hall.treasureInfo_pb.CMD_GP_QueryTodayWasnotPayResult_Pro();
    info:ParseFromString(event.data)

    if info.dwWasTodayPayed == 1 then
        self:close()
    end
end
function LiBaoLayer:getGift()
	-- body
    local index = self.kind
    local inReview = false;
    if OnlineConfig_review == nil or OnlineConfig_review == "on" then
        inReview = true;
    end
    if inReview then
        self.productTypeArr = {231,232}
    end
    self.productPrice = {1,6}
    local args = {packageID = self.productTypeArr[index],productId = self.productIDArr[index],productPrice = self.productPrice[index]}

    if true == PlatformGetChannel() then
        if AppChannel == "CMCC" then
            PlatformCMCCPurchases(args)
        elseif AppChannel == "CTCC" then
            PlatformCTCCPurchases(args)
        else
            PlatformAppPurchases(args)
        end
    else
        PlatformAppPurchases(args)
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
return LiBaoLayer