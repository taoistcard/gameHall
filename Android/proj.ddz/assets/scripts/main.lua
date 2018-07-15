function __G__TRACKBACK__(errorMessage)
    print("----------------------------------------")
    print("LUA ERROR: " .. tostring(errorMessage) .. "\n")
    print(debug.traceback("", 2))
    print("----------------------------------------")
end

require("lfs")
require("scripts.config");
require("framework.init")

package.path = package.path .. ";scripts/?.lua"

XPLAYER = false;
BindMobilePhone = false;
AccountType = 1--1游客，2.手机号登录,3.QQ登录,4.98账号登录

require("scripts.channel");

--NO_UPDATE = true;
NO_UPDATE = false;


LOAD_FROM_BIN = true
--LOAD_FROM_BIN = false;

function GameStart()

    if LOAD_FROM_BIN then

        cc.LuaLoadChunksFromZIP("app.bin");
        cc.LuaLoadChunksFromZIP("common.bin");

    end

    --modify protobuf path
    local modifyTable = {};
    for k,v in pairs(package.preload) do
        if string.find(k,"protobuf.") then
            local name = string.sub(k,10);
            modifyTable[name] = v;
        end
    end
    for k,v in pairs(modifyTable) do
        package.preload[k] = v;
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