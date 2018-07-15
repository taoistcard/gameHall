-- 确认框
-- Author: zx
-- Date: 2015-04-08 20:57:59

local ViewConfirmLayer = class("ViewConfirmLayer", function() return display.newLayer() end)

function ViewConfirmLayer:ctor(params)
    self.callBackOK = params.ok
    self.callBackCancel = params.cancel
    self.desc = params.desc or "您已经在其他房间中开始游戏了"
    self:createUI();

end

function ViewConfirmLayer:onEnter()

end

function ViewConfirmLayer:onExit()

    UserService:removeEventListener(self.userInfoChangedListener)

end

function ViewConfirmLayer:createUI()

    local displaySize = cc.size(display.width, display.height);
    local winSize = cc.Director:getInstance():getWinSize();

    self:setContentSize(displaySize);

    -- 蒙板
    local maskLayer = ccui.ImageView:create("black.png");
    maskLayer:setScale9Enabled(true);
    maskLayer:setContentSize(cc.size(winSize.width, winSize.height));
    maskLayer:setPosition(cc.p(displaySize.width / 2, displaySize.height / 2));
    maskLayer:setTouchEnabled(true);
    maskLayer:addTo(self);

    --外框
    local frame = display.newScale9Sprite("view/frame3.png", display.cx, display.cy, cc.size(690, 300), cc.rect(60, 60, 20, 20))
               :addTo(self)
            :align(display.CENTER, display.cx, display.cy)

    --关闭按钮
    local exit = ccui.Button:create("common/close.png");
    exit:setPosition(cc.p(680,270));
    exit:addTo(frame);
    exit:setPressedActionEnabled(true);
    exit:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:onClickClose()
                SoundManager.playSound("sound/buttonclick.mp3")
            end
        end
    )

    --title
    local title = display.newTTFLabel({text = "小提示",
                                size = 40,
                                color = cc.c3b(255,255,130),
                                font = FONT_ART_TEXT,
                                align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                            })
                :align(display.CENTER, 345, 260)
                :addTo(frame)

    --content
    local content = display.newTTFLabel({text = self.desc,
                                size = 24,
                                color = cc.c3b(255,255,130),
                                --font = "sxslst.ttf",
                                dimensions = cc.size(600, 90),
                                align = cc.ui.TEXT_ALIGN_LEFT, -- 文字内部居中对齐
                                valign = cc.VERTICAL_TEXT_ALIGNMENT_BOTTOM,
                            })
                :align(display.LEFT_CENTER, 50, 190)
                :addTo(frame)
    content = display.newTTFLabel({text = "是否重新进入该房间？",
                                size = 26,
                                color = cc.c3b(255,255,130),
                                --font = "sxslst.ttf",
                                align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                            })
                :align(display.LEFT_TOP, 50, 130)
                :addTo(frame)

    --确定
    local button = ccui.Button:create("common/button_green.png");
    button:setScale9Enabled(true);
    button:setContentSize(cc.size(180, 67));
    --button:setCapInsets(cc.rect(130, 33, 1, 1));
    button:setPosition(cc.p(220,55));
    button:setTitleFontName(FONT_ART_BUTTON);
    button:setTitleText("确定");
    button:setTitleColor(cc.c3b(255,255,255));
    button:setTitleFontSize(28);
    button:setPressedActionEnabled(true);
    -- button:getTitleRenderer():enableOutline(COLOR_BTN_GREEN,2)
    button:addTouchEventListener(
        function ( sender,eventType )
            if eventType == ccui.TouchEventType.ended then
                self:onClickYes()
                SoundManager.playSound("sound/buttonclick.mp3")
            end
        end
        )
    button:addTo(frame)
    
    --取消
    local button = ccui.Button:create("common/button_blue.png");
    button:setScale9Enabled(true);
    button:setContentSize(cc.size(180, 67));
    --button:setCapInsets(cc.rect(130, 33, 1, 1));
    button:setPosition(cc.p(470,55));
    button:setTitleFontName(FONT_ART_BUTTON);
    button:setTitleText("取消");
    button:setTitleColor(cc.c3b(255,255,255));
    button:setTitleFontSize(28);
    button:setPressedActionEnabled(true);
    -- button:getTitleRenderer():enableOutline(COLOR_BTN_BLUE,2)
    button:addTouchEventListener(
        function ( sender,eventType )
            if eventType == ccui.TouchEventType.ended then
                self:onClickCancel()
                SoundManager.playSound("sound/buttonclick.mp3")
            end
        end
        )
    button:addTo(frame)


    --poker装饰
    local banner = ccui.ImageView:create("hall/room/roompage_banner.png")
    banner:addTo(frame):align(display.CENTER, 0, 50)

    local banner1 = ccui.ImageView:create("hall/room/roompage_banner.png")
    banner1:scale(0.8)
    banner1:setRotation(35)
    banner1:addTo(frame):align(display.CENTER, 20, 50)
end

function ViewConfirmLayer:onClickClose()
    self.callBackCancel()
end

function ViewConfirmLayer:onClickYes()
    self.callBackOK()
end

function ViewConfirmLayer:onClickCancel()
    self.callBackCancel()
end

return ViewConfirmLayer