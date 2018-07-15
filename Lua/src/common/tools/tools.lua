--=======================================
-- Game Development With Lua
-- by Dragon
-- (c) copyright 2014
-- All Rights Reserved.
--=======================================
-- filename:  tools.lua
-- author:    Dragon
-- created:   2014-5-20
-- descrip:   In game play screen and interfaces
--=======================================
require("tools.improve");

function allKeyForTable(st)
    local keys = {}
    for k, v in pairs(st or {}) do
        table.insert(keys, k)
    end
    return keys
end

function mergeTable(resTable,addTable)
    local dis = resTable or {}
    local tab = addTable or {}
    for k, v in pairs(tab or {}) do
        if type(v) ~= "table" then
            dis[k] = v;
        else
            dis[k] = dis[k] or {};
            mergeTable(dis[k], v);
        end
    end
    return dis
end

function copyTable(st,disTable)
    local tab = disTable or {}
    for k, v in pairs(st or {}) do
        if type(v) ~= "table" then
            tab[k] = v
        else
            tab[k] = copyTable(v)
        end
    end
    return tab
end

function copyProtoTable(pTable)
    local tab = {}

    if pTable._fields == nil then

        for i,v in ipairs(pTable or {}) do

            if type(v) ~= "table" then
                tab[i] = v;
            else
                tab[i] = copyProtoTable(v);
            end

        end

    else

        for k, v in pairs(pTable._fields or {}) do

            local key = k.name;

            if type(v) ~= "table" then
                tab[key] = v;
            else
                tab[key] = copyProtoTable(v);
            end
        end

    end


    return tab
end


