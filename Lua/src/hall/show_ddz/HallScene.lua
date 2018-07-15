
local HallScene = class("HallScene", require("ui.CCBaseScene"))
require("data.LevelSetting")

-- OnlineConfig_review = "on";

updateStatus = {}
gamePackage = {
    niuniu={
        url = "http://cdn.98game.cn/cocos_games/release/Landlord_Niuniu/Landlord_Niuniu.zip",
        file="niuniu.zip",
        md5="d7f543beed78308884c95292907f18de",
    },
    zhajinhua={
        url = "http://cdn.98game.cn/cocos_games/release/Zhajinhua_Zhajinhua/Zhajinhua_Zhajinhua.zip",
        file="zhajinhua.zip",
        md5="d7f543beed78308884c95292907f18de",
    },
    fishing={
        url = "http://cdn.98game.cn/cocos_games/release/Fish_Fishing/Fish_Fishing.zip",
        file="fishing.zip",
        md5="d7f543beed78308884c95292907f18de",
    },
}

function HallScene:ctor()
    self.queryTime = 0
    self.isGameLoading = false

    -- 根节点变更为self.container
    self.super.ctor(self);
    --背景
    local bgSprite = cc.Sprite:create();
    bgSprite:setTexture("christmas/splash.jpg");
    bgSprite:align(display.CENTER, display.cx, display.cy);
    self.container:addChild(bgSprite);
    bgSprite:setColor(cc.c3b(100, 100, 100))
    self:createUI();  
    self:registerGameEvent()

     --请求支付列表
    PayInfo:sendPayOrderItemsRequest()

    --按键处理
    self:setKeypadEnabled(true)
    self:addNodeEventListener(cc.KEYPAD_EVENT, function(event)
        if event.key == "back" then
            Hall:enterLoginScene()
        end
    end)
end

