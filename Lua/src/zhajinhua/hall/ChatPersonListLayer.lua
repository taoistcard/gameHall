
--
-- Author: <zhaxun>
-- Date: 2015-05-29 15:49:58
--

local ChatPersonListLayer = class("ChatPersonListLayer", function() return display.newNode() end) --require("common.ui.CCModelView"))

local winWidth = 750
local winHeight = 370


function ChatPersonListLayer:ctor(parent)
    --self.super.ctor(self)
    self.parent = parent
    self:setNodeEventEnabled(true)
    self.count = 3
    
    local swallowLayer = ccui.ImageView:create("common/black.png");
    swallowLayer:setScale9Enabled(true);
    swallowLayer:setOpacity(200)
    local winSize = cc.Director:getInstance():getWinSize()

    swallowLayer:setContentSize(cc.size(winSize.width, winSize.height));
    swallowLayer:align(display.CENTER, DESIGN_WIDTH/2, DESIGN_HEIGHT/2)
    swallowLayer:addTo(self);
    swallowLayer:addTouchEventListener(function(sender,eventType)
        -- self:hideChat()
    end)
    swallowLayer:setTouchEnabled(true);
    swallowLayer:setSwallowTouches(true);
    
    self.maskLayer = swallowLayer-- 聊天界面

    self:createUI();

end

function ChatPersonListLayer:createUI()
    local size = self.maskLayer:getContentSize()
    
    self._bg = ccui.ImageView:create("view/frame3.png");
    self._bg:setScale9Enabled(true);
    self._bg:setContentSize(cc.size(winWidth, winHeight));
    self._bg:align(display.BOTTOM_CENTER, size.width / 2, 150)
    self._bg:addTo(self.maskLayer)
    self._bg:addTouchEventListener(function(sender,eventType)
        --self:hide()
    end)
    self._bg:setTouchEnabled(true);
    self._bg:setSwallowTouches(true);

    self:createTopTitle()
    self:showListLayer()

    local exit = ccui.Button:create("common/close2.png");
    exit:setPosition(cc.p(winWidth - 10, winHeight - 10));
    self._bg:addChild(exit);
    exit:setPressedActionEnabled(true);
    exit:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then

                self:removeFromParent();

            end
        end
    )
end

