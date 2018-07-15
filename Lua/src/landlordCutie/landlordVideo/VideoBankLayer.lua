local VideoBankLayer = class("VideoBankLayer",function() return display.newLayer() end)




function VideoBankLayer:ctor()
    self.score = 0
    self.insure = 0
    self.selectScore = 0
    self.selectInsure = 0

    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    self:setNodeEventEnabled(true)
    self:registerGameEvent();
    

    local winSize = cc.Director:getInstance():getWinSize()
    local contentSize = cc.size(1136,winSize.height)
    self:setContentSize(contentSize)
    -- 蒙板
    local maskLayer = ccui.ImageView:create("blank.png")
    maskLayer:setScale9Enabled(true)
    maskLayer:setContentSize(contentSize)
    maskLayer:setPosition(cc.p(display.cx, display.cy));
    maskLayer:setTouchEnabled(true)
    self:addChild(maskLayer)
    local maskImg = ccui.ImageView:create("landlordVideo/video_mask.png")
    maskImg:setPosition(cc.p(757, winSize.height / 2));
    maskLayer:addChild(maskImg)

    self:createUI();
    self:queryHandler();
    
end

function VideoBankLayer:createUI()
    local contentSize = self:getContentSize()

    local bankConainer = ccui.ImageView:create()
    bankConainer:loadTexture("common/pop_bg.png")
    bankConainer:setScale9Enabled(true)
    bankConainer:setContentSize(cc.size(622,435))
    bankConainer:setCapInsets(cc.rect(115,215,1,1))
    bankConainer:setPosition(cc.p(815,display.cy))
    self:addChild(bankConainer)

    local title_text_bg = ccui.ImageView:create()
    title_text_bg:loadTexture("common/pop_title.png")
    title_text_bg:setAnchorPoint(cc.p(0,0.5))
    title_text_bg:setPosition(cc.p(45,395))
    bankConainer:addChild(title_text_bg)
    local title_text = ccui.Text:create("银行", FONT_ART_TEXT, 24)
    title_text:setColor(cc.c3b(255,233,110));
    title_text:enableOutline(cc.c4b(141,0,166,255*0.7),2);
    title_text:setPosition(cc.p(68,65));
    title_text:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER);
    title_text_bg:addChild(title_text);

    local exit = ccui.Button:create("common/close.png");
    exit:setPosition(cc.p(590,400));
    bankConainer:addChild(exit);
    exit:setPressedActionEnabled(true);
    exit:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:removeGameEvent();
                self:removeFromParent();
            end
        end
    )

    local treasureInfo = ccui.ImageView:create()
    treasureInfo:loadTexture("common/panel.png")
    treasureInfo:setContentSize(cc.size(520,140))
    treasureInfo:setScale9Enabled(true)
    treasureInfo:setCapInsets(cc.rect(39,39,1,1))
    treasureInfo:setPosition(cc.p(305,280))
    bankConainer:addChild(treasureInfo)
    local curGoldText = ccui.Text:create()
    curGoldText:setString("现有金币：")
    curGoldText:setColor(cc.c3b(255,249,85))
    curGoldText:enableOutline(cc.c3b(83,19,13), 2)
    curGoldText:setFontSize(24)
    curGoldText:setAnchorPoint(cc.p(0,0.5))
    curGoldText:setPosition(cc.p(30,90))
    treasureInfo:addChild(curGoldText)
    self.curGoldValue = ccui.Text:create()
    self.curGoldValue:setString("0")
    self.curGoldValue:setColor(cc.c3b(245,240,209))
    self.curGoldValue:setFontSize(24)
    self.curGoldValue:setAnchorPoint(cc.p(0,0.5))
    self.curGoldValue:setPosition(cc.p(140,90))
    treasureInfo:addChild(self.curGoldValue)
    local curInsureGoldText = ccui.Text:create()
    curInsureGoldText:setString("银行金币：")
    curInsureGoldText:setColor(cc.c3b(255,249,85))
    curInsureGoldText:enableOutline(cc.c3b(83,19,13), 2)
    curInsureGoldText:setFontSize(24)
    curInsureGoldText:setAnchorPoint(cc.p(0,0.5))
    curInsureGoldText:setPosition(cc.p(30,50))
    treasureInfo:addChild(curInsureGoldText)
    self.curInsureGoldValue = ccui.Text:create()
    self.curInsureGoldValue:setString("0")
    self.curInsureGoldValue:setColor(cc.c3b(245,240,209))
    self.curInsureGoldValue:setFontSize(24)
    self.curInsureGoldValue:setAnchorPoint(cc.p(0,0.5))
    self.curInsureGoldValue:setPosition(cc.p(140,50))
    treasureInfo:addChild(self.curInsureGoldValue)
    local goldCoins = ccui.ImageView:create("hall/bank/goldcoins.png");
    goldCoins:setPosition(cc.p(410, 60));
    treasureInfo:addChild(goldCoins);


    self.quprogress = cc.ControlSlider:create("landlordVideo/vip_bank_process_bg.png","landlordVideo/vip_bank_process_now.png","common/gold.png")
    self.quprogress:setPosition(cc.p(235,110))
    bankConainer:addChild(self.quprogress)
    self.quprogress:setMinimumValue(0);
    self.quprogress:setMaximumValue(100);
    self.quprogress:registerControlEventHandler(
        function ()
            self:quprogressHandler(self.quprogress)
        end,cc.CONTROL_EVENTTYPE_VALUE_CHANGED
        )
    local qutips = ccui.ImageView:create("landlordVideo/vip_bank_qipao.png")
    qutips:setScale9Enabled(true)
    qutips:setCapInsets(cc.rect(30,29,1,1))
    qutips:setContentSize(cc.size(120,59))
    qutips:setPosition(25, 165)
    self.qutips = qutips;
    bankConainer:addChild(qutips)
    local qutxt = ccui.Text:create()
    qutxt:setFontSize(22)
    qutxt:setColor(cc.c3b(242,238,0))
    qutxt:setString("0")
    qutxt:setPosition(55, 35)
    qutips:addChild(qutxt)
    self.qutxt = qutxt;
    local qubutton = ccui.Button:create("landlordVideo/video_greenbutton_bg.png");
    qubutton:setScale9Enabled(true)
    qubutton:setContentSize(cc.size(160,67))
    qubutton:setPosition(cc.p(500,110));
    qubutton:setTitleFontName(FONT_ART_BUTTON);
    qubutton:getTitleRenderer():enableOutline(COLOR_BTN_GREEN,2);
    qubutton:setTitleText("取金币");
    qubutton:setTitleColor(cc.c3b(255,255,255));
    qubutton:setTitleFontSize(28);
    bankConainer:addChild(qubutton);
    qubutton:setPressedActionEnabled(true);
    qubutton:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then

                self:qubuttonHandler();

            end
        end
    )
    
    local curInsureTxt = ccui.Text:create()
    curInsureTxt:setFontSize(22)
    curInsureTxt:setColor(cc.c3b(250,240,243))
    curInsureTxt:enableOutline(cc.c3b(40,6,3), 2)
    curInsureTxt:setString("0")
    curInsureTxt:setPosition(400, 70)
    curInsureTxt:setAnchorPoint(cc.p(1,0.5))
    bankConainer:addChild(curInsureTxt)
    self.curInsureTxt = curInsureTxt;
