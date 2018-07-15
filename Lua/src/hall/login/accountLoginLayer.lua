local accountLoginLayer = class("accountLoginLayer", require("show.popView_Hall.baseWindow"))

function accountLoginLayer:ctor(param)
    self.super.ctor(self, 4)
    self:setNodeEventEnabled(true)
    self:createUI()
end

function accountLoginLayer:onEnter()
end

function accountLoginLayer:onExit()
end

function accountLoginLayer:createUI()

    local size = self:getContentSize();
    local title = display.newSprite("account/account_login_title.png", size.width/2, size.height/2+200);
    title:setScale(1.12)
    self:addChild(title);

    local account_word = display.newSprite("account/account_acc_word.png", size.width/2-190, size.height/2+90);
    self:addChild(account_word);

    local pwd_word = display.newSprite("account/account_pwd_word.png", size.width/2-190, size.height/2+10);
    self:addChild(pwd_word);

    local account_word_bg = display.newSprite("account/account_input_bg.png", size.width/2+40, size.height/2+90);
    self:addChild(account_word_bg);

    local pwd_word_bg = display.newSprite("account/account_input_bg.png", size.width/2+40, size.height/2+10);
    self:addChild(pwd_word_bg);

    local accountTextEdit = ccui.EditBox:create(cc.size(260,40), "blank.png");
    accountTextEdit:setAnchorPoint(cc.p(0.5,0.5));
    accountTextEdit:setPosition(cc.p(account_word_bg:getContentSize().width/2-20, account_word_bg:getContentSize().height/2));
    accountTextEdit:setFontSize(26);
    accountTextEdit:setPlaceHolder("请输入您的手机号");
    accountTextEdit:setPlaceholderFontColor(cc.c3b(0xff,0xd8,0x12));
    accountTextEdit:setPlaceholderFontSize(26);
    accountTextEdit:setText(cc.UserDefault:getInstance():getStringForKey("phoneNumber", ""))
    -- accountTextEdit:setInputMode(InputMode_PHONE_NUMBER);
    accountTextEdit:setMaxLength(13);
    account_word_bg:addChild(accountTextEdit);


    local pwdTextEdit = ccui.EditBox:create(cc.size(300,40), "blank.png");
    pwdTextEdit:setAnchorPoint(cc.p(0.5,0.5));
    pwdTextEdit:setPosition(cc.p(pwd_word_bg:getContentSize().width/2, pwd_word_bg:getContentSize().height/2));
    pwdTextEdit:setFontSize(26);
    pwdTextEdit:setPlaceHolder("请输入6～18个字符");
    pwdTextEdit:setPlaceholderFontColor(cc.c3b(0xff,0xd8,0x12));
    pwdTextEdit:setPlaceholderFontSize(26);
    pwdTextEdit:setInputFlag(0)
    pwdTextEdit:setText(cc.UserDefault:getInstance():getStringForKey("phonepassword", ""))
    -- pwdTextEdit:setInputMode(InputMode_PHONE_NUMBER);
    pwdTextEdit:setMaxLength(18);
    pwd_word_bg:addChild(pwdTextEdit);


    local btn = ccui.Button:create("account/account_login.png");
    btn:setPosition(cc.p(size.width/2, size.height/2-130));
    btn:onClick(
        function()
            local phoneStr = accountTextEdit:getText();
            local pwdStr = pwdTextEdit:getText();

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
    );
    self:addChild(btn);

end

return accountLoginLayer