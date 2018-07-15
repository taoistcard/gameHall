--斗地主小版本登录界面

if NO_UPDATE then
    require("tools.sound.SoundManager")
    SoundManager.loadConfig()
end

local LoginScene = class("LoginScene", require("ui.CCBaseScene"))

require("business.gloabFunctions.GloabFunction")
require("business.define.CMD_Version")


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

    --游客登陆
    local quickLogin = ccui.Button:create("hall/login2/fastlogin_button.png");
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
        
        phoneLogin = ccui.Button:create("hall/login2/accountlogin_button.png");
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

        phoneLogin = ccui.Button:create("hall/login2/phonelogin_button.png");
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
    local qqLogin = ccui.Button:create("hall/login2/qqlogin_button.png");
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
    ]]
    if RunTimeData.recommandAppListData and OnlineConfig_review == "off" then
        local recommandview = require("commonView.RecommandLayer").new(RunTimeData.recommandAppListData)
        recommandview:setPosition(0, 80)
        recommandview.callback = function()
            self:onClickRecommand()
        end
        self:addChild(recommandview)
    end

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

    local bgSprite = cc.Sprite:create("hall/login2/staticbackground.jpg");
    bgSprite:align(display.CENTER, display.cx, display.cy);
    self.container:addChild(bgSprite);

    local armature = self:getLoginArmature()
    if armature then
        armature:pos(display.cx, display.cy)
        self.container:addChild(armature)
        armature:getAnimation():playWithIndex(0)
    end

end

function LoginScene:getLoginArmature()
    local name = "qmddz_denglu"

    local filePath = "hall/login2/effect/qmddz_denglu/"..name..".ExportJson"
    local imagePath = "hall/login2/effect/qmddz_denglu/"..name.."0.png"
    local plistPath = "hall/login2/effect/qmddz_denglu/"..name.."0.plist"
    
    local manager = ccs.ArmatureDataManager:getInstance()
    if manager:getAnimationData(name) == nil then
        manager:addArmatureFileInfo(imagePath,plistPath,filePath)
    end
    local armature = ccs.Armature:create(name)
    return armature;
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

    local title = ccui.Text:create(itemName,"fonts/HKBDTW12.TTF", 24)
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