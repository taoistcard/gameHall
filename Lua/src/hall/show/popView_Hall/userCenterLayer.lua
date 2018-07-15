local baseWindow = require("show.popView_Hall.baseWindow")

local UserCenterLayer = class("UserCenterLayer", baseWindow)

function UserCenterLayer:ctor(params)
    self.super.ctor(self, 3)
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    self:setNodeEventEnabled(true)
    
    self:createUI();

    self:setDefaultData();

    self:bindEvent()
end

function UserCenterLayer:onEnter()

end

function UserCenterLayer:onExit()
    package.loaded["popView.userCenterLayer"] = nil
    self:unBindEvent()
end

function UserCenterLayer:bindEvent()
    self.bindIds = {}
    self.bindIds[#self.bindIds + 1] = BindTool.bind(AccountInfo, "gender", handler(self, self.setDefaultData))
    self.bindIds[#self.bindIds + 1] = BindTool.bind(AccountInfo, "nickName", handler(self, self.setDefaultData))

    self.head_handler = HallEvent:addEventListener(HallEvent.AVATAR_UPLOAD_SUCCESS,handler(self, self.customFaceUploadBackHandler))
    
end

function UserCenterLayer:unBindEvent()
    for _, bindid in ipairs(self.bindIds) do
        BindTool.unbind(bindid)
    end
    HallEvent:removeEventListener(self.head_handler)
end

function UserCenterLayer:createUI()

    local size = cc.Director:getInstance():getWinSize();
    local center = cc.p(size.width / 2, size.height / 2);
    local cx = center.x;
    local cy = center.y;
    local contentNode = self:getContentNode()

    local titleSprite = ccui.ImageView:create("hallUserCenter/gernzx.png");
    titleSprite:setPosition(cc.p(360, 515));
    contentNode:addChild(titleSprite, 2);

    --昵称
    local nicknameLabel = ccui.Text:create("昵称同步中", FONT_PTY_TEXT, 24);
    nicknameLabel:setColor(cc.c3b(255,255,255));
    nicknameLabel:setPosition(cc.p(136, 420));
    nicknameLabel:enableOutline(cc.c4b(0,0,0,255),2)
    contentNode:addChild(nicknameLabel);
    self.nicknameLabel = nicknameLabel;

    local headView = require("show.popView_Hall.HeadView").new(1,true);
    headView:setPosition(cc.p(136, 335));
    contentNode:addChild(headView);
    self.headView = headView;

    --ID
    local idLabel = ccui.Text:create("[游戏ID]", FONT_PTY_TEXT, 24);
    idLabel:setColor(cc.c3b(255,255,255));
    idLabel:enableOutline(cc.c4b(0,0,0,255),2);
    idLabel:setPosition(cc.p(457, 420));
    contentNode:addChild(idLabel);
    self.idLabel = idLabel;

    --自定义头像
    local btnbg = ccui.ImageView:create("hallUserCenter/btn_change_headImg_bg.png");
    btnbg:setPosition(cc.p(136, 240));
    contentNode:addChild(btnbg);
    btnbg:setTouchEnabled(true)
    display.newSprite("hallUserCenter/btn_change_headImg.png"):addTo(btnbg):align(display.CENTER, 62, 23)
    btnbg:addTouchEventListener(
        function ( sender,eventType )
            if eventType == ccui.TouchEventType.began then
                sender:scale(1.05)
            elseif eventType == ccui.TouchEventType.canceled then
                sender:scale(1.0)
            elseif eventType == ccui.TouchEventType.ended then
                sender:scale(1.0)
                self:setCustiomHead()
            end
        end
    )

    local startX = 250
    local addWidth = 20

    --gold
    local coinImage = ccui.ImageView:create();
    coinImage:loadTexture("common/ty_coin.png");
    coinImage:setPosition(cc.p(startX,360));
    coinImage:setAnchorPoint(cc.p(0,0.5));
    coinImage:scale(1.3);
    contentNode:addChild(coinImage)

    startX = startX + coinImage:getContentSize().width + addWidth

    local coinLabel = display.newTTFLabel({text = FormatNumToString(AccountInfo.score),
                                size = 22,
                                color = cc.c3b(255,224,20),
                                font = FONT_PTY_TEXT
                            })
    coinLabel:setAnchorPoint(cc.p(0,0.5));
    coinLabel:setPosition(cc.p(startX,360));
    coinLabel:enableOutline(cc.c4b(0,0,0,255),2);
    contentNode:addChild(coinLabel)
    self.coinLabel = coinLabel;

    startX = startX + coinLabel:getContentSize().width + addWidth

    --银行
    local bankboxImage = ccui.ImageView:create();
    bankboxImage:loadTexture("common/ty_bank.png");
    bankboxImage:setPosition(cc.p(startX, 360));
    bankboxImage:setAnchorPoint(cc.p(0,0.5));
    bankboxImage:scale(0.8)
    contentNode:addChild(bankboxImage)

    startX = startX + bankboxImage:getContentSize().width +addWidth

    local bankboxLabel = display.newTTFLabel({text = FormatNumToString(AccountInfo.insure),
                                size = 22,
                                color = cc.c3b(255,224,20),
                                font = FONT_PTY_TEXT
                            })
    bankboxLabel:setAnchorPoint(cc.p(0,0.5));
    bankboxLabel:setPosition(cc.p(startX,360));
    bankboxLabel:enableOutline(cc.c4b(0,0,0,255),2);
    contentNode:addChild(bankboxLabel)
    self.bankboxLabel = bankboxLabel;

    startX = startX + bankboxLabel:getContentSize().width + addWidth

    startX = 250

    --礼券
    local lqImage = ccui.ImageView:create();
    lqImage:loadTexture("common/ty_quan.png");
    lqImage:setPosition(cc.p(startX, 300));
    lqImage:setAnchorPoint(cc.p(0,0.5));
    contentNode:addChild(lqImage)

    startX = startX + lqImage:getContentSize().width + addWidth

    local coinLabel = display.newTTFLabel({text = FormatNumToString(AccountInfo.present),
                                size = 22,
                                color = cc.c3b(255,224,20),
                                font = FONT_PTY_TEXT
                            })
    coinLabel:setAnchorPoint(cc.p(0,0.5));
    coinLabel:setPosition(cc.p(startX, 300));
    coinLabel:enableOutline(cc.c4b(0,0,0,255),2);
    contentNode:addChild(coinLabel)
    self.lqLabel = coinLabel;

    startX = startX + coinLabel:getContentSize().width + addWidth

    --魅力值
    local meiLi = cc.Sprite:create("hallUserCenter/meili_icon.png");
    meiLi:setPosition(cc.p(startX, 300));
    meiLi:setAnchorPoint(cc.p(0,0.5));
    contentNode:addChild(meiLi);

    startX = startX + meiLi:getContentSize().width + addWidth

    local meiLiLabel = display.newTTFLabel({text = FormatNumToString(AccountInfo.loveLiness),
                                size = 22,
                                color = cc.c3b(255,224,20),
                                font = FONT_PTY_TEXT
                            })
    meiLiLabel:setAnchorPoint(cc.p(0,0.5));
    meiLiLabel:setPosition(cc.p(startX, 300));
    meiLiLabel:enableOutline(cc.c4b(0,0,0,255),2);
    contentNode:addChild(meiLiLabel);
    self.meiLiLabel = meiLiLabel;

    --Sex
    local manLabel = ccui.Text:create("男", FONT_PTY_TEXT, 32);
    manLabel:setColor(cc.c3b(255,255,255));
    manLabel:enableOutline(cc.c4b(0,0,0,255),2);
    manLabel:setPosition(cc.p(310, 225));
    contentNode:addChild(manLabel);

    local select1 = ccui.ImageView:create("common/ty_pao_pao.png");
    select1:setScale(0.65)
    select1:setTouchEnabled(true);
    select1:setPosition(cc.p(380, 225));
    contentNode:addChild(select1);
    select1:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended and self.manSelect:isVisible() == false then
                self:modifySex(1);
                -- Click();
            end
        end
    )

    local manSelect = ccui.ImageView:create("hallUserCenter/select.png");
    manSelect:setPosition(cc.p(50, 50));
    manSelect:setScale(1.3)
    select1:addChild(manSelect);
    self.manSelect = manSelect;

    local femaleLabe = ccui.Text:create("女", FONT_PTY_TEXT, 32);
    femaleLabe:setColor(cc.c3b(255,255,255));
    femaleLabe:enableOutline(cc.c4b(0,0,0,255),2);
    femaleLabe:setPosition(cc.p(470, 225));
    contentNode:addChild(femaleLabe);

    local select2 = ccui.ImageView:create("common/ty_pao_pao.png");
    select2:setScale(0.65)
    select2:setTouchEnabled(true);
    select2:setPosition(cc.p(540, 225));
    contentNode:addChild(select2);
    select2:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended and self.femaleSelect:isVisible() == false then
            self:modifySex(0);
            -- Click();
        end
    end)

    local femaleSelect = ccui.ImageView:create("hallUserCenter/select.png");
    femaleSelect:setPosition(cc.p(50, 50));
    femaleSelect:setScale(1.3)
    select2:addChild(femaleSelect);
    self.femaleSelect = femaleSelect;

    --修改昵称
    local btnNickNameBg = ccui.ImageView:create("common/ty_green_btn.png");
    btnNickNameBg:setPosition(cc.p(258, 72));
    contentNode:addChild(btnNickNameBg);
    btnNickNameBg:setTouchEnabled(true)
    display.newSprite("hallUserCenter/btn_modify_name.png"):addTo(btnNickNameBg):align(display.CENTER, 91, 36)
    btnNickNameBg:addTouchEventListener(
        function ( sender,eventType )
            if eventType == ccui.TouchEventType.began then
                sender:scale(1.05)
            elseif eventType == ccui.TouchEventType.canceled then
                sender:scale(1.0)
            elseif eventType == ccui.TouchEventType.ended then
                sender:scale(1.0)
                self:showNicknameModify()
            end
        end
    )

    --修改密码
    local btnPwdbg = ccui.ImageView:create("common/ty_yellow_btn.png");
    btnPwdbg:setPosition(cc.p(475, 72));
    contentNode:addChild(btnPwdbg);
    btnPwdbg:setTouchEnabled(true)
    display.newSprite("hallUserCenter/btn_modify_pwd.png"):addTo(btnPwdbg):align(display.CENTER, 91, 36)
    btnPwdbg:addTouchEventListener(
        function ( sender,eventType )
            if eventType == ccui.TouchEventType.began then
                sender:scale(1.05)
            elseif eventType == ccui.TouchEventType.canceled then
                sender:scale(1.0)
            elseif eventType == ccui.TouchEventType.ended then
                sender:scale(1.0)
                self:showPwdModify()
            end
        end
    )

    --绑定手机号
    if not BindMobilePhone then
        local btn = ccui.Button:create("hallUserCenter/btn_bind_phone.png");
        btn:setPosition(cc.p(550, 72));
        contentNode:addChild(btn);
        btn:onClick(
            function()
                self:mobileBindHandler()
            end
        );
        btnPwdbg:setPosition(cc.p(360, 72));
        btnNickNameBg:setPosition(cc.p(170, 72));
    end


