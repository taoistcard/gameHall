local BankLayer = class("BankLayer",function() return display.newLayer() end)
local DateModel = require("zhajinhua.DateModel")

function BankLayer:ctor(inGame)
    self.inGame = inGame or false
    self.score = 0
    self.insure = 0
    self.selectScore = 0
    self.selectInsure = 0

    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    self:setNodeEventEnabled(true)
    self:registerGameEvent();
    

    local winSize = cc.Director:getInstance():getWinSize()
    local contentSize
    -- if inGame then
    --     contentSize = cc.size(656,winSize.height)
    -- else
         contentSize = cc.size(winSize.width,winSize.height)
    -- end
    self:setContentSize(contentSize)
    -- 蒙板
    local maskLayer = ccui.ImageView:create()
    maskLayer:loadTexture("common/black.png")
    maskLayer:setContentSize(contentSize);
    maskLayer:setScale9Enabled(true)
    maskLayer:setCapInsets(cc.rect(4,4,1,1))
    maskLayer:setPosition(cc.p(DESIGN_WIDTH/2, DESIGN_HEIGHT/2));
    maskLayer:setTouchEnabled(true)
    self:addChild(maskLayer)

    self:createUI();
    
    if self.inGame then
        BankInfoInGame:sendQueryRequest()
    else
        BankInfo:sendQueryRequest()
    end
    
end

