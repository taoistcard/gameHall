
local LoginScene = class("LoginScene", require("ui.CCBaseScene"))

function LoginScene:ctor()
    -- 根节点变更为self.container
    self.super.ctor(self);

    --背景
    local bgSprite = cc.Sprite:create();
    -- bgSprite:setTexture("splash.jpg");
    bgSprite:setTexture("christmas/splash.jpg");
    bgSprite:align(display.CENTER, display.cx, display.cy);
    self.container:addChild(bgSprite);
    
    if AppChannel == "CTCC" then
        self:createEGameUI()
    else
        self:createUI();
    end

    self:setKeypadEnabled(true)
    self:addNodeEventListener(cc.KEYPAD_EVENT, function(event)
        if event.key == "back" then
            -- if true then
            --     self:testInterface()
            --     return
            -- end

            device.showAlert("退出", "确定退出游戏?", {"是","否"}, function(event)
                if event.buttonIndex == 1 then
                    cc.Director:getInstance():endToLua();
                    
                elseif event.buttonIndex == 2 then
                    device.cancelAlert()
                end
            end)
        end
    end)





    if HallConnection.isConnected then
        HallConnection:closeConnect();
    end

    local connectHost = ServerHost
    if string.len(ServerHostBackUp) > 0 then
        connectHost = ServerHostBackUp
    end
    HallConnection:connectServer(connectHost, ServerPort);
end

function LoginScene:createEGameUI()
    --游客登陆
    local quickLogin = ccui.Button:create("loginScene/egame_button.png");
    quickLogin:setPosition(cc.p(display.cx,56));
    self.container:addChild(quickLogin);
    quickLogin:setPressedActionEnabled(true);
    quickLogin:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:startLogin(4);
                Click();
            end
        end
    )

    --version
    local fileName = cc.FileUtils:getInstance():getWritablePath().."upd/flist.txt";
    if cc.FileUtils:getInstance():isFileExist(fileName) then
        local fileString = cc.FileUtils:getInstance():getStringFromFile(fileName)
        local updlist = lua_do_string(fileString)

        local string = "v."..updlist.version;
        local titleLabe = ccui.Text:create(string, "Arial", 21);
        titleLabe:setColor(cc.c3b(255,183,0));
        titleLabe:setPosition(cc.p(30, 15));
        self.container:addChild(titleLabe);

    end
    --切换测试服
    local changeServer = ccui.Button:create("common/hall_close.png")--loginScene/rock.png
    changeServer:setAnchorPoint(cc.p(0,1))
    changeServer:setPosition(display.left, display.top)
    changeServer:setOpacity(0)
    changeServer:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:changeServerHandler(sender)
            end
        end
    )
    self.container:addChild(changeServer)

    --动画特效
    local armature = self:getLoginArmature()
    if armature then
        armature:setPosition(cc.p(580,320))
        self.container:addChild(armature)
        armature:getAnimation():playWithIndex(0)
    end
