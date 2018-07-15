local showLayer = class("showLayer", function() return display.newLayer(); end );

local gamePackage = {
    fishing={
        -- url = "http://cdn.98game.cn/cocos_games/release/Landlord_Niuniu/Landlord_Niuniu.zip",
        -- url = "http://cdn.98game.cn/cocos_games/release/Zhajinhua_Zhajinhua/Zhajinhua_Zhajinhua.zip",
        url = "http://cdn.98game.cn/cocos_games/release/Fish_Fishing/Fish_Fishing.zip",
        file="fishing.zip",
        md5="d7f543beed78308884c95292907f18de",
    },
}

function showLayer:scene()

    local scene = display.newScene("showLayer");
    scene:addChild(self);
    self.scene = scene;

    return scene;

end

function showLayer:ctor()

    -- if XPLAYER ~= true then
    --     AccountInfo:sendLoginRequest(AccountInfo.nickName)
    -- end

    self:setNodeEventEnabled(true)
    self.bindIds = {}
    self.bindIds[#self.bindIds + 1] = BindTool.bind(AccountInfo, "nickName", handler(self, self.refreshNickName))
    self.bindIds[#self.bindIds + 1] = BindTool.bind(AccountInfo, "score", handler(self, self.refreshScore))
    self.bindIds[#self.bindIds + 1] = BindTool.bind(AccountInfo, "present", handler(self, self.refreshCoupon))
    self.bindIds[#self.bindIds + 1] = BindTool.bind(AccountInfo, "userInfoChange", handler(self, self.refreshUserInfo))
    self.bindIds[#self.bindIds + 1] = BindTool.bind(PayInfo, "orderItemList", handler(self, self.refreshButtonStatus))
    self.bindIds[#self.bindIds + 1] = BindTool.bind(PayInfo, "paymentNofity", handler(self, self.refreshButtonStatus))

    --HallConnection断线重练

    local backgroundSprite = cc.Sprite:create("room/bg.jpg");
    backgroundSprite:setPosition(getSrcreeCenter());
    self:addChild(backgroundSprite);

    self:showList();

    --是否正在下载游戏
    self.isGameLoading = false
    --是否更新的标志
    self.flag = true

    -- local winSize = cc.Director:getInstance():getWinSize();

    -- --滚动消息数组
    -- self.scrollMessageArr = {}

    -- --滚动消息
    -- local scrollTextContainer = ccui.Layout:create()
    -- scrollTextContainer:setAnchorPoint(cc.p(0.5,0.5))
    -- scrollTextContainer:setContentSize(cc.size(600,30))
    -- scrollTextContainer:setPosition(cc.p(winSize.width/2, winSize.height-140))
    -- self:addChild(scrollTextContainer,10)
    -- scrollTextContainer:setVisible(false)
    -- self.scrollTextContainer = scrollTextContainer

    -- local scrollBg = ccui.ImageView:create("common/ty_pao_ma_bg.png")
    -- scrollBg:setScale9Enabled(true)
    -- scrollBg:setContentSize(cc.size(520, 40))
    -- scrollBg:ignoreAnchorPointForPosition(false)
    -- scrollBg:setAnchorPoint(cc.p(0.5,0.5))
    -- scrollBg:setPosition(cc.p(313,15))
    -- scrollTextContainer:addChild(scrollBg)

    -- local scrollTextPanel = ccui.Layout:create()
    -- scrollTextPanel:setContentSize(cc.size(492,30))
    -- scrollTextPanel:setName("scrollTextPanel")
    -- scrollTextPanel:setPosition(cc.p(80,0))
    -- scrollTextPanel:setClippingEnabled(true)
    -- scrollTextContainer:addChild(scrollTextPanel)

    -- local labaImg = ccui.ImageView:create("common/ty_scroll_laba.png")
    -- labaImg:setPosition(cc.p(68,22))
    -- labaImg:setName("labaImg")
    -- scrollTextContainer:addChild(labaImg)

    --请求支付列表
    PayInfo:sendPayOrderItemsRequest()

    DataManager:setAutoHallLogin(true)

end

function showLayer:onExit()
    for _, bindid in ipairs(self.bindIds) do
        BindTool.unbind(bindid)
    end
end

function showLayer:refreshNickName()
    self.name:setString(FormotGameNickName(AccountInfo.nickName,4))
end

function showLayer:refreshScore()
    self.coinLabel:setString(FormatNumToString(AccountInfo.score))
end

function showLayer:refreshCoupon()
    self.liQuanLabel:setString(FormatNumToString(AccountInfo.present))
end

function showLayer:refreshUserInfo()
    self.headView:setNewHead(AccountInfo.faceId, AccountInfo.cy_userId, AccountInfo.headFileMD5);
    --vip信息
    if OnlineConfig_review == "off" and AccountInfo.memberOrder > 0 then
        self.headView:setVipHead(AccountInfo.memberOrder,1)
    end
end

-- function showLayer:showScrollMessage(messageContent)
--     table.insert(self.scrollMessageArr, messageContent)
--     if self.scrollTextContainer and self.scrollTextContainer:isVisible() == false then
--         self.scrollTextContainer:setVisible(true)
--         self:startScrollMessage()
--     end
-- end

-- function showLayer:startScrollMessage()
--     local messageCount = table.maxn(self.scrollMessageArr)
--     if messageCount > 0 then
        
--         local scrollTextPanel = self.scrollTextContainer:getChildByName("scrollTextPanel")
--         local messageContent = self.scrollMessageArr[1]
--         local scrollText = ccui.Text:create()
--         scrollText:setFontSize(24)
--         scrollText:setAnchorPoint(cc.p(0,0.5))
--         scrollText:setColor(cc.c3b(255,255,255))
--         scrollText:setString(messageContent)
--         scrollText:setPosition(cc.p(scrollTextPanel:getContentSize().width,scrollTextPanel:getContentSize().height/2))
--         scrollTextPanel:addChild(scrollText)

--         local moveDistance = scrollText:getContentSize().width + scrollTextPanel:getContentSize().width
--         local moveDuration = moveDistance / 100

--         local scrollAction = cc.Sequence:create(
--                         cc.MoveBy:create(moveDuration, cc.p(-moveDistance,0)),
--                         cc.CallFunc:create(function() 
--                             scrollText:removeFromParent()
--                             self:startScrollMessage()
--                         end)
--                     )
--         scrollText:runAction(scrollAction)

--         table.remove(self.scrollMessageArr,1)
        
--     else
--         self.scrollTextContainer:setVisible(false)
--     end
-- end

function showLayer:downloadAndEnterGame(gameName)

    -- curGameName = gameName
    self.gameName = gameName

    local isFinished = cc.UserDefault:getInstance():getBoolForKey(gameName.."_Finish", false)

    if self.isGameLoading == false and not isFinished then

        if gameName == "fishing" then
            
            if OnlineConfig_review == "on" then
                Hall.showTips(" 即将上线，敬请期待 ! ")
                return
            end

            --判断网络状态
            local iswifiConnect = network.getInternetConnectionStatus();
            if iswifiConnect == 1 then
                self:startLoad(gamePackage.fishing);
            else
                device.showAlert(
                    "提示",
                    "推荐使用WiFi下载，\n检测到您当前WiFi还未打开或连接，\n是否继续下载？",
                    {"确定","取消"}, 
                    function(event)
                        if event.buttonIndex == 1 then
                            self:startLoad(gamePackage.fishing)
                        elseif event.buttonIndex == 2 then
                        end
                    end
                )
            end

        elseif gameName == "niuniu" then
            --todo
        end
    end

    local unzipIsFinished = cc.UserDefault:getInstance():getBoolForKey(gamePackage.fishing.file, false)
    if isFinished and not unzipIsFinished then
        Hall.showTips("游戏已经下载成功,正努力安装中,请稍等...")
    end
    if isFinished and unzipIsFinished then
        Hall:selectGame(gameName)
    end

end

function showLayer:startLoad(name)

    self.isGameLoading = true
    self:downloadProcessBar(self.curIndex)

    local thunder = require("thunder.ThunderFile").new(name);
    thunder:setDelegate(self);
    thunder:startUpdate();
    self.thunder = thunder;

end

function showLayer:onFileDownloadStart()
    --TODO 更新界面
    print("showLayer onFileDownloadStart:")
    -- self.gameBtns[self.curIndex]:setColor(cc.c4b(0,0,0,100))
end

function showLayer:onFileDownloadProgess(singleProgess, singleTotal)
    --TODO 更新界面
    local percent = 0
    if singleTotal ~= 0 then
       percent = singleProgess / singleTotal
    end
    print("showLayer onFileDownloadProgess:",singleProgess,singleTotal,percent)

    if self.progress and self.progressTxt then
        self.progress:setTextureRect(cc.rect(0,0,math.floor(175*percent),24))
        self.progressTxt:setString(string.format("%.1f%%", percent*100))
    end
end

function showLayer:onFileDownloadFinish(errorCode)
    print("showLayer onFileDownloadFinish:", errorCode)
    
    self.isGameLoading = false

    if errorCode ~= 0 then
        self:cancelUpdateGame()
        Hall.showTips(" 下载失败，请重新下载 ! ")
    else

        self.gameBtns[1]:setColor(cc.c3b(255,255,255))

        if self.lockSprite4 then
            self.lockSprite4:stopAllActions()
            self.lockSprite4:removeFromParent()
            self.lockSprite4 = nil
        end

        print("游戏已经下载成功")
        cc.UserDefault:getInstance():setBoolForKey(self.gameName.."_Finish", true)
        cc.UserDefault:getInstance():flush()

        local downloadPath = self.thunder.downloadPath
        local installPath = self.thunder.downloadPath
        local fileName = self.thunder.downloadFile
        print(installPath, downloadPath, fileName)
        if cc.ZipUtils then
            cc.ZipUtils:uncompressDir(downloadPath, downloadPath, fileName)
        end

        if self.progress_bg then
            self.progress_bg:removeFromParent()
            self.progress_bg = nil
        end
        if self.progress then
            self.progress:removeFromParent()
            self.progress = nil
        end
        if self.progressTxt then
            self.progressTxt:removeFromParent()
            self.progressTxt = nil
        end

        --3seconds之后检查是否解压完成
        self:performWithDelay(function() self:checkUncompressFinish(fileName) end, 3)
        Hall.showWaitingState("下载成功,努力安装中,请稍等...")
    end
end

function showLayer:checkUncompressFinish(fileName)
    print("游戏已经下载成功,正努力安装中,请稍等...",fileName)
    local function onInterval(dt)
    
        local isFinished = cc.UserDefault:getInstance():getBoolForKey(fileName, false)
        print(fileName, ":isFinished", isFinished)
        if isFinished then
            scheduler.unscheduleGlobal(self._handle)
            self._handle = nil

            local fullPath = self.thunder.downloadPath .. fileName
            print("fullPath:", fullPath)
            if is_file_exists(fullPath) then
                os.remove(fullPath)
            end
            self:uncompressFinished()
        end
    end
    self._handle = scheduler.scheduleGlobal(onInterval, 1)
end

function showLayer:uncompressFinished()
    print("解压成功！")
    Hall.hideWaitingState()
    Hall:selectGame(self.gameName)
end

function showLayer:cancelUpdateGame()
    self.isGameLoading = false
    if self.thunder then
        self.thunder:stopUpdate()
        self.thunder = nil
    end
    if self.progress_bg then
        self.progress_bg:removeFromParent()
        self.progress_bg = nil
    end
    if self.progress then
        self.progress:removeFromParent()
        self.progress = nil
    end
    if self.progressTxt then
        self.progressTxt:removeFromParent()
        self.progressTxt = nil
    end
    if self._handle then
        scheduler.unscheduleGlobal(self._handle)
        self._handle = nil
    end
end

--下载游戏进度条
function showLayer:downloadProcessBar(i)
    if self.progress_bg then
        self.progress_bg:removeFromParent()
        self.progress_bg = nil
    end
    if self.progress then
        self.progress:removeFromParent()
        self.progress = nil
    end
    if self.progressTxt then
        self.progressTxt:removeFromParent()
        self.progressTxt = nil
    end
    --self.posArr[i]
    local progress_bg = cc.Sprite:create("common/ty_progress_bg_long.png");
    progress_bg:setPosition(cc.p(self.posArr[i].x-30,self.posArr[i].y-100));
    self:addChild(progress_bg);
    self.progress_bg = progress_bg;

    local progress = cc.Sprite:create("common/ty_progress_lv_long.png");
    progress:setAnchorPoint(cc.p(0.0,0.5));
    progress:setPosition(cc.p(self.posArr[i].x-119,self.posArr[i].y-99));
    self:addChild(progress);
    progress:setTextureRect(cc.rect(0,0,math.floor(175*0/4),24));
    self.progress = progress;

    -- print("测试:",progress:getContentSize().width,progress:getContentSize().height)

    local progressTxt = display.newTTFLabel({text = "",
                                size = 16,
                                color = cc.c3b(255,255,255),
                                -- font = FONT_PTY_TEXT,
                                align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                            })
    progressTxt:setPosition(cc.p(self.posArr[i].x-30,self.posArr[i].y-100))
    progressTxt:enableOutline(cc.c4b(40,90,14,255),2)
    self:addChild(progressTxt)
    self.progressTxt = progressTxt;
end

function showLayer:showList()

    local winSize = cc.Director:getInstance():getWinSize();

    --返回
    local backBtn = ccui.Button:create("show/hall_back.png");
    backBtn:setPosition(cc.p(70,winSize.height-70));
    backBtn:setPressedActionEnabled(true);
    backBtn:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                if APP_ID == 1038 then
                    -- curGameName = "fishing"
                elseif APP_ID == 1032 then
                    -- curGameName = "zhajinhua"
                end
                self:cancelUpdateGame()
                DataManager:setAutoHallLogin(false)
                Hall:start()
            end
        end
    )
    self:addChild(backBtn)

    self.gameBtns = {}
    -- self.posArr = {cc.p(winSize.width/2-380,winSize.height/2),cc.p(winSize.width/2-130,winSize.height/2),cc.p(winSize.width/2+130,winSize.height/2),cc.p(winSize.width/2+380,winSize.height/2)}
    self.posArr = {cc.p(winSize.width/2-300,winSize.height/2),cc.p(winSize.width/2+50,winSize.height/2),cc.p(winSize.width/2+400,winSize.height/2)}

    self.selected_ani = self:getSelectedAnimation()
    if self.selected_ani then
        self.selected_ani:setPosition(cc.p(self.posArr[2].x-36,self.posArr[2].y+60))
        self:addChild(self.selected_ani)
        self.selected_ani:getAnimation():playWithIndex(0)
    end

    --手指
    self.shouZhi = display.newSprite("common/ty_shou_zhi.png");
    self.shouZhi:setPosition(cc.p(self.posArr[2].x+100,self.posArr[2].y-50))
    -- self.shouZhi:setRotation(120)
    self:addChild(self.shouZhi,10);

    self.shouZhi:runAction(cc.RepeatForever:create(cc.Sequence:create(
            cc.MoveBy:create(0.08, cc.p(-20,-20)),
            cc.MoveBy:create(0.08, cc.p(20,20)),
            cc.DelayTime:create(0.15)
        )))

    local isFishFinished = cc.UserDefault:getInstance():getBoolForKey("fishing_Finish", false)

    for i=1,3 do
        local armature = self:getHallAnimation()
        if armature then
            armature:setPosition(self.posArr[i])
            armature:setTag(200+i)
            armature:setScale(0.9)
            self:addChild(armature)
            armature:getAnimation():playWithIndex(i-1)
        end
        table.insert(self.gameBtns,armature)

        if i == 3 then
            armature:setColor(cc.c3b(150,150,150))
            local lockSprite = display.newSprite("show/game_lock.png")
            lockSprite:setPosition(cc.p(self.posArr[i].x+50,self.posArr[i].y+50))
            self:addChild(lockSprite,10)
        end

        if i == 1 and not isFishFinished then
            armature:setColor(cc.c3b(150,150,150))
            self.lockSprite4 = display.newSprite("show/game_download.png")
            self.lockSprite4:setPosition(cc.p(self.posArr[i].x+50,self.posArr[i].y+50))
            self:addChild(self.lockSprite4,10)
            -- self.lockSprite4:runAction(cc.RepeatForever:create(
            --     cc.Sequence:create(cc.ScaleTo:create(0.5, 1.1),cc.ScaleTo:create(0.5, 1))
            -- ))
            self.lockSprite4:runAction(cc.RepeatForever:create(
                cc.Sequence:create(cc.MoveBy:create(0.5, cc.p(0,-10)),cc.MoveBy:create(0.5, cc.p(0,10)))
            ))
        end
    end

    local game_str = {"hall_fish","hall_zjh","hall_ddz"}

    for i=1,#game_str do
        local nToScale = 0.95
        local nBackScale = 0.9
        -- local freeRoom = ccui.Button:create("btn_green.png");
        local freeRoom = ccui.Button:create("blank.png");
        -- local freeRoom = ccui.Button:create("show/"..game_str[i]..".png");
        freeRoom:setScale9Enabled(true);
        freeRoom:setContentSize(cc.size(350, 450));
        freeRoom:setPosition(self.posArr[i]);
        freeRoom:setScale(0.8)
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
        self:addChild(freeRoom)
    end

    --底部一排按钮
    self:initBottomBtns()
    --顶部一排按钮
    if OnlineConfig_review == "off" then
        self:initTopBtns()
    end

    self.curIndex = 0

    --初始化选择炸金花
    self:selectGame(2)

end

function showLayer:initBottomBtns()

    local winSize = cc.Director:getInstance():getWinSize();

    local bottomBg = display.newSprite("show/hall_bottom_bg.png");
    bottomBg:setAnchorPoint(cc.p(0.5,0))
    bottomBg:setPosition(winSize.width/2, -1)
    self:addChild(bottomBg);

    local headView = require("show.popView_Hall.HeadView").new(1,true);
    headView:setPosition(cc.p(130, 100));
    -- headView:setScale(0.8);
    self:addChild(headView);
    self.headView = headView;

    headView:setTouchEnabled(true)
    headView:addTouchEventListener(
        function (sender,eventType)
            if eventType == ccui.TouchEventType.began then
                sender:scale(1.05)
            elseif eventType == ccui.TouchEventType.canceled then
                sender:scale(1.0)
            elseif eventType == ccui.TouchEventType.ended then
                sender:scale(1.0)
                local layer = require("show_zjh.popView_Hall.PersonalCenterLayer_New").new();
                self:popLayer(layer);
            end
        end
    )

    -- self:refreshUserInfo()

    local nameBg = display.newSprite("show/hall_name_bg.png");
    nameBg:setAnchorPoint(cc.p(0.5,0));
    nameBg:setPosition(130, 2)
    self:addChild(nameBg);

    local name = display.newTTFLabel({text = FormotGameNickName(AccountInfo.nickName,4),
                                        size = 22,
                                        color = cc.c3b(255,255,255),
                                        font = "",
                                        align = cc.ui.TEXT_ALIGN_CENTER
                                    })
    name:enableOutline(cc.c4b(0x03,0x08,0x06,255),2)
    name:setPosition(cc.p(nameBg:getContentSize().width/2, nameBg:getContentSize().height/2-2))
    nameBg:addChild(name)
    self.name = name

    --coin
    local coinBg = display.newSprite("show/hall_ty_bg.png");
    coinBg:setPosition(310, 36)
    self:addChild(coinBg);

    local coin = display.newSprite("show/hall_coin_icon.png");
    coin:setPosition(250, 36)
    self:addChild(coin);

    local coinLabel = display.newTTFLabel({text = ""..FormatNumToString(AccountInfo.score),
                                        size = 22,
                                        color = cc.c3b(250,218,76),
                                        font = "",
                                        align = cc.ui.TEXT_ALIGN_CENTER
                                    })
    coinLabel:enableOutline(cc.c4b(0x03,0x08,0x06,255),2)
    coinLabel:setAnchorPoint(cc.p(0,0.5))
    coinLabel:setPosition(cc.p(coinBg:getContentSize().width/2-30, coinBg:getContentSize().height/2))
    coinBg:addChild(coinLabel)
    self.coinLabel = coinLabel

    --liquan
    local liQuanBg = display.newSprite("show/hall_ty_bg.png");
    liQuanBg:setAnchorPoint(cc.p(0.5,0.5));
    liQuanBg:setPosition(470, 36)
    self:addChild(liQuanBg);

    local liQuan = display.newSprite("show/hall_quan_icon.png");
    liQuan:setPosition(410, 36)
    self:addChild(liQuan);

    local liQuanLabel = display.newTTFLabel({text = ""..FormatNumToString(AccountInfo.present),
                                        size = 22,
                                        color = cc.c3b(250,218,76),
                                        font = "",
                                        align = cc.ui.TEXT_ALIGN_CENTER
                                    })
    liQuanLabel:enableOutline(cc.c4b(0x03,0x08,0x06,255),2)
    liQuanLabel:setAnchorPoint(cc.p(0,0.5))
    liQuanLabel:setPosition(cc.p(liQuanBg:getContentSize().width/2-30, liQuanBg:getContentSize().height/2))
    liQuanBg:addChild(liQuanLabel)
    self.liQuanLabel = liQuanLabel

    local startXPos = 600
    local yPos = 56
    local nDis = 100

    if OnlineConfig_review == "off" then
        --兑换
        local btn = ccui.Button:create("show/hall_btn_exchange.png");
        btn:setPosition(cc.p(startXPos, yPos));
        btn:onClick(
            function()
                self:onClickExchange()
            end
        );
        self:addChild(btn);

        startXPos = startXPos + nDis
    end

    if OnlineConfig_review == "off" then
        --活动
        local btn = ccui.Button:create("show/hall_btn_activity.png");
        btn:setPosition(cc.p(startXPos, yPos));
        btn:onClick(function() self:onClickActivity() end);
        -- self:addChild(btn);

        -- startXPos = startXPos + nDis
    end

    --CZ
    local btn = ccui.Button:create("show/hall_btn_charge.png");
    btn:setPosition(cc.p(startXPos, yPos));
    btn:onClick(function()self:shopHandler()end);
    self:addChild(btn);

    startXPos = startXPos + nDis

    if OnlineConfig_review == "off" then
        --XX
        local btn = ccui.Button:create("show/hall_btn_msg.png");
        btn:setPosition(cc.p(startXPos, yPos));
        btn:onClick(function()self:noticeHandler()end);
        self:addChild(btn);

        startXPos = startXPos + nDis
    end

    --SZ
    local btn = ccui.Button:create("show/hall_btn_set.png");
    btn:setPosition(cc.p(startXPos, yPos));
    btn:onClick(function()self:settingHandler()end);
    self:addChild(btn);

end

function showLayer:shopHandler()
    -- local shop = require("show_zjh.popView_Hall.ShopLayer").new(1)
    -- self:addChild(shop,1000)

    local buy = require("show_zjh.popView_Hall.ShopLayer_New").new(2)
    buy:setPurchaseCallBack(self, function() self:showAppRestorePurchaseLayer() end)
    self:popLayer(buy)
end

function showLayer:noticeHandler()
    local setting = require("show_zjh.popView_Hall.NoticeLayer").new(1)
    self:popLayer(setting)
end

function showLayer:settingHandler()
    local setting = require("show_zjh.popView_Hall.SettingLayer").new()
    self:popLayer(setting)
end

function showLayer:onClickExchange()

    -- Hall.showTips(" 即将上线，敬请期待 ! ")

    local newLayer = require("show_zjh.popView_Hall.ExchangeCouponLayer").new()
    self:popLayer(newLayer)
    self.exchangeLayer = newLayer
end

function showLayer:popLayer(layer)
    local winSize = cc.Director:getInstance():getWinSize()
    layer:setPosition(cc.p(winSize.width/2,winSize.height/2));
    layer:setAnchorPoint(cc.p(0.5,0.5))
    layer:ignoreAnchorPointForPosition(false)
    self:addChild(layer,1000)
end

function showLayer:initTopBtns()
    -- print("---showLayer:initTopBtns---")

    local winSize = cc.Director:getInstance():getWinSize();

    local startXPos = winSize.width-80
    local yPos = winSize.height-70
    local nDis = 110

    -- --首充礼包
    -- local btn = ccui.Button:create("show/hall_btn_sc.png");
    -- btn:setPosition(cc.p(startXPos, yPos));
    -- btn:onClick(
    --     function()
    --         self:onClickGuestLiBao(1)
    --     end
    -- );
    -- self:addChild(btn);

    -- self.sc_btn = btn

    -- startXPos = startXPos - nDis

    -- --按照运营需求还有一个“每日礼包”，这次上传审核期间加上

    -- --新手礼包
    -- local btn = ccui.Button:create("show/hall_btn_xs.png");
    -- btn:setPosition(cc.p(startXPos, yPos));
    -- btn:onClick(
    --     function()
    --         self:onClickGuestLiBao(2)
    --     end
    -- );
    -- self:addChild(btn);

    -- self.xs_btn = btn

    -- startXPos = startXPos - nDis

    --每日金币
    local btn = ccui.Button:create("show/hall_btn_mr.png");
    btn:setPosition(cc.p(startXPos, yPos));
    btn:onClick(
        function()
            -- FreeChip("http://activity.game100.cn/hall/index/index")
            -- openWebView("http://activity.game100.cn/hall/index/index?sessionid="..AccountInfo.sessionId)
            openPortraitWebView("http://activity.game100.cn/hall/index/index?sessionid="..AccountInfo.sessionId)
        end
    );
    self:addChild(btn);

    self.mr_coin_btn = btn

    startXPos = startXPos - nDis

end

function showLayer:refreshButtonStatus()

    -- print("测试充值后刷新 showLayer ！")

    local nDis = 110

    if self.liBaoLayer then
        self.liBaoLayer:removeFromParent()
        self.liBaoLayer = nil
    end

    -- if self.sc_btn or self.xs_btn or self.mr_coin_btn then
    --     local winSize = cc.Director:getInstance():getWinSize();

    --     local startXPos = winSize.width-80
    --     local yPos = winSize.height-70
        
    --     if PayInfo:getChargeStatusById(437) then
    --         self.sc_btn:hide()
    --     else
    --         self.sc_btn:show()
    --         self.sc_btn:setPosition(cc.p(startXPos, yPos));
    --         startXPos = startXPos - nDis
    --     end

    --     if PayInfo:getChargeStatusById(438) then
    --         self.xs_btn:hide()
    --     else
    --         self.xs_btn:show()
    --         self.xs_btn:setPosition(cc.p(startXPos, yPos));
    --         startXPos = startXPos - nDis
    --     end

    --     --每日金币
    --     self.mr_coin_btn:setPosition(cc.p(startXPos, yPos));
    --     startXPos = startXPos - nDis
    -- end

end

function showLayer:selectGame(index)

    if self.isGameLoading then
        Hall.showTips(" 正在下载中，请稍后 ! ")
        return
    end

    if index == self.curIndex then
        --进入选择的游戏
        if index == 2 then
            Hall:selectGame("zhajinhua")
        elseif index == 4 then
        elseif index == 3 then
            -- Hall:selectGame("landlordCutie")
            Hall.showTips(" 即将上线，敬请期待 ! ")
        elseif index == 1 then

            local isFishFinished = cc.UserDefault:getInstance():getBoolForKey("fishing_Finish", false)
            local unzipIsFinished = cc.UserDefault:getInstance():getBoolForKey(gamePackage.fishing.file, false)

            if not isFishFinished or not unzipIsFinished then --下载失败
                self:downloadAndEnterGame("fishing")
            else
                Hall:selectGame("fishing");
            end
            
        end
    else
        self.curIndex = index
        self.selected_ani:setPosition(cc.p(self.posArr[index].x-36,self.posArr[index].y+60))--self.posArr[index]
        for i=1,3 do
            self.gameBtns[i]:stopAllActions()
            if i ~= self.curIndex then
                self.gameBtns[i]:setScale(0.8)
                self.gameBtns[i]:getAnimation():stop()
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

        --是否有更新下载
        if index == 2 then
            -- Hall:selectGame("zhajinhua")
        elseif index == 1 then
            -- Hall.showTips(" 即将上线，敬请期待 ! ")
            local unzipIsFinished = cc.UserDefault:getInstance():getBoolForKey(gamePackage.fishing.file, false)
            --test
            -- unzipIsFinished = true
            if unzipIsFinished then
                --更新
                require("updateSingleGame"):checkUpdate(self,1038,"fishing")
            else
                self:downloadAndEnterGame("fishing")
            end
        elseif index == 3 then
            -- Hall:selectGame("landlordCutie")
            Hall.showTips(" 即将上线，敬请期待 ! ")
        elseif index == 4 then
            Hall.showTips(" 即将上线，敬请期待 ! ")
        end
    end


end

function showLayer:getHallAnimation()
    local manager = ccs.ArmatureDataManager:getInstance()
    if manager:getAnimationData("ani_dating_game") == nil then
        manager:addArmatureFileInfo("effect/game_icon/ani_dating_game0.png","effect/game_icon/ani_dating_game0.plist","effect/game_icon/ani_dating_game.ExportJson")
    end
    local armature = ccs.Armature:create("ani_dating_game")
    return armature;
end

function showLayer:getSelectedAnimation()
    local manager = ccs.ArmatureDataManager:getInstance()
    if manager:getAnimationData("dating_xuanzhong") == nil then
        manager:addArmatureFileInfo("effect/selected/dating_xuanzhong0.png","effect/selected/dating_xuanzhong0.plist","effect/selected/dating_xuanzhong.ExportJson")
    end
    local armature = ccs.Armature:create("dating_xuanzhong")
    return armature;
end

function showLayer:onClickGuestLiBao(kind)
    Hall.showTips(" 即将上线，敬请期待 ! ")
    -- local newLayer = require("show.popView_Hall.GuestLiBaoLayer").new(kind)
    -- self:addChild(newLayer,100)
    -- self.liBaoLayer = newLayer
end

function showLayer:onClickActivity()
    --保存commonjs
    local activityManager = require("data.ActivityManager"):getInstance()
    activityManager:saveCommonJs()
    activityManager:callActivityWebView()
end

--更新模块Delegate方法
function showLayer:onDownloadStart(index, total)
    if self.flag then
        self.flag = false
        Hall.showWaitingState("下载更新中,请稍等...")
        self:downloadProcessBar(self.curIndex)
    end
    -- print("showLayer...onDownloadStart",index,total)
    --TODO 更新界面
    local percent = 0
    if total ~= 0 then
       percent = index / total
    end
    local text = "下载...("..index.."/"..total..")".." "..string.format("%.1f%%", percent*100);

    if self.progress and self.progressTxt then
        self.progress:setTextureRect(cc.rect(0,0,math.floor(175*percent),24))
        self.progressTxt:setString(text)
    end      
    
end

function showLayer:onDownloadProgess(singleProgess, singleTotal)
    -- print("showLayer...onDownloadProgess",singleProgess,singleTotal)
end

function showLayer:onDownloadFinish(errorCode)
    -- print("测试...showLayer:onDownloadFinish")
    if self.progress_bg then
        self.progress_bg:removeFromParent()
        self.progress_bg = nil
    end
    if self.progress then
        self.progress:removeFromParent()
        self.progress = nil
    end
    if self.progressTxt then
        self.progressTxt:removeFromParent()
        self.progressTxt = nil
    end
    if not self.flag then
        Hall.hideWaitingState()
        Hall.showTips(" 更新完成 ! ")
        self.flag = true
    end
end

return showLayer;