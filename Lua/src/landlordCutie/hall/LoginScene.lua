
if NO_UPDATE then
    require("tools.sound.SoundManager")
    SoundManager.loadConfig()
end

local LoginScene = class("LoginScene", require("ui.CCBaseScene"))


-- IsNoticeShow = false
function LoginScene:ctor()
    -- 根节点变更为self.container
    self.super.ctor(self);

    --背景
    -- local bgSprite = cc.Sprite:create();
    -- bgSprite:setTexture("launcher/splash.jpg");
    -- bgSprite:align(display.CENTER, display.cx, display.cy);
    -- self.container:addChild(bgSprite);

    self:setAnimationBackground();
    

    --will remove coming soon
    local info = ccui.Button:create("hall/login/notice.png");
    info:setPosition(cc.p(1050, 135));
    info:addTo(self);
    info:setPressedActionEnabled(true);
    info:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:onClickNotice();
            end
        end
    )
    info:setVisible(false);
    if OnlineConfig_review and OnlineConfig_review == "off" then
        info:setVisible(true);
    end

    if AppChannel == "CTCC" then
        self:createEGameUI()
    else
        self:createUI();
    end
    -- self:createEGameUI()

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
end

function LoginScene:createEGameUI()
    --游客登陆
    local quickLogin = ccui.Button:create("hall/login/egame_button.png");
    quickLogin:setPosition(cc.p(display.cx,56));
    self.container:addChild(quickLogin);
    quickLogin:setPressedActionEnabled(true);
    quickLogin:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:startLogin(4);
                Click();
            end
        end
    )

end
--构建界面
function LoginScene:createUI()

    -- --地主图片
    -- local landlordImage = ccui.ImageView:create();
    -- landlordImage:loadTexture("login/landlord.png");
    -- landlordImage:setPosition(cc.p(270,355));
    -- self.container:addChild(landlordImage);
    -- --农民图片
    -- local farmerImage = ccui.ImageView:create();
    -- farmerImage:loadTexture("login/farmer.png");
    -- farmerImage:setPosition(cc.p(865,410));
    -- self.container:addChild(farmerImage);

    --单机场
    local singleButton = ccui.Button:create("hall/login/singlePlayer_button.png");
    singleButton:setPosition(cc.p(1068,163));
    singleButton:setVisible(false);
    self.container:addChild(singleButton);

    --游客登陆
    local quickLogin = ccui.Button:create("hall/login/fastlogin_button.png");
    quickLogin:setPosition(cc.p(300,56));
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
        phoneLogin:setPosition(cc.p(570,56));
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
        phoneLogin:setPosition(cc.p(570,56));
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
    qqLogin:setPosition(cc.p(840,56));
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

    --version
    local fileName = cc.FileUtils:getInstance():getWritablePath().."upd/flist.txt";
    if cc.FileUtils:getInstance():isFileExist(fileName) then
        local fileString = cc.FileUtils:getInstance():getStringFromFile(fileName)
        local updlist = lua_do_string(fileString)

        local string = "v."..updlist.version;
        local titleLabe = ccui.Text:create(string, "Arial", 21);
        titleLabe:setColor(cc.c3b(255,183,0));
        titleLabe:setPosition(cc.p(30, 15));
        self.container:addChild(titleLabe);

    end
    --切换测试服
    local changeServer = ccui.Button:create("hall/login/rock.png")
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
LoginScene.changeclick = 0
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

    if index == 4 then
        LoginByCTCCEGame()
    end

    Hall.showWaiting(5);

end

-- 大厅登录回调
function LoginScene:hallLogonSuccess(event)

    Hall.hideWaiting();

    print("hallLogonSuccess!")
    local RoomScene = require("hall.RoomScene").new()
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
    RunTimeData:setAutoLogin(false)
    HallCenter:addEventListener(HallCenterEvent.EVENT_LOGIN_SUCCESS, handler(self, self.hallLogonSuccess));
    HallCenter:addEventListener(HallCenterEvent.EVENT_LOGIN_FAILURE, handler(self, self.hallLogonFailure));
    -- 进入以后 尝试更服务器建立连接
    HallCenter:connectHallServer(HallSetting.host, HallSetting.port);

    SoundManager.playMusic("sound/hallbgm.mp3", true);
            
    if OnlineConfig_review and OnlineConfig_review == "off" then

        if device.platform == "ios" and getAppVersion() < "3.0.3" then
            if IsNoticeShow == nil then
                IsNoticeShow = true
                self:onClickNotice()
            end
        end
    end


    local texture2d = cc.Director:getInstance():getTextureCache():addImage("christmas/effect/lizi_xuehua.png");
    local light = cc.ParticleSystemQuad:create("christmas/effect/lizi_xuehua.plist");
    light:setTexture(texture2d);
    light:setPosition(cc.p(display.cx, display.top));
    self.container:addChild(light,99)
