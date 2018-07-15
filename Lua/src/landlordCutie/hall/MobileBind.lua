local MobileBind = class("MobileBind",function() return display.newLayer() end)

function MobileBind:ctor()
	self:createUI()
end
function MobileBind:createUI()
	local displaySize = cc.size(display.width, display.height);
    local winSize = cc.Director:getInstance():getWinSize();
    -- 蒙板
    local maskLayer = ccui.ImageView:create("black.png");
    maskLayer:setScale9Enabled(true);
    maskLayer:setContentSize(cc.size(winSize.width, winSize.height));
    maskLayer:setPosition(cc.p(displaySize.width / 2, displaySize.height / 2));
    maskLayer:setTouchEnabled(true);
    maskLayer:addTo(self);

    local bgSprite = ccui.ImageView:create("common/pop_bg.png");
    -- bgSprite:setPosition(cc.p(displaySize.width / 2, displaySize.height / 2));
    bgSprite:setScale9Enabled(true);
    bgSprite:setContentSize(cc.size(674,433));
    bgSprite:setPosition(cc.p(displaySize.width/2, displaySize.height/2));
    self:addChild(bgSprite);

    local popTitle = ccui.ImageView:create("common/pop_title.png")
    popTitle:setPosition(139, 395)
    bgSprite:addChild(popTitle)

    local content = {"手","机","号","绑","定"};

    for i,v in ipairs(content) do
        local titleLabe = ccui.Text:create(v, FONT_ART_TEXT, 24);
        titleLabe:setColor(cc.c3b(255,233,110));
        titleLabe:enableOutline(cc.c4b(141,0,166,255*0.7),2);
        titleLabe:setPosition(cc.p(0 + i * 23, 70 ));
        popTitle:addChild(titleLabe);
    end
    --手机号
    local mobileNumber = ccui.Text:create("手机号：",FONT_ART_TEXT,24)
    mobileNumber:setColor(cc.c3b(252,255,255))
    mobileNumber:setPosition(135, 330)
    bgSprite:addChild(mobileNumber)
    local editSprite = ccui.ImageView:create("hall/login/edit_bg.png");
    editSprite:setAnchorPoint(cc.p(0,0.5))
    editSprite:setScale9Enabled(true);
    editSprite:setContentSize(cc.size(241, 55));
    editSprite:setPosition(cc.p(190, 333));
    bgSprite:addChild(editSprite);

    local phoneTextEdit = ccui.EditBox:create(cc.size(220,35), "blank.png");
    phoneTextEdit:setAnchorPoint(cc.p(0,0.5));
    phoneTextEdit:setPosition(cc.p(208, 334));

    phoneTextEdit:setFontSize(20);
    phoneTextEdit:setPlaceHolder("请输入绑定手机号");
    phoneTextEdit:setPlaceholderFontColor(cc.c3b(255,255,100));
    phoneTextEdit:setPlaceholderFontSize(20);

    phoneTextEdit:setInputMode(InputMode_PHONE_NUMBER);
    phoneTextEdit:setMaxLength(13);

    bgSprite:addChild(phoneTextEdit);
    self.phoneTextEdit = phoneTextEdit

    --	验证码
    local checkCode = ccui.Text:create("验证码：",FONT_ART_TEXT,24)
    checkCode:setColor(cc.c3b(252,255,255))
    checkCode:setPosition(135, 271)
    bgSprite:addChild(checkCode)
    local editSprite = ccui.ImageView:create("hall/login/edit_bg.png");
    editSprite:setAnchorPoint(cc.p(0,0.5))
    editSprite:setScale9Enabled(true);
    editSprite:setContentSize(cc.size(241, 55));
    editSprite:setPosition(cc.p(190, 273));
    bgSprite:addChild(editSprite);
    local codeTextEdit = ccui.EditBox:create(cc.size(220,35), "blank.png");
    codeTextEdit:setAnchorPoint(cc.p(0,0.5));
    codeTextEdit:setPosition(cc.p(208, 275));

    codeTextEdit:setFontSize(20);
    codeTextEdit:setPlaceHolder("请输入验证码");
    codeTextEdit:setPlaceholderFontColor(cc.c3b(255,255,100));
    codeTextEdit:setPlaceholderFontSize(20);

    codeTextEdit:setInputMode(InputMode_PHONE_NUMBER);
    codeTextEdit:setMaxLength(13);

    bgSprite:addChild(codeTextEdit);
    self.codeTextEdit = codeTextEdit

    --获取验证码
    local getcheckcode = ccui.Button:create("common/button_blue.png","common/button_blue.png")
    getcheckcode:setPosition(cc.p(531,333));
    bgSprite:addChild(getcheckcode);
    getcheckcode:setPressedActionEnabled(true);
    getcheckcode:setTitleFontName(FONT_ART_BUTTON)
    getcheckcode:setTitleText("获取验证码");
    getcheckcode:setTitleColor(cc.c4b(255,255,255,255));
    getcheckcode:setTitleFontSize(28);
    getcheckcode:getTitleRenderer():enableOutline(COLOR_BTN_BLUE,2)
    getcheckcode:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then

                self:getcheckcodeHandler();

            end
        end
    )
    --提交
    submit = ccui.Button:create("common/button_green.png");
    submit:setPosition(cc.p(336,66));
    bgSprite:addChild(submit);
    submit:setPressedActionEnabled(true);
    submit:setTitleFontName(FONT_ART_BUTTON)
    submit:setTitleText("提交");
    submit:setTitleColor(cc.c4b(255,255,255,255));
    submit:setTitleFontSize(28);
    submit:getTitleRenderer():enableOutline(COLOR_BTN_GREEN,2)
    submit:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then

                self:submitHandler();

            end
        end
    )
    --温馨提示
    local tishi = ccui.Text:create("温馨提示:","",18)
    tishi:setColor(cc.c3b(255,245,138))
    tishi:setPosition(119, 208)
    bgSprite:addChild(tishi)

    local info1 = ccui.Text:create("1、手机号仅作为登入保护，不会向您收取任何费用。","",16)
    info1:setColor(cc.c3b(255,245,138))
    info1:setAnchorPoint(cc.p(0,0.5))
    info1:setPosition(82, 173)
    bgSprite:addChild(info1)

    local info2 = ccui.Text:create("2、绑定手机号可以作为账号，直接登入。","",16)
    info2:setColor(cc.c3b(255,245,138))
    info2:setAnchorPoint(cc.p(0,0.5))
    info2:setPosition(82, 149)
    bgSprite:addChild(info2)

    local info3 = ccui.Text:create("3、我们承诺保证您的隐私权益，不会泄露您的手机号码。","",16)
    info3:setColor(cc.c3b(255,245,138))
    info3:setAnchorPoint(cc.p(0,0.5))
    info3:setPosition(82, 129)
    bgSprite:addChild(info3)


    local exit = ccui.Button:create("common/close.png");
    exit:setPosition(cc.p(641,404));
    bgSprite:addChild(exit);
    exit:setPressedActionEnabled(true);
    exit:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:removeFromParent()
            end
        end
    )
end
function MobileBind:getcheckcodeHandler()
    cc.Director:getInstance():getOpenGLView():setIMEKeyboardState(false);

    local phoneStr = self.phoneTextEdit:getText();

    if isEmptyString(phoneStr) then
        Hall.showTips("手机号不能为空！");
        return
    end

    PlatformPhoneRegCheckCode(phoneStr);
end
function MobileBind:submitHandler()
    cc.Director:getInstance():getOpenGLView():setIMEKeyboardState(false);

    local phoneStr = self.phoneTextEdit:getText();
    local codeStr = self.codeTextEdit:getText();

    if isEmptyString(phoneStr) then
        Hall.showTips("手机号不能为空！");
        return
    end
    if isEmptyString(codeStr) then
        Hall.showTips("验证码不能为空！");
        return
    end

    PlatformBindPhone(phoneStr,codeStr)
    -- PlatformLoginPhone(phoneStr, codeStr, pwdStr)
end
return MobileBind