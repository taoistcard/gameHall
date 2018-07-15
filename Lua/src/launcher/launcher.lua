require("lfs")
require("framework.init")

require("scripts.channel");

-----------------------------------------------------------------------------
local Launcher = class("LauncherScene", function()

    return display.newScene("LauncherScene")

end)

function Launcher:ctor()

    self:setData();
    self:createUI();
    --get new flist from server
    if 1 == cc.UserDefault:getInstance():getIntegerForKey("Music",1) then
        audio.playMusic("sound/hallbgm.mp3",true);
    end
    

end

function Launcher:checkLandlordCutieUpdate()
    local ret = false
    if APP_ID == 1005 then
        if device.platform == "ios" then
            local luaCallFun = require("cocos.cocos2d.luaoc")
            local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","appVersion")
            --print(ok,ret);
            if ok == true then
                APP_VERSiON = ret
                if APP_VERSiON < "3.2.0" then
                    ret = true
                    device.showAlert(
                        "提示",
                        "该版本需要升级，请前往APPSTORE下载最新版本？",
                        {"立即前往","取消"}, 
                        function(event)
                            if event.buttonIndex == 1 then
                                device.openURL("https://itunes.apple.com/us/app/huan-le-dou-zhu-98you-xi-chu/id673933496?l=zh&ls=1&mt=8")
                                cc.Director:getInstance():endToLua();
                                os.exit()
                                
                            elseif event.buttonIndex == 2 then
                                cc.Director:getInstance():endToLua();
                                os.exit()
                            end
                        end
                    )
                end
            end

        elseif device.platform == "android" then
            ret = true
            device.showAlert(
                "提示",
                "推荐使用WiFi下载，\n检测到您当前WiFi还未打开或连接，\n是否继续下载？",
                {"确定","取消"}, 
                function(event)
                    if event.buttonIndex == 1 then
                        device.showAlert("提示", "android版本暂停服务，稍等马上就来", {"确定"})
                        cc.Director:getInstance():endToLua();
                        os.exit()

                    elseif event.buttonIndex == 2 then
                        cc.Director:getInstance():endToLua();
                        os.exit()
                    end
                end
            )
        else
            ret = true
            print("Launcher:checkLandlordCutieUpdate!")
            device.showAlert(
                        "提示",
                        "该版本需要升级，请前往APPSTORE下载最新版本？",
                        {"立即前往","取消"}, 
                        function(event)
                            if event.buttonIndex == 1 then
                                device.openURL("https://itunes.apple.com/us/app/huan-le-dou-zhu-98you-xi-chu/id673933496?l=zh&ls=1&mt=8")
                                cc.Director:getInstance():endToLua();
                                os.exit()

                            elseif event.buttonIndex == 2 then
                                cc.Director:getInstance():endToLua();
                                os.exit()
                            end
                        end
                    )        
        end
    end

    return ret
end

function Launcher:onEnter()

    -- self:startLoad()
    local iswifiConnect = network.getInternetConnectionStatus();
    if iswifiConnect == 1 then
        -- if not Launcher:checkLandlordCutieUpdate() then
            self:startLoad();
        -- end
    else
   
        device.showAlert(
            "提示",
            "推荐使用WiFi下载，\n检测到您当前WiFi还未打开或连接，\n是否继续下载？",
            {"确定","取消"}, 
            function(event)
                if event.buttonIndex == 1 then
                    self:startLoad()
                    
                elseif event.buttonIndex == 2 then
                    cc.Director:getInstance():endToLua();
                    os.exit()
                end
            end
        )

    end

    return;
    
end

function Launcher:startLoad()

    if self.startDownload == true then
        return;
    end

    if XPLAYER == true or device.platform == "android" then

        OnlineConfig_review = "off"
        OnlineConfig_charge = "other"

        self:startDownload();

        return;

    end

    self.waitTime = self.waitTime or 0;
    self.waitTime = self.waitTime + 1;

    if OnlineConfig_review ~= nil or self.waitTime > 30 then
        if OnlineConfig_review == nil then
            OnlineConfig_review = "on"
            OnlineConfig_charge = "apple"
        end

        self:startDownload();

    else
        
        self:performWithDelay(
            function()
                self:startLoad();
            end,
            0.3
        );

    end

end

