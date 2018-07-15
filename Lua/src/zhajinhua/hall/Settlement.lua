local Settlement = class("Settlement",function() return display.newLayer() end)

local winSize = cc.Director:getInstance():getWinSize()

function Settlement:ctor()
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    self:setNodeEventEnabled(true)
    
    
    local contentSize = cc.size(winSize.width,winSize.height)
    self:setContentSize(contentSize)

    -- 蒙板
    local maskLayer = ccui.ImageView:create()
    maskLayer:loadTexture("common/black.png")
    maskLayer:setContentSize(contentSize);
    maskLayer:setScale9Enabled(true)
    maskLayer:setCapInsets(cc.rect(4,4,1,1))
    maskLayer:setPosition(cc.p(contentSize.width/2, winSize.height/2));
    maskLayer:setTouchEnabled(true)
    self:addChild(maskLayer)

    self:createUI();
    
end

function Settlement:createUI()
    local contentSize = self:getContentSize()

    local bgSprite = ccui.ImageView:create("common/pop_bg.png");
    bgSprite:setPosition(cc.p(winSize.width / 2, display.cy));
    bgSprite:setScale9Enabled(true);
    bgSprite:setContentSize(cc.size(706, 450));
    self:addChild(bgSprite);

    local panel = ccui.ImageView:create("common/panel.png")
    panel:setScale9Enabled(true);
    panel:setContentSize(cc.size(590,260));
    panel:setPosition(355, 250)
    bgSprite:addChild(panel)

    local titleSprite = ccui.ImageView:create("common/pop_title.png");
    titleSprite:setScale9Enabled(true);
    titleSprite:setContentSize(cc.size(250, 50));
    titleSprite:setPosition(cc.p(355, 415));
    bgSprite:addChild(titleSprite,2);

    local title = ccui.Text:create("游戏币结算", FONT_ART_TEXT, 24)
    title:setPosition(cc.p(125, 30))
    title:setTextColor(cc.c4b(251,248,142,255))
    title:enableOutline(cc.c4b(137,0,167,200), 3)
    title:addTo(titleSprite)


    local exit = ccui.Button:create("common/close.png");
    exit:setPosition(cc.p(695, 435));
    bgSprite:addChild(exit);
    exit:setPressedActionEnabled(true);
    exit:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
            	package.loaded["hall.Settlement"] = nil
                self:removeFromParent();
            end
        end
    )

    local noNotice = ccui.ImageView:create("hall/notice/dizhu.png")
    panel:addChild(noNotice)
    noNotice:setPosition(120, 130)
    self.renImg = noNotice


    local texttitle = ccui.Text:create()
    texttitle:setString("之前游戏币:45900")
    texttitle:setColor(cc.c4b(255,233,110,255))
    texttitle:enableOutline(cc.c4b(141,0,166,255), 2)
    texttitle:setFontSize(22)
    texttitle:setAnchorPoint(cc.p(0, 0.5))
    texttitle:setPosition(280, 220)
    panel:addChild(texttitle)
    self.preMoneyTxt = texttitle

    local texttitle = ccui.Text:create()
    texttitle:setString("现在游戏币:25900")
    texttitle:setColor(cc.c4b(255,233,110,255))
    texttitle:enableOutline(cc.c4b(141,0,166,255), 2)
    texttitle:setFontSize(22)
    texttitle:setAnchorPoint(cc.p(0, 0.5))
    texttitle:setPosition(280, 170)
    panel:addChild(texttitle)
    self.curMoneyTxt = texttitle


    local texttitle = ccui.Text:create()
    texttitle:setString("输掉:25900")
    texttitle:setColor(cc.c4b(255,233,110,255))
    texttitle:enableOutline(cc.c4b(141,0,166,255), 2)
    texttitle:setFontSize(22)
    texttitle:setAnchorPoint(cc.p(0, 0.5))
    texttitle:setPosition(280, 120)
    panel:addChild(texttitle)
    self.shuyingTxt = texttitle


    local texttitle = ccui.Text:create()
    texttitle:setString("没关系，再接再厉")
    texttitle:setColor(cc.c4b(255,233,110,255))
    texttitle:enableOutline(cc.c4b(141,0,166,255), 2)
    texttitle:setFontSize(20)
    texttitle:setAnchorPoint(cc.p(1, 0.5))
    texttitle:setPosition(560, 40)
    panel:addChild(texttitle)
    self.anweiTxt = texttitle


    local select1 = ccui.ImageView:create("common/panel.png");
    select1:setTouchEnabled(true);
    select1:setPosition(cc.p(80, 70));
    bgSprite:addChild(select1);
    select1:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended and self.manSelect:isVisible() == false then
                
                Click();
            end
        end
    )

    local tipSelect = ccui.ImageView:create("hall/personalCenter/select.png");
    tipSelect:setPosition(cc.p(30, 26));
    select1:addChild(tipSelect);
    self.tipSelect = tipSelect;

    local texttitle = ccui.Text:create()
    texttitle:setString("今天不再提醒")
    texttitle:setColor(cc.c4b(255,233,110,255))
    texttitle:enableOutline(cc.c4b(141,0,166,255), 2)
    texttitle:setFontSize(20)
    texttitle:setAnchorPoint(cc.p(0, 0.5))
    texttitle:setPosition(115, 70)
    bgSprite:addChild(texttitle)

    

    -- local curGoldText = ccui.Text:create()
    -- curGoldText:setString("当前筹码 :")
    -- curGoldText:setColor(cc.c3b(200,191,100))
    -- curGoldText:setFontSize(22)
    -- curGoldText:setAnchorPoint(cc.p(0,0.5))
    -- curGoldText:setPosition(cc.p(38, 67))
    -- panel:addChild(curGoldText)

    -- self.curGoldValue = ccui.Text:create()
    -- self.curGoldValue:setString("0")
    -- self.curGoldValue:setColor(cc.c3b(200,191,100))
    -- self.curGoldValue:setFontSize(22)
    -- self.curGoldValue:setAnchorPoint(cc.p(0,0.5))
    -- self.curGoldValue:setPosition(cc.p(160, 67))
    -- panel:addChild(self.curGoldValue)

    -- local curInsureGoldText = ccui.Text:create()
    -- curInsureGoldText:setString("银行筹码 :")
    -- curInsureGoldText:setColor(cc.c3b(200,191,100))
    -- curInsureGoldText:setFontSize(22)
    -- curInsureGoldText:setAnchorPoint(cc.p(0, 0.5))
    -- curInsureGoldText:setPosition(cc.p(38, 35))
    -- panel:addChild(curInsureGoldText)

    -- self.curInsureGoldValue = ccui.Text:create()
    -- self.curInsureGoldValue:setString("0")
    -- self.curInsureGoldValue:setColor(cc.c3b(200,191,100))
    -- self.curInsureGoldValue:setFontSize(22)
    -- self.curInsureGoldValue:setAnchorPoint(cc.p(0,0.5))
    -- self.curInsureGoldValue:setPosition(cc.p(160, 35))
    -- panel:addChild(self.curInsureGoldValue)



    -- -- 存银行
    -- local cunprogress = cc.ControlSlider:create("hall/bank/bank_process_bg.png","hall/bank/bank_process_blue.png","hall/bank/bank_process_button.png")
    -- bankConainer:addChild(cunprogress)
    -- cunprogress:setPosition(216, 150)
    -- cunprogress:setMinimumValue(0);
    -- cunprogress:setMaximumValue(100);
    -- cunprogress:registerControlEventHandler(
    --     function ()
    --         self:cunprogressHandler(cunprogress);
    --     end,
    --     cc.CONTROL_EVENTTYPE_VALUE_CHANGED
    --     )
    -- self.cunprogress = cunprogress;

    -- local cuntips = ccui.ImageView:create("hall/bank/slide_money_bg.png")
    -- cuntips:setPosition(cc.p(80, 185))
    -- bankConainer:addChild(cuntips)
    -- self.cuntips = cuntips;
    -- local cuntxt = ccui.Text:create()
    -- cuntxt:setFontSize(18)
    -- cuntxt:setColor(cc.c3b(182,153,121))
    -- cuntxt:setString("0")
    -- cuntxt:setPosition(40, 15)
    -- cuntips:addChild(cuntxt)
    -- self.cuntxt = cuntxt;

    -- local cunbutton = ccui.Button:create();
    -- cunbutton:loadTextures("hall/bank/cun_btn.png", "hall/bank/cun_btn_selected.png")
    -- cunbutton:setPosition(cc.p(590, 150));
    -- bankConainer:addChild(cunbutton);
    -- cunbutton:setPressedActionEnabled(true);
    -- cunbutton:getTitleRenderer():enableOutline(COLOR_BTN_BLUE,2)
    -- cunbutton:addTouchEventListener(
    --     function(sender,eventType)
    --         if eventType == ccui.TouchEventType.ended then

    --             self:cunbuttonHandler();

    --         end
    --     end
    -- )

    -- local zeroGoldTxt = ccui.Text:create()
    -- zeroGoldTxt:setFontSize(22)
    -- zeroGoldTxt:setColor(cc.c3b(200,191,100))
    -- zeroGoldTxt:setString("0")
    -- zeroGoldTxt:setPosition(40, 150)
    -- bankConainer:addChild(zeroGoldTxt)

    -- local curGoldTxt = ccui.Text:create()
    -- curGoldTxt:setFontSize(22)
    -- curGoldTxt:setColor(cc.c3b(200,191,100))
    -- curGoldTxt:setString("5000万")
    -- curGoldTxt:setPosition(390, 150)
    -- curGoldTxt:setAnchorPoint(cc.p(0, 0.5))
    -- bankConainer:addChild(curGoldTxt)
    -- self.curGoldTxt = curGoldTxt;

    -- --取钱
    -- self.quprogress = cc.ControlSlider:create("hall/bank/bank_process_bg.png","hall/bank/bank_process_blue.png","hall/bank/bank_process_button.png")
    -- self.quprogress:setPosition(cc.p(216, 70))
    -- bankConainer:addChild(self.quprogress)
    -- self.quprogress:setMinimumValue(0);
    -- self.quprogress:setMaximumValue(100);
    -- self.quprogress:registerControlEventHandler(
    --     function ()
    --         self:quprogressHandler(self.quprogress)
    --     end,cc.CONTROL_EVENTTYPE_VALUE_CHANGED
    -- )

    -- local qutips = ccui.ImageView:create("hall/bank/slide_money_bg.png")
    -- qutips:setPosition(80, 105)
    -- self.qutips = qutips;
    -- bankConainer:addChild(qutips)
    -- local qutxt = ccui.Text:create()
    -- qutxt:setFontSize(18)
    -- qutxt:setColor(cc.c3b(182,153,121))
    -- qutxt:setString("0")
    -- qutxt:setPosition(40, 15)
    -- qutips:addChild(qutxt)
    -- self.qutxt = qutxt;

    -- local qubutton = ccui.Button:create();
    -- qubutton:loadTextures("hall/bank/qu_btn.png", "hall/bank/qu_btn_selected.png")
    -- qubutton:setPosition(cc.p(590, 70));
    -- bankConainer:addChild(qubutton);
    -- qubutton:setPressedActionEnabled(true);
    -- qubutton:getTitleRenderer():enableOutline(COLOR_BTN_GREEN,2)
    -- qubutton:addTouchEventListener(
    --     function(sender,eventType)
    --         if eventType == ccui.TouchEventType.ended then

    --             self:qubuttonHandler();

    --         end
    --     end
    -- )
    -- local zeroGoldTxt = ccui.Text:create()
    -- zeroGoldTxt:setFontSize(22)
    -- zeroGoldTxt:setColor(cc.c3b(200,191,100))
    -- zeroGoldTxt:setString("0")
    -- zeroGoldTxt:setPosition(40, 70)
    -- bankConainer:addChild(zeroGoldTxt)

    -- local curInsureTxt = ccui.Text:create()
    -- curInsureTxt:setFontSize(22)
    -- curInsureTxt:setColor(cc.c3b(200,191,100))
    -- curInsureTxt:setString("1000万")
    -- curInsureTxt:setPosition(390, 70)
    -- curInsureTxt:setAnchorPoint(cc.p(0, 0.5))
    -- bankConainer:addChild(curInsureTxt)
    -- self.curInsureTxt = curInsureTxt;
