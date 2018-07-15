require("lfs")
require("framework.init")
require("scripts.channel")

local updateSingleGame = {}

function updateSingleGame:checkUpdate(parent,appid,appname)

    self.parent = parent
    self.appid = appid
    self.appname = appname

    -- self:startLoad()

    local iswifiConnect = network.getInternetConnectionStatus();
    if iswifiConnect == 1 then
        self:startLoad();
    else
        device.showAlert(
            "提示",
            "推荐使用WiFi下载，\n检测到您当前WiFi还未打开或连接，\n是否继续下载？",
            {"确定","取消"}, 
            function(event)
                if event.buttonIndex == 1 then
                    self:startLoad()
                elseif event.buttonIndex == 2 then
                end
            end
        )
    end

    return;
    
end

function updateSingleGame:startLoad()
    self:startDownload();
end

function updateSingleGame:startDownload()

    --APP_CHANNEL
    if APP_CHANNEL == nil then
        APP_CHANNEL = "a_01"
    end
    
    --APP_VERSiON:写成最低版本号,热更新的时候比这个高的版本都能更新
    APP_VERSiON = "1.0.0";

    -- if device.platform == "ios" then
    --     local luaCallFun = require("cocos.cocos2d.luaoc")
    --     local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","appVersion")
    --     --print(ok,ret);
    --     if ok == true then
    --         APP_VERSiON = ret;
    --     end
    -- elseif device.platform == "android" then
    -- end

    --APP_PLATFORM
    APP_PLATFORM = device.platform;
    if APP_PLATFORM == "mac" or APP_PLATFORM == "window" then
        APP_PLATFORM = "ios"
    end

    -- APP_CHANNEL = "test"

    local url = "http://service.game100.cn/service/sync/resversion?appid="..self.appid.."&source="..APP_CHANNEL.."&os="..APP_PLATFORM.."&ver="..APP_VERSiON..'&data={"'..self.appname..'flist":%d}'

    print("updateSingleGame...",url)

    local thunder = require("launcher.Thunder").new(url,self.appname.."/");
    thunder:setDelegate(self.parent);
    thunder:startUpdate();
    self.thunder = thunder;

end

function updateSingleGame:onDownloadStart(index, total)
end

function updateSingleGame:onDownloadProgess(singleProgess, singleTotal)
end

function updateSingleGame:onDownloadFinish(errorCode)
end

return updateSingleGame;
