require("cocos.init")
require("framework.init")

local Landlord = {};

function Landlord:start()

    self:setRes();
    self:setGlobalStaticClass();
    -- self:setData();
    self:startGame();

    --设置匹配模式
    IS_AUTOMATCH = false
    
end

function Landlord:setGlobalStaticClass()

end

function Landlord:setData()

    RunTimeData:setCurKindID(HallSetting.getAllKindID(curGameName))
end

function Landlord:setRes()	--CCFileUtils:sharedFileUtils():addSearchPath("optional/");
	
	local writablePath = cc.FileUtils:getInstance():getWritablePath()
	local UPD_FOLDER = writablePath.."upd/landlordCutie"

    --for dev
    cc.FileUtils:getInstance():addSearchPath("expandRes/landlordCutie", true);
    -- cc.FileUtils:getInstance():addSearchPath("expandRes/landlordCutie/fonts", true);
    --for phone
    cc.FileUtils:getInstance():addSearchPath("res/landlordCutie", true);
    --for all
    cc.FileUtils:getInstance():addSearchPath(UPD_FOLDER, true);
    
    --fonts
    FONT_NORMAL = "Arial";--STHeitiTC-Medium
    FONT_ART_TEXT = "fonts/SXSLST.TTF";
    FONT_ART_BUTTON = "fonts/JDQTJ.TTF";

    --color
    COLOR_BTN_GREEN = cc.c4b(73,110,4,255*0.7)
    COLOR_BTN_BLUE = cc.c4b(24,119,185,255*0.7)
    COLOR_BTN_YELLOW = cc.c4b(165,82,0,255*0.7)
end

function Landlord:startGame()
    
    local nextScene = require("hall.RoomScene").new()
    cc.Director:getInstance():replaceScene(cc.TransitionFadeDown:create(1, nextScene))

end

return Landlord
