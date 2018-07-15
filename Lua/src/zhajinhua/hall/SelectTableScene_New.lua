local SelectTableScene = class("SelectTableScene", require("ui.CCBaseScene_ZJH"))

local ScaleMode = {
    INIT = 0.9,
    NORMAL = 1,
}
local headPos = {cc.p(61,269),cc.p(57,128),cc.p(261,80),cc.p(453,123),cc.p(451,270)}
local DateModel = require("zhajinhua.DateModel")
local directorWinSize = cc.Director:getInstance():getWinSize();
function SelectTableScene:ctor(index)
    -- 根节点变更为self.container
    self.super.ctor(self)    
    if RunTimeData:getRoomIndex() > 3 then
        RunTimeData:setRoomIndex(1)
    end
    self.index = RunTimeData:getRoomIndex() --index or 1
    local wTableCount = RoomInfo.serverConfig.tableCount--RoomServerInfo:getInstance():getTableCount()
    print("SelectTableScene--wTableCount",wTableCount)
    self.tableNum = wTableCount--60
    self.moveCount = 0
    self.lastTableID = -1
    self.tablePlayerInfo = {{},{},{},{},{}}
    --背景
    local bgSprite = cc.Sprite:create()
    bgSprite:setTexture("common/table.jpg")
    bgSprite:align(display.CENTER, DESIGN_WIDTH/2, DESIGN_HEIGHT/2)
    self.container:addChild(bgSprite)
    self:createUI(self.index)
end
function SelectTableScene:onExit()
    onUmengEventEnd("xuanzhuo")
end
function SelectTableScene:onEnter()
    onUmengEventBegin("xuanzhuo")
    self:showBigTable(1)
    self:setSelfInfo()
    self:registerEventListener()
    self:updateTablePlayerInfo()
    self:onUpdateTableInfo()
