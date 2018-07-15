function onUnitedPlatFormLoginSuccess(event)
    local _type = type(event)
    local userID
    local nickName
    local sessionID
    local isBindMobile
    if _type == "table" then
        userID = event.userID
        nickName = event.nickName
        sessionID = event.sessionID
        isBindMobile = event.isBindMobile
    elseif _type == "string" then
        local t = string.split(event, ",")
        userID = t[1]
        nickName = t[2]
        sessionID = t[3]
    end

    SessionId = sessionID
    AccountInfo.nickName = nickName
    AccountInfo.cy_userId = userID
    AccountInfo.sessionId = SessionId
    DataManager:setMyPlatformID(userID)

    print("统一平台登陆成功:","isBindMobile",isBindMobile, userID, nickName, sessionID, Hall.nLoginType)
    -- BindMobilePhone = isBindMobile
    -- cc.UserDefault:getInstance():setBoolForKey("isBindMobile", isBindMobile)
    --向Umeng发送统计事件
    if Hall.nLoginType == 1 then
        onUmengEvent("1060")
    elseif Hall.nLoginType == 2 then
        onUmengEvent("1061")
    elseif Hall.nLoginType == 3 then
        onUmengEvent("1062")
    elseif Hall.nLoginType == 4 then
        onUmengEvent("1063")
    end

    scheduler.performWithDelayGlobal(function() 
        -- Hall:continue();
        AccountInfo:sendLoginRequest(nickName)
        --查询补单列表
        PlatformAchiveRestorePurchaseList()
    end, 0.1)
    

end

function sendRegisterFast()

-- if true then
--     AccountInfo:sendSimulatorLoginRequest("45622")
--     return
-- end
    Hall.showWaiting(5)
    --游客登录(存储登录方式)
    if TESTSERVER_93 then
        AccountInfo:sendSimulatorLoginRequest("45622")
        return
    end
    if device.platform == "ios" then
        local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","guestLogin")
        if ok == false then
            --luaoc调用出错
            print("luaoc调用出错 guestLogin失败")
        end
        
    elseif device.platform == "android" then
        local ok,ret  = luaCallFun.callStaticMethod(javaClassName,"guestLogin",{},"()V")
        if ok == false then
            print("luaj调用出错 guestLogin失败")
        end
    else
        -- Hall:continue();
        AccountInfo:sendSimulatorLoginRequest("45622")
    end
end

function PlatformLoginAcount(phoneStr, pwdStr)  
    Hall.showWaiting(5)
    --手机号登录(存储登录方式)
    AccountType = 4
    print("AccountType",AccountType)
    if device.platform == "ios" then
        local args = {account = phoneStr, password = pwdStr}
        local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","PlatformLoginAcount",args)
        if ok == false then
            --luaoc调用出错
            print("lua调用出错:PlatformLoginAcount")
        end
        
    elseif device.platform == "android" then
        local javaMethodName = "PlatformLoginAcount"
        local javaParams = {phoneStr, pwdStr}
        local javaMethodSig = "(Ljava/lang/String;Ljava/lang/String;)V"
        local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
        if ok == false then
            print("lua调用出错:PlatformLoginAcount")
        end
        
    else
        print("PlatformLoginAcount login!")
    end
end

function PlatformSwtichServer()
    -- 切换服务器
    if device.platform == "ios" then
        local args = {serverID="3"}
        local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","PlatformSwtichServer",args)
        if ok == false then
            print("luaoc调用出错:PlatformSwtichServer")
        end
        
    elseif device.platform == "android" then
        local javaMethodName = "PlatformSwtichServer"
        local javaParams = {3}
        local javaMethodSig = "(I)V"
        local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
        if ok == false then
            print("luaoc调用出错 PlatformSwtichServer")
        end

    else
        print("PlatformSwtichServer!")
    end
end

--手机号绑定回调
function onUnitedPlatFormBindPhoneResult(event)
    local _type = type(event)
    local code=nil
    if _type == "table" then
        code = event.resultCode
    elseif _type == "string" then
        local t = string.split(event, ",")
        code = tonumber(t[1])
    end
    --CY_CMD_BIND_PHONE       2
    print("手机号绑定回调onUnitedPlatFormBindPhoneResult===",code)
    if tonumber(code) == 1 then
        print("手机号绑定回调")
        AccountInfo:setBindingInfo(true)
        BindMobilePhone = true
    end
end

function onUnitedPlatFormAppCommandResult(event)
    if event then
        local code = event.code;
        local cmd = event.cmd;
        local msg = event.error;

        if code == 1 and cmd == 4 then --找回密码返回
            print("找回密码返回 : ", code, cmd)
            HallCenter:sendModifyPwdEvent(code, msg)
        end
    end
