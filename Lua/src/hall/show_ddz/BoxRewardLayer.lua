
-- Date: 2015-10-21 20:57:59

local BoxRewardLayer = class("BoxRewardLayer", require("ui.CCModelView"))

function BoxRewardLayer:ctor(parent)
    self.super.ctor(self)
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    self:setNodeEventEnabled(true)
    self.parent = parent;
    self:createUI();
end

function BoxRewardLayer:createUI()
    self.baseNode = cc.CSLoader:createNode("view/ddz_recommand/ddz_boxRewardLayer.csb"):addTo(self)
    self.container = self.baseNode:getChildByName("Image_1")

    self.ty_xiao_ji = self.container:getChildByName("ty_xiao_ji")
    self.ty_xiao_ji:setPositionX(self.ty_xiao_ji:getPositionX()+50)

    --test
    -- self.parent.lTotalRebates = 120000000
    -- self.parent.dwReceiveTimes = 0

    self.box_scale_progress = self.container:getChildByName("box_scale_progress")
    local percentNum = math.floor((self.parent.lTotalRebates%120000000)*100/120000000)
    if (self.parent.lTotalRebates%120000000) > 0 and percentNum == 0 then
        percentNum = 1
    elseif self.parent.lTotalRebates > 0 and (self.parent.lTotalRebates%120000000) == 0 and percentNum == 0 then
        percentNum = 100
    end
    self.box_scale_progress:setPercent(percentNum)

    --分割线
    local sepLine = ccui.ImageView:create("view/ddz_recommand/box_seperate_line.png")
    sepLine:setPosition(126,82)
    self.container:addChild(sepLine)

    local text_num = ccui.Text:create("1000万","",20)
    text_num:setPosition(126,64)
    text_num:setTextColor(cc.c4b(0x8b,0x43,0x0e,255))
    self.container:addChild(text_num)

    local sepLine = ccui.ImageView:create("view/ddz_recommand/box_seperate_line.png")
    sepLine:setPosition(252,82)
    self.container:addChild(sepLine)

    local text_num = ccui.Text:create("2000万","",20)
    text_num:setPosition(252,64)
    text_num:setTextColor(cc.c4b(0x8b,0x43,0x0e,255))
    self.container:addChild(text_num)    

    local sepLine = ccui.ImageView:create("view/ddz_recommand/box_seperate_line.png")
    sepLine:setPosition(379,82)
    self.container:addChild(sepLine)

    local text_num = ccui.Text:create("3000万","",20)
    text_num:setPosition(379,64)
    text_num:setTextColor(cc.c4b(0x8b,0x43,0x0e,255))
    self.container:addChild(text_num)    

    local sepLine = ccui.ImageView:create("view/ddz_recommand/box_seperate_line.png")
    sepLine:setPosition(500,82)
    self.container:addChild(sepLine)

    local text_num = ccui.Text:create("4000万","",20)
    text_num:setPosition(500,64)
    text_num:setTextColor(cc.c4b(0x8b,0x43,0x0e,255))
    self.container:addChild(text_num)

    local sepLine = ccui.ImageView:create("view/ddz_recommand/box_seperate_line.png")
    sepLine:setPosition(627,82)
    self.container:addChild(sepLine)

    local text_num = ccui.Text:create("5000万","",20)
    text_num:setPosition(627,64)
    text_num:setTextColor(cc.c4b(0x8b,0x43,0x0e,255))
    self.container:addChild(text_num)

    local text_num = ccui.Text:create("6000万","",20)
    text_num:setPosition(734,64)
    text_num:setTextColor(cc.c4b(0x8b,0x43,0x0e,255))
    self.container:addChild(text_num)

    self.Text_Award_Num_Replace = self.container:getChildByName("Text_Award_Num")
    self.Text_Award_Num_Replace:hide()

    self.Text_Award_Num = ccui.Text:create("0","",24)
    self.Text_Award_Num:setAnchorPoint(cc.p(0,0.5))
    self.Text_Award_Num:setPosition(self.Text_Award_Num_Replace:getPositionX(),self.Text_Award_Num_Replace:getPositionY())
    self.Text_Award_Num:setTextColor(cc.c4b(0xf8,0xff,0x00,255))
    self.Text_Award_Num:enableOutline(cc.c4b(0x7e,0x43,0x16,255), 2)
    self.Text_Award_Num:setString(FormatDigitToString(self.parent.lTotalRebates, 1))
    self.container:addChild(self.Text_Award_Num)

    --关闭
    local btnClose = ccui.Helper:seekWidgetByName(self.container, "btn_close")
    if btnClose then
        btnClose:setPressedActionEnabled(true)
        btnClose:addTouchEventListener(function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:hide()
                Click()
            end
        end)
    end

    self.btnBox1 = ccui.Helper:seekWidgetByName(self.container, "btn_red_box1")
    if self.btnBox1 then
        self.btnBox1:setPressedActionEnabled(true)
        self.btnBox1:addTouchEventListener(function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                UserService:ReceiveInviteChestRequest()
                Click()
            end
        end)
    end

    self.btnBox2 = ccui.Helper:seekWidgetByName(self.container, "btn_red_box2")
    if self.btnBox2 then
        self.btnBox2:setPressedActionEnabled(true)
        self.btnBox2:addTouchEventListener(function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                UserService:ReceiveInviteChestRequest()
                Click()
            end
        end)
    end

    self.btnBox3 = ccui.Helper:seekWidgetByName(self.container, "btn_red_box3")
    if self.btnBox3 then
        self.btnBox3:setPressedActionEnabled(true)
        self.btnBox3:addTouchEventListener(function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                UserService:ReceiveInviteChestRequest()
                Click()
            end
        end)
    end

    self.btnBox4 = ccui.Helper:seekWidgetByName(self.container, "btn_red_box4")
    if self.btnBox4 then
        self.btnBox4:setPressedActionEnabled(true)
        self.btnBox4:addTouchEventListener(function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                UserService:ReceiveInviteChestRequest()
                Click()
            end
        end)
    end

    self.btnBox5 = ccui.Helper:seekWidgetByName(self.container, "btn_red_box5")
    if self.btnBox5 then
        self.btnBox5:setPressedActionEnabled(true)
        self.btnBox5:addTouchEventListener(function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                UserService:ReceiveInviteChestRequest()
                Click()
            end
        end)
    end

    self.btnBox6 = ccui.Helper:seekWidgetByName(self.container, "btn_red_box6")
    if self.btnBox6 then
        self.btnBox6:setPressedActionEnabled(true)
        self.btnBox6:addTouchEventListener(function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                UserService:ReceiveInviteChestRequest()
                Click()
            end
        end)
    end

    self.box_bg_light1 = self.container:getChildByName("box_bg_light1")
    self.box_bg_light1:hide()
    self.box_bg_light2 = self.container:getChildByName("box_bg_light2")
    self.box_bg_light2:hide()
    self.box_bg_light3 = self.container:getChildByName("box_bg_light3")
    self.box_bg_light3:hide()
    self.box_bg_light4 = self.container:getChildByName("box_bg_light4")
    self.box_bg_light4:hide()
    self.box_bg_light5 = self.container:getChildByName("box_bg_light5")
    self.box_bg_light5:hide()
    self.box_bg_light6 = self.container:getChildByName("box_bg_light6")
    self.box_bg_light6:hide()

    self.box_light1 = self.container:getChildByName("box_light1")
    self.box_light1:hide()
    self.box_light2 = self.container:getChildByName("box_light2")
    self.box_light2:hide()
    self.box_light3 = self.container:getChildByName("box_light3")
    self.box_light3:hide()
    self.box_light4 = self.container:getChildByName("box_light4")
    self.box_light4:hide()
    self.box_light5 = self.container:getChildByName("box_light5")
    self.box_light5:hide()
    self.box_light6 = self.container:getChildByName("box_light6")
    self.box_light6:hide()

    --累计总额共可领取宝箱个数
    local nTotal = math.floor(self.parent.lTotalRebates/120000000)*6 + math.floor(self.parent.lTotalRebates%120000000/20000000)
    if nTotal > self.parent.dwReceiveTimes then
        local caseIndex = (self.parent.dwReceiveTimes+1)%6
        self:refreshBoxView(caseIndex)
    elseif nTotal == self.parent.dwReceiveTimes then
        local caseIndex = self.parent.dwReceiveTimes%6
        self:refreshOpenedBoxView(caseIndex)
    end

    local zhuBoMM = self.parent:getZhuBoMMAnimation()
    zhuBoMM:ignoreAnchorPointForPosition(false)
    zhuBoMM:setAnchorPoint(cc.p(0,0))
    zhuBoMM:setPosition(cc.p(-126,20))
    self.container:addChild(zhuBoMM)
    zhuBoMM:getAnimation():playWithIndex(0)
    zhuBoMM:setRotation(-12)

    --test
    -- self.parent.dwReceiveTimes = 12
    -- self.parent:showGetAwardView(0,((self.parent.dwReceiveTimes%6)==0))