end
function Settlement:cunprogressHandler(sender)
    local value = sender:getValue();

    local scoreNow = self.score*value/100.0;
    local widthmax = self.cunprogress:getContentSize().width
    local posX = 80+widthmax*value/100.0
    self.cuntips:setPositionX(posX);
    self.selectScore = math.floor(scoreNow)
    self.cuntxt:setString(FormatNumToString(self.selectScore)) --print("---self.selectScore----", self.selectScore)
end
function Settlement:quprogressHandler( sender )
    local value = sender:getValue();

    local insureNow = self.insure*value/100.0;
    local widthmax = self.quprogress:getContentSize().width
    local posX = 80+widthmax*value/100.0
    self.qutips:setPositionX(posX);

    self.selectInsure = math.floor(insureNow);
    self.qutxt:setString(FormatNumToString(self.selectInsure))
end
function Settlement:resetProgress()
    self.selectScore = 0
    self.cuntxt:setString(FormatNumToString(self.selectScore))
    local posX = 330
    self.cuntips:setPositionX(posX);
    self.cunprogress:setValue(0)

    self.selectInsure = 0
    self.qutxt:setString(FormatNumToString(self.selectInsure))
    local posX = 330
    self.qutips:setPositionX(posX);
    self.quprogress:setValue(0)