end
function SelectTableScene:registerEventListener()
    self.bindIds = {}

    self.bindIds[#self.bindIds + 1] = BindTool.bind(RoomInfo, "userInfo", handler(self, self.onUserEnter));
    self.bindIds[#self.bindIds + 1] = BindTool.bind(RoomInfo, "userInfoList", handler(self, self.onUpdateUserList));
    self.bindIds[#self.bindIds + 1] = BindTool.bind(TableInfo, "userStatus", handler(self, self.onUserStatusChange));
    self.bindIds[#self.bindIds + 1] = BindTool.bind(RoomInfo, "tableStatus", handler(self, self.onUpdateTableStatus));
    self.bindIds[#self.bindIds + 1] = BindTool.bind(RoomInfo, "tableStatusList", handler(self, self.onUpdateTableInfo));
    self.bindIds[#self.bindIds + 1] = BindTool.bind(TableInfo, "userSitDownResult", handler(self, self.onSitDownResult));
    self.bindIds[#self.bindIds + 1] = BindTool.bind(AccountInfo, "score", handler(self, self.refreshScore));
    self.connected_handler = GameConnection:addEventListener(NetworkManagerEvent.SOCKET_CONNECTED, handler(self, self.onSocketStatus));
end
function SelectTableScene:removeEventListener()
    for _, bindid in ipairs(self.bindIds) do
        BindTool.unbind(bindid)
    end
    GameConnection:removeEventListener(self.connected_handler)
end

function SelectTableScene:refreshScore()
    self.goldValueText2:setString(FormatNumToString(AccountInfo.score))
end

-- 构建界面
function SelectTableScene:createUI(index)
    -- index = 1
    local title = ccui.ImageView:create("hall/selectTable/title"..index..".png")
    title:setPosition(1036, 518)
    self.container:addChild(title)

    --单张桌子
    local singleTable = ccui.ImageView:create("hall/selectTable/bigTable"..self.index..".png")
    singleTable:setPosition(0, 157)
    singleTable:setVisible(false)
    self.container:addChild(singleTable)
    self.singleTable = singleTable
    --桌子列表
    self.bigtablelistView = ccui.ListView:create()
    self.bigtablelistView:setDirection(ccui.ScrollViewDir.horizontal)
    self.bigtablelistView:setBounceEnabled(true)
    self.bigtablelistView:setContentSize(cc.size(1136, 313+27))
    self.bigtablelistView:setPosition(0,177)
    -- self.bigtablelistView:setBackGroundColorType(1)
    -- self.bigtablelistView:setBackGroundColor(cc.c3b(100,123,100))
    self.container:addChild(self.bigtablelistView)

    local function listViewEvent(sender, eventType)  
        -- 事件类型为点击结束  
        if eventType == ccui.ListViewEventType.ONSELECTEDITEM_END then  
            print("select child index = ",sender:getCurSelectedIndex())
            -- self:selectTableAction(sender:getCurSelectedIndex())
            local tag = sender:getCurSelectedIndex()
            local tableNum = self.tableNum
            local maxdis = 568*(tableNum-1)
            local moveX = (tag-1)*568
            self.bigtablelistView:scrollToPercentHorizontal(100*moveX/maxdis,1,true)
        end  
    end  
    -- 设置ListView的监听事件
    self.bigtablelistView:addEventListener(listViewEvent)
    local lastPositonX = 0
    -- 滚动事件方法回调  
    local function scrollViewEvent(sender, eventType)  
        -- 滚动到底部  
        if eventType == ccui.ScrollviewEventType.scrolling then

        else
            -- print("eventType",eventType)
        end
      
    end
    self.bigtablelistView:addScrollViewEventListener(scrollViewEvent)
    self.bigtablelistView:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            print("eventType=ended")
            self.moveCount = 0
            self:performWithDelay(function ()
                self:selectTableStop()
            end, 0.5)
        elseif eventType == ccui.TouchEventType.began then
            return true
        elseif eventType == ccui.TouchEventType.canceled then
            print("eventType=canceledcanceledcanceled")
            self.moveCount = 0
            self:performWithDelay(function ()
                self:selectTableStop()
            end, 0.5)
        elseif eventType == ccui.TouchEventType.moved then
            --todo
            if self.moveCount == 0 then
                self.moveCount = self.moveCount + 1
                self.singleTable:runAction(cc.ScaleTo:create(0.2, ScaleMode.INIT))
            end
        end
        -- print("eventType",eventType)
    end)

    local fastEntry = ccui.Button:create("hall/selectTable/fastEntry.png","hall/selectTable/fastEntrySelected.png")
    fastEntry:setPosition(1070, 210)--942, 210
    fastEntry:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:fastStart()
            end
        end
    )
    self.container:addChild(fastEntry)

    local changeRoom = ccui.Button:create("hall/selectTable/changeRoom.png","hall/selectTable/changeRoomSelected.png")
    changeRoom:setPosition(1070, 210)
    changeRoom:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:changeRoomHandler()
            end
        end
    )
    changeRoom:hide()
    self.container:addChild(changeRoom)

    local custom_item = ccui.Layout:create()
    custom_item:setContentSize(cc.size(568/2,320))
    -- custom_item:setBackGroundColorType(1)
    -- custom_item:setBackGroundColor(cc.c3b(155-0*10,0*10,0))
    self.bigtablelistView:pushBackCustomItem(custom_item)
    local tableIDPos = cc.p(293, 196)
    if self.index == 3 then
        tableIDPos = cc.p(293, 185)
    end

    for i=1,self.tableNum do
        local tableBg = ccui.ImageView:create("hall/selectTable/bigTable"..self.index..".png")
        tableBg:setPosition(568/2, 157)
        tableBg:setScale(ScaleMode.INIT)
        -- tableBg:setTouchEnabled(true)
        -- tableBg:setTouchSwallowEnabled(false)
        -- tableBg:addTouchEventListener(
        --     function (sender,eventType )
        --         if eventType == ccui.TouchEventType.ended then
        --             print("tableBg==fjaskdfjlkajsf")
        --         elseif eventType == ccui.TouchEventType.began then
        --             return true
        --         end
        --     end
        --     )
        local tableNum = require("zhajinhua.NumberLayer").new() --ccui.Text:create(i,"",24)
        tableNum:setPosition(tableIDPos)--294, 209
        -- tableNum:setColor(cc.c3b(255, 255, 255))
        -- tableNum:setFontSize(35)
        -- tableNum:setName("tableNum")
        tableNum:updateNum(self.index, i)
        tableBg:addChild(tableNum)

        -- local onLineCount = ccui.Text:create("0/5","",24)
        -- onLineCount:setPosition(256, 142)
        -- onLineCount:setColor(cc.c3b(255, 255, 255))
        -- onLineCount:setFontSize(20)
        -- onLineCount:setName("onLineCount")
        -- tableBg:addChild(onLineCount)        

        local custom_item = ccui.Layout:create()
        custom_item:setTouchEnabled(true)
        custom_item:setTouchSwallowEnabled(false)
        custom_item:addTouchEventListener(
            function (sender,eventType )
                if eventType == ccui.TouchEventType.ended then
                    print("eventType=ended")
                    self.moveCount = 0
                    self:performWithDelay(function ()
                        self:selectTableStop()
                    end, 0.5)
                elseif eventType == ccui.TouchEventType.began then
                    return true
                elseif eventType == ccui.TouchEventType.canceled then
                    print("eventType=canceledcanceledcanceled")
                    self.moveCount = 0
                    self:performWithDelay(function ()
                        self:selectTableStop()
                    end, 0.5)
                elseif eventType == ccui.TouchEventType.moved then
                    --todo
                    if self.moveCount == 0 then
                        self.moveCount = self.moveCount + 1
                        self.singleTable:runAction(cc.ScaleTo:create(0.2, ScaleMode.INIT))
                    end
                end
            end
            )
        custom_item:setContentSize(cc.size(568,320))
        custom_item:addChild(tableBg)
        -- custom_item:setBackGroundColorType(1)
        -- custom_item:setBackGroundColor(cc.c3b(155-i*10,i*10,0))
        custom_item:setTag(i)
        self.bigtablelistView:pushBackCustomItem(custom_item)
    end
    local custom_item = ccui.Layout:create()
    custom_item:setContentSize(cc.size(568/2,320))
    -- custom_item:setBackGroundColorType(1)
    -- custom_item:setBackGroundColor(cc.c3b(155-11*10,11*10,0))
    self.bigtablelistView:pushBackCustomItem(custom_item)

    self:createTopView()
    self:createBottomPageView()


end

function SelectTableScene:fastStart()
    DateModel:getInstance():setTableID(65535)
    DateModel:getInstance():setChairID(65535)
    self:gotoPlayScene(2)
end

function SelectTableScene:onTouch(event, x, y)
    print("onTouch", event, x, y)
    return true
end

-- 大厅上层视图
function SelectTableScene:createTopView()
    
    -- topView bg,as container
    self.hallTopView = ccui.ImageView:create()
    self.hallTopView:loadTexture("hall/room/hall_top_bg.png")
    self.hallTopView:setAnchorPoint(cc.p(0.5,1.0))
    self.hallTopView:setPosition(cc.p(DESIGN_WIDTH/2, DESIGN_HEIGHT+directorWinSize.height/2-DESIGN_HEIGHT/2))
    self.container:addChild(self.hallTopView)

    -- back button
    local backButton = ccui.ImageView:create()
    backButton:setTouchEnabled(true)
    backButton:loadTexture("common/back.png")
    backButton:setPosition(cc.p(90,75))
    self.hallTopView:addChild(backButton)
    backButton:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.began then
            -- SoundManager:getInstance():playSoundByType(SoundType.BTN_CLICK)
            backButton:setScale(1.1)
        elseif eventType == ccui.TouchEventType.ended then
            backButton:setScale(1.0)
            self:gotoRoomScene();
        elseif eventType == ccui.TouchEventType.canceled then
            backButton:setScale(1.0)
        end
    end)

    -- 用户个人信息
    local selfInfoLayer = cc.Node:create(); --ccui.ImageView:create()
    -- selfInfoLayer:loadTexture("hall/room/hall_selfinfo_bg.png")
    -- selfInfoLayer:setAnchorPoint(cc.p(0.5,1.0))
    selfInfoLayer:setPosition(cc.p(155, 0))
    self.hallTopView:addChild(selfInfoLayer)

    --头像
    local headView = require("commonView.HeadView").new(1);
    headView:setScale(0.9)
    headView:setPosition(cc.p(60,56))
    selfInfoLayer:addChild(headView);
    self.headImage = headView;

    --等级
    self.levelText = ccui.Text:create("LV.1",FONT_ART_TEXT,22)
    self.levelText:setAnchorPoint(cc.p(0,0.5))
    self.levelText:setPosition(cc.p(140,40))
    self.levelText:setTextColor(cc.c4b(255,244,13,255))
    selfInfoLayer:addChild(self.levelText)

    --昵称
    self.nickNameText = ccui.Text:create("这里是昵称",FONT_ART_TEXT,35)
    self.nickNameText:setAnchorPoint(cc.p(0,0.5))
    self.nickNameText:setPosition(cc.p(140,75))
    self.nickNameText:setTextColor(cc.c4b(250,255,255,255))
    selfInfoLayer:addChild(self.nickNameText)

    --个人中心
    local personalCenter = ccui.Button:create("blank.png");
    personalCenter:setScale9Enabled(true)
    personalCenter:setContentSize(240,100)
    personalCenter:setPosition(cc.p(280,38));
    self.hallTopView:addChild(personalCenter);
    personalCenter:setPressedActionEnabled(true);
    personalCenter:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                -- self:onClickPersonalCenter();
            end
        end
    )
    
    --金币信息
    local goldInfoLayer = ccui.ImageView:create()
    goldInfoLayer:loadTexture("common/txtBg.png")
    -- goldInfoLayer:setScale9Enabled(true)
    -- goldInfoLayer:setContentSize(cc.size(200, 45))
    -- goldInfoLayer:setCapInsets(cc.rect(100,25,1,1))
    goldInfoLayer:setPosition(cc.p(700, 70))
    self.hallTopView:addChild(goldInfoLayer)

    local chouma = ccui.ImageView:create()
    chouma:loadTexture("hall/room/chouma_icon.png")
    chouma:setPosition(cc.p(22, 21))
    goldInfoLayer:addChild(chouma)

    --gold value
    self.goldValueText2 = ccui.Text:create("12.8万", FONT_ART_TEXT, 24)
    self.goldValueText2:setColor(cc.c3b(255, 255, 0))
    self.goldValueText2:setAnchorPoint(cc.p(0, 0.5))
    self.goldValueText2:setPosition(cc.p(65, goldInfoLayer:getContentSize().height/2-2))
    goldInfoLayer:addChild(self.goldValueText2)

    --add button
    local addButton2 = ccui.ImageView:create()
    addButton2:setTouchEnabled(true)
    addButton2:loadTexture("common/plus.png")
    addButton2:setPosition(cc.p(210, goldInfoLayer:getContentSize().height/2 - 3))
    goldInfoLayer:addChild(addButton2)
    addButton2:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.began then
            addButton2:setScale(1.1)
        elseif eventType == ccui.TouchEventType.ended then
            addButton2:setScale(1.0)
            self:onClickBuy(2)
        elseif eventType == ccui.TouchEventType.canceled then
            addButton2:setScale(1.0)
        end
    end)

    --礼券信息
    local couponLayer = ccui.ImageView:create("common/txtBg.png")
    couponLayer:setScale9Enabled(true)
    couponLayer:setContentSize(cc.size(200, 45))
    couponLayer:setCapInsets(cc.rect(100,25,1,1))
    couponLayer:setPosition(cc.p(830, 55))
    self.hallTopView:addChild(couponLayer)

    local couponIcon = ccui.ImageView:create("common/ty_lq_icon.png")
    couponIcon:setPosition(20, couponLayer:getContentSize().height/2-2)
    couponLayer:addChild(couponIcon)

    local couponTxt = ccui.Text:create("0",FONT_ART_TEXT,30)
    couponTxt:setColor(cc.c3b(255,255,0))
    couponTxt:setAnchorPoint(cc.p(0,0.5))
    couponTxt:setPosition(cc.p(65,couponLayer:getContentSize().height/2-2))
    couponLayer:addChild(couponTxt)
    self.couponTxt = couponTxt
    -- if OnlineConfig_review == nil or OnlineConfig_review == "on" then
        couponLayer:hide()
    -- end
    --设置
    local settingButton = ccui.ImageView:create()
    settingButton:setTouchEnabled(true)
    settingButton:loadTexture("hall/room/hall_setting.png")
    settingButton:setPosition(cc.p(1045,72))
    self.hallTopView:addChild(settingButton)
    settingButton:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.began then
            settingButton:setScale(1.1)
        elseif eventType == ccui.TouchEventType.ended then
            settingButton:setScale(1.0)
            self:onClickSetting();
        elseif eventType == ccui.TouchEventType.canceled then
            settingButton:setScale(1.0)
        end
    end)

    --奖池按钮
    local award_btn = ccui.ImageView:create("awardPool/award_btn.png")
    award_btn:setTouchEnabled(true)
    award_btn:setPosition(cc.p(1045,0))
    award_btn:setScale(0.6)
    self.hallTopView:addChild(award_btn)

    award_btn:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.began then
                award_btn:setScale(0.7)
            elseif eventType == ccui.TouchEventType.ended then
                award_btn:setScale(0.6)

                local winSize = cc.Director:getInstance():getWinSize();
                local awardLayer = require("hall.AwardPoolLayer").new(3)
                awardLayer:setPosition(cc.p(0,(640-winSize.height)/2));
                self.container:addChild(awardLayer,10)

            elseif eventType == ccui.TouchEventType.canceled then
                award_btn:setScale(0.6)
            end
        end
    )

    --滚动消息
    local scrollTextContainer = ccui.Layout:create()
    scrollTextContainer:setContentSize(cc.size(600,30))
    scrollTextContainer:setPosition(cc.p(display.left + 100+513, display.top - 60-107))
    self.container:addChild(scrollTextContainer, 3)
    scrollTextContainer:setVisible(false)
    self.scrollTextContainer = scrollTextContainer
    local scrollBg = ccui.ImageView:create("hall/room/scroll_bg.png")
    scrollBg:setPosition(cc.p(313-120,10))
    scrollTextContainer:addChild(scrollBg)
    local scrollTextPanel = ccui.Layout:create()
    scrollTextPanel:setContentSize(cc.size(626,30))
    scrollTextPanel:setName("scrollTextPanel")
    scrollTextPanel:setPosition(cc.p(0,0))
    scrollTextPanel:setClippingEnabled(true)
    scrollTextContainer:addChild(scrollTextPanel)
    -- local labaImg = ccui.ImageView:create("landlordVideo/scroll_laba.png")
    -- labaImg:setPosition(cc.p(20,15))
    -- scrollTextContainer:addChild(labaImg)