function HallScene:registerGameEvent()
    -- self.handlerQueryPayStatus = UserService:addEventListener(HallCenterEvent.EVENT_QUERY_TODAYWASNOTPAY_SUCCESS, handler(self, self.refreshLiBao))
    -- self.handlerPurcharse = UserService:addEventListener(HallCenterEvent.EVENT_APPPURCHASE_SUCCESS,handler(self, self.purcharseResult))
    -- self.handler_QUERY_INSURE = UserService:addEventListener(HallCenterEvent.EVENT_QUERY_INSURE_FOR_ROOM, handler(self, self.setSelfInfo))
    self.bindIds = {}
    self.bindIds[#self.bindIds + 1] = BindTool.bind(AccountInfo, "score", handler(self, self.setSelfInfo))
    self.bindIds[#self.bindIds + 1] = BindTool.bind(PayInfo, "orderItemList", handler(self, self.refreshLiBao))
    self.bindIds[#self.bindIds + 1] = BindTool.bind(AccountInfo, "present", handler(self, self.setSelfInfo));
    self.bindIds[#self.bindIds + 1] = BindTool.bind(AccountInfo, "insure", handler(self, self.setSelfInfo));
end

function HallScene:removeGameEvent()
    for _, bindid in ipairs(self.bindIds) do
        BindTool.unbind(bindid)
    end
end

function HallScene:onEnter()
    -- body
    print("HallScene--onEnter")
    self:setSelfInfo()
    if  self.queryTime < 3 then
        -- UserService:queryTodayWasPay()
        self.queryTime = self.queryTime + 1
    end

    self:createOtherButton()

    local texture2d = cc.Director:getInstance():getTextureCache():addImage("christmas/effect/lizi_xuehua.png");
    local light = cc.ParticleSystemQuad:create("christmas/effect/lizi_xuehua.plist");
    light:setTexture(texture2d);
    light:setPosition(cc.p(display.cx, display.top));
    self.container:addChild(light,99)

    self:checkGameDownload()

end

function HallScene:onExit()
    -- body
    print("HallScene--onExit")
    self:removeGameEvent()
end

function HallScene:checkGameDownload()

    local isFinished = false

    isFinished = cc.UserDefault:getInstance():getBoolForKey(gamePackage.niuniu.file, false)
    if not isFinished then
        print("牛牛还未下载")
    end

    -- isFinished = cc.UserDefault:getInstance():getBoolForKey(gamePackage.landlordCutie.file, false)
    -- if not isFinished then
    --     print("斗地主还未下载")
    --     self.gameBtns[3]:setColor(cc.c3b(150,150,150))
    -- end    
    
    isFinished = cc.UserDefault:getInstance():getBoolForKey(gamePackage.fishing.file, false)
    if not isFinished then
        print("捕鱼还未下载")
        self.gameBtns[1]:setColor(cc.c3b(150,150,150))
    end 

    isFinished = cc.UserDefault:getInstance():getBoolForKey(gamePackage.zhajinhua.file, false)
    if not isFinished then
        print("金花还未下载")
        self.gameBtns[2]:setColor(cc.c3b(150,150,150))
    end 
    
end

--数据更新
function HallScene:setSelfInfo()
    -- 顶部设置自己的属性
    
    local myInfo = DataManager:getMyUserInfo()
    if(myInfo ~= nil) then
        local nickName = FormotGameNickName(myInfo.nickName,5)
        self.nickNameText:setString(nickName)
        self.goldValueText2:setString(FormatNumToString(myInfo.score))
        self.couponTxt:setString(FormatNumToString(myInfo.present))
        print("HallScene:setSelfInfo------myInfo.present",myInfo.present,"myInfo.score",myInfo.score)
        -- self.headImage:setNewHead(myInfo.faceID, myInfo.platformID, myInfo.platformFace)
        -- self.headImage:setVipHead(myInfo.memberOrder)
    end
end
function HallScene:createUI()

    self:createBottomInfo()
    self:createGameList()
    

    --返回按钮
    -- local backButton = ccui.Button:create("hallScene/hall_center_back.png")
    local backButton = ccui.Button:create("christmas/hall_center_back.png")
    backButton:setPosition(cc.p(52,600));
    self.container:addChild(backButton);
    backButton:setPressedActionEnabled(true);
    backButton:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended and self.isGameLoading == false then
                --登出聊天服务器
                -- disconnectToChatServer()
                Hall:enterLoginScene()
                Click();
            end
        end
    )

    self:setDefaultData()
end

function HallScene:createDownloadProgress(gameName)

        if gameName == "landlordCutie" then
            self.gameBtns[3]:setColor(cc.c3b(150,150,150))
            self.gameBtns[3]:stopAllActions()

        elseif gameName == "fishing" then
            self.gameBtns[1]:setColor(cc.c3b(150,150,150))
            self.gameBtns[1]:stopAllActions()
            

        elseif gameName == "zhajinhua" then
            self.gameBtns[2]:setColor(cc.c3b(150,150,150))
            self.gameBtns[2]:stopAllActions()
            
        end



    local bg = display.newNode()
    -- if gameName == "landlordCutie" then
    --     display.newSprite("hallScene/Landlord.png"):addTo(bg):scale(85/120)
    -- elseif gameName == "niuniu" then
    --     display.newSprite("hallScene/Niuniu.png"):addTo(bg):scale(85/120)
    -- elseif gameName == "fishing" then
    --     display.newSprite("hallScene/Niuniu.png"):addTo(bg):scale(85/120)
    -- elseif gameName == "zhajinhua" then
    --     display.newSprite("hallScene/Niuniu.png"):addTo(bg):scale(85/120)
    -- end

    -- display.newSprite("hallScene/progress1.png"):addTo(bg):align(display.CENTER, 0, 0)
    display.newSprite("hallScene/progress2.png"):addTo(bg):align(display.CENTER, 0, 0)

    local progress = display.newProgressTimer("hallScene/progress3.png", display.PROGRESS_TIMER_RADIAL):addTo(bg)
    progress:align(display.CENTER, 0, 0)

    local txt = ccui.Text:create("", "", 36);
    txt:setColor(cc.c3b(0,255,0));
    txt:enableOutline(cc.c3b(0,0,0), 2)
    txt:setPosition(cc.p(199/2, 199/2));
    txt:setName("txt")
    txt:addTo(progress)
    
    return bg, progress
end

function HallScene:createOtherButton()

    if OnlineConfig_review == "on" then
       return 
    end

    local y = 60
    --首充礼包
    local mark = PayInfo:getNewGuestChargeStatus()
    if not mark then
        local nodeNewGift = display.newNode():addTo(self.container):pos(display.right-100, display.top-y)
        local lb1 = ccui.ImageView:create("hallScene/btn_dailyCharge.png")
        lb1:setTouchEnabled(true)
        lb1:addTo(nodeNewGift)
        -- lb1:setPosition(1058, 480)
        lb1:addTouchEventListener(function(sender,eventType)
            if eventType == ccui.TouchEventType.began then
                lb1:setScale(1.1)
            elseif eventType == ccui.TouchEventType.ended then
                lb1:setScale(1.0)
                self:popLiBao(1)
                onUmengEvent("1025")
            elseif eventType == ccui.TouchEventType.canceled then
                lb1:setScale(1.0)
            end
        end)
        local lb1animation = self:getShouChongLiBaoAnimation()
        local size = lb1:getContentSize()
        lb1animation:setPosition(size.width/2, size.height/2)
        lb1:addChild(lb1animation)
        self.lbNewGuest = lb1

        y = y+100
    end

    --每日礼包
    local mark = PayInfo:getDailyChargeStatus()
    if not mark then
        local nodeFirstCharge = display.newNode():addTo(self.container):pos(display.right-100, display.top-y)
        local lb2 = ccui.ImageView:create("hallScene/btn_newGuest.png")
        lb2:setTouchEnabled(true)
        -- lb2:setPosition(1058, 380)
        lb2:addTo(nodeFirstCharge)
        lb2:addTouchEventListener(function(sender,eventType)
            if eventType == ccui.TouchEventType.began then
                lb2:setScale(1.1)
            elseif eventType == ccui.TouchEventType.ended then
                lb2:setScale(1.0)
                self:popLiBao(2)
                onUmengEvent("1025")
            elseif eventType == ccui.TouchEventType.canceled then
                lb2:setScale(1.0)
            end
        end)
        local lb2animation = self:getMeiRiLiBaoAnimation()
        local size = lb2:getContentSize()
        lb2animation:setPosition(size.width/2, size.height/2)
        lb2:addChild(lb2animation)
        self.lbDailyCharge = lb2

        y = y +100
    end
--[[
    --每日金币
    local nodeToday = display.newNode():addTo(self.container):pos(display.right-100, display.top-y)
    local lb3 = ccui.ImageView:create("hallScene/btn_today.png")
    lb3:setTouchEnabled(true)
    -- lb3:setPosition(1058, 380)
    lb3:addTo(nodeToday)
    lb3:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.began then
            sender:setScale(1.1)
        elseif eventType == ccui.TouchEventType.ended then
            sender:setScale(1.0)
            self:onClickDialyGold()
            onUmengEvent("1025")
        elseif eventType == ccui.TouchEventType.canceled then
            sender:setScale(1.0)
        end
    end)

    local lb3animation = self:getDailyGoldButtonEffect()
    local size = lb3:getContentSize()
    lb3animation:setPosition(size.width/2, size.height/2)
    lb3animation:getAnimation():playWithIndex(0)
    lb3:addChild(lb3animation)
    self.lb3 = lb3

    y = y +100
]]
    --推荐人
    --[[
    local nodeRecommand = display.newNode():addTo(self.container):pos(display.right-100, display.top-y)

    local recommandAni = self:getTongYongButtonEffect()
    recommandAni:getAnimation():playWithIndex(0)
    nodeRecommand:addChild(recommandAni)

    local sure = ccui.Button:create("view/ddz_recommand/invite_friend_btn.png")
    nodeRecommand:addChild(sure)
    sure:setPressedActionEnabled(true)
    sure:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                Click()
                local infoLayer = require("show_ddz.RecomandGiftLayer").new()
                self.container:addChild(infoLayer)
                onUmengEvent("1055")
            end
        end
    )
    self.lb4 = nodeRecommand
    ]]
end

function HallScene:refreshLiBao()
    
    if RunTimeData:getNewGuestChargeStatus() then
        if self.lbNewGuest then
            self.lbNewGuest:hide()
        end
    else
        if self.lbNewGuest then
            self.lbNewGuest:show()
        end
    end

    if RunTimeData:getDailyChargeStatus() then
        if self.lbDailyCharge then
            self.lbDailyCharge:hide()
        end
    else
        if self.lbDailyCharge then
            self.lbDailyCharge:show()
        end
    end

    print("refreshLiBao")
    -- local chongzhi1 = RunTimeData:getChongZhiStatus(1)
    -- if chongzhi1 == 1 then
    --     if self.lbNewGuest then
    --         self.lbNewGuest:hide()
    --     end
    -- else
    --     if self.lbNewGuest then
    --         self.lbNewGuest:show()
    --     end
    -- end

    -- local chongzhi6 = RunTimeData:getChongZhiStatus(6)
    -- if chongzhi6 == 1 then
    --     if self.lbDailyCharge then
    --         self.lbDailyCharge:hide()
    --     end
    -- else
    --     if self.lbDailyCharge then
    --         self.lbDailyCharge:show()
    --     end
    -- end
end

--充值成功返回
function HallScene:purcharseResult()
    --同步个人账户信息
    UserService:sendQueryInsureInfo()
    self:refreshLiBao()

    if self.LiBaoLayer and self.LiBaoLayer:getParent() then
        self.LiBaoLayer:close()
        self.LiBaoLayer = nil
    end
end

function HallScene:popLiBao(kind)
    local libao = require("show_ddz.GuestLiBaoLayer").new(kind)
    self.container:addChild(libao)
    self.LiBaoLayer = libao
end

function HallScene:onClickDialyGold()
    local newLayer = require("show_ddz.DailyGoldLayer").new()
    self.container:addChild(newLayer)
end

function HallScene:setDefaultData()
    
    local userInfo = DataManager:getMyUserInfo();
    if userInfo then

        if userInfo.faceID and type(userInfo.faceID) == "number" then

           self.headView:setNewHead(userInfo.faceID, userInfo.platformID, userInfo.platformFace);
            
        end

       self.headView:setVipHead(userInfo.memberOrder,1)
    end
end
function HallScene:createBottomInfo()
    local bottomBg = ccui.ImageView:create("hallScene/hall_bottom_bg.png")
    bottomBg:setAnchorPoint(cc.p(0,0))
    self.container:addChild(bottomBg)

    --头像
    -- local circleStencil = cc.DrawNode:create()
    -- local radius = 38
    -- local circlePoints = {}
    -- for i=1,360 do
    --     local x = math.cos(math.pi / 180 * i) * radius
    --     local y = math.sin(math.pi / 180 * i) * radius
    --     local point = cc.p(x,y)
    --     circlePoints[i] = point
    -- end
    -- local params = {}
    -- params.fillColor = cc.c4b(1,0,0,0)
    -- params.borderWidth = 0
    -- params.borderColor = cc.c4b(1,1,0,1)
    -- circleStencil:drawPolygon(circlePoints,params)

    -- local headClipImg = cc.ClippingNode:create(circleStencil)
    -- headClipImg:setPosition(cc.p(77,93))
    -- bottomBg:addChild(headClipImg)

    -- local headImg = ccui.ImageView:create("hallScene/Landlord.png")
    -- headClipImg:addChild(headImg)
    -- self.headImg = headImg
    local headView = require("show_ddz.HeadView").new(1);
    headView:setPosition(cc.p(77,90))
    bottomBg:addChild(headView);
    self.headView = headView;
    --昵称
    local nicknameText = ccui.Text:create("我是名字啊", "fonts/HKBDTW12.TTF", 24);
    nicknameText:setColor(cc.c3b(108,58,20));
    nicknameText:setPosition(cc.p(82, 32));
    bottomBg:addChild(nicknameText);
    self.nickNameText = nicknameText
    --金币信息
    local goldImg = ccui.ImageView:create("hallScene/hall_gold.png")
    goldImg:setPosition(cc.p(148, 85));
    bottomBg:addChild(goldImg);
    local goldTxt = ccui.Text:create()
    goldTxt:setString("9999.9万")
    goldTxt:setColor(cc.c3b(254,255,117))
    goldTxt:setFontSize(24)
    goldTxt:setAnchorPoint(cc.p(0,0.5))
    goldTxt:setPosition(cc.p(170,85))
    bottomBg:addChild(goldTxt);
    self.goldValueText2 = goldTxt

    local personalCenter = ccui.Button:create("blank.png");
    personalCenter:setScale9Enabled(true)
    personalCenter:setContentSize(400,130)
    personalCenter:setPosition(cc.p(220,60));
    bottomBg:addChild(personalCenter);
    personalCenter:setPressedActionEnabled(true);
    personalCenter:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:onClickPersonalCenter();
                onUmengEvent("1054")
            end
        end
    )

    --礼券信息
    local presentImg = ccui.ImageView:create("hallScene/hall_present.png")
    presentImg:setPosition(cc.p(295, 85));
    bottomBg:addChild(presentImg);
    local presentTxt = ccui.Text:create()
    presentTxt:setString("9999.9万")
    presentTxt:setColor(cc.c3b(254,255,117))
    presentTxt:setFontSize(24)
    presentTxt:setAnchorPoint(cc.p(0,0.5))
    presentTxt:setPosition(cc.p(320,85))
    bottomBg:addChild(presentTxt);
    self.couponTxt = presentTxt


    if OnlineConfig_review == "on" then
        presentImg:hide()
        self.couponTxt:hide()
    end

    --功能信息
    local functionTxt = {"兑换","活动","充值","消息","设置"}
    local functionImg = {"christmas/function_gift.png",
                        "christmas/function_activity.png",
                        "christmas/function_charge.png",
                        "christmas/function_message.png",
                        "christmas/function_setting.png",}
    -- local functionImg = {"hallScene/function_gift.png",
    --                     "hallScene/function_activity.png",
    --                     "hallScene/function_charge.png",
    --                     "hallScene/function_message.png",
    --                     "hallScene/function_setting.png",}
    local notOpenArray = {0,1,0,0,0}
    if OnlineConfig_review == "on" then
        notOpenArray[1] = 1
    end

    for i=1,5 do
        local functionLayer = ccui.Layout:create()
        functionLayer:setTouchEnabled(true)
        functionLayer:setContentSize(cc.size(115,150))
        functionLayer:setTag(i)
        functionLayer:setPosition(cc.p(428 + (i - 1) * 110,10))
        bottomBg:addChild(functionLayer)

        local functionText = ccui.Text:create(functionTxt[i], "fonts/HKBDTW12.TTF", 24);
        functionText:setColor(cc.c3b(254,255,117));
        functionText:enableOutline(cc.c4b(0x3d,0x1b,0x02,255), 2)
        functionText:setPosition(cc.p(60, 20));
        functionLayer:addChild(functionText);

        local functionImage = ccui.Button:create(functionImg[i])
        functionImage:setPosition(cc.p(60, 80));
        functionLayer:addChild(functionImage);
        functionImage:setTag(i)
        functionImage:addTouchEventListener(
            function ( sender,eventType )
                if eventType == ccui.TouchEventType.ended then
                    self:buttonClick(sender)
                end
            end
        )
        local notOpen = ccui.ImageView:create("hallScene/hall_notOpen.png")
        notOpen:setPosition(60, 80)
        functionLayer:addChild(notOpen)
        if notOpenArray[i] == 1 then
            notOpen:setVisible(true)
        else
            notOpen:setVisible(false)
        end
    end

    display.newSprite("christmas/snow.png"):addTo(bottomBg):align(display.CENTER, 1057/2 + 34, 15)
    display.newSprite("christmas/tree.png"):addTo(bottomBg,-1):align(display.CENTER, 35, 145)
    display.newSprite("christmas/kx.png"):addTo(bottomBg):align(display.CENTER, 146, 127)
