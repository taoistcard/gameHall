
local BindPhoneLayer = class("BindPhoneLayer", require("show.popView_Hall.baseWindow") );

function BindPhoneLayer:ctor()
    self.super.ctor(self, 5);
	self.index = 1
	self:createUI()
end

function BindPhoneLayer:createUI()

    local size = cc.Director:getInstance():getWinSize();

    local title = display.newSprite("hallUserCenter/bind_title.png", size.width/2, size.height/2+210);
    title:setScale(1.2)
    self:addChild(title);

    local vipTxt = ccui.Text:create("温馨提示：","",18)
    vipTxt:setPosition(size.width/2-190, size.height/2-22)
    vipTxt:setAnchorPoint(cc.p(0.5,1))
    vipTxt:setColor(cc.c3b(255,255,255))
    vipTxt:enableOutline(cc.c4b(0,48,98,255),2)
    self:addChild(vipTxt)

    local vipTxt = ccui.Text:create("1、手机号仅作为登入保护，不会向您收取任何费用。\n2、绑定手机号可以作为账号，直接登入。\n3、我们承诺保证您的隐私权益，不会泄漏手机号码。","",18)
    vipTxt:setPosition(size.width/2, size.height/2-46)
    vipTxt:setAnchorPoint(cc.p(0.5,1))
    vipTxt:setColor(cc.c3b(255,255,255))
    vipTxt:enableOutline(cc.c4b(0,48,98,255),2)
    self:addChild(vipTxt)

    local account_word = display.newSprite("hallUserCenter/bind_phone_word.png", size.width/2-190, size.height/2+90);
    self:addChild(account_word);

    local pwd_word = display.newSprite("hallUserCenter/bind_code_word.png", size.width/2-190, size.height/2+20);
    self:addChild(pwd_word);

    local account_word_bg = display.newSprite("hallUserCenter/bind_input_bg.png", size.width/2-20, size.height/2+90);
    self:addChild(account_word_bg);

    local pwd_word_bg = display.newSprite("hallUserCenter/bind_input_bg.png", size.width/2-20, size.height/2+20);
    self:addChild(pwd_word_bg);

    local accountTextEdit = ccui.EditBox:create(cc.size(260,40), "blank.png");
    accountTextEdit:setAnchorPoint(cc.p(0.5,0.5));
    accountTextEdit:setPosition(cc.p(account_word_bg:getContentSize().width/2+30, account_word_bg:getContentSize().height/2));
    accountTextEdit:setFontSize(10);
    accountTextEdit:setPlaceHolder("输入绑定手机号");
    accountTextEdit:setPlaceholderFontColor(cc.c3b(0xff,0xd8,0x12));
    accountTextEdit:setPlaceholderFontSize(10);
    -- accountTextEdit:setInputMode(InputMode_PHONE_NUMBER);
    accountTextEdit:setMaxLength(13);
    account_word_bg:addChild(accountTextEdit);


    local pwdTextEdit = ccui.EditBox:create(cc.size(300,40), "blank.png");
    pwdTextEdit:setAnchorPoint(cc.p(0.5,0.5));
    pwdTextEdit:setPosition(cc.p(pwd_word_bg:getContentSize().width/2+50, pwd_word_bg:getContentSize().height/2));
    pwdTextEdit:setFontSize(10);
    pwdTextEdit:setPlaceHolder("输入验证码");
    pwdTextEdit:setPlaceholderFontColor(cc.c3b(0xff,0xd8,0x12));
    pwdTextEdit:setPlaceholderFontSize(10);
    -- pwdTextEdit:setInputMode(InputMode_PHONE_NUMBER);
    pwdTextEdit:setMaxLength(18);
    pwd_word_bg:addChild(pwdTextEdit);

    --获取验证码
    local btn = ccui.Button:create("hallUserCenter/bind_btn_bg.png");
    btn:setPosition(cc.p(size.width/2+180, size.height/2+90));
    btn:onClick(
        function()
            local phoneStr = accountTextEdit:getText();
            if isEmptyString(phoneStr) then
                Hall.showTips("手机号不能为空！");
                return;
            end
            PlatformPhoneRegCheckCode(phoneStr)
        end
    );
    self:addChild(btn);

    local title = display.newSprite("hallUserCenter/bind_get_code.png", btn:getContentSize().width/2, btn:getContentSize().height/2);
    btn:addChild(title);

    --提交按钮
    local btnbg = ccui.Button:create("common/ty_green_btn.png");
    display.newSprite("hallUserCenter/btn_submit.png"):addTo(btnbg):align(display.CENTER, 91, 36)
    btnbg:setPosition(cc.p(size.width/2, size.height/2-160));
    self:addChild(btnbg);
    btnbg:onClick(
        function()
            local phoneStr = accountTextEdit:getText();
            local pwdStr = pwdTextEdit:getText();

            if isEmptyString(phoneStr) then
                Hall.showTips("手机号不能为空！");
                return;
            end
            if isEmptyString(pwdStr) then
                Hall.showTips("验证码不能为空！");
                return;
            end

            PlatformBindPhone(phoneStr,codeStr)
        end
    );

end

return BindPhoneLayer