end
function SelectTableScene:onClickSetting()
    print("onClickSetting")
    local setting = require("hall.SettingLayer").new()
    self.container:addChild(setting)
    Click();
end
function SelectTableScene:onClickBuy(kind)
    --TODO buy something
    print("onClickBuy")
    if true == PlatformGetChannel() then
        if AppChannel == "CMCC" then
            kind = 3
        elseif AppChannel == "CTCC" then
            kind = 5
        end
    end
    
    local buy = require("hall.ShopLayer_New").new(kind)
    buy:setPurchaseCallBack(self,function()
        self:showAppRestorePurchaseLayer()
    end)
    -- buy:addEventListener(HallCenterEvent.EVENT_SHOW_RESTORELAYER, handler(self, self.showAppRestorePurchaseLayer))

    self.container:addChild(buy)

    Click();
end
function SelectTableScene:showAppRestorePurchaseLayer()
    print("showAppRestorePurchaseLayer",tostring(self))
    local appRestorePurchaseLayer = require("hall.AppRestorePurchaseLayer").new()
    self.container:addChild(appRestorePurchaseLayer)
end
function SelectTableScene:createBottomPageView()
    self.bottomPageView = ccui.Layout:create()
    self.bottomPageView:setContentSize(cc.size(1136,170))
    self.bottomPageView:setPosition(cc.p(0,0))
    -- self.bottomPageView:setBackGroundColorType(1)
    -- self.bottomPageView:setBackGroundColor(cc.c3b(255,0,100))
    self.container:addChild(self.bottomPageView)

    local bottombg = ccui.ImageView:create("hall/selectTable/bottom.png")
    bottombg:setPosition(0, 0)
    bottombg:setAnchorPoint(cc.p(0,0))
    bottombg:setScale9Enabled(true);
    bottombg:setContentSize(cc.size(1136,170));
    self.bottomPageView:addChild(bottombg)


    self.listView = ccui.ListView:create()
    self.listView:setDirection(ccui.ScrollViewDir.horizontal)
    self.listView:setBounceEnabled(true)
    self.listView:setContentSize(cc.size(980-14, 168))
    self.listView:setPosition(81-7,1)
    -- self.listView:setBackGroundColorType(1)
    -- self.listView:setBackGroundColor(cc.c3b(100,123,100))
    self.bottomPageView:addChild(self.listView)
    self.tableUserCountUIArray = {}
    local itemNum = (self.tableNum-self.tableNum%2)/2+self.tableNum%2
    for i=1,itemNum do
        local custom_item = ccui.Layout:create()
        custom_item:setTouchEnabled(true)
        custom_item:setContentSize(cc.size(195,168))

        local tabelIndex = (i-1)*2+1
        local tableBgUp = ccui.Button:create("hall/selectTable/smallTable"..self.index..".png")
        tableBgUp:setName("tableBgUp")
        tableBgUp:setPosition(108, 122)
        tableBgUp:setTag(tabelIndex)
        tableBgUp:addTouchEventListener(function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:selectTableHandler(sender)
            end
        end)
        local memberNum = ccui.Text:create(i.."/5","",24)
        memberNum:setPosition(50, 42)
        memberNum:setColor(cc.c3b(255, 255, 255))
        memberNum:setName("memberNum")
        tableBgUp:addChild(memberNum)
        self.tableUserCountUIArray[tabelIndex] = memberNum
        
        local tableNum = ccui.Text:create(tabelIndex.."桌","",24)
        tableNum:setPosition(105, 42)
        tableNum:setColor(cc.c3b(255, 255, 255))
        tableNum:setName("tableNum")
        tableBgUp:addChild(tableNum)        
        custom_item:addChild(tableBgUp)
        custom_item:setTag(i)


        local tabelIndex = (i-1)*2+2
        if tabelIndex<=self.tableNum then
            local tableBgDown = ccui.Button:create("hall/selectTable/smallTable"..self.index..".png")
            tableBgDown:setPosition(108, 41)
            tableBgDown:setName("tableBgDown")
            tableBgDown:setTag(tabelIndex)
            tableBgDown:addTouchEventListener(function(sender,eventType)
                if eventType == ccui.TouchEventType.ended then
                    self:selectTableHandler(sender)
                end
            end)
            local memberNum = ccui.Text:create(i.."/5","",24)
            memberNum:setPosition(50, 42)
            memberNum:setColor(cc.c3b(255, 255, 255))
            memberNum:setName("memberNum")
            tableBgDown:addChild(memberNum)
            self.tableUserCountUIArray[tabelIndex] = memberNum
            
            local tableNum = ccui.Text:create(tabelIndex.."桌","",24)
            tableNum:setPosition(105, 42)
            tableNum:setColor(cc.c3b(255, 255, 255))
            tableNum:setName("tableNum")
            tableBgDown:addChild(tableNum)
            custom_item:addChild(tableBgDown)
            custom_item:setTag(i)
        end
        self.listView:pushBackCustomItem(custom_item)
    end

    local leftArrow = ccui.Button:create("hall/selectTable/turnPage.png","hall/selectTable/turnPage.png","hall/selectTable/turnPageDisable.png")
    leftArrow:setPosition(43, 89)
    leftArrow:setPressedActionEnabled(true)
    leftArrow:setScaleX(-1)
    leftArrow:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:leftClick()
            end
        end
    )
    self.bottomPageView:addChild(leftArrow)
    self.leftArrow = leftArrow
    local rightArrow = ccui.Button:create("hall/selectTable/turnPage.png","hall/selectTable/turnPage.png","hall/selectTable/turnPageDisable.png")
    rightArrow:setPosition(1094, 89)
    rightArrow:setPressedActionEnabled(true)
    rightArrow:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:rightClick()
            end
        end
    )
    self.bottomPageView:addChild(rightArrow)
    self.rightArrow = rightArrow

    -- 滚动事件方法回调  
    local function scrollViewEvent(sender, eventType)  
        -- 滚动到底部  
        if eventType == ccui.ScrollviewEventType.scrollToLeft then  
            -- print("scrollToLeft")  
            -- 滚动到顶部  
        elseif eventType == ccui.ScrollviewEventType.bounceLeft then  
            -- print("bounceLeft")  
        elseif eventType == ccui.ScrollviewEventType.scrolling then
            -- print("self.listView:getInnerContainer():getPositionX()",self.listView:getInnerContainer():getPositionX())
            if self.listView:getInnerContainer():getPositionX()>=-1 then
                leftArrow:setEnabled(false)
                leftArrow:setBright(false)
            else
                leftArrow:setEnabled(true)
                leftArrow:setBright(true)
            end

            if self.listView:getInnerContainer():getPositionX()<=(self.listView:getContentSize().width-self.listView:getInnerContainerSize().width)+1 then
                rightArrow:setEnabled(false)
                rightArrow:setBright(false)
            else
                rightArrow:setEnabled(true)
                rightArrow:setBright(true)
            end
        else
            print("eventType",eventType)
        end  
      
    end
    self.listView:addScrollViewEventListener(scrollViewEvent)--handler(self, self.onUserSignUp)