end

function HallScene:buttonClick( sender )
    local tag = sender:getTag()
    if tag == 1 then
        self:onClickExchangeCoupon()

    elseif tag == 2 then

    elseif tag == 3 then
        -- local shopLayer = require("show_ddz.ShopLayer").new(2);
        -- self.container:addChild(shopLayer);
        
        if device.platform == "ios" or device.platform == "mac" then
            local shopLayer = require("show_ddz.AppStoreLayer").new();
            self.container:addChild(shopLayer);
        else
            local chargeLayer = require("show_ddz.ChargeLayer").new()
            self.container:addChild(chargeLayer)
        end
        onUmengEvent("1025")
    elseif tag == 4 then
        local noticeLayer = require("show_ddz.NoticeLayer").new();
        self.container:addChild(noticeLayer);
    elseif tag == 5 then
        local settingLayer = require("show_ddz.SettingLayer").new();
        self.container:addChild(settingLayer);
    end
end

function HallScene:onClickPersonalCenter()

    local personalCenter = require("show_ddz.PersonalCenterLayer").new();
    self.container:addChild(personalCenter);

    Click();
end

function HallScene:onClickExchangeCoupon()

    if OnlineConfig_review == "on" then
        return
    end
    
    local newLayer = require("show_ddz.ExchangeCouponLayer").new()
    self.container:addChild(newLayer)
    self.exchangeLayer = newLayer 
