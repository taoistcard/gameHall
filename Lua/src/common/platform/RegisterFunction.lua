
function registerLuaFunctions()
    if device.platform == "ios" then
        local args = {onUnitedPlatFormLoginSuccess = onUnitedPlatFormLoginSuccess,
                    onUnitedPlatFormAppPurchaseResult = onUnitedPlatFormAppPurchaseResult,
                    onUnitedPlatFormAppCommandResult = onUnitedPlatFormAppCommandResult,
                    onUnitedPlatFormAppAvatarUploadResult = onUnitedPlatFormAppAvatarUploadResult,
                    onUnitedPlatFormAppAvatarDownloadResult = onUnitedPlatFormAppAvatarDownloadResult,
                    OnAppRestorePurchaseList = OnAppRestorePurchaseList,
                    onRequestRecommandAppListSuccess = onRequestRecommandAppListSuccess,
                }
        
        local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","registerLuaListener",args)
        
    elseif device.platform == "android" then
    
    end

    --请求游戏推荐列表
    -- PlatformRequestRecommandAppList()
    
end