end
function SelectTableScene:selectTableHandler( sender )
    local tag = sender:getTag()
    self:selectTableAction(tag)
end
function SelectTableScene:selectTableAction(tableIndex)
    local tag = tableIndex
    print("tag",tag)
    local tableNum = self.tableNum
    local maxdis = 568*(tableNum-1)
    local moveX = (tag-1)*568
    self.bigtablelistView:scrollToPercentHorizontal(100*moveX/maxdis,1,true)

    self:performWithDelay(function ()
        self:showBigTable(tag)
    end, 1.1)
end
function SelectTableScene:selectTableStop()
    print("selectTableStop")
    -- print("xxxx",self.bigtablelistView:getInnerContainer():getPositionX())
    local tag = math.floor((284-self.bigtablelistView:getInnerContainer():getPositionX())/568)+1
    -- print("tagtagtag",tag)
    local tableNum = self.tableNum
    local maxdis = 568*(tableNum-1)
    local moveX = (tag-1)*568
    self.bigtablelistView:scrollToPercentHorizontal(100*moveX/maxdis,1,true)
    self:showBigTable(tag)

end
function SelectTableScene:showBigTable( tag )
    print("SelectTableScene:showBigTable",tag)
    if NEW_SERVER then
        DateModel:getInstance():setTableID(tag)
    else
    end
    
    local tableBg = self.singleTable
    tableBg:setPosition(568/2, 157)
    tableBg:setVisible(false)
    tableBg:setScale(ScaleMode.INIT)
    if tableBg:getParent() then
        -- tableBg:retain()
        tableBg:removeFromParent()
        self.bigTableOnLineCount = nil
        tableBg = ccui.ImageView:create("hall/selectTable/bigTable"..self.index..".png")
        tableBg:setPosition(568/2, 157)
        tableBg:setScale(ScaleMode.INIT)
        self.singleTable = tableBg
        print("tableBg:getParent()")
        local lookOn = ccui.Button:create("hall/roomselect/lookOn.png")
        lookOn:setPosition(265,265)
        lookOn:setName("lookOn")
        lookOn:hide()
        lookOn:addTouchEventListener(
            function(sender,eventType)
                if eventType == ccui.TouchEventType.ended then
                    self:randomLookOn()
                end
            end
        )
        tableBg:addChild(lookOn)
        local tableIDPos = cc.p(293, 196)
        if self.index == 3 then
            tableIDPos = cc.p(293, 185)
        end
        local tableNum = require("zhajinhua.NumberLayer").new()
        tableNum:setPosition(tableIDPos)
        tableNum:updateNum(self.index, tag)
        tableNum:setName("tableNum")
        tableBg:addChild(tableNum)

        local userCount = RoomInfo.tableStatusList[tag].sitCount--GameTableInfo:getTableUserCountByTableID(tag)
        local onLineCount = ccui.Text:create(userCount.."/5","",24)
        onLineCount:setPosition(266, 142)
        onLineCount:setColor(cc.c3b(255, 255, 255))
        onLineCount:setFontSize(20)
        onLineCount:setName("onLineCount")
        tableBg:addChild(onLineCount)
        self.bigTableOnLineCount = onLineCount
        for i=1,5 do


            local headbg = ccui.Button:create("common/blank.png")
            headbg:setPosition(headPos[i])
            headbg:setContentSize(cc.size(144,144))
            headbg:setScale9Enabled(true)
            headbg:setScale(0.1)
            headbg:runAction(cc.ScaleTo:create(0.5, 0.9))
            headbg:setTag(i)
            headbg:addTouchEventListener(
                function(sender,eventType)
                    if eventType == ccui.TouchEventType.ended then
                        self:selectChair(sender)
                    end
                end
            )
            self.tablePlayerInfo[i]["headbg"] = headbg
            headbg:hide()
            tableBg:addChild(headbg)

            local headview = require("commonView.HeadView").new(1)
            self.tablePlayerInfo[i]["headview"] = headview
            headview:setPosition(72,72)
            headview:hide()
            headbg:addChild(headview)

            local selectSeat = ccui.Button:create("zhajinhua/sitDown.png","zhajinhua/sitDown.png")
            selectSeat:setPosition(headPos[i])
            selectSeat:setName("selectSeat")
            selectSeat:setTag(i)
            selectSeat:hide()
            selectSeat:setScale(0.1)
            selectSeat:runAction(cc.ScaleTo:create(0.5, 0.9))
            selectSeat:addTouchEventListener(
                function (sender,eventType)
                    if eventType == ccui.TouchEventType.ended then
                        self:selectChair(sender)
                    end
                end
            )
            self.tablePlayerInfo[i]["selectSeat"] = selectSeat
            tableBg:addChild(selectSeat)

            local nickNameBg = ccui.ImageView:create("zhajinhua/nameBg.png")
            nickNameBg:setContentSize(cc.size(100,30))
            nickNameBg:setScale9Enabled(true)
            nickNameBg:setPosition(72, 27)
            nickNameBg:setName("nickNameBg")
            headbg:addChild(nickNameBg)
            local nickName = ccui.Text:create("我是名字","",18)
            nickName:setPosition(49, 16)
            nickName:setColor(cc.c3b(255, 255, 255))
            nickName:setName("nickName")
            self.tablePlayerInfo[i]["nickName"] = nickName
            nickNameBg:addChild(nickName)

            local userGoldBg = ccui.ImageView:create("zhajinhua/userGoldBg.png")
            -- userGoldBg:setContentSize(cc.size(160,30))
            -- userGoldBg:setScale9Enabled(true)
            userGoldBg:setPosition(66, 0)
            userGoldBg:setName("userGoldBg")
            headbg:addChild(userGoldBg)

            local userGold = ccui.Text:create("我是金币","",18)
            userGold:setPosition(35, 15)
            userGold:setAnchorPoint(cc.p(0,0.5))
            userGold:setColor(cc.c3b(255, 255, 255))
            userGold:setName("userGold")
            self.tablePlayerInfo[i]["userGold"] = userGold
            userGoldBg:addChild(userGold)
            -- print("头像",i)
        end
    end
    self.bigtablelistView:getChildByTag(tag):addChild(tableBg)
    tableBg:setVisible(true)
    local action = cc.ScaleTo:create(0.2, ScaleMode.NORMAL)
    tableBg:runAction(action)
    if NEW_SERVER then
        self:onUpdateUserList()
    else
        -- GameCenter:lookOn(DateModel:getInstance():getTableID(), 1)
        -- GameCenter:sitDownCommon(DateModel:getInstance():getTableID(), 1)
    
        if self.lastTableID == tag then
            self:updateTablePlayerInfo()--所选的桌子跟上一张是相同的，刷新ui播动画
        else
            --此时自己的tableID还有没有更新，所以会显示上一桌的人物信息
        end
    end
    self.lastTableID = tag
    -- 