function ChatPersonListLayer:createTopTitle()
    local node = display.newScale9Sprite("view/title_bg.png", 0, 0, cc.size(winWidth-2, 59), cc.rect(20, 20, 10, 10))
               :addTo(self._bg)
                :align(display.CENTER_TOP, winWidth/2, winHeight-2)

    local plinfos = DataManager:getPlayerUserInMyTable()

    local titleLabe = ccui.Text:create("本桌人数: "..#plinfos, FONT_ART_TEXT, 26)
    titleLabe:setColor(cc.c3b(255,255,255));
    titleLabe:setPosition(cc.p(25, 30));
    titleLabe:setAnchorPoint(cc.p(0, 0.5))
    node:addChild(titleLabe);

    local titleLabe = ccui.Text:create("名称", FONT_ART_TEXT, 26);
    titleLabe:setColor(cc.c3b(255,255,255));
    titleLabe:setPosition(cc.p(220, 30));
    titleLabe:setAnchorPoint(cc.p(0, 0.5))
    node:addChild(titleLabe);

    local titleLabe = ccui.Text:create("筹码", FONT_ART_TEXT, 26);
    titleLabe:setColor(cc.c3b(255,255,255));
    titleLabe:setPosition(cc.p(343, 30));
    titleLabe:setAnchorPoint(cc.p(0, 0.5))
    node:addChild(titleLabe);

    local titleLabe = ccui.Text:create("魅力", FONT_ART_TEXT, 26);
    titleLabe:setColor(cc.c3b(255,255,255));
    titleLabe:setPosition(cc.p(449, 30));
    titleLabe:setAnchorPoint(cc.p(0, 0.5))
    node:addChild(titleLabe);

    local titleLabe = ccui.Text:create("等级", FONT_ART_TEXT, 26);
    titleLabe:setColor(cc.c3b(255,255,255));
    titleLabe:setPosition(cc.p(565, 30));
    titleLabe:setAnchorPoint(cc.p(0, 0.5))
    node:addChild(titleLabe);
end

function ChatPersonListLayer:showListLayer()
   
    local node = ccui.Layout:create()
    node:setContentSize(cc.size(750, 295))
    node:align(display.BOTTOM_LEFT, 12, 7)
    self._bg:addChild(node)

    --listview
    local list = ccui.ListView:create()
    list:setDirection(ccui.ScrollViewDir.vertical)
    list:setBounceEnabled(true)
    list:setContentSize(cc.size(750, 295))
    list:setPosition(10, 5)
    node:addChild(list)

    local size = cc.size(750, 90)

    local plinfos = DataManager:getPlayerUserInMyTable()
    -- print("------plinfos---count:", #plinfos)
    --子节点
    for k, v in ipairs(plinfos) do
        local custom_item = ccui.Layout:create()
        custom_item:setContentSize(size)

        local ind = ccui.Text:create(tostring(k), FONT_ART_TEXT, 24);
        ind:setColor(cc.c3b(255,226, 112));
        ind:setPosition(cc.p(115, 45));
        ind:setAnchorPoint(cc.p(0, 0.5))
        custom_item:addChild(ind);

        local headView = require("commonView.HeadView").new(1);
        headView:setPosition(cc.p(50, 45))
        headView:setScale(0.65)
        if v.faceID and type(v.faceID) == "number" then
            headView:setNewHead(v.faceID, v.platformID, v.platformFace)
        end
        custom_item:addChild(headView);

        if v.userStatus == Define.US_LOOKON then
            local icon = ccui.ImageView:create("zhajinhua/lookonIcon.png");
            icon:setPosition(cc.p(85, 30));
            custom_item:addChild(icon);
        end

        local nickName = FormotGameNickName(v.nickName,5) --print("--v:getNickName()---", v:getNickName(), nickName)
        local ind = ccui.Text:create(nickName, FONT_ART_TEXT, 24);
        ind:setColor(cc.c3b(255,226, 112));
        ind:setPosition(cc.p(220, 45));
        ind:setAnchorPoint(cc.p(0.5, 0.5))
        custom_item:addChild(ind);

        --筹码
        local ind = ccui.Text:create(FormatNumToString(v.score), FONT_ART_TEXT, 24);
        ind:setColor(cc.c3b(255,226, 112));
        ind:setPosition(cc.p(350, 45));
        ind:setAnchorPoint(cc.p(0.5, 0.5))
        custom_item:addChild(ind);

        --魅力值
        local ind = ccui.Text:create(FormatNumToString(v.loveliness), FONT_ART_TEXT, 24);
        ind:setColor(cc.c3b(255,226, 112));
        ind:setPosition(cc.p(450, 45));
        ind:setAnchorPoint(cc.p(0.5, 0.5))
        custom_item:addChild(ind);

        --等级
        local guanxian = require("hall.GuanXianLayer").new({exp = v.medal, c3b=cc.c3b(255,226, 112)})
        guanxian:setPosition(cc.p(570, 45));
        custom_item:addChild(guanxian);

        local exit = ccui.Button:create("zhajinhua/propertyIcon.png");
        exit:setPosition(cc.p(660, 45));
        custom_item:addChild(exit);
        exit:setPressedActionEnabled(true);
        exit:addTouchEventListener(
            function(sender,eventType)
                if eventType == ccui.TouchEventType.ended then
                    local targetUserID = v.userId
                    local event = {targetUserID=targetUserID,sceneID=2}
                    self.parent:onClickCup(event)

                end
            end
        )

        list:pushBackCustomItem(custom_item)
    end

    --list:scrollToBottom(0.1, false)
    list:refreshView()
end

return ChatPersonListLayer