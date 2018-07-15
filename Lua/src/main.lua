function __G__TRACKBACK__(errorMessage)
    print("----------------------------------------")
    print("LUA ERROR: " .. tostring(errorMessage) .. "\n")
    print(debug.traceback("", 2))
    print("----------------------------------------")
end

require("lfs")
require("config")
require("gameConfig")
require("framework.init")


local projectPath = cc.FileUtils:getInstance():getWritablePath();
cc.FileUtils:getInstance():addSearchPath(projectPath);

package.path = package.path .. ";common/?.lua"
package.path = package.path .. ";hall/?.lua"

package.path = package.path .. ";preload/protobuf/?.lua" -- protobuf解析库

XPLAYER = true;

OnlineConfig_review = "off";

BindMobilePhone = false;

-- NO_LOGIN = true;

AccountType = 1--1游客，2.手机号登录,3.QQ登录,4.98账号登录


--NO_UPDATE = true;
NO_UPDATE = false;

--LOAD_FROM_BIN = true;
LOAD_FROM_BIN = false;

function GameStart()

    if LOAD_FROM_BIN then

       

    end

    --for protobuf path
    for k,v in pairs(package.preload) do
        print("-----preloadkey : ", k)
        if string.find(k,"protobuf.") then

            local name = string.sub(k,10);
            package.preload[name] = v;

        end

    end

    cc.FileUtils:getInstance():setPopupNotify(false);

    Hall = require("Hall");
    Hall:start();

end

if NO_UPDATE then

    GameStart();

else

    if LOAD_FROM_BIN then

        if cc.FileUtils:getInstance():isFileExist("upd/launcher.bin") then

            cc.LuaLoadChunksFromZIP("upd/launcher.bin");

        else

            cc.LuaLoadChunksFromZIP("res/launcher.bin");

        end

    end

    require("launcher.launcher").showScene();

end