end

function BoxRewardLayer:refreshInitState()

    self.btnBox1:setEnabled(false)
    self.btnBox2:setEnabled(false)
    self.btnBox3:setEnabled(false)
    self.btnBox4:setEnabled(false)
    self.btnBox5:setEnabled(false)
    self.btnBox6:setEnabled(false)

    self.btnBox1:setBright(true)
    self.btnBox2:setBright(true)
    self.btnBox3:setBright(true)
    self.btnBox4:setBright(true)
    self.btnBox5:setBright(true)
    self.btnBox6:setBright(true)

    self.btnBox1:stopAllActions()
    self.btnBox2:stopAllActions()
    self.btnBox3:stopAllActions()
    self.btnBox4:stopAllActions()
    self.btnBox5:stopAllActions()
    self.btnBox6:stopAllActions()

    self.box_bg_light1:stopAllActions()
    self.box_bg_light2:stopAllActions()
    self.box_bg_light3:stopAllActions()
    self.box_bg_light4:stopAllActions()
    self.box_bg_light5:stopAllActions()
    self.box_bg_light6:stopAllActions()

    self.box_bg_light1:hide()
    self.box_bg_light2:hide()
    self.box_bg_light3:hide()
    self.box_bg_light4:hide()
    self.box_bg_light5:hide()
    self.box_bg_light6:hide()

    self.box_light1:stopAllActions()
    self.box_light2:stopAllActions()
    self.box_light3:stopAllActions()
    self.box_light4:stopAllActions()
    self.box_light5:stopAllActions()
    self.box_light6:stopAllActions()

    self.box_light1:hide()
    self.box_light2:hide()
    self.box_light3:hide()
    self.box_light4:hide()
    self.box_light5:hide()
    self.box_light6:hide()