end
--构建界面
function LoginScene:createUI()

    --按钮底
    local buttonBg = ccui.ImageView:create("loginScene/hall_login_buttonbg.png")
    buttonBg:setPosition(cc.p(570,56))
    buttonBg:setScale9Enabled(true)
    buttonBg:setContentSize(cc.size(1136,114))
    self.container:addChild(buttonBg);

    --游客登陆
    local quickLogin = ccui.Button:create("loginScene/fastlogin_button.png");
    quickLogin:setPosition(cc.p(300,56));
    self.container:addChild(quickLogin);
    quickLogin:setPressedActionEnabled(true);
    quickLogin:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:startLogin(1);
                Click();
            end
        end
    )

    local phoneLogin;
    --手机登陆
    if OnlineConfig_review == nil or OnlineConfig_review == "on" then
        
        phoneLogin = ccui.Button:create("loginScene/accountlogin_button.png");
        phoneLogin:setPosition(cc.p(570,56));
        self.container:addChild(phoneLogin);
        phoneLogin:setPressedActionEnabled(true);
        phoneLogin:addTouchEventListener(
            function(sender,eventType)
                if eventType == ccui.TouchEventType.ended then

                    if not self.phoneLoginLayer then
                        local PhoneLoginLayer = require("show_ddz.PhoneLoginLayer"):new();
                        PhoneLoginLayer:addTo(self.container):align(display.LEFT_BOTTOM,0,0);
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

        phoneLogin = ccui.Button:create("loginScene/phonelogin_button.png");
        phoneLogin:setPosition(cc.p(570,56));
        self.container:addChild(phoneLogin);
        phoneLogin:setPressedActionEnabled(true);
        phoneLogin:addTouchEventListener(
            function(sender,eventType)
                if eventType == ccui.TouchEventType.ended then

                    if not self.phoneLoginLayer then
                        local PhoneLoginLayer = require("show_ddz.PhoneLoginLayer"):new();
                        PhoneLoginLayer:addTo(self.container):align(display.LEFT_BOTTOM,0,0);
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

        local myLogin = ccui.Button:create("loginScene/98login_button.png");
        myLogin:setPosition(cc.p(1050,570));
        self.container:addChild(myLogin);
        myLogin:setPressedActionEnabled(true);
        myLogin:addTouchEventListener(
            function(sender,eventType)
                if eventType == ccui.TouchEventType.ended then

                    if not self.phoneLoginLayer then
                        local PhoneLoginLayer = require("show_ddz.PhoneLoginLayer"):new();
                        PhoneLoginLayer:addTo(self.container):align(display.LEFT_BOTTOM,0,0);
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
    local qqLogin = ccui.Button:create("loginScene/qqlogin_button.png");
    qqLogin:setPosition(cc.p(840,56));
    self.container:addChild(qqLogin);
    qqLogin:setPressedActionEnabled(true);
    qqLogin:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                LoginByTencentQQ();
                Click();
            end
        end
    )

    if OnlineConfig_review == nil or OnlineConfig_review == "on" then
        qqLogin:setVisible(false);
        phoneLogin:setPositionX(qqLogin:getPositionX());
    end

    --version
    local fileName = cc.FileUtils:getInstance():getWritablePath().."upd/flist.txt";
    if cc.FileUtils:getInstance():isFileExist(fileName) then
        local fileString = cc.FileUtils:getInstance():getStringFromFile(fileName)
        local updlist = lua_do_string(fileString)

        local string = "v."..updlist.version;
        local titleLabe = ccui.Text:create(string, "Arial", 21);
        titleLabe:setColor(cc.c3b(255,183,0));
        titleLabe:setPosition(cc.p(30, 15));
        self.container:addChild(titleLabe);

    end
    --切换测试服
    local changeServer = ccui.Button:create("common/hall_close.png")--loginScene/rock.png
    changeServer:setAnchorPoint(cc.p(0,1))
    changeServer:setPosition(display.left, display.top)
    changeServer:setOpacity(0)
    changeServer:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:changeServerHandler(sender)
            end
        end
    )
    self.container:addChild(changeServer)

    --动画特效
    local armature = self:getLoginArmature()
    if armature then
        armature:setPosition(cc.p(580,320))
        self.container:addChild(armature)
        armature:getAnimation():playWithIndex(0)
    end
end
LoginScene.changeclick = 0
function LoginScene:changeServerHandler(sender)
    -- body
    self.changeclick = self.changeclick+1
    if self.changeclick==10 then
        Hall.showTips("你懂的！！", 1)
        HallSetting.host = "oa.98game.cn";
        HallSetting.port = 12000;
        HallCenter:connectHallServer("oa.98game.cn", 12000);
        self.changeclick = 0
    end
    
end
-- 大厅登录回调
function LoginScene:startLogin(index)

    if index == 1 then
        sendRegisterFast()
    end

    if index == 2 then
        --
    end

    if index == 3 then
        LoginByTencentQQ();
    end

    if index == 4 then
        LoginByCTCCEGame()
    end
    Hall.showWaiting(5);

end

function LoginScene:getLoginArmature()
    local name = "qipai_dating"

    local filePath = "hallEffect/"..name..".ExportJson"
    local imagePath = "hallEffect/"..name.."0.png"
    local plistPath = "hallEffect/"..name.."0.plist"
    
    local manager = ccs.ArmatureDataManager:getInstance()
    if manager:getAnimationData(name) == nil then
        manager:addArmatureFileInfo(imagePath,plistPath,filePath)
    end
    local armature = ccs.Armature:create(name)
    return armature;
end

-- 大厅登录回调
function LoginScene:loginSuccess(event)
    print("hallLogonSuccess!")

    Hall.hideWaiting();

    if Hall.phoneNumber ~= nil and Hall.phonepassword ~= nil then

        cc.UserDefault:getInstance():setStringForKey("phoneNumber", Hall.phoneNumber);
        cc.UserDefault:getInstance():setStringForKey("phonepassword", Hall.phonepassword);

    end

    Hall:continue()

end

function LoginScene:hallLogonFailure(event)
    Hall.showTips("登录失败:" .. event.pData)
    print("hallLogonFailure!")
    Hall.hideWaiting();
end

function LoginScene:onEnter()

    print("LoginScene onEnter!!!!")
    

    self.bindIds = {}
    self.bindIds[#self.bindIds + 1] = BindTool.bind(ServerInfo, "nodeItemList", handler(self, self.loginSuccess))

    -- 进入以后 尝试更服务器建立连接
    SoundManager.playMusic("sound/hallbgm.mp3", true);
    
    local texture2d = cc.Director:getInstance():getTextureCache():addImage("christmas/effect/lizi_xuehua.png");
    local light = cc.ParticleSystemQuad:create("christmas/effect/lizi_xuehua.plist");
    light:setTexture(texture2d);
    light:setPosition(cc.p(display.cx, display.top));
    self.container:addChild(light,99)
end

function LoginScene:onExit()
    for _, bindid in ipairs(self.bindIds) do
        BindTool.unbind(bindid)
    end
end

function LoginScene:testInterface()

    if self.testIndex == nil then
        self.testIndex = 1
    elseif self.testIndex == 7 then
        self.testIndex = 1
    else
        self.testIndex = self.testIndex + 1
    end

    -- FreeChip("http://112.124.38.85:8083/hall/freeChip.php")
    self.testIndex = 0
    if self.testIndex == 0 then
        showShare("","","")

    elseif self.testIndex == 1 then
        Hall.showTips("打开竖屏浏览器！")
        openPortraitWebView("http://112.124.38.85:8083/hall/freeChip.php")
        
    elseif self.testIndex == 2 then
        Hall.showTips("打开浏览器！")
        openWebView("http://112.124.38.85:8083/hall/freeChip.php")

    elseif self.testIndex == 3 then
        Hall.showTips("打开系统浏览器！")
        openPureURL("http://www.sina.com.cn")
    
    elseif self.testIndex == 4 then
        Hall.showTips("启动com.duole.game.client.niuniu！")
        openAppPkg("com.duole.game.client.niuniu")
    elseif self.testIndex == 5 then
        local ret = checkAppPkg("com.duole.game.client.niuniu")
        Hall.showTips("checkAppPkg(\"com.duole.game.client.niuniu\") " .. tostring(ret), 3.0)
    elseif self.testIndex == 6 then
        local ret = isWXAppInstalled()
        Hall.showTips("微信安装： " .. tostring(ret), 3.0)
    else
        Hall.showTips("测试完毕！")
    end

end

return LoginScene