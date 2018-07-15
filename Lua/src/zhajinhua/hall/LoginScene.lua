
if NO_UPDATE then
    require("tools.sound.SoundManager")
    SoundManager.loadConfig()
end

local LoginScene = class("LoginScene", require("ui.CCBaseScene"))

-- require("business.gloabFunctions.GloabFunction")
-- require("business.define.CMD_Version")
require("lfs")

local DateModel = require("zhajinhua.DateModel"):getInstance()
local EffectFactory = require("commonView.EffectFactory")
local scheduler = require("framework.scheduler")
function LoginScene:ctor()
    -- 根节点变更为self.container
    self.super.ctor(self);
    self.changeclick = 0

    self:createUI();

    self:setKeypadEnabled(true)
    self:addNodeEventListener(cc.KEYPAD_EVENT, function(event)
        if event.key == "back" then
            device.showAlert("退出", "确定退出游戏?", {"是","否"}, function(event)
                if event.buttonIndex == 1 then
                    cc.Director:getInstance():endToLua();
                    
                elseif event.buttonIndex == 2 then
                    device.cancelAlert()
                end
            end)
        end
    end)

    -- local activityManager = require("business.ActivityManager"):getInstance()
    -- activityManager:checkUpdate()

    -- local gif = CacheGif:create("chat/face1.gif");
    -- gif:setAnchorPoint(cc.p(0.5,0.5));
    -- self.container:addChild(gif);
    -- gif:setPosition(display.cx, display.cy);
    -- gif:setTag(1000);
    -- gif:setScale(3)


end