function Launcher:startDownload()

    self.startDownload = true;

    --APP_CHANNEL
    if APP_CHANNEL == nil then
        APP_CHANNEL = "a_01"
    end
    
    --APP_VERSiON
    APP_VERSiON = "1.0.0";
    if device.platform == "ios" then
        local luaCallFun = require("cocos.cocos2d.luaoc")
        local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","appVersion")
        --print(ok,ret);
        if ok == true then
            APP_VERSiON = ret;
        end
    elseif device.platform == "android" then

    end
    --APP_PLATFORM
    APP_PLATFORM = device.platform;
    if APP_PLATFORM == "mac" or APP_PLATFORM == "window" then
        APP_PLATFORM = "ios"
    end

    local url = "http://service.game100.cn/service/sync/resversion?appid="..APP_ID.."&source="..APP_CHANNEL.."&os="..APP_PLATFORM.."&ver="..APP_VERSiON..'&data={"flist":%d}'

    -- print("测试热更新...",url)

    local thunder = require("launcher.Thunder").new(url,"");
    thunder:setDelegate(self);
    thunder:startUpdate();
    self.thunder = thunder;


end

function Launcher:onDownloadStart(index, total)

    self:showMove(index, total)
    
end


function Launcher:onDownloadProgess(singleProgess, singleTotal)

    if singleProgess ~= singleTotal then

        local percent = singleProgess / singleTotal;
        local text = string.format("%.1f%%", percent * 100);
        self.percent:setString(text);

    else

        self.percent:setString("100%");

    end
    SHOWUPDATEINFO = true
end


function Launcher:onDownloadFinish(errorCode)

    if errorCode == 0 then
        print("Launcher:onDownloadFinish",errorCode)
        GameStart();

    else

        local codeText = display.newTTFLabel({
            text = "Http error code "..errorCode,
            font = "Helvetica-Bold",
            color = cc.c3b(255, 255, 255),
            size = 22,
            align = display.TEXT_ALIGN_LEFT,
            dimensions = cc.size(300,50),
        });
        codeText:setAnchorPoint(cc.p(0.0,0.0));
        codeText:setPosition(cc.p(25, 40));
        self:addChild(codeText);

        self:performWithDelay(
            function()
                print("Launcher:performWithDelay",errorCode)
                GameStart();
            end,
            3.0
        );

    end

end

function Launcher:setData()

    --constants
    local path = cc.FileUtils:getInstance():fullPathForFilename("scripts/main.lua");
    --print("path:",path)
    local resPath = string.sub(path, 1, string.len(path) - 16)
    --print("resPath:",resPath)
    local writablePath = cc.FileUtils:getInstance():getWritablePath()
    --print("writable path:",writablePath)

    local UPD_FOLDER = writablePath.."upd/"
    local RES_FOLDER = resPath.."res/"
    -- UPD_FOLDER = writablePath.."upd/"
    -- RES_FOLDER = resPath.."res/"
    -- print("UPD_FOLDER path:",UPD_FOLDER)
    -- print("RES_FOLDER path:",RES_FOLDER)

    --add search path here
    cc.FileUtils:getInstance():addSearchPath(UPD_FOLDER);
    cc.FileUtils:getInstance():addSearchPath("res/")

end

