-----------------------------------------------------------------------------
local Fishing = {}--class("Fishing");

function Fishing:ctor()

    self:setRes();

end


function Fishing:start()
    -- local gameLayer = require("layer.gameLayer").new();
    -- display.replaceScene(gameLayer:scene());
    self:setRes();
    local hall = require("layer.hallLayer").new();
    display.replaceScene(hall:scene());

end

function Fishing:setRes()   --CCFileUtils:sharedFileUtils():addSearchPath("optional/");
    
    local writablePath = cc.FileUtils:getInstance():getWritablePath()
    local UPD_FOLDER = writablePath.."upd/fishing"

    --for phone
    cc.FileUtils:getInstance():addSearchPath("res/fishing", true);
    --for dev
    cc.FileUtils:getInstance():addSearchPath("baseRes/fishing", true);
    cc.FileUtils:getInstance():addSearchPath("expandRes/fishing", true);
    --for all
    cc.FileUtils:getInstance():addSearchPath(UPD_FOLDER, true);

    -- cc.FileUtils:getInstance():addSearchPath("res", true);
    
end

return Fishing;
