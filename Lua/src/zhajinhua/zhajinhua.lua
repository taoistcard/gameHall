require("cocos.init")
require("framework.init")
local DateModel = require("zhajinhua.DateModel")
local Zhajinhua = {};
NEW_SERVER = true
function Zhajinhua:start()

    self:setRes();
    self:setGlobalStaticClass();
    -- self:setData();
    self:startGame();
    
end

function Zhajinhua:setGlobalStaticClass()

end

function Zhajinhua:setData()

    RunTimeData:setCurKindID(HallSetting.getAllKindID(curGameName))

end

function Zhajinhua:setRes()	--CCFileUtils:sharedFileUtils():addSearchPath("optional/");
	
	local writablePath = cc.FileUtils:getInstance():getWritablePath()
	local UPD_FOLDER = writablePath.."upd/zhajinhua"

    --for dev
    cc.FileUtils:getInstance():addSearchPath("expandRes/zhajinhua", true);
    -- cc.FileUtils:getInstance():addSearchPath("expandRes/ZhajinhuaCutie/fonts", true);
    --for phone
    cc.FileUtils:getInstance():addSearchPath("res/zhajinhua", true);
    cc.FileUtils:getInstance():addSearchPath("res/zhajinhua/common", true);
    --for all
    cc.FileUtils:getInstance():addSearchPath(UPD_FOLDER, true);
    cc.FileUtils:getInstance():addSearchPath(UPD_FOLDER.."/common", true);


    --移至hall进行设置(这里不废除是因为在hall的时候有可能因为没有资源而加载不到)
    --fonts
    FONT_NORMAL = "Arial";--STHeitiTC-Medium
    FONT_ART_TEXT = "fonts/JIANZHUNYUAN.ttf";
    FONT_ART_BUTTON = "fonts/JIANZHUNYUAN.ttf";
    --color
    COLOR_BTN_GREEN = cc.c4b(73,110,4,255*0.7)
    COLOR_BTN_BLUE = cc.c4b(24,119,185,255*0.7)
    COLOR_BTN_YELLOW = cc.c4b(165,82,0,255*0.7)
end

function Zhajinhua:startGame()
        local RoomScene = require("hall.RoomScene_New").new()
        cc.Director:getInstance():replaceScene(RoomScene)

end

return Zhajinhua
