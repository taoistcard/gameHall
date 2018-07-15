function onUmengEvent(eventid)
    if device.platform == "ios" then
        local args = {EventId = eventid
        }
    
        local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","onUmengEvent",args)
        if ok == false then
            print("luaoc调用出错:onUmengEvent")
        end

    elseif device.platform == "android" then
    
    end
end

function onUmengEventBegin(eventid)
    if device.platform == "ios" then
        local args = {EventId = eventid
        }
    
        local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","umengEventBegin",args)
        if ok == false then
            print("luaoc调用出错:UmengEventBegin")
        end
        
    elseif device.platform == "android" then
    
    end
end

function onUmengEventEnd(eventid)
    if device.platform == "ios" then
        local args = {EventId = eventid
        }
    
        local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","umengEventEnd",args)
        if ok == false then
            print("luaoc调用出错:UmengEventEnd")
        end

    elseif device.platform == "android" then
    
    end
end

function UmengEvent(event)
    --Umeng切换alias
    if device.platform == "ios" then
        
        local args = {eventID = event.id, eventName = event.name}
        -- local luaoc = require "cocos.cocos2d.luaoc"
        local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","OnCustomerEvent",args)
        if ok == false then
            --luaoc调用出错
            print("luaoc调用出错 OnCustomerEvent")
        end

    elseif device.platform == "android" then
        local javaMethodName = "OnUMengEvent"
        local javaParams = {event.id,event.name}
        local javaMethodSig = "(Ljava/lang/String;Ljava/lang/String;)V"
        local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
        if ok == true then
            return ret
        end
        
    else
        print("UmengEvent!")
    end
    
end

function AddUmengAlias(dwUserID)
    --Umeng切换alias
    if device.platform == "ios" then
        local args = {alias = dwUserID, type = "UserID"}
        -- local luaoc = require "cocos.cocos2d.luaoc"
        local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","addUmengAlias",args)
        if ok == false then
            --luaoc调用出错
            print("luaoc调用出错 AddUmengAlias")
        end
    elseif device.platform == "android" then

    else
        print("AddUmengAlias!")
    end
end