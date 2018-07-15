HallSetting = {}

function HallSetting.initSetting()
    require("data.ServerAddress")
    HallSetting.host = ServerHost;
    HallSetting.port = ServerPort;

    HallSetting.games = {};
    --[[
        三人斗地主   200
        百人斗地主   201
        二人斗地主   202
        单挑斗地主   203
    ]]--
    local landlordGame = {200,201,202,203};
    HallSetting.games["landlordCutie"] = landlordGame;
    --[[
        拼牛场     27
        百人牛牛   103
        牛牛视频   105
        二人牛牛   106
    ]]--
    local niuniuGame = {27,103,105,106}
    HallSetting.games["niuniu"] = niuniuGame

    
    local zhajinhuaGame = {6,5102}
    HallSetting.games["zhajinhua"] = zhajinhuaGame

    local fishingGame = {2010}
    HallSetting.games["fishing"] = fishingGame

end

function HallSetting.getAllGameKindID()
    local kinds = {}

    for k,v in pairs(HallSetting.games) do
        if type(v) ~= "table" then
            table.insert(kinds, v)

        else
            for kk,vv in pairs(v) do
                if type(vv) ~= "table" then
                    table.insert(kinds, vv)

                end
            end
        end
    end
    return kinds
end

function HallSetting.getAllKindID(gameName)

    if HallSetting.games and HallSetting.games[gameName] then
       
       return HallSetting.games[gameName];

    else

        return {};

    end

end

function HallSetting.getAppID(gameName)
    if gameName == "landlordCutie" then
        return 1005
    elseif gameName == "niuniu" then
        return 1002
    elseif gameName == "zhajinhua" then
        return 1032
    elseif gameName == "fishing" then
        return 1038
    end
end