end
function Settlement:queryHandler()
    local dwUserID = PlayerInfo:getMyUserID()
    print("PlayerInfo:getMyUserID()",dwUserID)

    if self.inGame == false then
        
        UserService:sendQueryInsureInfo()
    else
        local queryInsureInfo = protocol.hall.treasureInfo_pb.CMD_GR_C_QueryInsureInfo_Pro()
        queryInsureInfo.cbActivityGame = dwUserID
        local pData = queryInsureInfo:SerializeToString()
        local pDataLen = string.len(pData)

        local main = CMD_GameServer.MDM_GR_INSURE
        local sub = CMD_GameServer.SUB_GR_QUERY_INSURE_INFO
        
        GameCenter:sendData(main,sub,pData,pDataLen)
    end
end

--取钱
function Settlement:qubuttonHandler()
    if self.insure <=0 then
        Hall.showTips("您没有可以去的金币了，请前往商城去充值吧", 1)
        return
    end
    ;
    local dwUserID = PlayerInfo:getMyUserID()
    if self.inGame == false then
        local  takeScorePro = protocol.hall.treasureInfo_pb.CMD_GP_UserTakeScore_Pro()
        takeScorePro.dwUserID = dwUserID
        takeScorePro.lTakeScore = self.selectInsure
        takeScorePro.szPassword = GetDeviceID()
        takeScorePro.szMachineID = GetDeviceID()

        local pData = takeScorePro:SerializeToString()
        local pDataLen = string.len(pData)

        local main = CMD_LogonServer.MDM_GP_USER_SERVICE
        local sub = CMD_LogonServer.SUB_GP_USER_TAKE_SCORE

        
        HallCenter:send(main,sub,pData,pDataLen)
    else
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
    
