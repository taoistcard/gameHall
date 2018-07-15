BindTool = {}
isDEBUG = 2
cc(BindTool):addComponent("components.behavior.EventProtocol"):exportMethods()

BindTool.register = function(target, varName, default)
    target[varName] = default
    target["set" .. string.upper(string.sub(varName, 1, 1)) .. string.sub(varName, 2, -1)] = function(tar, values) 
        tar[varName] = values
        BindTool:dispatchEvent({name = tostring(target) .. varName, value = values})
    end

    target["get" .. string.upper(string.sub(varName, 1, 1)) .. string.sub(varName, 2, -1)] = function(tar)
        return tar[varName]
    end
end

BindTool.bind = function(target, varName, func)
    return BindTool:addEventListener(tostring(target) .. varName, func)
end

BindTool.unbind = function(handlerIndex)
    BindTool:removeEventListener(handlerIndex)
end