end

function HallScene:updateAndEnterGame(gameName)
    -- Hall.showWaiting(-1, "")

    print("HallScene:updateAndEnterGame", gameName)

    curGameName = gameName
    -- APP_CHANNEL = "a_01";
    local appID = APP_ID
    if curGameName == "fishing" then
        appID = 1038
    elseif curGameName == "zhajinhua" then
        appID = 1032
    elseif curGameName == "landlordCutie" then
        appID = 1005
    end
    
    dump(updateStatus, "updateStatus")

    if self:isGameUpdated(curGameName) then
        print("isGameUpdated", curGameName)
        Hall:selectGame(curGameName);
        return
    end
    
    --APP_VERSiON:写成最低版本号,热更新的时候比这个高的版本都能更新
    APP_VERSiON = "1.0.0";
    --[[
    if device.platform == "ios" then
        local luaCallFun = require("cocos.cocos2d.luaoc")
        local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","appVersion")
        --print(ok,ret);
        if ok == true then
            APP_VERSiON = ret;
        end
    elseif device.platform == "android" then

    end
]]
    APP_PLATFORM = device.platform;
    if APP_PLATFORM == "mac" or APP_PLATFORM == "window" then
        APP_PLATFORM = "ios"
    end

    local url = "http://service.game100.cn/service/sync/resversion?appid="..appID.."&source="..APP_CHANNEL.."&os="..APP_PLATFORM.."&ver="..APP_VERSiON..'&data={"'..curGameName..'flist":%d}'

    local thunder = require("thunder.Thunder").new(url,curGameName.."/");
    thunder:setDelegate(self);
    thunder:startUpdate();
    self.thunder = thunder;