end
function SelectTableScene:updateTablePlayerInfo()
    local showCount = 0
    local selectTable = DateModel:getInstance():getTableID()
    -- print("selectTable",selectTable)
    for i=1,5 do
        local playerInfo = DataManager:getUserInfoInSelectedTableByChairIDExceptLookOn(selectTable,i)
        -- print("playerInfo",i,playerInfo)
        if playerInfo  then
            self.tablePlayerInfo[i]["headbg"]:show()
            self.tablePlayerInfo[i]["selectSeat"]:hide()
            self.tablePlayerInfo[i]["headview"]:show()
            self.tablePlayerInfo[i]["nickName"]:setString(FormotGameNickName(playerInfo.nickName,6)) 
            self.tablePlayerInfo[i]["userGold"]:setString(FormatNumToString(playerInfo.score))
            self.tablePlayerInfo[i]["headview"]:setNewHead(playerInfo.faceID,playerInfo.platformID,playerInfo.platformFace)--
            -- print("headview",playerInfo:faceID(), playerInfo:getTokenID(),playerInfo:getHeadFile())
            showCount = showCount+1
        else
            self.tablePlayerInfo[i]["headbg"]:hide()
            self.tablePlayerInfo[i]["selectSeat"]:show()
            self.tablePlayerInfo[i]["headview"]:hide()
        end
    end
    if showCount>=5 then
        self.singleTable:getChildByName("lookOn"):show()
    else
        self.singleTable:getChildByName("lookOn"):hide()
    end
    