end

function LoginScene:onExit()

    HallCenter:removeEventListenersByEvent(HallCenterEvent.EVENT_LOGIN_SUCCESS);
    HallCenter:removeEventListenersByEvent(HallCenterEvent.EVENT_LOGIN_FAILURE);

end

function LoginScene:setAnimationBackground()

    local frameTime = 0.5;

    local bgSprite = cc.Sprite:create("hall/login/staticbackground.jpg");
    bgSprite:align(display.CENTER, display.cx, display.cy);
    self.container:addChild(bgSprite);

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

function LoginScene:onClickNotice()

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


    local bgSprite = ccui.ImageView:create("common/pop_bg.png");
    bgSprite:setScale9Enabled(true);
    bgSprite:setContentSize(cc.size(650, 420));
    bgSprite:setPosition(cc.p(winSize.width / 2, winSize.height / 2));
    bgSprite:addTo(maskLayer);

    local panel = ccui.ImageView:create("common/panel.png")
    panel:setScale9Enabled(true);
    panel:setContentSize(cc.size(550,260));
    panel:setPosition(325, 190)
    panel:addTo(bgSprite)

    --title
    local title = display.newTTFLabel({text = "公告",
                                size = 40,
                                color = cc.c3b(255,255,130),
                                font = FONT_ART_TEXT,
                                align = cc.ui.TEXT_ALIGN_CENTER, -- 文字内部居中对齐

                            })
                :align(display.CENTER, 325, 360)
                :addTo(bgSprite)


                
    local str = "升级ios9的亲，QQ登录无法使用的问题我们已经修复，您可以去AppStore上升级应用。如果您还需要其他帮助，请与客服联系处理哦。客服QQ：2764024642"
    --[[
    local str = "升级ios9的亲，QQ登录暂时无法使用，我们正在\n";
    str = str.."努力修复中，您可以选择游客登陆或手机号登陆。\n"
    str = str.."如果您需要登录之前使用QQ号注册的账号，请与客\n"
    str = str.."服联系处理哦。客服QQ：2764024642\n"

    str = str.."老用户（2.0.0版本之前注册）为确保录：\n"
    str = str.."1、如果您已绑定手机号：选择手机号登录，使用\n"
    str = str.."手机号和密码登录。\n"
    str = str.."2、如果您未绑定手机号，但是有账号和密码(包\n"
    str = str.."括游客)：\n"

    str = str.."3、如果您使用QQ登录，但未绑定手机号：请您\n"
    str = str.."联系客服QQ：2841190880绑定手机号。\n\n"
    str = str.."为庆祝版本升级，用户只要完成手机号绑定，都可\n"
    str = str.."以在活动中领取到大礼包一份，惊喜多多欢乐多多！\n"
    str = str.."如有问题请联系客服QQ：2841190880。感谢您的\n"
    str = str.."支持！"
    ]]
    local notice = display.newTTFLabel({text = str,
                                size = 24,
                                color = cc.c3b(255,255,130),
                                font = FONT_NORMAL,
                                align = cc.ui.TEXT_ALIGN_LEFT, -- 文字内部居中对齐
                                dimensions = cc.size(500, 240)
                            })
                :align(display.LEFT_BOTTOM, 10, 0)

    -- local notice = ccui.Text:create(str, "Arial", 24);
    -- notice:setColor(cc.c3b(238,182,102));
    -- notice:setAnchorPoint(cc.p(0,0.0));

    local content = ccui.ScrollView:create();
    content:setDirection(ccui.ScrollViewDir.vertical);
    content:setContentSize(cc.size(530, 240));
    content:setInnerContainerSize(notice:getContentSize());
    content:setAnchorPoint(cc.p(0,0));
    content:setPosition(10,10);
    content:addChild(notice);
    content:addTo(panel);


    local exit = ccui.Button:create("common/close.png");
    exit:setPosition(cc.p(630, 400));
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

return LoginScene