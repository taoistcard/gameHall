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
    -- self.bindIds[#self.bindIds + 1] = BindTool.bind(AccountInfo, "score", handler(self, self.bankSucceseHandler))
    self.bindIds[#self.bindIds + 1] = BindTool.bind(AccountInfo, "nickName", handler(self, self.queryBackHandler))
    self.bindIds[#self.bindIds + 1] = BindTool.bind(AccountInfo, "insure", handler(self, self.queryBackHandler))
    self.bindIds[#self.bindIds + 1] = BindTool.bind(AccountInfo, "faceID", handler(self, self.queryBackHandler))
    self.bindIds[#self.bindIds + 1] = BindTool.bind(AccountInfo, "gender", handler(self, self.queryBackHandler))
    self.bindIds[#self.bindIds + 1] = BindTool.bind(AccountInfo, "underwrite", handler(self, self.queryBackHandler))
    self.head_handler = HallEvent:addEventListener(HallEvent.AVATAR_UPLOAD_SUCCESS,handler(self, self.customFaceUploadBackHandler))
    BankInfo:sendQueryRequest()
end
function PersonalCenterLayer:queryHandler()

    
    UserService:sendQueryInsureInfo()

end
function PersonalCenterLayer:onExit()
    for _, bindid in ipairs(self.bindIds) do
        BindTool.unbind(bindid)
    end
    HallEvent:removeEventListener(self.head_handler)
end
    
--查询成功
function PersonalCenterLayer:queryBackHandler(event)
    self:setDefaultData()
    self.bankboxLabel:setString(FormatNumToString(AccountInfo.insure))

end
--上传头像成功回调 
function PersonalCenterLayer:customFaceUploadBackHandler(event)
    -- body
    local tokenID = event.tokenID
    local md5 = event.md5
    self.headView:setNewHead(999,tokenID,md5)
end

function PersonalCenterLayer:onUserInfoChanged(event)

    if event.subId == CMD_LogonServer.SUB_GP_OPERATE_SUCCESS then--操作成功
        self:setDefaultData();
        local operateSuccess = protocol.hall.userInfo_pb.CMD_GP_OperateSuccess_Pro()
        operateSuccess:ParseFromString(event.data)
        Hall.showTips(operateSuccess.szDescribeString,1.0)
        
    elseif event.subId == CMD_LogonServer.SUB_GP_OPERATE_FAILURE then
        self:setDefaultData();
        local operateFailure = protocol.hall.userInfo_pb.CMD_GP_OperateFailure_Pro()
        operateFailure:ParseFromString(event.data)
        Hall.showTips(operateFailure.szDescribeString,1.0)
        
    elseif event.subId == CMD_LogonServer.SUB_GP_USER_FACE_INFO then --头像修改成功
        self:setDefaultData();
        Hall.showTips("修改成功！", 1.0)
        
    end
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


    local bgSprite = ccui.ImageView:create("hall_frame_bg.png");
    bgSprite:setScale9Enabled(true);
    bgSprite:setContentSize(cc.size(717, 402));
    bgSprite:setPosition(cc.p(displaySize.width / 2, displaySize.height / 2));
    self:addChild(bgSprite);

    local panel = ccui.ImageView:create("hall_frame.png");
    panel:setScale9Enabled(true);
    panel:setContentSize(cc.size(671, 291));
    panel:setPosition(cc.p(displaySize.width / 2, displaySize.height / 2 +20));
    self:addChild(panel);

    local titleSprite = cc.Sprite:create("common/hall_title_bg.png");
    titleSprite:setPosition(cc.p(580, 515));
    self:addChild(titleSprite,2);

    local pcWord = ccui.ImageView:create("hallScene/personalCenter/pcWord.png");
    pcWord:setPosition(214, 55);
    titleSprite:addChild(pcWord);

    -- local title = ccui.Text:create("个", FONT_ART_TEXT, 24)
    -- title:setPosition(cc.p(30,68))
    -- title:setTextColor(cc.c4b(251,248,142,255))
    -- title:enableOutline(cc.c4b(137,0,167,200), 3)
    -- title:addTo(titleSprite)

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


    local panel2 = ccui.ImageView:create("hallScene/personalCenter/splitLine.png");
    panel2:setScale9Enabled(true);
    panel2:setContentSize(cc.size(3, 270));
    panel2:setPosition(465,335);
    self:addChild(panel2);



   local headView = require("show_ddz.HeadView").new(1);
   headView:setModifyMode(function (headIndex)
       print("setModifyMode",headIndex);
       self:modifyHeadModify(headIndex);
   end);
   headView:setPosition(cc.p(112, 202));
   panel:addChild(headView);
   self.headView = headView;

    --昵称
    local nicknameLabel = ccui.Text:create("昵称同步中", "fonts/HKBDTW12.TTF", 24);--"昵称同步中", 24, cc.c3b(255,230,100)
    nicknameLabel:setColor(cc.c3b(255,230,100));
    nicknameLabel:setPosition(cc.p(112, 130));
    panel:addChild(nicknameLabel);
    self.nicknameLabel = nicknameLabel;

    --ID
    local idLabel = ccui.Text:create("ID同步中", "fonts/HKBDTW12.TTF", 24);
    idLabel:setColor(cc.c3b(255,230,100));
    idLabel:setPosition(cc.p(112, 100));
    panel:addChild(idLabel);
    self.idLabel = idLabel;

    --自定义头像
    local button = ccui.Button:create("hallScene/personalCenter/customHead.png","hallScene/personalCenter/customHead.png","hallScene/personalCenter/customHead.png");
    -- button:setScale9Enabled(true);
    -- button:setContentSize(cc.size(170, 65));
    -- button:setTitleFontName(FONT_ART_BUTTON);
    -- button:setTitleText("自定义头像");
    -- button:setTitleColor(cc.c3b(255,255,255));
    -- button:setTitleFontSize(22);
    button:setPressedActionEnabled(true);
    -- button:getTitleRenderer():enableOutline(COLOR_BTN_BLUE,2);
    button:addTouchEventListener(
        function ( sender,eventType )
            if eventType == ccui.TouchEventType.ended then
                self:setCustiomHead()
                onUmengEvent("1041")
            end
        end
        )
    button:addTo(panel)
    button:setPosition(cc.p(112, 50))

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
    coinImage:loadTexture("hallScene/hall_gold.png");
    coinImage:setPosition(cc.p(280, 255));
    -- coinImage:scale(0.8)
    panel:addChild(coinImage)

    local coinLabel = display.newTTFLabel({text = "",
                                size = 22,
                                color = cc.c3b(255,255,128),
                                --align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                            })
                :align(display.LEFT_CENTER, 303, 255)
                :addTo(panel)
    self.coinLabel = coinLabel;
    --保险箱
    local bankboxImage = ccui.ImageView:create();
    bankboxImage:loadTexture("hallScene/hall_bankbox.png");
    bankboxImage:setPosition(cc.p(420, 255));
    -- bankboxImage:scale(0.8)
    panel:addChild(bankboxImage)

    local bankboxLabel = display.newTTFLabel({text = "",
                                size = 22,
                                color = cc.c3b(255,255,128),
                                --align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                            })
                :align(display.LEFT_CENTER, 440, 255)
                :addTo(panel)
    self.bankboxLabel = bankboxLabel;
    
    if OnlineConfig_review == "on" then
        bankboxImage:hide()
        self.bankboxLabel:hide()
    end

    --魅力
    local lovelinessImage = ccui.ImageView:create();
    lovelinessImage:loadTexture("hallScene/hall_loveliness.png");
    lovelinessImage:setPosition(cc.p(555, 255));
    -- lovelinessImage:scale(0.8)
    panel:addChild(lovelinessImage)

    local lovelinessLabel = display.newTTFLabel({text = "999",
                                size = 22,
                                color = cc.c3b(255,255,128),
                                --align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                            })
                :align(display.LEFT_CENTER, 575, 255)
                :addTo(panel)
    self.lovelinessLabel = lovelinessLabel;
    --礼券
    local lqImage = ccui.ImageView:create();
    lqImage:loadTexture("hallScene/hall_coupon.png");
    lqImage:setPosition(cc.p(280, 212));
    -- lqImage:scale(0.8)
    panel:addChild(lqImage)

    local coinLabel = display.newTTFLabel({text = "999",
                                size = 22,
                                color = cc.c3b(255,255,128),
                                --align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                            })
                :align(display.LEFT_CENTER, 303, 215)
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
    local maxLabel = ccui.Text:create("最高金额:", "fonts/HKBDTW12.TTF", 26);
    maxLabel:setColor(cc.c3b(255,255,130));
    maxLabel:setAnchorPoint(cc.p(0,0.5));
    maxLabel:setPosition(cc.p(270, 175));
    panel:addChild(maxLabel);

    local maxLabel = ccui.Text:create("即将来到", "fonts/HKBDTW12.TTF", 26);
    maxLabel:setColor(cc.c3b(255,255,130));
    maxLabel:setAnchorPoint(cc.p(0,0.5));
    maxLabel:setPosition(cc.p(380, 175));
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
    local levelSprite = display.newScale9Sprite("hallScene/personalCenter/level_bg.png", 0, 0, cc.size(60, 28))
    levelSprite:setPosition(cc.p(300, 135));
    panel:addChild(levelSprite);

    local lvLabel = ccui.Text:create("LV.1", "", 24);
    lvLabel:setColor(cc.c3b(255,255,255));
    --lvLabel:setAnchorPoint(cc.p(0,0.5));
    lvLabel:setPosition(cc.p(300, 135));
    panel:addChild(lvLabel);
    self.lvLabel = lvLabel;

    --exp
    local expPos = cc.p(495, 135);
    local expBgSprite = ccui.ImageView:create("hallScene/personalCenter/exp_background.png");
    expBgSprite:setScale9Enabled(true);
    expBgSprite:setContentSize(cc.size(282, 29));
    -- local expBgSprite = cc.Sprite:create("hallScene/personalCenter/exp_background.png");
    expBgSprite:setPosition(expPos);
    panel:addChild(expBgSprite);
    self.expBgSprite = expBgSprite;

    local expNowExp = display.newProgressTimer("hallScene/personalCenter/exp_now.png", display.PROGRESS_TIMER_BAR);
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
    local manLabel = ccui.Text:create("男", "fonts/HKBDTW12.TTF", 26);
    manLabel:setColor(cc.c3b(255,255,130));
    manLabel:setPosition(cc.p(285, 90));
    panel:addChild(manLabel);

    local select1 = ccui.ImageView:create("hallScene/personalCenter/selectBg.png");
    select1:setTouchEnabled(true);
    select1:setPosition(cc.p(325, 90));
    panel:addChild(select1);
    select1:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended and self.manSelect:isVisible() == false then
                self:modifySex(1);
                Click();
            end
        end
    )

    local manSelect = ccui.ImageView:create("hallScene/personalCenter/select.png");
    manSelect:setPosition(cc.p(325, 90));
    panel:addChild(manSelect);
    self.manSelect = manSelect;

    local femaleLabe = ccui.Text:create("女", "fonts/HKBDTW12.TTF", 26);
    femaleLabe:setColor(cc.c3b(255,255,130));
    femaleLabe:setPosition(cc.p(400, 90));
    panel:addChild(femaleLabe);

    local select2 = ccui.ImageView:create("hallScene/personalCenter/selectBg.png");
    select2:setTouchEnabled(true);
    select2:setPosition(cc.p(440, 90));
    panel:addChild(select2);
    select2:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended and self.femaleSelect:isVisible() == false then
            self:modifySex(0);
            Click();
        end
    end)

    local femaleSelect = ccui.ImageView:create("hallScene/personalCenter/select.png");
    femaleSelect:setPosition(cc.p(440, 90));
    panel:addChild(femaleSelect);
    self.femaleSelect = femaleSelect;

    --签名
    local underWriteLabel = ccui.Text:create("签名同步中", "fonts/HKBDTW12.TTF", 24);--"签名同步中", 24, cc.c3b(255,230,100)
    underWriteLabel:setColor(cc.c3b(255,230,100));
    underWriteLabel:setPosition(cc.p(270, 60));
    underWriteLabel:setAnchorPoint(cc.p(0,1))
    panel:addChild(underWriteLabel);
    
    underWriteLabel:setString("个性签名:")
    underWriteLabel:setTextAreaSize(cc.size(350,100))
    underWriteLabel:ignoreContentAdaptWithSize(false)
    underWriteLabel:setTextHorizontalAlignment(0)
    underWriteLabel:setTextVerticalAlignment(0)
    self.underWriteLabel = underWriteLabel;
    --修改按钮
    local button = ccui.Button:create("hallScene/personalCenter/modifyNickname.png");
    -- button:setScale9Enabled(true);
    -- button:setContentSize(cc.size(220, 67));
    --button:setCapInsets(cc.rect(130, 33, 1, 1));
    --button:setPosition(cc.p(840,56));
    -- button:setTitleFontName(FONT_ART_BUTTON);
    -- button:setTitleText("修改昵称");
    -- button:setTitleColor(cc.c3b(255,255,255));
    -- button:setTitleFontSize(30);
    -- button:setPressedActionEnabled(true);
    -- button:getTitleRenderer():enableOutline(COLOR_BTN_GREEN,2)
    button:addTouchEventListener(
        function ( sender,eventType )
            if eventType == ccui.TouchEventType.ended then
                self:showNicknameModify()
                onUmengEvent("1042")
            end
        end
        )
    button:setPosition(cc.p(150,38));
    bgSprite:addChild(button);
    --修改签名

    local button = ccui.Button:create("hallScene/personalCenter/editUnderwrite.png");
    -- button:setScale9Enabled(true);
    -- button:setContentSize(cc.size(220, 67));
    --button:setCapInsets(cc.rect(130, 33, 1, 1));
    --button:setPosition(cc.p(840,56));
    -- button:setTitleFontName(FONT_ART_BUTTON);
    -- button:setTitleText("编辑签名");
    -- button:setTitleColor(cc.c3b(255,255,255));
    -- button:setTitleFontSize(30);
    -- button:setPressedActionEnabled(true);
    -- button:getTitleRenderer():enableOutline(COLOR_BTN_GREEN,2)
    button:addTouchEventListener(
        function ( sender,eventType )
            if eventType == ccui.TouchEventType.ended then
                self:showUnderWriteModify()
            end
        end
        )
    button:setPosition(cc.p(368,38));
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

    local button = ccui.Button:create("hallScene/personalCenter/bindPhone.png");
    -- button:setScale9Enabled(true);
    -- button:setContentSize(cc.size(220, 67));
    -- button:setTitleFontName(FONT_ART_BUTTON);
    -- button:setTitleText("手机号绑定");
    -- button:setTitleColor(cc.c4b(255,255,255,255));
    -- button:setTitleFontSize(30);
    -- button:setPressedActionEnabled(true);
    -- button:getTitleRenderer():enableOutline(COLOR_BTN_GREEN,2)
    button:addTouchEventListener(
        function ( sender,eventType )
            if eventType == ccui.TouchEventType.ended then
                self:mobileBindHandler(sender)
            end
        end
        )
    button:setPosition(cc.p(575,38));
    bgSprite:addChild(button);

    local exit = ccui.Button:create("hall_close.png");
    exit:setPosition(cc.p(700,390));
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
    local mobileBind = require("show_ddz.MobileBind").new()
    self:addChild(mobileBind,2)
end
function PersonalCenterLayer:setDefaultData()
   
    local userInfo = DataManager:getMyUserInfo();
    if userInfo then

        print("===personalCenterLayer====", userInfo.faceID, userInfo.platformID, userInfo.platformFace)
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

        local levelInfo = getLevelInfo(userInfo.experience)
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

    local bgSprite = ccui.ImageView:create("hallScene/personalCenter/underWriteBg.png");
    bgSprite:setScale9Enabled(true);
    bgSprite:setContentSize(cc.size(450+200, 250+50));
    bgSprite:setPosition(cc.p(displaySize.width / 2, displaySize.height / 2));
    bgSprite:addTo(newLayer);



    --个性签名
    local editSprite = ccui.ImageView:create("hallScene/personalCenter/edit_bg.png");
    editSprite:setScale9Enabled(true);
    editSprite:setContentSize(cc.size(550, 125));
    editSprite:setPosition(cc.p(565, 350));
    editSprite:addTo(newLayer);

    -- local editLabel = ccui.Text:create("个性签名:", "Arial", 26);
    -- editLabel:setColor(cc.c3b(255,255,130));
    -- editLabel:setPosition(cc.p(420, 380));
    -- newLayer:addChild(editLabel);

    local underWriteField = ccui.EditBox:create(cc.size(530, 36), "blank.png");
    underWriteField:setAnchorPoint(cc.p(0.5,0.5));
    underWriteField:setPosition(cc.p(565, 346));
    underWriteField:setFont("", 20);

    local userInfo = DataManager:getMyUserInfo();
    local holder = FormotGameNickName(userInfo.signature,20) or "请输入新的签名";
    underWriteField:setPlaceHolder(holder);
    underWriteField:setPlaceholderFontColor(cc.c3b(255,255,255));
    underWriteField:setPlaceholderFontSize(24);
    underWriteField:setMaxLength(20);
    underWriteField:addTo(newLayer)

    underWriteField:setText(FormotGameNickName(userInfo.signature,20));
    underWriteField:setFontSize(20);

    local tipLabel = ccui.Text:create("字数限制20个汉字", "fonts/HKBDTW12.TTF", 16);
    tipLabel:setColor(cc.c3b(128,65,19));
    tipLabel:setAnchorPoint(cc.p(0.0,0.5));
    tipLabel:setPosition(cc.p(300, 270));
    newLayer:addChild(tipLabel);

    --提交按钮
    local button = ccui.Button:create("hallScene/personalCenter/submit.png");
    -- button:setScale9Enabled(true);
    -- button:setContentSize(cc.size(150, 67));
    -- --button:setCapInsets(cc.rect(130, 33, 1, 1));
    button:setPosition(cc.p(580,220));
    -- button:setTitleFontName(FONT_ART_BUTTON);
    -- button:setTitleText("提交");
    -- button:setTitleColor(cc.c3b(255,255,255));
    -- button:setTitleFontSize(30);
    -- button:setPressedActionEnabled(true);
    -- button:getTitleRenderer():enableOutline(COLOR_BTN_GREEN,2)
    button:addTouchEventListener(
        function ( sender,eventType )
            if eventType == ccui.TouchEventType.ended then
                local newUnderWrite = underWriteField:getText();
                if string.len(newUnderWrite) > 0 then

                    AccountInfo:sendChangeSignatureRequest(newUnderWrite)
                    newLayer:removeFromParent();
                else
                    Hall.showTips("请输入个性签名！")
                end

                Click()
            end
        end
        )
    newLayer:addChild(button);

    --关闭按钮
    local exit = ccui.Button:create("hall_close.png");
    exit:setPosition(cc.p(780+100,460));
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
function PersonalCenterLayer:modifyUnderWrite(newUnderWrite)
    local userInfo = DataManager:getMyUserInfo();

    UserService:sendModifyUserInfoWithUnderWrite(userInfo:gender(), userInfo.nickName, userInfo.mobilePhoneNumber, newUnderWrite, false);

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

    local bgSprite = ccui.ImageView:create("hallScene/personalCenter/underWriteBg.png");
    bgSprite:setScale9Enabled(true);
    bgSprite:setContentSize(cc.size(558, 261));
    bgSprite:setPosition(cc.p(displaySize.width / 2, displaySize.height / 2));
    bgSprite:addTo(newLayer);



    --昵称
    local editSprite = ccui.ImageView:create("hallScene/personalCenter/edit_bg.png");
    editSprite:setScale9Enabled(true);
    editSprite:setContentSize(cc.size(290, 55));
    editSprite:setPosition(cc.p(495, 380));
    editSprite:addTo(newLayer);

    local editLabel = ccui.Text:create("昵称:", "Arial", 26);
    editLabel:setColor(cc.c3b(255,255,130));
    editLabel:setPosition(cc.p(400, 380));
    newLayer:addChild(editLabel);

    local nicknameField = ccui.EditBox:create(cc.size(200, 38), "blank.png");
    nicknameField:setAnchorPoint(cc.p(0,0.5));
    nicknameField:setPosition(cc.p(430, 376));
    nicknameField:setFontSize(10);

    local userInfo = DataManager:getMyUserInfo();
    local holder = FormotGameNickName(userInfo.nickName,5) or "请输入新的昵称";
    nicknameField:setPlaceHolder(holder);
    nicknameField:setPlaceholderFontColor(cc.c3b(255,255,255));
    nicknameField:setPlaceholderFontSize(24);
    nicknameField:setMaxLength(10);
    nicknameField:addTo(newLayer)

    nicknameField:setText(userInfo.nickName);

    local shaizi = ccui.Button:create("hallScene/personalCenter/shaizi.png");
    shaizi:hide()
    shaizi:setPosition(cc.p(680,376));
    shaizi:setPressedActionEnabled(true);
    shaizi:addTouchEventListener(
        function ( sender,eventType )
            if eventType == ccui.TouchEventType.ended then
                

                Click();            
            end
        end
        )
    newLayer:addChild(shaizi);
    -- local tipLabel = ccui.Text:create("修改昵称需要50万金币.", "Arial", 26);
    -- tipLabel:setColor(cc.c3b(255,255,130));
    -- tipLabel:setAnchorPoint(cc.p(0.0,0.5));
    -- tipLabel:setPosition(cc.p(360, 320));
    -- newLayer:addChild(tipLabel);


    --提交按钮
    local button = ccui.Button:create("hallScene/personalCenter/submit.png");
    -- button:setScale9Enabled(true);
    -- button:setContentSize(cc.size(150, 67));
    -- --button:setCapInsets(cc.rect(130, 33, 1, 1));
    button:setPosition(cc.p(580,250));
    -- button:setTitleFontName(FONT_ART_BUTTON);
    -- button:setTitleText("提交");
    -- button:setTitleColor(cc.c3b(255,255,255));
    -- button:setTitleFontSize(30);
    -- button:setPressedActionEnabled(true);
    -- button:getTitleRenderer():enableOutline(COLOR_BTN_GREEN,2)
    button:addTouchEventListener(
        function ( sender,eventType )
            if eventType == ccui.TouchEventType.ended then
                local newName = nicknameField:getText();
                if string.len(newName) > 0 then

                    AccountInfo:sendChangeNickNameRequest(newName, false)
                    newLayer:removeFromParent();
                else
                    Hall.showTips("请输入昵称！")
                end

                Click();            
            end
        end
        )
    newLayer:addChild(button);

    --关闭按钮
    local exit = ccui.Button:create("hall_close.png");
    exit:setPosition(cc.p(820,440));
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
        local layer = require("show_ddz.CustomAvatarLayer").new():addTo(self)
    else
        local layer = require("show_ddz.CustomAvatarLayer").new():addTo(self)
    end
    

end

return PersonalCenterLayer