end
--存钱
function Settlement:cunbuttonHandler()
    local dwUserID = PlayerInfo:getMyUserID()
	if self.inGame == false then
        local wMainID = CMD_LogonServer.MDM_GP_USER_SERVICE
        local wSubID = CMD_LogonServer.SUB_GP_USER_SAVE_SCORE

        local data = protocol.hall.treasureInfo_pb.CMD_GP_UserSaveScore_Pro();--protocol.hall.treasureInfo_pb
        data.dwUserID = dwUserID;
        data.lSaveScore = self.selectScore;
        data.szMachineID = GetDeviceID();
        
        local pData = data:SerializeToString()
        local pDataLen = string.len(pData)
        
        HallCenter:send(wMainID,wSubID,pData,pDataLen)
    else
        Hall.showTips("游戏中不能存筹码",2) 

        -- local wMainID = CMD_GameServer.MDM_GR_INSURE
        -- local wSubID = CMD_GameServer.SUB_GR_SAVE_SCORE_REQUEST

        -- local data = protocol.hall.treasureInfo_pb.CMD_GR_C_SaveScore_Pro();--protocol.hall.treasureInfo_pb
        -- data.cbActivityGame = dwUserID;
        -- data.lSaveScore = self.selectScore;
        
        -- local pData = data:SerializeToString()
        -- local pDataLen = string.len(pData)
        -- GameCenter:sendData(wMainID,wSubID,pData,pDataLen)
    end
    
