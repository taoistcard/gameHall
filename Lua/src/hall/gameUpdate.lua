require("lfs")
require("framework.init")
require("scripts.channel")

-----------------------------------------------------------------------------
local gameUpdate = class("gameUpdateScene", function() return display.newScene("gameUpdateScene") end )

function gameUpdate:ctor()

    -- self:setData();
    self:createUI();
    --get new flist from server

end

function gameUpdate:onEnter()

    self:startLoad()

    -- local iswifiConnect = network.getInternetConnectionStatus();
    -- if iswifiConnect == 2 then
    --     self:startLoad();
    -- else
   
    --     device.showAlert(
    --         "提示",
    --         "推荐使用WLAN下载，\n检测到您当前WLAN还未打开或连接，\n是否继续下载？",
    --         {"确定","取消"}, 
    --         function(event)
    --             if event.buttonIndex == 1 then
    --                 self:startLoad()
                    
    --             elseif event.buttonIndex == 2 then
    --                 cc.Director:getInstance():endToLua();
    --             end
    --         end
    --     )

    -- end

    return;
    
end

function gameUpdate:startLoad()

    self:startDownload();

end

function gameUpdate:startDownload()

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

    local url = "http://service.game100.cn/service/sync/resversion?appid="..APP_ID.."&source="..APP_CHANNEL.."&os="..APP_PLATFORM.."&ver="..APP_VERSiON..'&data={"'..curGameName..'flist":%d}'

    -- print("gameUpdate测试热更新...",url)

    local thunder = require("launcher.Thunder").new(url,curGameName.."/");
    thunder:setDelegate(self);
    thunder:startUpdate();
    self.thunder = thunder;


end

function gameUpdate:onDownloadStart(index, total)

    self:showMove(index, total)
    
end


function gameUpdate:onDownloadProgess(singleProgess, singleTotal)

    if singleProgess ~= singleTotal then

        local percent = singleProgess / singleTotal;
        local text = string.format("%.1f%%", percent * 100);
        self.percent:setString(text);

    else

        self.percent:setString("100%");

    end
    SHOWUPDATEINFO = true
end


function gameUpdate:onDownloadFinish(errorCode)

    -- if errorCode == 0 then
    --     print("gameUpdate:onDownloadFinish",errorCode)
    --     GameStart();

    -- else

    --     local codeText = display.newTTFLabel({
    --         text = "Http error code "..errorCode,
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
    --             print("gameUpdate:performWithDelay",errorCode)
    --             GameStart();
    --         end,
    --         3.0
    --     );

    -- end

    Hall:login();

end

function gameUpdate:setData()

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

function gameUpdate:createUI()

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

function gameUpdate:showMove(finish, total)

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

-- function gameUpdate:startForError(code)

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

function gameUpdate:checkDeviceScreen()

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

gameUpdate.checkDeviceScreen();

function gameUpdate.showScene()

    local gameUpdate = gameUpdate.new();
    display.replaceScene(gameUpdate);

end

return gameUpdate;
