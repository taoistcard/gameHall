
luaCallFun = nil
javaClassName = nil

if device.platform == "ios" then
    luaCallFun = require("cocos.cocos2d.luaoc")
elseif device.platform == "android" then
    luaCallFun = require("cocos.cocos2d.luaj")
    -- if curGameName == "landlordCutie" then
        javaClassName = "com/zxsdk/UnitedPlatform/MethodForLuaJ"
    -- elseif curGameName == "niuniu" then
    --     javaClassName = "com.duole.game.client.niuniu/MethodForLuaJ"
    -- end
end
_callBack = nil

require("platform.UmengRelate")--必须先引用，别的函数有用到
require("platform.RegisterFunction")
require("platform.AppPurchaseRelate")
require("platform.AvatarImageRelate")
require("platform.RecommandApp")
require("platform.TencentRelate")
require("platform.ToolFunction")
require("platform.UnitedPlatFormLogin")

registerLuaFunctions()



