end

function PlatformPhoneRegCheckCode(phoneStr)
    Hall.showWaiting(5)
    if device.platform == "ios" then
        local args = {phone = phoneStr}
        local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","PlatformPhoneRegCheckCode",args)
        if ok == false then
            --luaoc调用出错
            print("luaoc调用出错:PlatformPhoneRegCheckCode失败")
        end
        
    elseif device.platform == "android" then
        local javaMethodName = "PlatformPhoneRegCheckCode"
        local javaParams = {phoneStr}
        local javaMethodSig = "(Ljava/lang/String;)V"
        local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
        if ok == false then
            print("lua调用出错:PlatformPhoneRegCheckCode")
        end
        
    else
        print("PlatformPhoneRegCheckCode login!")
    end
end

function PlatformLoginPhone(phoneStr,codeStr,pwdStr)

    --手机号登录(存储登录方式)
    Hall.nLoginType = 2
    AccountType = 2
    print("AccountType",AccountType)
    if device.platform == "ios" then
        local args = {phone = phoneStr, authCode = codeStr, password = pwdStr}
        local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","PlatformLoginPhone",args)
        if ok == false then
            --luaoc调用出错
            print("luaoc调用出错:PlatformLoginPhone失败")
        end
        
    elseif device.platform == "android" then
        local javaMethodName = "PlatformLoginPhone"
        local javaParams = {phoneStr,codeStr,pwdStr}
        local javaMethodSig = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V"
        local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
        if ok == false then
            print("lua调用出错:PlatformLoginPhone")
        end
        
    else
        print("PlatformLoginPhone login!")
    end
end

function PlatformPhoneBindCheckCode(phoneStr)
    Hall.showWaiting(5)
    if device.platform == "ios" then
        local args = {phone = phoneStr}
        local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","PlatformPhoneBindCheckCode",args)
        if ok == false then
            --luaoc调用出错
            print("luaoc调用出错:PlatformPhoneBindCheckCode")
        end
        
    elseif device.platform == "android" then

    else
        print("PlatformPhoneBindCheckCode login!")
    end
end

function PlatformBindPhone(phoneStr,codeStr)
    
    if device.platform == "ios" then
        local args = {phone = phoneStr, authCode = codeStr}
        local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","PlatformBindPhone",args)
        if ok == false then
            --luaoc调用出错
            print("luaoc调用出错:PlatformBindPhone失败")
        end
        
    elseif device.platform == "android" then
        
    else
        print("PlatformBindPhone login!")
    end
end

function PlatformFindPasswordSmsAuth(phoneStr)
    
    if device.platform == "ios" then
        local args = {phone = phoneStr}
        local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","PlatformFindPasswordSmsAuth",args)
        if ok == false then
            --luaoc调用出错
            print("luaoc调用出错 btn_wjmm_getcode失败")
        end
        
    elseif device.platform == "android" then
        local javaMethodName = "PlatformFindPasswordSmsAuth"
        local javaParams = {phoneStr}
        local javaMethodSig = "(Ljava/lang/String;)V"
        local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
        if ok == false then
            print("lua调用出错:PlatformFindPasswordSmsAuth")
        end
        
    else
        print("PlatformFindPasswordSmsAuth login!")
    end
    
end

function PlatformFindPasswordSms(phoneStr, codeStr, pwdStr, callBack)

    if device.platform == "ios" then
        local args = {phone = phoneStr, authCode = codeStr, password = pwdStr}
        local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","PlatformFindPasswordSms",args)
        if ok == false then
            --luaoc调用出错
            print("luaoc调用出错 btn_wjmm_ok失败")
        end
        
    elseif device.platform == "android" then
        _callBack = callBack;
        local javaMethodName = "PlatformFindPasswordSms"
        local javaParams = {phoneStr, codeStr, pwdStr}
        local javaMethodSig = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V"
        local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
        if ok == false then
            print("lua调用出错:PlatformFindPasswordSms")
        end
        
    else
        print("PlatformFindPasswordSms!")
    end
end

function PlatformFeedback()
    if device.platform == "ios" then
        local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","PlatformFeedback")
        if ok == false then
            --luaoc调用出错
            print("luaoc调用出错:PlatformFeedback")
        end
        
    elseif device.platform == "android" then
        local javaMethodName = "PlatformFeedback"
        local javaParams = {}
        local javaMethodSig = "()V"
        local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
        if ok == false then
            print("lua调用出错:PlatformFeedback")
        end

    else
        print("PlatformFeedback!")
    end
end