end
--查询成功
function Settlement:queryBackHandler(event)
    print("queryBackHandler111 ",event.score, event.insure)
    self.score = event.score;
    self.insure = event.insure;
    self.curGoldValue:setString(FormatDigitToString(self.score, 1))
    self.curInsureGoldValue:setString(FormatDigitToString(self.insure, 1))
    self.curGoldTxt:setString(FormatDigitToString(self.score, 1))
    self.curInsureTxt:setString(FormatDigitToString(self.insure, 1))
end
--银行操作成功
function Settlement:bankSucceseHandler(event)
    self.curInsureGoldValue:setString(FormatNumToString(event.insure))
    self.curGoldValue:setString(FormatNumToString(event.score));
    self.curInsureTxt:setString(FormatNumToString(event.insure))
    self.curGoldTxt:setString(FormatNumToString(event.score));

    Hall.showTips(event.msg)

    self:queryHandler();
    self:resetProgress();
end
--银行操作失败
function Settlement:bankFailureHandler(event)
    
    Hall.showTips(event.msg)
end
function Settlement:registerGameEvent()
    if self.inGame then
        self.handler1 = GameCenter:addEventListener(GameCenterEvent.EVENT_QUERY_INSURE_FOR_GAMEBANK, handler(self, self.queryBackHandler))
        self.handler2 = GameCenter:addEventListener(GameCenterEvent.EVENT_USERINSURE_SUCCESS_FOR_GAME, handler(self, self.bankSucceseHandler))
        self.handler3 = GameCenter:addEventListener(GameCenterEvent.EVENT_USERINSURE_FAILURE_FOR_GAME, handler(self, self.bankFailureHandler))
    else
        
        self.handler1 = UserService:addEventListener(HallCenterEvent.EVENT_QUERY_INSURE_FOR_ROOMBANK, handler(self, self.queryBackHandler))
        self.handler2 = UserService:addEventListener(HallCenterEvent.EVENT_USERINSURE_SUCCESS, handler(self, self.bankSucceseHandler))
        self.handler3 = UserService:addEventListener(HallCenterEvent.EVENT_USERINSURE_FAILURE, handler(self, self.bankFailureHandler))
    end

end
function Settlement:removeGameEvent()
    if self.inGame then
        GameCenter:removeEventListener(self.handler1)
        GameCenter:removeEventListener(self.handler2)
        GameCenter:removeEventListener(self.handler3)
    else
        
        UserService:removeEventListener(self.handler1)
        UserService:removeEventListener(self.handler2)
        UserService:removeEventListener(self.handler3)
    end
end
return Settlement