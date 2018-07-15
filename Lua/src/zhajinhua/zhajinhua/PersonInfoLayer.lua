-- 设置个人信息窗
-- Author: zx
-- Date: 2015-04-08 20:57:59

local PersonInfoLayer = class("PersonInfoLayer", function() return display.newLayer() end)

function PersonInfoLayer:ctor(userinfo)

    self.userinfo = userinfo
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    self:setNodeEventEnabled(true)
    
    self:createUI();
    self:setDefaultData()
end

function PersonInfoLayer:onEnter()

end

function PersonInfoLayer:onExit()

end

function PersonInfoLayer:createUI()

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


    local bgSprite = ccui.ImageView:create("view/frame3.png");
    bgSprite:setScale9Enabled(true);
    bgSprite:setContentSize(cc.size(595, 366));
    bgSprite:setPosition(cc.p(displaySize.width / 2, displaySize.height / 2));
    self:addChild(bgSprite);

    local panel2 = ccui.ImageView:create("common/panel2.png");
    panel2:setScale9Enabled(true);
    panel2:setContentSize(cc.size(176, 275));
    panel2:setPosition(cc.p(105, 180));
    bgSprite:addChild(panel2);

    local headView = require("commonView.HeadView").new(1);
    -- headView:setModifyMode(function (headIndex)
    --     print("setModifyMode",headIndex);
    --     self:modifyHeadModify(headIndex);
    -- end);
    headView:setPosition(cc.p(88, 195));
    panel2:addChild(headView);
    self.headView = headView;
    self:performWithDelay(function ( )
        local myInfo = self.userinfo--DataManager:getMyUserInfo()
        -- print("**myInfo.faceID",myInfo.faceID, myInfo.platformID, myInfo.platformFace)
        self.headView:setNewHead(myInfo.faceID, myInfo.platformID, myInfo.platformFace)        
        self.headView:setVipHead(myInfo.memberOrder)
    end, 0.5)
    --昵称
    local nicknameLabel = ccui.Text:create("昵称同步中", "Arial", 24);--"昵称同步中", 24, cc.c3b(255,230,100)
    nicknameLabel:setColor(cc.c3b(255,230,100));
    nicknameLabel:setPosition(cc.p(88, 100));
    panel2:addChild(nicknameLabel);
    self.nicknameLabel = nicknameLabel;

    --性别
    local idLabel = ccui.Text:create("性别:", "Arial", 24);
    idLabel:setColor(cc.c3b(255,230,100));
    idLabel:setAnchorPoint(cc.p(0,0.5));
    idLabel:setPosition(cc.p(33, 50));
    panel2:addChild(idLabel);

	local seximg = ccui.ImageView:create("common/sex1.png");
    seximg:setPosition(cc.p(118, 50));
    panel2:addChild(seximg);
    self.seximg = seximg


    --gold
    local coinImage = ccui.ImageView:create();
    coinImage:loadTexture("hall/room/chouma_icon.png");
    coinImage:setPosition(cc.p(230, 305));
    coinImage:scale(0.8)
    bgSprite:addChild(coinImage)

    local coinLabel = display.newTTFLabel({text = "3950万",
                                size = 22,
                                color = cc.c3b(255,255,128),
                                --align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                            })
                :align(display.LEFT_CENTER, 257, 305)
                :addTo(bgSprite)
    self.coinLabel = coinLabel;


    --魅力
    local lovelinessImage = ccui.ImageView:create();
    lovelinessImage:loadTexture("common/loveliness.png");
    lovelinessImage:setPosition(cc.p(390, 305));
    -- lovelinessImage:scale(0.8)
    bgSprite:addChild(lovelinessImage)

    local lovelinessLabel = display.newTTFLabel({text = "999",
                                size = 22,
                                color = cc.c3b(255,255,128),
                                --align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                            })
                :align(display.LEFT_CENTER, 415, 305)
                :addTo(bgSprite)
    self.lovelinessLabel = lovelinessLabel;


    --历史最高金额
    local temjine = ccui.Text:create("历史最高金额:", "Arial", 24);--"昵称同步中", 24, cc.c3b(255,230,100)
    temjine:setColor(cc.c3b(255,230,100));
    temjine:setPosition(cc.p(283, 254));
    bgSprite:addChild(temjine);

    local histopgold = display.newTTFLabel({text = "999",
                                size = 22,
                                color = cc.c3b(255,255,128),
                                --align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                            })
                :align(display.LEFT_CENTER, 380, 254)
                :addTo(bgSprite)
    self.histopgold = histopgold;


    --level
    local lvLabel = ccui.Text:create("LV.1", "", 22);
    lvLabel:setColor(cc.c3b(255,255,255));
    lvLabel:setAnchorPoint(cc.p(0,0.5));
    lvLabel:setPosition(cc.p(211, 213));
    bgSprite:addChild(lvLabel);
    self.lvLabel = lvLabel;

    --官衔
    self.guanxian = require("hall.GuanXianLayer").new({exp=0, c3b=cc.c3b(255,255,130)})
    self.guanxian:setPosition(cc.p(320, 213));
    bgSprite:addChild(self.guanxian);
    --exp
    local expPos = cc.p(485, 213);
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

    local expLabel = ccui.Text:create("NA/NA", "Arial", 20);
    expLabel:setColor(cc.c3b(255, 255, 255));
    expLabel:setPosition(expPos);
    expLabel:enableOutline(cc.c3b(12,90,134), 2)
    bgSprite:addChild(expLabel);
    self.expLabel = expLabel;

    --签名
    local underWriteLabel = ccui.Text:create("个性签名:", "Arial", 24);--"签名同步中", 24, cc.c3b(255,230,100)
    underWriteLabel:setColor(cc.c3b(255,230,100));
    underWriteLabel:setPosition(cc.p(211, 185));
    underWriteLabel:setAnchorPoint(cc.p(0,1))
    bgSprite:addChild(underWriteLabel);
    
    underWriteLabel:setTextAreaSize(cc.size(270, 80))
    underWriteLabel:ignoreContentAdaptWithSize(false)
    underWriteLabel:setTextHorizontalAlignment(0)
    underWriteLabel:setTextVerticalAlignment(0)
    self.underWriteLabel = underWriteLabel;

    --修改签名
    local button = ccui.Button:create("common/common_button3.png");
    button:setScale9Enabled(true);
    button:setContentSize(cc.size(162, 63));
    --button:setCapInsets(cc.rect(130, 33, 1, 1));
    --button:setPosition(cc.p(840,56));
    button:setTitleFontName(FONT_ART_TEXT);
    button:setTitleText("踢人");
    button:setTitleColor(cc.c3b(255,255,255));
    button:setTitleFontSize(24);
    button:setPressedActionEnabled(true);
    button:getTitleRenderer():enableOutline(COLOR_BTN_GREEN,2)
    button:addTouchEventListener(
        function ( sender,eventType )
            if eventType == ccui.TouchEventType.ended then
                TableInfo:sendKickUserRequest(self.userinfo.chairID)
            end
        end
        )
    button:setPosition(cc.p(385, 60));
    bgSprite:addChild(button);
    local myinfo = DataManager:getMyUserInfo()
    if myinfo.userID == self.userinfo.userID then
    	button:setEnabled(false)
        button:hide()
    end


    local exit = ccui.Button:create("common/close2.png");
    exit:setPosition(cc.p(590, 360));
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

