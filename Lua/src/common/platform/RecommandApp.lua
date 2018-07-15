function PlatformRequestRecommandAppList()

    if device.platform == "ios" then

        --local luaoc = require "cocos.cocos2d.luaoc"
        local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","PlatformRequestRecommandAppList")
        if ok == false then
            print("luaoc调用出错 PlatformRequestRecommandAppList")
        end
        
    elseif device.platform == "android" then
        local javaMethodName = "PlatformRequestRecommandAppList"
        local javaParams = {}
        local javaMethodSig = "()V"
        --local luaj = require("cocos.cocos2d.luaj")
        local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
        if ok == false then
            print("luaj调用出错 PlatformRequestRecommandAppList")
        end
    end
end

function onRequestRecommandAppListSuccess(event)

    local _type = type(event)

    local appListData;

    if _type == "table" then
        print("onRequestRecommandAppListSuccess:",event.data)
        appListData = json.decode(event.data)
        RunTimeData:setRecommandAppListData(appListData)
    elseif _type == "string" then
        print("onRequestRecommandAppListSuccess..", event)
    end
end