end

function UserCenterLayer:mobileBindHandler()
    local vipLayer = require("show.popView_Hall.BindPhoneLayer").new()
    self:addChild(vipLayer)
end

function UserCenterLayer:setDefaultData()
    self.headView:setNewHead(AccountInfo.faceId, AccountInfo.cy_userId, AccountInfo.headFileMD5);
        
    --vip信息
    if OnlineConfig_review == "off" and AccountInfo.memberOrder > 0 then
        self.headView:setVipHead(AccountInfo.memberOrder,1)
    end    

    local nickName = FormotGameNickName(AccountInfo.nickName, 5);
    self.nicknameLabel:setString(nickName);

    self.idLabel:setString("[游戏ID:" .. AccountInfo.gameId.."]");

    self.coinLabel:setString(FormatNumToString(AccountInfo.score));

    self.lqLabel:setString(FormatNumToString(AccountInfo.present));

    self:refreshUserGender(AccountInfo.gender)
end

function UserCenterLayer:modifySex(gender)
    self:refreshUserGender(gender)

    AccountInfo:sendChangeGenderRequest(gender)
end

function UserCenterLayer:refreshUserGender(gender)
    if gender == 1 then
        self.manSelect:setVisible(true);
        self.femaleSelect:setVisible(false);
    else
        self.manSelect:setVisible(false);
        self.femaleSelect:setVisible(true);
    end