function Launcher:createUI()

    -- --make sure we have the writablePath..upd/ folder
    -- make_dir(UPD_FOLDER..FLIST);

    local sharedDirector = cc.Director:getInstance();
    local winSize = sharedDirector:getWinSize();
    local centerX = winSize.width / 2;
    local centerY = winSize.height / 2;

    --back ground
    local sp = display.newSprite("launcher/splash.jpg");
    sp:setPosition(centerX,centerY);
    self:addChild(sp);

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

    local moveSprite = display.newSprite("launcher/movesprite.png");
    moveSprite:setPosition(centerX - 200, centerY - 160)
    self:addChild(moveSprite)
    self.moveSprite = moveSprite;

    local standSprite = display.newSprite("launcher/standsprite.png");
    standSprite:setPosition(centerX + 200, centerY - 150)
    self:addChild(standSprite)
    self.standSprite = standSprite;

    local linebg = display.newSprite("launcher/linebackground.png");
    linebg:setAnchorPoint(cc.p(0,0.5))
    linebg:setPosition(centerX - linebg:getContentSize().width/2, centerY - 200)
    self:addChild(linebg)

    local line = display.newSprite("launcher/line.png");
    line.width = line:getContentSize().width;
    line:setAnchorPoint(cc.p(0,0.5))
    line:setPosition(centerX - line:getContentSize().width/2, centerY - 200)
    self:addChild(line)
    self.line = line;
    line:setTextureRect(cc.rect(0,0,0,line:getContentSize().height));

    local light = display.newSprite("launcher/light.png");
    light:setAnchorPoint(cc.p(1.0,0.5))
    light:setPosition(centerX - line:getContentSize().width/2, centerY - 200)
    self:addChild(light)
    light:setVisible(false);
    self.light = light;

    local text = ccui.Text:create("正在检查更新中。。。", "launcher/font.TTF", 26);
    text:setColor(cc.c3b(255,255,255));
    --text:setAnchorPoint(cc.p(centerX,0.5));
    text:setPosition(cc.p(centerX - 50, centerY - 200));
    self:addChild(text);
    self.text = text;

    local percent = ccui.Text:create("0%", "launcher/font.TTF", 26);
    percent:setColor(cc.c3b(255,255,255));
    --text:setAnchorPoint(cc.p(centerX,0.5));
    percent:setPosition(cc.p(centerX + 150, centerY - 200));
    self:addChild(percent);
    self.percent = percent;

    -- local tips = display.newSprite("launcher/tips.png");
    -- tips:setPosition(centerX, centerY - 250)
    -- self:addChild(tips)

end

function Launcher:showMove(finish, total)

    local sharedDirector = cc.Director:getInstance();
    local winSize = sharedDirector:getWinSize();
    local centerX = winSize.width / 2;
    local centerY = winSize.height / 2;

    local percent = finish / total;

    if percent > 1 then
        percent = 1;
    end

    --for sprite
    if percent > 0.8 then
        local x,y = self.standSprite:getPosition();
        local pos = cc.p(x,y);
        pos.x = pos.x + 400;
        --self.standsprite.setPosition(pos);
        self.standSprite:stopAllActions();
        self.standSprite:runAction(cc.MoveTo:create(0.3, pos));
    end

    --for line
    local rect = self.line:getTextureRect();
    local width = self.line.width;
    rect.width = width * percent;
    self.line:setTextureRect(rect);

    --for move sprite
    local activeX = self.line:getPositionX() + width * percent;
    self.moveSprite:setPositionX(activeX);

    self.light:setVisible(true);
    self.light:setPositionX(activeX + 4);

    --for text
    local text = "正在下载... ("..finish.."/"..total..")";
    self.text:setString(text);


end

-- function Launcher:startForError(code)

--     local codeText = display.newTTFLabel({
--         text = "Http error code "..code,
--         font = "Helvetica-Bold",
--         color = cc.c3b(255, 255, 255),
--         size = 22,
--         align = display.TEXT_ALIGN_LEFT,
--         dimensions = cc.size(300,50),
--     });
--     codeText:setAnchorPoint(cc.p(0.0,0.0));
--     codeText:setPosition(cc.p(25, 40));
--     self:addChild(codeText);

--     self:performWithDelay(
--         function()
--             GameStart();
--         end,
--         3.0
--     );

-- end

function Launcher:checkDeviceScreen()

    -- check device screen size
    local glview = cc.Director:getInstance():getOpenGLView()
    
    local w = display.sizeInPixels.width
    local h = display.sizeInPixels.height

    if CONFIG_SCREEN_WIDTH == nil or CONFIG_SCREEN_HEIGHT == nil then
        CONFIG_SCREEN_WIDTH = w
        CONFIG_SCREEN_HEIGHT = h
    end
    
    local scale, scaleX, scaleY

    if CONFIG_SCREEN_AUTOSCALE == "SHOW_ALL" then
        scaleX, scaleY = w / CONFIG_SCREEN_WIDTH, h / CONFIG_SCREEN_HEIGHT
        if scaleX > scaleY then
            scale = scaleY
        else
            scale = scaleX
        end

        CONFIG_SCREEN_HEIGHT = h / scale
        CONFIG_SCREEN_WIDTH = w / scale

        glview:setDesignResolutionSize(CONFIG_SCREEN_WIDTH, CONFIG_SCREEN_HEIGHT, cc.ResolutionPolicy.SHOW_ALL)
    end
    display.contentScaleFactor = scale
end

Launcher.checkDeviceScreen();

function Launcher.showScene()

    local launcher = Launcher.new();
    display.replaceScene(launcher);

end

return Launcher;