end


function HallScene:onDownloadStart(index, total)
    --TODO 更新界面
    print("HallScene onDownloadStart:",index,total)
    -- Hall.showWaiting(-1, "")
    if index == 1 then
        local bg, progress = self:createDownloadProgress(curGameName)
        if curGameName == "landlordCutie" then
            bg:addTo(self.gameBtns[3],128)
            bg:pos(0, 0)

        -- elseif curGameName == "niuniu" then
        --     bg:addTo(self.niuniuButton)
        --     bg:pos(359 -50, 430-30)

        elseif curGameName == "fishing" then
            bg:addTo(self.gameBtns[1],128)
            bg:pos(0, 0)

        elseif curGameName == "zhajinhua" then
            bg:addTo(self.gameBtns[2],128)
            bg:pos(0, 0)
        end


        self.dlProgressBG = bg
        self.dlProgress = progress
    end

    self.downloadIndex = index;
    self.downloadTotal = total;
end

function HallScene:onDownloadProgess(singleProgess, singleTotal)
    --TODO 更新界面
    print("HallScene onDownloadProgess:",singleProgess,singleTotal)
    local percent = 0
    if singleProgess ~= 0 and singleTotal ~= 0 and self.downloadIndex and self.downloadTotal then
        percent = (self.downloadIndex - singleProgess / singleTotal ) / self.downloadTotal*100
        print("-----", percent)
        
        if self.dlProgressBG then
            self.dlProgress:setPercentage(percent)
            self.dlProgress:getChildByName("txt"):setString(string.format("%.0f%%", percent))
        end
    end
end

function HallScene:onDownloadFinish(errorCode)
    print("onDownloadFinish", errorCode)

    self.isGameLoading = false

    if self.downloadIndex and self.downloadTotal and self.downloadTotal ~= 0  then
        percent = self.downloadIndex / self.downloadTotal*100
        print("-----", percent)
        
        if self.dlProgressBG then
            self.dlProgress:setPercentage(percent)
            self.dlProgress:getChildByName("txt"):setString(string.format("%.0f%%", percent))
        end
    end

    if self.downloadIndex == self.downloadTotal and errorCode ~= -1 then--更新成功
        self:setGameUpdateStatus(curGameName, 1)
        Hall:selectGame(curGameName);
    end

end

function HallScene:createGameList()
    self.gameBtns = {}

    self.posArr = {cc.p(display.width*0.76, display.cy+20),cc.p(display.width*0.48, display.cy+20),cc.p(display.width*0.2, display.cy+20)}
    
    self.selected_ani = self:getSelectedAnimation()
    if self.selected_ani then
        self.selected_ani:setPosition(cc.p(self.posArr[2].x,self.posArr[2].y+80))
        self.container:addChild(self.selected_ani)
        self.selected_ani:getAnimation():playWithIndex(0)
    end

    --1-fishing  2-zhajinhua 3-landlordCutie
    for i=1,3 do
        local armature = self:getHallAnimation()
        if armature then
            armature:setPosition(self.posArr[i])
            self.container:addChild(armature)
            armature:getAnimation():playWithIndex(i-1)
        end
        table.insert(self.gameBtns,armature)
    end

    for i=1,3 do
        local nToScale = 1.1
        local nBackScale = 1.0
        -- local freeRoom = ccui.Button:create("btn_green.png");
        local freeRoom = ccui.Button:create("blank.png");
        freeRoom:setScale9Enabled(true);
        freeRoom:setContentSize(cc.size(200, 300));
        freeRoom:setPosition(self.posArr[i]);
        freeRoom:setPressedActionEnabled(true);
        freeRoom:addTouchEventListener(
            function(sender,eventType)
                if eventType == ccui.TouchEventType.began then
                    self.gameBtns[i]:setScale(nToScale)
                elseif eventType == ccui.TouchEventType.ended then
                    self.gameBtns[i]:setScale(nBackScale)
                    self:selectGame(i)
                elseif eventType == ccui.TouchEventType.canceled then
                    self.gameBtns[i]:setScale(nBackScale)
                end
            end
        )
        self.container:addChild(freeRoom)
    end

    --手指
    self.shouZhi = display.newSprite("common/ty_shou_zhi.png");
    self.shouZhi:setPosition(cc.p(self.posArr[2].x+100,self.posArr[2].y-50))
    -- self.shouZhi:setRotation(120)
    self.container:addChild(self.shouZhi);

    self.shouZhi:runAction(cc.RepeatForever:create(cc.Sequence:create(
            cc.MoveBy:create(0.08, cc.p(-20,-20)),
            cc.MoveBy:create(0.08, cc.p(20,20)),
            cc.DelayTime:create(0.15)
        )))


    --初始化选择捕鱼
    self:selectGame(3)
