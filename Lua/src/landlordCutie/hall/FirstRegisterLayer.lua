local FirstRegisterLayer = class("FirstRegisterLayer", require("ui.CCModelView"))

function FirstRegisterLayer:ctor()
    self.super.ctor(self);
    self:setNodeEventEnabled(true)
	self:createUI();
end


function FirstRegisterLayer:createUI()
    local displaySize = cc.size(display.width, display.height);
    local winSize = cc.Director:getInstance():getWinSize();

    self:setContentSize(displaySize);

    -- -- 蒙板
    -- local maskLayer = ccui.ImageView:create("black.png");
    -- maskLayer:setScale9Enabled(true);
    -- maskLayer:setContentSize(cc.size(winSize.width, winSize.height));
    -- maskLayer:setPosition(cc.p(displaySize.width / 2, displaySize.height / 2));
    -- maskLayer:setTouchEnabled(true);
    -- maskLayer:addTo(self);

    --外框
    local window = display.newScale9Sprite("view/frame3.png", display.cx, display.cy, cc.size(600, 300), cc.rect(60, 60, 20, 20))
               :addTo(self)
            :align(display.CENTER, display.cx, display.cy)

    

    --title
    local title = display.newTTFLabel({text = "修改昵称",
                                size = 40,
                                color = cc.c3b(255,255,130),
                                font = FONT_ART_TEXT,
                                align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                            })
                :align(display.CENTER, 295, 270)
                :addTo(window)

    --内框
    local frame = display.newScale9Sprite("view/frame1.png", display.cx, display.cy, cc.size(560, 140), cc.rect(60, 60, 20, 20))
               :addTo(window)
            :align(display.CENTER, 300, 170)

    --content
    local content = display.newTTFLabel({text = "注册成功，为自己起个好听的名字吧！",
                                size = 26,
                                color = cc.c3b(255,255,130),
                                --font = "sxslst.ttf",
                                align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                            })
                :align(display.LEFT_TOP, 25, 135)
                :addTo(frame)

    --昵称
    local editSprite = ccui.ImageView:create("hall/login/edit_bg.png");
    editSprite:setScale9Enabled(true);
    editSprite:setContentSize(cc.size(280, 55));
    editSprite:setPosition(cc.p(160, 65));
    editSprite:addTo(frame);

    local editLabel = ccui.Text:create("昵称:", "", 26);
    editLabel:setColor(cc.c3b(255,255,130));
    editLabel:align(display.LEFT_CENTER, 10, 28)
    editLabel:addTo(editSprite)

    local nicknameField = ccui.EditBox:create(cc.size(250, 38), "blank.png");
    nicknameField:setAnchorPoint(cc.p(0,0.5));
    nicknameField:setPosition(cc.p(70, 26));
    nicknameField:setFontSize(24);
    nicknameField:setPlaceHolder("请输入新的昵称");
    nicknameField:setPlaceholderFontColor(cc.c3b(255,255,255));
    nicknameField:setPlaceholderFontSize(20);
    nicknameField:setMaxLength(9);
    nicknameField:addTo(editSprite)
    self.nicknameTextField = nicknameField

    --随机取名
    display.newSprite("common/sezi.png"):addTo(frame):align(display.CENTER, 350, 60):hide()
    local button = ccui.Button:create("common/common_button2.png"):hide()
    button:setScale9Enabled(true);
    button:setContentSize(cc.size(150, 67));
    --button:setCapInsets(cc.rect(130, 33, 1, 1));
    button:setPosition(cc.p(465,60));
    button:setTitleFontName(FONT_ART_BUTTON);
    button:setTitleText("随机取名");
    button:setTitleColor(cc.c3b(255,255,255));
    button:setTitleFontSize(26);
    button:setPressedActionEnabled(true);
    button:getTitleRenderer():enableOutline(COLOR_BTN_BLUE,2)
    button:addTouchEventListener(
        function ( sender,eventType )
            if eventType == ccui.TouchEventType.ended then
                Click()
            end
        end
        )
    button:addTo(frame)
    
    --提交
    local button = ccui.Button:create("common/button_green.png");
    button:setScale9Enabled(true);
    button:setContentSize(cc.size(180, 67));
    --button:setCapInsets(cc.rect(130, 33, 1, 1));
    button:setPosition(cc.p(480,58));
    button:setTitleFontName(FONT_ART_BUTTON);
    button:setTitleText("提交");
    button:setTitleColor(cc.c3b(255,255,255));
    button:setTitleFontSize(28);
    button:setPressedActionEnabled(true);
    button:getTitleRenderer():enableOutline(COLOR_BTN_GREEN,2)
    button:addTouchEventListener(
        function ( sender,eventType )
            if eventType == ccui.TouchEventType.ended then
                local newName = string.trim(self.nicknameTextField:getText())
                if string.len(newName) > 0 then

                    self:modifyNickname(newName);
                else
                    Hall.showTips("请输入昵称！")
                end
                Click()
            end
        end
        )
    button:addTo(window)

    --poker装饰
    local banner = ccui.ImageView:create("hall/room/roompage_banner.png")
    banner:addTo(window):align(display.CENTER, 0, 50)

    local banner1 = ccui.ImageView:create("hall/room/roompage_banner.png")
    banner1:scale(0.8)
    banner1:setRotation(35)
    banner1:addTo(window):align(display.CENTER, 20, 50)

end

function FirstRegisterLayer:modifyNickname(newName)

    local userInfo = DataManager:getMyUserInfo();

    UserService:sendModifyUserInfoWithUnderWrite(userInfo.gender, newName, userInfo.mobilePhoneNumber, userInfo.signature, true);
end

function FirstRegisterLayer:onEnter()

    self.userInfoChangedListener = UserService:addEventListener(HallCenterEvent.EVENT_MODIFY_USERINFO, handler(self, self.onUserInfoChanged))

end

function FirstRegisterLayer:onExit()

    UserService:removeEventListener(self.userInfoChangedListener)

end

function FirstRegisterLayer:onUserInfoChanged(event)

    if event.subId == CMD_LogonServer.SUB_GP_OPERATE_SUCCESS then--操作成功
        local operateSuccess = protocol.hall.userInfo_pb.CMD_GP_OperateSuccess_Pro()
        operateSuccess:ParseFromString(event.data)
        Hall.showTips(operateSuccess.szDescribeString,1.0)
        
    elseif event.subId == CMD_LogonServer.SUB_GP_OPERATE_FAILURE then
        local operateFailure = protocol.hall.userInfo_pb.CMD_GP_OperateFailure_Pro()
        operateFailure:ParseFromString(event.data)
        Hall.showTips(operateFailure.szDescribeString,1.0)
        
    elseif event.subId == CMD_LogonServer.SUB_GP_USER_FACE_INFO then --头像修改成功
        Hall.showTips("修改成功！", 1.0)
    end
    self:removeFromParent()
end

return FirstRegisterLayer