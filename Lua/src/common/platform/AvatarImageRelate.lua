--下载头像--userID必须传的是统一平台userId
function PlatformDownloadAvatarImage(userID, fileName)
    if fileName and userID then
        
        print("==========PlatformDownloadAvatarImage --- userID : ", userID, ", fileName:", fileName)
        if device.platform == "ios" then
            local args = {userID = userID}
            local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","PlatformDownloadAvatarImageWithUser",args)
            if ok == false then
                --luaoc调用出错
                print("luaoc调用出错:PlatformDownloadAvatarImageWithUser")
            end

        elseif device.platform == "android" then
            local javaMethodName = "downloadHeadImage"
            local javaParams = {userID, fileName}
            local javaMethodSig = "(ILjava/lang/String;)V"
            local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
            if ok == false then
                print("luaoj调用出错 PlatformDownloadAvatarImage")
            end
        else
            -- print("PlatformDownloadAvatarImage===userID:", userID, "fileName:", fileName)
        end

    end
end

--//打开相册
--@param type  0相册 1相机
function PlatformOpenPhoto(type)
    if device.platform == "ios" then
        if type == 1 then
            local ok,ret = luaCallFun.callStaticMethod("MethodForLua","PlatformOpenCamera")
            if ok == false then
                --luaoc调用出错
                print("luaoc调用出错:PlatformOpenCamera")
            end
        else
            local ok,ret = luaCallFun.callStaticMethod("MethodForLua","PlatformOpenPhoto")
            if ok == false then
                --luaoc调用出错
                print("luaoc调用出错:PlatformOpenPhoto")
            end
        end
    elseif device.platform == "android" then
        local javaMethodName = "pickerImage"
        local javaParams = {type}
        local javaMethodSig = "(I)V"
        local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
        if ok == false then
            print("luaoj调用出错 PlatformOpenPhoto")
        end
    else
        print("not ios or android PlatformOpenPhoto!")
    end
end

--上传头像回调
function onUnitedPlatFormAppAvatarUploadResult(event)
    local _type = type(event)
    local code=nil
    local md5=nil
    local userID = nil
    if _type == "table" then
        code = event.resultCode
        md5 = event.md5
        userID = event.userID
        
    elseif _type == "string" then
        local t = string.split(event, ",")
        code = tonumber(t[1])
        md5 = t[2]
        userID = t[3]
    end

    print("onUnitedPlatFormAppAvatarUploadResult---resultCode:"..code,"md5 : ",md5)

    if code == 1 then
        
        if not userID then
            --统一平台userID--统一平台userID--统一平台userID--重要的事情说三遍,不是AccountInfo.userId
            print("异常:上传头像回调中统一平台userID为nil")
        end

        print("上传头像回调......",AccountInfo.tokenId,AccountInfo.userId,userID,md5)

        local fileName = RunTimeData:getLocalAvatarImageUrlByTokenID(userID)
        cc.Director:getInstance():getTextureCache():reloadTexture(fileName)

        local function onInterval(dt)
            --通知服务端
            AccountInfo.faceId = 999
            AccountInfo.headFileMD5 = md5
            AccountInfo:sendChangeFaceIdRequest(999)
            AccountInfo:sendSetPlatformFaceRequest(md5)
            HallEvent:dispatchEvent({name = HallEvent.AVATAR_UPLOAD_SUCCESS, md5 = md5, userID = userID})
        end

        local scheduler = require("framework.scheduler")
        scheduler.performWithDelayGlobal(onInterval, 1)
    else
        Hall.showTips("上传失败，请联系客服！")
    end
end

--下载头像完成的回调
function onUnitedPlatFormAppAvatarDownloadResult(event)
    local _type = type(event)
    local code=nil
    local userID = nil--这个是统一平台的USERID
    local md5 = nil
    local url = nil--下载后的头像的存放地址
    if _type == "table" then
        code = event.resultCode
        userID = event.tokenID
        url = event.data
    elseif _type == "string" then
        local t = string.split(event, ",")
        code = tonumber(t[1])
        userID = t[2]
        md5 = t[3]
    end

    if code == 1 then
        local fileName = getLocalAvatarImageUrlByUserID(userID)
        cc.Director:getInstance():getTextureCache():reloadTexture(fileName)

        if  device.platform == "ios" then
            print("获取头像地址回调onUnitedPlatFormAppAvatarDownloadResult---resultCode:"..code, event.data, "tokenID",event.tokenID)
            HallEvent:dispatchEvent({name = HallEvent.AVATAR_DOWNLOAD_URL_SUCCESS, url = event.data, userId = event.tokenID})

            print("获取头像地址成功！", url)
        elseif device.platform == "android" then
            HallEvent:dispatchEvent({name = HallEvent.AVATAR_DOWNLOAD_URL_SUCCESS, userId = userID})
        end
    elseif code == 2 then--下载失败
        print("下载头像失败！！")
    end
end

--获取自定义头像地址
function getLocalAvatarImageUrlByUserID( userId )
    if device.platform == "ios" then
        return cc.FileUtils:getInstance():getWritablePath().."avatarImages/"..userId
    elseif device.platform == "android" then
        local javaMethodName = "getCustomHeadImagePath"
        local javaParams = {userId}
        local javaMethodSig = "(Ljava/lang/String;)Ljava/lang/String;"
        local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
        if ok == true then
            print("图片路径=====", ret)
            return ret
        else
            print("luaoj调用出错 getCustomHeadImagePath")
        end
        
    else
        return cc.FileUtils:getInstance():getWritablePath().."avatarImages/"..userId
    end
end
