function getAppVersion()

    local result = "1.0.0";

    if device.platform == "ios" then
        --local luaoc = require "cocos.cocos2d.luaoc"
        local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","appVersion")
        if ok == false then
            --luaoc调用出错
            print("luaoc调用出错 guestLogin失败")
        end

        result = ret;
        
    elseif device.platform == "android" then

    end

    return result;
end

function GetDeviceID()
    if device.platform == "ios" then
        local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","getDeviceID")
        if ok == true then
            return ret
        end
        
    elseif device.platform == "android" then    
        local javaMethodName = "getDeviceID"
        local javaParams = {}
        local javaMethodSig = "()Ljava/lang/String;"
        local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
        if ok == true then
            return ret
        end
        
    else

        require("gameConfig");
        local deviceid = DeviceID
        return deviceid

    end
end
function GetBundleID()
    if device.platform == "ios" then
        local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","getBundleID")
        if ok == true then
            return ret
        else
            print("luaoc调用出错 GetBundleID失败")
        end
        
    elseif device.platform == "android" then
    else
        return "a.b.c";
    end
    return "a.b.c";
end
--竖向打开webview
function openPortraitWebView(url)
    local result = "1.0.0";
    if device.platform == "ios" then

        local args = {url = url}
        local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","openPortraitWebView",args)
        if ok == false then
            print("luaoc调用出错 openPortraitWebView")
        end

        result = ret;
        
    elseif device.platform == "android" then
        local javaMethodName = "openWebView"
        local javaParams = {url,"portrait",true}--landscape/portrait
        local javaMethodSig = "(Ljava/lang/String;Ljava/lang/String;Z)V"
        --local luaj = require("cocos.cocos2d.luaj")
        local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
        if ok == false then
            print("luaj调用出错 openWebView")
        end
    end

    return result;
end

--打开webView
function openWebView(url)
    local result
    if device.platform == "ios" then
        local args = {url = url}
        local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","openWebView",args)
        if ok == false then
            print("luaoc调用出错 openWebView")
        end
        result = ret;
    elseif device.platform == "android" then
        local javaMethodName = "openWebView"
        local javaParams = {url,"",true}--landscape/portrait
        local javaMethodSig = "(Ljava/lang/String;Ljava/lang/String;Z)V"
        --local luaj = require("cocos.cocos2d.luaj")
        local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
        if ok == false then
            print("luaj调用出错 openWebView")
        end
        result = ret
    end

    return result;
end

--Emoji表情判断
function stringContainsEmoji(chestring)
    if device.platform == "ios" then
        local args = {checkString = chestring
        }
    
        local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","stringContainsEmoji",args)
        if ok == false then
            print("luaoc调用出错:stringContainsEmoji")
            return false
        end
        if ret == "true" then return true end
        return false
    elseif device.platform == "android" then
    
    end
end

--解压缩zip文件
function unZipFile(zipfile, unzippath)
    if device.platform == "ios" then
        local args = {filePath = zipfile,
                  unziptoPath = unzippath
        }
    
        local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","unZipFile",args)
        if ok == false then
            print("luaoc调用出错:unZipFile")
        end

    elseif device.platform == "android" then
        --调用cocos系统函数ZipUtils
    end
end