end
function SelectTableScene:randomLookOn()
    local chairID = math.random(0, 4)
    DateModel:getInstance():setChairID(chairID)
    local enterType = 0
    print("旁观",chairID)
    DateModel:getInstance():setLookOn(1)

    self:gotoPlayScene(enterType)
end
function SelectTableScene:selectChair(sender)
    local tag = sender:getTag()
    if NEW_SERVER then
        DateModel:getInstance():setChairID(tag)
    else
        DateModel:getInstance():setChairID(tag-1)
    end
    
    print("选择椅子号",tag)
    local playerInfo = DataManager:getUserInfoInSelectedTableByChairIDExceptLookOn(DateModel:getInstance():getTableID(),tag)
    local enterType = 0
    if playerInfo then--有人就旁观，没人就坐下
        print("旁观")
        DateModel:getInstance():setLookOn(1)
    else
        print("坐下")
        DateModel:getInstance():setLookOn(0)
        enterType = 1
    end
    self:gotoPlayScene(enterType)
end
function SelectTableScene:leftClick()
    local countPerPage = 5
    local childWidth = self.listView:getChildByTag(1):getContentSize().width
    local movePos = childWidth*countPerPage
    local moveX = self.listView:getInnerContainer():getPositionX()+movePos
    local maxdis = self.listView:getInnerContainerSize().width - movePos
    -- print("movePos",movePos,"moveX",moveX,"maxdis",maxdis)
    if 0<=moveX then
        self.listView:scrollToLeft(1,true)
        self.leftArrow:setEnabled(false)
        self.leftArrow:setBright(false)
        -- print("self.listView:scrollToLeft")
    else
        self.leftArrow:setEnabled(true)
        self.leftArrow:setBright(true)
        self.listView:scrollToPercentHorizontal(100*moveX/-maxdis,1,true)
    end
