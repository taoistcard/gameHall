function showShare(text,image,typeStr,url,title)

    --提示：
    -- 微信和qq分享，请合理设置title、text、url，长度控制好，否则会显示不全,title和text长度控制在32个字内
    -- 短信分享需要只需设置text，短信内容为text内容

    if device.platform == "ios" then

        local args = {text = text, image = image, typeStr = typeStr}
        --local luaoc = require "cocos.cocos2d.luaoc"
        local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","showShare",args)
        if ok == false then
            print("luaoc调用出错 showShare")
        end
        
    elseif device.platform == "android" then
        local javaMethodName = "showShare"
        local javaParams = {title,text,typeStr,url}
        local javaMethodSig = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V"
        --local luaj = require("cocos.cocos2d.luaj")
        local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
        if ok == false then
            print("luaj调用出错 showShare")
        end
    end

    return result;
end

function isWXAppInstalled()

    local result = false;

    if device.platform == "ios" then
        --local luaoc = require "cocos.cocos2d.luaoc"
        local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","isWXAppInstalled")
        if ok == false then
            --luaoc调用出错
            print("luaoc调用出错 isWXAppInstalled")
        end

        result = ret;
        
    elseif device.platform == "android" then
        local javaMethodName = "isWXAppInstalled"
        local javaParams = {pkg}
        local javaMethodSig = "()Z"
        --local luaj = require("cocos.cocos2d.luaj")
        local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
        if ok == false then
            print("luaj调用出错 isWXAppInstalled")
        end
        result = ret
    end

    return result;
end

function LoginByTencentQQ()
    Hall.showWaiting(5)
    --QQ登录(存储登录方式)
    Hall.nLoginType = 3
    AccountType = 3
    print("AccountType",AccountType)
    if device.platform == "ios" then
        local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","tencentOAuth")
        if ok == false then
            print("luaoc调用出错 LoginByTencentQQ")
        end
        
    elseif device.platform == "android" then
        local javaMethodName = "tencentOAuth"
        local javaParams = {function(event) print( "Java method callback value is [" .. event .. "]" ) end }
        local javaMethodSig = "(I)V"
        --local luaj = require("cocos.cocos2d.luaj")
        local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
        if ok == false then
            print("luaoc调用出错 LoginByTencentQQ")
        end
    else
        print("this platform do not support qq login!")
    end
end