--构建界面
function LoginScene:createUI()

    local bgSprite = cc.Sprite:create("hall/room/bg.jpg");
    bgSprite:align(display.CENTER, display.cx, display.cy);
    self.container:addChild(bgSprite);

    -- local bgSprite = cc.Sprite:create("hall/login/girl_bg.png");
    -- bgSprite:align(display.CENTER, display.cx, display.cy);
    -- self.container:addChild(bgSprite);

    local bgSprite = EffectFactory:getGirlsArmature("ani_girl_1")
    bgSprite:align(display.CENTER, display.cx + 280, display.cy);
    self.container:addChild(bgSprite);

    local bgSprite = EffectFactory:getGirlsArmature("ani_girl_2")
    bgSprite:align(display.CENTER, display.cx - 280, display.cy);
    self.container:addChild(bgSprite);

    local bgSprite = EffectFactory:getGirlsArmature("ani_girl_3")
    bgSprite:align(display.CENTER, display.cx , display.cy);
    self.container:addChild(bgSprite);

    --设置
    local settingButton = ccui.ImageView:create()
    settingButton:setTouchEnabled(true)
    settingButton:loadTexture("hall/room/hall_setting.png")
    settingButton:setPosition(cc.p(100, display.height - 50))
    self.container:addChild(settingButton)
    settingButton:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.began then
            settingButton:setScale(1.1)
        elseif eventType == ccui.TouchEventType.ended then
            settingButton:setScale(1.0)
            HallCenter:sendPing()
            local setting = require("hall.SettingNormalLayer").new()
            self.container:addChild(setting)
            Click();

        elseif eventType == ccui.TouchEventType.canceled then
            settingButton:setScale(1.0)
        end
    end)

    --金三顺
    local bgSprite = cc.Sprite:create("hall/login/word_jinsanshun.png");
    bgSprite:align(display.CENTER, display.cx, 200);
    self.container:addChild(bgSprite);

    --筹码   
    local bgSprite = cc.Sprite:create("hall/login/zhuangshi_chouma.png");
    bgSprite:align(display.CENTER, display.cx + 200, 150);
    self.container:addChild(bgSprite);

    --poker
    local bgSprite = cc.Sprite:create("hall/login/poker_icon.png");
    bgSprite:align(display.CENTER, display.cx, 130);
    self.container:addChild(bgSprite);

    --发光
    local light1 = cc.Sprite:create("hall/login/light1.png");
    light1:align(display.CENTER, display.cx + 130, 160);
    self.container:addChild(light1);
    local action = cc.RepeatForever:create(cc.Sequence:create(
                                            cc.FadeOut:create(1.5),
                                            cc.FadeIn:create(1),
                                            cc.DelayTime:create(0.3)))
    light1:runAction(action)

    local light2 = cc.Sprite:create("hall/login/light2.png");
    light2:align(display.CENTER, display.cx + 110, 250);
    self.container:addChild(light2);
    light2:setScale(2)
    local action = cc.RepeatForever:create(cc.Sequence:create(
                                            cc.FadeOut:create(1.1),
                                            cc.FadeIn:create(1.5),
                                            cc.DelayTime:create(0.6)))
    light2:runAction(action)

    local light3 = cc.Sprite:create("hall/login/light2.png");
    light3:align(display.CENTER, display.cx -10, 210);
    self.container:addChild(light3);
    --light3:setScale(2)
    local action = cc.RepeatForever:create(cc.Sequence:create(
                                            cc.FadeOut:create(1.8),
                                            cc.FadeIn:create(1.2),
                                            cc.DelayTime:create(0.6)))
    light3:runAction(action)


    --单机场
    local singleButton = ccui.Button:create("hall/login/singlePlayer_button.png");
    singleButton:setPosition(cc.p(1068,163));
    singleButton:setVisible(false);
    self.container:addChild(singleButton);

    --游客登陆
    local quickLogin = ccui.Button:create("hall/login/fastlogin_button.png");
    quickLogin:setPosition(cc.p(230,56));
    self.container:addChild(quickLogin);
    quickLogin:setPressedActionEnabled(true);
    quickLogin:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:startLogin(1);
                Click();
            end
        end
    )

    local phoneLogin;
    --手机登陆
    if OnlineConfig_review == nil or OnlineConfig_review == "on" then
        
        phoneLogin = ccui.Button:create("hall/login/accountlogin_button.png");
        phoneLogin:setPosition(cc.p(560,56));
        self.container:addChild(phoneLogin);
        phoneLogin:setPressedActionEnabled(true);
        phoneLogin:addTouchEventListener(
            function(sender,eventType)
                if eventType == ccui.TouchEventType.ended then

                    if not self.phoneLoginLayer then
                        local PhoneLoginLayer = require("hall.PhoneLoginLayer"):new();
                        PhoneLoginLayer:addTo(self.container):align(display.LEFT_BOTTOM,0,0);
                        self.phoneLoginLayer = PhoneLoginLayer;
                        self.phoneLoginLayer:showLogin(true);
                    else
                        self.phoneLoginLayer:showLogin(true);
                        self.phoneLoginLayer:show();
                    end

                    Click();

                end
            end
        )

    else

        phoneLogin = ccui.Button:create("hall/login/phonelogin_button.png");
        phoneLogin:setPosition(cc.p(560,56));
        self.container:addChild(phoneLogin);
        phoneLogin:setPressedActionEnabled(true);
        phoneLogin:addTouchEventListener(
            function(sender,eventType)
                if eventType == ccui.TouchEventType.ended then

                    if not self.phoneLoginLayer then
                        local PhoneLoginLayer = require("hall.PhoneLoginLayer"):new();
                        PhoneLoginLayer:addTo(self.container):align(display.LEFT_BOTTOM,0,0);
                        self.phoneLoginLayer = PhoneLoginLayer;
                        self.phoneLoginLayer:showLogin();
                    else
                        self.phoneLoginLayer:showLogin();
                        self.phoneLoginLayer:show();
                    end

                    Click();

                end
            end
        )

        local myLogin = ccui.Button:create("hall/login/98login_button.png");
        myLogin:setPosition(cc.p(1050,570));
        self.container:addChild(myLogin);
        myLogin:setPressedActionEnabled(true);
        myLogin:addTouchEventListener(
            function(sender,eventType)
                if eventType == ccui.TouchEventType.ended then

                    if not self.phoneLoginLayer then
                        local PhoneLoginLayer = require("hall.PhoneLoginLayer"):new();
                        PhoneLoginLayer:addTo(self.container):align(display.LEFT_BOTTOM,0,0);
                        self.phoneLoginLayer = PhoneLoginLayer;
                        self.phoneLoginLayer:showLogin(true);
                    else
                        self.phoneLoginLayer:showLogin(true);
                        self.phoneLoginLayer:show();
                    end

                    Click();

                end
            end
        )

    end

    --QQ登陆
    local qqLogin = ccui.Button:create("hall/login/qqlogin_button.png");
    qqLogin:setPosition(cc.p(890,56));
    self.container:addChild(qqLogin);
    qqLogin:setPressedActionEnabled(true);
    qqLogin:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                LoginByTencentQQ();
                Click();
            end
        end
    )

    --facevisa登陆
    -- local facevisaLogin = ccui.Button:create("hall/login/facevisalogin_button.png");
    -- facevisaLogin:setPosition(cc.p(1050, 186));
    -- self.container:addChild(facevisaLogin);
    -- facevisaLogin:setPressedActionEnabled(true);
    -- facevisaLogin:addTouchEventListener(
    --     function(sender,eventType)
    --         if eventType == ccui.TouchEventType.ended then
    --             LoginByFaceVisa();
    --             Click();
    --         end
    --     end
    -- )

    if OnlineConfig_review == nil or OnlineConfig_review == "on" then
        qqLogin:setVisible(false);
        phoneLogin:setPositionX(qqLogin:getPositionX());
    end

    -- scheduler.performWithDelayGlobal(
    --     function()
    --         sendRegisterFast();
    --         --Hall:enterMainScene();
    --     end,
    --     0.5
    -- )

    local path = cc.FileUtils:getInstance():fullPathForFilename("scripts/main.lua");
    local resPath = string.sub(path, 1, string.len(path) - 16)

    --version
    local fileName = cc.FileUtils:getInstance():getWritablePath().."upd/flist.txt";
    if cc.FileUtils:getInstance():isFileExist(fileName) == false then
        fileName = resPath.."res/flist.txt";
    end

    if cc.FileUtils:getInstance():isFileExist(fileName) then
        local fileString = cc.FileUtils:getInstance():getStringFromFile(fileName)
        local updlist = lua_do_string(fileString)

        local string = "v."..updlist.version;
        local titleLabe = ccui.Text:create(string, "Arial", 21);
        titleLabe:setColor(cc.c3b(255,183,0));
        titleLabe:setPosition(cc.p(30, 50));
        self.container:addChild(titleLabe);
    end

    fileName = cc.FileUtils:getInstance():getWritablePath().."upd/zhajinhua/flist.txt";
    if cc.FileUtils:getInstance():isFileExist(fileName) == false then
        fileName = resPath.."res/zhajinhua/flist.txt";
    end

    if cc.FileUtils:getInstance():isFileExist(fileName) then
        local fileString = cc.FileUtils:getInstance():getStringFromFile(fileName)
        local updlist = lua_do_string(fileString)

        local string = "zv."..updlist.version;
        local titleLabe = ccui.Text:create(string, "Arial", 21);
        titleLabe:setColor(cc.c3b(255,183,0));
        titleLabe:setPosition(cc.p(30, 30));
        self.container:addChild(titleLabe);
    end

    --游戏推荐列表
    --[[
    RunTimeData.recommandAppListData = {}
    local info = {}
    info.icon_checksum = "b90c89b05093578ca956bba51e7bd5a2"
    info.appid = 1015
    info.pkg = "com.raccoon.huanle.lkpy"
    info.name = "欢乐街机捕鱼"
    info.pkg_url = "https://itunes.apple.com/cn/app/huan-le-jie-ji-bu-yu/id927781065?mt=8"
    info.icon_url = "http://icon.98pk.net/icon/1015/144.png"
    table.insert(RunTimeData.recommandAppListData, info)
    local info = {}
    info.icon_checksum = "b90c89b05093578ca956bba51e7bd5a2"
    info.appid = 1025
    info.pkg = "com.raccoon.huanle.lkpy"
    info.name = "欢乐二人麻将"
    info.pkg_url = "https://itunes.apple.com/cn/app/huan-le-jie-ji-bu-yu/id927781065?mt=8"
    info.icon_url = "http://icon.98pk.net/icon/1025/144.png"
    table.insert(RunTimeData.recommandAppListData, info)
    local info = {}
    info.icon_checksum = "b90c89b05093578ca956bba51e7bd5a2"
    info.appid = 1015
    info.pkg = "com.raccoon.huanle.lkpy"
    info.name = "欢乐街机捕鱼"
    info.pkg_url = "https://itunes.apple.com/cn/app/huan-le-jie-ji-bu-yu/id927781065?mt=8"
    info.icon_url = "http://icon.98pk.net/icon/1015/144.png"
    table.insert(RunTimeData.recommandAppListData, info)
    local info = {}
    info.icon_checksum = "b90c89b05093578ca956bba51e7bd5a2"
    info.appid = 1025
    info.pkg = "com.raccoon.huanle.lkpy"
    info.name = "欢乐二人麻将"
    info.pkg_url = "https://itunes.apple.com/cn/app/huan-le-jie-ji-bu-yu/id927781065?mt=8"
    info.icon_url = "http://icon.98pk.net/icon/1025/144.png"
    table.insert(RunTimeData.recommandAppListData, info)
    print("测试数据.....",RunTimeData.recommandAppListData)
    --]]
    -- if RunTimeData.recommandAppListData and OnlineConfig_review == "off" then
    --     local recommandview = require("commonView.RecommandLayer").new(RunTimeData.recommandAppListData)
    --     recommandview:setPosition(0, 180)
    --     recommandview.callback = function()
    --         self:onClickRecommand()
    --     end
    --     self:addChild(recommandview)
    -- end
    
    --切换测试服
    local changeServer = ccui.Button:create("hall/room/hall_setting.png")
    changeServer:setAnchorPoint(cc.p(0,1))
    changeServer:setPosition(display.left, display.top)
    changeServer:setOpacity(0)
    changeServer:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:changeServerHandler(sender)
            end
        end
    )
    self.container:addChild(changeServer)
