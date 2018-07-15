local MarriageTip = class("MarriageTip",function() return display.newLayer() end)
function MarriageTip:ctor(param)
    self.param = param
	self:createUI(param.kind,param.content)
end
function MarriageTip:createUI(kind,content)
	local displaySize = cc.size(display.width, display.height);
    local winSize = cc.Director:getInstance():getWinSize();
    -- 蒙板
    local maskLayer = ccui.ImageView:create("black.png");
    maskLayer:setScale9Enabled(true);
    maskLayer:setContentSize(cc.size(winSize.width, winSize.height));
    maskLayer:setPosition(cc.p(displaySize.width / 2, displaySize.height / 2));
    maskLayer:setTouchEnabled(true)
    self:addChild(maskLayer)

    local bg = ccui.ImageView:create("view/frame3.png");
    bg:setScale9Enabled(true);
    bg:setContentSize(cc.size(540,235));
    bg:setPosition(573,322)
    self:addChild(bg)

    local contentTxt = content--"您现在的身家不够付彩礼！快去充值吧！"
    local content = ccui.Text:create("","",26)
    content:setPosition(39, 190);
    content:setAnchorPoint(cc.p(0,1))
    content:setString("\t\t"..contentTxt)
    content:setColor(cc.c3b(216, 213, 111))
    content:setTextAreaSize(cc.size(440,80))
    content:ignoreContentAdaptWithSize(false)
    content:setTextHorizontalAlignment(0)
    content:setTextVerticalAlignment(0)
    bg:addChild(content)    
    self.content = content

    local buttonTitle = ""
    if kind == 1 then
        buttonTitle = "充值"
    elseif kind == 2 then
        buttonTitle = "确定"
    else
        buttonTitle = "确定"
    end
    local chongzhi = ccui.Button:create("common/button_green.png")
    bg:addChild(chongzhi)
    chongzhi:setPosition(cc.p(272,56))
    chongzhi:setScale9Enabled(true)
    chongzhi:setContentSize(cc.size(184,67))
    chongzhi:setTitleFontName(FONT_ART_BUTTON);
    chongzhi:setTitleText(buttonTitle);
    chongzhi:setTitleColor(cc.c3b(255,255,255));
    chongzhi:setTitleFontSize(28);
    chongzhi:getTitleRenderer():enableOutline(COLOR_BTN_BLUE,2)
    chongzhi:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:chongzhiHandler()
            end
        end
    )

    --关闭按钮
    local exit = ccui.Button:create("common/close.png");
    exit:setPosition(cc.p(516,217))
    bg:addChild(exit)
    exit:setPressedActionEnabled(true);
    exit:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:close()                
            end
        end
    )
end

function MarriageTip:chongzhiHandler()
    local kind = self.param.kind
    if kind == 1 then
        local buy = require("hall.ShopLayer").new(2)
        self:getParent():addChild(buy,11)
        self:close()
    elseif kind == 2 then
        self:close()
    else
        self:close()
    end
end

function MarriageTip:close()
	self:removeFromParent()
end

return MarriageTip