function BankLayer:createUI()
    local contentSize = self:getContentSize()

    local bankConainer = ccui.ImageView:create("common/ty_bank_bg.png");
    bankConainer:setScale9Enabled(true);
    bankConainer:setContentSize(cc.size(674, 433));
    bankConainer:setPosition(cc.p(555, 338));
    self:addChild(bankConainer);

    local exit = ccui.Button:create("common/close.png");
    exit:setPosition(cc.p(880, 545));
    self:addChild(exit);
    exit:setPressedActionEnabled(true);
    exit:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:removeGameEvent();
                self:removeFromParent();
            end
        end
    )

    --头像
    local headView = require("commonView.HeadView").new(1);
    headView:setPosition(cc.p(110, 335))
    bankConainer:addChild(headView);
    self.headImage = headView;

    -- panel
    local panel = ccui.ImageView:create("common/panel_bg.png")
    panel:setScale9Enabled(true);
    panel:setContentSize(cc.size(346, 100));
    panel:setPosition(cc.p(400, 335));
    bankConainer:addChild(panel);

    local texttitle = ccui.Text:create()
    texttitle:setString("存入筹码收取一定的手续费, 取出免手续费")
    texttitle:setColor(cc.c4b(255,233,110,255))
    texttitle:enableOutline(cc.c4b(141,0,166,255), 2)
    texttitle:setFontSize(20)
    texttitle:setPosition(173, -25)
    panel:addChild(texttitle)

    local curGoldText = ccui.Text:create()
    curGoldText:setString("当前筹码 :")
    curGoldText:setColor(cc.c3b(200,191,100))
    curGoldText:setFontSize(22)
    curGoldText:setAnchorPoint(cc.p(0,0.5))
    curGoldText:setPosition(cc.p(38, 67))
    panel:addChild(curGoldText)

    self.curGoldValue = ccui.Text:create()
    self.curGoldValue:setString("0")
    self.curGoldValue:setColor(cc.c3b(200,191,100))
    self.curGoldValue:setFontSize(22)
    self.curGoldValue:setAnchorPoint(cc.p(0,0.5))
    self.curGoldValue:setPosition(cc.p(160, 67))
    panel:addChild(self.curGoldValue)

    local curInsureGoldText = ccui.Text:create()
    curInsureGoldText:setString("银行筹码 :")
    curInsureGoldText:setColor(cc.c3b(200,191,100))
    curInsureGoldText:setFontSize(22)
    curInsureGoldText:setAnchorPoint(cc.p(0, 0.5))
    curInsureGoldText:setPosition(cc.p(38, 35))
    panel:addChild(curInsureGoldText)

    self.curInsureGoldValue = ccui.Text:create()
    self.curInsureGoldValue:setString("0")
    self.curInsureGoldValue:setColor(cc.c3b(200,191,100))
    self.curInsureGoldValue:setFontSize(22)
    self.curInsureGoldValue:setAnchorPoint(cc.p(0,0.5))
    self.curInsureGoldValue:setPosition(cc.p(160, 35))
    panel:addChild(self.curInsureGoldValue)



    -- 存银行
    local cunprogress = cc.ControlSlider:create("hall/bank/bank_process_bg.png","hall/bank/bank_process_blue.png","hall/bank/bank_process_button.png")
    bankConainer:addChild(cunprogress)
    cunprogress:setPosition(216, 150)
    cunprogress:setMinimumValue(0);
    cunprogress:setMaximumValue(100);
    cunprogress:registerControlEventHandler(
        function ()
            self:cunprogressHandler(cunprogress);
        end,
        cc.CONTROL_EVENTTYPE_VALUE_CHANGED
        )
    self.cunprogress = cunprogress;

    local cuntips = ccui.ImageView:create("hall/bank/slide_money_bg.png")
    cuntips:setPosition(cc.p(80, 185))
    bankConainer:addChild(cuntips)
    self.cuntips = cuntips;
    local cuntxt = ccui.Text:create()
    cuntxt:setFontSize(18)
    cuntxt:setColor(cc.c3b(182,153,121))
    cuntxt:setString("0")
    cuntxt:setPosition(40, 15)
    cuntips:addChild(cuntxt)
    self.cuntxt = cuntxt;

    local cunbutton = ccui.Button:create();
    cunbutton:loadTextures("hall/bank/cun_btn.png", "hall/bank/cun_btn_selected.png")
    cunbutton:setPosition(cc.p(590, 150));
    bankConainer:addChild(cunbutton);
    cunbutton:setPressedActionEnabled(true);
    cunbutton:getTitleRenderer():enableOutline(COLOR_BTN_BLUE,2)
    cunbutton:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then

                self:cunbuttonHandler();

            end
        end
    )

    local zeroGoldTxt = ccui.Text:create()
    zeroGoldTxt:setFontSize(22)
    zeroGoldTxt:setColor(cc.c3b(200,191,100))
    zeroGoldTxt:setString("0")
    zeroGoldTxt:setPosition(40, 150)
    bankConainer:addChild(zeroGoldTxt)

    local curGoldTxt = ccui.Text:create()
    curGoldTxt:setFontSize(22)
    curGoldTxt:setColor(cc.c3b(200,191,100))
    curGoldTxt:setString("0")
    curGoldTxt:setPosition(390, 150)
    curGoldTxt:setAnchorPoint(cc.p(0, 0.5))
    bankConainer:addChild(curGoldTxt)
    self.curGoldTxt = curGoldTxt;

    --取钱
    self.quprogress = cc.ControlSlider:create("hall/bank/bank_process_bg.png","hall/bank/bank_process_blue.png","hall/bank/bank_process_button.png")
    self.quprogress:setPosition(cc.p(216, 70))
    bankConainer:addChild(self.quprogress)
    self.quprogress:setMinimumValue(0);
    self.quprogress:setMaximumValue(100);
    self.quprogress:registerControlEventHandler(
        function ()
            self:quprogressHandler(self.quprogress)
        end,cc.CONTROL_EVENTTYPE_VALUE_CHANGED
    )

    local qutips = ccui.ImageView:create("hall/bank/slide_money_bg.png")
    qutips:setPosition(80, 105)
    self.qutips = qutips;
    bankConainer:addChild(qutips)
    local qutxt = ccui.Text:create()
    qutxt:setFontSize(18)
    qutxt:setColor(cc.c3b(182,153,121))
    qutxt:setString("0")
    qutxt:setPosition(40, 15)
    qutips:addChild(qutxt)
    self.qutxt = qutxt;

    local qubutton = ccui.Button:create();
    qubutton:loadTextures("hall/bank/qu_btn.png", "hall/bank/qu_btn_selected.png")
    qubutton:setPosition(cc.p(590, 70));
    bankConainer:addChild(qubutton);
    qubutton:setPressedActionEnabled(true);
    qubutton:getTitleRenderer():enableOutline(COLOR_BTN_GREEN,2)
    qubutton:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then

                self:qubuttonHandler();

            end
        end
    )
    local zeroGoldTxt = ccui.Text:create()
    zeroGoldTxt:setFontSize(22)
    zeroGoldTxt:setColor(cc.c3b(200,191,100))
    zeroGoldTxt:setString("0")
    zeroGoldTxt:setPosition(40, 70)
    bankConainer:addChild(zeroGoldTxt)

    local curInsureTxt = ccui.Text:create()
    curInsureTxt:setFontSize(22)
    curInsureTxt:setColor(cc.c3b(200,191,100))
    curInsureTxt:setString("0")
    curInsureTxt:setPosition(390, 70)
    curInsureTxt:setAnchorPoint(cc.p(0, 0.5))
    bankConainer:addChild(curInsureTxt)
    self.curInsureTxt = curInsureTxt;