end

function LoginScene:changeServerHandler(sender)
    -- body
    self.changeclick = self.changeclick+1
    if self.changeclick==10 then
        Hall.showTips("你懂的！！", 1)
        HallCenter:connectHallServer("oa.98game.cn", 12000);
        self.changeclick = 0
    end
    
end
-- 大厅登录回调
function LoginScene:startLogin(index)

    if index == 1 then
        sendRegisterFast();
    end

    if index == 2 then
        --
    end

    if index == 3 then
        LoginByTencentQQ();
    end

    Hall.showWaiting(10);

end

-- 大厅登录回调
function LoginScene:hallLogonSuccess(event)

    Hall.hideWaiting();

    print("hallLogonSuccess!")

    local RoomScene
    if NEW_SERVER == true then
        RoomScene = require("hall.RoomScene_New").new(true)
    else
        RoomScene = require("hall.RoomScene").new()
    end

    cc.Director:getInstance():replaceScene(cc.TransitionFadeDown:create(1, RoomScene))


    if Hall.phoneNumber ~= nil and Hall.phonepassword ~= nil then

        cc.UserDefault:getInstance():setStringForKey("phoneNumber", Hall.phoneNumber);
        cc.UserDefault:getInstance():setStringForKey("phonepassword", Hall.phonepassword);

    end

