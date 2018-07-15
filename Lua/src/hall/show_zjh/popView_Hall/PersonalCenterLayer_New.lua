-- 设置个人信息窗
-- Author: zx
-- Date: 2015-04-08 20:57:59

local PersonalCenterLayer = class("PersonalCenterLayer", function() return display.newLayer() end)

function PersonalCenterLayer:ctor(params)

    -- self.super.ctor(self)
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    self:setNodeEventEnabled(true)
    
    self.isRequestReturn = true

    self:createUI();
    self:setDefaultData();

end

function PersonalCenterLayer:onEnter()
    self.bindIds = {}
    -- self.bindIds[#self.bindIds + 1] = BindTool.bind(AccountInfo, "score", handler(self, self.bankSucceseHandler))
    self.bindIds[#self.bindIds + 1] = BindTool.bind(AccountInfo, "insure", handler(self, self.queryBackHandler))
    self.bindIds[#self.bindIds + 1] = BindTool.bind(AccountInfo, "nickName", handler(self, self.onUserInfoChanged))
    self.bindIds[#self.bindIds + 1] = BindTool.bind(AccountInfo, "gender", handler(self, self.onUserInfoChanged))
    self.bindIds[#self.bindIds + 1] = BindTool.bind(AccountInfo, "faceID", handler(self, self.onUserInfoChanged))
    self.bindIds[#self.bindIds + 1] = BindTool.bind(AccountInfo, "underwrite", handler(self, self.onUserInfoChanged))
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
    print("PersonalCenterLayer-queryBackHandler",AccountInfo.score,AccountInfo.insure)
    self:setDefaultData()
    self.bankboxLabel:setString(FormatNumToString(AccountInfo.insure))
end

--上传头像成功回调 
function PersonalCenterLayer:customFaceUploadBackHandler(event)
    -- body
    local tokenID = event.userID
    local md5 = event.md5
    -- local RunTimeData = require("business.RunTimeData")
    -- display.removeSpriteFrameByImageName(RunTimeData:getInstance():getLocalAvatarImageUrlByTokenID(tokenID))
    self.headView:setNewHead(999,tokenID,md5)
    --通知服务端
    AccountInfo:sendChangeFaceIdRequest(999)
    AccountInfo:sendSetPlatformFaceRequest(md5)
end

function PersonalCenterLayer:onUserInfoChanged(event)
    self.isRequestReturn = true
    self:setDefaultData();
    Hall.showTips("修改成功！", 1.0)
end

function PersonalCenterLayer:createUI()

    local displaySize = cc.size(DESIGN_WIDTH, DESIGN_HEIGHT);
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
    bgSprite:setContentSize(cc.size(642, 454));
    bgSprite:setPosition(cc.p(displaySize.width / 2, displaySize.height / 2));
    self:addChild(bgSprite);

    -- local panel = ccui.ImageView:create("common/panel.png");
    -- panel:setScale9Enabled(true);
    -- panel:setContentSize(cc.size(593+60, 255+70));
    -- panel:setPosition(cc.p(displaySize.width / 2, displaySize.height / 2 +20));
    -- self:addChild(panel);

    local titleSprite = ccui.ImageView:create("common/pop_title.png");
    titleSprite:setScale9Enabled(true);
    titleSprite:setContentSize(cc.size(226, 48));
    titleSprite:setPosition(cc.p(321, 422));
    bgSprite:addChild(titleSprite,2);

    local title = ccui.Text:create("个人中心", FONT_ART_TEXT, 24)
    title:setPosition(cc.p(113, 27))
    title:setTextColor(cc.c4b(251,248,142,255))
    title:enableOutline(cc.c4b(137,0,167,200), 3)
    title:addTo(titleSprite)

    -- title = ccui.Text:create("人", FONT_ART_TEXT, 24)
    -- title:setPosition(cc.p(55,68))
    -- title:setTextColor(cc.c4b(251,248,142,255))
    -- title:enableOutline(cc.c4b(137,0,167,200), 3)
    -- title:addTo(titleSprite)

    -- title = ccui.Text:create("中", FONT_ART_TEXT, 24)
    -- title:setPosition(cc.p(80,68))
    -- title:setTextColor(cc.c4b(251,248,142,255))
    -- title:enableOutline(cc.c4b(137,0,167,200), 3)
    -- title:addTo(titleSprite)

    -- title = ccui.Text:create("心", FONT_ART_TEXT, 24)
    -- title:setPosition(cc.p(105,68))
    -- title:setTextColor(cc.c4b(251,248,142,255))
    -- title:enableOutline(cc.c4b(137,0,167,200), 3)
    -- title:addTo(titleSprite)


    local panel2 = ccui.ImageView:create("common/panel.png");
    panel2:setScale9Enabled(true);
    panel2:setContentSize(cc.size(194, 284));
    panel2:setPosition(cc.p(128, 284));
    bgSprite:addChild(panel2);

    local headView = require("commonView.HeadView").new(1);
    headView:setModifyMode(function (headIndex)
        AccountInfo:sendChangeFaceIdRequest(headIndex)
    end);
    headView:addModifySprite()
    headView:setPosition(cc.p(97, 206));
    panel2:addChild(headView);
    self.headView = headView;

    --昵称
    local nicknameLabel = ccui.Text:create("昵称同步中", "Arial", 24);--"昵称同步中", 24, cc.c3b(255,230,100)
    nicknameLabel:setColor(cc.c3b(255,230,100));
    nicknameLabel:setPosition(cc.p(97, 125));
    panel2:addChild(nicknameLabel);
    self.nicknameLabel = nicknameLabel;

    --ID
    local idLabel = ccui.Text:create("ID同步中", "Arial", 24);
    idLabel:setColor(cc.c3b(255,230,100));
    --idLabel:setAnchorPoint(cc.p(0,0.5));
    idLabel:setPosition(cc.p(97, 93));
    panel2:addChild(idLabel);
    self.idLabel = idLabel;

    --自定义头像
    local button = ccui.Button:create("common/common_button2.png","common/common_button2.png","common/common_button0.png");
    button:setScale9Enabled(true);
    button:setContentSize(cc.size(164, 65));
    button:setTitleFontName(FONT_ART_TEXT);
    button:setTitleText("自定义头像");
    button:setTitleColor(cc.c3b(255,255,255));
    button:setTitleFontSize(22);
    button:setPressedActionEnabled(true);
    button:getTitleRenderer():enableOutline(COLOR_BTN_BLUE,2);
    button:addTouchEventListener(
        function ( sender,eventType )
            if eventType == ccui.TouchEventType.ended then
                self:setCustiomHead()
            end
        end
        )
    button:addTo(panel2)
    button:setPosition(cc.p(97, 46))

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
    coinImage:loadTexture("show/hall_coin_icon.png");
    coinImage:setPosition(cc.p(520+321-568,435+vy+227-displaySize.height/2));
    coinImage:scale(0.9)
    bgSprite:addChild(coinImage)

    local coinLabel = display.newTTFLabel({text = "",
                                size = 22,
                                color = cc.c3b(255,255,128),
                                --align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                            })
                :align(display.LEFT_CENTER, 550+321-568, 435+vy+227-displaySize.height/2)
                :addTo(bgSprite)
    self.coinLabel = coinLabel;

    --保险箱
    local bankboxImage = ccui.ImageView:create();
    bankboxImage:loadTexture("common/hall_icon_bank.png");
    bankboxImage:setPosition(cc.p(700+321-568,435+vy+227-displaySize.height/2));
    bankboxImage:scale(0.8)
    bgSprite:addChild(bankboxImage)

    local bankboxLabel = display.newTTFLabel({text = AccountInfo.insure,
                                size = 22,
                                color = cc.c3b(255,255,128),
                                --align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                            })
                :align(display.LEFT_CENTER, 730+321-568, 435+vy+227-displaySize.height/2)
                :addTo(bgSprite)
    self.bankboxLabel = bankboxLabel;

    --魅力
    local lovelinessImage = ccui.ImageView:create();
    lovelinessImage:loadTexture("common/loveliness.png");
    lovelinessImage:setPosition(cc.p(520+321-568, 380+vy+227-displaySize.height/2));
    -- lovelinessImage:scale(0.8)
    bgSprite:addChild(lovelinessImage)

    local lovelinessLabel = display.newTTFLabel({text = "999",
                                size = 22,
                                color = cc.c3b(255,255,128),
                                --align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                            })
                :align(display.LEFT_CENTER, 550+321-568, 385+vy+227-displaySize.height/2)
                :addTo(bgSprite)
    self.lovelinessLabel = lovelinessLabel;

    --礼券
    local lqImage = ccui.ImageView:create();
    lqImage:loadTexture("common/ty_lq_icon.png");
    lqImage:setPosition(cc.p(700+321-568, 380+vy+227-displaySize.height/2));
    lqImage:scale(0.8)
    bgSprite:addChild(lqImage)

    local coinLabel = display.newTTFLabel({text = "999",
                                size = 22,
                                color = cc.c3b(255,255,128),
                                --align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                            })
                :align(display.LEFT_CENTER, 730+321-568, 385+vy+227-displaySize.height/2)
                :addTo(bgSprite)
    self.lqLabel = coinLabel;
    local inReview = false;
    if OnlineConfig_review == nil or OnlineConfig_review == "on" then
        inReview = true;
    end
    -- if inReview then
        lqImage:hide()
        self.lqLabel:hide()
    -- end

    --High Score 
    local maxLabel = ccui.Text:create("最高金额:", "", 26);
    maxLabel:setColor(cc.c3b(255,255,130));
    maxLabel:setAnchorPoint(cc.p(0,0.5));
    maxLabel:setPosition(cc.p(250, 270));
    bgSprite:addChild(maxLabel);
    maxLabel:setVisible(false)

    local maxLabel = ccui.Text:create("即将来到", "", 26);
    maxLabel:setColor(cc.c3b(255,255,130));
    maxLabel:setAnchorPoint(cc.p(0,0.5));
    maxLabel:setPosition(cc.p(405, 270));
    bgSprite:addChild(maxLabel);
    self.maxLabel = maxLabel;
    self.maxLabel:setVisible(false)

    --EXP
    local levelSprite = ccui.ImageView:create("common/panel.png");
    levelSprite:setScale9Enabled(true);
    levelSprite:setContentSize(cc.size(70, 38));
    levelSprite:setPosition(cc.p(276, 230));
    bgSprite:addChild(levelSprite);

    local lvLabel = ccui.Text:create("LV.1", "", 22);
    lvLabel:setColor(cc.c3b(255,255,255));
    --lvLabel:setAnchorPoint(cc.p(0,0.5));
    lvLabel:setPosition(cc.p(35, 19));
    levelSprite:addChild(lvLabel);
    self.lvLabel = lvLabel;

    --官衔
    -- local guanxian = ccui.Text:create("村委主任", "", 22);
    -- guanxian:setColor(cc.c3b(255,255,130));
    -- --guanxian:setAnchorPoint(cc.p(0,0.5));
    -- guanxian:setPosition(cc.p(368, 230));
    -- bgSprite:addChild(guanxian);
    -- self.guanxian = guanxian;
    
    self.guanxian = require("show_zjh.popView_Hall.GuanXianLayer").new({exp=0, c3b=cc.c3b(255,255,130)})
    self.guanxian:setPosition(cc.p(368, 230));
    bgSprite:addChild(self.guanxian);

    --exp
    local expPos = cc.p(525, 230);
    local expBgSprite = cc.Sprite:create("hall/personalCenter/exp_background.png");
    expBgSprite:setPosition(expPos);
    bgSprite:addChild(expBgSprite);
    self.expBgSprite = expBgSprite;

    local expNowExp = display.newProgressTimer("hall/personalCenter/exp_now.png", display.PROGRESS_TIMER_BAR);
    expNowExp:align(display.CENTER, expPos.x, expPos.y)
    expNowExp:setMidpoint(cc.p(0, 0.5))
    expNowExp:setBarChangeRate(cc.p(1.0, 0))
    bgSprite:addChild(expNowExp);
    self.expNowExp = expNowExp;

    local expLabel = ccui.Text:create("NA/NA", FONT_ART_TEXT, 20);
    expLabel:setColor(cc.c3b(255, 255, 255));
    expLabel:setPosition(expPos);
    -- expLabel:enableOutline(cc.c3b(12,90,134), 1)
    -- expLabel:enableOutline(cc.c3b(0,0,0), 2)
    bgSprite:addChild(expLabel);
    self.expLabel = expLabel;

    --Sex
    local manLabel = ccui.Text:create("男", FONT_ART_TEXT, 26);
    manLabel:setColor(cc.c3b(255,255,130));
    manLabel:setPosition(cc.p(266, 175));
    bgSprite:addChild(manLabel);

    local select1 = ccui.ImageView:create("common/panel.png");
    select1:setTouchEnabled(true);
    select1:setPosition(cc.p(313, 175));
    bgSprite:addChild(select1);
    select1:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended and self.manSelect:isVisible() == false then
                self:modifySex(1);
                Click();
            end
        end
    )

    local manSelect = ccui.ImageView:create("hall/personalCenter/select.png");
    manSelect:setPosition(cc.p(30, 26));
    select1:addChild(manSelect);
    self.manSelect = manSelect;

    local femaleLabe = ccui.Text:create("女", FONT_ART_TEXT, 26);
    femaleLabe:setColor(cc.c3b(255,255,130));
    femaleLabe:setPosition(cc.p(390, 175));
    bgSprite:addChild(femaleLabe);

    local select2 = ccui.ImageView:create("common/panel.png");
    select2:setTouchEnabled(true);
    select2:setPosition(cc.p(438, 175));
    bgSprite:addChild(select2);
    select2:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended and self.femaleSelect:isVisible() == false then
            self:modifySex(0);
            Click();
        end
    end)

    local femaleSelect = ccui.ImageView:create("hall/personalCenter/select.png");
    femaleSelect:setPosition(cc.p(28, 28));
    select2:addChild(femaleSelect);
    self.femaleSelect = femaleSelect;

    --签名
    local underWriteLabel = ccui.Text:create("签名同步中", "Arial", 24);--"签名同步中", 24, cc.c3b(255,230,100)
    underWriteLabel:setColor(cc.c3b(255,230,100));
    underWriteLabel:setPosition(cc.p(43, 135));
    underWriteLabel:setAnchorPoint(cc.p(0,1))
    bgSprite:addChild(underWriteLabel);
    
    underWriteLabel:setString("个性签名:")
    underWriteLabel:setTextAreaSize(cc.size(548, 60))
    underWriteLabel:ignoreContentAdaptWithSize(false)
    underWriteLabel:setTextHorizontalAlignment(0)
    underWriteLabel:setTextVerticalAlignment(0)
    self.underWriteLabel = underWriteLabel;

    --修改按钮
    local button = ccui.Button:create("common/common_button3.png");
    button:setScale9Enabled(true);
    button:setContentSize(cc.size(162, 63));
    --button:setCapInsets(cc.rect(130, 33, 1, 1));
    --button:setPosition(cc.p(840,56));
    button:setTitleFontName(FONT_ART_TEXT);
    button:setTitleText("修改昵称");
    button:setTitleColor(cc.c3b(255,255,255));
    button:setTitleFontSize(24);
    button:setPressedActionEnabled(true);
    button:getTitleRenderer():enableOutline(COLOR_BTN_GREEN,2)
    button:addTouchEventListener(
        function ( sender,eventType )
            if eventType == ccui.TouchEventType.ended then
                self:showNicknameModify()
            end
        end
        )
    button:setPosition(cc.p(126, 48));
    bgSprite:addChild(button);

    --修改签名
    local button = ccui.Button:create("common/common_button3.png");
    button:setScale9Enabled(true);
    button:setContentSize(cc.size(162, 63));
    --button:setCapInsets(cc.rect(130, 33, 1, 1));
    --button:setPosition(cc.p(840,56));
    button:setTitleFontName(FONT_ART_TEXT);
    button:setTitleText("编辑签名");
    button:setTitleColor(cc.c3b(255,255,255));
    button:setTitleFontSize(24);
    button:setPressedActionEnabled(true);
    button:getTitleRenderer():enableOutline(COLOR_BTN_GREEN,2)
    button:addTouchEventListener(
        function ( sender,eventType )
            if eventType == ccui.TouchEventType.ended then
                self:showUnderWriteModify()
            end
        end
        )
    button:setPosition(cc.p(333, 48));
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
    if inReview == false then
        local button = ccui.Button:create("common/common_button3.png");
        button:setScale9Enabled(true);
        button:setContentSize(cc.size(162, 63));
        button:setTitleFontName(FONT_ART_TEXT);
        button:setTitleText("手机号绑定");
        button:setTitleColor(cc.c4b(255,255,255,255));
        button:setTitleFontSize(24);
        button:setPressedActionEnabled(true);
        button:getTitleRenderer():enableOutline(COLOR_BTN_GREEN,2)
        button:addTouchEventListener(
            function ( sender,eventType )
                if eventType == ccui.TouchEventType.ended then
                    self:mobileBindHandler(sender)
                end
            end
            )
        button:setPosition(cc.p(537, 48));
        bgSprite:addChild(button);
    end
    local exit = ccui.Button:create("common/close.png");
    exit:setPosition(cc.p(630, 440));
    bgSprite:addChild(exit);
    exit:setPressedActionEnabled(true);
    exit:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then

                package.loaded["show_zjh.popView_Hall.PersonalCenterLayer_New"] = nil;
                package.loaded["commonView.HeadView"] = nil;
                self:removeFromParent();

            end
        end
    )

end

function PersonalCenterLayer:mobileBindHandler(sender)
    local mobileBind = require("show_zjh.popView_Hall.MobileBind").new()
    self:addChild(mobileBind,2)
end

function PersonalCenterLayer:setDefaultData()
    
    local userInfo = DataManager:getMyUserInfo();
    -- dump(userInfo, "userInfo")
    if userInfo then

        if userInfo.faceID and type(userInfo.faceID) == "number" then

            -- self.headView:setNewHead(userInfo.faceID,userInfo.tokenID,userInfo.platformFace);
            self.headView:setNewHead(AccountInfo.faceId, AccountInfo.cy_userId, AccountInfo.headFileMD5)
            self.headView:setVipHead(AccountInfo.memberOrder)
        end

        local VIP_LABEL = {
        "绿钻VIP",
        "蓝钻VIP",
        "紫钻VIP",
        "金钻VIP",
        "王冠VIP",
        }
        self.headView:setVipHead(userInfo.memberOrder)
        -- if userInfo:memberOrder() > 0 and userInfo:memberOrder() <=5 then
        --     self.txtVIP:setString(VIP_LABEL[userInfo:memberOrder()])
        -- else
        --     self.txtVIP:setString("普通会员")
        -- end
        self.lvLabel:setString("LV." .. getLevelByExp(userInfo.medal))

        local nickName = FormotGameNickName(userInfo.nickName,5);
        self.nicknameLabel:setString(nickName);

        self.idLabel:setString("ID:" .. userInfo.userID);
        -- self.goldLabel:setString(FormatNumToString(userInfo:beans()));
        self.coinLabel:setString(FormatNumToString(userInfo.score));
        -- self.lqLabel:setString(FormatNumToString(userInfo:getCoupon()));
        self.maxLabel:setString(FormatNumToString(userInfo.score).."金币")
        
        self.lovelinessLabel:setString(FormatNumToString(userInfo.loveLiness))
        
        self.underWriteLabel:setString("个性签名:"..userInfo.signature)
        self.underWriteLabel:setTextAreaSize(cc.size(330,100))
        self.underWriteLabel:ignoreContentAdaptWithSize(false)
        self.underWriteLabel:setTextHorizontalAlignment(0)
        self.underWriteLabel:setTextVerticalAlignment(0)

        local levelInfo = getLevelInfo(userInfo.medal)
        self.expLabel:setString(levelInfo.curNextLevelExp .. "/" .. levelInfo.nextLevelExp);
        self.expNowExp:setPercentage(100*levelInfo.curNextLevelExp/levelInfo.nextLevelExp)
        self.guanxian:refreshGuanXian(levelInfo.curNextLevelExp)
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
    if self.isRequestReturn == true then
        self.isRequestReturn = false;
        local userInfo = DataManager:getMyUserInfo();
        -- UserService:sendModifyUserGender(gender);
        AccountInfo:sendChangeGenderRequest(gender)
    end
end

--修改个性签名
function PersonalCenterLayer:showUnderWriteModify()
    local displaySize = cc.size(DESIGN_WIDTH, DESIGN_HEIGHT);
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

    local userInfo = DataManager:getMyUserInfo();
    local holder = FormotGameNickName(userInfo.signature,20) or "请输入新的签名";
    underWriteField:setPlaceHolder(holder);
    underWriteField:setPlaceholderFontColor(cc.c3b(255,255,255));
    underWriteField:setPlaceholderFontSize(24);
    underWriteField:setMaxLength(20);
    underWriteField:addTo(editSprite)

    underWriteField:setText(FormotGameNickName(userInfo.signature,20));

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

function PersonalCenterLayer:showNicknameModify()


    local displaySize = cc.size(DESIGN_WIDTH, DESIGN_HEIGHT);
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
    bgSprite:setContentSize(cc.size(450, 250));
    bgSprite:setPosition(cc.p(displaySize.width / 2, displaySize.height / 2));
    bgSprite:addTo(newLayer);

    --昵称
    local editSprite = ccui.ImageView:create("common/edit_bg1.png");
    editSprite:setScale9Enabled(true);
    editSprite:setContentSize(cc.size(250, 55));
    editSprite:setPosition(cc.p(495, 380));
    editSprite:addTo(newLayer);

    local editLabel = ccui.Text:create("昵称:", FONT_ART_TEXT, 24);
    editLabel:setColor(cc.c3b(255,255,130));
    editLabel:setPosition(cc.p(420, 380));
    newLayer:addChild(editLabel);

    local nicknameField = ccui.EditBox:create(cc.size(250, 38), "blank.png");
    nicknameField:setAnchorPoint(cc.p(0,0.5));
    nicknameField:setPosition(cc.p(450, 380));
    nicknameField:setFontSize(24);
    local userInfo = DataManager:getMyUserInfo();
    local holder = FormotGameNickName(userInfo.nickName,5) or "请输入新的昵称";
    nicknameField:setPlaceHolder(holder);
    nicknameField:setPlaceholderFontColor(cc.c3b(255,255,255));
    nicknameField:setPlaceholderFontSize(24);
    nicknameField:setMaxLength(30);
    nicknameField:addTo(newLayer)

    nicknameField:setText(userInfo.nickName);

    local tipLabel = ccui.Text:create("修改昵称要消耗50万筹码", "Arial", 24);
    tipLabel:setColor(cc.c3b(255,255,130));
    tipLabel:setAnchorPoint(cc.p(0.0,0.5));
    tipLabel:setPosition(cc.p(393, 320));
    newLayer:addChild(tipLabel);


    --提交按钮
    local button = ccui.Button:create("common/common_button3.png");
    button:setScale9Enabled(true);
    button:setContentSize(cc.size(150, 67));
    --button:setCapInsets(cc.rect(130, 33, 1, 1));
    button:setPosition(cc.p(650,250));
    button:setTitleFontName(FONT_ART_TEXT);
    button:setTitleText("提交");
    button:setTitleColor(cc.c3b(255,255,255));
    button:setTitleFontSize(30);
    button:setPressedActionEnabled(true);
    button:getTitleRenderer():enableOutline(COLOR_BTN_GREEN,2)
    button:addTouchEventListener(
        function ( sender,eventType )
            if eventType == ccui.TouchEventType.ended then
                local newName = nicknameField:getText();
                -- if newName == "@EVILBOY" then
                --     EVILBOY = true
                --     return
                -- end
                if string.len(newName) > 0 then

                    if stringContainsEmoji(newName) == true then
                        Hall.showTips("字符中不能含有表情符号", 2.5)
                    else
                        AccountInfo:sendChangeNickNameRequest(newName, false)
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
    exit:setPosition(cc.p(773,433));
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
    if device.platform ~= "ios" then
        local layer = require("commonView.CustomAvatarLayer").new():addTo(self)
    else
        local layer = require("commonView.CustomAvatarLayer").new():addTo(self)
    end

end

return PersonalCenterLayer