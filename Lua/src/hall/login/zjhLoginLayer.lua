local zjhLoginLayer = class("zjhLoginLayer", function() return display.newLayer(); end );
local setReview = true
function zjhLoginLayer:scene()

    local scene = display.newScene("LoginScene");
    scene:addChild(self);
    self.scene = scene;

    if HallConnection.isConnected then
        HallConnection:closeConnect();
    end

    local connectHost = ServerHost
    if string.len(ServerHostBackUp) > 0 then
        connectHost = ServerHostBackUp
    end
    HallConnection:connectServer(connectHost, ServerPort);

    return scene;
end
function zjhLoginLayer:onEnter()
    self.bindIds = {}
    self.bindIds[#self.bindIds + 1] = BindTool.bind(ServerInfo, "nodeItemList", handler(self, self.loginSuccess))
end
function zjhLoginLayer:onExit()
    for _, bindid in ipairs(self.bindIds) do
        BindTool.unbind(bindid)
    end
end
function zjhLoginLayer:loginSuccess()
    print("zjhLoginLayer:loginSuccess")
    Hall:continue()
end
function zjhLoginLayer:ctor(loginBusiness)
    -- OnlineConfig_review = "off"
    BindMobilePhone = cc.UserDefault:getInstance():getBoolForKey("isBindMobile", false)
    BindMobilePhone = true
    print("******************",BindMobilePhone,"OnlineConfig_review",OnlineConfig_review)
    self.clickTimes = 0
    self.clickChannelTimes = 0
    self:setNodeEventEnabled(true)
    -- local loginBusiness = require("login.loginBusiness");
    self.business = loginBusiness;

    self:setNodeEventEnabled(true);

    self:createUI()
    -- local winSize = cc.Director:getInstance():getWinSize();

    -- local backgroundSprite = cc.Sprite:create("login/login_background.jpg");
    -- backgroundSprite:setPosition(getSrcreeCenter());
    -- self:addChild(backgroundSprite);


    -- if NO_LOGIN == true then
        
    --     local btn = ccui.Button:create("login/btn_accountLogin.png");
    --     btn:setTitleText("开始游戏");
    --     btn:setTitleFontSize(30);
    --     btn:setScale9Enabled(true);
    --     -- btn:setContentSize(cc.size(300, 80));
    --     btn:setPosition(cc.p(winSize.width / 2 + 95, 200));
    --     self:addChild(btn);
    --     btn:onClick(function()
    --         self.business:guestLogin();
    --     end);

    -- else

    --     local btn = ccui.Button:create("login/btn_guestLogin.png");
    --     btn:setPosition(cc.p(winSize.width / 2 - 185, 200));
    --     self:addChild(btn);
    --     btn:onClick(function()
    --         Hall.nLoginType = 1 --账号密码登陆时Hall.nLoginType = 2
    --         self.business:guestLogin();
    --     end);

    --     local btn = ccui.Button:create("login/btn_accountLogin.png");
    --     btn:setPosition(cc.p(winSize.width / 2 + 185, 200));
    --     self:addChild(btn);
    --     btn:onClick(function()
    --         -- Hall.nLoginType = 2 --账号密码登陆时Hall.nLoginType = 2
    --         local accountLayer = require("login.accountLoginLayer").new()
    --         self:addChild(accountLayer)

    --     end);

    -- end
    local activityManager = require("data.ActivityManager"):getInstance()
    activityManager:checkUpdate()
end
function zjhLoginLayer:changeServer()
    if self.clickTimes == 10 then
        TESTSERVER_93 = true
        HallConnection:closeConnect()
        HallConnection:connectServer("192.168.0.93", 2001);
        Hall.showTips("你懂的！！", 1)
        self.clickTimes = 0
    else
        self.clickTimes = self.clickTimes + 1
    end
end
function zjhLoginLayer:changeChannel()
    if self.clickChannelTimes == 10 then
        APP_CHANNEL = "test"
        Hall.showTips("channel你懂的！！", 1)
        self.clickChannelTimes = 0
        package.loaded["launcher.launcher"] = nil;
        require("launcher.launcher").showScene()
    else
        self.clickChannelTimes = self.clickChannelTimes + 1
    end
end
--构建界面
function zjhLoginLayer:createUI()
    local winSize = cc.Director:getInstance():getWinSize();
    print("winSize.width",winSize.width,"height",winSize.height,"display.cx",display.cx,"display.cy",display.cy)
    local EffectFactory = require("commonView.EffectFactory")
    local containerLayer = ccui.Layout:create()
    -- containerLayer:setAnchorPoint(cc.p(0.5,0.5))
    containerLayer:setContentSize(cc.size(1136,640))
    containerLayer:setPosition(-1136/2+winSize.width/2, -640/2+winSize.height/2)
    -- containerLayer:setBackGroundColorType(1)
    -- containerLayer:setBackGroundColor(cc.c3b(100,123,100))
    self.containerLayer = containerLayer
    self:addChild(containerLayer)
    local bgSprite = cc.Sprite:create("hall/room/bg.jpg");
    bgSprite:align(display.CENTER, 1136/2,640/2);
    self.containerLayer:addChild(bgSprite);

    -- local bgSprite = cc.Sprite:create("hall/login/girl_bg.png");
    -- bgSprite:align(display.CENTER, display.cx, display.cy);
    -- self.containerLayer:addChild(bgSprite);

    local bgSprite = EffectFactory:getGirlsArmature("ani_girl_1")
    bgSprite:align(display.CENTER, 568 + 280, 320);
    self.containerLayer:addChild(bgSprite);

    local bgSprite = EffectFactory:getGirlsArmature("ani_girl_2")
    bgSprite:align(display.CENTER, 568 - 280, 320);
    self.containerLayer:addChild(bgSprite);

    local bgSprite = EffectFactory:getGirlsArmature("ani_girl_3")
    bgSprite:align(display.CENTER, 568 , 320);
    self.containerLayer:addChild(bgSprite);

    --设置
    local settingButton = ccui.ImageView:create()
    settingButton:setTouchEnabled(true)
    settingButton:loadTexture("hall/room/hall_setting.png")
    settingButton:setPosition(cc.p(100, DESIGN_HEIGHT - 50))
    self.containerLayer:addChild(settingButton)
    settingButton:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.began then
            settingButton:setScale(1.1)
        elseif eventType == ccui.TouchEventType.ended then
            settingButton:setScale(1.0)
            local setting = require("show_zjh.popView_Hall.SettingNormalLayer").new()
            self.containerLayer:addChild(setting)
            Click();
            -- self:clickSetting()
        elseif eventType == ccui.TouchEventType.canceled then
            settingButton:setScale(1.0)
        end
    end)

    --切换服务器
    local changServerButton = ccui.ImageView:create()
    changServerButton:setTouchEnabled(true)
    changServerButton:loadTexture("common/blank.png")
    changServerButton:setPosition(cc.p(30, DESIGN_HEIGHT - 50))
    changServerButton:setScale9Enabled(true);
    changServerButton:setContentSize(cc.size(60,64));
    self.containerLayer:addChild(changServerButton)
    changServerButton:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.began then
            changServerButton:setScale(1.1)
        elseif eventType == ccui.TouchEventType.ended then
            changServerButton:setScale(1.0)
            self:changeServer()
        elseif eventType == ccui.TouchEventType.canceled then
            changServerButton:setScale(1.0)
        end
    end)

    --切换渠道
    local changServerButton = ccui.ImageView:create()
    changServerButton:setTouchEnabled(true)
    changServerButton:loadTexture("common/blank.png")
    changServerButton:setPosition(cc.p(1100, 56))
    changServerButton:setScale9Enabled(true);
    changServerButton:setContentSize(cc.size(60,64));
    self.containerLayer:addChild(changServerButton)
    changServerButton:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.began then
            changServerButton:setScale(1.1)
        elseif eventType == ccui.TouchEventType.ended then
            changServerButton:setScale(1.0)
            self:changeChannel()
        elseif eventType == ccui.TouchEventType.canceled then
            changServerButton:setScale(1.0)
        end
    end)

    --金三顺
    local bgSprite = cc.Sprite:create("hall/login/word_jinsanshun.png");
    bgSprite:align(display.CENTER, 568, 200);
    self.containerLayer:addChild(bgSprite);

    --筹码   
    local bgSprite = cc.Sprite:create("hall/login/zhuangshi_chouma.png");
    bgSprite:align(display.CENTER, 568 + 200, 150);
    self.containerLayer:addChild(bgSprite);

    --poker
    local bgSprite = cc.Sprite:create("hall/login/poker_icon.png");
    bgSprite:align(display.CENTER, 568, 130);
    self.containerLayer:addChild(bgSprite);

    --发光
    local light1 = cc.Sprite:create("hall/login/light1.png");
    light1:align(display.CENTER, 568 + 130, 160);
    self.containerLayer:addChild(light1);
    local action = cc.RepeatForever:create(cc.Sequence:create(
                                            cc.FadeOut:create(1.5),
                                            cc.FadeIn:create(1),
                                            cc.DelayTime:create(0.3)))
    light1:runAction(action)

    local light2 = cc.Sprite:create("hall/login/light2.png");
    light2:align(display.CENTER, 568 + 110, 250);
    self.containerLayer:addChild(light2);
    light2:setScale(2)
    local action = cc.RepeatForever:create(cc.Sequence:create(
                                            cc.FadeOut:create(1.1),
                                            cc.FadeIn:create(1.5),
                                            cc.DelayTime:create(0.6)))
    light2:runAction(action)

    local light3 = cc.Sprite:create("hall/login/light2.png");
    light3:align(display.CENTER, 568 -10, 210);
    self.containerLayer:addChild(light3);
    --light3:setScale(2)
    local action = cc.RepeatForever:create(cc.Sequence:create(
                                            cc.FadeOut:create(1.8),
                                            cc.FadeIn:create(1.2),
                                            cc.DelayTime:create(0.6)))
    light3:runAction(action)

    if BindMobilePhone == false then
        local btn = ccui.Button:create("login/gameStart_button.png");
        -- btn:setTitleText("开始游戏");
        -- btn:setTitleFontSize(30);
        -- btn:setScale9Enabled(true);
        -- btn:setContentSize(cc.size(300, 80));
        btn:setPosition(cc.p(560,56));
        self.containerLayer:addChild(btn);
        btn:onClick(function()
            self.business:guestLogin();
        end);
    else      

        --单机场
        local singleButton = ccui.Button:create("hall/login/singlePlayer_button.png");
        singleButton:setPosition(cc.p(1068,163));
        singleButton:setVisible(false);
        self.containerLayer:addChild(singleButton);

        --游客登陆
        local quickLogin = ccui.Button:create("hall/login/fastlogin_button.png");
        quickLogin:setPosition(cc.p(230,56));
        self.containerLayer:addChild(quickLogin);
        quickLogin:setPressedActionEnabled(true);
        quickLogin:addTouchEventListener(
            function(sender,eventType)
                if eventType == ccui.TouchEventType.ended then
                    self.business:guestLogin();
                    Click();
                end
            end
        )

        local phoneLogin;
        --手机登陆
        if OnlineConfig_review == nil or OnlineConfig_review == "on" then
            
            phoneLogin = ccui.Button:create("hall/login/accountlogin_button.png");
            phoneLogin:setPosition(cc.p(560,56));
            self.containerLayer:addChild(phoneLogin);
            phoneLogin:setPressedActionEnabled(true);
            phoneLogin:addTouchEventListener(
                function(sender,eventType)
                    if eventType == ccui.TouchEventType.ended then

                        if not self.phoneLoginLayer then
                            local PhoneLoginLayer = require("show_zjh.popView_Hall.zjhPhoneLoginLayer"):new();
                            PhoneLoginLayer:addTo(self.containerLayer):align(display.LEFT_BOTTOM,0,0);
                            self.phoneLoginLayer = PhoneLoginLayer;
                            self.phoneLoginLayer:showLogin(true);
                        else
                            self.phoneLoginLayer:showLogin(true);
                            self.phoneLoginLayer:show();
                        end

                        Click();

                    end
                end
            )

        else

            phoneLogin = ccui.Button:create("hall/login/phonelogin_button.png");
            phoneLogin:setPosition(cc.p(560,56));
            self.containerLayer:addChild(phoneLogin);
            phoneLogin:setPressedActionEnabled(true);
            phoneLogin:addTouchEventListener(
                function(sender,eventType)
                    if eventType == ccui.TouchEventType.ended then

                        if not self.phoneLoginLayer then
                            local PhoneLoginLayer = require("show_zjh.popView_Hall.zjhPhoneLoginLayer"):new();
                            PhoneLoginLayer:addTo(self.containerLayer):align(display.LEFT_BOTTOM,0,0);
                            self.phoneLoginLayer = PhoneLoginLayer;
                            self.phoneLoginLayer:showLogin();
                        else
                            self.phoneLoginLayer:showLogin();
                            self.phoneLoginLayer:show();
                        end

                        Click();

                    end
                end
            )

            local myLogin = ccui.Button:create("hall/login/98login_button.png");
            myLogin:setPosition(cc.p(1050,570));
            self.containerLayer:addChild(myLogin);
            myLogin:setPressedActionEnabled(true);
            myLogin:addTouchEventListener(
                function(sender,eventType)
                    if eventType == ccui.TouchEventType.ended then

                        if not self.phoneLoginLayer then
                            local PhoneLoginLayer = require("show_zjh.popView_Hall.zjhPhoneLoginLayer"):new();
                            PhoneLoginLayer:addTo(self.containerLayer):align(display.LEFT_BOTTOM,0,0);
                            self.phoneLoginLayer = PhoneLoginLayer;
                            self.phoneLoginLayer:showLogin(true);
                        else
                            self.phoneLoginLayer:showLogin(true);
                            self.phoneLoginLayer:show();
                        end

                        Click();

                    end
                end
            )

        end

        --QQ登陆
        local qqLogin = ccui.Button:create("hall/login/qqlogin_button.png");
        qqLogin:setPosition(cc.p(890,56));
        self.containerLayer:addChild(qqLogin);
        qqLogin:setPressedActionEnabled(true);
        qqLogin:addTouchEventListener(
            function(sender,eventType)
                if eventType == ccui.TouchEventType.ended then
                    LoginByTencentQQ();
                    Click();
                end
            end
        )

        --facevisa登陆
        -- local facevisaLogin = ccui.Button:create("hall/login/facevisalogin_button.png");
        -- facevisaLogin:setPosition(cc.p(1050, 186));
        -- self.containerLayer:addChild(facevisaLogin);
        -- facevisaLogin:setPressedActionEnabled(true);
        -- facevisaLogin:addTouchEventListener(
        --     function(sender,eventType)
        --         if eventType == ccui.TouchEventType.ended then
        --             LoginByFaceVisa();
        --             Click();
        --         end
        --     end
        -- )

        if OnlineConfig_review == nil or OnlineConfig_review == "on" then
            qqLogin:setVisible(false);
            phoneLogin:setPositionX(qqLogin:getPositionX());
        end
    end
    -- scheduler.performWithDelayGlobal(
    --     function()
    --         sendRegisterFast();
    --         --Hall:enterMainScene();
    --     end,
    --     0.5
    -- )

    local path = cc.FileUtils:getInstance():fullPathForFilename("scripts/main.lua");
    local resPath = string.sub(path, 1, string.len(path) - 16)

    --version
    local fileName = cc.FileUtils:getInstance():getWritablePath().."upd/flist.txt";
    if cc.FileUtils:getInstance():isFileExist(fileName) == false then
        fileName = resPath.."res/flist.txt";
    end

    if cc.FileUtils:getInstance():isFileExist(fileName) then
        local fileString = cc.FileUtils:getInstance():getStringFromFile(fileName)
        local updlist = lua_do_string(fileString)

        local string = "v."..updlist.version;
        local titleLabe = ccui.Text:create(string, "Arial", 21);
        titleLabe:setColor(cc.c3b(255,183,0));
        titleLabe:setPosition(cc.p(30, 50));
        self.containerLayer:addChild(titleLabe);
    end

    fileName = cc.FileUtils:getInstance():getWritablePath().."upd/zhajinhua/flist.txt";
    if cc.FileUtils:getInstance():isFileExist(fileName) == false then
        fileName = resPath.."res/zhajinhua/flist.txt";
    end

    if cc.FileUtils:getInstance():isFileExist(fileName) then
        local fileString = cc.FileUtils:getInstance():getStringFromFile(fileName)
        local updlist = lua_do_string(fileString)

        local string = "zv."..updlist.version;
        local titleLabe = ccui.Text:create(string, "Arial", 21);
        titleLabe:setColor(cc.c3b(255,183,0));
        titleLabe:setPosition(cc.p(30, 30));
        self.containerLayer:addChild(titleLabe);
    end

    -- --切换测试服
    -- local changeServer = ccui.Button:create("hall/room/hall_setting.png")
    -- changeServer:setAnchorPoint(cc.p(0,1))
    -- changeServer:setPosition(display.left, display.top)
    -- changeServer:setOpacity(0)
    -- changeServer:addTouchEventListener(
    --     function(sender,eventType)
    --         if eventType == ccui.TouchEventType.ended then
    --             self:changeServerHandler(sender)
    --         end
    --     end
    -- )
    -- self.containerLayer:addChild(changeServer)
    self:checkShowUpdateInfo()
end
function zjhLoginLayer:checkShowUpdateInfo()
    if SHOWUPDATEINFO then
        print("SHOWUPDATEINFO")
        local updateInfo = require("login.updateInfoLayer").new()
        self.containerLayer:addChild(updateInfo)
    end
end
function zjhLoginLayer:clickSetting()
    if setReview == true then
        setReview = false
        OnlineConfig_review = "off"
    else
        setReview = true 
        OnlineConfig_review = "on"
    end
    print("zjhLoginLayer---OnlineConfig_review",OnlineConfig_review)
end
return zjhLoginLayer;