local MarriageSearch = class("MarriageSearch",function() return display.newLayer() end)
function MarriageSearch:ctor()
	self:createUI()
end
function MarriageSearch:createUI()
	local displaySize = cc.size(display.width, display.height);
    local winSize = cc.Director:getInstance():getWinSize();
    -- 蒙板
    local maskLayer = ccui.ImageView:create("black.png");
    maskLayer:setScale9Enabled(true);
    maskLayer:setContentSize(cc.size(winSize.width, winSize.height));
    maskLayer:setPosition(cc.p(displaySize.width / 2, displaySize.height / 2));
    maskLayer:setTouchEnabled(true)
    self:addChild(maskLayer)

    local bg = ccui.ImageView:create("view/frame3.png");
    bg:setScale9Enabled(true);
    bg:setContentSize(cc.size(540,235));
    bg:setPosition(573,322)
    self:addChild(bg)

    local kuangBg = ccui.ImageView:create("hall/marry/shijiankuang.png")
    kuangBg:setAnchorPoint(cc.p(0,0.5));
    kuangBg:setPosition(115, 151)
    kuangBg:setScale9Enabled(true);
    kuangBg:setContentSize(cc.size(340, 38))
    bg:addChild(kuangBg)

    local searchTextEdit = ccui.EditBox:create(cc.size(320,35), "blank.png");
    searchTextEdit:setAnchorPoint(cc.p(0,0.5));
    searchTextEdit:setPosition(cc.p(126, 151));

    searchTextEdit:setFontSize(16);
    searchTextEdit:setPlaceHolder("请输入你想要搜索的ID");
    searchTextEdit:setPlaceholderFontColor(cc.c3b(139,103,57));
    searchTextEdit:setPlaceholderFontSize(16);

    searchTextEdit:setInputMode(InputMode_PHONE_NUMBER);
    searchTextEdit:setMaxLength(13);

    bg:addChild(searchTextEdit);
    self.searchTextEdit = searchTextEdit

    local buttonTitle = "确定"

    local sure = ccui.Button:create("common/button_green.png")
    bg:addChild(sure)
    sure:setPosition(cc.p(272,56))
    sure:setScale9Enabled(true)
    sure:setContentSize(cc.size(184,67))
    sure:setTitleFontName(FONT_ART_BUTTON);
    sure:setTitleText(buttonTitle);
    sure:setTitleColor(cc.c3b(255,255,255));
    sure:setTitleFontSize(28);
    sure:getTitleRenderer():enableOutline(COLOR_BTN_BLUE,2)
    sure:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:searchHandler()
            end
        end
    )

    --关闭按钮
    local exit = ccui.Button:create("common/close.png");
    exit:setPosition(cc.p(516,217))
    bg:addChild(exit)
    exit:setPressedActionEnabled(true);
    exit:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:close()                
            end
        end
    )
end
function MarriageSearch:searchHandler()
	local gameId = tonumber(self.searchTextEdit:getText())
    
    UserService:queryHuntingMarriagesByGameId(gameId)
    self:close()
end
function MarriageSearch:close()
	self:removeFromParent()
end
return MarriageSearch