end
function SelectTableScene:rightClick()
    local countPerPage = 5
    local childWidth = self.listView:getChildByTag(1):getContentSize().width
    local movePos = childWidth*countPerPage
    local moveX = self.listView:getInnerContainer():getPositionX()-movePos
    local maxdis = self.listView:getInnerContainerSize().width - movePos
    -- print("movePos",movePos,"moveX",moveX,"maxdis",maxdis)
    if movePos-self.listView:getInnerContainerSize().width>moveX then
        self.listView:scrollToRight(1,true)
        self.rightArrow:setEnabled(false)
        self.rightArrow:setBright(false)
        -- print("self.listView:scrollToRight")
    else
        self.rightArrow:setEnabled(true)
        self.rightArrow:setBright(true)
        self.listView:scrollToPercentHorizontal(100*moveX/-maxdis,1,true)
    end
end
function SelectTableScene:gotoRoomScene()
    TableInfo:sendUserStandUpRequest()--GameCenter:standUp()
    if NEW_SERVER then
        GameConnection:closeConnect() --GameCenter:closeConnection()
    else
    end
    

    self:removeEventListener()
    local roomScene
    if NEW_SERVER == true then
        roomScene = require("hall.RoomScene_New")
    else
    end
    cc.Director:getInstance():replaceScene(cc.TransitionSlideInT:create(0.5, roomScene.new()))
end
--@param enterType 0旁观1坐下2快速坐下
function SelectTableScene:gotoPlayScene(enterType)
    if enterType == 1 then
        local result = false
        local gameServer = RunTimeData:getCurGameServer()
        if gameServer then
            if AccountInfo.score>=gameServer.minEnterScore then
                result = true
            end
        end
        if result == false then
            Hall.showTips("很遗憾，您的筹码不足，至少需要"..gameServer.minEnterScore.."才能加入游戏!", 1)
            return
        end
        local tableID = DateModel:getInstance():getTableID() or 65535
        local chairID = DateModel:getInstance():getChairID() or 65535
        TableInfo:sendUserSitdownRequest(tableID, chairID, password)
    elseif enterType == 2 then
        DateModel:getInstance():setLookOn(0)
        local result = false
        local gameServer = RunTimeData:getCurGameServer()
        if gameServer then
            if AccountInfo.score>=gameServer.minEnterScore then
                result = true
            end
        end
        if result == false then
            Hall.showTips("很遗憾，您的筹码不足，至少需要"..gameServer.minEnterScore.."才能加入游戏!", 1)
            return
        end
        local tableID = DateModel:getInstance():getTableID() or 65535
        local chairID = DateModel:getInstance():getChairID() or 65535
        self:removeEventListener()
        local ZhajinhuaScene
        if NEW_SERVER then
            ZhajinhuaScene = require("zhajinhua.ZhajinhuaScene_New")
        else
        end
        cc.Director:getInstance():replaceScene(cc.TransitionSlideInT:create(0.5, ZhajinhuaScene.new()))
    else
        self:removeEventListener()
        local ZhajinhuaScene
        if NEW_SERVER then
            ZhajinhuaScene = require("zhajinhua.ZhajinhuaScene_New")
        else
        end
        cc.Director:getInstance():replaceScene(cc.TransitionSlideInT:create(0.5, ZhajinhuaScene.new()))
    end