end

function BoxRewardLayer:refreshOpenedBoxView(caseIndex)

    self:refreshInitState()

    if caseIndex == 1 then--1个宝箱已领
        self.btnBox1:setBright(false)
    end
    if caseIndex == 2 then--2个宝箱已领
        self.btnBox1:setBright(false)
        self.btnBox2:setBright(false)
    end
    if caseIndex == 3 then--3个宝箱已领
        self.btnBox1:setBright(false)
        self.btnBox2:setBright(false)
        self.btnBox3:setBright(false)
    end
    if caseIndex == 4 then--4个宝箱已领
        self.btnBox1:setBright(false)
        self.btnBox2:setBright(false)
        self.btnBox3:setBright(false)
        self.btnBox4:setBright(false)
    end
    if caseIndex == 5 then--5个宝箱已领
        self.btnBox1:setBright(false)
        self.btnBox2:setBright(false)
        self.btnBox3:setBright(false)
        self.btnBox4:setBright(false)
        self.btnBox5:setBright(false)
    end
end

function BoxRewardLayer:refreshBoxView(caseIndex)

    self:refreshInitState()

    if caseIndex == 0 then--第6个宝箱可以领
        self.btnBox1:setBright(false)
        self.btnBox2:setBright(false)
        self.btnBox3:setBright(false)
        self.btnBox4:setBright(false)
        self.btnBox5:setBright(false)
        self.btnBox6:setEnabled(true)

        self.box_light6:show()
        self.box_bg_light6:show()
        self.box_light6:runAction(cc.RepeatForever:create(cc.Sequence:create(
                cc.ScaleTo:create(0.8, 1.1),
                cc.ScaleTo:create(0.8, 1.0)
            )))
        self.box_bg_light6:runAction(cc.RepeatForever:create(cc.Sequence:create(
                cc.RotateBy:create(18, 360)
            )))
        self.btnBox6:runAction(cc.RepeatForever:create(cc.Sequence:create(
                cc.ScaleTo:create(0.8, 1.1),
                cc.ScaleTo:create(0.8, 1.0)
            )))
    end
    if caseIndex == 1 then--第1个宝箱可以领
        self.btnBox1:setEnabled(true)

        self.box_light1:show()
        self.box_bg_light1:show()
        self.box_light1:runAction(cc.RepeatForever:create(cc.Sequence:create(
                cc.ScaleTo:create(0.8, 1.1),
                cc.ScaleTo:create(0.8, 1.0)
            )))
        self.box_bg_light1:runAction(cc.RepeatForever:create(cc.Sequence:create(
                cc.RotateBy:create(18, 360)
            )))
        self.btnBox1:runAction(cc.RepeatForever:create(cc.Sequence:create(
                cc.ScaleTo:create(0.8, 1.1),
                cc.ScaleTo:create(0.8, 1.0)
            )))
    end
    if caseIndex == 2 then--第2个宝箱可以领
        self.btnBox1:setBright(false)
        self.btnBox2:setEnabled(true)

        self.box_light2:show()
        self.box_bg_light2:show()
        self.box_light2:runAction(cc.RepeatForever:create(cc.Sequence:create(
                cc.ScaleTo:create(0.8, 1.1),
                cc.ScaleTo:create(0.8, 1.0)
            )))
        self.box_bg_light2:runAction(cc.RepeatForever:create(cc.Sequence:create(
                cc.RotateBy:create(18, 360)
            )))
        self.btnBox2:runAction(cc.RepeatForever:create(cc.Sequence:create(
                cc.ScaleTo:create(0.8, 1.1),
                cc.ScaleTo:create(0.8, 1.0)
            )))
    end
    if caseIndex == 3 then--第3个宝箱可以领
        self.btnBox1:setBright(false)
        self.btnBox2:setBright(false)
        self.btnBox3:setEnabled(true)

        self.box_light3:show()
        self.box_bg_light3:show()
        self.box_light3:runAction(cc.RepeatForever:create(cc.Sequence:create(
                cc.ScaleTo:create(0.8, 1.1),
                cc.ScaleTo:create(0.8, 1.0)
            )))
        self.box_bg_light3:runAction(cc.RepeatForever:create(cc.Sequence:create(
                cc.RotateBy:create(18, 360)
            )))
        self.btnBox3:runAction(cc.RepeatForever:create(cc.Sequence:create(
                cc.ScaleTo:create(0.8, 1.1),
                cc.ScaleTo:create(0.8, 1.0)
            )))
    end
    if caseIndex == 4 then--第4个宝箱可以领
        self.btnBox1:setBright(false)
        self.btnBox2:setBright(false)
        self.btnBox3:setBright(false)
        self.btnBox4:setEnabled(true)

        self.box_light4:show()
        self.box_bg_light4:show()
        self.box_light4:runAction(cc.RepeatForever:create(cc.Sequence:create(
                cc.ScaleTo:create(0.8, 1.1),
                cc.ScaleTo:create(0.8, 1.0)
            )))
        self.box_bg_light4:runAction(cc.RepeatForever:create(cc.Sequence:create(
                cc.RotateBy:create(18, 360)
            )))
        self.btnBox4:runAction(cc.RepeatForever:create(cc.Sequence:create(
                cc.ScaleTo:create(0.8, 1.1),
                cc.ScaleTo:create(0.8, 1.0)
            )))
    end
    if caseIndex == 5 then--第5个宝箱可以领
        self.btnBox1:setBright(false)
        self.btnBox2:setBright(false)
        self.btnBox3:setBright(false)
        self.btnBox4:setBright(false)
        self.btnBox5:setEnabled(true)

        self.box_light5:show()
        self.box_bg_light5:show()
        self.box_light5:runAction(cc.RepeatForever:create(cc.Sequence:create(
                cc.ScaleTo:create(0.8, 1.1),
                cc.ScaleTo:create(0.8, 1.0)
            )))
        self.box_bg_light5:runAction(cc.RepeatForever:create(cc.Sequence:create(
                cc.RotateBy:create(18, 360)
            )))
        self.btnBox5:runAction(cc.RepeatForever:create(cc.Sequence:create(
                cc.ScaleTo:create(0.8, 1.1),
                cc.ScaleTo:create(0.8, 1.0)
            )))
    end    