function PersonInfoLayer:mobileBindHandler(sender)
    local mobileBind = require("hall.MobileBind").new()
    self:addChild(mobileBind,2)
end

function PersonInfoLayer:setDefaultData()
    
    local userInfo = self.userinfo

    if userInfo then

        if userInfo.faceID and type(userInfo.faceID) == "number" then

            self.headView:setNewHead(userInfo.faceID, userInfo.tokenId, userInfo.headFileMD5);
            
        end

        self.lvLabel:setString("LV." .. getLevelByExp(userInfo.medal))

        local nickName = FormotGameNickName(userInfo.nickName,5);
        self.nicknameLabel:setString(nickName);

        if userInfo.gender == 1 then
            self.seximg:loadTexture("common/sex1.png")
        else
            self.seximg:loadTexture("common/sex0.png")
        end
 
        self.coinLabel:setString(FormatNumToString(userInfo.score))
        self.histopgold:setString(FormatNumToString(userInfo.score))--最高金额，服务端没传
        self.lovelinessLabel:setString(FormatNumToString(userInfo.loveLiness))
        
        self.underWriteLabel:setString("个性签名:"..(userInfo.signature or ""))
        self.underWriteLabel:setTextAreaSize(cc.size(270, 80))
        self.underWriteLabel:ignoreContentAdaptWithSize(false)
        self.underWriteLabel:setTextHorizontalAlignment(0)
        self.underWriteLabel:setTextVerticalAlignment(0)

        local levelInfo = getLevelInfo(userInfo.medal)
        self.expLabel:setString(levelInfo.curNextLevelExp .. "/" .. levelInfo.nextLevelExp);
        self.expNowExp:setPercentage(100*levelInfo.curNextLevelExp/levelInfo.nextLevelExp)
        self.guanxian:refreshGuanXian(levelInfo.curNextLevelExp)
    end

end


function PersonInfoLayer:kickPerson()

    
end

return PersonInfoLayer