end
function SelectTableScene:changeRoomHandler()
    local bank = require("hall.RoomSelectLayer").new(RunTimeData:getRoomIndex());
    self:addChild(bank);

    Click();
end
function SelectTableScene:setSelfInfo()
    -- 顶部设置自己的属性
        local nickName = FormotGameNickName(AccountInfo.nickName,8)
        self.nickNameText:setString(nickName)
        -- self.goldValueText:setString(FormatNumToString(myInfo:beans()))
        self.goldValueText2:setString(FormatNumToString(AccountInfo.score))
        -- self.couponTxt:setString(FormatNumToString(AccountInfo:getCoupon()))
        self.headImage:setNewHead(AccountInfo.faceId, AccountInfo.cy_userId, AccountInfo.headFileMD5)
        self.headImage:setVipHead(AccountInfo.memberOrder)

        local levelStr = "LV."..getLevelByExp(AccountInfo.medal)
        self.levelText:setString(levelStr)
end
----------------------------------协议回调------------------------------------
function SelectTableScene:onSocketStatus(event)
    print(".... SelectTableScene:enterRoomRequest back ...............")
    if event.name == NetworkManagerEvent.SOCKET_CONNECTED then
        RoomInfo:sendLoginRequest(0, 60)
    elseif event.name == NetworkManagerEvent.SOCKET_CLOSED then
        
    elseif event.name == NetworkManagerEvent.SOCKET_CONNECTE_FAILURE then
        
    end
end
function SelectTableScene:onSitDownResult()
    local response = TableInfo.userSitDownResult
    if response.code == nil then
        self:removeEventListener()
        local ZhajinhuaScene
        if NEW_SERVER then
            ZhajinhuaScene = require("zhajinhua.ZhajinhuaScene_New")
        else
        end
        cc.Director:getInstance():replaceScene(cc.TransitionSlideInT:create(0.5, ZhajinhuaScene.new()))
    else
        Hall.showTips(response.msg, 2)
    end
end
function SelectTableScene:onUpdateTableStatus(event)
    local pTableStatus =  RoomInfo.tableStatus--event.data
    if NEW_SERVER then
        local tableID = pTableStatus.tableID
        local userCount = pTableStatus.sitCount
        -- print("SelectTableScene:onUpdateTableStatus-tableID",tableID,"userCount",userCount)
        self.tableUserCountUIArray[tableID]:setString(userCount.."/5")
        if self.bigTableOnLineCount and DateModel:getInstance():getTableID() == pTableStatus.tableID then
            self.bigTableOnLineCount:setString(userCount.."/5")
        end
    else

    end

end
function SelectTableScene:onUpdateTableInfo(event)
    -- local tableInfo =  event.data
    if NEW_SERVER then
        for i,v in ipairs(RoomInfo.tableStatusList) do
            -- print("SelectTableScene",i,v.isLocked,v.isStarted,v.sitCount,"v.tableID",v.tableID)
            self.tableUserCountUIArray[i]:setString(v.sitCount.."/5")
        end

    end

end
function SelectTableScene:onUpdateUserList()
    if NEW_SERVER then
        -- local myInfo = PlayerInfo:getMyUserInfo()
        -- myInfo.tagUserInfo.wTableID = DateModel:getInstance():getTableID()
        -- print("onUpdateUserList",myInfo.tagUserInfo.wTableID)
        self:updateTablePlayerInfo()
    end
end
function SelectTableScene:onUserEnter(pData)
    -- print("----------SelectTableScene:onUserEnter-----用户ID ： ",RoomInfo.userInfo.userID,"faceID=",RoomInfo.userInfo.faceID,"getMyUserID=",DataManager:getMyUserID())

    if RoomInfo.userInfo.userID == DataManager:getMyUserID() then
        
        DateModel:getInstance():setTableID(1)
    else
        local otherTableID = DataManager:getUserInfoByUserID(RoomInfo.userInfo.userID).tableID
        local myTableID = DataManager:getMyTableID()
        print("otherTableID",otherTableID,"myTableID",myTableID)
        if otherTableID == myTableID then
            self:updateTablePlayerInfo()
        else
            --todo
        end
    end

end
function SelectTableScene:onUserStatusChange(pData)
    local userinfo = DataManager:getUserInfoByUserID(TableInfo.userStatus.userID)
    if userinfo then        
        -- print("----------SelectTableScene:onUserStatusChange-----用户ID ： ",userinfo.nickName,TableInfo.userStatus.userID, ", 用户状态：", TableInfo.userStatus.userStatus)
    end
    if TableInfo.userStatus.userID == DataManager:getMyUserID() then
        --todo
    else
        self:updateTablePlayerInfo()
    end
    
end
return SelectTableScene