end

function BoxRewardLayer:onEnter()
    self.receiveInviteChest = UserService:addEventListener(HallCenterEvent.EVENT_RECEIVINVITECHEST, handler(self, self.receiveInviteChestBack))
end

function BoxRewardLayer:onExit()
    UserService:removeEventListener(self.receiveInviteChest)
end

function BoxRewardLayer:receiveInviteChestBack(event)
    local data = protocol.hall.business_pb.CMD_MB_ReceivInviteChest_Result_Pro()
    data:ParseFromString(event.data)
    print("receiveInviteChestBack......",data.nResultCode,data.szDescribe,data.nLastChestProgress)

    self.parent.progressBar:setPercent(data.nLastChestProgress)
    self.parent.progressNum:setString(data.nLastChestProgress.."%")

    if data.nResultCode == 0 then
        self.parent.dwReceiveTimes = self.parent.dwReceiveTimes + 1
        --累计总额共可领取宝箱个数
        local nTotal = self.parent.lTotalRebates%60000000*6 + math.floor(self.parent.lTotalRebates%10000000)
        if nTotal > self.parent.dwReceiveTimes then
            local caseIndex = (self.parent.dwReceiveTimes+1)%6
            self:refreshBoxView(caseIndex)
        elseif nTotal == self.parent.dwReceiveTimes then
            local caseIndex = self.parent.dwReceiveTimes%6
            self:refreshOpenedBoxView(caseIndex)
        end
        self.parent:showGetAwardView(0,((self.parent.dwReceiveTimes%6)==0))
    else
        Hall.showTips(data.szDescribe)
    end
end

return BoxRewardLayer