--[[
    local ddzPos = cc.p(380,368)
    local armature = self:getDDZ()
    if armature then
        armature:setPosition(ddzPos)
        self.container:addChild(armature)
        armature:getAnimation():playWithIndex(0)
    end
    local landlordButton = ccui.Button:create("common/blank.png")
    landlordButton:setScale9Enabled(true);
    landlordButton:setContentSize(cc.size(358,440));
    landlordButton:setPosition(cc.p(380,350))
    landlordButton:setTag(1)
    self.container:addChild(landlordButton)
    landlordButton:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            armature:getAnimation():playWithIndex(0)
            self:downloadAndEnterGame("landlordCutie")
            -- Hall:selectGame("landlordCutie");
        end
    end)
    self.landlordButton = landlordButton

    local armatureRen = self:getDDZREN()
    if armatureRen then
        armatureRen:setPosition(ddzPos)
        self.container:addChild(armatureRen)
        armatureRen:getAnimation():playWithIndex(0)
    end
    self.landlordButtonEffect = armatureRen

    --------
    local niuniuPos = cc.p(767,370)
    local armature_niu = self:getNIUNIU()
    if armature_niu then
        armature_niu:setPosition(niuniuPos)
        self.container:addChild(armature_niu)
        armature_niu:getAnimation():playWithIndex(0)
    end
    local niuniuButton = ccui.Button:create("common/blank.png")
    niuniuButton:setScale9Enabled(true);
    niuniuButton:setContentSize(cc.size(359,430));
    niuniuButton:setPosition(cc.p(760,350))
    landlordButton:setTag(2)
    self.container:addChild(niuniuButton)
    niuniuButton:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            armature_niu:getAnimation():playWithIndex(1)
            self:downloadAndEnterGame("fishing")
            -- Hall:selectGame("fishing");
            -- Hall.showTips("游戏还未开放，敬请期待！", 1.0)
        end
    end)
    self.niuniuButton = niuniuButton
    local armatureNiuRen = self:getNIUNIUREN()
    if armatureNiuRen then
        armatureNiuRen:setPosition(niuniuPos)
        self.container:addChild(armatureNiuRen)
        armatureNiuRen:getAnimation():playWithIndex(0)
    end
    self.niuniuButtonEffect = armatureNiuRen

    local zhajinhuaButton = ccui.Button:create("hall/hallScene/Niuniu.png")
    -- zhajinhuaButton:setScale9Enabled(true);
    -- zhajinhuaButton:setContentSize(cc.size(359,430));
    zhajinhuaButton:setTitleText("我是炸金花")
    zhajinhuaButton:setTitleFontSize(30)
    zhajinhuaButton:setTitleColor(cc.c3b(0, 0, 0))
    zhajinhuaButton:setPosition(cc.p(display.right-100, display.bottom+200))
    landlordButton:setTag(3)
    self.container:addChild(zhajinhuaButton)
    zhajinhuaButton:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            self:downloadAndEnterGame("zhajinhua")
            -- Hall:selectGame("zhajinhua");
        end
    end)
    
    -- zhajinhuaButton:hide()
]]
end

function HallScene:selectGame(index)

    if self.isGameLoading then
        Hall.showTips(" 正在下载中，请稍后 ! ")
        return
    end

    --1-fishing  2-zhajinhua 3-landlordCutie
    if index == self.curIndex then
        --进入选择的游戏
        if index == 1 then
            self:downloadAndEnterGame("fishing");
        
        elseif index == 2 then
            self:downloadAndEnterGame("zhajinhua");
            
        elseif index == 3 then
            self:downloadAndEnterGame("landlordCutie");
        
        end
    else
        self.curIndex = index
        self.selected_ani:setPosition(cc.p(self.posArr[index].x,self.posArr[index].y+80))--self.posArr[index]
        for i=1,3 do
            self.gameBtns[i]:stopAllActions()
            if i ~= self.curIndex then
                self.gameBtns[i]:getAnimation():stop()
                self.gameBtns[i]:setScale(0.8)
            else
                self.gameBtns[i]:getAnimation():playWithIndex(i-1)
            end
        end

        self.shouZhi:setPosition(cc.p(self.posArr[index].x+100,self.posArr[index].y-50))

        self.gameBtns[index]:runAction(cc.RepeatForever:create(cc.Sequence:create(
                cc.ScaleTo:create(0.1, 1.1),
                cc.ScaleTo:create(0.2, 1.0),
                cc.ScaleTo:create(0.1, 1.05),
                cc.ScaleTo:create(0.2, 1.0),
                cc.DelayTime:create(0.5)
            )))

    end


end

function HallScene:getHallAnimation()
    local name = "dating_game"

    local filePath = "hallScene/gameItem/dating_game/"..name..".ExportJson"
    local imagePath = "hallScene/gameItem/dating_game/"..name.."0.png"
    local plistPath = "hallScene/gameItem/dating_game/"..name.."0.plist"
    
    local manager = ccs.ArmatureDataManager:getInstance()
    if manager:getAnimationData(name) == nil then
        manager:addArmatureFileInfo(imagePath,plistPath,filePath)
    end
    local armature = ccs.Armature:create(name)
    return armature;
end

