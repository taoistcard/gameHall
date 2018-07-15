local PhoneLoginLayer = class("PhoneLoginLayer", function()
    return display.newLayer()
end)
local COLOR_BTN_GREEN = cc.c4b(73,110,4,255*0.7)
local COLOR_BTN_BLUE = cc.c4b(24,119,185,255*0.7)
local COLOR_BTN_YELLOW = cc.c4b(165,82,0,255*0.7)
function PhoneLoginLayer:ctor()

    local displaySize = cc.size(DESIGN_WIDTH,DESIGN_HEIGHT);
    self:setContentSize(displaySize);
    self:setNodeEventEnabled(true)

    self:showLogin();

    -- HallCenter:addEventListener(HallCenterEvent.EVENT_MODIYY_PWD_RETURN, handler(self, self.onModifyUserPwdReturn))
end

function PhoneLoginLayer:onCleanup()
    -- HallCenter:removeEventListenersByEvent(HallCenterEvent.EVENT_MODIYY_PWD_RETURN);
end

function PhoneLoginLayer:onModifyUserPwdReturn(event)
    print("PhoneLoginLayer:onModifyUserPwdReturn : ", event.code, event.cmd)
    if event.code == 1 then
        self:showLogin()
    end
end

function PhoneLoginLayer:showLogin(accountLogin)

    self:removeAllChildren();

    local displaySize = cc.size(DESIGN_WIDTH,DESIGN_HEIGHT);
    local winSize = cc.Director:getInstance():getWinSize();
    -- 蒙板
    local maskLayer = ccui.ImageView:create("black.png");
    maskLayer:setScale9Enabled(true);
    maskLayer:setContentSize(cc.size(winSize.width, winSize.height));
    maskLayer:setPosition(cc.p(displaySize.width / 2, displaySize.height / 2));
    maskLayer:setTouchEnabled(true);
    maskLayer:addTo(self);


    local bgSprite = ccui.ImageView:create("common/pop_bg.png");
    bgSprite:setScale9Enabled(true);
    bgSprite:setContentSize(cc.size(674, 433));
    bgSprite:setPosition(cc.p(displaySize.width / 2 + 20, displaySize.height / 2));
    self:addChild(bgSprite);


    local titleSprite = ccui.ImageView:create("common/pop_title.png");
    titleSprite:setScale9Enabled(true);
    titleSprite:setContentSize(cc.size(200, 52));
    titleSprite:setPosition(cc.p(337, 400));
    bgSprite:addChild(titleSprite);

    --I was drunk
    local content = {"手","机","号","登","录"};
    local stpos = 30
    local placeholder = "请输入手机号"
    if accountLogin == true then
        content = {"账","号","登","录"};
        stpos = 45
        placeholder = "请输入账号"
    end

    for i,v in ipairs(content) do

        local titleLabe = ccui.Text:create(v, FONT_ART_TEXT, 24);
        titleLabe:setColor(cc.c3b(255,233,110));
        titleLabe:enableOutline(cc.c4b(141,0,166,255*0.7),2);
        titleLabe:setPosition(cc.p(stpos + i * 23, 30 ));
        titleSprite:addChild(titleLabe);

    end

    local panel = ccui.ImageView:create("common/panel.png");
    panel:setScale9Enabled(true);
    panel:setContentSize(cc.size(550, 205));
    panel:setPosition(cc.p(displaySize.width / 2 + 20, displaySize.height / 2 + 30));
    self:addChild(panel);



    local accountLabel = ccui.Text:create("账号", FONT_ART_TEXT, 30);
    accountLabel:setColor(cc.c3b(255,255,255));
    accountLabel:setPosition(cc.p(380, 410));
    self:addChild(accountLabel);

    local editSprite = cc.Sprite:create("hall/login/edit_bg.png");
    editSprite:setPosition(cc.p(540, 410));
    self:addChild(editSprite);


    local accountTextEdit = ccui.EditBox:create(cc.size(200,35), "blank.png");
    accountTextEdit:setAnchorPoint(cc.p(0.5,0.5));
    accountTextEdit:setPosition(cc.p(550, 410));

    accountTextEdit:setFontSize(20);
    accountTextEdit:setPlaceHolder(placeholder);
    accountTextEdit:setPlaceholderFontColor(cc.c3b(255,255,100));
    accountTextEdit:setPlaceholderFontSize(20);

    accountTextEdit:setInputMode(InputMode_PHONE_NUMBER);
    accountTextEdit:setMaxLength(20);

    self:addChild(accountTextEdit);


    local passwordLabel = ccui.Text:create("密码", FONT_ART_TEXT, 30);
    passwordLabel:setColor(cc.c3b(255,255,255));
    passwordLabel:setPosition(cc.p(380, 335));
    self:addChild(passwordLabel);

    local editSprite2 = cc.Sprite:create("hall/login/edit_bg.png");
    editSprite2:setPosition(cc.p(540, 335));
    self:addChild(editSprite2);


    local passwordTextEdit = ccui.EditBox:create(cc.size(200,35), "blank.png");
    passwordTextEdit:setAnchorPoint(cc.p(0.5,0.5));
    passwordTextEdit:setPosition(cc.p(550, 335));

    passwordTextEdit:setFontSize(20);
    passwordTextEdit:setPlaceHolder("请输入密码");
    passwordTextEdit:setPlaceholderFontColor(cc.c3b(255,255,100));
    passwordTextEdit:setPlaceholderFontSize(20);

    --passwordTextEdit:setInputMode();
    passwordTextEdit:setInputFlag(0);
    passwordTextEdit:setMaxLength(13);

    self:addChild(passwordTextEdit);


    local phoneLogin = ccui.Button:create("common/common_button3.png");
    phoneLogin:setPosition(cc.p(765,360));
    phoneLogin:setTitleFontName(FONT_ART_BUTTON);
    phoneLogin:setTitleText("登录");
    phoneLogin:setTitleColor(cc.c3b(255,255,255));
    phoneLogin:setTitleFontSize(30);
    self:addChild(phoneLogin);

    phoneLogin:getTitleRenderer():enableOutline(COLOR_BTN_GREEN,2);--COLOR_BTN_GREEN = cc.c4b(73,110,4,255*0.7)
    phoneLogin:setPressedActionEnabled(true);
    phoneLogin:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then

                Click();

                cc.Director:getInstance():getOpenGLView():setIMEKeyboardState(false);

                local phoneStr = accountTextEdit:getText();
                local pwdStr = passwordTextEdit:getText();

                if isEmptyString(phoneStr) then
                    Hall.showTips("手机号不能为空！");
                    return;
                end
                if isEmptyString(pwdStr) then
                    Hall.showTips("密码不能为空！");
                    return;
                end

                Hall.phoneNumber = phoneStr;
                Hall.phonepassword = pwdStr;

                PlatformLoginAcount(phoneStr, pwdStr);

            end
        end
    )

    local registerPage = ccui.Button:create("hall/login/goregister_button.png");
    registerPage:setPosition(cc.p(385,200));
    self:addChild(registerPage);
    registerPage:setPressedActionEnabled(true);
    registerPage:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then

                self:removeAllChildren();
                self:showRegister();

                Click();

            end
        end
    )

    local regLabel = ccui.Text:create("手机号注册", "Helvetica-Bold", 24);--"fonts/JDQTJ.TTF"

    regLabel:setColor(cc.c3b(249,250,131));
    regLabel:enableOutline(cc.c4b(141,0,166,255*0.7),2);
    regLabel:setPosition(cc.p(385, 150 ));
    self:addChild(regLabel);

    if accountLogin == true then
        registerPage:setVisible(false);
        regLabel:setPosition(cc.p(470, 180 ));
        regLabel:setString("如无账号，直接输入账\n号密码即可快速注册");
        accountTextEdit:setInputMode(InputMode_EMAIL_ADDRESS);
    end

    if OnlineConfig_review == nil or OnlineConfig_review == "on" then
    else
        local forgetPage = ccui.Button:create("common/common_button2.png");
        forgetPage:setPosition(cc.p(760,190));
        forgetPage:setTitleFontName(FONT_ART_BUTTON);
        forgetPage:setTitleText("忘记密码");
        forgetPage:setTitleColor(cc.c3b(255,255,255));
        forgetPage:setTitleFontSize(30);
        self:addChild(forgetPage);

        forgetPage:getTitleRenderer():enableOutline(COLOR_BTN_BLUE,2);
        forgetPage:setPressedActionEnabled(true);
        forgetPage:addTouchEventListener(
            function(sender,eventType)
                if eventType == ccui.TouchEventType.ended then

                    self:removeAllChildren();
                    self:showForget();

                    Click();

                end
            end
        )
    end
    local exit = ccui.Button:create("common/close.png");
    exit:setPosition(cc.p(908,518));
    self:addChild(exit);
    exit:setPressedActionEnabled(true);
    exit:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then

                --self:removeFromParent();
                self:hide();

                Click();

                Hall.phoneNumber = nil;
                Hall.phonepassword = nil;

            end
        end
    )

    accountTextEdit:setText(cc.UserDefault:getInstance():getStringForKey("phoneNumber",""));
    passwordTextEdit:setText(cc.UserDefault:getInstance():getStringForKey("phonepassword",""));


