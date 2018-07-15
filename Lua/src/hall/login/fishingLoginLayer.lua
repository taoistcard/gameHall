local fishingLoginLayer = class("fishingLoginLayer", function() return display.newLayer(); end );

function fishingLoginLayer:scene()

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

function fishingLoginLayer:onEnter()
    self.bindIds = {}
    self.bindIds[#self.bindIds + 1] = BindTool.bind(ServerInfo, "nodeItemList", handler(self, self.loginSuccess))
end

function fishingLoginLayer:onExit()
    for _, bindid in ipairs(self.bindIds) do
        BindTool.unbind(bindid)
    end
end

function fishingLoginLayer:loginSuccess()
    print("fishingLoginLayer:loginSuccess")
    Hall:continue()
end

function fishingLoginLayer:ctor(loginBusiness)

    -- local loginBusiness = require("login.loginBusiness");
    self.business = loginBusiness;

    self:setNodeEventEnabled(true);

    local winSize = cc.Director:getInstance():getWinSize();

    -- local backgroundSprite = cc.Sprite:create("login/login_background.jpg");
    local backgroundSprite = cc.Sprite:create("launcher/splash.jpg");
    backgroundSprite:setPosition(getSrcreeCenter());
    self:addChild(backgroundSprite);

    -- local icon = cc.Sprite:create("login/game_icon.png");
    -- icon:setPosition(cc.p(winSize.width / 2 + 340, winSize.height / 2 + 108));
    -- backgroundSprite:addChild(icon);

    --login 动画
    local specified = true;
    local kindPath = "";
    local effectPath = kindPath.."launcher/";
    if cc.FileUtils:getInstance():isFileExist(effectPath.."fullscreen.ExportJson") then

        local name = "fullscreen";
        local filePath = effectPath.."fullscreen.ExportJson";
        local imagePath = effectPath.."fullscreen0.png";
        local plistPath = effectPath.."fullscreen0.plist";
        local manager = ccs.ArmatureDataManager:getInstance();
        if manager:getAnimationData(name) == nil then
            manager:addArmatureFileInfo(imagePath,plistPath,filePath);
        end
        local armature = ccs.Armature:create(name);
        armature:setPosition(cc.p(winSize.width / 2, winSize.height / 2));
        self:addChild(armature);
        armature:getAnimation():playWithIndex(0);

    end

    --游客登录
    local guestBtn = ccui.Button:create("login/btn_guestLogin.png");
    guestBtn:setPosition(cc.p(winSize.width / 2 - 185, 180));
    self:addChild(guestBtn);
    guestBtn:onClick(
        function()
            Hall.nLoginType = 1 --账号密码登陆时Hall.nLoginType = 2
            self.business:guestLogin();
            -- require("protocol.loginServer.loginServer_testfloat_c2s_pb")
            --  local request = protocol.loginServer.testfloat.c2s_pb.TestFloat()
            --  request.amount = 2.3
            --  local pData = request:SerializeToString()
            --  local response = protocol.loginServer.testfloat.c2s_pb.TestFloat()
            --  response:ParseFromString(pData)
            --  dump(response, "response")
        end
    );

    --账号登录
    local accountBtn = ccui.Button:create("login/btn_accountLogin.png");
    accountBtn:setPosition(cc.p(winSize.width / 2 + 185, 180));
    self:addChild(accountBtn);
    accountBtn:onClick(
        function()
            Hall.nLoginType = 2 --账号密码登陆时Hall.nLoginType = 2
            local accountLayer = require("login.accountLoginLayer").new()
            self:addChild(accountLayer)
        end
    );

    if OnlineConfig_review == "off" then
        
        --QQ登录
        -- local btn = ccui.Button:create("login/btn_qqLogin.png");
        -- btn:setPosition(cc.p(winSize.width/2+290,180));
        -- self:addChild(btn);
        -- btn:onClick(
        --     function()
        --         LoginByTencentQQ();
        --     end
        -- );
        -- guestBtn:setPosition(cc.p(winSize.width/2-290,180));
        -- accountBtn:setPosition(cc.p(winSize.width/2,180));
    
    end

    local activityManager = require("data.ActivityManager"):getInstance()
    activityManager:checkUpdate()

end

return fishingLoginLayer;