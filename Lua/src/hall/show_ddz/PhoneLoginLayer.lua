
local PhoneLoginLayer = class("PhoneLoginLayer", function()
    return display.newLayer()
end)

function PhoneLoginLayer:ctor()

    local displaySize = cc.size(display.width, display.height);
    self:setContentSize(displaySize);

    self:showLogin();

end


function PhoneLoginLayer:showLogin(accountLogin)

    self:removeAllChildren();

    local displaySize = cc.size(display.width, display.height);
    local winSize = cc.Director:getInstance():getWinSize();
    -- 蒙板
    local maskLayer = ccui.ImageView:create("black.png");
    maskLayer:setScale9Enabled(true);
    maskLayer:setContentSize(cc.size(winSize.width, winSize.height));
    maskLayer:setPosition(cc.p(displaySize.width / 2, displaySize.height / 2));
    maskLayer:setTouchEnabled(true);
    maskLayer:addTo(self);


    local bgSprite = ccui.ImageView:create("hall_frame_bg.png");
    bgSprite:setScale9Enabled(true);
    bgSprite:setContentSize(cc.size(612, 343));
    bgSprite:setPosition(cc.p(displaySize.width / 2 + 20, displaySize.height / 2));
    self:addChild(bgSprite);

    local panel = ccui.ImageView:create("hall_frame.png");
    panel:setScale9Enabled(true);
    panel:setContentSize(cc.size(574, 244));
    panel:setPosition(cc.p(306, 195));
    bgSprite:addChild(panel);

    --标题
    local titleSprite = cc.Sprite:create("hall_title_bg.png");
    titleSprite:setPosition(cc.p(306, 340));
    bgSprite:addChild(titleSprite);

    local titleTxtImg = ccui.ImageView:create("loginScene/hall_title_login.png")
    titleTxtImg:setPosition(cc.p(215,50))
    titleSprite:addChild(titleTxtImg)
    if accountLogin == true then
        titleTxtImg:loadTexture("loginScene/hall_title_account_login.png")
    end

    local accountLabel = ccui.Text:create("账号:", "fonts/HKBDTW12.TTF", 35);
    accountLabel:setColor(cc.c3b(250,255,106));
    accountLabel:setPosition(cc.p(100, 240));
    bgSprite:addChild(accountLabel);

    local editSprite = cc.Sprite:create("loginScene/login_edit_bg.png");
    editSprite:setPosition(cc.p(270, 240));
    bgSprite:addChild(editSprite);


    local accountTextEdit = ccui.EditBox:create(cc.size(200,40), "blank.png");
    accountTextEdit:setAnchorPoint(cc.p(0.5,0.5));
    accountTextEdit:setPosition(cc.p(113, 20));

    accountTextEdit:setFontSize(22);
    accountTextEdit:setPlaceHolder("请输入账号");
    accountTextEdit:setPlaceholderFontColor(cc.c3b(255,253,252));
    accountTextEdit:setPlaceholderFontSize(22);

    accountTextEdit:setText(cc.UserDefault:getInstance():getStringForKey("phoneNumber", ""))


    -- accountTextEdit:setInputMode(InputMode_PHONE_NUMBER);
    accountTextEdit:setMaxLength(13);

    editSprite:addChild(accountTextEdit);

    -- local accountTextEdit = ccui.TextField:create()
    -- accountTextEdit:setTouchEnabled(true)
    -- accountTextEdit:setFontSize(22)
    -- accountTextEdit:setPlaceHolder("input words here")
    -- accountTextEdit:setPosition(cc.p(113, 20))
    -- editSprite:addChild(accountTextEdit);
    -- editSprite:addEventListener(accountTextEdit) 


    local passwordLabel = ccui.Text:create("密码:", "fonts/HKBDTW12.TTF", 35);
    passwordLabel:setColor(cc.c3b(250,255,106));
    passwordLabel:setPosition(cc.p(100, 160));
    bgSprite:addChild(passwordLabel);

    local editSprite2 = cc.Sprite:create("loginScene/login_edit_bg.png");
    editSprite2:setPosition(cc.p(270, 160));
    bgSprite:addChild(editSprite2);


    local passwordTextEdit = ccui.EditBox:create(cc.size(200,35), "blank.png");
    passwordTextEdit:setAnchorPoint(cc.p(0.5,0.5));
    passwordTextEdit:setPosition(cc.p(113, 20));

    passwordTextEdit:setFontSize(22);
    passwordTextEdit:setPlaceHolder("请输入密码");
    passwordTextEdit:setPlaceholderFontColor(cc.c3b(255,253,252));
    passwordTextEdit:setPlaceholderFontSize(22);

    --passwordTextEdit:setInputMode();
    passwordTextEdit:setInputFlag(0);
    passwordTextEdit:setMaxLength(13);

    passwordTextEdit:setText(cc.UserDefault:getInstance():getStringForKey("phonepassword", ""))

    editSprite2:addChild(passwordTextEdit);


    local phoneLogin = ccui.Button:create("loginScene/hall_login_button.png");
    phoneLogin:setPosition(cc.p(485,240));
    bgSprite:addChild(phoneLogin);

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

    local registerPage = ccui.Button:create("loginScene/hall_phone_reg.png");
    registerPage:setPosition(cc.p(110,40));
    bgSprite:addChild(registerPage);
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

    if accountLogin == true then
        registerPage:setVisible(false);
        local regLabel = ccui.Text:create("如无账号，直接输入账\n号密码即可快速注册", "Helvetica-Bold", 22);--"fonts/JDQTJ.TTF"
        regLabel:setColor(cc.c3b(249,250,131));
        regLabel:enableOutline(cc.c4b(141,0,166,255*0.7),2);
        bgSprite:addChild(regLabel);
        regLabel:setPosition(cc.p(150, 40 ));
        -- accountTextEdit:setInputMode(InputMode_EMAIL_ADDRESS);

        regLabel:setVisible(false);
    end


    local forgetPage = ccui.Button:create("loginScene/hall_foget_button.png");
    forgetPage:setPosition(cc.p(490,40));
    bgSprite:addChild(forgetPage);

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

    local exit = ccui.Button:create("hall_close.png");
    exit:setPosition(cc.p(590,320));
    bgSprite:addChild(exit);
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

    -- accountTextEdit:setText(cc.UserDefault:getInstance():getStringForKey("phoneNumber",""));
    -- passwordTextEdit:setText(cc.UserDefault:getInstance():getStringForKey("phonepassword",""));