end

function PhoneLoginLayer:showRegister()

    self:removeAllChildren();

    local displaySize = cc.size(DESIGN_WIDTH,DESIGN_HEIGHT);
    local winSize = cc.Director:getInstance():getWinSize();
    -- 蒙板
    local maskLayer = ccui.ImageView:create("black.png");
    maskLayer:setScale9Enabled(true);
    maskLayer:setContentSize(cc.size(winSize.width, winSize.height));
    maskLayer:setPosition(cc.p(displaySize.width / 2, displaySize.height / 2));
    maskLayer:setTouchEnabled(true);
    maskLayer:addTo(self);


    local bgSprite = ccui.ImageView:create("common/pop_bg.png");
    bgSprite:setScale9Enabled(true);
    bgSprite:setContentSize(cc.size(674, 433));
    bgSprite:setPosition(cc.p(displaySize.width / 2 + 20, displaySize.height / 2));
    self:addChild(bgSprite);


    local titleSprite = ccui.ImageView:create("common/pop_title.png");
    titleSprite:setScale9Enabled(true);
    titleSprite:setContentSize(cc.size(200, 52));
    titleSprite:setPosition(cc.p(337, 398));
    bgSprite:addChild(titleSprite);

    --I was drunk
    local content = {"手","机","号","注","册"};
    for i,v in ipairs(content) do

        local titleLabe = ccui.Text:create(v, FONT_ART_TEXT, 24);
        titleLabe:setColor(cc.c3b(255,233,110));
        titleLabe:enableOutline(cc.c4b(141,0,166,255*0.7),2);
        titleLabe:setPosition(cc.p(30 + i * 23, 30 ));
        titleSprite:addChild(titleLabe);

    end

    local panel = ccui.ImageView:create("common/panel.png");
    panel:setScale9Enabled(true);
    panel:setContentSize(cc.size(550, 230));
    panel:setPosition(cc.p(displaySize.width / 2 + 20, displaySize.height / 2 + 20));
    self:addChild(panel);


    local regLabel = ccui.Text:create("请依次填写上面注册信息", "Helvetica-Bold", 24);--"fonts/JDQTJ.TTF"
    regLabel:setColor(cc.c3b(249,250,131));
    regLabel:enableOutline(cc.c4b(141,0,166,255*0.7),2);
    regLabel:setAnchorPoint(cc.p(0, 0.5))
    regLabel:setPosition(cc.p(50, 50 ));
    bgSprite:addChild(regLabel);


    local editSprite = display.newScale9Sprite("hall/login/edit_bg.png", 380, 410, cc.size(262,55))
    editSprite:setPosition(cc.p(500, 415));
    self:addChild(editSprite);

    local phoneTextEdit = ccui.EditBox:create(cc.size(240,35), "blank.png");
    phoneTextEdit:setAnchorPoint(cc.p(0.5,0.5));
    phoneTextEdit:setPosition(cc.p(525, 413));

    phoneTextEdit:setFontSize(20);
    phoneTextEdit:setPlaceHolder("请输入手机号");
    phoneTextEdit:setPlaceholderFontColor(cc.c3b(255,255,100));
    phoneTextEdit:setPlaceholderFontSize(20);

    phoneTextEdit:setInputMode(InputMode_PHONE_NUMBER);
    phoneTextEdit:setMaxLength(13);

    self:addChild(phoneTextEdit);


    local editSprite2 = display.newScale9Sprite("hall/login/edit_bg.png", 380, 410, cc.size(262,55))
    editSprite2:setPosition(cc.p(500, 350));
    self:addChild(editSprite2);

    local codeTextEdit = ccui.EditBox:create(cc.size(240,35), "blank.png");
    codeTextEdit:setAnchorPoint(cc.p(0.5,0.5));
    codeTextEdit:setPosition(cc.p(525, 348));

    codeTextEdit:setFontSize(20);
    codeTextEdit:setPlaceHolder("请输入短信验证码");
    codeTextEdit:setPlaceholderFontColor(cc.c3b(255,255,100));
    codeTextEdit:setPlaceholderFontSize(20);

    codeTextEdit:setInputMode(InputMode_PHONE_NUMBER);
    codeTextEdit:setMaxLength(6);

    self:addChild(codeTextEdit);


    local editSprite3 = display.newScale9Sprite("hall/login/edit_bg.png", 380, 410, cc.size(262,55))
    editSprite3:setPosition(cc.p(500, 270));
    self:addChild(editSprite3);

    local passwordTextEdit = ccui.EditBox:create(cc.size(240,35), "blank.png");
    passwordTextEdit:setAnchorPoint(cc.p(0.5,0.5));
    passwordTextEdit:setPosition(cc.p(525, 268));

    passwordTextEdit:setFontSize(20);
    passwordTextEdit:setPlaceHolder("请输入密码");
    passwordTextEdit:setPlaceholderFontColor(cc.c3b(255,255,100));
    passwordTextEdit:setPlaceholderFontSize(20);

    self:addChild(passwordTextEdit);


    local getcode = ccui.Button:create("common/common_button2.png");
    getcode:setPosition(cc.p(760,380));
    getcode:setTitleFontName(FONT_ART_BUTTON);
    getcode:setTitleText("获取验证码");
    getcode:setTitleColor(cc.c3b(255,255,255));
    getcode:setTitleFontSize(26);
    self:addChild(getcode);

    getcode:getTitleRenderer():enableOutline(COLOR_BTN_BLUE,2);
    getcode:setPressedActionEnabled(true);
    getcode:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then

                Click();

                cc.Director:getInstance():getOpenGLView():setIMEKeyboardState(false);

                local phoneStr = phoneTextEdit:getText();

                if isEmptyString(phoneStr) then
                    Hall.showTips("手机号不能为空！");
                    return
                end

                PlatformPhoneRegCheckCode(phoneStr);

            end
        end
    )


    local register = ccui.Button:create("common/common_button3.png");
    register:setPosition(cc.p(760,270));
    register:setTitleFontName(FONT_ART_BUTTON);
    register:setTitleText("注册");
    register:setTitleColor(cc.c3b(255,255,255));
    register:setTitleFontSize(30);
    self:addChild(register);

    register:getTitleRenderer():enableOutline(COLOR_BTN_GREEN,2);
    register:setPressedActionEnabled(true);
    register:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then

                Click();

                cc.Director:getInstance():getOpenGLView():setIMEKeyboardState(false);

                local phoneStr = phoneTextEdit:getText();
                local codeStr = codeTextEdit:getText();
                local pwdStr = passwordTextEdit:getText();

                if isEmptyString(phoneStr) then
                    Hall.showTips("手机号不能为空！");
                    return
                end
                if isEmptyString(codeStr) then
                    Hall.showTips("验证码不能为空！");
                    return
                end
                if isEmptyString(pwdStr) then
                    Hall.showTips("密码不能为空！");
                    return
                end

                PlatformLoginPhone(phoneStr, codeStr, pwdStr)

            end
        end
    )



    local loginPage = ccui.Button:create("common/back.png");
    loginPage:setPosition(cc.p(845,175));
    self:addChild(loginPage);
    loginPage:setPressedActionEnabled(true);
    loginPage:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then

                self:removeAllChildren();
                self:showLogin();

                Click();

            end
        end
    )