end

function LoginScene:hallLogonFailure(event)
    Hall.showTips("登录失败:" .. event.pData)
    print("hallLogonFailure!")
    Hall.hideWaiting();
end

function LoginScene:onEnter()

    print("LoginScene onEnter!!!!")
    self.changeclick = 0
    RunTimeData:setAutoLogin(false)
    HallCenter:addEventListener(HallCenterEvent.EVENT_LOGIN_SUCCESS, handler(self, self.hallLogonSuccess));
    HallCenter:addEventListener(HallCenterEvent.EVENT_LOGIN_FAILURE, handler(self, self.hallLogonFailure));
    -- 进入以后 尝试更服务器建立连接
    HallCenter:connectHallServer(HallSetting.host, HallSetting.port);
    SoundManager.play3CardHallBackGround()

end

function LoginScene:onExit()

    HallCenter:removeEventListenersByEvent(HallCenterEvent.EVENT_LOGIN_SUCCESS);
    HallCenter:removeEventListenersByEvent(HallCenterEvent.EVENT_LOGIN_FAILURE);

end

function LoginScene:setAnimationBackground()

    local frameTime = 0.5;

    -- local bgSprite = cc.Sprite:create("hall/room/bg.jpg");
    -- bgSprite:align(display.CENTER, display.cx, display.cy);
    -- self.container:addChild(bgSprite);

    -- local bgSprite = cc.Sprite:create("hall/login/girl_bg.png");
    -- bgSprite:align(display.CENTER, display.cx, display.cy);
    -- self.container:addChild(bgSprite);

    --
    local famerhand = cc.Sprite:create("hall/login/famerhand.png");
    famerhand:setAnchorPoint(cc.p(-0.2, 0.5));
    famerhand:setPosition(490, 410);
    self.container:addChild(famerhand);

    famerhand:setRotation(-120);
    local sequencefamerhand = transition.sequence(
        {
            cc.CallFunc:create(function()famerhand:setRotation(-120);end),
            cc.RotateBy:create(0.5, 120),
            cc.DelayTime:create(2.5),
            
        }
    )
    famerhand:runAction(cc.RepeatForever:create(sequencefamerhand));

    local sequencefamerhand2 = transition.sequence(
        {
            cc.CallFunc:create(function()famerhand:setPosition(490, 410);end),
            cc.MoveBy:create(0.5, cc.p(0,-40)),
            cc.DelayTime:create(2.5),
            
        }
    )
    famerhand:runAction(cc.RepeatForever:create(sequencefamerhand2));

    --
    local famer = cc.Sprite:create("hall/login/famer.png");
    famer:setAnchorPoint(cc.p(0.5, 0.0));
    famer:setPosition(460, 205);
    self.container:addChild(famer);
    local sequencefamer = transition.sequence(
        {
            cc.ScaleBy:create(1, 1.03, 1.05),
            cc.ScaleTo:create(1, 1.00, 1.00),
            --cc.DelayTime:create(3.0),
        }
    )
    famer:runAction(cc.RepeatForever:create(sequencefamer));


    --
    local hat = cc.Sprite:create("hall/login/hat.png");
    hat:setAnchorPoint(cc.p(1.0, -1.0));
    --hat:setPosition(755, 540);
    hat:setPosition(830, 340);
    self.container:addChild(hat);

    local sequencehat = transition.sequence(
        {
            cc.RotateBy:create(1, -5),
            cc.RotateBy:create(1, 5),
            cc.DelayTime:create(1),
        }
    )
    hat:runAction(cc.RepeatForever:create(sequencehat));


    --
    local landlordhand = cc.Sprite:create("hall/login/landlordhand.png");
    landlordhand:setPosition(1050, 400);
    self.container:addChild(landlordhand);

    local sequencelandlordhand = transition.sequence(
        {
            cc.MoveBy:create(1, cc.p(-10,20)),
            cc.MoveBy:create(1, cc.p(10,-20)),
            cc.DelayTime:create(1.0),
        }
    )
    landlordhand:runAction(cc.RepeatForever:create(sequencelandlordhand));

    local sequencelandlordhand2 = transition.sequence(
        {
            cc.RotateBy:create(1, -5),
            cc.RotateBy:create(1, 5),
            cc.DelayTime:create(1),
        }
    )
    landlordhand:runAction(cc.RepeatForever:create(sequencelandlordhand2));

    --
    local landlord = cc.Sprite:create("hall/login/landlord.png");
    landlord:setPosition(810, 310);
    self.container:addChild(landlord);

    local sequencelandlord = transition.sequence(
        {
            cc.MoveBy:create(1, cc.p(0,-20)),
            cc.MoveBy:create(1, cc.p(0,20)),
            --cc.DelayTime:create(3.0),
        }
    )
    landlord:runAction(cc.RepeatForever:create(sequencelandlord));

    --
    local chick = cc.Sprite:create("hall/login/chick.png");
    chick:setPosition(550, 205);
    self.container:addChild(chick);

    local sequencechick = transition.sequence(
        {
            cc.MoveBy:create(1, cc.p(0,20)),
            cc.MoveBy:create(1, cc.p(0,-20)),
            --cc.DelayTime:create(3.0),
        }
    )
    chick:runAction(cc.RepeatForever:create(sequencechick));

    --
    local smallking = cc.Sprite:create("hall/login/smallking.png");
    smallking:setPosition(635, 295);
    self.container:addChild(smallking);

    local sequencesmallking = transition.sequence(
        {
            cc.RotateBy:create(1, 10),
            cc.RotateBy:create(1, -10),
            cc.DelayTime:create(1),
        }
    )
    smallking:runAction(cc.RepeatForever:create(sequencesmallking));

    --
    local bigking = cc.Sprite:create("hall/login/bigking.png");
    bigking:setPosition(600, 265);
    self.container:addChild(bigking);

    local sequencebigking = transition.sequence(
        {
            cc.RotateBy:create(1, -5),
            cc.RotateBy:create(1, 5),
            cc.DelayTime:create(1),
        }
    )
    bigking:runAction(cc.RepeatForever:create(sequencebigking));

    local centerX = 550;
    local centerY = 370;
    local rad = 75;
    local container = cc.LayerColor:create(cc.c4b(255,0,0,255*0.0));
    container:setContentSize(cc.size(rad*2,rad*2));
    container:setPosition(centerX, centerY);
    self.container:addChild(container);

    local rock = cc.Sprite:create("hall/login/rock.png");
    rock:setPosition(0, rad*2);
    container:addChild(rock);

    rock:runAction(cc.RepeatForever:create(cc.RotateBy:create(3, 360)));

    local sequencecontainer = transition.sequence(
        {
            cc.CallFunc:create(function()rock:setVisible(true);end),
            cc.CallFunc:create(function()rock:setPosition(0, rad*2);container:setPosition(centerX, centerY);container:setRotation(-30);end),
            cc.RotateBy:create(1, 120),
            cc.CallFunc:create(function()rock:setPosition(0, rad);container:setPosition(centerX+2*rad, centerY+rad);container:setRotation(0);end),
            cc.RotateBy:create(1, 120),
            cc.CallFunc:create(function()rock:setVisible(false);end),
            cc.DelayTime:create(1),
        }
    )
    container:runAction(cc.RepeatForever:create(sequencecontainer));

