-- 设置个人信息窗
-- Author: zx
-- Date: 2015-04-08 20:57:59

local PersonalCenterLayer = class("PersonalCenterLayer", function() return display.newLayer() end)

function PersonalCenterLayer:ctor(params)

    -- self.super.ctor(self)
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    self:setNodeEventEnabled(true)
    
    self:createUI();
    self:setDefaultData();

end

function PersonalCenterLayer:onEnter()
    self.bindIds = {}
    self.bindIds[#self.bindIds + 1] = BindTool.bind(AccountInfo, "nickName", handler(self, self.queryBackHandler))
    self.bindIds[#self.bindIds + 1] = BindTool.bind(AccountInfo, "insure", handler(self, self.queryBackHandler))
    self.bindIds[#self.bindIds + 1] = BindTool.bind(AccountInfo, "faceID", handler(self, self.queryBackHandler))
    self.bindIds[#self.bindIds + 1] = BindTool.bind(AccountInfo, "gender", handler(self, self.queryBackHandler))
    self.bindIds[#self.bindIds + 1] = BindTool.bind(AccountInfo, "underwrite", handler(self, self.queryBackHandler))
    self.head_handler = HallEvent:addEventListener(HallEvent.AVATAR_UPLOAD_SUCCESS,handler(self, self.customFaceUploadBackHandler))
    BankInfo:sendQueryRequest()

end

function PersonalCenterLayer:onExit()
    for _, bindid in ipairs(self.bindIds) do
        BindTool.unbind(bindid)
    end
    HallEvent:removeEventListener(self.head_handler)

end

    
--查询成功
function PersonalCenterLayer:queryBackHandler(event)
    print("PersonalCenterLayer-queryBackHandler",event.score,event.insure)

    self:setDefaultData()
    self.bankboxLabel:setString(FormatNumToString(AccountInfo.insure))

end

--上传头像成功回调 
function PersonalCenterLayer:customFaceUploadBackHandler(event)
    -- body
    local tokenID = event.tokenID
    local md5 = event.md5
    self.headView:setNewHead(999,tokenID,md5)

    --通知服务端
    AccountInfo:sendChangeFaceIdRequest(999)
    AccountInfo:sendSetPlatformFaceRequest(md5)
end

function PersonalCenterLayer:onUserInfoChanged(event)
    self:setDefaultData();
    Hall.showTips("修改成功！", 1.0)

end

function PersonalCenterLayer:createUI()

    local displaySize = cc.size(display.width, display.height);
    local winSize = cc.Director:getInstance():getWinSize();

    self:setContentSize(displaySize);
    
    -- 蒙板
    local maskLayer = ccui.ImageView:create("black.png");
    maskLayer:setScale9Enabled(true);
    maskLayer:setContentSize(cc.size(winSize.width, winSize.height));
    maskLayer:setPosition(cc.p(displaySize.width / 2, displaySize.height / 2));
    maskLayer:setTouchEnabled(true);
    maskLayer:addTo(self);


    local bgSprite = ccui.ImageView:create("common/pop_bg.png");
    bgSprite:setScale9Enabled(true);
    bgSprite:setContentSize(cc.size(674, 443));
    bgSprite:setPosition(cc.p(displaySize.width / 2, displaySize.height / 2));
    self:addChild(bgSprite);

    local panel = ccui.ImageView:create("common/panel.png");
    panel:setScale9Enabled(true);
    panel:setAnchorPoint(cc.p(0,0))
    panel:setContentSize(cc.size(595, 305));
    panel:setPosition(cc.p(40, 100));
    bgSprite:addChild(panel);

    local titleSprite = cc.Sprite:create("hall/room/hall_common_title.png");
    titleSprite:setPosition(cc.p(137, 406));
    bgSprite:addChild(titleSprite,2);

    local title = ccui.Text:create("个", FONT_ART_TEXT, 24)
    title:setPosition(cc.p(30,68))
    title:setTextColor(cc.c4b(251,248,142,255))
    title:enableOutline(cc.c4b(137,0,167,200), 3)
    title:addTo(titleSprite)

    title = ccui.Text:create("人", FONT_ART_TEXT, 24)
    title:setPosition(cc.p(55,68))
    title:setTextColor(cc.c4b(251,248,142,255))
    title:enableOutline(cc.c4b(137,0,167,200), 3)
    title:addTo(titleSprite)

    title = ccui.Text:create("中", FONT_ART_TEXT, 24)
    title:setPosition(cc.p(80,68))
    title:setTextColor(cc.c4b(251,248,142,255))
    title:enableOutline(cc.c4b(137,0,167,200), 3)
    title:addTo(titleSprite)

    title = ccui.Text:create("心", FONT_ART_TEXT, 24)
    title:setPosition(cc.p(105,68))
    title:setTextColor(cc.c4b(251,248,142,255))
    title:enableOutline(cc.c4b(137,0,167,200), 3)
    title:addTo(titleSprite)


    local panel2 = ccui.ImageView:create("common/panelinpanel.png");
    panel2:setScale9Enabled(true);
    panel2:setAnchorPoint(cc.p(0,0))
    panel2:setContentSize(cc.size(190, 295));
    panel2:setPosition(cc.p(10, 5));
    panel:addChild(panel2);

    local headView = require("commonView.GameHeadView").new(1);
    headView:setModifyMode(function (headIndex)
        print("setModifyMode",headIndex);
        AccountInfo:sendChangeFaceIdRequest(headIndex)
    end);
    headView:setPosition(cc.p(89, 210));
    panel2:addChild(headView);
    self.headView = headView;

    --昵称
    local nicknameLabel = ccui.Text:create("昵称同步中", "Arial", 24);--"昵称同步中", 24, cc.c3b(255,230,100)
    nicknameLabel:setColor(cc.c3b(255,230,100));
    nicknameLabel:setPosition(cc.p(89, 130));
    nicknameLabel:setAnchorPoint(cc.p(0.5,0));
    panel2:addChild(nicknameLabel);
    self.nicknameLabel = nicknameLabel;

    --ID
    local idLabel = ccui.Text:create("ID同步中", "Arial", 24);
    idLabel:setColor(cc.c3b(255,230,100));
    idLabel:setAnchorPoint(cc.p(0.5,0));
    idLabel:setPosition(cc.p(89, 95));
    panel2:addChild(idLabel);
    self.idLabel = idLabel;

    --自定义头像
    local button = ccui.Button:create("common/common_button2.png","common/common_button2.png","common/common_button0.png");
    button:setScale9Enabled(true);
    button:setContentSize(cc.size(170, 65));
    button:setTitleFontName(FONT_ART_BUTTON);
    button:setTitleText("自定义头像");
    button:setTitleColor(cc.c3b(255,255,255));
    button:setTitleFontSize(22);
    button:setPressedActionEnabled(true);
    button:getTitleRenderer():enableOutline(COLOR_BTN_BLUE,2);
    button:addTouchEventListener(
        function ( sender,eventType )
            if eventType == ccui.TouchEventType.ended then
                self:setCustiomHead()
                onUmengEvent("1041")
            end
        end
        )
    button:addTo(panel2)
    button:setPosition(cc.p(89, 52))

    local vy = 29
    --huanledou
    -- local goldImage = ccui.ImageView:create();
    -- goldImage:loadTexture("common/huanledou.png");
    -- goldImage:setPosition(cc.p(520,435+vy));
    -- goldImage:scale(0.8)
    -- self:addChild(goldImage)

    -- local goldLabel = display.newTTFLabel({text = "",
    --                             size = 22,
    --                             color = cc.c3b(255,255,128),
    --                             --align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
    --                         })
    --             :align(display.LEFT_CENTER, 540, 435+vy)
    --             :addTo(self)
    -- self.goldLabel = goldLabel;

    --gold
    local coinImage = ccui.ImageView:create();
    coinImage:loadTexture("common/gold.png");
    coinImage:setPosition(cc.p(240, 275));
    coinImage:scale(0.8)
    panel:addChild(coinImage)

    local coinLabel = display.newTTFLabel({text = "",
                                size = 22,
                                color = cc.c3b(255,255,128),
                                --align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                            })
                :align(display.LEFT_CENTER, 260, 275)
                :addTo(panel)
    self.coinLabel = coinLabel;
    --保险箱
    local bankboxImage = ccui.ImageView:create();
    bankboxImage:loadTexture("common/bankbox.png");
    bankboxImage:setPosition(cc.p(370,275));
    -- bankboxImage:scale(0.8)
    panel:addChild(bankboxImage)

    local bankboxLabel = display.newTTFLabel({text = "",
                                size = 22,
                                color = cc.c3b(255,255,128),
                                --align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                            })
                :align(display.LEFT_CENTER, 390, 275)
                :addTo(panel)
    self.bankboxLabel = bankboxLabel;

    if OnlineConfig_review == "on" then
        bankboxImage:hide()
        self.bankboxLabel:hide()
    end


    --魅力
    local lovelinessImage = ccui.ImageView:create();
    lovelinessImage:loadTexture("common/loveliness.png");
    lovelinessImage:setPosition(cc.p(490, 275));
    -- lovelinessImage:scale(0.8)
    panel:addChild(lovelinessImage)

    local lovelinessLabel = display.newTTFLabel({text = "999",
                                size = 22,
                                color = cc.c3b(255,255,128),
                                --align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                            })
                :align(display.LEFT_CENTER, 510, 275)
                :addTo(panel)
    self.lovelinessLabel = lovelinessLabel;
    --礼券
    local lqImage = ccui.ImageView:create();
    lqImage:loadTexture("liquan/lq_icon0.png");
    lqImage:setPosition(cc.p(240,225));
    lqImage:scale(0.8)
    panel:addChild(lqImage)

    local coinLabel = display.newTTFLabel({text = "999",
                                size = 22,
                                color = cc.c3b(255,255,128),
                                --align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                            })
                :align(display.LEFT_CENTER, 260, 232)
                :addTo(panel)
    self.lqLabel = coinLabel;
    local inReview = false;
    if OnlineConfig_review == nil or OnlineConfig_review == "on" then
        inReview = true;
    end
    if inReview then
        lqImage:hide()
        self.lqLabel:hide()
    end

    --High Score
    local maxLabel = ccui.Text:create("最高金额:", "", 26);
    maxLabel:setColor(cc.c3b(255,255,130));
    maxLabel:setAnchorPoint(cc.p(0,0.5));
    maxLabel:setPosition(cc.p(228, 192));
    panel:addChild(maxLabel);

    local maxLabel = ccui.Text:create("即将来到", "", 26);
    maxLabel:setColor(cc.c3b(255,255,130));
    maxLabel:setAnchorPoint(cc.p(0,0.5));
    maxLabel:setPosition(cc.p(360, 192));
    panel:addChild(maxLabel);
    self.maxLabel = maxLabel;


    --会员
    -- display.newTTFLabel({text = "会员  ",
    --                             size = 26,
    --                             color = cc.c3b(255,255,130),
    --                             --align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
    --                         })
    --             :align(display.LEFT_BOTTOM, 510, 335+vy)
    --             :addTo(self)
    --             --:hide()
    -- self.txtVIP = display.newTTFLabel({text = "金冠VIP",
    --                             size = 24,
    --                             color = cc.c3b(255,255,128),
    --                             align = cc.ui.TEXT_ALIGN_LEFT -- 文字内部居中对齐
    --                         })
    --             :align(display.LEFT_BOTTOM, 580, 335+vy)
    --             :addTo(self)
    --             --:hide()

    --EXP
    local levelSprite = display.newScale9Sprite("hall/personalCenter/level_bg.png", 0, 0, cc.size(60, 28))
    levelSprite:setPosition(cc.p(252, 152));
    panel:addChild(levelSprite);

    local lvLabel = ccui.Text:create("LV.1", "", 24);
    lvLabel:setColor(cc.c3b(255,255,255));
    --lvLabel:setAnchorPoint(cc.p(0,0.5));
    lvLabel:setPosition(cc.p(251, 152));
    panel:addChild(lvLabel);
    self.lvLabel = lvLabel;

    --exp
    local expPos = cc.p(435, 152);
    local expBgSprite = cc.Sprite:create("hall/personalCenter/exp_background.png");
    expBgSprite:setPosition(expPos);
    panel:addChild(expBgSprite);
    self.expBgSprite = expBgSprite;

    local expNowExp = display.newProgressTimer("hall/personalCenter/exp_now.png", display.PROGRESS_TIMER_BAR);
    expNowExp:align(display.CENTER, expPos.x, expPos.y)
    expNowExp:setMidpoint(cc.p(0, 0.5))
    expNowExp:setBarChangeRate(cc.p(1.0, 0))
    panel:addChild(expNowExp);
    self.expNowExp = expNowExp;

    local expLabel = ccui.Text:create("NA/NA", "Arial", 24);
    expLabel:setColor(cc.c3b(255,255,255));
    expLabel:setPosition(expPos);
    panel:addChild(expLabel);
    self.expLabel = expLabel;

    --Sex
    local manLabel = ccui.Text:create("男", "Arial", 26);
    manLabel:setColor(cc.c3b(255,255,130));
    manLabel:setPosition(cc.p(242, 106));
    panel:addChild(manLabel);

    local select1 = ccui.ImageView:create("common/panelinpanel.png");
    select1:setTouchEnabled(true);
    select1:setPosition(cc.p(288, 106));
    panel:addChild(select1);
    select1:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended and self.manSelect:isVisible() == false then
                self:modifySex(1);
                Click();
            end
        end
    )

    local manSelect = ccui.ImageView:create("hall/personalCenter/select.png");
    manSelect:setPosition(cc.p(288, 106));
    panel:addChild(manSelect);
    self.manSelect = manSelect;

    local femaleLabe = ccui.Text:create("女", "Arial", 26);
    femaleLabe:setColor(cc.c3b(255,255,130));
    femaleLabe:setPosition(cc.p(370, 106));
    panel:addChild(femaleLabe);

    local select2 = ccui.ImageView:create("common/panelinpanel.png");
    select2:setTouchEnabled(true);
    select2:setPosition(cc.p(435, 106));
    panel:addChild(select2);
    select2:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended and self.femaleSelect:isVisible() == false then
            self:modifySex(0);
            Click();
        end
    end)

    local femaleSelect = ccui.ImageView:create("hall/personalCenter/select.png");
    femaleSelect:setPosition(cc.p(435, 106));
    panel:addChild(femaleSelect);
    self.femaleSelect = femaleSelect;

    --签名
    local underWriteLabel = ccui.Text:create("签名同步中", "Arial", 24);--"签名同步中", 24, cc.c3b(255,230,100)
    underWriteLabel:setColor(cc.c3b(255,230,100));
    underWriteLabel:setPosition(cc.p(227, 72));
    underWriteLabel:setAnchorPoint(cc.p(0,1))
    panel:addChild(underWriteLabel);
    
    underWriteLabel:setString("个性签名:")
    underWriteLabel:setTextAreaSize(cc.size(330,100))
    underWriteLabel:ignoreContentAdaptWithSize(false)
    underWriteLabel:setTextHorizontalAlignment(0)
    underWriteLabel:setTextVerticalAlignment(0)
    self.underWriteLabel = underWriteLabel;
    --修改按钮
    local button = ccui.Button:create("common/button_green.png");
    button:setScale9Enabled(true);
    button:setContentSize(cc.size(180, 67));
    --button:setCapInsets(cc.rect(130, 33, 1, 1));
    --button:setPosition(cc.p(840,56));
    button:setTitleFontName(FONT_ART_BUTTON);
    button:setTitleText("修改昵称");
    button:setTitleColor(cc.c3b(255,255,255));
    button:setTitleFontSize(26);
    button:setPressedActionEnabled(true);
    button:getTitleRenderer():enableOutline(COLOR_BTN_GREEN,2)
    button:addTouchEventListener(
        function ( sender,eventType )
            if eventType == ccui.TouchEventType.ended then
                self:showNicknameModify()
                onUmengEvent("1042")
            end
        end
        )
    button:setPosition(cc.p(150, 65));
    bgSprite:addChild(button);

    --修改签名
    local button = ccui.Button:create("common/button_green.png");
    button:setScale9Enabled(true);
    button:setContentSize(cc.size(180, 67));
    --button:setCapInsets(cc.rect(130, 33, 1, 1));
    --button:setPosition(cc.p(840,56));
    button:setTitleFontName(FONT_ART_BUTTON);
    button:setTitleText("编辑签名");
    button:setTitleColor(cc.c3b(255,255,255));
    button:setTitleFontSize(26);
    button:setPressedActionEnabled(true);
    button:getTitleRenderer():enableOutline(COLOR_BTN_GREEN,2)
    button:addTouchEventListener(
        function ( sender,eventType )
            if eventType == ccui.TouchEventType.ended then
                self:showUnderWriteModify()
            end
        end
        )
    button:setPosition(cc.p(335, 65));
    bgSprite:addChild(button);

    -- local modify = ccui.Button:create("hall/personalCenter/modify_button.png");
    -- modify:setPosition(cc.p(568,135));
    -- self:addChild(modify);
    -- modify:setPressedActionEnabled(true);
    -- modify:addTouchEventListener(
    --     function(sender,eventType)
    --         if eventType == ccui.TouchEventType.ended then

    --             self:showNicknameModify();

    --         end
    --     end
    -- )

    local button = ccui.Button:create("common/button_green.png");
    button:setScale9Enabled(true);
    button:setContentSize(cc.size(180, 67));
    button:setTitleFontName(FONT_ART_BUTTON);
    button:setTitleText("手机号绑定");
    button:setTitleColor(cc.c4b(255,255,255,255));
    button:setTitleFontSize(26);
    button:setPressedActionEnabled(true);
    button:getTitleRenderer():enableOutline(COLOR_BTN_GREEN,2)
    button:addTouchEventListener(
        function ( sender,eventType )
            if eventType == ccui.TouchEventType.ended then
                self:mobileBindHandler(sender)
            end
        end
        )
    button:setPosition(cc.p(520, 65));
    bgSprite:addChild(button);

    local exit = ccui.Button:create("common/close.png");
    exit:setPosition(cc.p(645, 420));
    bgSprite:addChild(exit);
    exit:setPressedActionEnabled(true);
    exit:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then

                self:removeFromParent();

            end
        end
    )

end

function PersonalCenterLayer:mobileBindHandler(sender)
    local mobileBind = require("hall.MobileBind").new()
    self:addChild(mobileBind,2)
end

function PersonalCenterLayer:setDefaultData()
    
    local userInfo = DataManager:getMyUserInfo();
    if userInfo then

        if userInfo.faceID and type(userInfo.faceID) == "number" then

            self.headView:setNewHead(userInfo.faceID, userInfo.platformID, userInfo.platformFace);
            
        end

        local VIP_LABEL = {
        "绿钻VIP",
        "蓝钻VIP",
        "紫钻VIP",
        "金钻VIP",
        "王冠VIP",
        }
        self.headView:setVipHead(userInfo.memberOrder)
        -- if userInfo.memberOrder > 0 and userInfo.memberOrder <=5 then
        --     self.txtVIP:setString(VIP_LABEL[userInfo.memberOrder])
        -- else
        --     self.txtVIP:setString("普通会员")
        -- end
        self.lvLabel:setString("LV." .. getLevelByExp(userInfo.medal))

        local nickName = FormotGameNickName(userInfo.nickName,5);
        self.nicknameLabel:setString(nickName);

        self.idLabel:setString("ID:" .. userInfo.userID);
        -- self.goldLabel:setString(FormatNumToString(userInfo.beans));
        self.coinLabel:setString(FormatNumToString(userInfo.score));
        self.lqLabel:setString(FormatNumToString(userInfo.present));
        self.maxLabel:setString(FormatNumToString(userInfo.score).."金币")
        
        self.lovelinessLabel:setString(FormatNumToString(userInfo.loveLiness))
        
        self.underWriteLabel:setString("个性签名:"..userInfo.signature)
        print("AccountInfo.signature", AccountInfo.signature)
        print("userInfo.signature", userInfo.signature)

        self.underWriteLabel:setTextAreaSize(cc.size(330,100))
        self.underWriteLabel:ignoreContentAdaptWithSize(false)
        self.underWriteLabel:setTextHorizontalAlignment(0)
        self.underWriteLabel:setTextVerticalAlignment(0)

        local levelInfo = getLevelInfo(userInfo.medal)
        self.expLabel:setString(levelInfo.curNextLevelExp .. "/" .. levelInfo.nextLevelExp);
        self.expNowExp:setPercentage(100*levelInfo.curNextLevelExp/levelInfo.nextLevelExp)
        -- self.guanxian:refreshGuanXian(levelInfo.curNextLevelExp)
        print("性别：", userInfo.gender)
        if userInfo.gender == 1 then
            self.manSelect:setVisible(true);
            self.femaleSelect:setVisible(false);
        else
            self.manSelect:setVisible(false);
            self.femaleSelect:setVisible(true);
        end
    end

end

function PersonalCenterLayer:modifySex(gender)

    AccountInfo:sendChangeGenderRequest(gender)

end

--修改个性签名
function PersonalCenterLayer:showUnderWriteModify()
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

    local bgSprite = ccui.ImageView:create("view/frame3.png");
    bgSprite:setScale9Enabled(true);
    bgSprite:setContentSize(cc.size(450+200, 250+50));
    bgSprite:setPosition(cc.p(displaySize.width / 2, displaySize.height / 2));
    bgSprite:addTo(newLayer);

    --个性签名
    local editSprite = ccui.ImageView:create("hall/login/edit_bg.png");
    editSprite:setScale9Enabled(true);
    editSprite:setContentSize(cc.size(550, 125));
    editSprite:setPosition(cc.p(565, 350));
    editSprite:addTo(newLayer);

    -- local editLabel = ccui.Text:create("个性签名:", "Arial", 26);
    -- editLabel:setColor(cc.c3b(255,255,130));
    -- editLabel:setPosition(cc.p(420, 380));
    -- newLayer:addChild(editLabel);

    local underWriteField = ccui.EditBox:create(cc.size(500, 38), "blank.png");
    underWriteField:setAnchorPoint(cc.p(0.5,0.5));
    underWriteField:setPosition(cc.p(565, 346));
    underWriteField:setFontSize(24);

    local userInfo = DataManager:getMyUserInfo();
    local holder = FormotGameNickName(userInfo.signature,20) or "请输入新的签名";
    underWriteField:setPlaceHolder(holder);
    underWriteField:setPlaceholderFontColor(cc.c3b(255,255,255));
    underWriteField:setPlaceholderFontSize(24);
    underWriteField:setMaxLength(20);
    underWriteField:addTo(newLayer)

    underWriteField:setText(FormotGameNickName(userInfo.signature,20));

    local tipLabel = ccui.Text:create("字数限制20个汉字", "Arial", 26);
    tipLabel:setColor(cc.c3b(255,255,130));
    tipLabel:setAnchorPoint(cc.p(0.0,0.5));
    tipLabel:setPosition(cc.p(300, 250));
    newLayer:addChild(tipLabel);

    --提交按钮
    local button = ccui.Button:create("common/button_green.png");
    button:setScale9Enabled(true);
    button:setContentSize(cc.size(150, 67));
    --button:setCapInsets(cc.rect(130, 33, 1, 1));
    button:setPosition(cc.p(650+150,235));
    button:setTitleFontName(FONT_ART_BUTTON);
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
                        AccountInfo:sendChangeSignatureRequest(newUnderWrite)
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
    exit:setPosition(cc.p(780+100,440));
    newLayer:addChild(exit);
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

function PersonalCenterLayer:showNicknameModify()


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

    local bgSprite = ccui.ImageView:create("view/frame3.png");
    bgSprite:setScale9Enabled(true);
    bgSprite:setContentSize(cc.size(585, 250));
    bgSprite:setPosition(cc.p(displaySize.width / 2, displaySize.height / 2));
    bgSprite:addTo(newLayer);

    --昵称
    local editSprite = ccui.ImageView:create("hall/login/edit_bg.png");
    editSprite:setScale9Enabled(true);
    editSprite:setAnchorPoint(cc.p(0,0.5))
    editSprite:setContentSize(cc.size(350, 55));
    editSprite:setPosition(cc.p(435, 380));
    editSprite:addTo(newLayer);

    local editLabel = ccui.Text:create("昵称:", FONT_ART_TEXT, 26);
    editLabel:setColor(cc.c3b(0xfe,0xfe,0xf9));
    editLabel:setPosition(cc.p(380, 380));
    -- editLabel:enableOutline(cc.c4b(), 2)
    newLayer:addChild(editLabel);

    local nicknameField = ccui.EditBox:create(cc.size(200, 38), "blank.png");
    nicknameField:setAnchorPoint(cc.p(0,0.5));
    nicknameField:setPosition(cc.p(440, 376));
    nicknameField:setFontSize(24);

    local userInfo = DataManager:getMyUserInfo();
    local holder = userInfo.nickName or "请输入新的昵称";
    nicknameField:setPlaceHolder(holder);
    nicknameField:setPlaceholderFontColor(cc.c3b(255,255,255));
    nicknameField:setPlaceholderFontSize(24);
    nicknameField:setMaxLength(10);
    nicknameField:addTo(newLayer)

    nicknameField:setText(userInfo.nickName);

    local tipLabel = ccui.Text:create("修改昵称需要50万金币.", "Arial", 26);
    tipLabel:setColor(cc.c3b(255,255,130));
    tipLabel:setAnchorPoint(cc.p(0.0,0.5));
    tipLabel:setPosition(cc.p(350, 320));
    newLayer:addChild(tipLabel);


    --提交按钮
    local button = ccui.Button:create("common/button_green.png");
    button:setScale9Enabled(true);
    button:setContentSize(cc.size(150, 67));
    --button:setCapInsets(cc.rect(130, 33, 1, 1));
    button:setPosition(cc.p(display.cx,255));
    button:setTitleFontName(FONT_ART_BUTTON);
    button:setTitleText("提交");
    button:setTitleColor(cc.c3b(255,255,255));
    button:setTitleFontSize(30);
    button:setPressedActionEnabled(true);
    button:getTitleRenderer():enableOutline(COLOR_BTN_GREEN,2)
    button:addTouchEventListener(
        function ( sender,eventType )
            if eventType == ccui.TouchEventType.ended then
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
    newLayer:addChild(button);

    --关闭按钮
    local exit = ccui.Button:create("common/close.png");
    exit:setPosition(cc.p(840,440));
    newLayer:addChild(exit);
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

function PersonalCenterLayer:setCustiomHead()
    -- if 1 then
    --     Hall.showTips("自定义头像即将到来！", 1)
    --     return
    -- end
    if device.platform ~= "ios" then
        print("PersonalCenterLayer:setCustiomHead")
        local layer = require("commonView.CustomAvatarLayer").new():addTo(self)
    else
        local layer = require("commonView.CustomAvatarLayer").new():addTo(self)
    end

end

return PersonalCenterLayer