end



function PhoneLoginLayer:showForget()

    self:removeAllChildren();


    local displaySize = cc.size(DESIGN_WIDTH,DESIGN_HEIGHT);
    local winSize = cc.Director:getInstance():getWinSize();
    -- 蒙板
    local maskLayer = ccui.ImageView:create("black.png");
    maskLayer:setScale9Enabled(true);
    maskLayer:setContentSize(cc.size(winSize.width, winSize.height));
    maskLayer:setPosition(cc.p(displaySize.width / 2, displaySize.height / 2));
    maskLayer:setTouchEnabled(true);
    maskLayer:addTo(self);


    local bgSprite = ccui.ImageView:create("common/pop_bg.png");
    bgSprite:setScale9Enabled(true);
    bgSprite:setContentSize(cc.size(674, 433));
    bgSprite:setPosition(cc.p(displaySize.width / 2 + 20, displaySize.height / 2));
    self:addChild(bgSprite);


    local titleSprite = ccui.ImageView:create("common/pop_title.png");
    titleSprite:setScale9Enabled(true);
    titleSprite:setContentSize(cc.size(200, 52));
    titleSprite:setPosition(cc.p(337, 398));
    bgSprite:addChild(titleSprite);

    --I was drunk
    local content = {"忘","记","密","码"};
    for i,v in ipairs(content) do

        local titleLabe = ccui.Text:create(v, FONT_ART_TEXT, 24);
        titleLabe:setColor(cc.c3b(255,233,110));
        titleLabe:enableOutline(cc.c4b(141,0,166,255*0.7),2);
        titleLabe:setPosition(cc.p(45 + i * 23, 30 ));
        titleSprite:addChild(titleLabe);

    end

    local panel = ccui.ImageView:create("common/panel.png");
    panel:setScale9Enabled(true);
    panel:setContentSize(cc.size(550, 230));
    panel:setPosition(cc.p(displaySize.width / 2 + 20, displaySize.height / 2 + 20));
    self:addChild(panel);


    local regLabel = ccui.Text:create("手机号找回密码", "Helvetica-Bold", 24);
    regLabel:setColor(cc.c3b(249,250,131));
    regLabel:enableOutline(cc.c4b(141,0,166,255*0.7),2);
    regLabel:setAnchorPoint(cc.p(0,0.5))
    regLabel:setPosition(cc.p(50, 50 ));
    bgSprite:addChild(regLabel);


    local editSprite = display.newScale9Sprite("hall/login/edit_bg.png", 380, 410, cc.size(262,55))
    editSprite:setPosition(cc.p(500, 415));
    self:addChild(editSprite);

    local phoneTextEdit = ccui.EditBox:create(cc.size(240,35), "blank.png");
    phoneTextEdit:setAnchorPoint(cc.p(0.5,0.5));
    phoneTextEdit:setPosition(cc.p(525, 413));

    phoneTextEdit:setFontSize(20);
    phoneTextEdit:setPlaceHolder("请输入绑定手机号");
    phoneTextEdit:setPlaceholderFontColor(cc.c3b(255,255,100));
    phoneTextEdit:setPlaceholderFontSize(20);

    phoneTextEdit:setInputMode(InputMode_PHONE_NUMBER);
    phoneTextEdit:setMaxLength(13);

    self:addChild(phoneTextEdit);


    local editSprite2 = display.newScale9Sprite("hall/login/edit_bg.png", 380, 410, cc.size(262,55))
    editSprite2:setPosition(cc.p(500, 350));
    self:addChild(editSprite2);

    local codeTextEdit = ccui.EditBox:create(cc.size(240,35), "blank.png");
    codeTextEdit:setAnchorPoint(cc.p(0.5,0.5));
    codeTextEdit:setPosition(cc.p(525, 348));

    codeTextEdit:setFontSize(20);
    codeTextEdit:setPlaceHolder("请输入短信验证码");
    codeTextEdit:setPlaceholderFontColor(cc.c3b(255,255,100));
    codeTextEdit:setPlaceholderFontSize(20);

    codeTextEdit:setInputMode(InputMode_PHONE_NUMBER);
    codeTextEdit:setMaxLength(6);

    self:addChild(codeTextEdit);


    local editSprite3 = display.newScale9Sprite("hall/login/edit_bg.png", 380, 410, cc.size(262,55))
    editSprite3:setPosition(cc.p(500, 270));
    self:addChild(editSprite3);

    local passwordTextEdit = ccui.EditBox:create(cc.size(240,35), "blank.png");
    passwordTextEdit:setAnchorPoint(cc.p(0.5,0.5));
    passwordTextEdit:setPosition(cc.p(525, 268));

    passwordTextEdit:setFontSize(20);
    passwordTextEdit:setPlaceHolder("请输入新密码");
    passwordTextEdit:setPlaceholderFontColor(cc.c3b(255,255,100));
    passwordTextEdit:setPlaceholderFontSize(20);

    self:addChild(passwordTextEdit);


    local getcode = ccui.Button:create("common/common_button2.png");
    getcode:setPosition(cc.p(760,380));
    getcode:setTitleFontName(FONT_ART_BUTTON);
    getcode:setTitleText("获取验证码");
    getcode:setTitleColor(cc.c3b(255,255,255));
    getcode:setTitleFontSize(26);
    self:addChild(getcode);

    getcode:getTitleRenderer():enableOutline(COLOR_BTN_BLUE,2);
    getcode:setPressedActionEnabled(true);
    getcode:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then

                Click();

                cc.Director:getInstance():getOpenGLView():setIMEKeyboardState(false);

                local phoneStr = phoneTextEdit:getText();

                if isEmptyString(phoneStr) then
                    Hall.showTips("手机号不能为空！");
                    return
                end

                PlatformFindPasswordSmsAuth(phoneStr);

            end
        end
    )


    local register = ccui.Button:create("common/common_button3.png");
    register:setPosition(cc.p(760,270));
    register:setTitleFontName(FONT_ART_BUTTON);
    register:setTitleText("确认");
    register:setTitleColor(cc.c3b(255,255,255));
    register:setTitleFontSize(30);
    self:addChild(register);

    register:getTitleRenderer():enableOutline(COLOR_BTN_GREEN,2);
    register:setPressedActionEnabled(true);
    register:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then

                Click();

                cc.Director:getInstance():getOpenGLView():setIMEKeyboardState(false);

                local phoneStr = phoneTextEdit:getText();
                local codeStr = codeTextEdit:getText();
                local pwdStr = passwordTextEdit:getText();

                if isEmptyString(phoneStr) then
                    Hall.showTips("手机号不能为空！");
                    return
                end
                if isEmptyString(codeStr) then
                    Hall.showTips("验证码不能为空！");
                    return
                end
                if isEmptyString(pwdStr) then
                    Hall.showTips("密码不能为空！");
                    return
                end

                PlatformFindPasswordSms(phoneStr, codeStr, pwdStr,
                    function()
                        
                    end
                )

            end
        end
    )



    local loginPage = ccui.Button:create("common/back.png");
    loginPage:setPosition(cc.p(845,175));
    self:addChild(loginPage);
    loginPage:setPressedActionEnabled(true);
    loginPage:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then

                self:removeAllChildren();
                self:showLogin();

                Click();

            end
        end
    )

end

return PhoneLoginLayer