end


--修改个性签名
function UserCenterLayer:showUnderWriteModify()
    local displaySize = cc.size(display.width, display.height);
    local winSize = cc.Director:getInstance():getWinSize();

    local newLayer = display.newLayer();
    newLayer:setContentSize(displaySize);
    self:addChild(newLayer,3);

    -- 蒙板
    local maskLayer = ccui.ImageView:create("black.png");
    maskLayer:setScale9Enabled(true);
    maskLayer:setContentSize(cc.size(winSize.width, winSize.height));
    maskLayer:setPosition(cc.p(displaySize.width / 2, displaySize.height / 2));
    maskLayer:setTouchEnabled(true);
    maskLayer:addTo(newLayer);

    local bgSprite = ccui.ImageView:create("common/pop_bg.png");
    bgSprite:setScale9Enabled(true);
    bgSprite:setContentSize(cc.size(570, 270));
    bgSprite:setPosition(cc.p(displaySize.width / 2, displaySize.height / 2));
    bgSprite:addTo(newLayer);

    --个性签名
    local editSprite = ccui.ImageView:create("common/edit_bg1.png");
    editSprite:setScale9Enabled(true);
    editSprite:setContentSize(cc.size(505, 115));
    editSprite:setPosition(cc.p(565, 350));
    editSprite:addTo(newLayer);

    -- local editLabel = ccui.Text:create("个性签名:", "Arial", 26);
    -- editLabel:setColor(cc.c3b(255,255,130));
    -- editLabel:setPosition(cc.p(420, 380));
    -- newLayer:addChild(editLabel);

    local underWriteField = ccui.EditBox:create(cc.size(480, 50), "blank.png");
    underWriteField:setAnchorPoint(cc.p(0, 0.5));
    underWriteField:setPosition(cc.p(12, 57));
    underWriteField:setFontSize(20);

    local userInfo = PlayerInfo:getMyUserInfo();
    local holder = FormotGameNickName(userInfo:getUnderWrite(),20) or "请输入新的签名";
    underWriteField:setPlaceHolder(holder);
    underWriteField:setPlaceholderFontColor(cc.c3b(255,255,255));
    underWriteField:setPlaceholderFontSize(24);
    underWriteField:setMaxLength(20);
    underWriteField:addTo(editSprite)

    underWriteField:setText(FormotGameNickName(userInfo:getUnderWrite(),20));

    local tipLabel = ccui.Text:create("字数限制20个汉字", "Arial", 24);
    tipLabel:setColor(cc.c3b(255,255,130));
    tipLabel:setAnchorPoint(cc.p(0.0,0.5));
    tipLabel:setPosition(cc.p(320, 250));
    newLayer:addChild(tipLabel);

    --提交按钮
    local button = ccui.Button:create("common/common_button3.png");
    button:setScale9Enabled(true);
    button:setContentSize(cc.size(150, 67));
    --button:setCapInsets(cc.rect(130, 33, 1, 1));
    button:setPosition(cc.p(770,235));
    button:setTitleFontName(FONT_ART_TEXT);
    button:setTitleText("提交");
    button:setTitleColor(cc.c3b(255,255,255));
    button:setTitleFontSize(30);
    button:setPressedActionEnabled(true);
    button:getTitleRenderer():enableOutline(COLOR_BTN_GREEN,2)
    button:addTouchEventListener(
        function ( sender,eventType )
            if eventType == ccui.TouchEventType.ended then
                local newUnderWrite = underWriteField:getText();
                if string.len(newUnderWrite) > 0 then

                    if stringContainsEmoji(newUnderWrite) == true then
                        Hall.showTips("字符中不能含有表情符号", 2.5)
                    else
                        self:modifyUnderWrite(newUnderWrite);
                        newLayer:removeFromParent();
                    end
                else
                    Hall.showTips("请输入个性签名！")
                end

                Click()
            end
        end
        )
    newLayer:addChild(button);

    --关闭按钮
    local exit = ccui.Button:create("common/close.png");
    exit:setPosition(cc.p(560, 255));
    bgSprite:addChild(exit);
    exit:setPressedActionEnabled(true);
    exit:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then

                newLayer:removeFromParent();

                Click();

            end
        end
    )