-- 参数:待分割的字符串,分割字符
-- 返回:子串表.(含有空串)
function stringSplit(str, split_char)
    local sub_str_tab = {};
    while (true) do
        local pos = string.find(str, split_char);
        if (not pos) then
            sub_str_tab[#sub_str_tab + 1] = str;
            break;
        end
        local sub_str = string.sub(str, 1, pos - 1);
        sub_str_tab[#sub_str_tab + 1] = sub_str;
        str = string.sub(str, pos + 1, #str);
    end

    return sub_str_tab;
end

function serialize(obj)  
    local lua = ""  
    local t = type(obj)  
    if t == "number" then  
        lua = lua .. obj  
    elseif t == "boolean" then  
        lua = lua .. tostring(obj)  
    elseif t == "string" then  
        lua = lua .. string.format("%q", obj)  
    elseif t == "table" then  
        lua = lua .. "{\n"  
    for k, v in pairs(obj) do  
        lua = lua .. "[" .. serialize(k) .. "]=" .. serialize(v) .. ",\n"  
    end  
    local metatable = getmetatable(obj)  
        if metatable ~= nil and type(metatable.__index) == "table" then  
        for k, v in pairs(metatable.__index) do  
            lua = lua .. "[" .. serialize(k) .. "]=" .. serialize(v) .. ",\n"  
        end  
    end  
        lua = lua .. "}"  
    elseif t == "nil" then  
        return nil  
    else  
        error("can not serialize a " .. t .. " type.")  
    end  
    return lua  
end  
  
function unserialize(lua)  
    local t = type(lua)  
    if t == "nil" or lua == "" then  
        return nil  
    elseif t == "number" or t == "string" or t == "boolean" then  
        lua = tostring(lua)  
    else  
        error("can not unserialize a " .. t .. " type.")  
    end  
    lua = "return " .. lua  
    local func = loadstring(lua)  
    if func == nil then  
        return nil  
    end  
    return func()  
end  


function random(startNumber,endNumber)
    return math.random(startNumber,endNumber)
end

function md5(source)

    local res;
    if type(source) == "number" then
        res = source;
    elseif type(source) == "string" then
        res = tonumber(source);
    else
        return source;
    end

    local dis = 0;

    local design = "Dragon";
    for i = 1, 10 do
        
        local key = string.byte(design, i % string.len(design) + 1);
        local single = math.floor(res / math.pow(10,i-1)) % 10;
        dis = dis + single * key * key;

        dis = tonumber(string.reverse(string.format("%09d",dis)));

        if dis > 1000000000 then
            dis = dis - 1000000000;
        end

    end

    return string.format("%d",dis);

end

--data

function getResVersion()

    local updPath = CCFileUtils:sharedFileUtils():getWritablePath().."upd/flist.txt";
    local updExsit = CCFileUtils:sharedFileUtils():isFileExist( CCFileUtils:sharedFileUtils():fullPathForFilename(updPath) );
    if updExsit then
        local flistStr = cc.FileUtils:getInstance():getStringFromFile(updPath)
        local flist = lua_do_string(flistStr)
        return flist.version;
    end

    local resPath = CCFileUtils:sharedFileUtils():fullPathForFilename("res/flist.txt");
    if string.len(resPath) > 13 then
        local flistStr = cc.FileUtils:getInstance():getStringFromFile(resPath)
        local flist = lua_do_string(flistStr)
        return flist.version;

    end

    return 0;

end

--UI

function adapterLayer()

    local layer = display.newLayer();
    --local layer = display.newColorLayer(ccc4(255,0,0,255));
    layer:setContentSize( CCSize(DESIGN_SCREEN_WIDTH, DESIGN_SCREEN_HEIGHT) );
    layer:ignoreAnchorPointForPosition(false);
    layer:setAnchorPoint(ccp(0.5, 0.5));
    layer:setPosition(display.width / 2, display.height / 2);
    return layer

end

function fullColorLayer(color)

    local layer = display.newColorLayer(color);
    layer:ignoreAnchorPointForPosition(false);
    layer:setAnchorPoint(ccp(0.5, 0.5));
    layer:setPosition(DESIGN_SCREEN_WIDTH / 2, DESIGN_SCREEN_HEIGHT / 2);
    return layer

end

function getNodeCenter(node)

    local width = node:getContentSize().width;
    local height = node:getContentSize().height;

    return cc.p(width/2,height/2);

end

function getSrcreeCenter()

    local winSize = cc.Director:getInstance():getWinSize();
    return cc.p(winSize.width/2,winSize.height/2);

end



-----add---------------------------------------------------------------------------------
function removeItem(list, item, removeAll)
    local rmCount = 0
    for i = 1, #list do
        if list[i - rmCount] == item then
            table.remove(list, i - rmCount)
            if removeAll then
                rmCount = rmCount + 1
            else
                break
            end
        end
    end
end

function cleanTable(localTable)
    for i=#localTable, 1, -1 do
        table.remove(localTable,i)
    end
end

function isEmptyString(pStr)
    if pStr == nil or pStr == "" then
        return true
    end
    return false
end

function FormotGameNickName(nickname,len)
    if nickname==nil then
        return ""
    end
    local lengthUTF_8 = #(string.gsub(nickname, "[\128-\191]", ""))
    if lengthUTF_8 <= len then
        return nickname
    else
        local matchStr = "^"
        for var=1, len do
            matchStr = matchStr..".[\128-\191]*"
        end
        local str = string.match(nickname, matchStr)
        return string.format("%s..",str);
    end
end

--格式化数字
--超过6位数，截断万位，用万字替代
--超过9位数，截断亿位，用亿字替代
function FormatNumToString(num)
    
    local s = num;
    local len = string.len(tostring(num));
    
    if len >= 6 and len < 9 then
        if len <= 8 then
            s = string.format("%.1f", num/10000) .. "万"
        else
            s = string.format("%.0f", num/10000) .. "万"
        end
    elseif len >= 9 then
        if len <= 10 then
            s = string.format("%.1f", num/100000000) .. "亿"
        else
            s = string.format("%.0f", num/100000000) .. "亿"
        end
    end
    return s;
end

function FormatDigitToString(num,limit)
    
    local s = num;
    local len = string.len(tostring(num));
    
    if len >= 5 and len < 9 then
        s = string.format("%."..limit.."f", num/10000) .. "万"
    elseif len >= 9 then
        s = string.format("%."..limit.."f", num/100000000) .. "亿"
    end
    return s;
end

-- for CCLuaEngine
function __G__TRACKBACK__(errorMessage)
    print("----------------------------------------")
    print("LUA ERROR: "..tostring(errorMessage).."\n")
    print(debug.traceback("", 2))
    print("----------------------------------------")
end