function HallScene:getSelectedAnimation()
    local manager = ccs.ArmatureDataManager:getInstance()
    if manager:getAnimationData("dating_xuanzhong") == nil then
        manager:addArmatureFileInfo("hallScene/gameItem/dating_xuanzhong/dating_xuanzhong0.png","hallScene/gameItem/dating_xuanzhong/dating_xuanzhong0.plist","hallScene/gameItem/dating_xuanzhong/dating_xuanzhong.ExportJson")
    end
    local armature = ccs.Armature:create("dating_xuanzhong")
    return armature;
end

function HallScene:getNIUNIUREN()
    local name = "game_nn_ren"

    local filePath = "hallEffect/"..name..".ExportJson"
    local imagePath = "hallEffect/"..name.."0.png"
    local plistPath = "hallEffect/"..name.."0.plist"
    
    local manager = ccs.ArmatureDataManager:getInstance()
    if manager:getAnimationData(name) == nil then
        manager:addArmatureFileInfo(imagePath,plistPath,filePath)
    end
    local armature = ccs.Armature:create(name)
    return armature;
end
function HallScene:getNIUNIU()
    local name = "game_nn"

    local filePath = "hallEffect/"..name..".ExportJson"
    local imagePath = "hallEffect/"..name.."0.png"
    local plistPath = "hallEffect/"..name.."0.plist"
    
    local manager = ccs.ArmatureDataManager:getInstance()
    if manager:getAnimationData(name) == nil then
        manager:addArmatureFileInfo(imagePath,plistPath,filePath)
    end
    local armature = ccs.Armature:create(name)
    return armature;
end
function HallScene:getDDZREN()
    local name = "game_ddz_ren"

    local filePath = "hallEffect/"..name..".ExportJson"
    local imagePath = "hallEffect/"..name.."0.png"
    local plistPath = "hallEffect/"..name.."0.plist"
    
    local manager = ccs.ArmatureDataManager:getInstance()
    if manager:getAnimationData(name) == nil then
        manager:addArmatureFileInfo(imagePath,plistPath,filePath)
    end
    local armature = ccs.Armature:create(name)
    return armature;
end
function HallScene:getDDZ()
    local name = "game_ddz"

    local filePath = "hallEffect/"..name..".ExportJson"
    local imagePath = "hallEffect/"..name.."0.png"
    local plistPath = "hallEffect/"..name.."0.plist"
    
    local manager = ccs.ArmatureDataManager:getInstance()
    if manager:getAnimationData(name) == nil then
        manager:addArmatureFileInfo(imagePath,plistPath,filePath)
    end
    local armature = ccs.Armature:create(name)
    return armature;
end

function HallScene:getShouChongLiBaoAnimation()
    local name = "shouchonglibao"

    local filePath = "hallEffect/shouchong/"..name..".ExportJson"
    local imagePath = "hallEffect/shouchong/"..name.."0.png"
    local plistPath = "hallEffect/shouchong/"..name.."0.plist"
    
    local manager = ccs.ArmatureDataManager:getInstance()
    if manager:getAnimationData(name) == nil then
        manager:addArmatureFileInfo(imagePath,plistPath,filePath)
    end
    local armature = ccs.Armature:create(name)
    return armature;

end

function HallScene:getMeiRiLiBaoAnimation()
    local name = "meirilibao"

    local filePath = "hallEffect/meirilibao/"..name..".ExportJson"
    local imagePath = "hallEffect/meirilibao/"..name.."0.png"
    local plistPath = "hallEffect/meirilibao/"..name.."0.plist"
    
    local manager = ccs.ArmatureDataManager:getInstance()
    if manager:getAnimationData(name) == nil then
        manager:addArmatureFileInfo(imagePath,plistPath,filePath)
    end
    local armature = ccs.Armature:create(name)
    return armature;

end

--通用图标动画
function HallScene:getTongYongButtonEffect()
    local name = "eff_libao_anniu"

    local filePath = "hallEffect/icon_tongyong/"..name..".ExportJson"
    local imagePath = "hallEffect/icon_tongyong/"..name.."0.png"
    local plistPath = "hallEffect/icon_tongyong/"..name.."0.plist"
    
    local manager = ccs.ArmatureDataManager:getInstance()
    if manager:getAnimationData(name) == nil then
        manager:addArmatureFileInfo(imagePath,plistPath,filePath)
    end
    local armature = ccs.Armature:create(name)
    return armature;

end

function HallScene:getDailyGoldButtonEffect()
    local name = "meirijinbi"

    local filePath = "hallEffect/dailyGold/"..name..".ExportJson"
    local imagePath = "hallEffect/dailyGold/"..name.."0.png"
    local plistPath = "hallEffect/dailyGold/"..name.."0.plist"
    
    local manager = ccs.ArmatureDataManager:getInstance()
    if manager:getAnimationData(name) == nil then
        manager:addArmatureFileInfo(imagePath,plistPath,filePath)
    end
    local armature = ccs.Armature:create(name)
    return armature;

end

function HallScene:cancelUpdateGame(gameName)
    self.isGameLoading = false
    self.downloadIndex = nil
    self.downloadTotal = nil

    if self.thunder then
        self.thunder:stopUpdate()
        self.thunder = nil
    end
    if self.dlProgressBG then
        self.dlProgressBG:removeSelf()
        self.dlProgressBG = nil
    end
    Hall.showTips("游戏下载失败！", 3.0)

    -- if gameName == "landlordCutie" then
    --     self.landlordButtonEffect:getAnimation():playWithIndex(0)

    -- elseif gameName == "niuniu" then
    --     self.niuniuButtonEffect:getAnimation():playWithIndex(0)
    -- end

    if self._handle then
        scheduler.unscheduleGlobal(self._handle)
        self._handle = nil
    end
