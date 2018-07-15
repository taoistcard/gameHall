local FansRankLayer = class("FansRankLayer", function() return display.newLayer(); end );

function FansRankLayer:ctor()
    local winSize = cc.Director:getInstance():getWinSize()
    local contentSize = cc.size(1136,winSize.height)
    -- 蒙板
    local maskLayer = ccui.ImageView:create("blank.png")
    maskLayer:setScale9Enabled(true)
    maskLayer:setContentSize(contentSize)
    maskLayer:setPosition(cc.p(display.cx, display.cy));
    maskLayer:setTouchEnabled(true)
    self:addChild(maskLayer)
    local maskImg = ccui.ImageView:create("landlordVideo/video_mask.png")
    maskImg:setPosition(cc.p(757, winSize.height / 2));
    maskLayer:addChild(maskImg)

    self:createUI()
end

function FansRankLayer:createUI()
    local fansRankList = ccui.ImageView:create()
    fansRankList:loadTexture("common/pop_bg.png")
    fansRankList:setScale9Enabled(true)
    fansRankList:setContentSize(cc.size(622,622))
    fansRankList:setCapInsets(cc.rect(115,215,1,1))
    fansRankList:setPosition(cc.p(815,315))
    self:addChild(fansRankList)
    local title_text_bg = ccui.ImageView:create()
    title_text_bg:loadTexture("common/pop_title.png")
    title_text_bg:setAnchorPoint(cc.p(0,0.5))
    title_text_bg:setPosition(cc.p(45,580))
    fansRankList:addChild(title_text_bg)
    local title_text = ccui.Text:create("粉丝排行榜",FONT_ART_TEXT,22)
    title_text:setTextColor(cc.c4b(251,248,142,255))
    title_text:enableOutline(cc.c4b(137,0,167,200), 2)
    title_text:setPosition(cc.p(68,70))
    title_text_bg:addChild(title_text)

    local myRankTxt = ccui.Text:create()
    myRankTxt:setString("我的排名：")
    myRankTxt:setFontSize(20)
    myRankTxt:enableOutline(cc.c4b(61,4,0,255), 2)
    myRankTxt:setAnchorPoint(cc.p(0,0.5))
    myRankTxt:setPosition(cc.p(150,550))
    fansRankList:addChild(myRankTxt)

    local myRankLabel = ccui.Text:create()
    myRankLabel:setString("不在排名内")
    myRankLabel:setFontSize(20)
    myRankLabel:setColor(cc.c3b(255,255,0))
    myRankLabel:enableOutline(cc.c4b(61,4,0,255), 2)
    myRankLabel:setAnchorPoint(cc.p(0,0.5))
    myRankLabel:setPosition(cc.p(240,550))
    fansRankList:addChild(myRankLabel)
    self.myRankLabel = myRankLabel

    local sendLoveTxt = ccui.Text:create()
    sendLoveTxt:setString("赠送主播魅力")
    sendLoveTxt:setFontSize(20)
    sendLoveTxt:setColor(cc.c3b(0,255,0))
    sendLoveTxt:enableOutline(cc.c4b(61,4,0,255), 2)
    sendLoveTxt:setAnchorPoint(cc.p(0,0.5))
    sendLoveTxt:setPosition(cc.p(420,550))
    fansRankList:addChild(sendLoveTxt)
    -- local maskLayer = cc.LayerColor:create(cc.c4b(255, 0, 0, 255))
    -- maskLayer:setContentSize(cc.size(530, 430));
    -- maskLayer:setPosition(cc.p(45, 100));
    -- fansRankList:addChild(maskLayer)
    self.listView = ccui.ListView:create()
    self.listView:setDirection(ccui.ScrollViewDir.vertical)
    self.listView:setBounceEnabled(true)
    self.listView:setContentSize(cc.size(530, 430))
    self.listView:ignoreAnchorPointForPosition(false)
    self.listView:setPosition(45,100)
    fansRankList:addChild(self.listView)
    -- ListView点击事件回调
    local function listViewEvent(sender, eventType)
        -- 事件类型为点击结束
        if eventType == ccui.ListViewEventType.ONSELECTEDITEM_END then
            -- print("AnchorChangeLayerselect child index = ",sender:getCurSelectedIndex())
            -- local anchorInfo = AnchorList[sender:getCurSelectedIndex()+1]
            -- if anchorInfo then
            --     -- TTCStop()
            --     -- TTCPlayWithUserID(anchorInfo.userId)
            -- end
        end
    end
    -- 设置ListView的监听事件
    self.listView:addEventListener(listViewEvent)

    --tab button
    local tabButtonPos = {
        {150,60},
        {310,60},
        {470,60},
    }
    for i=1,3 do
        local tabButton = ccui.ImageView:create("landlordVideo/fansRank/fansRank_normal"..i..".png")
        tabButton:setTouchEnabled(true)
        tabButton:setPosition(cc.p(tabButtonPos[i][1],tabButtonPos[i][2]))
        tabButton:setName("tabButton"..i)
        fansRankList:addChild(tabButton)
        tabButton:addTouchEventListener(function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                -- SoundManager.playSound("sound/buttonclick.mp3")
                self:onClickTabButton(i)
            end
        end)
    end

    --关闭按钮
    local closeButton = ccui.Button:create("common/close.png")
    closeButton:setPressedActionEnabled(true)
    closeButton:setPosition(cc.p(590,585))
    fansRankList:addChild(closeButton)
    closeButton:addTouchEventListener(function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                -- SoundManager.playSound("sound/buttonclick.mp3")
                self:onCloseClick()
            end
        end)

    self.fansRankList = fansRankList