end

function UserCenterLayer:modifyUnderWrite(newUnderWrite)

    local userInfo = PlayerInfo:getMyUserInfo();

end

function UserCenterLayer:showNicknameModify()

    local size = self:getContentSize();

    local newLayer = display.newLayer();
    newLayer:setContentSize(size);
    self:addChild(newLayer,3);

    -- 蒙板
    local maskLayer = ccui.ImageView:create("black.png");
    maskLayer:setScale9Enabled(true);
    maskLayer:setContentSize(size);
    maskLayer:setPosition(cc.p(size.width/2, size.height/2));
    maskLayer:setTouchEnabled(true);
    maskLayer:addTo(newLayer);
    maskLayer:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then

                newLayer:removeFromParent();
                Click();

            end
        end
    )

    local bgSprite = ccui.ImageView:create("common/ty-dikuang.png");
    bgSprite:setScale(0.6)
    bgSprite:setPosition(cc.p(size.width/2, size.height/2));
    bgSprite:addTo(newLayer);
    bgSprite:setTouchEnabled(true);

    --昵称
    local editSprite = ccui.ImageView:create("hallUserCenter/edit_bg.png");
    editSprite:setScale9Enabled(true);
    editSprite:setContentSize(cc.size(350, 90));
    editSprite:setPosition(cc.p(size.width/2, size.height/2+60));
    editSprite:addTo(newLayer);

    local nicknameField = ccui.EditBox:create(cc.size(250, 38), "blank.png");
    nicknameField:setAnchorPoint(cc.p(0,0.5));
    nicknameField:setPosition(cc.p(size.width/2-155, size.height/2+60));
    nicknameField:setFontSize(24);

    local holder = FormotGameNickName(AccountInfo.nickName,9) or "请输入新的昵称";
    nicknameField:setPlaceHolder(holder);
    nicknameField:setPlaceholderFontColor(cc.c3b(255,255,255));
    nicknameField:setPlaceholderFontSize(24);
    nicknameField:setMaxLength(30);
    nicknameField:addTo(newLayer)
    nicknameField:setText(AccountInfo.nickName);

    local tipLabel = ccui.Text:create("*修改昵称要花费50万", FONT_PTY_TEXT, 24);
    tipLabel:setColor(cc.c3b(255,224,20));
    tipLabel:setAnchorPoint(cc.p(0.5,0.5));
    tipLabel:enableOutline(cc.c4b(0,0,0,255),2)
    tipLabel:setPosition(cc.p(size.width/2, size.height/2-20));

    newLayer:addChild(tipLabel);


    --提交按钮
    local btnbg = ccui.ImageView:create("common/ty_green_btn.png");
    display.newSprite("hallUserCenter/btn_submit.png"):addTo(btnbg):align(display.CENTER, 91, 36)
    btnbg:setPosition(cc.p(size.width/2+90, size.height/2-90));
    newLayer:addChild(btnbg);
    btnbg:setTouchEnabled(true)
    btnbg:addTouchEventListener(
        function ( sender,eventType )
            if eventType == ccui.TouchEventType.began then
                sender:scale(1.05)
            elseif eventType == ccui.TouchEventType.canceled then
                sender:scale(1.0)
            elseif eventType == ccui.TouchEventType.ended then
                sender:scale(1.0)
                local newName = nicknameField:getText();
                if string.len(newName) > 0 then

                    if stringContainsEmoji(newName) == true then
                        Hall.showTips("字符中不能含有表情符号", 2.5)
                    else
                        AccountInfo:sendChangeNickNameRequest(newName, true)
                        newLayer:removeFromParent();
                    end
                else
                    Hall.showTips("请输入昵称！")
                end

                Click();            
            end
        end
    )

