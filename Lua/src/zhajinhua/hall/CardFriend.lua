local CardFriend = class("CardFriend", function() return display.newLayer() end)
function CardFriend:ctor()
    self:createUI()
end
function CardFriend:createUI()
    local bgWidth = 407
    local bgHeight = 590
    self.slideStatus = 0
    local friendBg = ccui.ImageView:create("hall/cardFriend/friendBg.png")
    friendBg:setScale9Enabled(true)
    friendBg:setContentSize(cc.size(bgWidth,bgHeight))
    friendBg:setAnchorPoint(cc.p(0,0))
    friendBg:setPosition(0, 0)
    friendBg:setTouchEnabled(true)
    friendBg:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:slideIn()
            end
        end
    )
    -- self:addChild(friendBg)
    self.friendBg = friendBg
    self.bgWidth = bgWidth
    local friendLayer = ccui.Layout:create()
    -- friendLayer:setAnchorPoint(cc.p(0.5,0.5))
    friendLayer:setContentSize(cc.size(1136,640))
    friendLayer:setPosition(1136,0)
    -- friendLayer:setBackGroundColorType(1)
    -- friendLayer:setBackGroundColor(cc.c3b(100,123,100))
    
    friendLayer:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:slideIn()
            end
        end
    )
    self.friendLayer = friendLayer
    self:addChild(friendLayer)
    friendLayer:addChild(friendBg)
    local tabPos = {cc.p(79,514),cc.p(209,514),cc.p(331,514)}
    self.tabArray = {}
    for i=1,3 do
        local tab = ccui.Button:create("hall/cardFriend/tab"..i..".png")
        tab:setPosition(tabPos[i])
        tab:setTag(i)
        tab:addTouchEventListener(
            function (sender,eventType)
                if  eventType == ccui.TouchEventType.ended then
                    self:tabHandler(sender)
                end
            end
        )
        friendLayer:addChild(tab)
        table.insert(self.tabArray,tab)
    end

    self.listView = ccui.ListView:create()
    self.listView:setDirection(ccui.ScrollViewDir.vertical)
    self.listView:setBounceEnabled(true)
    self.listView:setContentSize(cc.size(390, 410))
    self.listView:setPosition(8,9.5)
    friendLayer:addChild(self.listView)
    self.listView:addEventListener(function(sender, eventType)
        if eventType == ccui.ListViewEventType.ONSELECTEDITEM_END then

        end
    end)
    self:updateFriend(1)
    local friendButton = ccui.Button:create("hall/cardFriend/buttonFriend.png");
    friendButton:setPosition(cc.p(-25,260));
    friendLayer:addChild(friendButton);
    friendButton:setPressedActionEnabled(true);
    friendButton:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                if self.slideStatus == 0 then
                    self:slideOut()
                else
                    self:slideIn()
                end
                
            end
        end
    )
end
function CardFriend:updateFriend(kind)
    self.listView:removeAllItems()
    for i=1,3 do
        local friendItemLayer = ccui.ImageView:create()

        local custom_item = ccui.Layout:create()
        custom_item:setTouchEnabled(true)
        custom_item:setContentSize(cc.size(390, 187))
        friendItemLayer:setPosition(5, 10)
        custom_item:addChild(friendItemLayer)
        
        local headView = require("commonView.HeadView").new(1)
        headView:setPosition(72,96)
        custom_item:addChild(headView)

        local nickName = ccui.Text:create()
        nickName:setString("王晓亮")
        nickName:setPosition(183, 139)
        nickName:setAnchorPoint(cc.p(0.5,0.5))
        nickName:setFontSize(24)
        nickName:setColor(cc.c3b(254, 253, 54))
        custom_item:addChild(nickName)

        local chip = ccui.ImageView:create("hall/room/chouma_icon.png")
        chip:setPosition(276,139)
        custom_item:addChild(chip)

        local money = ccui.Text:create()
        money:setString("7898万")
        money:setPosition(302, 139)
        money:setAnchorPoint(cc.p(0.0,0.5))
        money:setFontSize(24)
        money:setColor(cc.c3b(254, 253, 54))
        custom_item:addChild(money)

        local relation = ccui.Text:create()
        relation:setString("近期赢走你")
        relation:setPosition(197, 100)
        relation:setAnchorPoint(cc.p(0.5,0.5))
        relation:setFontSize(20)
        relation:setColor(cc.c3b(254, 253, 54))
        custom_item:addChild(relation)

        local relationMoney = ccui.Text:create()
        relationMoney:setString("7898万")
        relationMoney:setPosition(256, 100)
        relationMoney:setAnchorPoint(cc.p(0.0,0.5))
        relationMoney:setFontSize(20)
        relationMoney:setColor(cc.c3b(254, 253, 54))
        custom_item:addChild(relationMoney)

        local status = ccui.Text:create()
        status:setString("当前状态")
        status:setPosition(189, 72)
        status:setAnchorPoint(cc.p(0.5,0.5))
        status:setFontSize(20)
        status:setColor(cc.c3b(254, 253, 54))
        custom_item:addChild(status)

        local statusValue = ccui.Text:create()
        statusValue:setString("大厅")
        statusValue:setPosition(249, 72)
        statusValue:setAnchorPoint(cc.p(0.0,0.5))
        statusValue:setFontSize(20)
        statusValue:setColor(cc.c3b(254, 253, 54))
        custom_item:addChild(statusValue)     

        local invite = ccui.Button:create("hall/cardFriend/invite.png");
        invite:setPosition(cc.p(256,30));
        custom_item:addChild(invite);
        invite:setPressedActionEnabled(true);
        invite:addTouchEventListener(
            function(sender,eventType)
                if eventType == ccui.TouchEventType.ended then
                    self:inviteHandler(sender)
                end
            end
        )

        local goAhead = ccui.Button:create("hall/cardFriend/goto.png");
        goAhead:setPosition(cc.p(349,30));
        custom_item:addChild(goAhead);
        goAhead:setPressedActionEnabled(true);
        goAhead:addTouchEventListener(
            function(sender,eventType)
                if eventType == ccui.TouchEventType.ended then
                    self:gotoHandler(sender)
                end
            end
        )
        self.listView:pushBackCustomItem(custom_item)
    end
end
function CardFriend:inviteHandler(sender)
    
end
function CardFriend:gotoHandler(sender)
    
end
function CardFriend:tabHandler(sender)
    local kind = sender:getTag()
    for i=1,3 do
        if i == kind then
            self.tabArray[i]:setScale(1)
        else
            self.tabArray[i]:setScale(0.5)
        end     
    end
    self:updateFriend(kind)
end
function CardFriend:slideOut()
    self.friendLayer:setPosition(1136, 0)
    local moveby = cc.MoveBy:create(0.2, cc.p(-self.bgWidth, 0))
    local fun = cc.CallFunc:create(function ()
        self.friendLayer:setPosition(1136-self.bgWidth, 0)
        self.slideStatus = 1
    end)
    self.friendLayer:runAction(cc.Sequence:create(moveby,fun))
    self.friendLayer:setTouchEnabled(true)
end
function CardFriend:slideIn()
    self.friendLayer:setPosition(1136-self.bgWidth, 0)
    local moveby = cc.MoveBy:create(0.2, cc.p(self.bgWidth, 0))
    local fun = cc.CallFunc:create(function ()
        self.friendLayer:setPosition(1136, 0)
        self.slideStatus = 0
    end)
    self.friendLayer:runAction(cc.Sequence:create(moveby,fun))
    self.friendLayer:setTouchEnabled(false)
end
return CardFriend