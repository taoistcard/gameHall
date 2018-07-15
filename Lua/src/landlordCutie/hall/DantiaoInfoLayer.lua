local DantiaoInfoLayer = class("DantiaoInfoLayer",function () return display.newLayer() end)

function DantiaoInfoLayer:ctor(kind)
	local roomIndex = RunTimeData:getRoomIndexByConnectServer()
	kind = roomIndex
	self:createUI(kind)
end
function DantiaoInfoLayer:createUI(kind)

	local displaySize = cc.size(display.width, display.height);
    local winSize = cc.Director:getInstance():getWinSize();
    -- 蒙板
    local maskLayer = ccui.ImageView:create("black.png");
    maskLayer:setScale9Enabled(true);
    maskLayer:setContentSize(cc.size(winSize.width, winSize.height));
    maskLayer:setPosition(cc.p(displaySize.width / 2, displaySize.height / 2));
    maskLayer:setTouchEnabled(true);
    maskLayer:addTo(self);

    local bgSprite = ccui.ImageView:create("landlord1vs1/dantiaoInfoBg.png");
    -- bgSprite:setScale9Enabled(true);
    -- bgSprite:setContentSize(cc.size(674, 433));
    bgSprite:setPosition(cc.p(588,368));
    self:addChild(bgSprite);

    local dizhu = ccui.ImageView:create("result/win_dz_dantiao.png")
    dizhu:setPosition(280, 475)
    -- dizhu:setScaleX(-1)
    self:addChild(dizhu)
    local csfArray = {"2000金币","2万金币","20万金币","200万金币"}
    local chashuifei = ccui.Text:create()
    chashuifei:setPosition(490, 408)
    chashuifei:setAnchorPoint(cc.p(0,0.5))
    chashuifei:setFontSize(24)
    chashuifei:setColor(cc.c3b(254,240,100))
    self:addChild(chashuifei)
    chashuifei:setString(csfArray[kind])

    local jiangcengArray  = {"10万金币","100万金币","1000万金币","1亿金币"}
    local jiangceng = ccui.Text:create()
    jiangceng:setPosition(490, 355)
    jiangceng:setAnchorPoint(cc.p(0,0.5))
    jiangceng:setFontSize(24)
    jiangceng:setColor(cc.c3b(254,240,100))
    self:addChild(jiangceng)
    jiangceng:setString(jiangcengArray[kind])

    local rule  = ccui.Text:create()
    rule:setPosition(490, 303)
    rule:setAnchorPoint(cc.p(0,0.5))
    rule:setFontSize(24)
    rule:setColor(cc.c3b(254,240,100))
    self:addChild(rule)
    rule:setString("一局定输赢，不计底分和倍数。")

    



    local button = ccui.Button:create("common/button_green.png");
    button:setScale9Enabled(true);
    button:setContentSize(cc.size(220, 67));
    --button:setCapInsets(cc.rect(130, 33, 1, 1));
    --button:setPosition(cc.p(840,56));
    button:setTitleFontName(FONT_ART_BUTTON);
    button:setTitleText("确认");
    button:setTitleColor(cc.c3b(255,255,255));
    button:setTitleFontSize(30);
    button:setPressedActionEnabled(true);
    button:getTitleRenderer():enableOutline(COLOR_BTN_GREEN,2)
    button:addTouchEventListener(
        function ( sender,eventType )
            if eventType == ccui.TouchEventType.ended then
                self:removeFromParent()
            end
        end
        )
    button:setPosition(cc.p(576,148));
    self:addChild(button);
end
return DantiaoInfoLayer