end

function FansRankLayer:onClickTabButton(index)
    local unselectedIcon = {
                        "video_vip/img/fansRank/today1.png",
                        "video_vip/img/fansRank/lastday1.png",
                        "video_vip/img/fansRank/lastweek1.png"
                    }
    local selectedIcon = {
                        "video_vip/img/fansRank/today2.png",
                        "video_vip/img/fansRank/lastday2.png",
                        "video_vip/img/fansRank/lastweek2.png"
                    }
    for i=1,3 do
        local tabButton = self.fansRankList:getChildByName("tabButton"..i)
        if i == index then
            tabButton:loadTexture("landlordVideo/fansRank/fansRank_select"..i..".png")
        else
            tabButton:loadTexture("landlordVideo/fansRank/fansRank_normal"..i..".png")
        end
    end
    self:refreshFansRank(index)
end

function FansRankLayer:refreshFansRank(orderType)
    self.listView:removeAllItems()
    local loveRank = LoveRankManager.getLoveRank(orderType)
    local myRankIndex = 0
    if loveRank.Order == nil or rankUserCount == 0 then
        --TODO 显示无排名
        print("暂无排名信息")
    else
        for i=1,#loveRank.Order do
            local rankItemLayer = require("landlordVideo.FansRankItemLayer").new()
            local custom_item = ccui.Layout:create()
            custom_item:setTouchEnabled(true)
            custom_item:setContentSize(rankItemLayer:getContentSize())
            custom_item:addChild(rankItemLayer)
            self.listView:pushBackCustomItem(custom_item)

            rankItemLayer:updateRankItem(loveRank.Order[i],i)
            if loveRank.Order[i].dwUserID == DataManager:getMyUserID() then
                myRankIndex = i
            end
        end
    end

    if myRankIndex == 0 then
        self.myRankLabel:setString("不在排名内")
    else
        self.myRankLabel:setString("第"..myRankIndex.."名")
    end
end

function FansRankLayer:onCloseClick()
    self:hide()
end

function FansRankLayer:showFansRankLayer()
    print("RoomChangeLayer:showRoomListLayer")
    self:show()
    self:onClickTabButton(1)
end

return FansRankLayer