end

--密码修改需要绑定手机号才能进行忘记密码然后找回密码的操作。不能直接修改密码
function UserCenterLayer:showPwdModify()

    local size = self:getContentSize();

    local newLayer = display.newLayer();
    newLayer:setContentSize(size);
    self:addChild(newLayer,3);

    -- 蒙板
    local maskLayer = ccui.ImageView:create("black.png");
    maskLayer:setScale9Enabled(true);
    maskLayer:setContentSize(size);
    maskLayer:setPosition(cc.p(size.width/2, size.height/2));
    maskLayer:setTouchEnabled(true);
    maskLayer:addTo(newLayer);
    maskLayer:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then

                newLayer:removeFromParent();
                Click();

            end
        end
    )

    local bgSprite = ccui.ImageView:create("common/ty-dikuang.png");
    bgSprite:setScale(0.6)
    bgSprite:setPosition(cc.p(size.width/2, size.height/2));
    bgSprite:addTo(newLayer);
    bgSprite:setTouchEnabled(true)

    --密码1
    local editSprite = ccui.ImageView:create("hallUserCenter/edit_bg.png");
    editSprite:setScale9Enabled(true);
    editSprite:setContentSize(cc.size(345, 61));
    editSprite:setPosition(cc.p(size.width/2, size.height/2+90));
    editSprite:addTo(newLayer);

    local nicknameField = ccui.EditBox:create(cc.size(250, 38), "blank.png");
    nicknameField:setAnchorPoint(cc.p(0,0.5));
    nicknameField:setPosition(cc.p(size.width/2-155, size.height/2+90));
    nicknameField:setFontSize(24);
    local holder = "请输入新密码";
    nicknameField:setPlaceHolder(holder);
    nicknameField:setPlaceholderFontColor(cc.c3b(255,255,255));
    nicknameField:setPlaceholderFontSize(24);
    nicknameField:setMaxLength(15);
    nicknameField:addTo(newLayer)

    --密码2
    local editSprite = ccui.ImageView:create("hallUserCenter/edit_bg.png");
    editSprite:setScale9Enabled(true);
    editSprite:setContentSize(cc.size(345, 61));
    editSprite:setPosition(cc.p(size.width/2, size.height/2+10));
    editSprite:addTo(newLayer);

    local nicknameField2 = ccui.EditBox:create(cc.size(250, 38), "blank.png");
    nicknameField2:setAnchorPoint(cc.p(0,0.5));
    nicknameField2:setPosition(cc.p(size.width/2-155, size.height/2+10));
    nicknameField2:setFontSize(24);
    local holder = "请再次输入新密码";
    nicknameField2:setPlaceHolder(holder);
    nicknameField2:setPlaceholderFontColor(cc.c3b(255,255,255));
    nicknameField2:setPlaceholderFontSize(24);
    nicknameField2:setMaxLength(15);
    nicknameField2:addTo(newLayer)

    --提交按钮
    local btnbg = ccui.ImageView:create("common/ty_green_btn.png");
    display.newSprite("hallUserCenter/btn_submit.png"):addTo(btnbg):align(display.CENTER, 91, 36)
    btnbg:setPosition(cc.p(size.width/2+90, size.height/2-90));
    newLayer:addChild(btnbg);
    btnbg:setTouchEnabled(true)
    btnbg:addTouchEventListener(
        function (sender,eventType)
            if eventType == ccui.TouchEventType.began then
                sender:scale(1.05)
            elseif eventType == ccui.TouchEventType.canceled then
                sender:scale(1.0)
            elseif eventType == ccui.TouchEventType.ended then
                sender:scale(1.0)
                local pwd = nicknameField:getText();
                local agPwd
                
                if string.len(pwd) > 0 and string.len(agPwd) > 0 and pwd == agPwd then

                    if stringContainsEmoji(pwd) == true or stringContainsEmoji(agPwd) == true then
                        Hall.showTips("字符中不能含有表情符号", 2.5)
                    else
                        --修改密码的功能有限制
                        print("---修改密码的功能有限制,需咨询统一平台---")
                        newLayer:removeFromParent();
                    end
                else
                    Hall.showTips("密码不一致，请输入密码！")
                end
                Click();            
            end
        end
    )