end

function BankLayer:cunprogressHandler(sender)
    local value = sender:getValue();

    local scoreNow = self.score*value/100.0;
    local widthmax = self.cunprogress:getContentSize().width
    local posX = 80+widthmax*value/100.0
    self.cuntips:setPositionX(posX);
    self.selectScore = math.floor(scoreNow)
    self.cuntxt:setString(FormatNumToString(self.selectScore)) --print("---self.selectScore----", self.selectScore)
end

function BankLayer:quprogressHandler( sender )
    local value = sender:getValue();

    local insureNow = self.insure*value/100.0;
    local widthmax = self.quprogress:getContentSize().width
    local posX = 80+widthmax*value/100.0
    self.qutips:setPositionX(posX);

    self.selectInsure = math.floor(insureNow);
    self.qutxt:setString(FormatNumToString(self.selectInsure))
end

function BankLayer:resetProgress()
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


--取钱
function BankLayer:qubuttonHandler()
    if self.insure <=0 then
        Hall.showTips("您没有可以去的金币了，请前往商城去充值吧", 1)
        return
    end

    if self.selectInsure > 0 then
        if self.inGame then
            BankInfoInGame:sendWithdrawRequest(self.selectInsure)
        else
            BankInfo:sendWithdrawRequest(self.selectInsure)
        end
        

    end
end
--存钱
function BankLayer:cunbuttonHandler()
	if self.inGame == false then
        if self.selectScore > 0 then
            -- UserService:saveScoreToBank(self.selectScore)
            BankInfo:sendDepositRequest(self.selectScore)
        end
    else
        Hall.showTips("游戏中不能存筹码",2) 
    end
end

--查询成功
function BankLayer:queryBackHandler(event)
    -- self.score = event.score;
    -- self.insure = event.insure;
    -- self.curGoldValue:setString(FormatDigitToString(self.score, 1))
    -- self.curInsureGoldValue:setString(FormatDigitToString(self.insure, 1))
    -- self.curGoldTxt:setString(FormatDigitToString(self.score, 1))
    -- self.curInsureTxt:setString(FormatDigitToString(self.insure, 1))
    self:bankSucceseHandler(event)
end

--银行操作成功
function BankLayer:bankSucceseHandler(event)
    self.score = AccountInfo.score;
    self.insure = AccountInfo.insure;
    print("score",AccountInfo.score,AccountInfo.insure)
    self.curInsureGoldValue:setString(FormatNumToString(AccountInfo.insure))
    self.curGoldValue:setString(FormatNumToString(AccountInfo.score));
    self.curInsureTxt:setString(FormatNumToString(AccountInfo.insure))
    self.curGoldTxt:setString(FormatNumToString(AccountInfo.score));

    self:resetProgress();
end

--银行操作失败
function BankLayer:bankFailureHandler(event)
    Hall.showTips(event.msg)
end

function BankLayer:registerGameEvent()
    -- self.handler1 = UserService:addEventListener(HallCenterEvent.EVENT_QUERY_INSURE_FOR_ROOMBANK, handler(self, self.queryBackHandler))
    -- self.handler2 = UserService:addEventListener(HallCenterEvent.EVENT_USERINSURE_SUCCESS, handler(self, self.bankSucceseHandler))
    -- self.handler3 = UserService:addEventListener(HallCenterEvent.EVENT_USERINSURE_FAILURE, handler(self, self.bankFailureHandler))
    self.bindIds = {}
    -- self.bindIds[#self.bindIds + 1] = BindTool.bind(AccountInfo, "score", handler(self, self.bankSucceseHandler))
    self.bindIds[#self.bindIds + 1] = BindTool.bind(AccountInfo, "insure", handler(self, self.bankSucceseHandler))
end

function BankLayer:removeGameEvent()
    -- UserService:removeEventListener(self.handler1)
    -- UserService:removeEventListener(self.handler2)
    -- UserService:removeEventListener(self.handler3)
    for _, bindid in ipairs(self.bindIds) do
        BindTool.unbind(bindid)
    end
end

return BankLayer