end

function VideoBankLayer:quprogressHandler( sender )
    local value = sender:getValue();

    local insureNow = self.insure*value/100.0;
    local widthmax = self.quprogress:getContentSize().width
    local posX = 25+widthmax*value/100.0
    self.qutips:setPositionX(posX);

    self.selectInsure = math.floor(insureNow);
    self.qutxt:setString(FormatNumToString(self.selectInsure))
end
function VideoBankLayer:resetProgress()
    self.selectInsure = 0
    self.qutxt:setString(FormatNumToString(self.selectInsure))
    local posX = 25
    self.qutips:setPositionX(posX);
    self.quprogress:setValue(0)
end
function VideoBankLayer:queryHandler()
    local dwUserID = DataManager:getMyUserID()
    print("DataManager:getMyUserID()",dwUserID)

    local queryInsureInfo = protocol.hall.treasureInfo_pb.CMD_GR_C_QueryInsureInfo_Pro()
    queryInsureInfo.cbActivityGame = dwUserID
    local pData = queryInsureInfo:SerializeToString()
    local pDataLen = string.len(pData)

    local main = CMD_GameServer.MDM_GR_INSURE
    local sub = CMD_GameServer.SUB_GR_QUERY_INSURE_INFO
    
    GameCenter:sendData(main,sub,pData,pDataLen)
end

--取钱
function VideoBankLayer:qubuttonHandler()
    local dwUserID = DataManager:getMyUserID()
    local  takeScorePro = protocol.hall.treasureInfo_pb.CMD_GR_C_TakeScore_Pro()
    takeScorePro.cbActivityGame = dwUserID
    takeScorePro.lTakeScore = self.selectInsure
    takeScorePro.szInsurePass = GetDeviceID()

    local pData = takeScorePro:SerializeToString()
    local pDataLen = string.len(pData)

    local main = CMD_GameServer.MDM_GR_INSURE
    local sub = CMD_GameServer.SUB_GR_TAKE_SCORE_REQUEST

    GameCenter:sendData(main,sub,pData,pDataLen)
    
end
--查询成功
function VideoBankLayer:queryBackHandler(event)
    print("queryBackHandler",event.score,event.insure)
    self.score = event.score;
    self.insure = event.insure;
    self.curGoldValue:setString(FormatDigitToString(self.score, 1))
    self.curInsureGoldValue:setString(FormatDigitToString(self.insure, 1))
    self.curInsureTxt:setString(FormatDigitToString(self.insure, 1))
end
--银行操作成功
function VideoBankLayer:bankSucceseHandler(event)
    self.curInsureGoldValue:setString(FormatNumToString(event.insure))
    self.curGoldValue:setString(FormatNumToString(event.score));
    self.curInsureTxt:setString(FormatNumToString(event.insure))

    Hall.showTips(event.msg)

    self:queryHandler();
    self:resetProgress();
end
--银行操作失败
function VideoBankLayer:bankFailureHandler(event)
    
    Hall.showTips(event.msg)
end
function VideoBankLayer:registerGameEvent()
    self.handler1 = GameCenter:addEventListener(GameCenterEvent.EVENT_QUERY_INSURE_FOR_GAMEBANK, handler(self, self.queryBackHandler))
    self.handler2 = GameCenter:addEventListener(GameCenterEvent.EVENT_USERINSURE_SUCCESS_FOR_GAME, handler(self, self.bankSucceseHandler))
    self.handler3 = GameCenter:addEventListener(GameCenterEvent.EVENT_USERINSURE_FAILURE_FOR_GAME, handler(self, self.bankFailureHandler))

end
function VideoBankLayer:removeGameEvent()
    GameCenter:removeEventListener(self.handler1)
    GameCenter:removeEventListener(self.handler2)
    GameCenter:removeEventListener(self.handler3)
end
return VideoBankLayer