end

function PhoneLoginLayer:showRegister()

    self:removeAllChildren();

    local displaySize = cc.size(display.width, display.height);
    local winSize = cc.Director:getInstance():getWinSize();
    -- 蒙板
    local maskLayer = ccui.ImageView:create("black.png");
    maskLayer:setScale9Enabled(true);
    maskLayer:setContentSize(cc.size(winSize.width, winSize.height));
    maskLayer:setPosition(cc.p(displaySize.width / 2, displaySize.height / 2));
    maskLayer:setTouchEnabled(true);
    maskLayer:addTo(self);


    local bgSprite = ccui.ImageView:create("hall_frame_bg.png");
    bgSprite:setScale9Enabled(true);
    bgSprite:setContentSize(cc.size(612, 343));
    bgSprite:setPosition(cc.p(displaySize.width / 2 + 20, displaySize.height / 2));
    self:addChild(bgSprite);

    local panel = ccui.ImageView:create("hall_frame.png");
    panel:setScale9Enabled(true);
    panel:setContentSize(cc.size(574, 244));
    panel:setPosition(cc.p(306, 195));
    bgSprite:addChild(panel);

    --标题
    local titleSprite = cc.Sprite:create("hall_title_bg.png");
    titleSprite:setPosition(cc.p(306, 340));
    bgSprite:addChild(titleSprite);

    local titleTxtImg = ccui.ImageView:create("loginScene/hall_title_register.png")
    titleTxtImg:setPosition(cc.p(215,50))
    titleSprite:addChild(titleTxtImg)

    local editSprite = display.newScale9Sprite("loginScene/login_edit_bg.png", 220, 250, cc.size(262,42))
    bgSprite:addChild(editSprite);

    local phoneTextEdit = ccui.EditBox:create(cc.size(240,40), "blank.png");
    phoneTextEdit:setAnchorPoint(cc.p(0.5,0.5));
    phoneTextEdit:setPosition(cc.p(130, 20));

    phoneTextEdit:setFontSize(22);
    phoneTextEdit:setPlaceHolder("请输入手机号");
    phoneTextEdit:setPlaceholderFontColor(cc.c3b(255,253,252));
    phoneTextEdit:setPlaceholderFontSize(22);

    phoneTextEdit:setInputMode(InputMode_PHONE_NUMBER);
    phoneTextEdit:setMaxLength(13);

    editSprite:addChild(phoneTextEdit);


    local editSprite2 = display.newScale9Sprite("loginScene/login_edit_bg.png", 220, 185, cc.size(262,42))
    bgSprite:addChild(editSprite2);

    local codeTextEdit = ccui.EditBox:create(cc.size(240,40), "blank.png");
    codeTextEdit:setAnchorPoint(cc.p(0.5,0.5));
    codeTextEdit:setPosition(cc.p(130, 20));

    codeTextEdit:setFontSize(22);
    codeTextEdit:setPlaceHolder("请输入短信验证码");
    codeTextEdit:setPlaceholderFontColor(cc.c3b(255,253,252));
    codeTextEdit:setPlaceholderFontSize(22);

    codeTextEdit:setInputMode(InputMode_PHONE_NUMBER);
    codeTextEdit:setMaxLength(6);

    editSprite2:addChild(codeTextEdit);


    local editSprite3 = display.newScale9Sprite("loginScene/login_edit_bg.png", 220, 120, cc.size(262,42))
    bgSprite:addChild(editSprite3);

    local passwordTextEdit = ccui.EditBox:create(cc.size(240,40), "blank.png");
    passwordTextEdit:setAnchorPoint(cc.p(0.5,0.5));
    passwordTextEdit:setPosition(cc.p(130, 20));

    passwordTextEdit:setFontSize(22);
    passwordTextEdit:setPlaceHolder("请输入密码");
    passwordTextEdit:setPlaceholderFontColor(cc.c3b(255,253,252));
    passwordTextEdit:setPlaceholderFontSize(22);

    editSprite3:addChild(passwordTextEdit);


    local getcode = ccui.Button:create("loginScene/hall_getcode_button.png");
    getcode:setPosition(cc.p(475,250));
    bgSprite:addChild(getcode);

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


    local register = ccui.Button:create("loginScene/hall_reg_button.png");
    register:setPosition(cc.p(475,120));
    bgSprite:addChild(register);

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



    local loginPage = ccui.Button:create("loginScene/hall_login_backbutton.png");
    loginPage:setPosition(cc.p(530,40));
    bgSprite:addChild(loginPage);
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

    local displaySize = cc.size(display.width, display.height);
    local winSize = cc.Director:getInstance():getWinSize();
    -- 蒙板
    local maskLayer = ccui.ImageView:create("black.png");
    maskLayer:setScale9Enabled(true);
    maskLayer:setContentSize(cc.size(winSize.width, winSize.height));
    maskLayer:setPosition(cc.p(displaySize.width / 2, displaySize.height / 2));
    maskLayer:setTouchEnabled(true);
    maskLayer:addTo(self);


    local bgSprite = ccui.ImageView:create("hall_frame_bg.png");
    bgSprite:setScale9Enabled(true);
    bgSprite:setContentSize(cc.size(612, 343));
    bgSprite:setPosition(cc.p(displaySize.width / 2 + 20, displaySize.height / 2));
    self:addChild(bgSprite);

    local panel = ccui.ImageView:create("hall_frame.png");
    panel:setScale9Enabled(true);
    panel:setContentSize(cc.size(574, 244));
    panel:setPosition(cc.p(306, 195));
    bgSprite:addChild(panel);

    --标题
    local titleSprite = cc.Sprite:create("hall_title_bg.png");
    titleSprite:setPosition(cc.p(306, 340));
    bgSprite:addChild(titleSprite);

    local titleTxtImg = ccui.ImageView:create("loginScene/hall_title_forget.png")
    titleTxtImg:setPosition(cc.p(215,50))
    titleSprite:addChild(titleTxtImg)

    local editSprite = display.newScale9Sprite("loginScene/login_edit_bg.png", 220, 250, cc.size(262,42))
    bgSprite:addChild(editSprite);

    local phoneTextEdit = ccui.EditBox:create(cc.size(240,40), "blank.png");
    phoneTextEdit:setAnchorPoint(cc.p(0.5,0.5));
    phoneTextEdit:setPosition(cc.p(130, 20));

    phoneTextEdit:setFontSize(22);
    phoneTextEdit:setPlaceHolder("请输入绑定手机号");
    phoneTextEdit:setPlaceholderFontColor(cc.c3b(255,253,252));
    phoneTextEdit:setPlaceholderFontSize(22);

    phoneTextEdit:setInputMode(InputMode_PHONE_NUMBER);
    phoneTextEdit:setMaxLength(13);

    editSprite:addChild(phoneTextEdit);

    local editSprite2 = display.newScale9Sprite("loginScene/login_edit_bg.png", 220, 185, cc.size(262,42))
    bgSprite:addChild(editSprite2);

    local codeTextEdit = ccui.EditBox:create(cc.size(240,40), "blank.png");
    codeTextEdit:setAnchorPoint(cc.p(0.5,0.5));
    codeTextEdit:setPosition(cc.p(130, 20));

    codeTextEdit:setFontSize(22);
    codeTextEdit:setPlaceHolder("请输入短信验证码");
    codeTextEdit:setPlaceholderFontColor(cc.c3b(255,253,252));
    codeTextEdit:setPlaceholderFontSize(22);

    codeTextEdit:setInputMode(InputMode_PHONE_NUMBER);
    codeTextEdit:setMaxLength(6);

    editSprite2:addChild(codeTextEdit);


    local editSprite3 = display.newScale9Sprite("loginScene/login_edit_bg.png", 220, 120, cc.size(262,42))
    bgSprite:addChild(editSprite3);

    local passwordTextEdit = ccui.EditBox:create(cc.size(240,40), "blank.png");
    passwordTextEdit:setAnchorPoint(cc.p(0.5,0.5));
    passwordTextEdit:setPosition(cc.p(130, 20));

    passwordTextEdit:setFontSize(22);
    passwordTextEdit:setPlaceHolder("请输入新密码");
    passwordTextEdit:setPlaceholderFontColor(cc.c3b(255,253,252));
    passwordTextEdit:setPlaceholderFontSize(22);

    editSprite3:addChild(passwordTextEdit);

    local getcode = ccui.Button:create("loginScene/hall_getcode_button.png");
    getcode:setPosition(cc.p(475,250));
    bgSprite:addChild(getcode);

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


    local register = ccui.Button:create("loginScene/hall_confirm_button.png");
    register:setPosition(cc.p(475,120));
    bgSprite:addChild(register);

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

    local loginPage = ccui.Button:create("loginScene/hall_login_backbutton.png");
    loginPage:setPosition(cc.p(530,40));
    bgSprite:addChild(loginPage);
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