end

function UserCenterLayer:setCustiomHead()

    local displaySize = cc.size(display.width, display.height);
    local winSize = cc.Director:getInstance():getWinSize();

    local newLayer = display.newLayer();
    newLayer:setContentSize(displaySize);
    self:addChild(newLayer,3);

    -- 蒙板
    local maskLayer = ccui.ImageView:create("black.png");
    maskLayer:setScale9Enabled(true);
    maskLayer:setContentSize(winSize);
    maskLayer:setPosition(cc.p(winSize.width / 2, winSize.height / 2));
    maskLayer:setTouchEnabled(true);
    maskLayer:addTo(newLayer);
    maskLayer:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                newLayer:removeFromParent()
            end
        end
    )

    local bgSprite = ccui.ImageView:create("common/ty-dikuang.png");
    bgSprite:setScale(0.5)
    bgSprite:setPosition(cc.p(winSize.width / 2, winSize.height / 2));
    newLayer:addChild(bgSprite)
    bgSprite:setTouchEnabled(true)

    --photo
    local photobutton = ccui.Button:create("hallUserCenter/btn_photo.png","hallUserCenter/btn_photo.png");
    photobutton:addTo(bgSprite)
    photobutton:setScale(2)
    photobutton:align(display.CENTER, 200, 250)
    photobutton:setScale9Enabled(false)
    photobutton:setPressedActionEnabled(false);
    photobutton:addTouchEventListener(
        function ( sender,eventType )
            if eventType == ccui.TouchEventType.ended then
                newLayer:removeFromParent()
                PlatformOpenPhoto(0)
            end
        end
        )

    --camera
    local camerabutton = ccui.Button:create("hallUserCenter/btn_camera.png","hallUserCenter/btn_camera.png");
    camerabutton:addTo(bgSprite)
    camerabutton:setScale(2)
    camerabutton:align(display.CENTER, 510, 255)
    camerabutton:setScale9Enabled(false)
    -- camerabutton:setTitleText("camera");
    camerabutton:setTitleColor(cc.c3b(0,0,0));
    camerabutton:setTitleFontSize(30);
    camerabutton:setPressedActionEnabled(false);
    camerabutton:addTouchEventListener(
        function ( sender,eventType )
            if eventType == ccui.TouchEventType.ended then
                newLayer:removeFromParent()
                PlatformOpenPhoto(1)
            end
        end
    )

end

--上传头像成功回调
function UserCenterLayer:customFaceUploadBackHandler(event)
    local md5 = event.md5
    local userID = event.userID
    self.headView:setNewHead(999,userID,md5)
    --通知服务端
    AccountInfo:sendChangeFaceIdRequest(999)
    AccountInfo:sendSetPlatformFaceRequest(md5)
end

return UserCenterLayer