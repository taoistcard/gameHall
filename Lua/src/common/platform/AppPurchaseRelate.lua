--网页版免费金币
function FreeChip(freeChipUrl)
    if device.platform == "ios" then
        local args = {url = freeChipUrl}
        local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","freeChip",args)
        if ok == false then
            --luaoc调用出错
            print("luaoc调用出错:FreeChip")
        end
    elseif device.platform == "android" then
        local javaMethodName = "freeChip"
        local javaParams = {freeChipUrl}
        local javaMethodSig = "(Ljava/lang/String;)V"
        local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
        if ok == false then
            print("lua调用出错:FreeChip")
        end
        
    else
        print("FreeChip!")
    end

end

function onUnitedPlatFormAppPurchaseResult(event)

    local _type = type(event)
    local code=nil
    if _type == "table" then
        code = event.resultCode
        
    elseif _type == "string" then
        local t = string.split(event, ",")
        code = tonumber(t[1])
    end

    print("充值成功回调resultCode:"..code)
    if code == 1 then
        -- 刷新用户数据
        local function onInterval(dt)
            -- UserService:sendQueryInsureInfo()
            -- UserService:queryTodayWasPay();
            -- UserService:AppPurchaseResult()
            BankInfo:sendQueryRequest()
            Hall.showTips("充值成功！", 1)
        end
        --延迟两秒是因为充值时间过长导致断线，这时查询信息服务端不返回，断线重练需要1秒时间，所以设置延迟3秒
        local scheduler = require("framework.scheduler")
        scheduler.performWithDelayGlobal(onInterval, 3)
    end
end

--计费通用接口
function AppPurcharse(args)
    local chargeChannel = args.channel
    local chargePrice = args.price
    local productType = args.product
    local chargeArgs = nil
    if productType then
        chargeArgs = PurcharseConfig:getChargeArgsByProduct(chargeChannel, productType)
    else
        chargeArgs = PurcharseConfig:getChargeArgs(chargeChannel, chargePrice)
    end    
    print("AppPurcharse=====", chargeChannel, chargePrice, productType)
    -- local chargeArgs = PurcharseConfig:getChargeArgs(chargeChannel, chargePrice)

    if chargeChannel ==1 then --"微信支付" 
        WeiXinAppPurchases(chargeArgs)

    elseif chargeChannel ==2 then --"支付宝"
        AliPayAppPurchases(chargeArgs)

    elseif chargeChannel ==3 then --"银联卡"
        print("unionpay is not suport!")

    elseif chargeChannel ==4 then --"京东支付"
        print("jd pay is not suport!")

    elseif chargeChannel ==5 or chargeChannel ==7 or chargeChannel ==8 then --"其他"
        PlatformWebMobilePay(chargeArgs)
    
    else --"review/apple"
        PlatformAppPurchases(chargeArgs)
    
    end

end

function PlatformWebMobilePay(args)
    print("PlatformWebMobilePay------", args.packageID)

    if device.platform == "ios" then
        local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","PlatformWebMobilePay",args)
        if ok == false then
            --luaoc调用出错
            print("luaoc调用出错:PlatformWebMobilePay")
        end
        
    elseif device.platform == "android" then
        local javaMethodName = "PlatformAppPurchases"
        local javaParams = {args.packageID}
        local javaMethodSig = "(Ljava/lang/String;)V"
        local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
        if ok == false then
            print("lua调用出错:PlatformAppPurchases")
        end
        
    else
        print("PlatformWebMobilePay!")
    end
end

function PlatformAppPurchases(args)
    print("PlatformAppPurchases------", args.packageID, args.productId)

    if device.platform == "ios" then
        local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","PlatformAppPurchases",args)
        if ok == false then
            --luaoc调用出错
            print("luaoc调用出错:PlatformAppPurchases")
        end
        
    elseif device.platform == "android" then
        local javaMethodName = "PlatformAppPurchases"
        local javaParams = {args.packageID}
        local javaMethodSig = "(Ljava/lang/String;)V"
        local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
        if ok == false then
            print("lua调用出错:PlatformAppPurchases")
        end
        
    else
        print("PlatformAppPurchases!")
    end
end

--微信支付
function WeiXinAppPurchases(args)
    print("WeiXinAppPurchases------", args.packageID, args.productId)

    if device.platform == "ios" then
        local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","WeiXinAppPurchases",args)
        if ok == false then
            --luaoc调用出错
            print("luaoc调用出错:WeiXinAppPurchases")
        end
    elseif device.platform == "android" then
        local javaMethodName = "PlatformWechatPurchases"
        local javaParams = {args.packageID}
        local javaMethodSig = "(Ljava/lang/String;)V"
        local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
        if ok == false then
            print("lua调用出错:PlatformWechatPurchases")
        end
    else
        print("WeiXinAppPurchases!")
    end
end

--支付宝支付
function AliPayAppPurchases(args)
    print("AliPayAppPurchases------", args.packageID, args.productId)
    if device.platform == "ios" then
        local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","AliPayAppPurchases",args)
        if ok == false then
            --luaoc调用出错
            print("luaoc调用出错:AliPayAppPurchases")
        end
    elseif device.platform == "android" then
        local javaMethodName = "PlatformAlipayPurchases"
        local javaParams = {args.packageID}
        local javaMethodSig = "(Ljava/lang/String;)V"
        local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
        if ok == false then
            print("lua调用出错:AliPayAppPurchases")
        end
    else
        print("AliPayAppPurchases!")
    end
end

function PlatformAppRestorePurchases(args)
    if device.platform == "ios" then
        local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","PlatformAppRestorePurchases",args)
        if ok == false then
            --luaoc调用出错
            print("luaoc调用出错:PlatformAppRestorePurchases")
        end
        
    elseif device.platform == "android" then
        local javaMethodName = "PlatformAppPurchases"
        local javaParams = {args.packageID}
        local javaMethodSig = "(Ljava/lang/String;)V"
        local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
        if ok == false then
            print("lua调用出错:PlatformAppPurchases")
        end
        
    else
        print("PlatformAppPurchases!")
    end
end

function PlatformAchiveRestorePurchaseList()
    if device.platform == "ios" then
        local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","PlatformAchiveRestorePurchaseList")
        if ok == false then
            --luaoc调用出错
            print("luaoc调用出错:PlatformAppRestorePurchases")
        end
        
    elseif device.platform == "android" then
        -- local javaMethodName = "PlatformAppPurchases"
        -- local javaParams = {args.packageID}
        -- local javaMethodSig = "(Ljava/lang/String;)V"
        -- local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
        -- if ok == false then
        --     print("lua调用出错:PlatformAppPurchases")
        -- end
        
    else
        print("PlatformAppPurchases!")
    end
end

function OnAppRestorePurchaseList(event)
    print("OnAppRestorePurchaseList!!")
    AppRestorePurchaseList = AppRestorePurchaseList or {}
    cleanTable(AppRestorePurchaseList)
    copyTable(event, AppRestorePurchaseList)
    
    for k,v in pairs(AppRestorePurchaseList) do
        print("OnAppRestorePurchaseList:",v.userID,v.orderID,v.orderDate,v.receipt)
    end
end
--获取渠道信息
function PlatformGetChannel()
    if device.platform == "android" then    
        local javaMethodName = "getChannel"
        local javaParams = {}
        local javaMethodSig = "()Ljava/lang/String;"
        local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
        if ok == true then

            local t = string.split(ret, ",")
            AppChannel = t[1]
            AppChannelName = t[2]
            return true
        end
        return false
    elseif device.platform =="ios" then
        return false
    else
        return true
    end
end