end

function LoginScene:onClickRecommand()
    
    local displaySize = cc.size(display.width, display.height);
    local winSize = cc.Director:getInstance():getWinSize();

    local layer = display.newLayer();
    layer:setContentSize(displaySize);
    layer:ignoreAnchorPointForPosition(false);
    layer:setAnchorPoint(cc.p(0.5,0.5))
    layer:setPosition(cc.p(winSize.width / 2, winSize.height / 2));
    layer:addTo(self);

    -- 蒙板
    local maskLayer = ccui.ImageView:create("black.png");
    maskLayer:setScale9Enabled(true);
    maskLayer:setContentSize(cc.size(winSize.width, winSize.height));
    maskLayer:setPosition(cc.p(displaySize.width / 2, displaySize.height / 2));
    maskLayer:setTouchEnabled(true);
    maskLayer:addTo(layer);


    local bgSprite = ccui.ImageView:create("hall/exchange/bg.png");
    bgSprite:setScale9Enabled(true);
    bgSprite:setCapInsets(cc.rect(60,50,10,10))
    bgSprite:setContentSize(cc.size(755, 490));
    bgSprite:setPosition(cc.p(winSize.width / 2, winSize.height / 2));
    bgSprite:addTo(maskLayer);

    local panel = ccui.ImageView:create("hall/exchange/frame.png")
    panel:setScale9Enabled(true);
    panel:setContentSize(cc.size(685,410));
    panel:setPosition(377, 248)
    panel:addTo(bgSprite)

    --title
    local title = display.newSprite("hall/login2/recommend/title.png")
    title:addTo(bgSprite)
    title:setPosition(377, 470)

    --banner
    display.newSprite("hall/shop/zsgold2.png"):addTo(bgSprite,2):align(display.CENTER, -5, 286)
    display.newSprite("hall/exchange/banner3.png"):addTo(bgSprite,2):align(display.CENTER, 740, 85)

    --listview
    self.listView = ccui.ListView:create()
    self.listView:setDirection(ccui.ScrollViewDir.vertical)
    self.listView:setBounceEnabled(true)
    self.listView:setContentSize(cc.size(660,380))
    self.listView:setPosition(50, 50)
    self.listView:addTo(bgSprite,1)

    local num =2
    local row =1
    local col =1
    local curRow = 0
    local custom_item = nil
    local height = 0
    local custom_itemX = 645
    local custom_itemY = 180
    local count = #RunTimeData.recommandAppListData
    for i=1,count do
        row = math.ceil(i/num)
        col = i%num
        if col == 0 then
            col = num
        end

        if curRow ~= row then
            custom_item = ccui.Layout:create()
            custom_item:setTouchEnabled(true)
            custom_item:setContentSize(cc.size(custom_itemX,custom_itemY))
            custom_item:setAnchorPoint(cc.p(0,1))
            curRow = row

            self.listView:pushBackCustomItem(custom_item)
        end

        local item = self:createChargeItem(i)
        item:setAnchorPoint(cc.p(0.5,0.5))
        item:setPosition((col-0.5)*330, 0.5*180)
        custom_item:addChild(item)
    
    end

    local exit = ccui.Button:create("common/close.png");
    exit:setPosition(cc.p(740, 470));
    exit:addTo(bgSprite);
    exit:setPressedActionEnabled(true);
    exit:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                layer:removeFromParent();
            end
        end
    )
end

function LoginScene:createChargeItem(index)
    
    local item = ccui.ImageView:create("hall/login2/recommend/item_bg.png")
    item:setScale9Enabled(true)
    item:setContentSize(cc.size(322, 166))
    item:setTouchEnabled(false)

    local itemImage = RunTimeData.recommandAppListData[index].icon_file_name
    display.newSprite(itemImage):addTo(item):pos(80, 80)

    local itemName = RunTimeData.recommandAppListData[index].name

    local title = ccui.Text:create(itemName,"fonts/JIANZHUNYUAN.ttf", 24)
    title:setPosition(cc.p(230,110))
    title:setColor(cc.c3b(0xff, 0xf6, 0x28))
    title:enableOutline(cc.c4b(0x66, 0x1e, 0x08, 0xff), 2)
    title:addTo(item)


    local button = ccui.Button:create("hall/login2/recommend/btn_download.png");
    button:setPressedActionEnabled(true);
    button:addTo(item)
    button:pos(230,60)
    button:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                device.openURL(RunTimeData.recommandAppListData[index].pkg_url)
                -- openPureURL(RunTimeData.recommandAppListData[index].pkg_url)
            end
        end
    )

    return item
end

return LoginScene