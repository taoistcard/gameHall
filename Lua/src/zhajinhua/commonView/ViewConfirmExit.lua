-- 设置个人信息窗
-- Author: zx
-- Date: 2015-04-08 20:57:59

local ViewConfirmExit = class("ViewConfirmExit", function() return display.newLayer() end)

function ViewConfirmExit:ctor(params)
    self.callBackOK = params.ok
    self.callBackCancel = params.cancel

    self:createUI();

end

function ViewConfirmExit:onEnter()

end

function ViewConfirmExit:onExit()

    UserService:removeEventListener(self.userInfoChangedListener)

end
    
function ViewConfirmExit:onUserInfoChanged(event)

    if event.subId == CMD_LogonServer.SUB_GP_OPERATE_SUCCESS then--操作成功
        self:setDefaultData();
        local operateSuccess = protocol.hall.userInfo_pb.CMD_GP_OperateSuccess_Pro()
        operateSuccess:ParseFromString(event.data)
        Hall.showTips(operateSuccess.szDescribeString,1.0)
        
    elseif event.subId == CMD_LogonServer.SUB_GP_OPERATE_FAILURE then
        self:setDefaultData();
        local operateFailure = protocol.hall.userInfo_pb.CMD_GP_OperateFailure_Pro()
        operateFailure:ParseFromString(event.data)
        Hall.showTips(operateFailure.szDescribeString,1.0)
        
    elseif event.subId == CMD_LogonServer.SUB_GP_USER_FACE_INFO then --头像修改成功
        self:setDefaultData();
        Hall.showTips("修改成功！", 1.0)
        
    end
end

function ViewConfirmExit:createUI()

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
    local frame = display.newScale9Sprite("view/frame3.png", display.cx, display.cy, cc.size(590, 255), cc.rect(60, 60, 20, 20))
               :addTo(self)
            :align(display.CENTER, display.cx, display.cy)

    --关闭按钮
    local exit = ccui.Button:create("common/close.png");
    exit:setPosition(cc.p(580,240));
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
                :align(display.CENTER, 295, 220)
                :addTo(frame)

    --content
    local content = display.newTTFLabel({text = "你确定要离开吗？",
                                size = 26,
                                color = cc.c3b(255,255,130),
                                --font = "sxslst.ttf",
                                align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                            })
                :align(display.LEFT_TOP, 50, 170)
                :addTo(frame)
    content = display.newTTFLabel({text = "如果离开，机器人伊娃将帮您打完本局。",
                                size = 26,
                                color = cc.c3b(255,255,130),
                                --font = "sxslst.ttf",
                                align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                            })
                :align(display.LEFT_TOP, 50, 140)
                :addTo(frame)

    --确定
    local button = ccui.Button:create("common/button_green.png");
    button:setScale9Enabled(true);
    button:setContentSize(cc.size(180, 67));
    --button:setCapInsets(cc.rect(130, 33, 1, 1));
    button:setPosition(cc.p(190,60));
    button:setTitleFontName(FONT_ART_BUTTON);
    button:setTitleText("确定");
    button:setTitleColor(cc.c3b(255,255,255));
    button:setTitleFontSize(28);
    button:setPressedActionEnabled(true);
    button:getTitleRenderer():enableOutline(COLOR_BTN_GREEN,2)
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
    button:setPosition(cc.p(400,60));
    button:setTitleFontName(FONT_ART_BUTTON);
    button:setTitleText("取消");
    button:setTitleColor(cc.c3b(255,255,255));
    button:setTitleFontSize(28);
    button:setPressedActionEnabled(true);
    button:getTitleRenderer():enableOutline(COLOR_BTN_BLUE,2)
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

function ViewConfirmExit:onClickClose()
    self.callBackCancel()
end

function ViewConfirmExit:onClickYes()
    self.callBackOK()
end

function ViewConfirmExit:onClickCancel()
    self.callBackCancel()
end

return ViewConfirmExit