end

function HallScene:downloadAndEnterGame(gameName)
    if XPLAYER == true then
        curGameName = gameName
        self:updateAndEnterGame(curGameName)
        return
    end

    --下载单个文件
    if self.isGameLoading == false then
        curGameName = gameName
        self.isGameLoading = true



        if gameName == "niuniu" then
            -- self:updateAndEnterGame(curGameName)
            
            if OnlineConfig_review == nil or OnlineConfig_review == "on" then
                Hall.showTips("游戏还未开放，敬请期待！")
                self.isGameLoading = false
                return
            end
 

            local isFinished = cc.UserDefault:getInstance():getBoolForKey(gamePackage.niuniu.file, false)
            print(gamePackage.niuniu.file, "=========isFinished", isFinished)

            if isFinished then
                self:updateAndEnterGame(gameName)

            else
                local thunder = require("thunder.ThunderFile").new(gamePackage.niuniu);
                thunder:setDelegate(self);
                thunder:startUpdate();
                self.thunder = thunder;
            end

        elseif gameName == "fishing" then
            local isFinished = cc.UserDefault:getInstance():getBoolForKey(gamePackage.fishing.file, false)
            print(gamePackage.niuniu.file, "=========isFinished", isFinished)

            if isFinished then
                self:updateAndEnterGame(gameName)

            else
                local thunder = require("thunder.ThunderFile").new(gamePackage.fishing);
                thunder:setDelegate(self);
                thunder:startUpdate();
                self.thunder = thunder;
            end

        elseif gameName == "zhajinhua" then
            local isFinished = cc.UserDefault:getInstance():getBoolForKey(gamePackage.zhajinhua.file, false)
            print(gamePackage.niuniu.file, "=========isFinished", isFinished)

            if isFinished then
                self:updateAndEnterGame(gameName)

            else
                local thunder = require("thunder.ThunderFile").new(gamePackage.zhajinhua);
                thunder:setDelegate(self);
                thunder:startUpdate();
                self.thunder = thunder;
            end

        else
            self:updateAndEnterGame(curGameName)

        end
    end
    
    -- else
    --     self:cancelUpdateGame(gameName)
    -- end

end

function HallScene:checkUncompressFinish(fileName)
    
    local function onInterval(dt)
    
        local isFinished = cc.UserDefault:getInstance():getBoolForKey(fileName, false)
        print(fileName, "=========isFinished", isFinished)
        if isFinished then
            scheduler.unscheduleGlobal(self._handle)
            self._handle = nil

            local fullPath = self.thunder.downloadPath .. fileName
            print("fullPath===========", fullPath)
            if is_file_exists(fullPath) then
                os.remove(fullPath)
            end
            self:uncompressFinished()
        end
    end
    self._handle = scheduler.scheduleGlobal(onInterval, 1)
end

function HallScene:uncompressFinished()
    print("解压成功！")
    Hall.hideWaiting()

    Hall:selectGame(curGameName)
end

function HallScene:onFileDownloadStart()
    --TODO 更新界面
    print("HallScene onFileDownloadStart:", curGameName)
    -- Hall.showWaiting(-1, "")

    local bg, progress = self:createDownloadProgress(curGameName)
    if curGameName == "landlordCutie" then
        bg:addTo(self.gameBtns[3],128)
        bg:pos(0, 0)

    -- elseif curGameName == "niuniu" then
    --     bg:addTo(self.niuniuButton)
    --     bg:pos(359 -50, 430-30)

    elseif curGameName == "fishing" then
        bg:addTo(self.gameBtns[1],128)
        bg:pos(0, 0)

    elseif curGameName == "zhajinhua" then
        bg:addTo(self.gameBtns[2],128)
        bg:pos(0, 0)
    end


    self.dlProgressBG = bg
    self.dlProgress = progress


    -- self.downloadIndex = index;
    -- self.downloadTotal = total;
    
    -- local bg, progress = self:createDownloadProgress(curGameName)
    -- bg:addTo(self.niuniuButton)
    -- bg:pos(359 -50, 430-30)
    -- self.dlProgressBG = bg
    -- self.dlProgress = progress

end


function HallScene:onFileDownloadProgess(singleProgess, singleTotal)
    --TODO 更新界面
    print("HallScene onFileDownloadProgess:",singleProgess,singleTotal)
    local percent = 0
    if singleTotal ~= 0 then
       percent = singleProgess / singleTotal
    end
    
    print("-----", percent)
    self.dlProgress:setPercentage(percent*100)
    self.dlProgress:getChildByName("txt"):setString(string.format("%.1f%%", percent*100))

end


function HallScene:onFileDownloadFinish(errorCode)
    print("onFileDownloadFinish", errorCode)
    
    self.isGameLoading = false

    if errorCode ~= 0 then
        self:cancelUpdateGame(curGameName)

    else
        local downloadPath = self.thunder.downloadPath
        local installPath = self.thunder.downloadPath
        local fileName = self.thunder.downloadFile
        print(installPath, downloadPath, fileName)
        cc.ZipUtils:uncompressDir(downloadPath, downloadPath, fileName)

        --10seconds之后检查是否解压完成
        self:performWithDelay(function() self:checkUncompressFinish(fileName) end, 10)
        self.dlProgressBG:removeSelf()

        Hall.showWaiting(-1, "游戏已经下载成功,正努力安装中,请稍等...")
    end
end

function HallScene:setGameUpdateStatus(gameName, status)
    updateStatus[gameName] = status
end

function HallScene:isGameUpdated(gameName)
    return updateStatus[gameName]
end

return HallScene